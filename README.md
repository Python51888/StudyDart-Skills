# studydart-skills

Agent skills for Dart, sourced from [dart.cn](https://dart.cn/docs) documentation and curated open-source projects.

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
| [dart-async-concurrency](skills/dart-async-concurrency/SKILL.md) | 掌握 Dart 异步与并发编程（Future、async/await、Stream、Isolate），编写高性能无阻塞的应用。 | 使用 Stream 和 async/await 实现一个并发的文件流处理器 |
| [dart-classes-objects](skills/dart-classes-objects/SKILL.md) | 设计 Dart 类与对象的层次结构（构造方法、继承、混入、扩展方法），构建可维护的面向对象架构。 | 使用 mixin 和类修饰符设计一个带扩展方法的类层级结构 |
| [dart-collections-iterables](skills/dart-collections-iterables/SKILL.md) | 使用 Dart 集合操作与可迭代工具链（List、Set、Map、Iterable），高效处理数据变换。 | 使用 Iterable 方法链对一组数据进行过滤、映射和归约操作 |
| [dart-core-libraries](skills/dart-core-libraries/SKILL.md) | 熟练使用 Dart SDK 核心库（dart:core、dart:convert、dart:io、dart:math），避免重复造轮子。 | 使用 dart:io 读取文件并用 dart:convert 解析 JSON 数据 |
| [dart-effective-dart](skills/dart-effective-dart/SKILL.md) | 遵循 Effective Dart 最佳实践（代码风格、文档、用法、API 设计），编写一致、可维护、高效的 Dart 代码。 | 按照 Effective Dart 风格重构函数命名和文档注释 |
| [dart-fundamentals](skills/dart-fundamentals/SKILL.md) | 掌握 Dart 语言的基础要素（变量、操作符、控制流、函数、导库），用于编写符合规范的 Dart 代码。 | 使用 Dart 的变量声明和函数定义编写一个基础的应用入口 |
| [dart-null-safety](skills/dart-null-safety/SKILL.md) | 运用 Dart 健全空安全机制（Sound Null Safety），消除空引用异常并编写类型安全的代码。 | 将现有代码迁移到空安全，使用 null-aware 操作符消除潜在的 NPE |
| [dart-packages-pub](skills/dart-packages-pub/SKILL.md) | 管理 Dart 包生态（Pub 仓库），掌握创建、使用、发布 Package 及工作空间的多包管理。 | 创建一个新的 Dart Package 并配置工作空间管理多个子包 |
| [dart-pattern-matching](skills/dart-pattern-matching/SKILL.md) | 使用 Dart 3 的模式匹配特性（Pattern Matching）简化数据解构和分支逻辑。 | 使用模式匹配解构一个嵌套的 Record 并实现 switch 表达式分支 |
| [dart-type-system](skills/dart-type-system/SKILL.md) | 深入理解 Dart 类型系统（基本类型、泛型、Record、别名），确保类型安全和代码健壮性。 | 定义一个泛型 Record 类型并实现类型别名简化复杂类型声明 |

### 纯 Dart 开源项目技能

在真实开源项目中巩固 Dart 知识，按上手难度排列。每个项目映射到一个 Dart 主题技能。

| 难度 | Skill | Stars | 关联主题 |
|------|-------|-------|---------|
| L1 | [dart-oss-beginners-course](skills/dart-open-source-projects/dart-oss-beginners-course/SKILL.md) | 59 | dart-fundamentals |
| L1 | [dart-oss-design-patterns](skills/dart-open-source-projects/dart-oss-design-patterns/SKILL.md) | 479 | dart-classes-objects |
| L1 | [dart-oss-google-translator](skills/dart-open-source-projects/dart-oss-google-translator/SKILL.md) | 191 | dart-fundamentals |
| L1 | [dart-oss-common-utils](skills/dart-open-source-projects/dart-oss-common-utils/SKILL.md) | 1.5k | dart-core-libraries |
| L2 | [dart-oss-formz](skills/dart-open-source-projects/dart-oss-formz/SKILL.md) | 481 | dart-type-system |
| L2 | [dart-oss-fresh](skills/dart-open-source-projects/dart-oss-fresh/SKILL.md) | 421 | dart-async-concurrency |
| L2 | [dart-oss-talker](skills/dart-open-source-projects/dart-oss-talker/SKILL.md) | 827 | dart-core-libraries |
| L2 | [dart-oss-dson](skills/dart-open-source-projects/dart-oss-dson/SKILL.md) | 65 | dart-core-libraries |
| L3 | [dart-oss-very-good-cli](skills/dart-open-source-projects/dart-oss-very-good-cli/SKILL.md) | 2.4k | dart-packages-pub |
| L3 | [dart-oss-mason](skills/dart-open-source-projects/dart-oss-mason/SKILL.md) | 1.1k | dart-packages-pub |
| L3 | [dart-oss-dart-frog](skills/dart-open-source-projects/dart-oss-dart-frog/SKILL.md) | 2.2k | dart-async-concurrency |
| L3 | [dart-oss-image](skills/dart-open-source-projects/dart-oss-image/SKILL.md) | 1.3k | dart-core-libraries |

> 完整项目总览与维护指南参见 [dart-oss SKILL.md](skills/dart-open-source-projects/SKILL.md)

## 推荐学习路线

```
L1 基础语法
  → dart-fundamentals → dart-oss-beginners-course
  → dart-classes-objects → dart-oss-design-patterns

L2 库与工具
  → dart-type-system → dart-oss-formz
  → dart-async-concurrency → dart-oss-fresh

L3 实战项目
  → dart-async-concurrency → dart-oss-dart-frog
  → dart-packages-pub → dart-oss-very-good-cli
```

