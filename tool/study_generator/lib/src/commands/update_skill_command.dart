import 'dart:io';

import '../models/skill_params.dart';
import '../services/opencode_service.dart';
import '../services/resource_fetcher_service.dart';
import 'base_skill_command.dart';

class UpdateSkillCommand extends BaseSkillCommand {
  UpdateSkillCommand({
    required super.logger,
    required super.httpClient,
    super.defaultOutputDir,
    super.defaultConfigPath,
    super.environment,
  });

  @override
  String get name => 'update-skill';

  @override
  String get description =>
      'Update existing SKILL.md files with new source content';

  @override
  Future<void> runSkill(
    SkillParams skill,
    String outputDir,
    OpenCodeService service,
  ) async {
    final isDryRun = argResults!['dry-run'] as bool;

    final existingFile = File('$outputDir/${skill.name}/SKILL.md');
    if (!existingFile.existsSync()) {
      logger.severe(
        'SKILL.md not found for ${skill.name}, use generate-skill first',
      );
      return;
    }
    final existingContent = existingFile.readAsStringSync();

    final fetcher = ResourceFetcherService(
      httpClient: httpClient,
      logger: logger,
    );
    final combinedMarkdown = await fetcher.fetchAndConvertContent(
      skill.resources,
      configDir: Directory(argResults!['config'] as String).parent,
    );

    if (combinedMarkdown.isEmpty) {
      logger.warning('No new content fetched for ${skill.name}');
      return;
    }

    if (isDryRun) {
      logger.info(
        '[DRY RUN] Would update ${skill.name} '
        '(existing: ${existingContent.length}, '
        'new source: ${combinedMarkdown.length} chars)',
      );
      return;
    }

    logger.info('Updating ${skill.name}...');
    final updatedContent = await service.updateSkillContent(
      existingContent: existingContent,
      markdown: combinedMarkdown,
      skillName: skill.name,
      description: skill.description,
      instructions: skill.instructions,
    );

    existingFile.writeAsStringSync(updatedContent);
    logger.info('Updated ${skill.name}/SKILL.md');
  }
}
