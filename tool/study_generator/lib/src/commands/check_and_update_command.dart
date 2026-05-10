import 'dart:io';

import '../models/skill_params.dart';
import '../services/hash_service.dart';
import '../services/metadata_service.dart';
import '../services/opencode_service.dart';
import '../services/resource_fetcher_service.dart';
import 'base_skill_command.dart';

enum UpdateStatus {
  skipped,
  autoMerged,
  needsReview,
  fetchFailed,
  changesDetected,
}

class SkillResult {
  final String skillName;
  final UpdateStatus status;
  final int? grade;
  final String? validationPath;
  final String? errorDetail;

  const SkillResult({
    required this.skillName,
    required this.status,
    this.grade,
    this.validationPath,
    this.errorDetail,
  });

  factory SkillResult.fromGrade({
    required String skillName,
    required int grade,
    required int threshold,
    required String validationPath,
  }) {
    return SkillResult(
      skillName: skillName,
      status: grade >= threshold ? UpdateStatus.autoMerged : UpdateStatus.needsReview,
      grade: grade,
      validationPath: validationPath,
    );
  }

  factory SkillResult.skipped(String skillName) {
    return SkillResult(skillName: skillName, status: UpdateStatus.skipped);
  }

  factory SkillResult.fetchFailed(String skillName, String error) {
    return SkillResult(
      skillName: skillName,
      status: UpdateStatus.fetchFailed,
      errorDetail: error,
    );
  }
}

class CheckAndUpdateCommand extends BaseSkillCommand {
  final HashService _hashService;
  final MetadataService _metadataService;
  final List<SkillResult> _results = <SkillResult>[];

  CheckAndUpdateCommand({
    required super.logger,
    required super.httpClient,
    super.defaultOutputDir,
    super.defaultConfigPath,
    super.environment,
    HashService? hashService,
    MetadataService? metadataService,
  })  : _hashService = hashService ?? HashService(),
        _metadataService = metadataService ?? MetadataService() {
    argParser.addOption(
      'threshold',
      help: 'Minimum validation grade for auto-merge (default: 85)',
      defaultsTo: '85',
    );
  }

  @override
  String get name => 'check-and-update';

  @override
  String get description =>
      'Check dart.cn docs for changes and auto-update SKILL.md files';

  @override
  Future<void> runWithSkills(List<SkillParams> skills, String outputDir) async {
    _results.clear();
    final isDryRun = argResults!['dry-run'] as bool;
    if (isDryRun) {
      for (final skill in skills) {
        try {
          await _checkForChanges(skill, outputDir);
        } on Exception catch (e) {
          logger.severe('Failed to check ${skill.name}: $e');
          _results.add(SkillResult.fetchFailed(skill.name, e.toString()));
        }
      }
    } else {
      await super.runWithSkills(skills, outputDir);
    }
    _printReport();
  }

