# 《Hello 算法》Dart 语言版 — 案例提取

> 作者：靳宇栋（@krahets） | Release 1.3.0 | 2026-01-01

---

## 第 1 章 · 初识算法

### CASE 1-1：查字典 = 二分查找
- **关联算法**：二分查找
- **位置**：1.1 算法无处不在
- **描述**：查字典时，翻开字典约一半页码，看首字母；若目标字母在后半部分则排除前半，反复折半缩小范围，最终找到目标字。这在计算机科学中就是著名的"二分查找"算法，体现了分而治之的思想。
- **代码片段**：
```dart
// 二分查找核心思想
int binarySearch(List<int> nums, int target) {
  int i = 0, j = nums.length - 1;
  while (i <= j) {
    int m = i + (j - i) ~/ 2;
    if (nums[m] < target) i = m + 1;
    else if (nums[m] > target) j = m - 1;
    else return m;
  }
  return -1;
}
```

### CASE 1-2：整理扑克牌 = 插入排序
- **关联算法**：插入排序
- **位置**：1.1 算法无处不在
- **描述**：打牌时每局整理手中扑克牌，将其分为"有序"和"无序"两部分。从无序部分抽一张，插入到有序部分的正确位置。反复进行，直至全部有序。这就是插入排序在生活中的原型。
- **代码片段**：
```dart
void insertionSort(List<int> nums) {
  for (int i = 1; i < nums.length; i++) {
    int base = nums[i], j = i - 1;
    while (j >= 0 && nums[j] > base) {
      nums[j + 1] = nums[j];
      j--;
    }
    nums[j + 1] = base;
  }
}
```

### CASE 1-3：货币找零 = 贪心算法
- **关联算法**：贪心算法
- **位置**：1.1 算法无处不在
- **描述**：购买 69 元商品付 100 元，收银员找零 31 元时，每次都选最大面额货币：先拿 20 元（剩 11），再拿 10 元（剩 1），最后拿 1 元。每一步都做当前最好选择，这就是贪心策略。
- **代码片段**：
```dart
int coinChangeGreedy(List<int> coins, int amt) {
  int i = coins.length - 1;
  int count = 0;
  while (amt > 0) {
    while (i > 0 && coins[i] > amt) i--;
    amt -= coins[i];
    count++;
  }
  return amt == 0 ? count : -1;
}
```

### CASE 1-4：数据结构与算法 = 拼装积木
- **关联概念**：数据结构与算法关系
- **位置**：1.2.3 数据结构与算法的关系
- **描述**：输入数据 = 未拼装的积木；数据结构 = 积木组织形式（形状、大小、连接方式）；算法 = 把积木拼成目标形态的一系列操作步骤；输出数据 = 积木模型。
- **代码片段**：（概念类比，无代码）

---

## 第 2 章 · 复杂度分析

### CASE 2-1：内存 = Excel 表格
- **关联概念**：内存与空间复杂度
- **位置**：2.4 空间复杂度
- **描述**：将内存比作 Excel 表格的简化类比 —— 每个格子代表一个内存单元，数据按地址存取。虽然实际内存工作机制更复杂（涉及地址空间、分页等），但这帮助我们直观理解内存分配和数据存储。
- **代码片段**：（概念类比）

### CASE 2-2：时间换空间 vs 空间换时间
- **关联概念**：复杂度权衡
- **位置**：2.4 空间复杂度（L1922-1923）
- **描述**：数据库索引（B+ 树、哈希索引）用空间换时间，查询 O(log n) 甚至 O(1)；嵌入式开发内存宝贵，可用时间换空间（如压缩算法）。这是计算机科学中无处不在的权衡。
- **代码片段**：（设计原则）

### CASE 2-3：递归 = 函数调用栈的先入后出
- **关联概念**：递归与栈
- **位置**：2.2 迭代与递归
- **描述**：递归函数调用过程遵循"先入后出"原则：最外层函数最先被调用但最后完成计算，与栈的工作机制如出一辙。这揭示了递归与栈的内在联系。
- **代码片段**：
```dart
int recur(int n) {
  if (n == 1) return 1;        // 终止条件
  int res = recur(n - 1);      // 递归调用
  return n + res;              // 归：返回结果
}

// 用栈模拟递归
int forLoopRecur(int n) {
  List<int> stack = [];
  int res = 0;
  for (int i = n; i > 0; i--) { stack.add(i); }
  while (stack.isNotEmpty) { res += stack.removeLast(); }
  return res;
}
```

---

## 第 4 章 · 数组与链表

### CASE 4-1：数组 = 连续排列的砖块
- **关联数据结构**：数组
- **位置**：4.1 数组（Abstract）
- **描述**：数组的砖块（元素）整齐排列、逐个紧贴，存储在一块连续的内存空间中。每个元素可通过索引 O(1) 直接访问，就像通过门牌号直接找到房间。
- **代码片段**：
```dart
// 初始化数组
List<int> arr = List.filled(5, 0);  // [0, 0, 0, 0, 0]
List<int> nums = [1, 3, 2, 5, 4];

// 随机访问
int randomAccess(List<int> nums) {
  int randomIndex = Random().nextInt(nums.length);
  return nums[randomIndex];
}
```

### CASE 4-2：链表 = 分散各处的砖块用藤蔓连接
- **关联数据结构**：链表
- **位置**：4.2 链表（Abstract）
- **描述**：链表的砖块（节点）分散在内存各处，由连接它们的"藤蔓"（指针/引用）自由穿梭其间。每个节点知道自己的值和下一个节点的位置。
- **代码片段**：
```dart
class ListNode {
  int val;
  ListNode? next;
  ListNode(this.val, [this.next]);
}

// 插入节点
void insert(ListNode n0, ListNode P) {
  ListNode? n1 = n0.next;
  P.next = n1;
  n0.next = P;
}
```

### CASE 4-3：数组 vs 链表效率对比
- **关联概念**：数据结构选型
- **位置**：4.2.2 数组 vs. 链表
- **描述**：数组和链表采用两种相反的存储策略 —— 连续存储 vs 分散存储。数组 O(1) 访问但插入/删除 O(n)；链表 O(n) 访问但在已知位置插入/删除仅 O(1)。实际应用中根据访问模式和数据规模选择。
- **代码片段**：
```dart
// 数组插入（需后移）
void insert(List<int> nums, int num, int index) {
  for (var i = nums.length - 1; i > index; i--)
    nums[i] = nums[i - 1];
  nums[index] = num;
}

// 链表查找
int find(ListNode? head, int target) {
  int index = 0;
  while (head != null) {
    if (head.val == target) return index;
    head = head.next;
    index++;
  }
  return -1;
}
```

