# studydart-skills Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a standalone Dart CLI tool that fetches dart.cn documentation pages and uses AI to generate 10 structured SKILL.md skill files, plus verify their quality.

**Architecture:** Four-command CLI (generate/update/validate/update-readme) driven by a YAML config. The core service calls an OpenAI-compatible API instead of Gemini. All commands share base classes for YAML parsing and API key management.

**Tech Stack:** Dart ^3.10.8, `args`, `http`, `html`, `yaml`, `path`, `file`, `logging`. API: OpenAI-compatible `/v1/chat/completions`.

---

### Task 1: Project Scaffold

**Files:**
- Create: `D:\MyProject\studydart-skills\tool\study_generator\pubspec.yaml`
- Create: `D:\MyProject\studydart-skills\tool\study_generator\analysis_options.yaml`
- Create: `D:\MyProject\studydart-skills\tool\study_generator\.gitignore`
- Create: `D:\MyProject\studydart-skills\.gitignore`

- [ ] **Step 1: Create directory structure**

Run:
```powershell
New-Item -ItemType Directory -Force -Path "D:\MyProject\studydart-skills\tool\study_generator\bin"
New-Item -ItemType Directory -Force -Path "D:\MyProject\studydart-skills\tool\study_generator\lib\src\commands"
New-Item -ItemType Directory -Force -Path "D:\MyProject\studydart-skills\tool\study_generator\lib\src\models"
New-Item -ItemType Directory -Force -Path "D:\MyProject\studydart-skills\tool\study_generator\lib\src\services"
New-Item -ItemType Directory -Force -Path "D:\MyProject\studydart-skills\resources"
New-Item -ItemType Directory -Force -Path "D:\MyProject\studydart-skills\skills"
```

- [ ] **Step 2: Write pubspec.yaml**

```yaml
name: study_generator
description: AI-powered skill generator for Dart CN documentation
version: 0.1.0
publish_to: 'none'

environment:
  sdk: ^3.10.8

dependencies:
  args: ^2.5.0
  file: ^7.0.1
  html: ^0.15.5
  http: ^1.2.2
  logging: ^1.3.0
  meta: ^1.15.0
  path: ^1.9.1
  platform: ^3.1.5
  yaml: ^3.1.3

dev_dependencies:
  lints: ^5.1.1
  test: ^1.25.0
```

- [ ] **Step 3: Write analysis_options.yaml**

```yaml
include: package:lints/recommended.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

linter:
  rules:
    - always_declare_return_types
    - avoid_dynamic_calls
    - avoid_print
    - avoid_void_async
    - camel_case_types
    - constant_identifier_names
    - prefer_const_constructors
    - prefer_single_quotes
    - require_trailing_commas
    - unawaited_futures
```

- [ ] **Step 4: Write root .gitignore**

```
.dart_tool/
.packages
.pub/
build/
```

- [ ] **Step 5: Run dart pub get**

Run:
```powershell
dart pub get
```
Workdir: `D:\MyProject\studydart-skills\tool\study_generator`

- [ ] **Step 6: Commit**

```bash
git init
git add -A
git commit -m "chore: scaffold project structure"
```
Workdir: `D:\MyProject\studydart-skills`

---

### Task 2: SkillParams Model & YAML Config

**Files:**
- Create: `tool\study_generator\lib\src\models\skill_params.dart`
- Create: `resources\studydart_skills.yaml`

- [ ] **Step 1: Write SkillParams model**

```dart
class SkillParams {
  final String name;
  final String description;
  final String? examplePrompt;
  final String? instructions;
  final List<String> resources;

  const SkillParams({
    required this.name,
    required this.description,
    this.examplePrompt,
    this.instructions,
    required this.resources,
  });

  factory SkillParams.fromJson(Map<String, dynamic> json) {
    return SkillParams(
      name: json['name'] as String,
      description: json['description'] as String,
      examplePrompt: json['examplePrompt'] as String?,
      instructions: json['instructions'] as String?,
      resources: (json['resources'] as List).cast<String>(),
    );
  }
}
```

- [ ] **Step 2: Write studydart_skills.yaml**

Copy the 10 skill definitions from the DESIGN.md (section 三) into YAML format. Each entry includes `name`, `description`, `examplePrompt`, `instructions`, and `resources`. All URLs use `https://` prefix. All names are kebab-case starting with `dart-`.

