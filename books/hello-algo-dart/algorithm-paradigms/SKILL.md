---
name: dart-book-hello-algo-algorithm-paradigms
description: 掌握分治、回溯、动态规划、贪心四大算法范式的核心思想、适用场景、实现模板和选择决策框架
metadata:
  model: deepseek-v4-pro
  last_modified: 2026-05-14T10:00:00Z
  tags: [dart, core-libraries, collections-iterables]
  source_book: hello-algo-dart
---

# 算法范式对比与选择

> 来源：靳宇栋《Hello 算法》Dart 语言版，Release 1.3.0，2026

## Contents

- [四大范式速览](#四大范式速览)
- [一、分治 Divide & Conquer](#一分治-divide--conquer)
- [二、回溯 Backtracking](#二回溯-backtracking)
- [三、动态规划 Dynamic Programming](#三动态规划-dynamic-programming)
- [四、贪心 Greedy](#四贪心-greedy)
- [五、范式选择决策框架](#五范式选择决策框架)
- [六、回溯→记忆化搜索→动态规划渐进路径](#六回溯记忆化搜索动态规划渐进路径)
- [七、范式横向对比表](#七范式横向对比表)
- [Workflow：拿到新问题如何选范式](#workflow拿到新问题如何选范式)
- [Examples](#examples)

---

## 四大范式速览

| 范式 | 核心思想 | 时间复杂度典型 | 适合场景 | 致命缺陷 |
|------|---------|--------------|---------|---------|
| 分治 | 分解→独立求解→合并 | O(n log n) | 子问题独立可合并 | 子问题重叠时重复计算 |
| 回溯 | 穷举+剪枝+回退 | O(k^n) / O(n!) | 求所有解/排列组合 | 无剪枝时状态爆炸 |
| 动态规划 | 存储子问题解避免重复 | O(n) / O(n²) | 最优解+重叠子问题 | 不满足最优子结构则失败 |
| 贪心 | 每一步选局部最优 | O(n) / O(n log n) | 贪心选择性质成立 | 不可靠的局部选择导致次优 |

---

## 一、分治 Divide & Conquer

### R — 原文引用

> 分治算法递归地将原问题划分为多个相互独立的子问题，直至最小子问题，并在回溯中合并子问题的解，最终得到原问题的解。— §14.2

> 分：递归地将原数组划分为两个子数组，直到子数组只剩一个元素。治：从底至顶地将有序的子数组合并。— §12.1

### I — 用自己的话重写

分治将大问题递归拆分为若干个**结构相同、规模更小**的子问题。子问题之间**完全独立**（无重叠），各自求解后再将结果**合并**为原问题解。核心是"分—治—合"三步，每一层的子问题与父问题形式一致，只是数据规模递减。提升效率的底层逻辑有二：操作数量优化（划分后常数项缩小，递归至 O(n log n)）；并行计算优化（独立子问题可多核并行）。

### A1 — 书中案例

**归并排序**：将数组从中间分成两半，递归排好左右子数组，再合并两个有序数组。

```dart
/// 归并排序 — 分治经典实现
void mergeSort(List<int> nums, int left, int right) {
  if (left >= right) return;                  // 终止条件：子数组长度为 1
  int mid = left + (right - left) ~/ 2;      // 分：计算中点
  mergeSort(nums, left, mid);                 // 治：递归排序左半
  mergeSort(nums, mid + 1, right);            // 治：递归排序右半
  _merge(nums, left, mid, right);             // 合：合并两个有序子数组
}

void _merge(List<int> nums, int left, int mid, int right) {
  List<int> tmp = List.filled(right - left + 1, 0);
  int i = left, j = mid + 1, k = 0;
  while (i <= mid && j <= right) {
    if (nums[i] <= nums[j]) tmp[k++] = nums[i++];
    else tmp[k++] = nums[j++];
  }
  while (i <= mid) tmp[k++] = nums[i++];
  while (j <= right) tmp[k++] = nums[j++];
  for (int p = 0; p < tmp.length; p++) nums[left + p] = tmp[p];
}
```

**汉诺塔**：n 个盘子从 A 移到 C，借助 B。分解为三步：n-1 个盘子 A→B、第 n 个盘子 A→C、n-1 个盘子 B→C。

```dart
/// 汉诺塔 — 分治递归
void hanoi(List<int> A, List<int> B, List<int> C) {
  void _move(int n, List<int> src, List<int> buf, List<int> tar) {
    if (n == 1) { tar.add(src.removeLast()); return; }
    _move(n - 1, src, tar, buf);   // 子问题1：n-1 移到缓冲柱
    tar.add(src.removeLast());      // 最大盘直接移到目标
    _move(n - 1, buf, src, tar);   // 子问题2：n-1 从缓冲移到目标
  }
  _move(A.length, A, B, C);
}
```

### A2 — 何时需要分治

- 问题能按相同逻辑分解为更小规模的子问题
- 子问题间无依赖、无重叠（否则应选 DP）
- 子问题的解可以合并还原原问题的解
- 典型信号：归并排序、快速排序、二分查找、构建二叉树、最近点对、大整数乘法

### E — 可执行步骤 / Dart 实现模板

```dart
/// 分治通用模板
ReturnType divideAndConquer(Params params) {
  // 1. 终止条件：问题规模已经足够小，直接求解
  if (isBaseCase(params)) return solveBaseCase(params);

  // 2. 分（Divide）：将原问题拆分为 k 个子问题
  var subProblems = divide(params, k);

  // 3. 治（Conquer）：递归解决每个子问题（可并行）
  var subResults = subProblems.map((p) => divideAndConquer(p));

  // 4. 合（Combine）：合并子问题的解得到原问题的解
  return merge(subResults);
}
```

### B — 边界限制

- 三个条件缺一不可：可分解、子问题独立、解可合并（§12.1.1）
- 若子问题重叠（如 Fibonacci），分治会重复计算导致指数级开销——应改用 DP
- 递归深度可能导致栈溢出，部分场景需转为迭代（如归并排序的非递归实现）
- 等分 k 份时，当 n > 4 划分才有操作数量优势（§12.1.2）

---

## 二、回溯 Backtracking

### R — 原文引用

> 回溯算法在尝试和回退中穷举所有可能的解，并通过剪枝避免不必要的搜索分支。— §14.2

> "剪枝"可避免遍历无意义的搜索空间，从而提升搜索效率。— §13.1

### I — 用自己的话重写

回溯是一种**试探性穷举**搜索：每一步在可选集合中尝试一个选项，递归深入；若当前路径不可能产生解，则**剪枝**终止该分支；若所有选项穷尽或遇错，则**回退**到上一步，撤销选择，替换下一个候选。本质是 DFS 在解空间树上的搜素，辅以约束条件剪枝来压缩搜索空间。核心四要素：状态（state）、选择（choice）、剪枝条件（isValid）、回退（undo）。

### A1 — 书中案例

**全排列**：给定不重复数字数组，返回所有排列。

```dart
/// 全排列 — 回溯模板
List<List<int>> permute(List<int> nums) {
  List<List<int>> res = [];
  List<int> state = [];
  List<bool> selected = List.filled(nums.length, false);
  void backtrack() {
    if (state.length == nums.length) { res.add(List.from(state)); return; }
    for (int i = 0; i < nums.length; i++) {
      if (selected[i]) continue;           // 剪枝：跳过已选元素
      selected[i] = true;
      state.add(nums[i]);                  // 尝试
      backtrack();                         // 递归
      selected[i] = false;
      state.removeLast();                  // 回退
    }
  }
  backtrack();
  return res;
}
```

**子集和 I**：无重复元素数组，求所有和等于 target 的子集。

```dart
/// 子集和 — 带 start 剪枝
void backtrack(List<int> state, int target, int start, List<int> choices,
               List<List<int>> res) {
  if (target == 0) { res.add(List.from(state)); return; }
  for (int i = start; i < choices.length; i++) {
    if (target - choices[i] < 0) break;        // 剪枝一：超出目标
    state.add(choices[i]);                      // 尝试
    backtrack(state, target - choices[i], i, choices, res);
    state.removeLast();                         // 回退
  }
}
```

**N 皇后**：n×n 棋盘放 n 个皇后，彼此不攻击。

```dart
/// N 皇后 — 逐行放置 + 对角线剪枝
List<List<String>> solveNQueens(int n) {
  List<List<String>> res = [];
  List<int> cols = List.filled(n, 0);      // cols[row] = col
  List<bool> diag1 = List.filled(2 * n, false);
  List<bool> diag2 = List.filled(2 * n, false);
  void backtrack(int row) {
    if (row == n) { res.add(_buildBoard(cols)); return; }
    for (int col = 0; col < n; col++) {
      int d1 = row - col + n, d2 = row + col;
      if (cols.contains(col) || diag1[d1] || diag2[d2]) continue; // 剪枝
      cols[row] = col; diag1[d1] = diag2[d2] = true; // 尝试
      backtrack(row + 1);
      diag1[d1] = diag2[d2] = false;                // 回退
    }
  }
  backtrack(0);
  return res;
}
```

### A2 — 何时需要回溯

- 需要**穷举所有可能解**（全排列、子集、组合）
- 问题可用**决策树**建模，每个节点代表一次选择
- 搜索空间可通过**约束条件剪枝**大幅压缩
- 典型信号：排列、组合、子集、棋盘问题、数独、图着色

### E — 可执行步骤 / Dart 实现模板

```dart
/// 回溯通用模板
void backtrack(
  State state,           // 当前状态
  List<Choice> choices,  // 当前可选列表
  List<State> res,       // 结果集
) {
  // 1. 检查是否为解 → 记录
  if (isSolution(state)) { res.add(state.copy()); /* 可选 return */ }

  // 2. 遍历所有选择
  for (final choice in choices) {
    // 3. 剪枝：跳过不合法选项
    if (!isValid(state, choice)) continue;

    // 4. 尝试：做出选择，更新状态
    makeChoice(state, choice);

    // 5. 递归深入
    backtrack(state, nextChoices(choice), res);

    // 6. 回退：撤销选择，恢复状态
    undoChoice(state, choice);
  }
}
```

### B — 边界限制

- 时间复杂度可达 O(k^n) 或 O(n!)，**剪枝是核心竞争力**——无剪枝的回溯在大规模问题中不可行
- 剪枝条件必须**正确且尽可能紧**：宽松则效率低，过紧则漏解
- 重复选择剪枝 vs 相等元素剪枝目标不同：前者防同一元素被多次选（用 `selected` 数组），后者防等值元素产生重复排列/子集（用 `duplicated` 集合或 `start` 索引，§13.2-13.3）
- 回溯不适合纯"求最优解"问题——那是 DP 的领地

---

## 三、动态规划 Dynamic Programming

### R — 原文引用

> 动态规划将一个问题分解为一系列更小的子问题，并通过存储子问题的解来避免重复计算，从而大幅提升时间效率。— §14.1

> 动态规划中的子问题是相互依赖的，在分解过程中会出现许多重叠子问题。— §14.2

### I — 用自己的话重写

DP 的核心是**空间换时间**：将分解出的重叠子问题的解存入 dp 表，后续直接查表而不用重新计算，将指数级复杂度降为多项式级。DP 与分治的关键区别：分治的子问题**独立**（各自求解，无重复），DP 的子问题**依赖重叠**（同一子问题被反复用到）。三大前提条件：重叠子问题（驱动动力）、最优子结构（原问题最优解由子问题最优解构建）、无后效性（状态未来发展只取决于当前状态，与历史路径无关）。

### A1 — 书中案例

**爬楼梯**：每步可上 1 或 2 阶，n 阶楼梯有几种爬法？dp[i] = dp[i-1] + dp[i-2]

```dart
/// 爬楼梯 — DP（自底向上 + 滚动变量优化）
int climbingStairsDP(int n) {
  if (n == 1 || n == 2) return n;
  int a = 1, b = 2;               // a=dp[i-2], b=dp[i-1]
  for (int i = 3; i <= n; i++) {
    int c = a + b;                // dp[i] = dp[i-1] + dp[i-2]
    a = b;
    b = c;
  }
  return b;
}
```

**0-1 背包**：n 个物品，重量 w[i]、价值 v[i]，容量 cap，求最大价值。

```dart
/// 0-1 背包 — DP 空间优化版（一维倒序）
int knapsack01(List<int> w, List<int> v, int cap) {
  List<int> dp = List.filled(cap + 1, 0);
  for (int i = 0; i < w.length; i++) {
    for (int c = cap; c >= w[i]; c--) {   // 倒序遍历，防覆盖
      dp[c] = max(dp[c], dp[c - w[i]] + v[i]);
    }
  }
  return dp[cap];
}
```

**编辑距离**：将 s1 变成 s2 的最少操作数（增/删/改）。

```dart
/// 编辑距离 — DP
int editDistance(String s1, String s2) {
  int m = s1.length, n = s2.length;
  List<List<int>> dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
  for (int i = 0; i <= m; i++) dp[i][0] = i;
  for (int j = 0; j <= n; j++) dp[0][j] = j;
  for (int i = 1; i <= m; i++) {
    for (int j = 1; j <= n; j++) {
      if (s1[i - 1] == s2[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1];
      } else {
        dp[i][j] = min(min(dp[i - 1][j], dp[i][j - 1]), dp[i - 1][j - 1]) + 1;
      }
    }
  }
  return dp[m][n];
}
```

### A2 — 何时需要动态规划

- 问题可用回溯但出现**大量重叠子问题**（递归树中有大量相同子树）
- 题目含"最大/最小/最多/最少/最长/最短"等最优化描述（加分项）
- 状态能表示为列表/矩阵/树，且状态间存在递推关系
- 目标是求**最优解**而非列举所有方案（减分项：需要返回所有具体方案时 DP 不适用，§14.3.1）

### E — 可执行步骤 / Dart 实现模板

```dart
/// DP 解题五步法（§14.3.2）
///
/// Step 1: 定义状态与 dp 表
///   将决策变量抽象为状态维度，如 dp[i][j] 表示前 i 个物品容量 j 下的最大价值
///
/// Step 2: 找出最优子结构
///   原问题最优解如何从子问题最优解构建，如 dp[i][c] = max(dp[i-1][c], dp[i-1][c-w]+v)
///
/// Step 3: 推导状态转移方程
///   用公式表达递推关系
///
/// Step 4: 确定边界条件与遍历顺序
///   初始化 dp[0][*] 和 dp[*][0]，确保计算 dp[i] 时前序状态已就绪
///
/// Step 5: 可选空间优化
///   若当前状态仅依赖有限个前序状态，用滚动变量/数组降维
///
/// 模板代码：
ReturnType dynamicProgramming(Params params) {
  // 1. 定义 dp 表
  var dp = List.generate(n + 1, (_) => List.filled(m + 1, 0));

  // 2. 初始化边界条件
  for (int i = 0; i <= n; i++) dp[i][0] = baseValue(i);
  for (int j = 0; j <= m; j++) dp[0][j] = baseValue(j);

  // 3. 按正确顺序递推（确保依赖的状态已计算）
  for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= m; j++) {
      // 4. 状态转移
      dp[i][j] = transition(dp, i, j, params);
    }
  }

  // 5. 返回目标状态
  return dp[n][m];
}
```

### B — 边界限制

- **三道门槛**：重叠子问题 + 最优子结构 + 无后效性，缺一不可（§14.2）
- **无后效性被违反时**：可通过增加状态维度（如 [i] 扩为 [i, j]）来恢复，但代价是 dp 表维度膨胀（§14.2.2 带约束爬楼梯例）。严重有后效性问题（如每次决策改变全局约束）即使扩展状态也无法救回
- **空间优化有坑**：0-1 背包一维化时**必须倒序遍历** c（因为当前状态依赖上一行正上方和左上方，倒序防止尚未使用的旧值被覆盖）；完全背包则**正序**（因为依赖同一行正上方和正左方，§14.7 小结）
- **目标不是"最优值"而是"所有方案"时**：DP 不适用，退回回溯

---

## 四、贪心 Greedy

### R — 原文引用

> 贪心算法不会考虑过去的决策，而是一路向前地进行贪心选择。— §15.1

> 动态规划会根据之前阶段的所有决策来考虑当前决策。— §15.1（对比 DP）

### I — 用自己的话重写

贪心在每一步都做出**当前看来最好**的选择（局部最优），期望一路选下去就得到全局最优解。它"只看眼前"——不回头改之前的决定，也不规划未来。核心挑战在于**贪心策略的正确性**：并非所有问题都满足贪心选择性质（局部最优→全局最优）。当条件满足时，贪心往往比 DP 快一个数量级；当条件不满足时，贪心会给出次优解甚至错误解。

### A1 — 书中案例

**分数背包**：物品可分割，每次选单位价值最高的物品装满背包。

```dart
/// 分数背包 — 贪心（按单位价值降序）
double fractionalKnapsack(List<int> w, List<int> v, int cap) {
  List<_Item> items = [];
  for (int i = 0; i < w.length; i++) items.add(_Item(w[i], v[i]));
  items.sort((a, b) => (b.v / b.w).compareTo(a.v / a.w)); // 贪心策略：按单位价值排序

  double res = 0;
  for (final item in items) {
    if (item.w <= cap) { res += item.v; cap -= item.w; }
    else { res += (item.v / item.w) * cap; break; }
  }
  return res;
}
```

**最大容量问题**：给定 n 个隔板高度，选两个隔板使得构成的容器能装最多水。

```dart
/// 最大容量 — 贪心双指针
int maxCapacity(List<int> ht) {
  int i = 0, j = ht.length - 1, res = 0;
  while (i < j) {
    int cap = min(ht[i], ht[j]) * (j - i);
    res = max(res, cap);
    if (ht[i] < ht[j]) i++; else j--;  // 贪心策略：移动较短的板
  }
  return res;
}
```

**零钱兑换（正例与反例）**：

```dart
/// 零钱兑换 — 贪心（仅当硬币面额满足特定条件时才正确）
int coinChangeGreedy(List<int> coins, int amt) {
  coins.sort((a, b) => b.compareTo(a)); // 从大到小
  int count = 0;
  for (final coin in coins) {
    count += amt ~/ coin;
    amt %= coin;
  }
  return amt == 0 ? count : -1;
}
// ✅ coins=[1,5,10,20], amt=31 → 20+10+1 = 3 枚，正确
// ❌ coins=[1,5,11], amt=15 → 贪心选 11+1+1+1+1=5 枚，但最优是 5+5+5=3 枚
```

### A2 — 何时需要贪心

- 问题满足**贪心选择性质**：每一步的局部最优决策不会阻止达到全局最优
- 同时满足**最优子结构**（与 DP 共享）
- 数据具有某种可排序/可比较的性质，能定义清晰的贪心策略
- 典型信号：分数背包、区间调度、霍夫曼编码、Dijkstra 最短路径、活动选择、最大容量

### E — 可执行步骤 / Dart 实现模板

```dart
/// 贪心三步法（§15.1.3）
///
/// Step 1: 问题分析 — 梳理状态、优化目标、约束条件
/// Step 2: 确定贪心策略 — 每一步选择什么规则（如"选最大"、"选最轻"、"选最早结束"）
/// Step 3: 正确性验证 — 用反证法或数学归纳法证明（实践中可用测试样例迭代验证）
///
/// 模板代码：
ResultType greedy(Input input) {
  // 1. 预处理（排序、建堆等），为贪心策略做准备
  input.sort((a, b) => greedyComparator(a, b));

  ResultType result = initialValue;

  // 2. 按贪心策略逐步决策
  for (final item in input) {
    if (canInclude(item, result)) {
      result = applyGreedyChoice(result, item);  // 局部最优选择
      if (isComplete(result)) break;             // 提前终止条件
    }
  }

  return result;
}
```

### B — 边界限制

- **贪心选择性质是硬条件**：不满足时贪心结果不可靠（如零钱兑换 coins=[1,5,11] 时，§15.1）
- **正确性必须验证**：书中建议用反证法或数学归纳法；不可想当然——很多看似可贪心的问题实则需要 DP（§15.1.2）
- **贪心≠简单**：贪心策略设计千变万化，不同问题差异巨大，没有万用模板
- **贪心失败时用 DP**：贪心是"健忘的"只向前看，DP 是"记忆的"回顾过去；两者共享最优子结构，前者更高效但条件苛刻

---

## 五、范式选择决策框架

```
                      ┌─ 拿到一个新问题 ─┐
                      │                   │
                      ▼                   ▼
              能否拆成独立子问题？    需要穷举所有解？
              ├─ 是 → 分治           ├─ 是 → 回溯（+剪枝）
              │                       │
              ▼                       ▼
         子问题有重叠？        有大量重叠子问题且求最优？
         ├─ 否 → 分治 ✓       ├─ 是 → 动态规划
         │                       │
         ▼                       ▼
     是 → 动态规划          局部最优 = 全局最优？
                           ├─ 是 → 贪心（更快）
                           └─ 否 → 动态规划
```

### 决策检查清单

| 检查项 | 是 → | 否 → 下一项 |
|--------|------|-----------|
| 1. 子问题可分解且独立？ | **分治** | 2 |
| 2. 需要穷举所有解（排列/组合/子集）？ | **回溯** + 剪枝 | 3 |
| 3. 求最优解 + 重叠子问题 + 最优子结构？ | **动态规划** | 4 |
| 4. 局部最优可保证全局最优？ | **贪心** | 5 |
| 5. 回溯可解但有大量重叠子问题？ | **DP**（渐进优化） | 回到回溯 |

### 动态规划加分/减分项（§14.3.1）

**加分项**（适合 DP）：
- 题目含"最大/最小/最多/最少/最长/最短"
- 状态可用列表/矩阵/树表示且存在递推关系
- 时间复杂度可通过缓存从指数降为多项式

**减分项**（不适合 DP）：
- 目标是找出**所有方案**而非最优解
- 有明显的排列组合特征需返回多个具体方案
- 严重有后效性，扩展状态维度也无法消除

---

## 六、回溯→记忆化搜索→动态规划渐进路径

> 面对 DP 问题的推荐开发顺序（§14.1, §14.3）

### 四阶段渐进优化

```
回溯（暴力 DFS）                复杂度 O(2^n) / O(n!)
    │  加入 mem 数组缓存已解子问题
    ▼
记忆化搜索（自顶向下 + 缓存）   复杂度 O(n) / O(nm)
    │  转为迭代，从最小值推到目标
    ▼
动态规划（自底向上迭代）        复杂度 O(n) / O(nm)
    │  观察当前状态仅依赖有限前序状态
    ▼
滚动变量优化（空间降维）        空间从 O(n) → O(1)
```

### Dart 四阶段代码对比（以爬楼梯为例）

```dart
// ── 阶段一：暴力回溯 O(2^n) ──
int dfs(int i) {
  if (i == 1 || i == 2) return i;
  return dfs(i - 1) + dfs(i - 2);       // 大量重复计算
}

// ── 阶段二：记忆化搜索 O(n) 时间, O(n) 空间 ──
int dfsMem(int i, List<int> mem) {
  if (i == 1 || i == 2) return i;
  if (mem[i] != 0) return mem[i];       // 缓存命中
  mem[i] = dfsMem(i - 1, mem) + dfsMem(i - 2, mem);
  return mem[i];
}

// ── 阶段三：动态规划（自底向上）O(n) 时间, O(n) 空间 ──
int climbingStairsDP(int n) {
  if (n == 1 || n == 2) return n;
  List<int> dp = List.filled(n + 1, 0);
  dp[1] = 1; dp[2] = 2;
  for (int i = 3; i <= n; i++) dp[i] = dp[i - 1] + dp[i - 2];
  return dp[n];
}

// ── 阶段四：滚动变量优化 O(n) 时间, O(1) 空间 ──
int climbingStairsOptimized(int n) {
  if (n == 1 || n == 2) return n;
  int a = 1, b = 2;                     // a=dp[i-2], b=dp[i-1]
  for (int i = 3; i <= n; i++) {
    int c = a + b; a = b; b = c;
  }
  return b;
}
```

### 渐进路径适用条件

| 阶段 | 何时适用 | 何时跳回 |
|------|---------|---------|
| 回溯 | 任何新 DP 问题的起点，理清决策树 | — |
| 记忆化搜索 | 回溯中发现大量重叠子树 | 递归深度过大导致栈溢出时转迭代 |
| 动态规划 | 所有 DP 问题，编码量比记忆化多但无递归开销 | — |
| 滚动变量 | 状态转移仅依赖 dp[i-1]、dp[i-2] 等紧邻状态 | 依赖跨度大或需保留完整 dp 表回溯路径时不可用 |

---

## 七、范式横向对比表

| 维度 | 分治 | 回溯 | 动态规划 | 贪心 |
|------|------|------|---------|------|
| 子问题关系 | 独立 | 递进（共享部分前缀） | 重叠依赖 | 不分解 |
| 方向 | 自顶向下递归 | 自顶向下试探 | 自底向上递推 | 自左向右单次扫描 |
| 记忆化 | 不需要 | 可选（状态去重） | 核心必需 | 不需要 |
| 正确性保证 | 数学归纳 | 穷举保证 | 状态转移方程 | 需严格证明 |
| 典型复杂度 | O(n log n) | O(k^n) / O(n!) | O(n) ~ O(n²) | O(n) / O(n log n) |
| 是否求最优 | 不保证 | 不专攻 | 核心目标 | 条件苛刻 |
| Dart 常见模式 | 递归 + 合并 | 递归 + selected/used + undo | List.filled + 双层循环 | 排序 + 单次扫描 |

---

## Workflow：拿到新问题如何选范式

### Task Progress

- [ ] **Step 1: 建模。** 将问题抽象为状态 + 决策树，确定输入输出范围。
- [ ] **Step 2: 穷举判断。** 是否要穷举所有解（排列/组合）？→ 是 → **回溯 + 剪枝**。
- [ ] **Step 3: 独立性判断。** 问题可分解为独立子问题且无重叠？→ 是 → **分治**。
- [ ] **Step 4: 重叠子问题判断。** 递归树中是否有大量重复子树？→ 是 → **DP**（从记忆化搜索起步）。
- [ ] **Step 5: 贪心适用判断。** 每步局部最优能否保证全局最优？→ 是 → **贪心**；否 → **DP**。
- [ ] **Step 6: 兜底验证。** 不确定时，先写回溯暴力解，观察递归树 → 有重叠→DP；有剪枝空间→回溯优化；独立子问题→分治。

### 条件逻辑

- **如果需要穷举所有排列/组合** → 回溯（加剪枝优化）
- **如果子问题相互独立、无共享状态** → 分治
- **如果子问题有大量重叠计算** → 动态规划（自底向上或记忆化搜索）
- **如果贪心选择性质可证 + 最优子结构成立** → 贪心
- **如果无法判断范式** → 先写回溯暴力解，分析递归树再决定优化方向
- **如果 DP 空间过大** → 尝试滚动变量优化（如爬楼梯 O(n)→O(1)）

## Examples

### 分治示例：归并排序

```dart
List<int> mergeSort(List<int> nums) {
  if (nums.length <= 1) return nums;
  final mid = nums.length ~/ 2;
  final left = mergeSort(nums.sublist(0, mid));
  final right = mergeSort(nums.sublist(mid));
  return _merge(left, right);
}

List<int> _merge(List<int> a, List<int> b) {
  final res = <int>[];
  var i = 0, j = 0;
  while (i < a.length && j < b.length) {
    res.add(a[i] < b[j] ? a[i++] : b[j++]);
  }
  res.addAll(a.sublist(i));
  res.addAll(b.sublist(j));
  return res;
}
```

### DP 示例：爬楼梯（空间优化）

```dart
int climbingStairs(int n) {
  if (n == 1 || n == 2) return n;
  var a = 1, b = 2;
  for (var i = 3; i <= n; i++) {
    final c = a + b;
    a = b;
    b = c;
  }
  return b;  // O(n) 时间, O(1) 空间
}
```

### 贪心示例：分数背包

```dart
double fractionalKnapsack(List<int> w, List<int> v, int cap) {
  final items = List.generate(w.length, (i) => [v[i] / w[i], w[i], v[i]]);
  items.sort((a, b) => b[0].compareTo(a[0])); // 按单位价值降序
  double res = 0;
  for (final item in items) {
    if (item[1] <= cap) { res += item[2]; cap -= item[1]; }
    else { res += item[0] * cap; break; }
  }
  return res;
}
```