### CASE 4-4：缓存命中率 = 数组优于链表的隐秘优势
- **关联概念**：缓存效率
- **位置**：4.4 内存与缓存
- **描述**：数组的高缓存命中率来自四个机制：(1) 数组元素紧凑不浪费缓存行空间；(2) 连续存储减少无效加载；(3) 顺序访问模式可被预取器预测；(4) 空间局部性让附近数据更可能被访问。这解释了为何数组在算法题中更受欢迎。
- **代码片段**：（概念分析，无代码）

---

## 第 5 章 · 栈与队列

### CASE 5-1：栈 = 冬天穿衣服（一摞盘子）
- **关联数据结构**：栈（Stack）
- **位置**：5.1 栈
- **描述**：冬天最先穿上的衣服最后才能脱下（先入后出）。类比桌上一摞盘子，每次只能取最上面的，要取底部必须先把上面的全部移开。栈顶 = 盘子顶部，入栈 = 放盘子，出栈 = 取盘子。
- **代码片段**：
```dart
// Dart 中 List 当栈用
List<int> stack = [];
stack.add(1); stack.add(3); stack.add(2);   // 入栈
int peek = stack.last;                       // 访问栈顶
int pop = stack.removeLast();                // 出栈

// 基于链表实现栈
class LinkedListStack {
  ListNode? stackPeek;
  void push(int num) {
    final node = ListNode(num);
    node.next = stackPeek;
    stackPeek = node;
  }
  int? pop() {
    final num = stackPeek?.val;
    stackPeek = stackPeek?.next;
    return num;
  }
}
```

### CASE 5-2：队列 = 羽毛球筒（排队等候）
- **关联数据结构**：队列（Queue）
- **位置**：5.2 队列
- **描述**：羽毛球筒一端放入一端取出（先入先出）。模拟排队现象：新人加入队尾，队首的人逐个离开。队列的"先入先出"保证处理的公平性。
- **代码片段**：
```dart
Queue<int> queue = Queue();
queue.add(1); queue.add(3);                 // 入队
int peek = queue.first;                      // 访问队首
int pop = queue.removeFirst();               // 出队

// 基于环形数组实现队列
class ArrayQueue {
  List<int> nums;
  int front = 0, queSize = 0;
  void push(int num) {
    int rear = (front + queSize) % nums.length;
    nums[rear] = num;
    queSize++;
  }
}
```

### CASE 5-3：双向队列 = 栈 + 队列的组合
- **关联数据结构**：双向队列（Deque）
- **位置**：5.3 双向队列
- **描述**：双向队列像是栈和队列的组合，或两个栈拼在一起。两端均可入队/出队，兼具栈和队列的所有应用场景，提供更高自由度。
- **代码片段**：
```dart
Queue<int> deque = Queue<int>();
deque.addFirst(3);  deque.addFirst(1);      // 队首入队
deque.addLast(2);   deque.addLast(5);       // 队尾入队
int first = deque.first;                     // 访问队首
int last = deque.last;                       // 访问队尾
```

---

## 第 6 章 · 哈希表

### CASE 6-1：哈希表 = 聪慧的图书管理员
- **关联数据结构**：哈希表（Hash Table）
- **位置**：6.1 哈希表（Abstract）
- **描述**：哈希表如同一位聪慧的图书管理员。她知道每本书放在哪个书架的哪个位置，可以瞬间取到目标书（key → value）。这就是哈希函数的魔力 —— 将任意键映射为确定的存储位置。
- **代码片段**：
```dart
Map<int, String> map = {};
map[12836] = "小哈";                        // 添加
String name = map[15937];                   // 查询 O(1)
map.remove(10583);                          // 删除 O(1)

// 遍历方式
map.forEach((key, value) { print('$key -> $value'); });  // 键值对
map.keys.forEach((key) { print(key); });                  // 遍历键
map.values.forEach((value) { print(value); });            // 遍历值
```

### CASE 6-2：基于数组的简单哈希表实现
- **关联算法**：哈希函数（取模）
- **位置**：6.1.2 哈希表简单实现
- **描述**：用数组实现哈希表，每个桶存储一个键值对。通过 hash(key) = key % 100 定位桶位置，实现 O(1) 增删查改。这展示了哈希表最朴素的设计思想。
- **代码片段**：
```dart
class Pair { int key; String val; Pair(this.key, this.val); }

class ArrayHashMap {
  List<Pair?> buckets = List.filled(100, null);
  int hashFunc(int key) => key % 100;

  String? get(int key) => buckets[hashFunc(key)]?.val;
  void put(int key, String val) {
    buckets[hashFunc(key)] = Pair(key, val);
  }
}
```

### CASE 6-3：链式地址法解决哈希冲突
- **关联算法**：链式地址（Chaining）
- **位置**：6.2 哈希冲突
- **描述**：当多个 key 映射到同一桶时，在桶内用链表存储冲突的键值对。当负载因子（size/capacity）超过阈值时扩容，避免单链表过长导致查询退化为 O(n)。
- **代码片段**：
```dart
class HashMapChaining {
  int size = 0, capacity = 4;
  double loadThres = 2.0 / 3.0;
  int extendRatio = 2;
  List<List<Pair>> buckets = List.generate(4, (_) => []);

  int hashFunc(int key) => key % capacity;
}
```

### CASE 6-4：开放寻址法解决哈希冲突
- **关联算法**：线性探测（Open Addressing）
- **位置**：6.2 哈希冲突
- **描述**：通过线性探测、二次探测或双重哈希，在冲突时寻找下一个空桶。删除时使用墓碑标记（TOMBSTONE）避免搜索链断裂。不需要额外链表空间但需要更大数组。
- **代码片段**：
```dart
class HashMapOpenAddressing {
  int size = 0, capacity = 4;
  double loadThres = 2.0 / 3.0;
  int extendRatio = 2;
  List<Pair?> buckets;
  Pair TOMBSTONE = Pair(-1, "-1");  // 删除标记
  int hashFunc(int key) => key % capacity;
  // 查找时跳过墓碑，插入时复用墓碑位置
}
```

