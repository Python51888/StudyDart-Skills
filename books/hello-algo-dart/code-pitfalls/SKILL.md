---
name: dart-book-hello-algo-code-pitfalls
description: 识别并避免 Dart 算法实现中的 20+ 个常见陷阱，涵盖递归、排序、查找、DP、哈希表等核心领域
metadata:
  model: deepseek-v4-pro
  last_modified: 2026-05-14T10:00:00Z
  tags: [dart, core-libraries, fundamentals, collections-iterables]
  source_book: hello-algo-dart
---

# Dart 算法实现中的常见陷阱与反模式

基于《Hello 算法》Dart 版（靳宇栋，2026）。

## Contents
- [递归陷阱](#一递归陷阱)
- [二分查找陷阱](#二二分查找陷阱)
- [排序陷阱](#三排序陷阱)
- [哈希陷阱](#四哈希陷阱)
- [DP与贪心陷阱](#五dp与贪心陷阱)
- [数值陷阱](#六数值陷阱)
- [Workflow: 上线前检查清单](#workflow-算法实现上线前检查清单)
- [Examples](#examples)

---

## 一、递归陷阱

### 1.1 递归栈溢出

> **R**: "递归调用深度过大时，每次递归调用都会在调用栈上分配新的栈帧。当递归深度超过系统栈容量时，会引发 Stack Overflow 错误。"（《Hello 算法》第 2 章）

**I**: 递归每深入一层就占用一块栈内存，深度过大时直接爆栈。Dart 栈空间有限（通常几千层），递归解决深层问题不可靠。

**A1**: 递归计算斐波那契第 100 项——即便用了记忆化，第一次线性展开的深度也达 100 层；若不加记忆化，指数爆炸先于栈溢出到来。标准做法是改用迭代。

**A2**: 当数据规模未知或输入规模 > 1000 时；树/图遍历中子树可能退化为链表时；需要稳定可预测的内存消耗时。

**E**:

```dart
// ❌ 危险：深度不可控
int factorial(int n) {
  if (n <= 1) return 1;
  return n * factorial(n - 1);
}

// ✅ 安全：显式栈迭代
int factorialSafe(int n) {
  int result = 1;
  for (int i = 2; i <= n; i++) {
    result *= i;
  }
  return result;
}

// ✅ 树遍历显式栈（避免递归打爆调用栈）
void dfsIterative(Node root) {
  final stack = <Node>[root];
  while (stack.isNotEmpty) {
    final node = stack.removeLast();
    _process(node);
    if (node.right != null) stack.add(node.right!);
    if (node.left != null) stack.add(node.left!);
  }
}
```

**B**: 尾递归函数 Dart VM 不保证优化为循环；`Iterable.generate` 等惰性构造不替代栈安全。

---

### 1.2 尾递归不被 Dart 优化

> **R**: "尾递归是指递归调用是函数最后一个操作……部分编译器会自动优化尾递归为迭代形式，但 Dart 目前不保证这一优化。"

**I**: Dart VM 不会将尾递归转成循环，该爆栈还是爆栈。别指望 tail call optimization（TCO）。

**A1**: 尾递归求和 `sum(n, acc)` ——在 Scala/Elixir 中安全，在 Dart 中 n=10000 直接 StackOverflow。

**A2**: 任何看起来是尾递归的函数，尤其处理列表/流时。

**E**:

```dart
// ❌ 看似安全，实则会爆栈
int sumTail(int n, int acc) {
  if (n == 0) return acc;
  return sumTail(n - 1, acc + n); // Dart 不会优化此尾调用
}

// ✅ 老老实实写循环
int sumLoop(int n) {
  int acc = 0;
  for (int i = 1; i <= n; i++) {
    acc += i;
  }
  return acc;
}
```

**B**: 不依赖任何编译标志或 `--optimization-level` 来期望 TCO。

---

### 1.3 重叠子问题导致指数爆炸

> **R**: "暴力递归通常包含大量重复计算。以斐波那契数列为例，时间复杂从 O(2^n) 降至 O(n) 的关键在于引入记忆化搜索（Memoization）。"

**I**: 递归树中同一子问题被反复求解，计算量指数增长。这是从不可行到可行的关键一步。

**A1**: `fib(50)` 暴力递归需要约 2×10^10 次调用，实际无法在有限时间完成；加 `Map<int, int>` 缓存后只需 ~99 次调用。

**A2**: 当递归函数参数空间有限而反复出现同一组参数时；问题具备最优子结构但尚未使用 DP 时；`pub get` 前不想引入额外依赖但又需要效率时。

**E**:

```dart
// ❌ 指数爆炸
int fib(int n) {
  if (n <= 1) return n;
  return fib(n - 1) + fib(n - 2);
}

// ✅ 记忆化递归
int fibMemo(int n, [Map<int, int>? memo]) {
  memo ??= {};
  if (memo.containsKey(n)) return memo[n]!;
  if (n <= 1) return n;
  return memo[n] = fibMemo(n - 1, memo) + fibMemo(n - 2, memo);
}

// ✅ 自底向上 DP（空间 O(1)）
int fibDP(int n) {
  if (n <= 1) return n;
  int a = 0, b = 1;
  for (int i = 2; i <= n; i++) {
    final c = a + b;
    a = b;
    b = c;
  }
  return b;
}
```

**B**: 记忆化适合参数空间稀疏的情况；自底向上 DP 适合参数空间密集、需严格控制内存时。

---

### 1.4 BST 退化

> **R**: "二叉搜索树的各项操作时间复杂度与树高成正比。若按有序序列顺序插入节点，BST 退化为链表，查找、插入、删除操作退化为 O(n)。"（第 7 章）

**I**: 有序插入 BST → 全挂在右子树 → 变成链表。平衡是 BST 高效的前提。

**A1**: 依次插入 `[1,2,3,4,5,6]` 构建 BST，搜索 6 需要遍历整棵"树"；同一组数据用 AVL 树插入，树高保持 O(log n)。

**A2**: 数据源可能有序（从数据库 ORDER BY 拿到、从排序后的列表构建）；需要构建 BST 做范围查询。

**E**:

```dart
// ❌ 朴素 BST 插入 → 有序数据退化为链表
TreeNode? insert(TreeNode? root, int val) {
  if (root == null) return TreeNode(val);
  if (val < root.val) {
    root.left = insert(root.left, val);
  } else {
    root.right = insert(root.right, val);
  }
  return root;
}

// ✅ 使用 AVL 树——Dart 中可以用 SplayTreeSet 作为替代
import 'dart:collection';
final balancedSet = SplayTreeSet<int>();
for (final v in [1, 2, 3, 4, 5, 6]) {
  balancedSet.add(v);
}
// SplayTreeSet 自平衡，查找 O(log n)
```

**B**: `SplayTreeSet`/`SplayTreeMap` 基于伸展树，摊还 O(log n)，但不保证单次操作 O(log n)；需要严格 O(log n) 可用 `package:avl_tree`。

---

## 二、二分查找陷阱

### 2.1 区间定义混淆

> **R**: "二分查找的边界条件是最容易出错的环节。必须在实现前明确区间定义：双闭区间 `[i, j]` 还是左闭右开 `[i, j)`，并保持循环条件与边界更新一致。"（第 10 章）

**I**: `while (i <= j)` 配 `[i,j]`，`while (i < j)` 配 `[i,j)`。混用导致死循环或漏元素。

**A1**: 在 `[0, n)` 区间搜索，但用了 `i <= j` 条件 → 越界；在 `[0, n-1]` 区间却用 `j = mid` 更新 → 死循环。

**A2**: 每次写二分查找时；面试手写二分；代码 review 中看到二分查找。

**E**:

```dart
// 双闭区间 [i, j]
int binarySearchClosed(List<int> nums, int target) {
  int i = 0, j = nums.length - 1;
  while (i <= j) { // 区间为空时 i > j
    final mid = i + (j - i) ~/ 2;
    if (nums[mid] < target) {
      i = mid + 1;
    } else if (nums[mid] > target) {
      j = mid - 1; // 排除 mid
    } else {
      return mid;
    }
  }
  return -1;
}

// 左闭右开 [i, j)
int binarySearchHalfOpen(List<int> nums, int target) {
  int i = 0, j = nums.length;
  while (i < j) { // 区间为空时 i == j
    final mid = i + (j - i) ~/ 2;
    if (nums[mid] < target) {
      i = mid + 1;
    } else if (nums[mid] > target) {
      j = mid; // mid 不在搜索范围内
    } else {
      return mid;
    }
  }
  return -1;
}
```

**B**: 左闭右开更符合 Dart 的 `List.sublist` / `for (var i = 0; i < list.length; i++)` 惯例，推荐首选。

---

### 2.2 mid 计算溢出

> **R**: "在 i 和 j 都很大时，`(i + j) / 2` 可能超出整数范围导致溢出。安全的写法是 `i + (j - i) / 2`。"

**I**: `(i + j) ~/ 2` 在 i+j 超过 2^63-1 时溢出。Dart 整数是任意精度（big int），严格来说不会溢出——但 **Dart2JS 编译目标下 int 回退到 JS Number（53 位）**，i+j 超过 2^53 会丢失精度。

**A1**: Dart2JS 中搜索 2^53 级别的大数组，`(i+j)~/2` 导致 mid 计算错误，返回值偏差。

**A2**: 目标平台可能是 Web（Dart2JS）；处理超大索引数组；团队编码规范要求防御性写法。

**E**:

```dart
// ❌ Dart2JS 下可能精度丢失
final mid = (i + j) ~/ 2;

// ✅ 安全写法，JIT/AOT/JS 全平台正确
final mid = i + (j - i) ~/ 2;
```

**B**: Dart VM（JIT/AOT）int 无精度问题，但统一写成安全形式保证跨平台一致性。

---

### 2.3 忘记数据必须有序

> **R**: "二分查找的前提是数据已按关键字有序排列。在无序数组上使用二分查找，结果无意义。"

**I**: 二分查找依赖有序性。无序数据先排序（O(n log n)）再二分（O(log n)）——如果只查一次，不如线性扫描 O(n)。

**A1**: 拿到一个未排序的 List 直接传进二分查找，得到随机结果。

**A2**: 不确定输入是否有序时；数据源是第三方 API 或用户输入。

**E**:

```dart
int safeBinarySearch(List<int> nums, int target) {
  // 防御性检查：只在开发/测试阶段开启
  assert(() {
    for (int i = 1; i < nums.length; i++) {
      if (nums[i - 1] > nums[i]) {
        throw StateError('输入数组必须有序，索引 $i 处违反有序性');
      }
    }
    return true;
  }(), 'binary search requires sorted input');
  // ... 二分查找逻辑
}
```

**B**: assert 只在 debug 模式生效，release 模式会被移除。生产环境如需校验，自行实现显式检查。

---

## 三、排序陷阱

### 3.1 快速排序基准选择不良

> **R**: "快速排序的性能高度依赖于基准元素的选择。若每次选择最左或最右元素作为基准，在已有序或接近有序的数据上，快速排序退化为 O(n²)。"（第 11 章）

**I**: 选最左/最右元素当 pivot → 遇到有序数据直接 O(n²)。随机选或三数取中可避免。

**A1**: 对一个近乎有序的 10 万元素数组做快排（固定取最左元素为 pivot），递归深度 ~10^5，栈溢出或极慢；随机 pivot 使深度期望 O(log n)。

**A2**: 数据来源不可控（可能已局部有序）；生产环境排序；快速排序是唯一可行的 in-place O(n log n) 方案时。

**E**:

```dart
import 'dart:math';

final _rand = Random();

// ✅ 随机基准
int _partitionRandom(List<int> nums, int left, int right) {
  final pivotIdx = left + _rand.nextInt(right - left + 1);
  _swap(nums, left, pivotIdx); // 把随机基准换到最左边
  return _partition(nums, left, right);
}

// ✅ 三数取中
int _medianOfThree(List<int> nums, int left, int right) {
  final mid = left + (right - left) ~/ 2;
  // 取 left, mid, right 的中位数作为基准
  if (nums[left] > nums[mid]) _swap(nums, left, mid);
  if (nums[left] > nums[right]) _swap(nums, left, right);
  if (nums[mid] > nums[right]) _swap(nums, mid, right);
  _swap(nums, left, mid); // 将中位数换到最左
  return _partition(nums, left, right);
}

void _swap(List<int> nums, int i, int j) {
  final tmp = nums[i];
  nums[i] = nums[j];
  nums[j] = tmp;
}

// _partition 同标准 Lomuto 划分，此处省略
```

**B**: 随机 pivot 每次调用 `Random.nextInt` 有微小开销，三数取中在近乎有序数据上表现更好且无随机开销。工程实践选三数取中。

---

### 3.2 相等元素稳定性丢失

> **R**: "排序算法的稳定性指相等元素在排序后是否保持原始相对顺序。快速排序、堆排序不稳定；归并排序、插入排序稳定。Dart 的 `List.sort` 默认使用快速排序（不稳定）。"

**I**: Dart `sort()` 不保证稳定。需要稳定排序时，要么用稳定算法，要么把原始索引编码进比较器。

**A1**: 先按年龄排序再按姓名排序——若 sort 不稳定，第二次排序可能打乱第一次的年龄分组。

**A2**: 多级排序（先按 A 再按 B）；排序对象有主键/次键；UI 列表需要保持用户感知顺序。

**E**:

```dart
// ❌ 不稳定排序可能破坏已有顺序
items.sort((a, b) => a.age.compareTo(b.age));

// ✅ 方案一：使用归并排序（稳定）
List<T> mergeSort<T>(List<T> list, int Function(T, T) compare) {
  if (list.length <= 1) return list;
  final mid = list.length ~/ 2;
  final left = mergeSort(list.sublist(0, mid), compare);
  final right = mergeSort(list.sublist(mid), compare);
  return _merge(left, right, compare);
}

// ✅ 方案二：把原始索引编码进比较器（Schwartzian transform）
final sorted = items
    .asMap()
    .entries
    .toList()
  ..sort((a, b) {
    final cmp = a.value.age.compareTo(b.value.age);
    if (cmp != 0) return cmp;
    return a.key.compareTo(b.key); // 索引保序
  });
final result = sorted.map((e) => e.value).toList();
```

**B**: 归并排序需要 O(n) 额外空间；索引编码法在原 List 所有元素相等时不影响结果正确性。

---

## 四、哈希陷阱

### 4.1 哈希冲突退化

> **R**: "哈希冲突不可避免。当冲突严重时（如所有键映射到同一桶），哈希表操作退化为 O(n)。需要设计良好的哈希函数和冲突处理策略（链式地址、开放寻址）来保证均摊 O(1)。"（第 6 章）

**I**: 所有 key 哈希到同一个桶 → 退化为链表遍历。常见于恶意构造的输入（哈希碰撞攻击）或糟糕的 `hashCode` 实现。

**A1**: 自定义类覆盖了 `hashCode` 但始终返回 `0`，存入 10 万元素后 `map[key]` 退化为 O(n) 线性扫描。

**A2**: 自定义对象的 `hashCode` 实现；处理来自不可信源的 key；高频 HashMap 操作。

**E**:

```dart
// ❌ 糟糕的 hashCode：所有对象落入同一桶
class BadKey {
  final String id;
  const BadKey(this.id);

  @override
  int get hashCode => 0; // 全部冲突！

  @override
  bool operator ==(Object other) =>
      other is BadKey && other.id == id;
}

// ✅ 使用 Object.hash() 自动生成良好分布的 hashCode
class GoodKey {
  final String id;
  final int version;
  const GoodKey(this.id, this.version);

  @override
  int get hashCode => Object.hash(id, version);

  @override
  bool operator ==(Object other) =>
      other is GoodKey && other.id == id && other.version == version;
}
```

**B**: `Object.hash()` 从 Dart 2.14 开始可用。确保 `==` 和 `hashCode` 一致：`a == b` → `a.hashCode == b.hashCode`。

---

### 4.2 TOMBSTONE 死标签累积

> **R**: "开放寻址法的删除操作不能简单将桶置空，否则会切断探测链。通常使用 TOMBSTONE 标记已删除元素。但大量删除后，TOMBSTONE 占比过高会导致查找性能下降。"

**I**: 开放寻址哈希表删除时插"墓碑"占位，防止探测链断裂。墓碑太多 → 表里空位多但探测路径长 → 性能退化。

**A1**: 开放寻址哈希表经历大量增删交替操作，load factor 只有 0.3 但查找仍需探测 5-8 步。

**A2**: 自己实现哈希表；增删频繁的场景（如 LRU 淘汰后重建）；理解 Dart `HashMap` 内部行为。

**E**:

```dart
// 开放寻址哈希表删除示意
class OpenAddressingHashMap<K, V> {
  static final _TOMBSTONE = Object();

  V? remove(K key) {
    final idx = _findIndex(key);
    if (idx == -1) return null;
    final old = _values[idx] as V;
    _keys[idx] = _TOMBSTONE; // 墓碑占位，不设 null
    _values[idx] = null;
    _size--;
    // ⚠️ 墓碑累积：当墓碑比例 > 50% 时重新哈希
    if (_tombstoneCount > _capacity ~/ 2) {
      _rehash();
    }
    return old;
  }
}
```

**B**: Dart 标准库 `HashMap` 使用链式地址法，无需关心墓碑问题；此陷阱仅针对自己实现的开放寻址表。

---

## 五、动态规划与贪心陷阱

### 5.1 贪心不一定全局最优

> **R**: "贪心算法在每一步选择当前看起来最优的选项，但这种局部最优并不必然导向全局最优解。最典型的是零钱兑换问题：当硬币面额为 `[1,3,4]`、目标金额为 6 时，贪心策略选择 4+1+1 共 3 枚，而最优解是 3+3 共 2 枚。"（第 15 章）

**I**: 贪心是赌当前最优=全局最优。硬币面额不满足贪心选择性质时赌输。

**A1**: 面额 `[1,3,4]` 兑 6 元——贪心输出 3 枚，DP 输出 2 枚。

**A2**: 每次想用贪心时，先证明"贪心选择性质 + 最优子结构"；否则用 DP。

**E**:

```dart
// ❌ 贪心策略：对 [1,3,4] 目标 6 给出错误结果 3
int coinChangeGreedy(List<int> coins, int amount) {
  final sorted = coins..sort((a, b) => b.compareTo(a)); // 降序
  int count = 0, remaining = amount;
  for (final coin in sorted) {
    count += remaining ~/ coin;
    remaining %= coin;
  }
  return remaining == 0 ? count : -1;
}

// ✅ DP 保证全局最优
int coinChangeDP(List<int> coins, int amount) {
  final dp = List.filled(amount + 1, amount + 1);
  dp[0] = 0;
  for (int i = 1; i <= amount; i++) {
    for (final coin in coins) {
      if (coin <= i) {
        dp[i] = dp[i] < dp[i - coin] + 1 ? dp[i] : dp[i - coin] + 1;
      }
    }
  }
  return dp[amount] > amount ? -1 : dp[amount];
}
```

**B**: 部分硬币系统（如人民币 `[1,2,5,10]`）贪心确实最优，但这需要数学证明，不能假定。

---

### 5.2 背包遍历顺序错误

> **R**: "0-1 背包问题中，若使用正序遍历容量会导致物品被重复选用（即退化为完全背包）。0-1 背包的容量维度必须倒序遍历，而完全背包必须正序遍历。"（第 14 章）

**I**: 0-1 背包正序遍历 → 同一件物品可能被放多次；完全背包倒序遍历 → 物品不能重复使用。遍历方向搞反，结果完全错误。

**A1**: 0-1 背包 `dp[j] = max(dp[j], dp[j-w]+v)` 正序遍历 j → 物品 i 被重复计入（因为 `dp[j-w]` 可能刚被物品 i 更新过）。

**A2**: 写任何背包变种（0-1、完全、多重）；面试中手写 DP。

**E**:

```dart
// 0-1 背包：每个物品最多选一次
int knapsack01(List<int> weights, List<int> values, int capacity) {
  final dp = List.filled(capacity + 1, 0);
  for (int i = 0; i < weights.length; i++) {
    // ✅ 倒序遍历：避免重复使用物品 i
    for (int j = capacity; j >= weights[i]; j--) {
      final take = dp[j - weights[i]] + values[i];
      if (take > dp[j]) dp[j] = take;
    }
  }
  return dp[capacity];
}

// 完全背包：每个物品可选无限次
int knapsackUnbounded(List<int> weights, List<int> values, int capacity) {
  final dp = List.filled(capacity + 1, 0);
  for (int i = 0; i < weights.length; i++) {
    // ✅ 正序遍历：允许重复使用物品 i
    for (int j = weights[i]; j <= capacity; j++) {
      final take = dp[j - weights[i]] + values[i];
      if (take > dp[j]) dp[j] = take;
    }
  }
  return dp[capacity];
}
```

**B**: 二维 DP 数组版本不存在遍历方向陷阱（`dp[i][j]` 隔离了物品维度），但空间占用 O(n×cap) vs 一维 O(cap)。

---

## 六、数值陷阱

### 6.1 浮点精度问题

> **R**: "浮点数遵循 IEEE 754 标准，无法精确表示所有实数。在算法中直接使用 `==` 比较浮点数可能导致逻辑错误。应当使用差值比较法。"（第 3 章）

**I**: `0.1 + 0.2 == 0.3` 为 `false`。浮点运算有舍入误差，算法中用 `==` 做浮点等值判断是 bug 来源。

**A1**: 用 `==` 比较两个"相等"的 `double` 结果，条件分支走到错误路径；二分查找中 `double` mid 比较导致无限循环。

**A2**: 任何涉及浮点比较的地方——几何计算、物理模拟、金融计算、ML 梯度检查。

**E**:

```dart
import 'dart:math';

// ❌ 直接等值比较——不可靠
bool isZero(double x) => x == 0.0;

// ✅ 差值比较
const eps = 1e-9;
bool isZeroSafe(double x) => x.abs() < eps;
bool approxEqual(double a, double b) => (a - b).abs() < eps;

// 二分查找中的浮点安全写法
int binarySearchFloats(List<double> nums, double target) {
  int i = 0, j = nums.length - 1;
  while (i <= j) {
    final mid = i + (j - i) ~/ 2;
    if (nums[mid] < target - eps) {
      i = mid + 1;
    } else if (nums[mid] > target + eps) {
      j = mid - 1;
    } else {
      return mid; // 在 eps 范围内视为相等
    }
  }
  return -1;
}
```

**B**: `eps = 1e-9` 适合大多数场景；金融计算请用 `package:decimal` 定点数而非浮点；科学计算中 eps 应根据数据量级动态计算。

---

## 七、速查表

| 陷阱 | 症状 | 快速修复 |
|------|------|----------|
| 递归爆栈 | StackOverflow | 改显式栈迭代 |
| 尾递归 | 大 n 时爆栈 | 改循环 |
| 重叠子问题 | 运算时间指数增长 | 加 Map 缓存 / 改 DP |
| BST 退化 | 查找变慢 | 用 AVL / SplayTreeSet |
| 二分区间混乱 | 死循环/漏元素 | 统一 `[i,j)` + `i<j` |
| mid 溢出（JS） | 查找结果错误 | `i + (j-i)~/2` |
| 无序二分 | 结果随机 | 先排序或线性扫描 |
| 快排选基准 | 有序数据 O(n²) | 三数取中 / 随机 pivot |
| 排序不稳定 | 相等元素乱序 | 归并排序 / 编码索引 |
| hashCode=0 | HashMap O(n) | `Object.hash(...)` |
| 墓碑累积 | 探测路径变长 | 定期 rehash |
| 贪心非最优 | 硬币兑换多给币 | 改用 DP |
| 背包遍历反 | 物品重复/缺失 | 0-1 倒序，完全正序 |
| 浮点 == | 条件分支错误 | `abs(a-b) < eps` |

---

## Workflow: 算法实现上线前检查清单

### Task Progress

- [ ] **Step 1: 递归深度检查。** 数据规模 > 1000？改迭代或显式栈。
- [ ] **Step 2: 重复计算检查。** 子问题是否反复出现？加记忆化或改 DP。
- [ ] **Step 3: 数据结构假设验证。** BST 有序插入？用自平衡树。
- [ ] **Step 4: 二分前提确认。** 数据是否有序？不放心加 assert。
- [ ] **Step 5: 区间语义。** `[i,j)` 还是 `[i,j]`？写注释，保持一致。
- [ ] **Step 6: 基准选择。** 快排 pivot 是否固定？随机或三数取中。
- [ ] **Step 7: 排序稳定性。** 相等元素顺序是否重要？选稳定排序。
- [ ] **Step 8: hashCode 质量。** 自定义类 hashCode 是否均匀分布？
- [ ] **Step 9: 贪心证明。** 是否已验证最优子结构？
- [ ] **Step 10: DP 遍历方向。** 0-1 倒序，完全正序。
- [ ] **Step 11: 浮点比较。** 是否用了 `==`？改为 `(a-b).abs() < eps`。
- [ ] **Step 12: Feedback Loop。** 满足全部检查项，算法实现才具备上线质量。

### 条件逻辑

- **如果遇到栈溢出** → 改为迭代或显式栈实现
- **如果性能不达标** → 检查是否存在隐藏的 O(n²) 操作
- **如果结果不稳定** → 检查排序算法是否稳定，或编码时加入稳定化处理

在执行任何算法实现前，按此清单逐项检查：

1. **递归深度** —— 数据规模 > 1000？改迭代或显式栈。
2. **重复计算** —— 子问题是否反复出现？加记忆化或改 DP。
3. **数据结构假设** —— BST 有序插入？用自平衡树。
4. **二分前提** —— 数据是否有序？不放心加 assert。
5. **区间语义** —— `[i,j)` 还是 `[i,j]`？写注释，保持一致性。
6. **基准选择** —— 快排 pivot 是否固定？随机或三数取中。
7. **排序稳定性** —— 相等元素顺序是否重要？选稳定排序。
8. **hashCode 质量** —— 自定义类 `hashCode` 是否声明为 const 且分布均匀？
9. **贪心证明** —— 是否已验证贪心选择性质和最优子结构？
10. **DP 遍历方向** —— 0-1 背包容量倒序，完全背包容量正序。
11. **浮点比较** —— 是否用了 `==`？改为 `(a-b).abs() < eps`。

满足全部检查项，算法实现才具备上线质量。

## Examples

### ❌ 错误：未检查有序直接二分

```dart
final unsorted = [3, 1, 4, 1, 5];
final idx = binarySearch(unsorted, 3); // ❌ 结果不可预测
```

### ✅ 正确：二分前确保有序

```dart
final data = [3, 1, 4, 1, 5];
data.sort();                              // ✓ 先排序
final idx = binarySearch(data, 3);        // ✓ 结果可靠
```

### ❌ 错误：0-1 背包正序遍历导致物品复用

```dart
for (var i = 0; i < n; i++)
for (var c = 0; c <= cap; c++)  // ❌ 正序：同一物品可多次计算
  if (c >= w[i]) dp[c] = max(dp[c], dp[c - w[i]] + v[i]);
```

### ✅ 正确：0-1 背包倒序遍历

```dart
for (var i = 0; i < n; i++)
for (var c = cap; c >= w[i]; c--)  // ✓ 倒序：每件物品只用一次
  dp[c] = max(dp[c], dp[c - w[i]] + v[i]);
```

### ❌ 错误：浮点直接用 == 比较

```dart
if (a + b == 1.0) { /* ❌ 精度误差导致误判 */ }
```

### ✅ 正确：浮点安全比较

```dart
const eps = 1e-9;
if ((a + b - 1.0).abs() < eps) { /* ✓ 安全比较 */ }
```
