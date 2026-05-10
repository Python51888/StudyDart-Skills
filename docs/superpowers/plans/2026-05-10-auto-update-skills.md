# Auto-Update Skills Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a `check-and-update` CLI command and GitHub Actions workflow that auto-detects dart.cn doc changes and self-updates SKILL.md files.

**Architecture:** Two new services (HashService, MetadataService) plus one new command (CheckAndUpdateCommand) that orchestrates fetch→hash→update→validate→merge/revert per skill. A GitHub Actions workflow runs daily. Everything reuses existing OpenCodeService and ResourceFetcherService unmodified.

**Tech Stack:** Dart ^3.10.8, `dart:convert` sha256, GitHub Actions, `package:http`, `package:args`

**Design spec:** `docs/superpowers/specs/2026-05-10-auto-update-skills-design.md`

---

### File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `tool/study_generator/lib/src/services/hash_service.dart` | Create | SHA-256 hash over HTML→markdown converted content |
| `tool/study_generator/lib/src/services/metadata_service.dart` | Create | Read/write `skills/{name}/metadata.json` with content_hash, last_updated, last_grade |
| `tool/study_generator/lib/src/commands/check_and_update_command.dart` | Create | Orchestrate detect→update→validate→decide pipeline per skill |
| `tool/study_generator/bin/generate.dart` | Modify | Register `CheckAndUpdateCommand` |
| `.github/workflows/auto-update-skills.yml` | Create | Daily cron + manual trigger for auto-update pipeline |

---

### Task 1: HashService

**Files:**
- Create: `tool/study_generator/lib/src/services/hash_service.dart`
- Test: `tool/study_generator/test/services/hash_service_test.dart`

- [ ] **Step 1: Write the failing test**

Create `tool/study_generator/test/services/hash_service_test.dart`:

```dart
import 'package:study_generator/src/services/hash_service.dart';
import 'package:test/test.dart';

void main() {
  group('HashService', () {
    final hashService = HashService();

    test('computeHash returns 64-char hex string', () {
      final result = hashService.computeHash('hello world');
      expect(result, hasLength(64));
      expect(result, matches(RegExp(r'^[a-f0-9]{64}$')));
    });

    test('computeHash same input produces same output', () {
      final a = hashService.computeHash('hello');
      final b = hashService.computeHash('hello');
      expect(a, equals(b));
    });

    test('computeHash different input produces different output', () {
      final a = hashService.computeHash('hello');
      final b = hashService.computeHash('world');
      expect(a, isNot(equals(b)));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```powershell
dart run test test/services/hash_service_test.dart
```

Expected: compilation error, `HashService` not found.

- [ ] **Step 3: Write minimal implementation**

Create `tool/study_generator/lib/src/services/hash_service.dart`:

```dart
import 'dart:convert';