### CASE 6-5：常用哈希算法
- **关联算法**：加法哈希、乘法哈希
- **位置**：6.3 哈希算法
- **描述**：加法哈希将字符串各字符码值累加取模；乘法哈希每步乘 31 再求和（类似进制转换），散列分布更均匀。Dart 内置 hashCode 可以获取整数、布尔、浮点数、字符串、数组的哈希值。
- **代码片段**：
```dart
// 加法哈希
int addHash(String key) {
  int hash = 0, MODULUS = 1000000007;
  for (int i = 0; i < key.length; i++)
    hash = (hash + key.codeUnitAt(i)) % MODULUS;
  return hash;
}

// 乘法哈希
int mulHash(String key) {
  int hash = 0, MODULUS = 1000000007;
  for (int i = 0; i < key.length; i++)
    hash = (31 * hash + key.codeUnitAt(i)) % MODULUS;
  return hash;
}
```

---

## 第 7 章 · 树

### CASE 7-1：树 = 家族族谱（社会组织的树形结构）
- **关联数据结构**：二叉树（Binary Tree）
- **位置**：7.1 二叉树
- **描述**：大到国家、小到家庭，社会的主要组织形式呈现"树"的特征。二叉树代表"祖先"与"后代"的派生关系，体现"一分为二"的分治逻辑。根节点 → 父节点 → 左/右子节点 → 叶节点。
- **代码片段**：
```dart
class TreeNode {
  int val;
  TreeNode? left;
  TreeNode? right;
  TreeNode(this.val, [this.left, this.right]);
}

// 初始化二叉树
TreeNode n1 = TreeNode(1), n2 = TreeNode(2), n3 = TreeNode(3);
n1.left = n2;  n1.right = n3;    // 构建父子关系
```

### CASE 7-2：二叉树的三种深度优先遍历
- **关联算法**：前序/中序/后序遍历
- **位置**：7.2 二叉树遍历
- **描述**：DFS 遍历就像绕着整棵二叉树外围"走"一圈：前序（根→左→右）、中序（左→根→右，BST 得到有序序列）、后序（左→右→根，先子后父）。层序遍历则借助队列逐层访问。
- **代码片段**：
```dart
// 前序遍历：根节点 -> 左子树 -> 右子树
void preOrder(TreeNode? node) {
  if (node == null) return;
  list.add(node.val);
  preOrder(node.left);
  preOrder(node.right);
}

// 中序遍历：左子树 -> 根节点 -> 右子树
void inOrder(TreeNode? node) {
  if (node == null) return;
  inOrder(node.left);
  list.add(node.val);
  inOrder(node.right);
}

// 层序遍历 (BFS)
List<int> levelOrder(TreeNode? root) {
  Queue<TreeNode?> queue = Queue(); queue.add(root);
  List<int> res = [];
  while (queue.isNotEmpty) {
    TreeNode? node = queue.removeFirst();
    res.add(node!.val);
    if (node.left != null) queue.add(node.left);
    if (node.right != null) queue.add(node.right);
  }
  return res;
}
```

### CASE 7-3：二叉搜索树 = 高效查找的树
- **关联数据结构**：二叉搜索树（BST）
- **位置**：7.4 二叉搜索树
- **描述**：左子树所有节点值 < 根节点 < 右子树所有节点值。查询时通过与当前节点比较决定走左或右，最多比较树的高度次。中序遍历得到升序排列。应用于数据库索引、有序集合等。
- **代码片段**：
```dart
// BST 查找
TreeNode? search(int num) {
  TreeNode? cur = root;
  while (cur != null) {
    if (cur.val < num) cur = cur.right;
    else if (cur.val > num) cur = cur.left;
    else break;
  }
  return cur;
}

// BST 插入
void insert(int num) {
  if (root == null) { root = TreeNode(num); return; }
  TreeNode? cur = root, pre = null;
  while (cur != null) {
    if (cur.val == num) return;
    pre = cur;
    cur = cur.val < num ? cur.right : cur.left;
  }
  if (pre!.val < num) pre.right = TreeNode(num);
  else pre.left = TreeNode(num);
}
```

### CASE 7-4：AVL 树 = 自平衡二叉搜索树
- **关联数据结构**：AVL 树
- **位置**：7.5 AVL 树
- **描述**：每个节点的平衡因子（左子树高 - 右子树高）保持在 [-1, 0, 1] 范围内。通过四种旋转操作（右旋、左旋、先左后右、先右后左）恢复平衡，保证查询始终 O(log n)。
- **代码片段**：
```dart
// 右旋操作
TreeNode? rightRotate(TreeNode? node) {
  TreeNode? child = node!.left;
  TreeNode? grandChild = child!.right;
  child.right = node;
  node.left = grandChild;
  updateHeight(node);
  updateHeight(child);
  return child;
}

// 获取平衡因子
int balanceFactor(TreeNode? node) {
  if (node == null) return 0;
  return height(node.left) - height(node.right);
}
```

---

## 第 8 章 · 堆

### CASE 8-1：堆 = 高低错落的山峰
- **关联数据结构**：堆（Heap）
- **位置**：8.1 堆
- **描述**：堆如同山岳峰峦，层叠起伏。最高的山峰（根节点）总是最先映入眼帘。大顶堆根节点最大，小顶堆根节点最小。利用数组存储完全二叉树的特性，索引映射：左子 = 2i+1、右子 = 2i+2、父 = (i-1)/2。
- **代码片段**：
```dart
int left(int i) => 2 * i + 1;
int right(int i) => 2 * i + 2;
int parent(int i) => (i - 1) ~/ 2;

// 入堆：从底至顶堆化
void push(int val) {
  maxHeap.add(val);
  siftUp(size() - 1);
}

void siftUp(int i) {
  int p = parent(i);
  while (p >= 0 && maxHeap[p] < maxHeap[i]) {
    swap(p, i);
    i = p;
    p = parent(i);
  }
}
```

