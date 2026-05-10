import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

import '../models/skill_params.dart';

abstract class BaseYamlCommand extends Command<void> {
  final Logger logger;

  BaseYamlCommand({
    required this.logger,
    String defaultOutputDir = '../skills',
    String defaultConfigPath = '../resources/studydart_skills.yaml',
  }) {
    argParser
      ..addOption(
        'config',
        help: 'Path to YAML config file',
        defaultsTo: defaultConfigPath,
      )
      ..addOption(
        'skill',
        help: 'Filter by skill name',
      )
      ..addOption(
        'directory',
        abbr: 'd',
        help: 'Output directory for skills',
        defaultsTo: defaultOutputDir,
      );
  }

  @override
  Future<void> run() async {
    final argResults = this.argResults!;
    final configPath = argResults['config'] as String;
    final outputDir = argResults['directory'] as String;
    final skillFilter = argResults['skill'] as String?;

    final configFile = File(configPath);
    if (!configFile.existsSync()) {
      logger.severe('Config file not found: $configPath');
      return;
    }

    final yamlContent = loadYaml(configFile.readAsStringSync());
    if (yamlContent is! YamlList) {
      logger.severe('Config must be a YAML list');
      return;
    }

    final skills = yamlContent
        .whereType<Map>()
        .map((m) => SkillParams.fromJson(m.cast<String, dynamic>()))
        .toList();

    final filtered = skillFilter != null
        ? skills.where((s) => s.name == skillFilter).toList()
        : skills;

    if (filtered.isEmpty) {
      logger.warning(
        skillFilter != null
            ? 'No skills match filter: $skillFilter'
            : 'No skills defined in config',
      );
      return;
    }

    await runWithSkills(filtered, outputDir);
  }

  Future<void> runWithSkills(List<SkillParams> skills, String outputDir);
}
