# studydart-skills

Agent skills for Dart, sourced from [dart.cn](https://dart.cn/docs) documentation.

A collection of skills providing tailored instructions for happy-path Dart app development workflows. Each skill teaches an AI agent the precise steps, conditional logic, and best practices for a specific Dart task.

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENCODE_API_KEY` | Yes | API key for AI backend |
| `OPENCODE_BASE_URL` | Yes | OpenAI-compatible endpoint URL |
| `OPENCODE_MODEL` | No | Model name (default: `deepseek-v4-pro`) |

## Usage

```bash
cd tool/study_generator

# Generate all skills from documentation
dart run bin/generate.dart generate-skill --config ../resources/studydart_skills.yaml --directory ../skills

# Update existing skills with new doc changes
dart run bin/generate.dart update-skill --config ../resources/studydart_skills.yaml --directory ../skills

# Validate skills and get quality grades
dart run bin/generate.dart validate-skill --config ../resources/studydart_skills.yaml --directory ../skills

# Auto-update this README skills table
dart run bin/generate.dart update-readme
```

## Available Skills

| Skill | Description | Example prompt |
|---|---|---|
| [dart-fundamentals](skills/dart-fundamentals/SKILL.md) | 掌握 Dart 语言的基础要素（变量、操作符、控制流、函数、导库），用于编写符合规范的 Dart 代码。 | 使用 Dart 的变量声明和函数定义编写一个基础的应用入口 |
| [dart-type-system](skills/dart-type-system/SKILL.md) | 深入理解 Dart 类型系统（基本类型、泛型、Record、别名），确保类型安全和代码健壮性。 | 定义一个泛型 Record 类型并实现类型别名简化复杂类型声明 |
| [dart-classes-objects](skills/dart-classes-objects/SKILL.md) | 设计 Dart 类与对象的层次结构（构造方法、继承、混入、扩展方法），构建可维护的面向对象架构。 | 使用 mixin 和类修饰符设计一个带扩展方法的类层级结构 |
| [dart-pattern-matching](skills/dart-pattern-matching/SKILL.md) | 使用 Dart 3 的模式匹配特性（Pattern Matching）简化数据解构和分支逻辑。 | 使用模式匹配解构一个嵌套的 Record 并实现 switch 表达式分支 |
| [dart-null-safety](skills/dart-null-safety/SKILL.md) | 运用 Dart 健全空安全机制（Sound Null Safety），消除空引用异常并编写类型安全的代码。 | 将现有代码迁移到空安全，使用 null-aware 操作符消除潜在的 NPE |
| [dart-async-concurrency](skills/dart-async-concurrency/SKILL.md) | 掌握 Dart 异步与并发编程（Future、async/await、Stream、Isolate），编写高性能无阻塞的应用。 | 使用 Stream 和 async/await 实现一个并发的文件流处理器 |
| [dart-collections-iterables](skills/dart-collections-iterables/SKILL.md) | 使用 Dart 集合操作与可迭代工具链（List、Set、Map、Iterable），高效处理数据变换。 | 使用 Iterable 方法链对一组数据进行过滤、映射和归约操作 |
| [dart-core-libraries](skills/dart-core-libraries/SKILL.md) | 熟练使用 Dart SDK 核心库（dart:core、dart:convert、dart:io、dart:math），避免重复造轮子。 | 使用 dart:io 读取文件并用 dart:convert 解析 JSON 数据 |
| [dart-packages-pub](skills/dart-packages-pub/SKILL.md) | 管理 Dart 包生态（Pub 仓库），掌握创建、使用、发布 Package 及工作空间的多包管理。 | 创建一个新的 Dart Package 并配置工作空间管理多个子包 |
| [dart-effective-dart](skills/dart-effective-dart/SKILL.md) | 遵循 Effective Dart 最佳实践（代码风格、文档、用法、API 设计），编写一致、可维护、高效的 Dart 代码。 | 按照 Effective Dart 风格重构函数命名和文档注释 |