### CASE 8-2：堆排序（HeapSort）
- **关联算法**：堆排序
- **位置**：11.8 堆排序
- **描述**：利用堆数据结构进行排序。先建堆（O(n)），然后依次将堆顶（最大值）与末尾交换，再堆化剩余元素。O(n log n) 时间、O(1) 空间的原地排序，不稳定。
- **代码片段**：
```dart
void siftDown(List<int> nums, int n, int i) {
  while (true) {
    int l = 2 * i + 1, r = 2 * i + 2, ma = i;
    if (l < n && nums[l] > nums[ma]) ma = l;
    if (r < n && nums[r] > nums[ma]) ma = r;
    if (ma == i) break;
    swap(nums, i, ma);
    i = ma;
  }
}

void heapSort(List<int> nums) {
  int n = nums.length;
  for (int i = n ~/ 2 - 1; i >= 0; i--) siftDown(nums, n, i); // 建堆
  for (int i = n - 1; i > 0; i--) {
    swap(nums, 0, i);
    siftDown(nums, i, 0);
  }
}
```

### CASE 8-3：Top-K 问题 = 热度前 K 条新闻
- **关联算法**：堆解决 Top-K
- **位置**：8.3 Top-K 问题
- **描述**：从海量数据中找到最大的 K 个元素。用小顶堆维护当前 K 个最大元素：遍历数据，若当前元素大于堆顶则替换并堆化。时间复杂度 O(n log k)，空间复杂度 O(k)。典型应用：热搜 Top 10、排行榜等。
- **代码片段**：
```dart
MinHeap topKHeap(List<int> nums, int k) {
  MinHeap heap = MinHeap([]);
  for (int i = 0; i < k; i++) heap.push(nums[i]);
  for (int i = k; i < nums.length; i++) {
    if (nums[i] > heap.peek()) {
      heap.pop();
      heap.push(nums[i]);
    }
  }
  return heap;
}
```

---

## 第 9 章 · 图

### CASE 9-1：图 = 社交网络（被无数看不见的边相连）
- **关联数据结构**：图（Graph）
- **位置**：9.1 图
- **描述**：大到社会网络、小到地铁线路，许多系统可建模为"图"。微信好友关系 = 无向图（互相关注），微博抖音关注 = 有向图（A 关注 B ≠ B 关注 A）。王者荣耀亲密度 = 有权图。
- **代码片段**：
```dart
// 邻接表表示图
class GraphAdjList {
  Map<Vertex, List<Vertex>> adjList = {};

  void addEdge(Vertex a, Vertex b) {
    adjList[a]!.add(b);
    adjList[b]!.add(a);   // 无向图添加两条边
  }
}

// 邻接矩阵表示图
class GraphAdjMat {
  List<int> vertices = [];
  List<List<int>> adjMat = [];
}
```

### CASE 9-2：BFS 广度优先遍历
- **关联算法**：广度优先搜索（BFS）
- **位置**：9.3 图的遍历
- **描述**：BFS 借助队列逐层遍历图：从起点出发，先访问所有距离为 1 的顶点，再访问距离为 2 的……遍历序列不唯一。应用于最短路径查找。
- **代码片段**：
```dart
List<Vertex> graphBFS(GraphAdjList graph, Vertex startVet) {
  List<Vertex> res = [];
  Set<Vertex> visited = {startVet};
  Queue<Vertex> queue = Queue()..add(startVet);
  while (queue.isNotEmpty) {
    Vertex vet = queue.removeFirst();
    res.add(vet);
    for (Vertex adjVet in graph.adjList[vet]!) {
      if (!visited.contains(adjVet)) {
        visited.add(adjVet);
        queue.add(adjVet);
      }
    }
  }
  return res;
}
```

### CASE 9-3：DFS 深度优先遍历
- **关联算法**：深度优先搜索（DFS）
- **位置**：9.3 图的遍历
- **描述**：DFS 沿着一条路径走到底再回溯，借助递归或栈实现。类似走迷宫：遇到死路返回上一步再试其他方向。遍历序列因邻接顶点顺序不同而不同。
- **代码片段**：
```dart
void dfs(GraphAdjList graph, Set<Vertex> visited, List<Vertex> res, Vertex vet) {
  res.add(vet);
  visited.add(vet);
  for (Vertex adjVet in graph.adjList[vet]!) {
    if (!visited.contains(adjVet)) {
      dfs(graph, visited, res, adjVet);
    }
  }
}
```

---

## 第 10 章 · 搜索

### CASE 10-1：二分查找 = 查字典算法
- **关联算法**：二分查找
- **位置**：10.1 二分查找
- **描述**：在有序数组中通过不断将搜索区间折半来定位目标值。每次比较中点元素，根据大小关系将区间缩小一半。时间复杂度 O(log n)，空间复杂度 O(1)。要求数据有序且支持索引访问。
- **代码片段**：
```dart
int binarySearch(List<int> nums, int target) {
  int i = 0, j = nums.length - 1;
  while (i <= j) {
    int m = i + (j - i) ~/ 2;
    if (nums[m] < target) i = m + 1;
    else if (nums[m] > target) j = m - 1;
    else return m;
  }
  return -1;
}
```

### CASE 10-2：两步之和 = 哈希优化经典场景
- **关联算法**：哈希查找替换线性查找
- **位置**：10.4 哈希优化策略
- **描述**：给定数组和目标值 target，找两个数之和等于 target。暴力枚举 O(n²)，利用哈希表存储已遍历元素可将时间复杂度降为 O(n)。这是"以空间换时间"的经典优化策略。
- **代码片段**：
```dart
// 暴力枚举 O(n²)
List<int> twoSumBruteForce(List<int> nums, int target) {
  int size = nums.length;
  for (var i = 0; i < size - 1; i++)
    for (var j = i + 1; j < size; j++)
      if (nums[i] + nums[j] == target) return [i, j];
  return [];
}

// 哈希表优化 O(n)
List<int> twoSumHashTable(List<int> nums, int target) {
  Map<int, int> dic = HashMap();
  for (var i = 0; i < nums.length; i++) {
    if (dic.containsKey(target - nums[i]))
      return [dic[target - nums[i]]!, i];
    dic[nums[i]] = i;
  }
  return [];
}
```

### CASE 10-3：二分查找插入点
- **关联算法**：二分查找变体
- **位置**：10.2 二分查找插入点
- **描述**：当数组有序但 target 不存在时，二分查找结束后的 i 指针恰指向首个大于 target 的位置。该位置即为插入 target 的正确位置。适用于维护有序数组。
- **代码片段**：
```dart
int binarySearchInsertion(List<int> nums, int target) {
  int i = 0, j = nums.length - 1;
  while (i <= j) {
    int m = i + (j - i) ~/ 2;
    if (nums[m] < target) i = m + 1;
    else if (nums[m] > target) j = m - 1;
    else j = m - 1;        // 持续向左搜索
  }
  return i;                // 返回插入点
}
```