  @override
  Future<void> runSkill(
    SkillParams skill,
    String outputDir,
    OpenCodeService service,
  ) async {
    final threshold = int.parse(argResults!['threshold'] as String);

    final fetcher = ResourceFetcherService(
      httpClient: httpClient,
      logger: logger,
    );

    try {
      final combinedMarkdown = await fetcher.fetchAndConvertContent(
        skill.resources,
        configDir: Directory(argResults!['config'] as String).parent,
      );

      if (combinedMarkdown.isEmpty) {
        logger.warning('No content fetched for ${skill.name}, skipping');
        _results.add(SkillResult.fetchFailed(skill.name, 'Empty content'));
        return;
      }

      final newHash = _hashService.computeHash(combinedMarkdown);
      final storedHash = _metadataService.loadHash(skill.name, outputDir);

      if (storedHash != null && storedHash == newHash) {
        logger.info('  No changes detected for ${skill.name}');
        _results.add(SkillResult.skipped(skill.name));
        return;
      }

      logger.info('  Changes detected for ${skill.name}, updating...');

      final skillFile = File('$outputDir/${skill.name}/SKILL.md');
      final String originalContent;
      if (skillFile.existsSync()) {
        originalContent = skillFile.readAsStringSync();
      } else {
        logger.warning('  SKILL.md not found for ${skill.name}, generating fresh');
        originalContent = '';
      }

      final updatedContent = await service.updateSkillContent(
        existingContent: originalContent,
        markdown: combinedMarkdown,
        skillName: skill.name,
        description: skill.description,
        instructions: skill.instructions,
      );

      skillFile.parent.createSync(recursive: true);
      skillFile.writeAsStringSync(updatedContent);
      logger.info('  Updated ${skill.name}/SKILL.md');

      logger.info('  Validating ${skill.name}...');
      final report = await service.validateExistingSkillContent(
        markdown: combinedMarkdown,
        skillName: skill.name,
        instructions: skill.instructions,
        generationDate: DateTime.now().toUtc().toIso8601String(),
        modelName: 'deepseek-v4-pro',
        currentSkillContent: updatedContent,
      );

      final reportDir = Directory('validation/${skill.name}');
      reportDir.createSync(recursive: true);
      final reportPath = '${reportDir.path}/validation.md';
      File(reportPath).writeAsStringSync(report);

      final gradeMatch = RegExp(r'Grade:\s*(\d+)').firstMatch(report);
      final grade = gradeMatch != null ? int.tryParse(gradeMatch.group(1)!) ?? 0 : 0;

      logger.info('  ${skill.name}: Grade $grade/100');

      if (grade >= threshold) {
        _metadataService.saveUpdateResult(skill.name, outputDir, newHash, grade);
        logger.info('  ${skill.name}: AUTO-MERGED');
        _results.add(SkillResult.fromGrade(
          skillName: skill.name,
          grade: grade,
          threshold: threshold,
          validationPath: reportPath,
        ));
      } else {
        _revertSkillFile(skillFile, originalContent);
        logger.warning(
          '  ${skill.name}: NEEDS REVIEW (grade $grade < $threshold), SKILL.md reverted',
        );
        _results.add(SkillResult.fromGrade(
          skillName: skill.name,
          grade: grade,
          threshold: threshold,
          validationPath: reportPath,
        ));
      }
    } on Exception catch (e) {
      logger.severe('  Failed to process ${skill.name}: $e');
      _results.add(SkillResult.fetchFailed(skill.name, e.toString()));
    }
  }

  Future<void> _checkForChanges(SkillParams skill, String outputDir) async {
    final fetcher = ResourceFetcherService(
      httpClient: httpClient,
      logger: logger,
    );

    final combinedMarkdown = await fetcher.fetchAndConvertContent(
      skill.resources,
      configDir: Directory(argResults!['config'] as String).parent,
    );

    if (combinedMarkdown.isEmpty) {
      logger.warning('No content fetched for ${skill.name}');
      _results.add(SkillResult.fetchFailed(skill.name, 'Empty content'));
      return;
    }

    final newHash = _hashService.computeHash(combinedMarkdown);
    final storedHash = _metadataService.loadHash(skill.name, outputDir);

    if (storedHash != null && storedHash == newHash) {
      logger.info('  No changes detected for ${skill.name}');
      _results.add(SkillResult.skipped(skill.name));
    } else {
      logger.info('  [DRY RUN] Changes detected for ${skill.name}');
      _results.add(SkillResult(
        skillName: skill.name,
        status: UpdateStatus.changesDetected,
      ));
    }
  }

  void _revertSkillFile(File file, String originalContent) {
    try {
      if (originalContent.isEmpty) {
        if (file.existsSync()) file.deleteSync();
      } else {
        file.writeAsStringSync(originalContent);
      }
    } on Exception catch (e) {
      logger.warning('  Failed to revert ${file.path}: $e');
    }
  }

  void _printReport() {
    logger.info('');
    logger.info('=== Auto-Update Report ===');
    for (final result in _results) {
      switch (result.status) {
        case UpdateStatus.skipped:
          logger.info('${result.skillName}: SKIPPED (no changes)');
        case UpdateStatus.changesDetected:
          logger.info('${result.skillName}: CHANGES DETECTED');
        case UpdateStatus.autoMerged:
          logger.info(
            '${result.skillName}: AUTO-MERGED (grade ${result.grade}/100)',
          );
        case UpdateStatus.needsReview:
          logger.warning(
            '${result.skillName}: NEEDS REVIEW (grade ${result.grade}/100) '
            '-> see ${result.validationPath}',
          );
        case UpdateStatus.fetchFailed:
          logger.severe(
            '${result.skillName}: FETCH FAILED (${result.errorDetail})',
          );
      }
    }
  }
}
