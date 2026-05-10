import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../models/skill_params.dart';
import '../services/opencode_service.dart';
import 'base_yaml_command.dart';

abstract class BaseSkillCommand extends BaseYamlCommand {
  final http.Client httpClient;
  final Map<String, String>? _environment;

  BaseSkillCommand({
    required super.logger,
    required this.httpClient,
    super.defaultOutputDir,
    super.defaultConfigPath,
    Map<String, String>? environment,
  }) : _environment = environment {
    argParser
      ..addOption(
        'thinking-budget',
        help: 'Token budget for model thinking (default: 4096)',
        defaultsTo: '4096',
      )
      ..addFlag(
        'dry-run',
        abbr: 'n',
        help: 'Simulate without API calls or file writes',
        defaultsTo: false,
      );
  }

  Map<String, String> get _env =>
      _environment ?? Platform.environment;

  @override
  Future<void> runWithSkills(
    List<SkillParams> skills,
    String outputDir,
  ) async {
    final apiKey = _env['OPENCODE_API_KEY'];
    final baseUrl = _env['OPENCODE_BASE_URL'];
    final model = _env['OPENCODE_MODEL'] ?? 'deepseek-v4-pro';

    if (apiKey == null || apiKey.isEmpty) {
      logger.severe('OPENCODE_API_KEY environment variable is not set');
      return;
    }
    if (baseUrl == null || baseUrl.isEmpty) {
      logger.severe('OPENCODE_BASE_URL environment variable is not set');
      return;
    }

    final service = OpenCodeService(
      baseUrl: baseUrl,
      apiKey: apiKey,
      model: model,
      client: httpClient,
      logger: logger,
    );

    for (final skill in skills) {
      try {
        await runSkill(skill, outputDir, service);
      } on Exception catch (e) {
        logger.severe('Failed to process ${skill.name}: $e');
      }
    }
  }

  Future<void> runSkill(
    SkillParams skill,
    String outputDir,
    OpenCodeService service,
  );
}