---

## 第 11 章 · 排序

### CASE 11-1：选择排序 = 从头到尾选最小的
- **关联算法**：选择排序
- **位置**：11.2 选择排序
- **描述**：每次从未排序区间找到最小元素，与区间首元素交换，将其归入已排序区间。O(n²) 时间，O(1) 空间，非稳定排序。简单直观但效率低下。
- **代码片段**：
```dart
void selectionSort(List<int> nums) {
  int n = nums.length;
  for (int i = 0; i < n - 1; i++) {
    int k = i;
    for (int j = i + 1; j < n; j++)
      if (nums[j] < nums[k]) k = j;
    swap(nums, i, k);
  }
}
```

### CASE 11-2：冒泡排序 = 气泡从底部升到顶部
- **关联算法**：冒泡排序
- **位置**：11.3 冒泡排序
- **描述**：相邻元素两两比较，将较大元素"冒泡"到右侧。每轮结束后最大元素在右端。可用标志位优化：若某轮未发生交换，则数组已有序，可提前结束。
- **代码片段**：
```dart
// 标准冒泡排序
void bubbleSort(List<int> nums) {
  for (int i = nums.length - 1; i > 0; i--)
    for (int j = 0; j < i; j++)
      if (nums[j] > nums[j + 1]) swap(nums, j, j + 1);
}

// 标志位优化版
void bubbleSortWithFlag(List<int> nums) {
  for (int i = nums.length - 1; i > 0; i--) {
    bool flag = false;
    for (int j = 0; j < i; j++) {
      if (nums[j] > nums[j + 1]) { swap(nums, j, j + 1); flag = true; }
    }
    if (!flag) break;  // 无交换，已有序
  }
}
```

### CASE 11-3：插入排序 = 整理扑克牌
- **关联算法**：插入排序
- **位置**：11.4 插入排序（同 1-2 案例扩展）
- **描述**：将数组分为已排序区和未排序区，每次从未排序区取一个元素，在已排序区中找到正确位置并插入。类似打牌时整理手牌。O(n²) 最坏，O(n) 最好（已有序），稳定排序。小型数据集非常高效。
- **代码片段**：
```dart
void insertionSort(List<int> nums) {
  for (int i = 1; i < nums.length; i++) {
    int base = nums[i], j = i - 1;
    while (j >= 0 && nums[j] > base) {
      nums[j + 1] = nums[j];
      j--;
    }
    nums[j + 1] = base;
  }
}
```

### CASE 11-4：快速排序 = 哨兵划分 + 分治
- **关联算法**：快速排序
- **位置**：11.5 快速排序
- **描述**：选基准数 pivot，将数组分为左（≤ pivot）右（≥ pivot）两部分，递归排序子数组。平均 O(n log n)，最坏 O(n²)（已排序时）。通过基准数优化（三数取中）和尾递归优化可改善性能。
- **代码片段**：
```dart
int partition(List<int> nums, int left, int right) {
  int i = left, j = right;
  while (i < j) {
    while (i < j && nums[j] >= nums[left]) j--;
    while (i < j && nums[i] <= nums[left]) i++;
    swap(nums, i, j);
  }
  swap(nums, i, left);
  return i;
}

void quickSort(List<int> nums, int left, int right) {
  if (left >= right) return;
  int pivot = partition(nums, left, right);
  quickSort(nums, left, pivot - 1);
  quickSort(nums, pivot + 1, right);
}
```

### CASE 11-5：归并排序 = 先分后合
- **关联算法**：归并排序
- **位置**：11.6 归并排序
- **描述**：递归将数组从中点分为两半，分别排序后合并。合并时用双指针比较两个有序子数组，取较小值放入临时数组。O(n log n) 时间，O(n) 辅助空间，稳定排序，是分治策略的典型应用。
- **代码片段**：
```dart
void merge(List<int> nums, int left, int mid, int right) {
  List<int> tmp = List.filled(right - left + 1, 0);
  int i = left, j = mid + 1, k = 0;
  while (i <= mid && j <= right)
    tmp[k++] = nums[i] <= nums[j] ? nums[i++] : nums[j++];
  while (i <= mid) tmp[k++] = nums[i++];
  while (j <= right) tmp[k++] = nums[j++];
  for (k = 0; k < tmp.length; k++) nums[left + k] = tmp[k];
}
```

### CASE 11-6：桶排序 = 分桶处理
- **关联算法**：桶排序
- **位置**：11.9 桶排序
- **描述**：将数据分到若干有序的桶中，每个桶内独立排序（可用插入排序），最后合并。当数据分布均匀时，时间复杂度可达到 O(n + k)。适合浮点数排序。
- **代码片段**：
```dart
void bucketSort(List<double> nums) {
  int k = nums.length ~/ 2;
  List<List<double>> buckets = List.generate(k, (_) => []);
  for (double num in nums) {
    int i = (num * k).toInt();
    buckets[i].add(num);
  }
  for (var bucket in buckets) bucket.sort();
  int i = 0;
  for (var bucket in buckets)
    for (double num in bucket) nums[i++] = num;
}
```

### CASE 11-7：计数排序 = 用空间换时间
- **关联算法**：计数排序
- **位置**：11.10 计数排序
- **描述**：统计每个元素出现的次数，再根据计数将元素填入数组。仅适用于整数且范围不大的数据。时间复杂度 O(n + m)，空间 O(n + m)，稳定排序。利用前缀和实现稳定版。
- **代码片段**：
```dart
void countingSortNaive(List<int> nums) {
  int m = nums.reduce(max);
  List<int> counter = List.filled(m + 1, 0);
  for (int num in nums) counter[num]++;        // 计数
  int i = 0;
  for (int num = 0; num <= m; num++)
    for (int j = 0; j < counter[num]; j++)
      nums[i++] = num;
}
```

### CASE 11-8：基数排序 = 逐位排序
- **关联算法**：基数排序
- **位置**：11.11 基数排序
- **描述**：从最低位到最高位，逐位使用计数排序进行稳定排序。适用于整数或等长字符串。时间复杂度 O(k × n)，k 为位数，n 为元素个数。当数据为固定位数整数时比 O(n log n) 更快。
- **代码片段**：
```dart
int digit(int num, int exp) => (num ~/ exp) % 10;

void radixSort(List<int> nums) {
  int m = nums.reduce(max);
  for (int exp = 1; exp <= m; exp *= 10)
    countingSortDigit(nums, exp);
}
```

