# studydart-skills 设计文档

**日期**: 2026-05-10
**状态**: 已批准

---

## 一、项目定位

从 dart.cn/docs 抓取官方中文文档，通过 AI 重写为结构化的 Agent Skills，为 AI 编码 Agent 提供 Dart 语言领域的精确工作流指导。

**核心理念**（继承自 flutter/skills）：MCP 给 Agent 工具，Skills 教 Agent "如何"使用工具完成特定任务。

**AI 后端**：使用与当前 opencode 会话相同的 DeepSeek API（deepseek-v4-pro），OpenAI-compatible 格式（`/v1/chat/completions`）。

---

## 二、整体架构（五层）

```
┌────────────────────────────────────────────────────┐
│  1. skills/                                         │
│     10 个 SKILL.md，每个是单文件自包含的指导手册       │
├────────────────────────────────────────────────────┤
│  2. tool/study_generator/                           │
│     - ResourceFetcherService: 抓取 dart.cn HTML     │
│     - MarkdownConverter: HTML → Markdown 转换       │
│     - OpenCodeService: 调用 DeepSeek API 生成 Skill │
│     - Prompts: 系统指令 & 用户提示模板               │
├────────────────────────────────────────────────────┤
│  3. resources/studydart_skills.yaml                 │
│     YAML 配置：10 个技能的名称、描述、源 URL         │
├────────────────────────────────────────────────────┤
│  4. .claude/skills/studydart-skills/                │
│     用 GitNexus 技能管理本项目自身的代码导航         │
├────────────────────────────────────────────────────┤
│  5. 复用现有校验工具 dart_skills_lint                │
│     从原项目 repo 引用，校验 SKILL.md 元数据         │
└────────────────────────────────────────────────────┘
```

---

## 三、10 个技能清单

### 1. dart-fundamentals
**描述**: 掌握 Dart 语言的基础要素（变量、操作符、控制流、函数、导库），用于编写符合规范的 Dart 代码。

**覆盖**: 变量声明与作用域、操作符优先级与用法、注释规范、循环（for/while/do-while）、分支（if/switch/match）、错误处理（try/catch/finally）、函数定义与参数传递、元数据注解、库的导入导出与可见性控制、关键字速查。

**源 URL**: https://dart.cn/language, https://dart.cn/language/variables, https://dart.cn/language/operators, https://dart.cn/language/comments, https://dart.cn/language/loops, https://dart.cn/language/branches, https://dart.cn/language/error-handling, https://dart.cn/language/functions, https://dart.cn/language/metadata, https://dart.cn/language/libraries, https://dart.cn/language/keywords

### 2. dart-type-system
**描述**: 深入理解 Dart 类型系统（基本类型、泛型、Record、别名），确保类型安全和代码健壮性。

**覆盖**: 基本数据类型（int/double/String/bool）、Records 元组类型、Collections 集合类型、泛型协变与逆变、Typedef 类型别名、Dart 类型系统原理与类型推断。

**源 URL**: https://dart.cn/language/built-in-types, https://dart.cn/language/records, https://dart.cn/language/generics, https://dart.cn/language/typedefs, https://dart.cn/language/type-system

### 3. dart-classes-objects
**描述**: 设计 Dart 类与对象的层次结构（构造方法、继承、混入、扩展方法），构建可维护的面向对象架构。

**覆盖**: 类定义属性/方法、构造方法（标准/命名/工厂/const）、成员方法（getter/setter/operator）、extends 继承、Mixin 混入与多重继承、枚举与增强枚举、扩展方法与扩展类型、类修饰符（sealed/final/interface/base/mixin）、callable objects、旧类型点号简写。

**源 URL**: https://dart.cn/language/classes, https://dart.cn/language/constructors, https://dart.cn/language/methods, https://dart.cn/language/extend, https://dart.cn/language/mixins, https://dart.cn/language/enums, https://dart.cn/language/dot-shorthands, https://dart.cn/language/extension-methods, https://dart.cn/language/extension-types, https://dart.cn/language/callable-objects, https://dart.cn/language/class-modifiers, https://dart.cn/language/class-modifiers-for-apis, https://dart.cn/language/modifier-reference

### 4. dart-pattern-matching
**描述**: 使用 Dart 3 的模式匹配特性（Pattern Matching）简化数据解构和分支逻辑。

**覆盖**: 模式匹配概览与用法、模式类型（常量/变量/List/Map/Record/逻辑运算/关系运算）、模式的解构与赋值、switch 表达式中的模式应用。

**源 URL**: https://dart.cn/language/patterns, https://dart.cn/language/pattern-types

### 5. dart-null-safety
**描述**: 运用 Dart 健全空安全机制（Sound Null Safety），消除空引用异常并编写类型安全的代码。

