import Foundation

/// Additional original interview-pattern problems. Each blueprint represents
/// one genuinely distinct task; retrieval repetitions belong in the spaced
/// review system rather than masquerading as new curriculum entries.
enum MasteryCurriculum {
    private struct Blueprint {
        let moduleID: String
        let key: String
        let title: String
        let difficulty: ProblemDifficulty
        let minutes: Int
        let prompt: String
        let parameters: String
        let idea: String
        let hints: [String]
        let solution: String
        let time: String
        let space: String
        let tests: [(String, String, String)]
    }

    static func problems(for moduleID: String) -> [AlgorithmProblem] {
        blueprints.filter { $0.moduleID == moduleID }.map(makeProblem)
    }

    static func orderedModules(from core: [CurriculumModule]) -> [CurriculumModule] {
        let extras = Dictionary(uniqueKeysWithValues: additionalModules.map { ($0.id, $0) })
        let order = [
            "arrays-hashing", "two-pointers", "sliding-window", "stack", "linked-lists",
            "binary-search", "intervals", "trees", "queues-heaps", "tries-strings",
            "graphs", "union-find", "backtracking", "bit-math", "dynamic-programming",
            "greedy", "advanced", "advanced-data-structures"
        ]
        let all = Dictionary(uniqueKeysWithValues: (core + additionalModules).map { ($0.id, $0) })
        return order.compactMap { all[$0] ?? extras[$0] }
    }

    private static var additionalModules: [CurriculumModule] {
        [
            CurriculumModule(
                id: "linked-lists", title: "Linked Lists", symbol: "link",
                summary: "Reason about nodes through indices, pointer movement, and cycle structure.",
                recognitionCues: ["Following next links defines the order", "Fast and slow pointers reveal structure", "Rewiring beats copying"],
                problems: problems(for: "linked-lists")
            ),
            CurriculumModule(
                id: "queues-heaps", title: "Queues & Heaps", symbol: "arrow.up.arrow.down.square.fill",
                summary: "Keep only the next most useful item instead of repeatedly sorting everything.",
                recognitionCues: ["You repeatedly need the smallest or largest item", "Top-k output is required", "Items arrive as a stream"],
                problems: problems(for: "queues-heaps")
            ),
            CurriculumModule(
                id: "tries-strings", title: "Tries & String Algorithms", symbol: "textformat.abc.dottedunderline",
                summary: "Exploit shared prefixes and previously matched text to avoid rescanning strings.",
                recognitionCues: ["Many words share prefixes", "You need fast prefix queries", "Naive substring matching repeats comparisons"],
                problems: problems(for: "tries-strings")
            ),
            CurriculumModule(
                id: "bit-math", title: "Bits & Mathematics", symbol: "function",
                summary: "Use representation-level identities to compress repeated arithmetic work.",
                recognitionCues: ["Parity or binary digits matter", "Values cancel in pairs", "Exponentiation must avoid a linear loop"],
                problems: problems(for: "bit-math")
            ),
            CurriculumModule(
                id: "union-find", title: "Union-Find & Connectivity", symbol: "point.3.filled.connected.trianglepath.dotted",
                summary: "Merge groups while answering connectivity questions almost instantly.",
                recognitionCues: ["Edges arrive incrementally", "Groups repeatedly merge", "A cycle appears when endpoints are already connected"],
                problems: problems(for: "union-find")
            ),
            CurriculumModule(
                id: "advanced-data-structures", title: "Advanced Data Structures", symbol: "square.3.layers.3d",
                summary: "Maintain query answers as data changes instead of recomputing whole ranges.",
                recognitionCues: ["There are many updates and queries", "Prefix information combines into range answers", "Recency changes after every access"],
                problems: problems(for: "advanced-data-structures")
            )
        ]
    }

    private static func makeProblem(_ blueprint: Blueprint) -> AlgorithmProblem {
        let functionName = "\(blueprint.moduleID)_\(blueprint.key)"
            .replacingOccurrences(of: "-", with: "_")
        let solution = blueprint.solution.replacingOccurrences(
            of: "def solve(", with: "def \(functionName)("
        )
        return AlgorithmProblem(
            id: "mastery.\(blueprint.moduleID).\(blueprint.key)",
            title: blueprint.title,
            difficulty: blueprint.difficulty,
            estimatedMinutes: blueprint.minutes,
            whyItMatters: blueprint.idea,
            prompt: blueprint.prompt,
            examples: blueprint.tests.first.map { [.init(input: $0.1, output: $0.2)] } ?? [],
            constraints: [
                "Inputs match the function signature shown in the editor",
                "Return only JSON-compatible Python values",
                "The built-in tests include empty, boundary, and representative cases"
            ],
            functionName: functionName,
            starterCode: "def \(functionName)(\(blueprint.parameters)):\n    # Write your solution here.\n    pass\n",
            hints: blueprint.hints,
            referenceSolution: solution,
            solutionExplanation: blueprint.idea,
            timeComplexity: blueprint.time,
            spaceComplexity: blueprint.space,
            tests: blueprint.tests.map {
                AlgorithmTestCase(name: $0.0, argumentsJSON: $0.1, expectedJSON: $0.2)
            }
        )
    }

    private static func b(
        _ moduleID: String, _ key: String, _ title: String, _ difficulty: ProblemDifficulty,
        _ minutes: Int, _ parameters: String, _ prompt: String, _ idea: String,
        _ hints: [String], _ solution: String, _ time: String, _ space: String,
        _ tests: [(String, String, String)]
    ) -> Blueprint {
        Blueprint(moduleID: moduleID, key: key, title: title, difficulty: difficulty,
                  minutes: minutes, prompt: prompt, parameters: parameters, idea: idea,
                  hints: hints, solution: solution, time: time, space: space, tests: tests)
    }