---

## 第 12 章 · 分治

### CASE 12-1：汉诺塔问题 = 分治的经典案例
- **关联算法**：分治（Divide and Conquer）
- **位置**：12.4 汉诺塔问题
- **描述**：将 n 个圆盘从 A 柱移到 C 柱，每次只移一个，大盘不能放小盘上。分治策略：先将 n-1 个移到辅助柱，再将最大盘移到目标柱，最后将 n-1 个移到目标柱。时间复杂度 O(2^n)。
- **代码片段**：
```dart
void move(List<int> src, List<int> tar) {
  int pan = src.removeLast();
  tar.add(pan);
}

void dfs(int i, List<int> src, List<int> buf, List<int> tar) {
  if (i == 1) { move(src, tar); return; }
  dfs(i - 1, src, tar, buf);  // n-1 个移到辅助柱
  move(src, tar);              // 最大盘移到目标
  dfs(i - 1, buf, src, tar);  // n-1 个移到目标柱
}
```

### CASE 12-2：用分治构建二叉树
- **关联算法**：分治 + 二叉树重构
- **位置**：12.3 构建二叉树问题
- **描述**：根据前序遍历（根→左→右）和中序遍历（左→根→右）构建二叉树。前序的首元素是根节点，在中序中找到根节点位置，左子数组构建左子树，右子数组构建右子树。递归分治完成。
- **代码片段**：
```dart
TreeNode? dfs(List<int> preorder, Map<int, int> inorderMap, int i, int l, int r) {
  if (r - l < 0) return null;
  TreeNode? root = TreeNode(preorder[i]);
  int m = inorderMap[preorder[i]]!;
  root.left = dfs(preorder, inorderMap, i + 1, l, m - 1);
  root.right = dfs(preorder, inorderMap, i + 1 + m - l, m + 1, r);
  return root;
}
```

---

## 第 13 章 · 回溯

### CASE 13-1：回溯 = 迷宫中的探索者
- **关联算法**：回溯（Backtracking）
- **位置**：13.1 回溯算法
- **描述**：我们如同迷宫中的探索者，前进时可能遇到困难。回溯让我们能重新开始、不断尝试，直到找到通往目标的出口。算法核心：尝试 → 递归探索 → 剪枝 → 撤销（恢复状态） → 尝试下一选择。
- **代码片段**：
```dart
void backtrack(State state, List<Choice> choices, List<State> res) {
  if (isSolution(state)) { recordSolution(state, res); return; }
  for (Choice choice in choices) {
    if (!isValid(state, choice)) continue;  // 剪枝
    makeChoice(state, choice);              // 尝试
    backtrack(state, choices, res);         // 递归
    undoChoice(state, choice);              // 撤销（恢复状态）
  }
}
```

### CASE 13-2：全排列问题 = 所有可能的排列
- **关联算法**：回溯 → 全排列
- **位置**：13.2 全排列问题
- **描述**：给定集合 [1, 2, 3]，求所有可能的排列（共 3! = 6 种）。通过回溯穷举：每轮选择一个未使用的元素加入排列，标记已选，递归后撤销标记。处理重复元素时需排序 + 剪枝避免重结果。
- **代码片段**：
```dart
void backtrack(List<int> state, List<int> choices, List<bool> selected, List<List<int>> res) {
  if (state.length == choices.length) { res.add(List.from(state)); return; }
  Set<int> duplicated = {};  // 本轮已选值，用于去重
  for (int i = 0; i < choices.length; i++) {
    if (selected[i] || duplicated.contains(choices[i])) continue;
    duplicated.add(choices[i]);
    selected[i] = true;
    state.add(choices[i]);
    backtrack(state, choices, selected, res);
    selected[i] = false;
    state.removeLast();
  }
}
```

### CASE 13-3：子集和问题 = 凑出目标金额
- **关联算法**：回溯 → 子集和
- **位置**：13.3 子集和问题
- **描述**：给定数组和目标值 target，找到所有和等于 target 的子集。通过剪枝优化：(1) 当前和已超 target 则不继续；(2) 先排序，每次从当前索引开始避免重复。类似全排列问题的选择序列。
- **代码片段**：
```dart
void backtrack(List<int> state, int target, List<int> choices, int start, List<List<int>> res) {
  if (target == 0) { res.add(List.from(state)); return; }
  for (int i = start; i < choices.length; i++) {
    if (target - choices[i] < 0) break;  // 剪枝
    if (i > start && choices[i] == choices[i - 1]) continue;  // 避免重复
    state.add(choices[i]);
    backtrack(state, target - choices[i], choices, i + 1, res);
    state.removeLast();
  }
}
```

### CASE 13-4：N 皇后问题 = 棋盘回溯
- **关联算法**：回溯 → N 皇后
- **位置**：13.4 N 皇后问题
- **描述**：在 n × n 棋盘上放置 n 个皇后，使它们互不攻击（不在同一行、列、对角线）。逐行放置皇后，检查列和两个对角线不冲突则继续。回溯尝试所有可能位置。
- **代码片段**：
```dart
void backtrack(int row, int n, List<List<String>> state, List<List<List<String>>> res,
               List<bool> cols, List<bool> diags1, List<bool> diags2) {
  if (row == n) { /* 记录解 */ return; }
  for (int col = 0; col < n; col++) {
    int d1 = row - col + n - 1, d2 = row + col;
    if (cols[col] || diags1[d1] || diags2[d2]) continue;  // 剪枝
    cols[col] = diags1[d1] = diags2[d2] = true;
    state[row][col] = 'Q';
    backtrack(row + 1, n, state, res, cols, diags1, diags2);
    state[row][col] = '#';
    cols[col] = diags1[d1] = diags2[d2] = false;
  }
}
```

---

## 第 14 章 · 动态规划

