import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../models/skill_params.dart';
import 'base_yaml_command.dart';

class UpdateReadmeCommand extends BaseYamlCommand {
  UpdateReadmeCommand({
    required super.logger,
    super.defaultOutputDir,
    super.defaultConfigPath,
  });

  @override
  String get name => 'update-readme';

  @override
  String get description =>
      'Update README.md with a table of available skills';

  @override
  Future<void> runWithSkills(
    List<SkillParams> skills,
    String outputDir,
  ) async {
    // Resolve README path
    String? readmePath = argResults!['readme'] as String?;
    readmePath ??= _findReadme();
    if (readmePath == null) {
      logger.severe('README.md not found');
      return;
    }

    final readmeFile = File(readmePath);
    var readmeContent = readmeFile.readAsStringSync();

    // Build skills table
    final buffer = StringBuffer();
    buffer.writeln('| Skill | Description | Example prompt |');
    buffer.writeln('|---|---|---|');

    final sorted = List<SkillParams>.from(skills)
      ..sort((a, b) => a.name.compareTo(b.name));

    for (final skill in sorted) {
      final link = _relativeLink(
        readmePath,
        '$outputDir/${skill.name}/SKILL.md',
      );
      final desc = skill.description.replaceAll('\n', ' ').trim();
      final prompt = skill.examplePrompt ?? '';
      buffer.writeln('| [$skill.name]($link) | $desc | $prompt |');
    }

    final table = buffer.toString();

    // Replace or append ## Available Skills section
    final sectionHeader =
        RegExp(r'^## Available Skills\s*$', multiLine: true);
    if (sectionHeader.hasMatch(readmeContent)) {
      final start = readmeContent.indexOf(sectionHeader);
      final afterHeader = readmeContent.indexOf('\n', start);
      final nextSection =
          RegExp(r'^## ', multiLine: true).matchAsPrefix(readmeContent, afterHeader + 1);
      if (nextSection != null) {
        readmeContent =
            '${readmeContent.substring(0, afterHeader + 1)}\n$table\n\n'
            '${readmeContent.substring(nextSection.start)}';
      } else {
        readmeContent =
            '${readmeContent.substring(0, afterHeader + 1)}\n$table\n';
      }
    } else {
      readmeContent += '\n## Available Skills\n\n$table\n';
    }

    readmeFile.writeAsStringSync(readmeContent);
    logger.info('Updated $readmePath');
  }

  String? _findReadme() {
    for (final path in ['../README.md', 'README.md']) {
      if (File(path).existsSync()) return path;
    }
    return null;
  }

  String _relativeLink(String fromPath, String toPath) {
    final from = p.normalize(File(fromPath).absolute.parent.path);
    final to = p.normalize(File(toPath).absolute.path);
    return p.relative(to, from: from).replaceAll(r'\', '/');
  }
}