    private static let blueprints: [Blueprint] = [
        // MARK: Arrays & Hashing
        b("arrays-hashing", "missing-number", "Missing Number", .easy, 20, "numbers",
          "The list contains distinct values from 0 through n with one value absent. Return the absent value.",
          "The expected full range has a known sum. Subtracting the observed values leaves exactly the missing one.",
          ["Let n be the list length.", "Compute the sum of 0 through n without building that list.", "Subtract the actual sum from n × (n + 1) / 2."],
          """
          def solve(numbers):
              n = len(numbers)
              return n * (n + 1) // 2 - sum(numbers)
          """, "O(n)", "O(1)",
          [("middle", "[[3,0,1]]", "2"), ("end", "[[0,1]]", "2"), ("zero", "[[1]]", "0"), ("empty", "[[]]", "0")]),

        b("arrays-hashing", "majority", "Majority Candidate", .easy, 25, "numbers",
          "A non-empty list is guaranteed to contain a value occurring more than half the time. Return that value.",
          "Boyer-Moore cancellation removes opposing pairs; a true majority must survive as the final candidate.",
          ["Imagine cancelling two different values.", "Track one candidate and a balance.", "Reset the candidate whenever the balance reaches zero."],
          """
          def solve(numbers):
              candidate = None
              balance = 0
              for number in numbers:
                  if balance == 0:
                      candidate = number
                  balance += 1 if number == candidate else -1
              return candidate
          """, "O(n)", "O(1)",
          [("classic", "[[2,2,1,1,1,2,2]]", "2"), ("single", "[[7]]", "7"), ("negative", "[[-1,-1,2]]", "-1"), ("short", "[[3,3,4]]", "3")]),

        b("arrays-hashing", "target-subarrays", "Count Target-Sum Subarrays", .medium, 40, "numbers, target",
          "Return how many contiguous subarrays sum exactly to target. Values may be negative.",
          "Every valid subarray is a pair of prefix sums whose difference is target; a frequency map counts all earlier starts.",
          ["Maintain a running prefix sum.", "A span ending here works when an earlier prefix equals current minus target.", "Store how often every prefix has appeared, beginning with prefix 0 once."],
          """
          def solve(numbers, target):
              counts = {0: 1}
              prefix = 0
              total = 0
              for number in numbers:
                  prefix += number
                  total += counts.get(prefix - target, 0)
                  counts[prefix] = counts.get(prefix, 0) + 1
              return total
          """, "O(n)", "O(n)",
          [("mixed", "[[1,1,1],2]", "2"), ("negatives", "[[1,-1,0],0]", "3"), ("none", "[[2,4],3]", "0"), ("empty", "[[],0]", "0")]),

        // MARK: Two Pointers
        b("two-pointers", "merge-sorted", "Merge Sorted Values", .easy, 25, "first, second",
          "Merge two ascending integer lists into one ascending list without calling sort on the combined input.",
          "Each next output is the smaller value under the two read pointers; once one list ends, append the other suffix.",
          ["Keep one index for each input.", "Compare only the two current values.", "Do not forget the unconsumed suffix."],
          """
          def solve(first, second):
              i = j = 0
              merged = []
              while i < len(first) and j < len(second):
                  if first[i] <= second[j]:
                      merged.append(first[i]); i += 1
                  else:
                      merged.append(second[j]); j += 1
              return merged + first[i:] + second[j:]
          """, "O(n + m)", "O(n + m) output",
          [("mixed", "[[1,4,7],[2,3,9]]", "[1,2,3,4,7,9]"), ("empty first", "[[],[1,2]]", "[1,2]"), ("duplicates", "[[1,2],[1,2]]", "[1,1,2,2]"), ("negative", "[[-3,-1],[-2,0]]", "[-3,-2,-1,0]")]),

        b("two-pointers", "subsequence", "Subsequence Check", .easy, 20, "candidate, text",
          "Return true when every character of candidate appears in text in the same order, not necessarily contiguously.",
          "One pointer advances only on matches while the other scans the text once.",
          ["You never need to move backward.", "Advance the candidate pointer when characters match.", "Success means the candidate pointer reaches its length."],
          """
          def solve(candidate, text):
              index = 0
              for character in text:
                  if index < len(candidate) and candidate[index] == character:
                      index += 1
              return index == len(candidate)
          """, "O(n)", "O(1)",
          [("yes", "[\"ace\",\"abcde\"]", "true"), ("no", "[\"aec\",\"abcde\"]", "false"), ("empty", "[\"\",\"abc\"]", "true"), ("longer", "[\"abcd\",\"abc\"]", "false")]),

        b("two-pointers", "pairs-below", "Pairs Below Target", .medium, 35, "numbers, target",
          "Given an ascending list, count index pairs i < j whose values sum to less than target.",
          "When the endpoint pair is small enough, the left value also pairs successfully with every index up to right.",
          ["Begin at opposite ends.", "If the sum is too large, decrease the right pointer.", "If it works, add right - left pairs at once and advance left."],
          """
          def solve(numbers, target):
              left, right = 0, len(numbers) - 1
              count = 0
              while left < right:
                  if numbers[left] + numbers[right] < target:
                      count += right - left
                      left += 1
                  else:
                      right -= 1
              return count
          """, "O(n)", "O(1)",
          [("mixed", "[[-1,1,2,3,5],4]", "4"), ("all", "[[1,2,3],10]", "3"), ("none", "[[5,6],3]", "0"), ("duplicates", "[[1,1,1],3]", "3")]),

        // MARK: Sliding Window
        b("sliding-window", "max-vowels", "Maximum Vowels in a Window", .easy, 25, "text, size",
          "Treat only lowercase a, e, i, o, and u as vowels. Return the greatest number of vowels in any contiguous substring of exactly size characters. Return 0 when size <= 0 or size > len(text).",
          "A fixed window changes by only one outgoing and one incoming character, so update its vowel count in constant time.",
          ["Count vowels in the first window.", "Subtract the character leaving on the left.", "Add the character entering on the right and retain the maximum."],
          """
          def solve(text, size):
              if size <= 0 or size > len(text):
                  return 0
              vowels = set("aeiou")
              current = sum(1 for char in text[:size] if char in vowels)
              best = current
              for right in range(size, len(text)):
                  current += 1 if text[right] in vowels else 0
                  current -= 1 if text[right - size] in vowels else 0
                  best = max(best, current)
              return best
          """, "O(n)", "O(1)",
          [("classic", "[\"abciiidef\",3]", "3"), ("none", "[\"rhythms\",4]", "0"), ("whole", "[\"aeiou\",5]", "5"), ("invalid", "[\"abc\",4]", "0")]),

        b("sliding-window", "minimum-positive", "Shortest Positive-Sum Window", .medium, 35, "numbers, target",
          "All values are positive. Return the minimum length of a contiguous subarray with sum at least target, or 0 when impossible.",
          "Positivity makes the window sum monotonic: expand to become feasible, then shrink greedily while it remains feasible.",
          ["Grow the right edge and add its value.", "Once the sum reaches target, move the left edge repeatedly.", "Record the shortest feasible length before each shrink."],
          """
          def solve(numbers, target):
              left = 0
              total = 0
              best = len(numbers) + 1
              for right, number in enumerate(numbers):
                  total += number
                  while total >= target:
                      best = min(best, right - left + 1)
                      total -= numbers[left]
                      left += 1
              return 0 if best == len(numbers) + 1 else best
          """, "O(n)", "O(1)",
          [("classic", "[[2,3,1,2,4,3],7]", "2"), ("single", "[[1,4,4],4]", "1"), ("none", "[[1,1],5]", "0"), ("whole", "[[2,2,2],6]", "3")]),

        b("sliding-window", "k-distinct", "Longest Window with K Distinct Values", .medium, 40, "numbers, limit",
          "Return the length of the longest contiguous span containing at most limit distinct values. Return 0 when the list is empty or limit <= 0.",
          "A frequency map describes the window; shrink from the left only while the number of keys exceeds the limit.",
          ["Count values as the right edge grows.", "Delete a key when its count becomes zero.", "After restoring validity, update the maximum length."],
          """
          def solve(numbers, limit):
              if limit <= 0:
                  return 0
              counts = {}
              left = 0
              best = 0
              for right, number in enumerate(numbers):
                  counts[number] = counts.get(number, 0) + 1
                  while len(counts) > limit:
                      old = numbers[left]
                      counts[old] -= 1
                      if counts[old] == 0:
                          del counts[old]
                      left += 1
                  best = max(best, right - left + 1)
              return best
          """, "O(n)", "O(k)",
          [("classic", "[[1,2,1,2,3],2]", "4"), ("one", "[[4,4,5,4],1]", "2"), ("empty", "[[],3]", "0"), ("zero", "[[1,2],0]", "0")]),

        // MARK: Stacks
        b("stack", "simplify-path", "Simplify a File Path", .medium, 35, "path",
          "Normalize an absolute slash-separated path. Ignore empty and dot segments; two dots remove the previous directory when possible.",
          "A stack mirrors the directory depth: normal names push and parent segments pop.",
          ["Split on slash.", "Skip empty strings and single dots.", "Pop for two dots; otherwise push the directory name."],
          """
          def solve(path):
              stack = []
              for part in path.split('/'):
                  if part == '' or part == '.':
                      continue
                  if part == '..':
                      if stack:
                          stack.pop()
                  else:
                      stack.append(part)
              return '/' + '/'.join(stack)
          """, "O(n)", "O(n)",
          [("parent", "[\"/home/user/../docs\"]", "\"/home/docs\""), ("root", "[\"/../../\"]", "\"/\""), ("slashes", "[\"//a///b\"]", "\"/a/b\""), ("dots", "[\"/a/./b/.\"]", "\"/a/b\"")]),

        b("stack", "next-smaller", "Next Smaller Value", .medium, 35, "numbers",
          "For each value, return the first strictly smaller value to its right, or -1 when none exists.",
          "Scanning from the right, a monotonic stack discards values that can never be the next smaller answer.",
          ["Process values from right to left.", "Pop stack values greater than or equal to the current value.", "The remaining top is the answer before pushing the current value."],
          """
          def solve(numbers):
              stack = []
              answer = [-1] * len(numbers)
              for index in range(len(numbers) - 1, -1, -1):
                  while stack and stack[-1] >= numbers[index]:
                      stack.pop()
                  if stack:
                      answer[index] = stack[-1]
                  stack.append(numbers[index])
              return answer
          """, "O(n)", "O(n)",
          [("mixed", "[[4,8,5,2,25]]", "[2,5,2,-1,-1]"), ("ascending", "[[1,2,3]]", "[-1,-1,-1]"), ("descending", "[[3,2,1]]", "[2,1,-1]"), ("empty", "[[]]", "[]")]),

        b("stack", "validate-sequences", "Validate Stack Sequences", .medium, 40, "pushed, popped",
          "Return true when popped could be the pop order of a stack receiving pushed in the supplied order.",
          "Simulate the only meaningful strategy: push each value, then perform every currently requested pop.",
          ["Use a list as a stack.", "After each push, pop while the top matches the next requested output.", "Every requested pop must be consumed for success."],
          """
          def solve(pushed, popped):
              stack = []
              index = 0
              for value in pushed:
                  stack.append(value)
                  while stack and index < len(popped) and stack[-1] == popped[index]:
                      stack.pop()
                      index += 1
              return index == len(popped)
          """, "O(n)", "O(n)",
          [("valid", "[[1,2,3,4,5],[4,5,3,2,1]]", "true"), ("invalid", "[[1,2,3,4,5],[4,3,5,1,2]]", "false"), ("empty", "[[],[]]", "true"), ("reverse", "[[1,2,3],[3,2,1]]", "true")]),

        // MARK: Binary Search
        b("binary-search", "lower-bound", "Lower Bound", .easy, 25, "numbers, target",
          "Given an ascending list, return the first index whose value is at least target. Return the list length when none qualifies.",
          "The predicate value >= target changes from false to true once; binary search finds that boundary.",
          ["Search a half-open interval [left, right).", "When the middle qualifies, keep it by moving right to middle.", "Otherwise discard it by moving left past middle."],
          """
          def solve(numbers, target):
              left, right = 0, len(numbers)
              while left < right:
                  middle = (left + right) // 2
                  if numbers[middle] >= target:
                      right = middle
                  else:
                      left = middle + 1
              return left
          """, "O(log n)", "O(1)",
          [("present", "[[1,3,3,7],3]", "1"), ("between", "[[1,3,7],5]", "2"), ("after", "[[1,2],9]", "2"), ("empty", "[[],4]", "0")]),

        b("binary-search", "kth-missing", "K-th Missing Positive", .medium, 35, "numbers, k",
          "Given strictly increasing positive integers, return the k-th positive integer absent from the list.",
          "At index i, numbers[i] - i - 1 positives are missing before that value; this monotonic count supports binary search.",
          ["Define how many values are missing before an index.", "Find the first index whose missing count reaches k.", "Translate that boundary back into the missing value."],
          """
          def solve(numbers, k):
              left, right = 0, len(numbers)
              while left < right:
                  middle = (left + right) // 2
                  missing = numbers[middle] - middle - 1
                  if missing >= k:
                      right = middle
                  else:
                      left = middle + 1
              return left + k
          """, "O(log n)", "O(1)",
          [("classic", "[[2,3,4,7,11],5]", "9"), ("early", "[[5,6],2]", "2"), ("after", "[[1,2,3],2]", "5"), ("empty", "[[],4]", "4")]),

        b("binary-search", "split-largest", "Minimize Largest Partition Sum", .hard, 55, "numbers, parts",
          "Split non-negative numbers into exactly parts non-empty contiguous groups. Return the smallest possible largest group sum.",
          "A proposed maximum is feasible monotonically: greedily form groups and binary-search the minimum feasible capacity.",
          ["The answer lies between the largest value and the total sum.", "For a proposed limit, greedily start a new group before exceeding it.", "If more than parts groups are needed, the limit is too small."],
          """
          def solve(numbers, parts):
              if not numbers or parts <= 0:
                  return 0
              low, high = max(numbers), sum(numbers)
              while low < high:
                  limit = (low + high) // 2
                  groups = 1
                  current = 0
                  for number in numbers:
                      if current + number > limit:
                          groups += 1
                          current = 0
                      current += number
                  if groups <= parts:
                      high = limit
                  else:
                      low = limit + 1
              return low
          """, "O(n log S)", "O(1)",
          [("classic", "[[7,2,5,10,8],2]", "18"), ("each", "[[1,2,3],3]", "3"), ("one", "[[1,2,3],1]", "6"), ("empty", "[[],2]", "0")]),

        // MARK: Intervals
        b("intervals", "union-length", "Total Covered Length", .medium, 35, "intervals",
          "Intervals are half-open [start, end). Return the total length covered by at least one interval.",
          "After sorting, either extend the active merged interval or close it and begin a disjoint one.",
          ["Sort by start then end.", "Track the current merged boundaries.", "Add a segment only when the next interval starts after the current end."],
          """
          def solve(intervals):
              if not intervals:
                  return 0
              ordered = sorted(intervals)
              start, end = ordered[0]
              total = 0
              for next_start, next_end in ordered[1:]:
                  if next_start > end:
                      total += end - start
                      start, end = next_start, next_end
                  else:
                      end = max(end, next_end)
              return total + end - start
          """, "O(n log n)", "O(n) for sorting",
          [("overlap", "[[[1,4],[2,6],[8,10]]]", "7"), ("touch", "[[[1,3],[3,5]]]", "4"), ("nested", "[[[1,9],[2,3]]]", "8"), ("empty", "[[]]", "0")]),

        b("intervals", "max-overlap", "Peak Concurrent Intervals", .medium, 40, "intervals",
          "Intervals are half-open [start, end). Return the maximum number active at the same time.",
          "Sorted start and end events create a sweep line; at equal times, process endings before starts for half-open intervals.",
          ["Create a +1 start event and -1 end event.", "Sort by time, with -1 before +1 on ties.", "Track the running active count and its maximum."],
          """
          def solve(intervals):
              events = []
              for start, end in intervals:
                  events.append([start, 1])
                  events.append([end, -1])
              events.sort(key=lambda event: (event[0], event[1]))
              active = best = 0
              for _, change in events:
                  active += change
                  best = max(best, active)
              return best
          """, "O(n log n)", "O(n)",
          [("mixed", "[[[1,5],[2,6],[4,8]]]", "3"), ("touch", "[[[1,3],[3,5]]]", "1"), ("same", "[[[0,2],[0,2]]]", "2"), ("empty", "[[]]", "0")]),

        b("intervals", "carpool", "Capacity-Constrained Trips", .medium, 40, "trips, capacity",
          "Each trip is [passengers, start, end) on a line. Return true when capacity is never exceeded.",
          "Passenger changes are interval events; a chronological sweep measures occupancy without simulating every position.",
          ["Add passengers at each start.", "Remove them at each end.", "At equal positions, drop-offs occur before pickups."],
          """
          def solve(trips, capacity):
              events = []
              for passengers, start, end in trips:
                  events.append([start, passengers])
                  events.append([end, -passengers])
              events.sort(key=lambda event: (event[0], event[1]))
              occupied = 0
              for _, change in events:
                  occupied += change
                  if occupied > capacity:
                      return False
              return True
          """, "O(n log n)", "O(n)",
          [("fits", "[[[2,1,5],[3,5,7]],3]", "true"), ("overlap", "[[[2,1,5],[3,3,7]],4]", "false"), ("exact", "[[[2,0,4],[2,2,3]],4]", "true"), ("empty", "[[],0]", "true")]),

        // MARK: Trees (heap-array representation)
        b("trees", "leaf-count", "Count Tree Leaves", .easy, 25, "tree",
          "A binary tree is stored in heap order with null for missing nodes. Return the number of present nodes with no present children.",
          "Heap indices expose children at 2i+1 and 2i+2, so each present node can be classified directly.",
          ["Skip null entries.", "Compute both child indices.", "A node is a leaf when neither child index contains a non-null value."],
          """
          def solve(tree):
              leaves = 0
              for index, value in enumerate(tree):
                  if value is None:
                      continue
                  left = 2 * index + 1
                  right = left + 1
                  has_left = left < len(tree) and tree[left] is not None
                  has_right = right < len(tree) and tree[right] is not None
                  if not has_left and not has_right:
                      leaves += 1
              return leaves
          """, "O(n)", "O(1)",
          [("balanced", "[[1,2,3,4,5,null,6]]", "3"), ("single", "[[9]]", "1"), ("chain", "[[1,2,null,3]]", "1"), ("empty", "[[]]", "0")]),

        b("trees", "right-view", "Right Side View", .medium, 35, "tree",
          "A binary tree is stored in heap order with null gaps. Return the rightmost present value on each non-empty depth.",
          "The heap index determines depth; overwriting the value for a depth while scanning left-to-right retains its rightmost node.",
          ["Depth is floor(log2(index + 1)), but you can track level boundaries without logarithms.", "Scan heap indices in ascending order.", "Replace the saved value whenever another present node appears at the same depth."],
          """
          def solve(tree):
              view = []
              level_end = 0
              depth = 0
              for index, value in enumerate(tree):
                  while index > level_end:
                      depth += 1
                      level_end = 2 * level_end + 2
                  if value is not None:
                      if depth == len(view):
                          view.append(value)
                      else:
                          view[depth] = value
              return view
          """, "O(n)", "O(h)",
          [("mixed", "[[1,2,3,null,5,null,4]]", "[1,3,4]"), ("left", "[[1,2,null,3]]", "[1,2,3]"), ("single", "[[7]]", "[7]"), ("empty", "[[]]", "[]")]),

        b("trees", "max-path", "Maximum Tree Path Sum", .hard, 55, "tree",
          "A binary tree is stored in heap order with null gaps. Return the largest sum on any non-empty path connected through parent-child edges.",
          "Each node returns its best downward arm, while a global answer considers joining the best non-negative arm from each child through that node.",
          ["A parent can continue through at most one child.", "Clamp a negative child contribution to zero.", "At each node, also test left arm + node + right arm as a complete path."],
          """
          def solve(tree):
              if not tree or tree[0] is None:
                  return 0
              best = [tree[0]]
              def arm(index):
                  if index >= len(tree) or tree[index] is None:
                      return 0
                  left = max(0, arm(2 * index + 1))
                  right = max(0, arm(2 * index + 2))
                  best[0] = max(best[0], tree[index] + left + right)
                  return tree[index] + max(left, right)
              arm(0)
              return best[0]
          """, "O(n)", "O(h)",
          [("classic", "[[-10,9,20,null,null,15,7]]", "42"), ("negative", "[[-3]]", "-3"), ("small", "[[1,2,3]]", "6"), ("empty", "[[]]", "0")]),

        // MARK: Graphs
        b("graphs", "provinces", "Count Provinces", .medium, 35, "matrix",
          "An undirected graph is given as a square 0/1 adjacency matrix. Return its number of connected components.",
          "Start a traversal from each unseen vertex; one traversal marks exactly one whole component.",
          ["Keep a set or list of visited vertices.", "When an unseen vertex is found, increment the component count.", "Traverse every neighbor whose matrix entry is 1."],
          """
          def solve(matrix):
              seen = set()
              components = 0
              for start in range(len(matrix)):
                  if start in seen:
                      continue
                  components += 1
                  stack = [start]
                  seen.add(start)
                  while stack:
                      node = stack.pop()
                      for neighbor, connected in enumerate(matrix[node]):
                          if connected and neighbor not in seen:
                              seen.add(neighbor)
                              stack.append(neighbor)
              return components
          """, "O(n²)", "O(n)",
          [("two", "[[[1,1,0],[1,1,0],[0,0,1]]]", "2"), ("one", "[[[1,1],[1,1]]]", "1"), ("separate", "[[[1,0],[0,1]]]", "2"), ("empty", "[[]]", "0")]),

        b("graphs", "network-delay", "Network Signal Delay", .medium, 50, "node_count, edges, start",
          "Directed weighted edges are [from, to, cost] with nodes numbered 0 through node_count-1. Return the time for a signal from start to reach all nodes, or -1 if impossible.",
          "Dijkstra repeatedly finalizes the unvisited node with smallest known distance, then relaxes its outgoing edges.",
          ["Initialize every distance to infinity except the start.", "Choose the closest unvisited node.", "Relax each outgoing edge and return the largest final distance."],
          """
          def solve(node_count, edges, start):
              graph = [[] for _ in range(node_count)]
              for source, target, cost in edges:
                  graph[source].append([target, cost])
              distance = [float('inf')] * node_count
              distance[start] = 0
              used = set()
              for _ in range(node_count):
                  node = -1
                  for candidate in range(node_count):
                      if candidate not in used and (node == -1 or distance[candidate] < distance[node]):
                          node = candidate
                  if node == -1 or distance[node] == float('inf'):
                      break
                  used.add(node)
                  for neighbor, cost in graph[node]:
                      distance[neighbor] = min(distance[neighbor], distance[node] + cost)
              return -1 if any(value == float('inf') for value in distance) else max(distance)
          """, "O(V² + E)", "O(V + E)",
          [("classic", "[4,[[0,1,1],[0,2,4],[1,2,2],[2,3,1]],0]", "4"), ("direct", "[2,[[0,1,5]],0]", "5"), ("unreachable", "[3,[[0,1,1]],0]", "-1"), ("single", "[1,[],0]", "0")]),

        b("graphs", "safe-nodes", "Eventually Safe Nodes", .hard, 50, "graph",
          "A directed graph is an adjacency list. Return ascending nodes from which every possible path eventually stops rather than entering a cycle.",
          "Three-color DFS distinguishes unvisited, currently exploring, and proven-safe nodes; reaching an exploring node exposes a cycle.",
          ["Mark a node as visiting before exploring neighbors.", "A path to a visiting node is unsafe.", "Mark a node safe only after every neighbor is proven safe."],
          """
          def solve(graph):
              state = [0] * len(graph)
              def safe(node):
                  if state[node] != 0:
                      return state[node] == 2
                  state[node] = 1
                  for neighbor in graph[node]:
                      if not safe(neighbor):
                          return False
                  state[node] = 2
                  return True
              return [node for node in range(len(graph)) if safe(node)]
          """, "O(V + E)", "O(V)",
          [("mixed", "[[[1,2],[2,3],[5],[0],[5],[],[]]]", "[2,4,5,6]"), ("cycle", "[[[1],[0]]]", "[]"), ("terminal", "[[[],[]]]", "[0,1]"), ("chain", "[[[1],[2],[]]]", "[0,1,2]")]),

        // MARK: Backtracking
        b("backtracking", "combinations", "Choose K Values", .medium, 35, "n, k",
          "Return all ascending combinations of k distinct integers chosen from 1 through n, in lexicographic order.",
          "Backtracking grows one increasing prefix and prunes when too few values remain to fill it.",
          ["The next choice must be greater than the previous one.", "Append a copy when the path length reaches k.", "Stop a loop early when the remaining values cannot fill the path."],
          """
          def solve(n, k):
              result = []
              path = []
              def search(start):
                  if len(path) == k:
                      result.append(path[:])
                      return
                  needed = k - len(path)
                  for value in range(start, n - needed + 2):
                      path.append(value)
                      search(value + 1)
                      path.pop()
              search(1)
              return result
          """, "O(C(n,k) · k)", "O(k)",
          [("pairs", "[4,2]", "[[1,2],[1,3],[1,4],[2,3],[2,4],[3,4]]"), ("all", "[3,3]", "[[1,2,3]]"), ("none", "[2,3]", "[]"), ("zero", "[3,0]", "[[]]")]),

        b("backtracking", "restore-address", "Restore Dot-Separated Address", .medium, 45, "digits",
          "Split a digit string into exactly four decimal parts, each 0 through 255 with no leading zero unless the part is exactly 0. Return valid addresses in lexicographic order.",
          "Backtracking chooses one-, two-, or three-digit parts and rejects invalid prefixes before exploring deeper.",
          ["Exactly four parts must consume the entire string.", "Reject a multi-digit part beginning with zero.", "Reject a numeric part above 255."],
          """
          def solve(digits):
              result = []
              parts = []
              def search(index):
                  if len(parts) == 4:
                      if index == len(digits):
                          result.append('.'.join(parts))
                      return
                  for length in range(1, 4):
                      part = digits[index:index + length]
                      if len(part) != length:
                          continue
                      if len(part) > 1 and part[0] == '0':
                          continue
                      if int(part) > 255:
                          continue
                      parts.append(part)
                      search(index + length)
                      parts.pop()
              search(0)
              return sorted(result)
          """, "O(1) bounded search", "O(1) excluding output",
          [("classic", "[\"25525511135\"]", "[\"255.255.11.135\",\"255.255.111.35\"]"), ("zeros", "[\"0000\"]", "[\"0.0.0.0\"]"), ("short", "[\"111\"]", "[]"), ("mixed", "[\"101023\"]", "[\"1.0.10.23\",\"1.0.102.3\",\"10.1.0.23\",\"10.10.2.3\",\"101.0.2.3\"]")]),

        b("backtracking", "letter-cases", "Letter Case Variations", .easy, 30, "text",
          "Return every string formed by independently choosing lower- or uppercase for each ASCII letter. Digits remain unchanged. Return sorted output.",
          "Each letter creates two branches while a digit creates one; undo the appended choice after each recursive call.",
          ["Build the output one character at a time.", "Branch twice only for alphabetic characters.", "Sort the completed strings for deterministic output."],
          """
          def solve(text):
              result = []
              path = []
              def search(index):
                  if index == len(text):
                      result.append(''.join(path))
                      return
                  char = text[index]
                  choices = [char.lower(), char.upper()] if char.isalpha() else [char]
                  for choice in choices:
                      path.append(choice)
                      search(index + 1)
                      path.pop()
              search(0)
              return sorted(set(result))
          """, "O(2^L · n)", "O(n) excluding output",
          [("mixed", "[\"a1b\"]", "[\"A1B\",\"A1b\",\"a1B\",\"a1b\"]"), ("digits", "[\"123\"]", "[\"123\"]"), ("one", "[\"z\"]", "[\"Z\",\"z\"]"), ("empty", "[\"\"]", "[\"\"]")]),

        // MARK: Dynamic Programming
        b("dynamic-programming", "knapsack", "Zero-One Knapsack", .medium, 45, "weights, values, capacity",
          "Each item may be chosen at most once. Return the maximum total value whose total weight does not exceed capacity.",
          "A one-dimensional DP stores the best value for each capacity; iterating capacities backward prevents reusing an item.",
          ["Initialize one best value per capacity.", "Process items one at a time.", "Visit capacities from high to low so the current item contributes only once."],
          """
          def solve(weights, values, capacity):
              best = [0] * (capacity + 1)
              for weight, value in zip(weights, values):
                  for limit in range(capacity, weight - 1, -1):
                      best[limit] = max(best[limit], best[limit - weight] + value)
              return best[capacity]
          """, "O(n · capacity)", "O(capacity)",
          [("classic", "[[1,3,4,5],[1,4,5,7],7]", "9"), ("none", "[[5],[9],3]", "0"), ("all", "[[1,2],[3,4],3]", "7"), ("zero", "[[],[],10]", "0")]),

        b("dynamic-programming", "equal-partition", "Equal-Sum Partition", .medium, 40, "numbers",
          "Assign every non-negative input value to exactly one of two groups and return true when their sums can be equal. Either group may be empty, so an empty list or a list containing only zeros returns true.",
          "Equal groups require a subset summing to half the total; a reachable-sums set compactly represents subset DP states.",
          ["An odd total can never split equally.", "Target half of the total.", "For each number, add it to every previously reachable sum without reusing it."],
          """
          def solve(numbers):
              total = sum(numbers)
              if total % 2:
                  return False
              target = total // 2
              reachable = {0}
              for number in numbers:
                  reachable |= {value + number for value in reachable if value + number <= target}
              return target in reachable
          """, "O(n · target)", "O(target)",
          [("yes", "[[1,5,11,5]]", "true"), ("no", "[[1,2,3,5]]", "false"), ("zeros", "[[0,0]]", "true"), ("empty", "[[]]", "true")]),

        b("dynamic-programming", "max-square", "Largest All-One Square", .medium, 45, "matrix",
          "A rectangular matrix contains 0 and 1 integers. Return the area of its largest square containing only 1 values.",
          "A square ending at a cell extends one beyond the minimum square ending above, left, and diagonally above-left.",
          ["Use one DP value per matrix cell.", "Zeros end every square.", "For a one, take 1 plus the minimum of the three neighboring DP states."],
          """
          def solve(matrix):
              if not matrix:
                  return 0
              previous = [0] * (len(matrix[0]) + 1)
              best = 0
              for row in matrix:
                  current = [0]
                  for column, value in enumerate(row, 1):
                      side = 1 + min(previous[column], current[column - 1], previous[column - 1]) if value == 1 else 0
                      current.append(side)
                      best = max(best, side)
                  previous = current
              return best * best
          """, "O(rows · columns)", "O(columns)",
          [("mixed", "[[[1,0,1,0,0],[1,0,1,1,1],[1,1,1,1,1],[1,0,0,1,0]]]", "4"), ("single", "[[[1]]]", "1"), ("zero", "[[[0,0]]]", "0"), ("empty", "[[]]", "0")]),

        // MARK: Greedy
        b("greedy", "cookies", "Assign Resources", .easy, 25, "requirements, resources",
          "Each requirement needs one resource of at least its value, and each resource is used once. Return the maximum number satisfied.",
          "Sorting lets the smallest adequate resource satisfy the smallest remaining requirement without wasting larger options.",
          ["Sort both lists.", "Compare the smallest unsatisfied requirement with the smallest unused resource.", "Use a resource on success; otherwise discard that too-small resource."],
          """
          def solve(requirements, resources):
              needs = sorted(requirements)
              supply = sorted(resources)
              i = j = satisfied = 0
              while i < len(needs) and j < len(supply):
                  if supply[j] >= needs[i]:
                      satisfied += 1
                      i += 1
                  j += 1
              return satisfied
          """, "O(n log n + m log m)", "O(n + m) for sorting",
          [("some", "[[1,2,3],[1,1]]", "1"), ("all", "[[1,2],[2,3]]", "2"), ("none", "[[5],[1,2]]", "0"), ("empty", "[[],[1]]", "0")]),

        b("greedy", "minimum-jumps", "Minimum Forward Jumps", .medium, 40, "numbers",
          "Each value is the maximum forward jump length from that index. Return the fewest jumps to reach the last index, or -1 when unreachable.",
          "The current jump covers a range; scan it to discover the farthest boundary reachable by the next jump, like level-order traversal.",
          ["Track the end of the current jump range.", "Track the farthest index seen within that range.", "When the scan reaches the range end, commit one jump and extend the boundary."],
          """
          def solve(numbers):
              if len(numbers) <= 1:
                  return 0
              jumps = 0
              boundary = farthest = 0
              for index in range(len(numbers) - 1):
                  farthest = max(farthest, index + numbers[index])
                  if index == boundary:
                      if farthest == boundary:
                          return -1
                      jumps += 1
                      boundary = farthest
                      if boundary >= len(numbers) - 1:
                          return jumps
              return -1
          """, "O(n)", "O(1)",
          [("classic", "[[2,3,1,1,4]]", "2"), ("blocked", "[[3,2,1,0,4]]", "-1"), ("single", "[[0]]", "0"), ("steps", "[[1,1,1,1]]", "3")]),

        b("greedy", "reorganize", "Reorganize Repeated Characters", .medium, 45, "text",
          "Rearrange all characters so no equal characters are adjacent. At each output position, among characters different from the previous output character, choose the one with greatest remaining frequency; break a frequency tie with the lexicographically smallest character. Return an empty string if this deterministic process has no valid next character before all input occurrences are used.",
          "Repeatedly placing the most frequent character other than the previous one preserves room for dominant characters; failure proves no valid continuation.",
          ["Count every character.", "At each step exclude the previously placed character.", "Choose greatest remaining frequency, then smallest character for deterministic output."],
          """
          def solve(text):
              counts = {}
              for char in text:
                  counts[char] = counts.get(char, 0) + 1
              result = []
              previous = None
              while len(result) < len(text):
                  choices = [char for char in counts if counts[char] > 0 and char != previous]
                  if not choices:
                      return ''
                  char = sorted(choices, key=lambda item: (-counts[item], item))[0]
                  result.append(char)
                  counts[char] -= 1
                  previous = char
              return ''.join(result)
          """, "O(n · a log a)", "O(a)",
          [("balanced", "[\"aab\"]", "\"aba\""), ("impossible", "[\"aaab\"]", "\"\""), ("tie", "[\"aabb\"]", "\"abab\""), ("empty", "[\"\"]", "\"\"")]),

        // MARK: Advanced synthesis
        b("advanced", "circular-sum", "Maximum Circular Subarray", .hard, 45, "numbers",
          "Return the largest sum of a non-empty circular contiguous subarray. A chosen span follows adjacent indices and may cross from the final index to index 0 at most once; it may include each input position at most once.",
          "The best span is either ordinary Kadane, or the total sum minus a minimum middle span; the all-negative case must use the ordinary result.",
          ["Compute the normal maximum subarray sum.", "A wrapping maximum excludes one minimum subarray.", "Do not choose an empty wrapping result when every value is negative."],
          """
          def solve(numbers):
              if not numbers:
                  return 0
              max_end = max_all = numbers[0]
              min_end = min_all = numbers[0]
              total = numbers[0]
              for number in numbers[1:]:
                  max_end = max(number, max_end + number)
                  max_all = max(max_all, max_end)
                  min_end = min(number, min_end + number)
                  min_all = min(min_all, min_end)
                  total += number
              return max_all if max_all < 0 else max(max_all, total - min_all)
          """, "O(n)", "O(1)",
          [("wrap", "[[5,-3,5]]", "10"), ("normal", "[[1,-2,3,-2]]", "3"), ("negative", "[[-3,-2,-5]]", "-2"), ("empty", "[[]]", "0")]),

        b("advanced", "wildcard", "Wildcard Pattern Match", .hard, 55, "text, pattern",
          "Return true when the whole text matches a pattern where ? matches one character and * matches any sequence, including empty.",
          "Dynamic programming tracks which text prefixes match each pattern prefix; star either consumes nothing or extends an existing star match.",
          ["Define DP over prefixes of text and pattern.", "Question mark behaves like an exact one-character match.", "For star, combine the state above (consume a character) and left (consume nothing)."],
          """
          def solve(text, pattern):
              previous = [True] + [False] * len(text)
              for token in pattern:
                  current = [previous[0] and token == '*'] + [False] * len(text)
                  for index, char in enumerate(text, 1):
                      if token == '*':
                          current[index] = current[index - 1] or previous[index]
                      elif token == '?' or token == char:
                          current[index] = previous[index - 1]
                  previous = current
              return previous[-1]
          """, "O(n · m)", "O(n)",
          [("star", "[\"adceb\",\"*a*b\"]", "true"), ("no", "[\"acdcb\",\"a*c?b\"]", "false"), ("empty", "[\"\",\"*\"]", "true"), ("exact", "[\"abc\",\"abc\"]", "true")]),

        b("advanced", "distinct-subsequences", "Count Distinct Subsequences", .hard, 55, "source, target",
          "Return how many distinct choices of source indices form target after deleting zero or more other characters. Chosen indices must increase, but equal resulting text from different index choices counts as different ways. The empty target has exactly one construction.",
          "A backward one-dimensional DP updates counts for target prefixes, preventing one source character from being reused in the same iteration.",
          ["There is one way to form an empty target.", "Scan the source characters.", "Update target positions backward; on a character match, add ways for the previous target prefix."],
          """
          def solve(source, target):
              ways = [1] + [0] * len(target)
              for char in source:
                  for index in range(len(target), 0, -1):
                      if char == target[index - 1]:
                          ways[index] += ways[index - 1]
              return ways[-1]
          """, "O(n · m)", "O(m)",
          [("classic", "[\"rabbbit\",\"rabbit\"]", "3"), ("multiple", "[\"babgbag\",\"bag\"]", "5"), ("empty target", "[\"abc\",\"\"]", "1"), ("impossible", "[\"ab\",\"abc\"]", "0")]),

        // MARK: Linked Lists (array-backed nodes)
        b("linked-lists", "middle-node", "Middle Linked Node", .easy, 30, "values, next_indices, head",
          "Nodes are parallel arrays: values[i] is a node value and next_indices[i] is its next index or -1. Return the middle node value; for even length return the second middle.",
          "A slow pointer advances once while a fast pointer advances twice; when fast finishes, slow is at the requested middle.",
          ["Indices play the role of pointers.", "Advance fast through two next links when possible.", "Advance slow once for every two fast steps."],
          """
          def solve(values, next_indices, head):
              if head == -1:
                  return None
              slow = fast = head
              while fast != -1 and next_indices[fast] != -1:
                  slow = next_indices[slow]
                  fast = next_indices[next_indices[fast]]
              return values[slow]
          """, "O(n)", "O(1)",
          [("odd", "[[10,20,30],[1,2,-1],0]", "20"), ("even", "[[1,2,3,4],[1,2,3,-1],0]", "3"), ("single", "[[9],[-1],0]", "9"), ("empty", "[[],[],-1]", "null")]),

        b("linked-lists", "reverse-values", "Reverse Linked Traversal", .easy, 30, "values, next_indices, head",
          "Follow an acyclic array-backed linked list and return its values in reverse traversal order.",
          "A forward pass records the chain; reversing that collected sequence mirrors reversing next pointers for the observable order.",
          ["Start at head and repeatedly follow next_indices.", "Append each visited value.", "Reverse the collected output after reaching -1."],
          """
          def solve(values, next_indices, head):
              result = []
              node = head
              while node != -1:
                  result.append(values[node])
                  node = next_indices[node]
              return result[::-1]
          """, "O(n)", "O(n) output",
          [("chain", "[[1,2,3],[1,2,-1],0]", "[3,2,1]"), ("reordered", "[[5,6,7],[2,-1,1],0]", "[6,7,5]"), ("single", "[[4],[-1],0]", "[4]"), ("empty", "[[],[],-1]", "[]")]),

        b("linked-lists", "cycle-entry", "Linked Cycle Entry", .medium, 45, "next_indices, head",
          "Each node stores a next index or -1. Return the index where a reachable cycle begins, or -1 when the chain is acyclic.",
          "Floyd pointers first meet inside a cycle; resetting one to head and advancing both once locates the entry.",
          ["Move slow once and fast twice until they meet or fast ends.", "A missing meeting means no cycle.", "Reset slow to head, then move both one step until equal."],
          """
          def solve(next_indices, head):
              slow = fast = head
              while fast != -1 and next_indices[fast] != -1:
                  slow = next_indices[slow]
                  fast = next_indices[next_indices[fast]]
                  if slow == fast:
                      break
              else:
                  return -1
              slow = head
              while slow != fast:
                  slow = next_indices[slow]
                  fast = next_indices[fast]
              return slow
          """, "O(n)", "O(1)",
          [("middle", "[[1,2,3,1],0]", "1"), ("self", "[[0],0]", "0"), ("none", "[[1,2,-1],0]", "-1"), ("empty", "[[],-1]", "-1")]),

        // MARK: Queues & Heaps
        b("queues-heaps", "kth-smallest", "K-th Smallest Value", .medium, 35, "numbers, k",
          "Return the k-th smallest value, counting duplicates, where k is one-based.",
          "Ordering the candidates exposes the requested rank; in production a size-k heap can reduce work when k is small.",
          ["Duplicates occupy separate ranks.", "Use one-based k carefully.", "After ordering, the answer is at index k - 1."],
          """
          def solve(numbers, k):
              return sorted(numbers)[k - 1]
          """, "O(n log n)", "O(n)",
          [("mixed", "[[7,2,5,2],3]", "5"), ("first", "[[-1,4,0],1]", "-1"), ("last", "[[3,1,2],3]", "3"), ("duplicate", "[[8,8,9],2]", "8")]),

        b("queues-heaps", "closest-points", "K Closest Points", .medium, 40, "points, k",
          "Return the k points closest to the origin by squared distance, breaking ties by x then y. Return them in that priority order.",
          "A priority key of squared distance and coordinates makes the ranking explicit without using square roots.",
          ["Compare squared distances.", "Include coordinates in the sort key for deterministic ties.", "Return the first k ranked points."],
          """
          def solve(points, k):
              return sorted(points, key=lambda point: (point[0] * point[0] + point[1] * point[1], point[0], point[1]))[:k]
          """, "O(n log n)", "O(n)",
          [("mixed", "[[[1,3],[-2,2],[2,-2]],2]", "[[-2,2],[2,-2]]"), ("one", "[[[3,4],[0,1]],1]", "[[0,1]]"), ("zero", "[[[0,0],[1,0]],2]", "[[0,0],[1,0]]"), ("empty", "[[],0]", "[]")]),

        b("queues-heaps", "running-medians", "Running Doubled Medians", .hard, 50, "numbers",
          "After each inserted integer, return twice the median of all values seen so far. For an odd-sized prefix this is 2 times its middle sorted value; for an even-sized prefix it is the sum of its two middle sorted values. Return one answer per input prefix, or [] for empty input.",
          "Maintaining ordered halves is the heap pattern; this compact reference uses ordered insertion to make the median invariant visible.",
          ["Keep the seen prefix ordered.", "Insert each value at its lower-bound position.", "For odd length double the middle; for even length add the two middle values."],
          """
          def solve(numbers):
              ordered = []
              medians = []
              for number in numbers:
                  left, right = 0, len(ordered)
                  while left < right:
                      middle = (left + right) // 2
                      if ordered[middle] < number:
                          left = middle + 1
                      else:
                          right = middle
                  ordered.insert(left, number)
                  size = len(ordered)
                  if size % 2:
                      medians.append(2 * ordered[size // 2])
                  else:
                      medians.append(ordered[size // 2 - 1] + ordered[size // 2])
              return medians
          """, "O(n²) reference; O(n log n) with two heaps", "O(n)",
          [("classic", "[[5,15,1,3]]", "[10,20,10,8]"), ("ascending", "[[1,2,3]]", "[2,3,4]"), ("negative", "[[-1,-3]]", "[-2,-4]"), ("empty", "[[]]", "[]")]),

        // MARK: Tries & Strings
        b("tries-strings", "kmp-index", "Linear Substring Search", .hard, 50, "text, pattern",
          "Return the first index where pattern occurs in text, or -1 when absent. An empty pattern starts at index 0.",
          "KMP records the longest reusable prefix after a mismatch, so neither text nor pattern work is discarded unnecessarily.",
          ["Build a longest-prefix-suffix table for the pattern.", "On mismatch, fall back using that table instead of restarting.", "Advance the text index only when no shorter reusable prefix remains."],
          """
          def solve(text, pattern):
              if pattern == '':
                  return 0
              prefix = [0] * len(pattern)
              length = 0
              for index in range(1, len(pattern)):
                  while length and pattern[index] != pattern[length]:
                      length = prefix[length - 1]
                  if pattern[index] == pattern[length]:
                      length += 1
                  prefix[index] = length
              matched = 0
              for index, char in enumerate(text):
                  while matched and char != pattern[matched]:
                      matched = prefix[matched - 1]
                  if char == pattern[matched]:
                      matched += 1
                  if matched == len(pattern):
                      return index - len(pattern) + 1
              return -1
          """, "O(n + m)", "O(m)",
          [("found", "[\"sadbutsad\",\"sad\"]", "0"), ("later", "[\"mississippi\",\"issip\"]", "4"), ("none", "[\"abc\",\"d\"]", "-1"), ("empty", "[\"abc\",\"\"]", "0")]),

        b("tries-strings", "prefix-counts", "Prefix Query Counts", .medium, 40, "words, queries",
          "For every query prefix, return how many words begin with it. Duplicate words count separately.",
          "A trie can store a pass-through count at every character node; this reference uses direct checks to emphasize the query contract.",
          ["Each query is independent.", "A word contributes when its first characters equal the query.", "An empty query is a prefix of every word."],
          """
          def solve(words, queries):
              return [sum(1 for word in words if word.startswith(query)) for query in queries]
          """, "O(total query × word characters) reference", "O(q) output",
          [("mixed", "[[\"apple\",\"app\",\"ape\",\"bat\"],[\"ap\",\"app\",\"b\"]]", "[3,2,1]"), ("none", "[[\"cat\"],[\"d\"]]", "[0]"), ("empty prefix", "[[\"a\",\"b\"],[\"\"]]", "[2]"), ("duplicates", "[[\"go\",\"go\"],[\"go\"]]", "[2]")]),

        b("tries-strings", "unique-prefixes", "Shortest Unique Prefixes", .hard, 50, "words",
          "Words are distinct lowercase strings. Return the shortest prefix identifying each word uniquely; if a word prefixes another, return the whole word for that entry.",
          "Prefix frequencies tell exactly when a word's path stops being shared; a trie stores the same counts compactly.",
          ["Count every prefix of every word.", "Scan each word from its first character.", "Stop at the first prefix whose frequency is one."],
          """
          def solve(words):
              counts = {}
              for word in words:
                  for length in range(1, len(word) + 1):
                      prefix = word[:length]
                      counts[prefix] = counts.get(prefix, 0) + 1
              result = []
              for word in words:
                  chosen = word
                  for length in range(1, len(word) + 1):
                      if counts[word[:length]] == 1:
                          chosen = word[:length]
                          break
                  result.append(chosen)
              return result
          """, "O(total characters²) reference", "O(total prefixes)",
          [("classic", "[[\"dog\",\"dove\",\"duck\",\"zebra\"]]", "[\"dog\",\"dov\",\"du\",\"z\"]"), ("prefix", "[[\"app\",\"apple\"]]", "[\"app\",\"appl\"]"), ("single", "[[\"code\"]]", "[\"c\"]"), ("empty", "[[]]", "[]")]),

        // MARK: Bits & Mathematics
        b("bit-math", "popcount", "Count Set Bits", .easy, 20, "number",
          "Return the number of 1 bits in the binary representation of a non-negative integer.",
          "Clearing the lowest set bit with n & (n - 1) performs one loop per 1 bit instead of one per bit position.",
          ["Subtracting one flips the lowest set bit and lower zeros.", "AND the number with number - 1.", "Count how many clears are needed to reach zero."],
          """
          def solve(number):
              count = 0
              while number:
                  number &= number - 1
                  count += 1
              return count
          """, "O(number of set bits)", "O(1)",
          [("mixed", "[11]", "3"), ("zero", "[0]", "0"), ("power", "[16]", "1"), ("many", "[255]", "8")]),

        b("bit-math", "single-number", "Unpaired Number", .easy, 20, "numbers",
          "Every non-negative integer appears exactly twice except one. Return the unpaired value.",
          "XOR is associative and a value XOR itself is zero, so paired values cancel regardless of order.",
          ["Start with zero.", "XOR every value into one accumulator.", "All pairs disappear, leaving the single value."],
          """
          def solve(numbers):
              result = 0
              for number in numbers:
                  result ^= number
              return result
          """, "O(n)", "O(1)",
          [("classic", "[[4,1,2,1,2]]", "4"), ("one", "[[7]]", "7"), ("larger", "[[12,3,3]]", "12"), ("zero", "[[0,5,5]]", "0")]),

        b("bit-math", "mod-power", "Fast Modular Power", .medium, 35, "base, exponent, modulus",
          "Return base raised to a non-negative exponent modulo a positive modulus without constructing the full power.",
          "Binary exponentiation squares the base and consumes one exponent bit per step, multiplying only for set bits.",
          ["Reduce the base modulo modulus first.", "When the exponent is odd, multiply it into the result.", "Square the base and halve the exponent each iteration."],
          """
          def solve(base, exponent, modulus):
              result = 1 % modulus
              base %= modulus
              while exponent:
                  if exponent & 1:
                      result = (result * base) % modulus
                  base = (base * base) % modulus
                  exponent //= 2
              return result
          """, "O(log exponent)", "O(1)",
          [("small", "[2,10,1000]", "24"), ("zero exponent", "[9,0,7]", "1"), ("mod one", "[5,3,1]", "0"), ("large", "[7,20,13]", "3")]),

        // MARK: Union-Find
        b("union-find", "redundant-edge", "First Redundant Edge", .medium, 40, "node_count, edges",
          "Starting with node_count isolated nodes, return the first undirected edge whose addition creates a cycle, or an empty list when none does.",
          "An edge is redundant exactly when both endpoints already have the same union-find representative.",
          ["Give each node itself as an initial parent.", "Find representatives with path compression.", "If representatives match, return the edge; otherwise union the groups."],
          """
          def solve(node_count, edges):
              parent = list(range(node_count))
              rank = [0] * node_count
              def find(node):
                  while node != parent[node]:
                      parent[node] = parent[parent[node]]
                      node = parent[node]
                  return node
              for first, second in edges:
                  a, b = find(first), find(second)
                  if a == b:
                      return [first, second]
                  if rank[a] < rank[b]:
                      a, b = b, a
                  parent[b] = a
                  if rank[a] == rank[b]:
                      rank[a] += 1
              return []
          """, "O((V + E) α(V))", "O(V)",
          [("triangle", "[3,[[0,1],[1,2],[2,0]]]", "[2,0]"), ("none", "[3,[[0,1],[1,2]]]", "[]"), ("self", "[1,[[0,0]]]", "[0,0]"), ("later", "[4,[[0,1],[2,3],[1,2],[0,3]]]", "[0,3]")]),

        b("union-find", "component-stream", "Components After Each Union", .medium, 40, "node_count, unions",
          "Return the number of connected components after each undirected union operation.",
          "The component count begins at the node count and decreases only when a union joins two different representatives.",
          ["Initialize one parent per node.", "Find both representatives for every operation.", "Decrement the count only when representatives differ."],
          """
          def solve(node_count, unions):
              parent = list(range(node_count))
              count = node_count
              answer = []
              def find(node):
                  if parent[node] != node:
                      parent[node] = find(parent[node])
                  return parent[node]
              for first, second in unions:
                  a, b = find(first), find(second)
                  if a != b:
                      parent[b] = a
                      count -= 1
                  answer.append(count)
              return answer
          """, "O((V + E) α(V))", "O(V)",
          [("chain", "[4,[[0,1],[1,2],[2,3]]]", "[3,2,1]"), ("repeat", "[3,[[0,1],[0,1]]]", "[2,2]"), ("none", "[2,[]]", "[]"), ("self", "[2,[[0,0]]]", "[2]")]),

        b("union-find", "mst-cost", "Minimum Connection Cost", .hard, 55, "node_count, edges",
          "Nodes are numbered 0 through node_count - 1 and weighted undirected edges are [first, second, cost]. Return the total edge cost of a minimum spanning tree connecting every node, or -1 if no spanning tree exists. For node_count 0 or 1, return 0.",
          "Kruskal processes edges from cheapest upward and accepts exactly those joining different union-find groups.",
          ["Sort edges by cost.", "Use union-find to reject cycle-forming edges.", "A spanning tree needs exactly node_count - 1 accepted edges."],
          """
          def solve(node_count, edges):
              if node_count <= 1:
                  return 0
              parent = list(range(node_count))
              def find(node):
                  if parent[node] != node:
                      parent[node] = find(parent[node])
                  return parent[node]
              total = used = 0
              for first, second, cost in sorted(edges, key=lambda edge: edge[2]):
                  a, b = find(first), find(second)
                  if a != b:
                      parent[b] = a
                      total += cost
                      used += 1
              return total if used == node_count - 1 else -1
          """, "O(E log E)", "O(V)",
          [("classic", "[4,[[0,1,1],[1,2,2],[0,2,4],[2,3,3]]]", "6"), ("choose", "[3,[[0,1,5],[1,2,1],[0,2,2]]]", "3"), ("disconnected", "[3,[[0,1,1]]]", "-1"), ("single", "[1,[]]", "0")]),

        // MARK: Advanced Data Structures
        b("advanced-data-structures", "fenwick-prefix", "Mutable Prefix Queries", .medium, 45, "values, operations",
          "Operations are [0,index,newValue] updates or [1,index] prefix-sum queries. Return query answers in order.",
          "A Fenwick tree stores partial sums at indices determined by the lowest set bit, supporting both point updates and prefix queries logarithmically.",
          ["Build a one-based Fenwick tree.", "An assignment update adds the difference from the old value.", "For a query, repeatedly subtract index & -index while accumulating."],
          """
          def solve(values, operations):
              size = len(values)
              tree = [0] * (size + 1)
              current = values[:]
              def add(index, change):
                  index += 1
                  while index <= size:
                      tree[index] += change
                      index += index & -index
              def prefix(index):
                  total = 0
                  index += 1
                  while index > 0:
                      total += tree[index]
                      index -= index & -index
                  return total
              for index, value in enumerate(values):
                  add(index, value)
              answer = []
              for operation in operations:
                  if operation[0] == 0:
                      index, value = operation[1], operation[2]
                      add(index, value - current[index])
                      current[index] = value
                  else:
                      answer.append(prefix(operation[1]))
              return answer
          """, "O((n + q) log n)", "O(n)",
          [("mixed", "[[1,2,3],[[1,2],[0,1,5],[1,2]]]", "[6,9]"), ("first", "[[4,2],[[1,0]]]", "[4]"), ("updates", "[[0],[[0,0,7],[1,0]]]", "[7]"), ("none", "[[1,2],[]]", "[]")]),

        b("advanced-data-structures", "range-add", "Range Add, Point Read", .medium, 40, "length, updates, queries",
          "The initial array has length entries, all zero. Apply updates in their supplied order; each [left, right, change] adds change to every inclusive index left through right. After all updates, return one final value for each index in queries, preserving query order and repeated query indices.",
          "A difference array marks only where each range change starts and stops; one prefix pass reconstructs every point value.",
          ["Add change at left.", "Subtract change just after right when that index exists.", "Prefix-sum the difference array, then answer each point query."],
          """
          def solve(length, updates, queries):
              difference = [0] * (length + 1)
              for left, right, change in updates:
                  difference[left] += change
                  if right + 1 < length:
                      difference[right + 1] -= change
              values = []
              current = 0
              for index in range(length):
                  current += difference[index]
                  values.append(current)
              return [values[index] for index in queries]
          """, "O(n + q + u)", "O(n)",
          [("overlap", "[5,[[1,3,2],[2,4,1]],[0,1,2,4]]", "[0,2,3,1]"), ("whole", "[3,[[0,2,5]],[0,2]]", "[5,5]"), ("negative", "[2,[[0,0,-2]],[0,1]]", "[-2,0]"), ("none", "[2,[],[1]]", "[0]")]),

        b("advanced-data-structures", "lru", "Least-Recently-Used Cache", .hard, 55, "capacity, operations",
          "Operations are [\"put\",key,value] or [\"get\",key]. Return get results, using -1 for missing keys. Both get and put make a key most recent.",
          "A hash map stores values while recency order determines eviction; this compact reference keeps that order in a list.",
          ["Remove a key from the recency order whenever it is touched.", "Append the touched key as most recent.", "When over capacity, evict the oldest key at the front."],
          """
          def solve(capacity, operations):
              values = {}
              order = []
              output = []
              for operation in operations:
                  kind, key = operation[0], operation[1]
                  if kind == 'get':
                      if key not in values:
                          output.append(-1)
                      else:
                          order.remove(key)
                          order.append(key)
                          output.append(values[key])
                  else:
                      if capacity == 0:
                          continue
                      if key in values:
                          order.remove(key)
                      values[key] = operation[2]
                      order.append(key)
                      if len(order) > capacity:
                          oldest = order.pop(0)
                          del values[oldest]
              return output
          """, "O(q · capacity) reference; O(q) with a linked map", "O(capacity)",
          [("classic", "[2,[[\"put\",1,1],[\"put\",2,2],[\"get\",1],[\"put\",3,3],[\"get\",2]]]", "[1,-1]"), ("update", "[1,[[\"put\",1,1],[\"put\",1,7],[\"get\",1]]]", "[7]"), ("zero", "[0,[[\"put\",1,1],[\"get\",1]]]", "[-1]"), ("missing", "[2,[[\"get\",9]]]", "[-1]")])
    ]
}