class HashService {
  String computeHash(String content) {
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```powershell
dart run test test/services/hash_service_test.dart
```

Expected: 3 tests PASS.

- [ ] **Step 5: Commit**

```powershell
git add tool/study_generator/lib/src/services/hash_service.dart tool/study_generator/test/services/hash_service_test.dart
git commit -m "feat: add HashService for SHA-256 content hashing"
```

---

### Task 2: MetadataService

**Files:**
- Create: `tool/study_generator/lib/src/services/metadata_service.dart`
- Test: `tool/study_generator/test/services/metadata_service_test.dart`

- [ ] **Step 1: Write the failing test**

Create `tool/study_generator/test/services/metadata_service_test.dart`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:study_generator/src/services/metadata_service.dart';
import 'package:test/test.dart';

void main() {
  group('MetadataService', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('metadata_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('loadHash returns null when metadata.json does not exist', () {
      final service = MetadataService();
      final result = service.loadHash('nonexistent', tempDir.path);
      expect(result, isNull);
    });

    test('saveUpdateResult and loadHash round-trip', () {
      final service = MetadataService();
      service.saveUpdateResult('test-skill', tempDir.path, 'abc123hash', 92);

      final hash = service.loadHash('test-skill', tempDir.path);
      expect(hash, equals('abc123hash'));

      final meta = service.loadMetadata('test-skill', tempDir.path);
      expect(meta['skill_name'], equals('test-skill'));
      expect(meta['content_hash'], equals('abc123hash'));
      expect(meta['last_grade'], equals(92));
      expect(meta['last_updated'], isNotNull);
    });

    test('saveUpdateResult with null grade does not write last_grade', () {
      final service = MetadataService();
      service.saveUpdateResult('test-skill', tempDir.path, 'hash', null);

      final file = File('${tempDir.path}/test-skill/metadata.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      expect(json.containsKey('last_grade'), isFalse);
    });

    test('loadMetadata returns empty map when file does not exist', () {
      final service = MetadataService();
      final result = service.loadMetadata('nonexistent', tempDir.path);
      expect(result, isEmpty);
    });

    test('saveUpdateResult overwrites existing metadata', () {
      final service = MetadataService();
      service.saveUpdateResult('test-skill', tempDir.path, 'old-hash', 80);
      service.saveUpdateResult('test-skill', tempDir.path, 'new-hash', 95);

      final hash = service.loadHash('test-skill', tempDir.path);
      expect(hash, equals('new-hash'));

      final meta = service.loadMetadata('test-skill', tempDir.path);
      expect(meta['last_grade'], equals(95));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```powershell
dart run test test/services/metadata_service_test.dart
```

Expected: compilation error, `MetadataService` not found.

- [ ] **Step 3: Write minimal implementation**

Create `tool/study_generator/lib/src/services/metadata_service.dart`:

```dart
import 'dart:convert';
import 'dart:io';

class MetadataService {
  String? loadHash(String skillName, String outputDir) {
    final file = File('$outputDir/$skillName/metadata.json');
    if (!file.existsSync()) return null;
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return json['content_hash'] as String?;
  }

  void saveUpdateResult(
    String skillName,
    String outputDir,
    String hash,
    int? grade,
  ) {
    final file = File('$outputDir/$skillName/metadata.json');
    final Map<String, dynamic> data = file.existsSync()
        ? jsonDecode(file.readAsStringSync()) as Map<String, dynamic>
        : {};
    data['skill_name'] = skillName;
    data['content_hash'] = hash;
    data['last_updated'] = DateTime.now().toUtc().toIso8601String();
    if (grade != null) {
      data['last_grade'] = grade;
    }
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  }

  Map<String, dynamic> loadMetadata(String skillName, String outputDir) {
    final file = File('$outputDir/$skillName/metadata.json');
    if (!file.existsSync()) return <String, dynamic>{};
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```powershell
dart run test test/services/metadata_service_test.dart
```

Expected: 5 tests PASS.

- [ ] **Step 5: Commit**

```powershell
git add tool/study_generator/lib/src/services/metadata_service.dart tool/study_generator/test/services/metadata_service_test.dart
git commit -m "feat: add MetadataService for per-skill metadata persistence"
```

---

### Task 3: CheckAndUpdateCommand

**Files:**
- Create: `tool/study_generator/lib/src/commands/check_and_update_command.dart`
- Test: `tool/study_generator/test/commands/check_and_update_command_test.dart`

- [ ] **Step 1: Write the failing test for threshold logic**

Create `tool/study_generator/test/commands/check_and_update_command_test.dart`:

```dart
import 'package:study_generator/src/commands/check_and_update_command.dart';
import 'package:test/test.dart';

void main() {
  group('SkillResult', () {
    test('fromGrade auto_merged when grade >= threshold', () {
      final result = SkillResult.fromGrade(
        skillName: 'test-skill',
        grade: 90,
        threshold: 85,
        validationPath: 'validation/test-skill/validation.md',
      );
      expect(result.status, equals(UpdateStatus.autoMerged));
    });

    test('fromGrade needsReview when grade < threshold', () {
      final result = SkillResult.fromGrade(
        skillName: 'test-skill',
        grade: 70,
        threshold: 85,
        validationPath: 'validation/test-skill/validation.md',
      );
      expect(result.status, equals(UpdateStatus.needsReview));
    });

    test('fromGrade auto_merged when grade equals threshold', () {
      final result = SkillResult.fromGrade(
        skillName: 'test-skill',
        grade: 85,
        threshold: 85,
        validationPath: 'validation/test-skill/validation.md',
      );
      expect(result.status, equals(UpdateStatus.autoMerged));
    });

    test('gradeRegex matches valid format', () {
      final regex = RegExp(r'Grade:\s*(\d+)');
      final match = regex.firstMatch('Some text\nGrade: 89\nMore text');
      expect(match, isNotNull);
      expect(match!.group(1), equals('89'));
    });

    test('gradeRegex does not match invalid format', () {
      final regex = RegExp(r'Grade:\s*(\d+)');
      expect(regex.hasMatch('Grade: ABC'), isFalse);
      expect(regex.hasMatch('No grade here'), isFalse);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```powershell
dart run test test/commands/check_and_update_command_test.dart
```

Expected: compilation error, `CheckAndUpdateCommand` not found.

- [ ] **Step 3: Write the CheckAndUpdateCommand implementation**

Create `tool/study_generator/lib/src/commands/check_and_update_command.dart`:

```dart
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;

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
  Future<void> runSkill(
    SkillParams skill,
    String outputDir,
    OpenCodeService service,
  ) async {
    final threshold = int.parse(argResults!['threshold'] as String);
    final isDryRun = argResults!['dry-run'] as bool;

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

      if (isDryRun) {
        logger.info('  [DRY RUN] Changes detected for ${skill.name}');
        _results.add(SkillResult(
          skillName: skill.name,
          status: UpdateStatus.autoMerged,
        ));
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

      // Step 6: Update
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

      // Step 8-9: Validate
      logger.info('  Validating ${skill.name}...');
      final report = await service.validateExistingSkillContent(
        markdown: combinedMarkdown,
        skillName: skill.name,
        instructions: skill.instructions,
        generationDate: DateTime.now().toUtc().toIso8601String(),
        modelName: 'deepseek-v4-pro',
        currentSkillContent: updatedContent,
      );

      // Save validation report
      final reportDir = Directory('validation/${skill.name}');
      reportDir.createSync(recursive: true);
      final reportPath = '${reportDir.path}/validation.md';
      File(reportPath).writeAsStringSync(report);

      final gradeMatch = RegExp(r'Grade:\s*(\d+)').firstMatch(report);
      final grade = gradeMatch != null ? int.tryParse(gradeMatch.group(1)!) ?? 0 : 0;

      logger.info('  ${skill.name}: Grade $grade/100');

      // Step 11: Evaluate
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

  final List<SkillResult> _results = <SkillResult>[];

  @override
  Future<void> runWithSkills(List<SkillParams> skills, String outputDir) async {
    _results.clear();
    await super.runWithSkills(skills, outputDir);
    _printReport();
  }

  void _printReport() {
    logger.info('');
    logger.info('=== Auto-Update Report ===');
    for (final result in _results) {
      switch (result.status) {
        case UpdateStatus.skipped:
          logger.info('${result.skillName}: SKIPPED (no changes)');
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
```

- [ ] **Step 4: Run test to verify it passes**

```powershell
dart run test test/commands/check_and_update_command_test.dart
```

Expected: 5 tests PASS.

- [ ] **Step 5: Commit**

```powershell
git add tool/study_generator/lib/src/commands/check_and_update_command.dart tool/study_generator/test/commands/check_and_update_command_test.dart
git commit -m "feat: add CheckAndUpdateCommand for auto-update pipeline"
```

---

### Task 4: Register Command in CLI Entry Point

**Files:**
- Modify: `tool/study_generator/bin/generate.dart`

- [ ] **Step 1: Add import and register the command**

Read `tool/study_generator/bin/generate.dart` (already done). Edit to add import and command registration.

Add import line after the validate_skill_command import:

```dart
import 'package:study_generator/src/commands/check_and_update_command.dart';
```

Add command registration after the ValidateSkillCommand line (line 30):

```dart
..addCommand(CheckAndUpdateCommand(logger: logger, httpClient: client))
```

The final file should be:

```dart
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'package:study_generator/src/commands/generate_skill_command.dart';
import 'package:study_generator/src/commands/update_skill_command.dart';
import 'package:study_generator/src/commands/validate_skill_command.dart';
import 'package:study_generator/src/commands/check_and_update_command.dart';
import 'package:study_generator/src/commands/update_readme_command.dart';

Future<void> main(List<String> arguments) async {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    final out = record.level >= Level.SEVERE ? stderr : stdout;
    out.writeln('[${record.level.name}] ${record.message}');
  });

  final logger = Logger('study_generator');

  final client = http.Client();
  try {
    final runner =
        CommandRunner<void>(
            'study_generator',
            'AI-powered skill generator for Dart CN documentation',
          )
          ..addCommand(GenerateSkillCommand(logger: logger, httpClient: client))
          ..addCommand(UpdateSkillCommand(logger: logger, httpClient: client))
          ..addCommand(ValidateSkillCommand(logger: logger, httpClient: client))
          ..addCommand(CheckAndUpdateCommand(logger: logger, httpClient: client))
          ..addCommand(UpdateReadmeCommand(logger: logger));

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
}
```

- [ ] **Step 2: Verify command registration**

```powershell
dart run tool/study_generator/bin/generate.dart --help
```

Expected: output includes `check-and-update` in the available commands list.

- [ ] **Step 3: Commit**

```powershell
git add tool/study_generator/bin/generate.dart
git commit -m "feat: register check-and-update command in CLI entry point"
```

---

### Task 5: GitHub Actions Workflow

**Files:**
- Create: `.github/workflows/auto-update-skills.yml`

- [ ] **Step 1: Create the workflow file**

Create `.github/workflows/auto-update-skills.yml`:

```yaml
name: Auto-Update Skills

on:
  schedule:
    - cron: '0 0 * * *'
  workflow_dispatch:

jobs:
  update-skills:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write

    steps:
      - uses: actions/checkout@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

      - uses: dart-lang/setup-dart@v1
        with:
          sdk: '3.10.8'

      - name: Install dependencies
        working-directory: tool/study_generator
        run: dart pub get

      - name: Check and update skills
        working-directory: tool/study_generator
        run: dart run bin/generate.dart check-and-update
        env:
          OPENCODE_API_KEY: ${{ secrets.OPENCODE_API_KEY }}
          OPENCODE_BASE_URL: ${{ secrets.OPENCODE_BASE_URL }}

      - name: Check for changes
        id: changes
        run: |
          if git diff --quiet; then
            echo "changed=false" >> $GITHUB_OUTPUT
          else
            echo "changed=true" >> $GITHUB_OUTPUT
          fi

      - name: Create branch and PR
        if: steps.changes.outputs.changed == 'true'
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          BRANCH="auto-update-$(date +%Y%m%d-%H%M%S)"
          git checkout -b "$BRANCH"
          git add skills/ validation/
          git commit -m "auto: update skills ($(date +%Y-%m-%d))"
          git push origin "$BRANCH"
          gh pr create \
            --title "auto: update skills ($(date +%Y-%m-%d))" \
            --body "Automated skill update from dart.cn documentation changes. Review validation/ reports and merge if acceptable."
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

- [ ] **Step 2: Verify workflow YAML syntax**

```powershell
gh workflow lint .github/workflows/auto-update-skills.yml
```

Alternatively, manually inspect the YAML for valid GitHub Actions syntax since `gh workflow lint` may not be available locally. The workflow follows standard GitHub Actions conventions.

- [ ] **Step 3: Commit**

```powershell
git add .github/workflows/auto-update-skills.yml
git commit -m "ci: add daily auto-update skills workflow"
```

---

### Task 6: Verification

**Files:** None created/modified.

- [ ] **Step 1: Run dart analyze on the entire project**

```powershell
dart run dart analyze tool/study_generator/
```

Expected: No issues found.

- [ ] **Step 2: Run all unit tests**

```powershell
dart run test tool/study_generator/test/
```

Expected: All tests PASS.

- [ ] **Step 3: Run dry-run check-and-update against real config**

```powershell
dart run tool/study_generator/bin/generate.dart check-and-update --dry-run
```

Expected: Checks all 10 skills' resources, reports which have detected changes (first run will detect all 10 as changed since no metadata.json exists yet), no files written.

- [ ] **Step 4: Final review of all changed files**

```powershell
git status
git diff --stat HEAD~3
```

Verify only the intended files are changed: 5 new files created, 1 modified.

- [ ] **Step 5: Final commit if needed**

If all verification passes, no additional commit needed. Tasks 1-5 already committed individually.

---

### Quick Verification Commands (Post-Implementation)

After all tasks complete, run these in order:

```powershell
# 1. Static analysis
dart analyze tool/study_generator/

# 2. Unit tests
dart run test tool/study_generator/test/

# 3. Dry-run against real config (no API calls, no file writes)
dart run tool/study_generator/bin/generate.dart check-and-update --dry-run

# 4. Check command help
dart run tool/study_generator/bin/generate.dart check-and-update --help
```