**Verify:** Each entry has:
- `name` — lowercase, kebab-case, starts with `dart-`
- `description` — 1-2 sentences
- `resources` — non-empty list, all `https://` URLs

- [ ] **Step 3: Commit**

```bash
git add resources/studydart_skills.yaml tool/study_generator/lib/src/models/skill_params.dart
git commit -m "feat: add skill params model and YAML config"
```

---

### Task 3: MarkdownConverter Service

**Files:**
- Create: `tool\study_generator\lib\src\services\markdown_converter.dart`

- [ ] **Step 1: Write MarkdownConverter**

Port from `D:\MyProject\skills\tool\generator\lib\src\services\markdown_converter.dart`. The class is self-contained with a single method `String convert(String htmlContent)`. It walks the DOM tree and converts HTML elements to Markdown equivalents (h1-h6 → #,##, p → text, a → [text](href), code → backticks, pre → fenced code, ul/ol → list items, table → markdown table, img → ![alt](src), etc.).

**Key implementation notes:**
- Uses `package:html` to parse
- Recursively walks `Node` tree
- Handles: h1-h6, p, a, strong/b, em/i, del/s/strike, code, pre, blockquote, hr, ul/ol/li, img, video, iframe, table/thead/tbody/tr/th/td, dl/dt/dd, details/summary, br, div/section/main/article
- Unknown tags pass through content only

- [ ] **Step 2: Quick manual test**

Run:
```dart
void main() {
  final converter = MarkdownConverter();
  final html = '<h1>Title</h1><p>Hello <strong>world</strong></p>';
  print(converter.convert(html));
  // Expected: # Title\n\nHello **world**
}
```

- [ ] **Step 3: Commit**

```bash
git add tool/study_generator/lib/src/services/markdown_converter.dart
git commit -m "feat: add HTML to Markdown converter"
```

---

### Task 4: ResourceFetcherService

**Files:**
- Create: `tool\study_generator\lib\src\services\resource_fetcher_service.dart`

- [ ] **Step 1: Write ResourceFetcherService**

Port from `D:\MyProject\skills\tool\generator\lib\src\services\resource_fetcher_service.dart`. Core method:

```dart
class ResourceFetcherService {
  final http.Client _client;
  final MarkdownConverter _markdownConverter;

  ResourceFetcherService(this._client, this._markdownConverter);

  Future<String> fetchAndConvertContent(
    List<String> resources, {
    String? configDir,
  }) async {
    final buffer = StringBuffer();
    for (final resource in resources) {
      if (resource.startsWith('https://')) {
        final response = await _client.get(Uri.parse(resource));
        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode} for $resource');
        }
        final markdown = _markdownConverter.convert(response.body);
        buffer.writeln('--- Raw content from $resource ---');
        buffer.writeln(markdown);
      } else if (resource.startsWith('http://')) {
        throw Exception('Insecure HTTP not allowed: $resource');
      } else {
        // Relative path: read local file relative to configDir
        if (configDir == null) {
          throw Exception('configDir required for relative path: $resource');
        }
        final file = File(path.join(configDir, resource));
        if (!file.existsSync()) {
          throw Exception('File not found: ${file.path}');
        }
        buffer.writeln('--- Raw content from ${file.path} ---');
        buffer.writeln(file.readAsStringSync());
      }
    }
    return buffer.toString();
  }
}
```

Key behaviors:
- Fail-fast on any fetch error (to avoid wasting AI tokens)
- Add `--- Raw content from {url} ---` header before each resource
- Throw on insecure HTTP URLs
- Resolve relative paths against configDir

- [ ] **Step 2: Commit**

```bash
git add tool/study_generator/lib/src/services/resource_fetcher_service.dart
git commit -m "feat: add resource fetcher service"
```

---

### Task 5: Skill Instructions & Prompts

**Files:**
- Create: `tool\study_generator\lib\src\services\skill_instructions.dart`
- Create: `tool\study_generator\lib\src\services\prompts.dart`

- [ ] **Step 1: Write skill_instructions.dart**

Port from `D:\MyProject\skills\tool\generator\lib\src\services\skill_instructions.dart`. This is the system instruction injected into every AI call. Key rules:

```dart
const String skillInstructions = '''
You are an Expert Skill Author for Dart development. Guidelines:

1. **Concise & Expert** — Assume the reader is a competent Dart developer.
   Every paragraph must justify its token cost.

2. **Imperative mood** — Write "Use List.generate()" not "The developer should use..."

3. **Single file** — No external references. All content inline.

4. **Naming** — Use gerund form: "Declaring Variables" not "Variable Declaration"

5. **Workflows & feedback loops** — Every skill must have:
   - Task Progress checklist with checkboxes
   - Conditional logic: "If ... then ... else ..."
   - Feedback loop: "Run → Review → Fix → Repeat until passing"

6. **Examples** — Provide complete, runnable Dart code (imports included).

Formatting rules:
- No YAML frontmatter in your response
- Raw markdown, NOT wrapped in ```
- Structure: # Title → ## Contents → ## Sections → ## Workflow → ## Examples
''';
```

- [ ] **Step 2: Write prompts.dart**

Port from `D:\MyProject\skills\tool\generator\lib\src\services\prompts.dart`. Three prompt methods:

```dart
class Prompts {
  static String createSkillPrompt(String markdown, String? instructions) {
    final buffer = StringBuffer();
    buffer.writeln('Rewrite the following technical documentation into a high-quality SKILL.md file.');
    buffer.writeln();
    buffer.writeln('Return ONLY the SKILL.md content as raw markdown. Do NOT wrap in triple backticks. Do NOT include YAML frontmatter.');
    buffer.writeln();
    if (instructions != null && instructions.isNotEmpty) {
      buffer.writeln('Additional instructions:');
      buffer.writeln(instructions);
      buffer.writeln();
    }
    buffer.writeln('--- SOURCE DOCUMENTATION ---');
    buffer.writeln(markdown);
    return buffer.toString();
  }

  static String updateSkillPrompt(
    String existingContent,
    String markdown,
    String? instructions,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('Update the following existing SKILL.md file by incorporating new information from the source documentation.');
    buffer.writeln('Preserve existing content that is still accurate. Update what has changed. Add what is new.');
    buffer.writeln();
    buffer.writeln('Return ONLY the updated SKILL.md content as raw markdown. Do NOT wrap in triple backticks. Do NOT include YAML frontmatter.');
    buffer.writeln();
    if (instructions != null && instructions.isNotEmpty) {
      buffer.writeln('Additional instructions:');
      buffer.writeln(instructions);
      buffer.writeln();
    }
    buffer.writeln('--- EXISTING SKILL.md ---');
    buffer.writeln(existingContent);
    buffer.writeln();
    buffer.writeln('--- NEW SOURCE DOCUMENTATION ---');
    buffer.writeln(markdown);
    return buffer.toString();
  }

  static String validateSkillPrompt(
    String markdown,
    String? instructions,
    String generationDate,
    String modelName,
    String currentContent,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('Validate the following skill document against the provided source material.');
    buffer.writeln();
    buffer.writeln('Context: This skill was generated on $generationDate using model $modelName.');
    buffer.writeln();
    if (instructions != null && instructions.isNotEmpty) {
      buffer.writeln('Original generation instructions:');
      buffer.writeln(instructions);
      buffer.writeln();
    }
    buffer.writeln('Evaluate:');
    buffer.writeln('1. Does the skill accurately reflect the source documentation?');
    buffer.writeln('2. Are there any factual errors or omissions?');
    buffer.writeln('3. Does the skill follow best practices for agent skills (workflows, checklists, conditional logic)?');
    buffer.writeln('4. Are the code examples correct and complete?');
    buffer.writeln();
    buffer.writeln('Provide a detailed report. The VERY LAST LINE must be: Grade: [0-100]');
    buffer.writeln();
    buffer.writeln('--- SOURCE DOCUMENTATION ---');
    buffer.writeln(markdown);
    buffer.writeln();
    buffer.writeln('--- SKILL TO VALIDATE ---');
    buffer.writeln(currentContent);
    return buffer.toString();
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add tool/study_generator/lib/src/services/skill_instructions.dart tool/study_generator/lib/src/services/prompts.dart
git commit -m "feat: add skill instructions and prompt templates"
```

---

### Task 6: OpenCodeService (Core: replaces GeminiService)

**Files:**
- Create: `tool\study_generator\lib\src\services\opencode_service.dart`

- [ ] **Step 1: Write OpenCodeService**

This is the only file that differs substantially from the original. It uses OpenAI-compatible API instead of Gemini:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class OpenCodeService {
  final String _baseUrl;
  final String _apiKey;
  final String _model;
  final http.Client _client;
  final Logger logger;

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
        logger = logger;

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

    logger.info('Sending request to $_model ...');

    // Retry up to 3 times
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
        logger.warning('Attempt ${attempt + 1} failed: $e');
      }
    }
    throw lastError ?? Exception('Unknown API error');
  }

  String _prependFrontMatter(
    String content,
    String skillName,
    String description,
  ) {
    final now = DateTime.now().toUtc().toString().substring(0, 19);
    return '---\n'
        'name: $skillName\n'
        'description: $description\n'
        'metadata:\n'
        '  model: $_model\n'
        '  last_modified: $now\n'
        '---\n'
        '$content';
  }

  @visibleForTesting
  static String cleanContent(String? content) {
    if (content == null || content.isEmpty) return '';

    var cleaned = content.trimLeft();

    // Strip leading markdown code blocks
    final codeBlockPattern = RegExp(r'^```\w*\n', multiLine: true);
    if (codeBlockPattern.hasMatch(cleaned)) {
      cleaned = cleaned.replaceFirst(codeBlockPattern, '');
    }

    // Strip trailing markdown code blocks
    if (cleaned.endsWith('```\n')) {
      cleaned = cleaned.substring(0, cleaned.length - 3).trimRight();
    } else if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3).trimRight();
    }

    // Strip YAML frontmatter if present
    if (cleaned.startsWith('---')) {
      final secondDelim = cleaned.indexOf('---', 3);
      if (secondDelim != -1) {
        cleaned = cleaned.substring(secondDelim + 3).trimLeft();
      }
    }

    // Ensure trailing newline
    if (!cleaned.endsWith('\n')) {
      cleaned += '\n';
    }

    return cleaned;
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add tool/study_generator/lib/src/services/opencode_service.dart
git commit -m "feat: add OpenCodeService (OpenAI-compatible API)"
```

---

### Task 7: Base Commands

**Files:**
- Create: `tool\study_generator\lib\src\commands\base_yaml_command.dart`
- Create: `tool\study_generator\lib\src\commands\base_skill_command.dart`

- [ ] **Step 1: Write BaseYamlCommand**

Port from `D:\MyProject\skills\tool\generator\lib\src\commands\base_yaml_command.dart`:

```dart
import 'dart:io';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';
import '../models/skill_params.dart';

abstract class BaseYamlCommand extends Command<void> {
  final Logger logger;
  final String _defaultOutputDir;
  final String _defaultConfigPath;

  BaseYamlCommand({
    required this.logger,
    required String defaultOutputDir,
    String defaultConfigPath = '../resources/studydart_skills.yaml',
  })  : _defaultOutputDir = defaultOutputDir,
        _defaultConfigPath = defaultConfigPath {
    argParser
      ..addOption(
        'config',
        help: 'Path to YAML config file',
        defaultsTo: _defaultConfigPath,
      )
      ..addOption(
        'skill',
        help: 'Filter by skill name',
      )
      ..addOption(
        'directory',
        abbr: 'd',
        help: 'Output directory for skills',
        defaultsTo: _defaultOutputDir,
      );
  }

  @override
  Future<void> run() async {
    final argResults = argResults!;
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

  Future<void> runWithSkills(
    List<SkillParams> skills,
    String outputDir,
  );
}
```

- [ ] **Step 2: Write BaseSkillCommand**

Port from `D:\MyProject\skills\tool\generator\lib\src\commands\base_skill_command.dart`. Extends BaseYamlCommand, adds `--thinking-budget` (for compatibility, though may not be used), `--dry-run` flag, validates `OPENCODE_API_KEY`, `OPENCODE_BASE_URL` env vars, creates `OpenCodeService`:

```dart
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../models/skill_params.dart';
import '../services/opencode_service.dart';

abstract class BaseSkillCommand extends BaseYamlCommand {
  final http.Client httpClient;
  final Map<String, String>? _environment;

  BaseSkillCommand({
    required super.logger,
    required super.defaultOutputDir,
    required this.httpClient,
    Map<String, String>? environment,
    String defaultConfigPath = '../resources/studydart_skills.yaml',
  })  : _environment = environment,
        super(
          logger: logger,
          defaultOutputDir: defaultOutputDir,
          defaultConfigPath: defaultConfigPath,
        ) {
    argParser
      ..addOption('thinking-budget',
        help: 'Token budget for model thinking (default: 4096)',
        defaultsTo: '4096',
      )
      ..addFlag('dry-run',
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
      client: _httpClient,
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
```

- [ ] **Step 3: Commit**

```bash
git add tool/study_generator/lib/src/commands/base_yaml_command.dart tool/study_generator/lib/src/commands/base_skill_command.dart
git commit -m "feat: add base command classes"
```

---

### Task 8: GenerateSkillCommand

**Files:**
- Create: `tool\study_generator\lib\src\commands\generate_skill_command.dart`

- [ ] **Step 1: Write GenerateSkillCommand**

Port from `D:\MyProject\skills\tool\generator\lib\src\commands\generate_skill_command.dart`:

```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../models/skill_params.dart';
import '../services/markdown_converter.dart';
import '../services/opencode_service.dart';
import '../services/resource_fetcher_service.dart';
import 'base_skill_command.dart';

class GenerateSkillCommand extends BaseSkillCommand {
  GenerateSkillCommand({
    required super.logger,
    required super.defaultOutputDir,
    required super.httpClient,
    super.environment,
    super.defaultConfigPath,
  });

  @override
  String get name => 'generate-skill';

  @override
  String get description =>
      'Generate SKILL.md files from YAML config using AI';

  @override
  Future<void> runSkill(
    SkillParams skill,
    String outputDir,
    OpenCodeService service,
  ) async {
    final isDryRun = argResults!['dry-run'] as bool;

    // Fetch and convert resources
    final fetcher = ResourceFetcherService(
      httpClient,
      MarkdownConverter(),
    );
    final combinedMarkdown = await fetcher.fetchAndConvertContent(
      skill.resources,
      configDir: File(argResults!['config'] as String).parent.path,
    );

    if (combinedMarkdown.isEmpty) {
      logger.warning('No content fetched for ${skill.name}, skipping');
      return;
    }

    if (isDryRun) {
      logger.info('[DRY RUN] Would generate ${skill.name} (${combinedMarkdown.length} chars)');
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
```

- [ ] **Step 2: Commit**

```bash
git add tool/study_generator/lib/src/commands/generate_skill_command.dart
git commit -m "feat: add generate-skill command"
```

---

### Task 9: UpdateSkillCommand

**Files:**
- Create: `tool\study_generator\lib\src\commands\update_skill_command.dart`

- [ ] **Step 1: Write UpdateSkillCommand**

Port from `D:\MyProject\skills\tool\generator\lib\src\commands\update_skill_command.dart`:

```dart
import 'dart:io';
import 'package:logging/logging.dart';
import '../models/skill_params.dart';
import '../services/markdown_converter.dart';
import '../services/opencode_service.dart';
import '../services/resource_fetcher_service.dart';
import 'base_skill_command.dart';

class UpdateSkillCommand extends BaseSkillCommand {
  UpdateSkillCommand({
    required super.logger,
    required super.defaultOutputDir,
    required super.httpClient,
    super.environment,
    super.defaultConfigPath,
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

    // Check existing SKILL.md
    final existingFile = File('$outputDir/${skill.name}/SKILL.md');
    if (!existingFile.existsSync()) {
      logger.severe('SKILL.md not found for ${skill.name}, use generate-skill first');
      return;
    }
    final existingContent = existingFile.readAsStringSync();

    // Fetch new resources
    final fetcher = ResourceFetcherService(
      httpClient,
      MarkdownConverter(),
    );
    final combinedMarkdown = await fetcher.fetchAndConvertContent(
      skill.resources,
      configDir: File(argResults!['config'] as String).parent.path,
    );

    if (combinedMarkdown.isEmpty) {
      logger.warning('No new content fetched for ${skill.name}');
      return;
    }

    if (isDryRun) {
      logger.info('[DRY RUN] Would update ${skill.name} (existing: ${existingContent.length}, new source: ${combinedMarkdown.length} chars)');
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
```

- [ ] **Step 2: Commit**

```bash
git add tool/study_generator/lib/src/commands/update_skill_command.dart
git commit -m "feat: add update-skill command"
```

---

### Task 10: ValidateSkillCommand

**Files:**
- Create: `tool\study_generator\lib\src\commands\validate_skill_command.dart`

- [ ] **Step 1: Write ValidateSkillCommand**

Port from `D:\MyProject\skills\tool\generator\lib\src\commands\validate_skill_command.dart`:

```dart
import 'dart:io';
import 'package:logging/logging.dart';
import '../models/skill_params.dart';
import '../services/markdown_converter.dart';
import '../services/opencode_service.dart';
import '../services/resource_fetcher_service.dart';
import 'base_skill_command.dart';

class ValidateSkillCommand extends BaseSkillCommand {
  final String _validationDir;

  ValidateSkillCommand({
    required super.logger,
    required super.defaultOutputDir,
    required super.httpClient,
    String validationDir = 'validation',
    super.environment,
    super.defaultConfigPath,
  }) : _validationDir = validationDir;

  @override
  String get name => 'validate-skill';

  @override
  String get description =>
      'Validate existing SKILL.md files against source documentation';

  @override
  Future<void> run() async {
    // Pre-validate YAML structure
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
          if (name is! String || !RegExp(r'^dart-[a-z0-9-]+$').hasMatch(name)) {
            logger.severe('Invalid skill name: $name (must start with dart- and be kebab-case)');
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

    // Fetch source documentation
    final fetcher = ResourceFetcherService(
      httpClient,
      MarkdownConverter(),
    );
    final combinedMarkdown = await fetcher.fetchAndConvertContent(
      skill.resources,
      configDir: File(argResults!['config'] as String).parent.path,
    );

    // Read existing SKILL.md
    final skillFile = File('$outputDir/${skill.name}/SKILL.md');
    if (!skillFile.existsSync()) {
      logger.warning('SKILL.md not found for ${skill.name}');
      return;
    }
    final currentContent = skillFile.readAsStringSync();

    // Extract metadata
    final nameMatch = RegExp(r'^name:\s*(.+)$', multiLine: true).firstMatch(currentContent);
    final dateMatch = RegExp(r'last_modified:\s*(.+)$', multiLine: true).firstMatch(currentContent);
    final modelMatch = RegExp(r'model:\s*(.+)$', multiLine: true).firstMatch(currentContent);

    if (nameMatch != null && nameMatch.group(1)!.trim() != skill.name) {
      logger.severe('Name mismatch in ${skill.name}: expected ${skill.name}, got ${nameMatch.group(1)}');
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

    // Extract grade
    final gradeMatch = RegExp(r'Grade:\s*(\d+)').firstMatch(report);
    if (gradeMatch != null) {
      logger.info('${skill.name}: Grade ${gradeMatch.group(1)}/100');
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add tool/study_generator/lib/src/commands/validate_skill_command.dart
git commit -m "feat: add validate-skill command"
```

---

### Task 11: UpdateReadmeCommand

**Files:**
- Create: `tool\study_generator\lib\src\commands\update_readme_command.dart`

- [ ] **Step 1: Write UpdateReadmeCommand**

Port from `D:\MyProject\skills\tool\generator\lib\src\commands\update_readme_command.dart`. This command auto-generates the skills table in README.md:

```dart
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import '../models/skill_params.dart';
import 'base_yaml_command.dart';

class UpdateReadmeCommand extends BaseYamlCommand {
  UpdateReadmeCommand({
    required super.logger,
    required super.defaultOutputDir,
    super.defaultConfigPath,
  }) {
    argParser.addOption('readme',
      help: 'Path to README.md',
    );
  }

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
      final link = _relativeLink(readmePath, '$outputDir/${skill.name}/SKILL.md');
      final name = skill.name;
      final desc = skill.description.replaceAll('\n', ' ').trim();
      final prompt = skill.examplePrompt ?? '';
      buffer.writeln('| [$name]($link) | $desc | $prompt |');
    }

    final table = buffer.toString();

    // Replace or append section
    final sectionHeader = RegExp(r'## Available Skills\b', multiLine: true);
    if (sectionHeader.hasMatch(readmeContent)) {
      // Find the table between ## Available Skills and next ##
      final start = readmeContent.indexOf(sectionHeader);
      final afterHeader = readmeContent.indexOf('\n', start);
      // Find next ## heading after the section
      final nextSection = RegExp(r'^## ', multiLine: true).matchAsPrefix(readmeContent, afterHeader + 1);
      if (nextSection != null) {
        readmeContent = '${readmeContent.substring(0, afterHeader + 1)}\n$table\n\n${readmeContent.substring(nextSection.start)}';
      } else {
        readmeContent = '${readmeContent.substring(0, afterHeader + 1)}\n$table\n';
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
    var rel = p.relative(to, from: from).replaceAll(r'\', '/');
    return rel;
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add tool/study_generator/lib/src/commands/update_readme_command.dart
git commit -m "feat: add update-readme command"
```

---

### Task 12: CLI Entry Point

**Files:**
- Create: `tool\study_generator\bin\generate.dart`

- [ ] **Step 1: Write CLI entry point**

```dart
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:study_generator/src/commands/generate_skill_command.dart';
import 'package:study_generator/src/commands/update_skill_command.dart';
import 'package:study_generator/src/commands/validate_skill_command.dart';
import 'package:study_generator/src/commands/update_readme_command.dart';

void main(List<String> arguments) {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    final out = record.level >= Level.SEVERE ? stderr : stdout;
    out.writeln('[${record.level.name}] ${record.message}');
  });

  final logger = Logger('study_generator');

  final runner = CommandRunner<void>(
    'study_generator',
    'AI-powered skill generator for Dart CN documentation',
  )
    ..addCommand(GenerateSkillCommand(
      logger: logger,
      defaultOutputDir: '../skills',
      httpClient: http.Client(),
    ))
    ..addCommand(UpdateSkillCommand(
      logger: logger,
      defaultOutputDir: '../skills',
      httpClient: http.Client(),
    ))
    ..addCommand(ValidateSkillCommand(
      logger: logger,
      defaultOutputDir: '../skills',
      httpClient: http.Client(),
    ))
    ..addCommand(UpdateReadmeCommand(
      logger: logger,
      defaultOutputDir: '../skills',
    ));

  runZonedGuarded(
    () async {
      final client = http.Client();
      try {
        await runner.run(arguments);
        exit(0);
      } on UsageException catch (e) {
        stderr.writeln(e);
        exit(64);
      } on Exception catch (e) {
        stderr.writeln(e);
        exit(1);
      } finally {
        client.close();
      }
    },
    (error, stack) {
      logger.severe('Unhandled error: $error\n$stack');
      exit(1);
    },
  );
}
```

- [ ] **Step 2: Verify CLI parses correctly**

Run:
```powershell
dart run bin/generate.dart --help
```
Workdir: `D:\MyProject\studydart-skills\tool\study_generator`

Expected: Help text showing 4 commands (generate-skill, update-skill, validate-skill, update-readme), plus global flags.

- [ ] **Step 3: Commit**

```bash
git add tool/study_generator/bin/generate.dart
git commit -m "feat: add CLI entry point with 4 commands"
```

---

### Task 13: Generate All 10 Skills

**Files:**
- Create: `skills/dart-fundamentals/SKILL.md`
- Create: `skills/dart-type-system/SKILL.md`
- Create: `skills/dart-classes-objects/SKILL.md`
- Create: `skills/dart-pattern-matching/SKILL.md`
- Create: `skills/dart-null-safety/SKILL.md`
- Create: `skills/dart-async-concurrency/SKILL.md`
- Create: `skills/dart-collections-iterables/SKILL.md`
- Create: `skills/dart-core-libraries/SKILL.md`
- Create: `skills/dart-packages-pub/SKILL.md`
- Create: `skills/dart-effective-dart/SKILL.md`

- [ ] **Step 1: Set environment variables**

Ensure `OPENCODE_API_KEY`, `OPENCODE_BASE_URL`, `OPENCODE_MODEL` are set before running.

- [ ] **Step 2: Run generate-skill for all**

Run:
```powershell
dart run bin/generate.dart generate-skill --config ../resources/studydart_skills.yaml --directory ../skills
```
Workdir: `D:\MyProject\studydart-skills\tool\study_generator`

Expected: 10 `SKILL.md` files created in `skills/` subdirectories.

- [ ] **Step 3: Verify each SKILL.md exists and has content**

Run:
```powershell
Get-ChildItem -Recurse ../skills -Filter SKILL.md | ForEach-Object { $_.FullName; (Get-Content $_.FullName | Measure-Object -Line).Lines }
```
Workdir: `D:\MyProject\studydart-skills\tool\study_generator`

Expected: 10 files, each with >50 lines of content and valid YAML frontmatter.

- [ ] **Step 4: Run validate-skill to check quality**

Run:
```powershell
dart run bin/generate.dart validate-skill --config ../resources/studydart_skills.yaml --directory ../skills
```
Workdir: `D:\MyProject\studydart-skills\tool\study_generator`

Expected: Each skill gets a grade (e.g., `Grade: 85/100`). Review validation reports in `validation/` directory.

- [ ] **Step 5: Commit**

```bash
git add skills/
git commit -m "feat: add 10 generated Dart skills"
```

---

### Task 14: Documentation & Final Polish

**Files:**
- Create: `README.md`
- Create: `AGENTS.md`
- Create: `.claude/skills/studydart-skills/` (GitNexus skills)

- [ ] **Step 1: Write README.md with skill table**

Write the following README.md. The `update-readme` command will populate the ## Available Skills table automatically — run it AFTER writing this file once.

```markdown
# studydart-skills

Agent skills for Dart, sourced from dart.cn documentation.

A collection of skills providing tailored instructions for happy-path Dart app development workflows.

## Installation

```bash
npx skills add studydart-skills --skill '*' --agent universal
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENCODE_API_KEY` | Yes | API key for AI backend |
| `OPENCODE_BASE_URL` | Yes | OpenAI-compatible endpoint URL |
| `OPENCODE_MODEL` | No | Model name (default: deepseek-v4-pro) |

## Usage

```bash
cd tool/study_generator
dart run bin/generate.dart generate-skill --config ../resources/studydart_skills.yaml --directory ../skills
dart run bin/generate.dart validate-skill --config ../resources/studydart_skills.yaml --directory ../skills
dart run bin/generate.dart update-readme  # Auto-updates this table
```

## Available Skills
```

Then run:
```powershell
dart run bin/generate.dart update-readme --config ../resources/studydart_skills.yaml --directory ../skills --readme ../README.md
```
Workdir: `D:\MyProject\studydart-skills\tool\study_generator`

The `update-readme` command will auto-insert the skills table below `## Available Skills`. Verify the table has 10 rows.

- [ ] **Step 2: Write AGENTS.md**

Write a minimal AGENTS.md instructing agents to use GitNexus tools for impact analysis before editing, and to run `dart analyze` after changes.

- [ ] **Step 3: Copy GitNexus skills from original project**

Copy the 6 `gitnexus-*` skill folders from `D:\MyProject\skills\.claude\skills\gitnexus\` into `.claude/skills/studydart-skills/`.

- [ ] **Step 4: Run dart analyze**

Run:
```powershell
dart analyze
```
Workdir: `D:\MyProject\studydart-skills\tool\study_generator`

Expected: No errors.

- [ ] **Step 5: Final commit & tag**

```bash
git add README.md AGENTS.md .claude/
git commit -m "docs: add README, AGENTS.md, and GitNexus skills"
```
Workdir: `D:\MyProject\studydart-skills`

---

### Task 15: Git Init & Verify

**Files:**
- None (verification only)

- [ ] **Step 1: Verify project structure**

Run:
```powershell
tree /F
```
Workdir: `D:\MyProject\studydart-skills`

Check that all files from the DESIGN.md file structure are present.

- [ ] **Step 2: Verify final commit status**

Run:
```powershell
git status; git log --oneline
```
Workdir: `D:\MyProject\studydart-skills`

Expected: Clean working tree, history shows all commits.

---

## Summary

**Total tasks:** 15
**Files to create:** ~25 (10 SKILL.md + 15 source/tool files)
**Key replacement:** OpenCodeService replaces GeminiService (Task 6) — the only architectural divergence from original
**Port from original:** MarkdownConverter, ResourceFetcherService, Prompts, SkillInstructions — near-identical
**New files:** skill_params.dart adjusted for dart- prefix, base commands adjusted for dart.cn paths
