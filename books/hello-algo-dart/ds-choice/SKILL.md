---
name: dart-book-hello-algo-ds-choice
description: 根据数据特性选择最优数据结构，掌握数组/链表/栈/队列/哈希表/树/堆/图的选择决策框架
metadata:
  model: deepseek-v4-pro
  last_modified: 2026-05-14T10:00:00Z
  tags: [dart, core-libraries, collections-iterables]
  source_book: hello-algo-dart
---
# 数据结构选择决策

> 来源：靳宇栋《Hello 算法》Dart 语言版（Release 1.3.0，2026），第 4-9 章

## Contents

- [RIA++ 核心分析](#ria-核心分析)
- [数据结构选择决策矩阵](#数据结构选择决策矩阵)
- [Workflow: 选择合适的数据结构](#workflow-选择合适的数据结构)
- [各结构关键操作复杂度速查](#各结构关键操作复杂度速查)
- [Examples (Dart 代码示例)](#examples-dart-代码示例)
- [Dart List](#dart-list列表)

## RIA++ 核心分析

### R (Reading) —— 书中原文

> 数组和链表是两种基本的数据结构，分别代表数据在计算机内存中的两种存储方式：连续空间存储和分散空间存储。两者的特点呈现出互补的特性。所有数据结构都是基于数组、链表或二者的组合实现的。

— 《Hello 算法》4.5 小结

### I (Interpretation) —— 方法论提炼

数据结构选择的本质是在**时间效率**与**空间效率**之间做权衡。连续存储（数组）以空间换时间——内存紧凑、缓存友好、随机访问 O(1)，但增删 O(n)。分散存储（链表）以时间换空间——增删 O(1)、灵活扩容，但访问 O(n)、指针开销大。所有高级数据结构都是这两种基础结构的选择或组合：哈希表是数组+链表；树是链表节点的层级组织；堆是数组实现的完全二叉树；图则需要在邻接矩阵（空间换时间）与邻接表（时间换空间）之间二选一。

**决策核心公式**：选择 = 根据访问模式（随机/顺序/两端） × 操作频率（查/增/删哪个多） × 空间约束（内存是否紧张） × 有序性要求。

### A1 (Past Application) —— 书中案例

| 场景 | 选择 | 原因 |
|------|------|------|
| 算法题中的栈 | 基于数组实现 | 缓存命中率高，操作效率优 |
| 数据量大、动态性高的栈 | 基于链表实现 | 避免数组扩容开销，分散存储 |
| 图的稠密图场景（电路网络） | 邻接矩阵 | 边数接近 n²，需要快速判断连通性 |
| 图的稀疏图场景（社交网络） | 邻接表 | 节省 O(n²) 空间为 O(n+m) |
| 软件的"撤销"功能 | 双向队列替代栈 | 需要支持从栈底删除超限历史 |
| Top-K 热搜排行 | 小顶堆 | O(1) 取堆顶 + O(log k) 维护 |

### A2 (Future Trigger) —— 何时需要

你在以下任一场景中遇到选择困难时，加载本 skill：

- 需要一个集合存储数据，但不确定用 `List`、`Set` 还是 `Map`
- 需要频繁在头部/尾部插入删除，考虑是否该用 `Queue`
- 需要按键查找且希望 O(1)，但担心内存占用
- 需要维护数据的排序状态，在 BST 和排序数组之间犹豫
- 需要找出"最大/最小的 K 个"元素
- 需要建模一个关系网络（社交、地图、依赖）
- 面试算法题中对数据结构选型没有把握

### E (Execution) —— 可执行步骤

1. **画出访问模式**：你的代码主要做什么操作？读取（索引/按键/遍历）、写入（追加/插入/删除）各占多少比例？
2. **查阅决策矩阵**：对照下方决策矩阵，找到匹配你操作模式的行
3. **确认空间约束**：内存是否紧张？数据量是否可能大幅增长？
4. **选择实现方式**：确定数据结构后，选择基于数组还是链表的实现（参考复杂度速查表）
5. **编写并测试**：用 Dart 原生集合类实现，运行验证性能

### B (Boundary) —— 不适用场景

- **纯函数式计算或不可变数据**：本 skill 关注 Dart 原生可变集合；如需不可变集合，应使用 `built_collection` 等包
- **并发环境下的线程安全集合**：Dart Isolate 隔离模型通常不需要；若跨 Isolate 共享，需用 `SendPort`/`ReceivePort` 传递副本
- **数据库级别的数据管理**：本 skill 不涉及 SQLite、Hive、Drift 等持久化存储的选择
- **极端性能优化场景**：复杂度分析提供趋势判断，但常数因子在极端场景下可能逆转结论——需实测验证

---

## 数据结构选择决策矩阵

> 从四个维度评估每种数据结构：访问速度、增删效率、空间开销、有序性。按你的操作模式匹配最佳选择。

| 数据结构 | 随机访问 | 增删（已知位置） | 空间效率 | 有序性 | 典型 Dart 类型 |
|----------|---------|----------------|---------|-------|---------------|
| 数组 | **O(1)** | O(n) | 高（无额外开销） | 有序/无序 | `List<T>` |
| 链表 | O(n) | **O(1)** | 低（指针开销） | 无序 | 自定义 `ListNode` |
| 栈 | O(1)(顶) | O(1)(顶) | 取决于实现 | LIFO | `List<T>`（当栈用） |
| 队列 | O(1)(两端) | O(1)(两端) | 取决于实现 | FIFO | `Queue<T>` |
| 哈希表 | **O(1)*** | **O(1)*** | 低（空位浪费） | **无序** | `Map<K,V>` / `Set<T>` |
| 二叉搜索树 | O(log n)* | O(log n)* | 中（指针开销） | **有序** | 自定义 `TreeNode` |
| 堆（优先队列） | **O(1)**(顶) | O(log n) | 高（数组实现） | 部分有序 | 自定义 `MinHeap` |
| 图 | — | O(1)/O(n) | O(n²) 或 O(n+m) | — | `Map<V, List<V>>` |

> \* 哈希表为平均情况，最坏 O(n)；BST 平均 O(log n)，退化时 O(n)

### 按需求快速定位

| 你的需求 | 首选结构 | 备选方案 |
|----------|---------|---------|
| "我需要快速按索引取值" | List | — |
| "我需要频繁在中间增删" | 链表 | Queue（仅两端） |
| "我需要先进先出的处理顺序" | Queue | List（手动管理索引） |
| "我需要后进先出的处理顺序" | List（栈） | Queue（双向） |
| "我需要按 Key 快速查找" | Map | BST（需有序时） |
| "我需要数据不重复" | Set | Map<K, bool> |
| "我需要数据始终保持有序" | BST / SplayTreeMap | 排序 List + 二分查找 |
| "我需要实时获取最大/最小值" | 堆 | 每次排序（不推荐） |
| "我需要建模节点间关系" | 图（邻接表） | 邻接矩阵（稠密图） |

---

## Workflow: 选择合适的数据结构

### Task Progress

- [ ] 列出你的核心操作（查找、插入、删除、遍历）及其频率
- [ ] 判断是否有顺序要求（FIFO / LIFO / 排序 / 无序）
- [ ] 判断是否需要唯一性约束（去重）
- [ ] 判断是否需要 Key-Value 映射
- [ ] 估算数据规模：＜1000 → 低成本结构即可；＞10^6 → 优先 O(1) / O(log n)
- [ ] 确认内存限制：嵌入式/移动端 → 优先数组实现
- [ ] 对照决策矩阵选择数据结构
- [ ] 选择具体实现变体（基于数组 vs 基于链表）
- [ ] 在 Dart 中用原生类型或自定义类实现
- [ ] 编写基准测试验证性能假设

### 条件逻辑

```
你主要的操作模式是什么？
├─ 索引访问 + 尾部追加
│   → List<T>（Dart 原生）
│
├─ 头部 + 尾部插入/删除
│   → Queue<T>（dart:collection）
│
├─ Key → Value 查找（无需排序）
│   → Map<K,V> / HashMap<K,V>
│   └─ 数据量大 + 内存敏感？→ 链式哈希 vs 开放寻址
│
├─ Key → Value 查找（需要排序遍历）
│   → SplayTreeMap<K,V>（dart:collection）
│
├─ 只要值，不重复（去重）
│   → Set<T> / HashSet<T>
│
├─ 经常取最大/最小 K 个
│   → 自定义堆（用 List 实现）
│
├─ 建模网络/地图/依赖关系
│   ├─ 边数 < 顶点数²/10（稀疏）→ Map<V, List<V>>（邻接表）
│   └─ 边数接近顶点数²（稠密）→ List<List<int>>（邻接矩阵）
│
└─ 所有以上需求的组合
    → 分层设计：外层用 Map 索引，内层用 List 存储
```

### Decision Tree

```
需要随机访问（按索引）？
├─ YES → 需要增删在中间？
│   ├─ YES → 数据量如何？
│   │   ├─ < 1000 → List（O(n) 可接受）
│   │   └─ > 10^6 → 链表 + 辅助索引结构
│   └─ NO  → List<T>
│
└─ NO  → 需要按 Key 查找？
    ├─ YES → 需要有序遍历？
    │   ├─ YES → SplayTreeMap / 自定义 BST
    │   └─ NO  → Map / HashMap
    │
    └─ NO  → 需要特定顺序处理？
        ├─ LIFO → List 当做栈
        ├─ FIFO → Queue
        ├─ 最值优先 → 堆
        └─ 无所谓   → 需要去重？
            ├─ YES → Set
            └─ NO  → List（通用）
```

---

## 各结构关键操作复杂度速查

| 操作 | List (数组) | 链表 | Queue | Map (哈希) | BST (平衡) | 堆 |
|------|------------|------|-------|-----------|-----------|----|
| 访问 | O(1) | O(n) | O(1)(两端) | O(1)* | O(log n) | O(1)(顶) |
| 搜索 | O(n) | O(n) | O(n) | O(1)* | O(log n) | O(n) |
| 插入 | O(n) | O(1) | O(1) | O(1)* | O(log n) | O(log n) |
| 删除 | O(n) | O(1) | O(1) | O(1)* | O(log n) | O(log n) |
| 遍历 | O(n) | O(n) | O(n) | O(n) | O(n) | O(n) |
| 空间 | O(n) | O(n) | O(n) | O(n) | O(n) | O(n) |

> \* 哈希表为平均复杂度；最坏（大量冲突）退化为 O(n)。
> BST 未平衡时最坏退化为 O(n)。

### 图：邻接表 vs 邻接矩阵

| 操作 | 邻接表 | 邻接矩阵 |
|------|--------|---------|
| 空间 | O(\|V\|+\|E\|) | O(\|V\|²) |
| 添加边 | O(1) | O(1) |
| 删除边 | O(\|E\|) | O(1) |
| 添加顶点 | O(1) | O(\|V\|²) |
| 删除顶点 | O(\|V\|+\|E\|) | O(\|V\|²) |
| 查询边 | O(\|V\|) | O(1) |

选择规则：边数 > \|V\|²/10 → 邻接矩阵；边数 < \|V\|²/10 → 邻接表。

---

## Examples (Dart 代码示例)

### 1. 数组（List）—— 随机访问王者

```dart
void demoList() {
  // 初始化
  List<int> nums = [1, 3, 2, 5, 4];

  // 随机访问 O(1)
  int item = nums[2];       // 2

  // 尾部追加 O(1)
  nums.add(6);              // [1, 3, 2, 5, 4, 6]

  // 中间插入 O(n) —— 后续元素后移
  nums.insert(2, 10);       // [1, 3, 10, 2, 5, 4, 6]

  // 删除 O(n) —— 后续元素前移
  nums.removeAt(2);         // [1, 3, 2, 5, 4, 6]

  // 遍历 O(n)
  for (var n in nums) { print(n); }
}
```

### Dart List（列表）— 动态数组封装

> **R**: "在 Dart 中，List 是一个动态数组，底层基于数组实现，自动管理扩容。"（《Hello 算法》第 4 章）

**I**: Dart 的 `List` 本质上是一个会自动扩容的数组。它提供了随机访问 O(1) 和尾部增删 O(1)，但中间插入删除为 O(n)。扩容时会分配新内存并拷贝，触发时 O(n)。

**A1**: 书中所有排序算法均以 `List<int>` 作为输入，利用其随机访问特性实现高效排序。

**A2**: 需要随机访问且增删集中在尾部时（如日志收集、打点记录），`List` 是首选。

**E**:
1. 确认主要操作是随机读取还是频繁增删
2. 主操作为随机读取且增删在尾部 → `List`
3. 中间频繁插入删除 → 考虑 `Queue` 或自定义链表

**B**: 中间大量插入删除操作 O(n)，此时应改用 `Queue` 或链表。

```dart
// Dart List 示例
final nums = <int>[];
nums.add(1);        // 尾部添加 O(1) 均摊
nums.addAll([2,3]); // 批量添加
nums.insert(1, 99); // 中间插入 O(n)
nums.removeAt(0);   // 删除 O(n)
nums[2];            // 随机访问 O(1)

// 固定长度 List
final fixed = List.filled(5, 0); // 长度不可变
```

### 2. 链表 —— 频繁增删的首选

```dart
class ListNode {
  int val;
  ListNode? next;
  ListNode(this.val, [this.next]);
}

void demoLinkedList() {
  // 构建链表: 1 → 3 → 2
  ListNode n0 = ListNode(1);
  ListNode n1 = ListNode(3);
  ListNode n2 = ListNode(2);
  n0.next = n1;
  n1.next = n2;

  // 在 n0 后插入节点 O(1)
  void insertAfter(ListNode target, ListNode newNode) {
    newNode.next = target.next;
    target.next = newNode;
  }
  insertAfter(n0, ListNode(4));  // 1 → 4 → 3 → 2

  // 删除 n0 的后继节点 O(1)
  void removeAfter(ListNode target) {
    if (target.next == null) return;
    target.next = target.next?.next;
  }
  removeAfter(n0);  // 1 → 3 → 2

  // 查找 O(n)
  int indexOf(ListNode? head, int target) {
    int index = 0;
    while (head != null) {
      if (head.val == target) return index;
      head = head.next;
      index++;
    }
    return -1;
  }
}
```

### 3. 栈 —— LIFO 后进先出

```dart
import 'dart:collection';

void demoStack() {
  // Dart List 天然支持栈操作
  List<int> stack = [];

  // 入栈 O(1)
  stack.add(1);
  stack.add(3);
  stack.add(2);

  // 访问栈顶 O(1)
  int top = stack.last;     // 2

  // 出栈 O(1)
  int popped = stack.removeLast(); // 2
  // stack 现在是 [1, 3]

  // 判空
  bool empty = stack.isEmpty;
}

// 栈的典型应用：括号匹配
bool isValid(String s) {
  List<String> stack = [];
  Map<String, String> pairs = {')': '(', ']': '[', '}': '{'};
  for (var ch in s.split('')) {
    if (pairs.containsValue(ch)) {
      stack.add(ch);
    } else if (pairs.containsKey(ch)) {
      if (stack.isEmpty || stack.removeLast() != pairs[ch]) return false;
    }
  }
  return stack.isEmpty;
}
```

### 4. 队列 —— FIFO 先进先出

```dart
import 'dart:collection';

void demoQueue() {
  // Queue 提供 O(1) 的两端操作
  Queue<int> queue = Queue<int>();

  // 入队（队尾） O(1)
  queue.addLast(1);
  queue.addLast(3);
  queue.addLast(2);

  // 访问队首 O(1)
  int front = queue.first;  // 1

  // 出队（队首） O(1)
  int dequeued = queue.removeFirst(); // 1
  // queue 现在是 [3, 2]

  int size = queue.length;  // 2
}

// 队列的典型应用：BFS 层序遍历
List<int> levelOrder(Map<int, List<int>> graph, int start) {
  List<int> result = [];
  Set<int> visited = {start};
  Queue<int> queue = Queue<int>()..add(start);

  while (queue.isNotEmpty) {
    int node = queue.removeFirst();
    result.add(node);
    for (var neighbor in (graph[node] ?? [])) {
      if (!visited.contains(neighbor)) {
        visited.add(neighbor);
        queue.addLast(neighbor);
      }
    }
  }
  return result;
}
```

### 5. 哈希表 —— O(1) 键值查找

```dart
void demoHashMap() {
  // Dart Map 即哈希表
  Map<String, int> map = {};

  // 插入/更新 O(1)*
  map['apple'] = 5;
  map['banana'] = 3;
  map['cherry'] = 8;

  // 查找 O(1)*
  int? price = map['apple'];    // 5
  bool has = map.containsKey('grape'); // false

  // 删除 O(1)*
  map.remove('banana');

  // 遍历 O(n) —— 无序！
  map.forEach((key, value) => print('$key: $value'));

  // 去重利器
  List<int> nums = [1, 2, 2, 3, 3, 3];
  Set<int> unique = nums.toSet(); // {1, 2, 3}

  // 计数统计
  Map<int, int> freq = {};
  for (var n in nums) {
    freq[n] = (freq[n] ?? 0) + 1;
  } // {1: 1, 2: 2, 3: 3}
}
```

### 6. 堆（优先队列）—— O(1) 取最值

```dart
// 小顶堆 —— 用于 Top-K 问题
class MinHeap {
  final List<int> _heap = [];

  int peek() => _heap[0];
  int size() => _heap.length;
  bool isEmpty() => _heap.isEmpty;

  void push(int val) {
    _heap.add(val);
    _siftUp(size() - 1);
  }

  int pop() {
    int root = _heap[0];
    _heap[0] = _heap.removeLast();
    if (_heap.isNotEmpty) _siftDown(0);
    return root;
  }

  void _siftUp(int i) {
    int p = (i - 1) ~/ 2;
    while (p >= 0 && _heap[p] > _heap[i]) {
      _swap(p, i);
      i = p;
      p = (i - 1) ~/ 2;
    }
  }

  void _siftDown(int i) {
    while (true) {
      int l = 2 * i + 1, r = 2 * i + 2, min = i;
      if (l < _heap.length && _heap[l] < _heap[min]) min = l;
      if (r < _heap.length && _heap[r] < _heap[min]) min = r;
      if (min == i) break;
      _swap(i, min);
      i = min;
    }
  }

  void _swap(int i, int j) {
    int tmp = _heap[i]; _heap[i] = _heap[j]; _heap[j] = tmp;
  }
}

// Top-K 问题：从海量数据找最大的 K 个元素
List<int> topKLargest(List<int> nums, int k) {
  MinHeap heap = MinHeap();
  // 先用前 K 个元素建堆
  for (int i = 0; i < k; i++) heap.push(nums[i]);
  // 维护小顶堆：大于堆顶则替换
  for (int i = k; i < nums.length; i++) {
    if (nums[i] > heap.peek()) {
      heap.pop();
      heap.push(nums[i]);
    }
  }
  // 导出结果
  List<int> result = [];
  while (!heap.isEmpty()) result.add(heap.pop());
  return result; // 升序输出
}

void demoTopK() {
  List<int> data = [3, 1, 5, 12, 2, 11, 7, 8, 9, 4];
  List<int> top3 = topKLargest(data, 3);
  print(top3); // [9, 11, 12]
}
```

### 7. 图 —— 关系网络建模

```dart
// 邻接表实现（适用于稀疏图）
class GraphAdjList {
  final Map<int, List<int>> adjList = {};

  void addVertex(int v) => adjList.putIfAbsent(v, () => []);

  void addEdge(int a, int b) {
    addVertex(a);
    addVertex(b);
    adjList[a]!.add(b);
    // 无向图需双向添加
    // adjList[b]!.add(a);
  }

  void removeEdge(int a, int b) {
    adjList[a]?.remove(b);
  }

  void removeVertex(int v) {
    adjList.remove(v);
    for (var list in adjList.values) list.remove(v);
  }

  bool hasEdge(int a, int b) => adjList[a]?.contains(b) ?? false;
}

// 邻接矩阵实现（适用于稠密图）
class GraphAdjMat {
  List<int> vertices = [];
  List<List<int>> adjMat = [];

  void addVertex(int v) {
    int n = vertices.length;
    vertices.add(v);
    // 扩充矩阵
    for (var row in adjMat) row.add(0);
    adjMat.add(List.filled(n + 1, 0));
  }

  void addEdge(int i, int j) => adjMat[i][j] = 1;
  void removeEdge(int i, int j) => adjMat[i][j] = 0;
  bool hasEdge(int i, int j) => adjMat[i][j] == 1;
}

void demoGraph() {
  // 社交网络示例
  GraphAdjList social = GraphAdjList();
  social.addEdge(1, 2);
  social.addEdge(1, 3);
  social.addEdge(2, 4);

  print(social.adjList); // {1: [2, 3], 2: [4], 3: [], 4: []}
}
```

### 8. 综合示例：从需求到数据结构选择

```dart
void main() {
  // 场景：需要维护一个排行榜，支持：
  // 1) 快速获取前 10 名
  // 2) 按用户名查找排名
  // 3) 更新分数

  // 选择组合：
  // - 堆 → 维护 Top-10
  // - Map → 按用户名 O(1) 查找

  Map<String, int> scores = {};
  MinHeap topK = MinHeap();
  int k = 3; // 演示用 3

  void updateScore(String user, int newScore) {
    int oldScore = scores[user] ?? 0;
    scores[user] = newScore;

    // 如果进入 Top-K 则更新堆
    if (topK.size() < k || newScore > topK.peek()) {
      // 简化处理：重建（生产环境用更精细的维护策略）
      topK = MinHeap();
      List<int> sorted = scores.values.toList()..sort((a, b) => b.compareTo(a));
      for (int i = 0; i < k && i < sorted.length; i++) topK.push(sorted[i]);
    }
  }

  updateScore('Alice', 100);
  updateScore('Bob', 200);
  updateScore('Charlie', 50);
  updateScore('Diana', 300);

  print(scores); // {Alice: 100, Bob: 200, Charlie: 50, Diana: 300}
}
```

---

## 双向队列（Deque）—— 两端操作均 O(1)

```dart
import 'dart:collection';

void demoDeque() {
  // Dart 的 Queue 即双向队列
  Queue<int> deque = Queue<int>();

  // 两端入队 O(1)
  deque.addFirst(1);
  deque.addLast(2);
  deque.addFirst(3);  // 3 → 1 → 2

  // 两端出队 O(1)
  int first = deque.removeFirst(); // 3
  int last = deque.removeLast();   // 2

  // 滑动窗口最大值 —— 双向队列经典应用
  List<int> maxSlidingWindow(List<int> nums, int k) {
    List<int> result = [];
    Queue<int> deque = Queue<int>(); // 存储索引

    for (int i = 0; i < nums.length; i++) {
      // 移除超出窗口的索引
      while (deque.isNotEmpty && deque.first <= i - k)
        deque.removeFirst();
      // 维护递减队列：移除所有小于当前值的索引
      while (deque.isNotEmpty && nums[deque.last] < nums[i])
        deque.removeLast();
      deque.addLast(i);
      // 窗口形成后记录最大值
      if (i >= k - 1) result.add(nums[deque.first]);
    }
    return result;
  }

  List<int> result = maxSlidingWindow([1, 3, -1, -3, 5, 3, 6, 7], 3);
  print(result); // [3, 3, 5, 5, 6, 7]
}
```

---

## 总结：一分钟决策速查

```
数据有索引/位置含义？
├─ YES → List<T>（Dart 默认，90% 场景适用）
└─ NO  → 数据有 Key 且需要查找？
    ├─ YES → Map<K,V>（O(1) 查找）
    └─ NO  → 需要特定顺序？
        ├─ FIFO（先进先出）→ Queue<T>
        ├─ LIFO（后进先出）→ List 当做栈
        ├─ 最值优先 → 自定义堆（List 实现）
        └─ 需要排序 + 范围查询 → SplayTreeMap<K,V>
```

**核心原则**：用最简单的结构，能 `List` 就不自定义类。复杂度只在数据量 > 10^5 时真正重要。