### CASE 14-1：爬楼梯问题 = 回溯 → 记忆化搜索 → DP 的经典演进
- **关联算法**：动态规划（DP）
- **位置**：14.1 初探动态规划
- **描述**：n 阶楼梯，每次可爬 1 或 2 阶，求方案数。三个阶段演进：(1) 回溯 O(2^n) 超时；(2) 记忆化搜索 O(n) 但需递归开销；(3) DP 自底向上 O(n) 迭代。最终空间优化至 O(1)。
- **代码片段（演化过程）**：
```dart
// 阶段1：回溯（穷举所有路径）O(2^n)
void backtrack(List<int> choices, int state, int n, List<int> res) {
  if (state == n) { res[0]++; return; }
  for (int choice in choices)
    if (state + choice <= n)
      backtrack(choices, state + choice, n, res);
}

// 阶段2：记忆化搜索 O(n)
int dfs(int i, List<int> mem) {
  if (i == 1 || i == 2) return i;
  if (mem[i] != -1) return mem[i];           // 直接返回已有结果
  int count = dfs(i - 1, mem) + dfs(i - 2, mem);
  mem[i] = count;
  return count;
}

// 阶段3：动态规划（自底向上迭代）O(n)
int climbingStairsDP(int n) {
  if (n == 1 || n == 2) return n;
  List<int> dp = List.filled(n + 1, 0);
  dp[1] = 1; dp[2] = 2;
  for (int i = 3; i <= n; i++)
    dp[i] = dp[i - 1] + dp[i - 2];
  return dp[n];
}

// 阶段4：空间优化 O(1)
int climbingStairsDPComp(int n) {
  if (n == 1 || n == 2) return n;
  int a = 1, b = 2;
  for (int i = 3; i <= n; i++) {
    int tmp = b; b = a + b; a = tmp;
  }
  return b;
}
```

### CASE 14-2：最小路径和 = 网格 DP
- **关联算法**：动态规划 → 方格最小路径
- **位置**：14.3 最小路径和
- **描述**：给定 m×n 网格，每格有非负代价，从左上到右下只能右移或下移，求最小路径代价。dp[i][j] = min(dp[i-1][j], dp[i][j-1]) + grid[i][j]。空间优化：只需保留当前行。
- **代码片段**：
```dart
int minPathSumDP(List<List<int>> grid) {
  int n = grid.length, m = grid[0].length;
  List<List<int>> dp = List.generate(n, (i) => List.filled(m, 0));
  dp[0][0] = grid[0][0];
  for (int j = 1; j < m; j++) dp[0][j] = dp[0][j - 1] + grid[0][j];
  for (int i = 1; i < n; i++) dp[i][0] = dp[i - 1][0] + grid[i][0];
  for (int i = 1; i < n; i++)
    for (int j = 1; j < m; j++)
      dp[i][j] = dp[i - 1][j] < dp[i][j - 1]
        ? dp[i - 1][j] + grid[i][j]
        : dp[i][j - 1] + grid[i][j];
  return dp[n - 1][m - 1];
}
```

### CASE 14-3：0/1 背包问题 = 回溯 → 记忆化 → DP 演进
- **关联算法**：动态规划 → 0/1 背包
- **位置**：14.4 0-1 背包问题
- **描述**：n 个物品各有重量和价值，背包容量有限，每物品最多选一次，求最大总价值。dp[i][c] = max(dp[i-1][c], dp[i-1][c-wgt[i-1]] + val[i-1])。空间优化：单行数组倒序遍历。
- **代码片段**：
```dart
int knapsackDP(List<int> wgt, List<int> val, int cap) {
  int n = wgt.length;
  List<List<int>> dp = List.generate(n + 1, (_) => List.filled(cap + 1, 0));
  for (int i = 1; i <= n; i++)
    for (int c = 1; c <= cap; c++)
      if (wgt[i - 1] > c)
        dp[i][c] = dp[i - 1][c];
      else
        dp[i][c] = max(dp[i - 1][c], dp[i - 1][c - wgt[i - 1]] + val[i - 1]);
  return dp[n][cap];
}

// 空间优化 O(cap)
int knapsackDPComp(List<int> wgt, List<int> val, int cap) {
  int n = wgt.length;
  List<int> dp = List.filled(cap + 1, 0);
  for (int i = 1; i <= n; i++)
    for (int c = cap; c >= wgt[i - 1]; c--)  // 倒序遍历
      dp[c] = max(dp[c], dp[c - wgt[i - 1]] + val[i - 1]);
  return dp[cap];
}
```

### CASE 14-4：完全背包 = 物品可重复选取
- **关联算法**：动态规划 → 完全背包
- **位置**：14.5 完全背包问题
- **描述**：与 0/1 背包的区别：每种物品可选任意次。dp[i][c] = max(dp[i-1][c], dp[i][c-wgt[i-1]] + val[i-1])。空间优化时正序遍历（与 0/1 背包相反），因为需要利用本行左侧更新值。
- **代码片段**：
```dart
int unboundedKnapsackDPComp(List<int> wgt, List<int> val, int cap) {
  int n = wgt.length;
  List<int> dp = List.filled(cap + 1, 0);
  for (int i = 1; i <= n; i++)
    for (int c = 1; c <= cap; c++)          // 正序遍历
      if (wgt[i - 1] <= c)
        dp[c] = max(dp[c], dp[c - wgt[i - 1]] + val[i - 1]);
  return dp[cap];
}
```

### CASE 14-5：零钱兑换 = 完全背包的特殊情况
- **关联算法**：动态规划 → 零钱兑换
- **位置**：14.5.3 零钱兑换问题
- **描述**：给定面值数组和目标金额，求最少硬币数。本质是最小化的完全背包：dp[i][a] = min(dp[i-1][a], dp[i][a-coins[i-1]] + 1)。空间优化后可降至 O(amt)。
- **代码片段**：
```dart
int coinChangeDP(List<int> coins, int amt) {
  int n = coins.length, MAX = amt + 1;
  List<List<int>> dp = List.generate(n + 1, (_) => List.filled(amt + 1, 0));
  for (int a = 1; a <= amt; a++) dp[0][a] = MAX;  // 不可能状态
  for (int i = 1; i <= n; i++)
    for (int a = 1; a <= amt; a++)
      if (coins[i - 1] > a)
        dp[i][a] = dp[i - 1][a];
      else
        dp[i][a] = min(dp[i - 1][a], dp[i][a - coins[i - 1]] + 1);
  return dp[n][amt] != MAX ? dp[n][amt] : -1;
}
```

