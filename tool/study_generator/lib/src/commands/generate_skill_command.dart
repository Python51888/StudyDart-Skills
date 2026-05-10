import 'dart:io';

import '../models/skill_params.dart';
import '../services/opencode_service.dart';
import '../services/resource_fetcher_service.dart';
import 'base_skill_command.dart';

class GenerateSkillCommand extends BaseSkillCommand {
  GenerateSkillCommand({
    required super.logger,
    required super.httpClient,
    super.defaultOutputDir,
    super.defaultConfigPath,
    super.environment,
  });

  @override
  String get name => 'generate-skill';

  @override
  String get description => 'Generate SKILL.md files from YAML config using AI';

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

    if (combinedMarkdown.isEmpty) {
      logger.warning('No content fetched for ${skill.name}, skipping');
      return;
    }

    if (isDryRun) {
      logger.info(
        '[DRY RUN] Would generate ${skill.name} '
        '(${combinedMarkdown.length} chars)',
      );
      return;
    }

    logger.info('Generating ${skill.name}...');
    final content = await service.generateSkillContent(
      markdown: combinedMarkdown,
      skillName: skill.name,
      description: skill.description,
      instructions: skill.instructions,
    );

    final skillDir = Directory('$outputDir/${skill.name}');
    if (!skillDir.existsSync()) {
      skillDir.createSync(recursive: true);
    }

    File('${skillDir.path}/SKILL.md').writeAsStringSync(content);
    logger.info('Generated ${skill.name}/SKILL.md');
  }
}
