# INDEX — 《Hello 算法》Dart 版 蒸馏技能总览

> 来源：靳宇栋《Hello 算法》Dart 语言版 Release 1.3.0 (2026)
> 蒸馏日期：2026-05-14 | 合并为统一技能：2026-05-15

## Skill

| Skill | 描述 | 文件 |
|-------|------|------|
| dart-algorithms | 《Hello 算法》完整技能手册 — 算法思维基础 → 复杂度分析 → 数据结构选择 → 排序搜索 → 算法范式 → 常见陷阱 | [SKILL.md](SKILL.md) |

## 章节结构（原书逻辑流）

```
第一部分：算法思维基础 (foundations)
    ↓
第二部分：复杂度分析 (complexity)
    ↓
 ┌──────┼──────┐
 ↓      ↓      ↓
第三部分    第四部分    第五部分
(数据结构)  (排序搜索)  (算法范式)
    ↓      ↓      ↓
 └──────┼──────┘
    ↓
第六部分：常见陷阱 (code-pitfalls)
```

## 与现有 studydart-skills 的关联

| 章节 | 对应的官技 | 关联说明 |
|------|-----------|---------|
| 第二部分（复杂度） | dart-fundamentals | 函数、递归、基本语法 |
| 第三部分（数据结构） | dart-collections-iterables | List/Set/Map/Queue 操作 |
| 第三部分（数据结构） | dart-core-libraries | dart:core 集合类 |
| 第四部分（排序搜索） | dart-collections-iterables | 排序方法、集合操作 |
| 第四部分（排序搜索） | dart-core-libraries | dart:math 数学函数 |
| 第五部分（算法范式） | dart-async-concurrency | 递归深度与栈、并行计算 |
| 第六部分（常见陷阱） | dart-fundamentals | 变量、操作符陷阱 |
| 第六部分（常见陷阱） | dart-type-system | 类型安全、精度问题 |

## 辅助文件

| 文件 | 用途 |
|------|------|
| [BOOK_OVERVIEW.md](BOOK_OVERVIEW.md) | Phase 0：全书概览、骨架、术语表 |
| [candidates/](candidates/) | Phase 1：58 个候选单元原始提取 |
| [rejected/](rejected/) | Phase 5：27 个被淘汰候选的验证报告 |
| [test-prompts.json](test-prompts.json) | Phase 6：技能验证压力测试用例 |

## 统计

- 蒸馏由：58 个候选单元 → 6 个原始技能 → 1 个统一技能
- 淘汰：27 个单元（见 rejected/verification-report.md）
- 候选池：framework(6) + principle(22) + case(14) + counter-example(16)
