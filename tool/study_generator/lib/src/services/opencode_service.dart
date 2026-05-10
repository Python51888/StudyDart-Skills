import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'prompts.dart';
import 'skill_instructions.dart';

/// Service for calling an OpenAI-compatible API to generate, update, and
/// validate skill content.
class OpenCodeService {
  final String _baseUrl;
  final String _apiKey;
  final String _model;
  final http.Client _client;
  final Logger _logger;

  static const defaultModel = 'deepseek-v4-pro';
  static const defaultTemperature = 0.2;
  static const defaultMaxTokens = 8192;

  OpenCodeService({
    required String baseUrl,
    required String apiKey,
    String model = defaultModel,
    required http.Client client,
    required Logger logger,
  })  : _baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl,
        _apiKey = apiKey,
        _model = model,
        _client = client,
        _logger = logger;

  /// Generates a new SKILL.md from source documentation.
  Future<String> generateSkillContent({
    required String markdown,
    required String skillName,
    required String description,
    String? instructions,
  }) async {
    final prompt = Prompts.createSkillPrompt(markdown, instructions);
    final content = await _sendRequest(skillInstructions, prompt);
    final cleaned = cleanContent(content);
    return _prependFrontMatter(cleaned, skillName, description);
  }

  /// Updates an existing SKILL.md with new source material.
  Future<String> updateSkillContent({
    required String existingContent,
    required String markdown,
    required String skillName,
    required String description,
    String? instructions,
  }) async {
    final prompt = Prompts.updateSkillPrompt(
      existingContent,
      markdown,
      instructions,
    );
    final content = await _sendRequest(skillInstructions, prompt);
    final cleaned = cleanContent(content);
    return _prependFrontMatter(cleaned, skillName, description);
  }

  /// Validates an existing skill against source documentation.
  Future<String> validateExistingSkillContent({
    required String markdown,
    required String skillName,
    String? instructions,
    required String generationDate,
    required String modelName,
    required String currentSkillContent,
  }) async {
    final prompt = Prompts.validateSkillPrompt(
      markdown,
      instructions,
      generationDate,
      modelName,
      currentSkillContent,
    );
    return _sendRequest(skillInstructions, prompt);
  }

  /// Sends a request to the OpenAI-compatible API.
  ///
  /// Retries up to 3 times on failure.
  Future<String> _sendRequest(
    String systemInstruction,
    String userPrompt,
  ) async {
    final url = Uri.parse('$_baseUrl/v1/chat/completions');

    final body = jsonEncode({
      'model': _model,
      'temperature': defaultTemperature,
      'max_tokens': defaultMaxTokens,
      'messages': [
        {'role': 'system', 'content': systemInstruction},
        {'role': 'user', 'content': userPrompt},
      ],
    });

    _logger.info('Sending request to $_model ...');

    Exception? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await _client.post(
          url,
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          body: body,
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final choices = data['choices'] as List;
          if (choices.isEmpty) {
            throw Exception('Empty response from API');
          }
          final message = choices[0]['message'] as Map<String, dynamic>;
          final text = message['content'] as String?;
          if (text == null || text.isEmpty) {
            throw Exception('Empty content in API response');
          }
          return text;
        } else {
          lastError = Exception(
            'API error ${response.statusCode}: ${response.body}',
          );
        }
      } on Exception catch (e) {
        lastError = e;
        if (attempt < 2) {
          _logger.warning('Attempt ${attempt + 1} failed: $e. Retrying...');
        }
      }
    }

    throw lastError ?? Exception('Unknown API error');
  }

  /// Prepends YAML frontmatter to generated content.
  String _prependFrontMatter(
    String content,
    String skillName,
    String description,
  ) {
    return '---\n'
        'name: $skillName\n'
        'description: $description\n'
        'metadata:\n'
        '  model: $_model\n'
        '  last_modified: ${DateTime.now().toUtc().toIso8601String()}\n'
        '---\n'
        '$content';
  }

  /// Cleans AI-generated content by removing code blocks and duplicate
  /// frontmatter.
  @visibleForTesting
  static String cleanContent(String? content) {
    if (content == null || content.isEmpty) return '';

    var cleaned = content.trimLeft();

    // Strip leading markdown code blocks (```markdown or ```)
    final codeBlockStart = RegExp(r'^```\w*\n', multiLine: true);
    if (codeBlockStart.hasMatch(cleaned)) {
      cleaned = cleaned.replaceFirst(codeBlockStart, '');
    }

    // Strip trailing markdown code blocks
    final codeBlockEnd = RegExp(r'```\s*$', multiLine: true);
    if (codeBlockEnd.hasMatch(cleaned.trimRight())) {
      cleaned = cleaned.replaceFirst(codeBlockEnd, '');
    }

    // Strip YAML frontmatter if the model included it
    if (cleaned.startsWith('---')) {
      final secondDelim = cleaned.indexOf('---', 3);
      if (secondDelim != -1) {
        cleaned = cleaned.substring(secondDelim + 3).trimLeft();
      }
    }

    // Ensure exactly one trailing newline
    cleaned = cleaned.trimRight();
    cleaned += '\n';

    return cleaned;
  }
}