**覆盖**: null-safety 基本概念与语法（`?`/`!`/`late`）、类型提升与 flow analysis、null-aware 操作符（`?.`/`??`/`??=`）、深入理解空安全原理、Dart 3 迁移到空安全的指南。

**源 URL**: https://dart.cn/null-safety, https://dart.cn/null-safety/understanding-null-safety, https://dart.cn/resources/dart-3-migration

### 6. dart-async-concurrency
**描述**: 掌握 Dart 异步与并发编程（Future、async/await、Stream、Isolate），编写高性能无阻塞的应用。

**覆盖**: 并发编程概念、async/await 语法与工作原理、Future API（then/catchError/whenComplete/静态方法）、错误处理与异常传播、Stream 的使用与创建（单订阅/广播/StreamController）、Isolate 隔离（创建/通信/端口）。

**源 URL**: https://dart.cn/language/concurrency, https://dart.cn/language/async, https://dart.cn/language/isolates, https://dart.cn/libraries/async/async-await, https://dart.cn/libraries/async/futures-error-handling, https://dart.cn/libraries/async/using-streams, https://dart.cn/libraries/async/creating-streams

### 7. dart-collections-iterables
**描述**: 使用 Dart 集合操作与可迭代工具链（List、Set、Map、Iterable），高效处理数据变换。

**覆盖**: 集合类型（List/Set/Map）的创建与操作、Iterable 的惰性求值与方法链（map/where/fold/reduce/expand/take/any/every）、spread 运算符与 collection-if/for。

**源 URL**: https://dart.cn/language/collections, https://dart.cn/libraries/collections/iterables

### 8. dart-core-libraries
**描述**: 熟练使用 Dart SDK 核心库（dart:core、dart:convert、dart:io、dart:math），避免重复造轮子。

**覆盖**: 核心库总览、dart:core 提供的基础类型与工具、dart:convert 提供的数据转换（json/utf8/base64）、dart:io 提供的文件和网络操作、dart:math 提供的数学与随机数、dart:async 提供的异步编程工具。

**源 URL**: https://dart.cn/libraries, https://dart.cn/libraries/dart-core, https://dart.cn/libraries/dart-async, https://dart.cn/libraries/dart-math, https://dart.cn/libraries/dart-convert, https://dart.cn/libraries/dart-io

### 9. dart-packages-pub
**描述**: 管理 Dart 包生态（Pub 仓库），掌握创建、使用、发布 Package 及工作空间的多包管理。

**覆盖**: 如何使用 Pub 包（依赖添加/版本约束/依赖覆盖）、创建 Package（文件结构/元数据/pubspec）、发布 Package 到 pub.dev（发布者认证/安全通告）、依赖管理与版本策略、工作空间（Monorepo）配置、Hooks 系统、环境变量声明。

**源 URL**: https://dart.cn/tools/pub/packages, https://dart.cn/tools/pub/create-packages, https://dart.cn/tools/pub/publishing, https://dart.cn/tools/pub/dependencies, https://dart.cn/tools/pub/workspaces, https://dart.cn/tools/hooks, https://dart.cn/tools/pub/package-layout, https://dart.cn/tools/pub/versioning, https://dart.cn/libraries/core/environment-declarations

### 10. dart-effective-dart
**描述**: 遵循 Effective Dart 最佳实践（代码风格、文档、用法、API 设计），编写一致、可维护、高效的 Dart 代码。

**覆盖**: 代码风格规范（命名约定/格式化/导入排序/花括号）、文档规范（文档注释/示例代码/包文档）、使用规范（Collection 使用/函数使用/变量使用/成员使用）、API 设计规范（类设计/类型签名/参数设计/相等性）。

**源 URL**: https://dart.cn/effective-dart, https://dart.cn/effective-dart/style, https://dart.cn/effective-dart/documentation, https://dart.cn/effective-dart/usage, https://dart.cn/effective-dart/design

---

## 四、生成器工具设计

### 4.1 命令体系（完整保留）

| 命令 | 功能 |
|------|------|
| `generate-skill` | 从 YAML 配置生成全新 SKILL.md 文件 |
| `update-skill` | 结合已有内容 + 新抓取文档，增量更新 SKILL.md |
| `validate-skill` | 重新生成并对比现有文件，产生质量评分（Grade: 0-100） |
| `update-readme` | 自动生成 README 中的技能表格 |

### 4.2 OpenCodeService（唯一替换点）

```yaml
# 环境变量
OPENCODE_BASE_URL: https://api.xxx.com          # OpenAI-compatible endpoint
OPENCODE_API_KEY: sk-xxxxxxxx                    # API key
OPENCODE_MODEL: deepseek-v4-pro                  # 模型名（默认值）
```

**API 调用格式**（OpenAI-compatible）：

