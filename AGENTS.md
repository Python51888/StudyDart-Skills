# studydart-skills — Agent Instructions

This project builds Agent Skills for Dart from dart.cn documentation.

## Rules for Agents

- Use `dart analyze` after any Dart code changes
- Use `dart run bin/generate.dart validate-skill` to verify skills before committing
- Follow the SKILL.md format: YAML frontmatter → `# Title` → `## Contents` → `## Sections` → `## Workflow` → `## Examples`
- Do NOT manually edit the skills table in README.md — use `dart run bin/generate.dart update-readme`

## CI Requirements

- All SKILL.md files must pass `dart run bin/generate.dart validate-skill`
- All Dart source must pass `dart analyze`
