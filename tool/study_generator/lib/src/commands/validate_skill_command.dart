import 'dart:io';

import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

import '../models/skill_params.dart';
import '../services/markdown_converter.dart';
import '../services/opencode_service.dart';
import '../services/resource_fetcher_service.dart';
import 'base_skill_command.dart';

class ValidateSkillCommand extends BaseSkillCommand {
  final String _validationDir;

  ValidateSkillCommand({
    required super.logger,
    required super.httpClient,
    super.defaultOutputDir,
    super.defaultConfigPath,
    super.environment,
    String validationDir = 'validation',
  }) : _validationDir = validationDir;

  @override
  String get name => 'validate-skill';

  @override
  String get description =>
      'Validate existing SKILL.md files against source documentation';

  @override
  Future<void> run() async {
    // Pre-validate YAML structure before processing
    final configPath = argResults!['config'] as String;
    final configFile = File(configPath);
    if (configFile.existsSync()) {
      final yamlContent = loadYaml(configFile.readAsStringSync());
      if (yamlContent is YamlList) {
        for (final item in yamlContent) {
          if (item is! Map) {
            logger.severe('Config item is not a map');
            return;
          }
          final name = item['name'];
          if (name is! String ||
              !RegExp(r'^dart-[a-z0-9-]+$').hasMatch(name)) {
            logger.severe(
              'Invalid skill name: $name '
              '(must start with dart- and be kebab-case)',
            );
            return;
          }
          final resources = item['resources'];
          if (resources is! List || resources.isEmpty) {
            logger.severe('Skill $name has no resources');
            return;
          }
          for (final r in resources) {
            if (r is String && r.startsWith('http://')) {
              logger.severe('Insecure URL in $name: $r');
              return;
            }
          }
        }
      }
    }

    await super.run();
  }

  @override
  Future<void> runSkill(
    SkillParams skill,
    String outputDir,
    OpenCodeService service,
  ) async {
    final isDryRun = argResults!['dry-run'] as bool;

    final fetcher = ResourceFetcherService(
      httpClient: httpClient,
      logger: logger,
    );
    final combinedMarkdown = await fetcher.fetchAndConvertContent(
      skill.resources,
      configDir: Directory(argResults!['config'] as String).parent,
    );

    final skillFile = File('$outputDir/${skill.name}/SKILL.md');
    if (!skillFile.existsSync()) {
      logger.warning('SKILL.md not found for ${skill.name}');
      return;
    }
    final currentContent = skillFile.readAsStringSync();

    // Extract metadata from existing SKILL.md
    final nameMatch =
        RegExp(r'^name:\s*(.+)$', multiLine: true).firstMatch(currentContent);
    final dateMatch = RegExp(r'last_modified:\s*(.+)$', multiLine: true)
        .firstMatch(currentContent);
    final modelMatch =
        RegExp(r'model:\s*(.+)$', multiLine: true).firstMatch(currentContent);

    if (nameMatch != null && nameMatch.group(1)!.trim() != skill.name) {
      logger.severe(
        'Name mismatch in ${skill.name}: '
        'expected ${skill.name}, got ${nameMatch.group(1)}',
      );
      return;
    }

    if (isDryRun) {
      logger.info('[DRY RUN] Would validate ${skill.name}');
      return;
    }

    final generationDate = dateMatch?.group(1)?.trim() ?? 'Unknown';
    final modelName = modelMatch?.group(1)?.trim() ?? 'Unknown';

    logger.info('Validating ${skill.name}...');
    final report = await service.validateExistingSkillContent(
      markdown: combinedMarkdown,
      skillName: skill.name,
      instructions: skill.instructions,
      generationDate: generationDate,
      modelName: modelName,
      currentSkillContent: currentContent,
    );

    // Save validation report
    final reportDir = Directory('$_validationDir/${skill.name}');
    if (!reportDir.existsSync()) {
      reportDir.createSync(recursive: true);
    }
    File('${reportDir.path}/validation.md').writeAsStringSync(report);

    // Extract and log grade
    final gradeMatch = RegExp(r'Grade:\s*(\d+)').firstMatch(report);
    if (gradeMatch != null) {
      logger.info('${skill.name}: Grade ${gradeMatch.group(1)}/100');
    }
  }
}