```
POST {OPENCODE_BASE_URL}/v1/chat/completions
{
  "model": "{OPENCODE_MODEL}",
  "temperature": 0.2,
  "max_tokens": 8192,
  "messages": [
    {"role": "system", "content": "<skill_instructions.dart 的内容>"},
    {"role": "user", "content": "<prompts.dart 的提示模板 + 抓取的文档 Markdown>"}
  ]
}
```

### 4.3 与原 Gemini 实现的差异

| 特性 | Gemini 实现 | OpenCode 实现 |
|------|-----------|--------------|
| 系统指令 | Gemini `systemInstruction` 参数 | OpenAI `messages[].role=system` |
| 思考预算 | `thinkingBudget` 参数 | `reasoning_effort` 参数（或省略） |
| API 认证 | `x-goog-api-key` header | `Authorization: Bearer xxx` header |
| 安全设置 | Gemini 安全等级配置 | OpenAI `reasoning_effort` 或省略 |
| 内容清理 | 去掉代码块 + 前置元数据 | 同 Gemini（输出格式一致） |

---

## 五、SKILL.md 模板格式

每个生成的文件严格遵循以下结构（由 `skill_instructions.dart` 系统指令约束）：

```markdown
---
name: dart-fundamentals
description: <1-2句话说明用途和适用场景>
metadata:
  model: {OPENCODE_MODEL}
  last_modified: <ISO 8601 时间戳>
---
# <动名词标题>

## Contents
- [章节1](#章节1)
- [Workflow: ...](#workflow)
- [Examples](#examples)

## 概念章节
<从 dart.cn 文档提取的指导内容>

## Workflow: <任务名称>
### Task Progress
- [ ] Step 1: ...
- [ ] Step 2: ...
- [ ] Step N: Feedback Loop（验证 -> 修复 -> 重复）

<条件逻辑: "If ... then ... else ...">

## Examples
<完整可运行 Dart 代码>
```

---

## 六、数据流

```
  dart.cn 页面 (HTML)
         │
    ResourceFetcherService.fetchAndConvertContent()
    ├── http.Client.get(url)
    └── MarkdownConverter.convert(html) → Markdown
         │
         聚合 Markdown
         │
    OpenCodeService.generateSkillContent(markdown, name, description)
    ├── 注入系统指令 (skillInstructions)
    ├── 注入提示模板 (Prompts.createSkillPrompt)
    ├── POST /v1/chat/completions → AI 响应
    └── cleanContent() → 写入 skills/{name}/SKILL.md
         │
    dart_skills_lint (可选校验)
    ├── valid-yaml-metadata    → 检查 frontmatter
    ├── invalid-skill-name     → 检查命名规范
    ├── description-too-long   → 检查描述长度
    ├── check-absolute-paths   → 检查绝对路径
    └── check-relative-paths   → 检查相对路径
```

---

## 七、文件结构（最终交付物）

```
D:\MyProject\studydart-skills/
├── AGENTS.md
├── README.md
├── DESIGN.md                              ← 本文档
├── resources/
│   └── studydart_skills.yaml              ← 技能配置（含 instructions 字段）
├── skills/
│   ├── dart-fundamentals/SKILL.md
│   ├── dart-type-system/SKILL.md
│   ├── dart-classes-objects/SKILL.md
│   ├── dart-pattern-matching/SKILL.md
│   ├── dart-null-safety/SKILL.md
│   ├── dart-async-concurrency/SKILL.md
│   ├── dart-collections-iterables/SKILL.md
│   ├── dart-core-libraries/SKILL.md
│   ├── dart-packages-pub/SKILL.md
│   └── dart-effective-dart/SKILL.md
├── tool/
│   └── study_generator/
│       ├── pubspec.yaml
│       ├── analysis_options.yaml
│       ├── bin/generate.dart
│       └── lib/src/
│           ├── commands/
│           │   ├── base_yaml_command.dart
│           │   ├── base_skill_command.dart
│           │   ├── generate_skill_command.dart
│           │   ├── update_skill_command.dart
│           │   ├── validate_skill_command.dart
│           │   └── update_readme_command.dart
│           ├── models/
│           │   └── skill_params.dart
│           └── services/
│               ├── opencode_service.dart         ← 替换 gemini_service
│               ├── resource_fetcher_service.dart
│               ├── markdown_converter.dart
│               ├── prompts.dart
│               └── skill_instructions.dart
└── .claude/
    └── skills/
        └── studydart-skills/                    ← GitNexus 元技能
```

---

## 八、验收标准

1. `dart run generate-skill --config resources/studydart_skills.yaml --output skills/` 能成功生成 10 个 SKILL.md
2. 每个 SKILL.md 通过 `dart_skills_lint` 校验（零 error）
3. 每个 SKILL.md 包含：YAML frontmatter、目录、概念章节、带 Task Progress 的工作流、条件逻辑、完整代码示例
4. `dart run validate-skill ...` 能产出评分报告
5. `dart run update-readme` 能自动更新 README 的技能表格
