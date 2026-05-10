# Auto-Update Skills Design

## Problem

The studydart-skills project generates 10 SKILL.md files from dart.cn documentation via AI. When dart.cn docs change, skills become stale. Currently, updating requires manual invocation of `update-skill` + `validate-skill` per skill. This spec describes automatic detection of doc changes and self-updating of affected skills.

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Trigger | CLI (`check-and-update`) + GitHub Actions cron | Manual batch update for developers; scheduled auto-update for CI |
| Change detection | SHA-256 hash of combined markdown per skill | Deterministic, no false positives, zero changes to existing services |
| Update handling | Grade >= 85 auto-commit; Grade < 85 PR for review | Balances automation with quality guard |
| Hash storage | `skills/{name}/metadata.json` per skill | Simple, version-controlled, human-readable |

## Architecture

### New Files

```
tool/study_generator/lib/src/
├── services/
│   ├── metadata_service.dart      # Read/write skills/{name}/metadata.json
│   └── hash_service.dart          # SHA-256 hash computation
└── commands/
    └── check_and_update_command.dart  # Orchestration command

.github/workflows/
└── auto-update-skills.yml         # GitHub Actions scheduled workflow
```

### Modified Files

```
tool/study_generator/bin/generate.dart  # Register new command
```

### No Changes To

- `OpenCodeService` — reused as-is for `updateSkillContent()` and `validateExistingSkillContent()`
- `ResourceFetcherService` — reused as-is (combined markdown is hashed as a whole)
- `UpdateSkillCommand`, `ValidateSkillCommand` — unchanged; the new command calls the same service methods directly
- `MarkdownConverter`, `Prompts`, `SkillParams` — unchanged
- Existing commands and YAML config — unchanged

## Component Design

### MetadataService

Manages per-skill metadata at `skills/{skillName}/metadata.json`.

**Schema:**

```json
{
  "skill_name": "dart-fundamentals",
  "content_hash": "abc123sha256...",
  "last_updated": "2026-05-10T08:00:00Z",
  "last_grade": 92
}
```

**Rationale:** Hash all combined markdown per skill rather than per-URL. Any URL change changes the combined hash. This avoids modifying `ResourceFetcherService`.

**Key methods:**

- `String? loadHash(String skillName, String outputDir)` — load stored hash or null (first run, metadata.json missing)
- `void saveUpdateResult(String skillName, String outputDir, String hash, int? grade)` — persist hash, timestamp, and optionally grade after a successful update
- `Map<String, dynamic> loadMetadata(String skillName, String outputDir)` — load full metadata or return empty map

### HashService

- `String computeHash(String content)` — SHA-256 hex digest of the input string

### CheckAndUpdateCommand

Extends `BaseSkillCommand`. Orchestrates the full pipeline per skill.

**Data flow per skill:**

```
1. fetchAndConvertContent(skill.resources) → combinedMarkdown
2. hashService.computeHash(combinedMarkdown) → newHash
3. metadataService.loadHash() → storedHash
4. storedHash == null || storedHash != newHash → changes detected
   storedHash == newHash → skip (log "No changes detected")
5. Read skills/{name}/SKILL.md → existingContent
6. service.updateSkillContent(existingContent, combinedMarkdown, ...) → updatedContent
7. Write updatedContent to skills/{name}/SKILL.md
8. service.validateExistingSkillContent(combinedMarkdown, ..., currentSkillContent: updatedContent) → report
9. Extract grade: RegExp(r'Grade:\s*(\d+)').firstMatch(report)
10. Save validation report to validation/{name}/validation.md
11. Evaluate:
    ├── grade >= threshold → metadataService.saveUpdateResult(name, outputDir, newHash, grade)
    │                        return 'auto_merged'
    └── grade < threshold → git checkout skills/{name}/SKILL.md (revert)
                             save validation report only, return 'needs_review'
```

**Return value:** a structured summary object listing each skill's result (skipped / auto_merged / needs_review / fetch_failed).

**CLI arguments:**
- `--threshold` (int, default 85): Minimum grade for auto-commit
- `--dry-run` (flag): Check hashes only, no AI calls, no file writes
- Inherited from base: `--config`, `--skill`, `--directory`

**Output format (console):**

```
=== Auto-Update Report ===
dart-fundamentals:    SKIPPED (no changes)
dart-null-safety:     AUTO-MERGED (grade 89/100)
dart-core-libraries:  NEEDS REVIEW (grade 72/100) → see validation/dart-core-libraries/validation.md
dart-pattern-matching: FETCH FAILED (dart.cn returned 503)
```

## GitHub Actions Workflow

### Trigger

- `schedule: cron(0 0 * * *)` — daily at midnight UTC
- `workflow_dispatch` — manual trigger from GitHub UI

### Steps

```yaml
1. Checkout repository (with token for push)
2. Install Dart SDK (^3.10.8)
3. cd tool/study_generator && dart pub get
4. dart run bin/generate.dart check-and-update
5. Check for changes (git diff --exit-code):
   - No changes → workflow completes, nothing to do
   - Changes exist → continue
6. git add skills/ validation/
7. git commit -m "auto: update skills [date]"
8. git push origin HEAD:auto-update-YYYYMMDD
9. Create PR with summary (list of changed skill names extracted from git diff)
```

**Local vs CI behavior:** The `check-and-update` command itself only writes files and logs results. It never commits or pushes. CI commit/PR logic is handled by GitHub Actions workflow steps 5-9, not by the Dart command.

### Commit and PR Strategy

- **High-grade updates (>=85):** SKILL.md + metadata.json are committed together in one commit
- **Low-grade updates (<85):** SKILL.md is reverted (`git checkout -- skills/{name}/SKILL.md`), only validation.md is committed, and a PR is created that lists these skills as "Needs Review"
- **No updates:** Workflow exits early, no commit, no PR

### Security

- Uses `${{ secrets.OPENCODE_API_KEY }}` as environment variable
- Uses `${{ secrets.OPENCODE_BASE_URL }}` as environment variable
- Repository checkout uses `${{ secrets.GITHUB_TOKEN }}` (auto-provided)

## Error Handling

| Failure | Behavior |
|---------|----------|
| Resource URL returns non-200 | Log error, skip skill, continue with remaining skills |
| AI API call fails (retry 3x still fails) | Log error, skip skill, continue with remaining skills |
| Validation grade regex fails to match | Treat as grade 0, mark as needs_review |
| metadata.json missing or malformed | Treat as changed (first run), generate fresh |
| Disk write fails | Log severe error, skip skill, continue |

## Testing Strategy

- `HashService` — unit test: known inputs produce known hashes
- `MetadataService` — unit test: round-trip read/write, compare old/new hash maps
- `CheckAndUpdateCommand` — integration test: dry-run with real config, verify no crashes; mock AI service to test threshold logic

## Out of Scope

- Diff-based content comparison (full markdown diff is stored in git history)
- Rollback of auto-merged skills (git revert suffices)
- Email/notification of updates (GitHub PR notifications are sufficient)
- Self-modifying the auto-update workflow itself
