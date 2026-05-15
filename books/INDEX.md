# 全局书籍知识索引

> 自动生成。每本书蒸馏完成后，本书条目会自动添加至此文件。
> 用户也可手动添加注释或交叉引用。

## 已蒸馏书籍

### 《Hello 算法》Dart 版 (`hello-algo-dart`)
- **作者**: 靳宇栋（@krahets）
- **出版年**: 2026 (Release 1.3.0)
- **蒸馏日期**: 2026-05-14 | **合并为统一技能**: 2026-05-15
- **Skills 数量**: 1（合并自 6 个原始技能）
- **Skill**: `dart-algorithms` — 完整六章体系：算法思维基础 → 复杂度分析 → 数据结构选择 → 排序搜索 → 算法范式 → 常见陷阱
- **交叉引用**: 与 dart-fundamentals、dart-core-libraries、dart-collections-iterables、dart-async-concurrency 互补
- **详细索引**: [books/hello-algo-dart/INDEX.md](hello-algo-dart/INDEX.md)

<!-- 书籍条目格式：
### <书名> (`<book-slug>`)
- **作者**: <作者名>
- **出版年**: <年份>
- **蒸馏日期**: <YYYY-MM-DD>
- **Skills 数量**: N
- **领域标签**: <tag1>, <tag2>
- **Skills**:
  - `<skill-slug>`: <简短描述>
  - ...
- **交叉引用**: 与现有 skills/ 的关联说明
-->

 

## 推荐起始书籍

首次使用时，建议从以下书籍中选择一本试点：

1. **《Dart Apprentice》** — 基础语法、变量选择、空安全实践，适合蒸馏基础方法论
2. **《Flutter Apprentice》** — UI 组件设计、状态管理决策树，适合蒸馏设计模式
3. **《Effective Dart》** — 编码规范、API 设计，适合蒸馏编码风格类 skills

详见 `resources/dart_books.yaml`。

## 交叉引用图

```
books/<book-slug>/INDEX.md    → 单书 skill 引用图
books/INDEX.md                → 全局汇总（本文件）
skills/                       → 官方 Dart 学习技能
  ↑ 蒸馏产出的 skills 可与此处的官方技能形成知识互补
```

## 如何使用

1. 准备好书籍文本（PDF/EPUB/TXT）
2. 在 agent 中说："帮我蒸馏 books/我的书.pdf"
3. Agent 自动执行六阶段蒸馏流水线
4. 产出 skills 存放在 `books/<book-slug>/` 下
5. 本书 INDEX.md 和本文件自动更新