### CASE 14-6：编辑距离 = DP 填表
- **关联算法**：动态规划 → 编辑距离
- **位置**：14.6 编辑距离问题
- **描述**：编辑距离问题的状态转移与背包问题非常类似，可看作填写二维网格的过程。dp[i][j] 表示 s[0..i] 转换为 t[0..j] 的最少操作次数（增、删、改）。应用于拼写检查、DNA 比对等。
- **代码片段**：
```dart
int editDistanceDP(String s, String t) {
  int n = s.length, m = t.length;
  List<List<int>> dp = List.generate(n + 1, (_) => List.filled(m + 1, 0));
  for (int i = 1; i <= n; i++) dp[i][0] = i;
  for (int j = 1; j <= m; j++) dp[0][j] = j;
  for (int i = 1; i <= n; i++)
    for (int j = 1; j <= m; j++)
      if (s[i - 1] == t[j - 1])
        dp[i][j] = dp[i - 1][j - 1];
      else
        dp[i][j] = min(min(dp[i - 1][j], dp[i][j - 1]), dp[i - 1][j - 1]) + 1;
  return dp[n][m];
}
```

---

## 第 15 章 · 贪心

### CASE 15-1：零钱兑换贪心 = 总是选最大面额
- **关联算法**：贪心算法
- **位置**：15.1 贪心算法
- **描述**：贪心与 DP 的区别：DP 考虑所有过去决策，贪心只做当前最优选择。零钱兑换贪心策略：每次选择不大于且最接近剩余金额的最大面额硬币。当硬币面额满足最优子结构时（如人民币），贪心得到全局最优。
- **代码片段**：
```dart
int coinChangeGreedy(List<int> coins, int amt) {
  int i = coins.length - 1, count = 0;
  while (amt > 0) {
    while (i > 0 && coins[i] > amt) i--;
    amt -= coins[i];
    count++;
  }
  return amt == 0 ? count : -1;
}
```

### CASE 15-2：分数背包问题 = 按性价比贪心
- **关联算法**：贪心算法
- **位置**：15.2 分数背包问题
- **描述**：物品可被切割取部分。贪心策略：按单位重量价值 v/w 降序排列，优先拿性价比最高的物品，可拿到最优解。与 0/1 背包不同，0/1 背包不能贪心（需 DP）。
- **代码片段**：
```dart
double fractionalKnapsack(List<int> wgt, List<int> val, int cap) {
  List<Item> items = [];
  for (int i = 0; i < wgt.length; i++) items.add(Item(wgt[i], val[i]));
  items.sort((a, b) => (b.v / b.w).compareTo(a.v / a.w));  // 按性价比降序

  double res = 0;
  for (Item item in items) {
    if (item.w <= cap) { res += item.v; cap -= item.w; }
    else { res += (item.v / item.w) * cap; break; }  // 取部分
  }
  return res;
}
```

### CASE 15-3：最大容量问题 = 短板效应
- **关联算法**：贪心算法 → 双指针
- **位置**：15.3 最大容量问题
- **描述**：给定一组隔板高度，找两隔板围成的最大面积。贪心策略：初始左右指针在两端，每次移动较短的隔板（因为短的是瓶颈，移动它可能得到更大面积）。转化为"求在有限横轴区间下围成的最大面积"的几何问题。
- **代码片段**：
```dart
int maxCapacity(List<int> ht) {
  int i = 0, j = ht.length - 1, res = 0;
  while (i < j) {
    int cap = min(ht[i], ht[j]) * (j - i);
    res = max(res, cap);
    if (ht[i] < ht[j]) i++; else j--;  // 移动短板
  }
  return res;
}
```

### CASE 15-4：最大切分乘积问题
- **关联算法**：贪心算法 → 整数拆分
- **位置**：15.4 最大切分乘积问题
- **描述**：将正整数 n 拆分为若干正整数之和，使乘积最大。贪心策略：尽可能拆成 3（数学推导：3 是乘积最优因子），余数为 1 时取一个 3 变成 2+2（因为 2×2 > 3×1）。
- **代码片段**：
```dart
int maxProductCutting(int n) {
  if (n <= 3) return 1 * (n - 1);
  int a = n ~/ 3, b = n % 3;
  if (b == 1) return pow(3, a - 1).toInt() * 2 * 2;
  if (b == 2) return pow(3, a).toInt() * 2;
  return pow(3, a).toInt();
}
```

---

## 附录：完整类比索引

| 类比对象 | 算法/数据结构 | 所在章节 |
|---------|------------|---------|
| 查字典（翻半本） | 二分查找 | 1.1 |
| 整理扑克牌 | 插入排序 | 1.1 |
| 货币找零 | 贪心算法 | 1.1 |
| 拼装积木 | 数据结构与算法关系 | 1.2.3 |
| 算法如扫雷游戏 | 刷题学习方法 | 序言 |
| 内存如 Excel 表格 | 内存与空间复杂度 | 2.4 |
| 递归如函数调用栈 | 递归与栈 | 2.2 |
| 数组如连续砖块 | 数组 | 4.1 |
| 链表如藤蔓连接砖块 | 链表 | 4.2 |
| 冬天衣服如栈 | 栈（先入后出） | 5.1 |
| 一摞盘子如栈 | 栈 | 5.1 |
| 羽毛球筒如队列 | 队列（先入先出） | 5.2 |
| 排队等候如队列 | 队列 | 5.2 |
| 双向队列 = 栈 + 队列 | 双向队列 | 5.3 |
| 哈希表如图书管理员 | 哈希表 | 6.1 |
| 家族族谱如二叉树 | 树 | 7.1 |
| DFS 如绕着树走一圈 | 深度优先遍历 | 7.2 |
| 山峰如堆 | 堆 | 8.1 |
| 社交网络如无向图 | 图 | 9.1 |
| 微博关注如有向图 | 有向图 | 9.1 |
| 亲密度如加权图 | 有权图 | 9.1 |
| 二分查找如查字典 | 二分查找 | 10.1 |
| 冒泡如气泡上升 | 冒泡排序 | 11.3 |
| 迷宫探索如回溯 | 回溯算法 | 13.1 |
| DP 如填表格 | 动态规划 | 14.6 |
| 向日葵追光如贪心 | 贪心算法 | 15.1 |
| 短板效应如最大容量 | 贪心双指针 | 15.3 |

---

> 共提取 **50+** 个案例，涵盖类比、代码实现、应用场景和算法演进全过程。
