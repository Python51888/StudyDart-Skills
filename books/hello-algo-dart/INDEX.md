# INDEX — 《Hello 算法》Dart 版 蒸馏技能总览

> 来源：靳宇栋《Hello 算法》Dart 语言版 Release 1.3.0 (2026)
> 蒸馏日期：2026-05-14

## Skill 列表

| # | Skill | 描述 | 领域标签 |
|---|-------|------|----------|
| 0 | [foundations](foundations/SKILL.md) | 算法思维基础、数据结构分类、学习路径 | fundamentals |
| 1 | [complexity](complexity/SKILL.md) | 时间复杂度与空间复杂度分析 | core-libraries, fundamentals |
| 2 | [ds-choice](ds-choice/SKILL.md) | 9 种数据结构选择决策矩阵 | core-libraries, collections-iterables |
| 2 | [ds-choice](ds-choice/SKILL.md) | 8+1 种数据结构（含 Dart List）选择决策矩阵 | core-libraries, collections-iterables |
| 3 | [algorithm-paradigms](algorithm-paradigms/SKILL.md) | 分治/回溯/DP/贪心四大范式对比与选择 | core-libraries, collections-iterables |
| 4 | [sort-search](sort-search/SKILL.md) | 9 种排序算法对比 + 二分查找变体 + 哈希优化 | core-libraries, collections-iterables |
| 5 | [code-pitfalls](code-pitfalls/SKILL.md) | 20+ 常见算法陷阱与反模式（Dart 版） | fundamentals, core-libraries |

## 引用关系图

```
                    complexity
                    （复杂度分析基础）
                      ↓
         ┌────────────┼────────────┐
         ↓            ↓            ↓
    ds-choice    sort-search   algorithm-paradigms
  （数据结构选择）（排序与搜索）  （算法范式）
         ↓            ↓            ↓
         └────────────┼────────────┘
                      ↓
               code-pitfalls
               （常见陷阱）
```

- `complexity` → 所有技能的基础，提供复杂度分析思维
- `ds-choice` ↔ `algorithm-paradigms`：数据结构是算法的载体
- `sort-search` → `algorithm-paradigms`：归并/快排是分治实例，堆排序关联堆
- `code-pitfalls` → 所有技能的反面参考

## 与现有 studydart-skills 的关联

| 蒸馏技能 | 对应的官技 | 关联说明 |
|---------|-----------|---------|
| complexity | dart-fundamentals | 函数、递归、基本语法 |
| ds-choice | dart-collections-iterables | List/Set/Map/Queue 操作 |
| ds-choice | dart-core-libraries | dart:core 集合类 |
| algorithm-paradigms | dart-async-concurrency | 递归深度与栈、并行计算 |
| sort-search | dart-collections-iterables | 排序方法、集合操作 |
| sort-search | dart-core-libraries | dart:math 数学函数 |
| code-pitfalls | dart-fundamentals | 变量、操作符陷阱 |
| code-pitfalls | dart-type-system | 类型安全、精度问题 |

## 统计

- 蒸馏由：58 个候选单元 → 5 个合成技能
- 淘汰：27 个单元（见 rejected/verification-report.md）
- 候选池：framework(6) + principle(22) + case(14) + counter-example(16)
