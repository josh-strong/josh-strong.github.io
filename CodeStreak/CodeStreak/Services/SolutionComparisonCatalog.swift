import Foundation

enum SolutionComparisonCatalog {
    static func alternatives(for problemID: String) -> [SolutionAlternative] {
        let canonical = canonicalID(for: problemID)
        return entries[canonical] ?? MLInterviewCurriculum.alternatives[canonical] ?? []
    }

    static func canonicalID(for problemID: String) -> String {
        let parts = problemID.split(separator: ".").map(String.init)
        guard parts.first == "mastery", parts.count == 4 else { return problemID }
        return parts.dropLast().joined(separator: ".")
    }

    static var curatedProblemIDs: Set<String> {
        Set(entries.keys).union(MLInterviewCurriculum.alternatives.keys)
    }

    private static func alternative(
        _ id: String,
        _ title: String,
        _ kind: SolutionComparisonKind,
        _ summary: String,
        time: String,
        space: String,
        bestWhen: String,
        tradeoff: String,
        code: String? = nil
    ) -> SolutionAlternative {
        SolutionAlternative(
            id: id,
            title: title,
            kind: kind,
            summary: summary,
            timeComplexity: time,
            spaceComplexity: space,
            bestWhen: bestWhen,
            tradeoff: tradeoff,
            code: code
        )
    }

    private static let entries: [String: [SolutionAlternative]] = [
        // MARK: Arrays & hashing

        "arrays.sum-positive": [alternative(
            "generator-sum", "Generator expression", .sameBigO,
            "Python can express the same one-pass accumulator with sum(number for number in numbers if number > 0).",
            time: "O(n)", space: "O(1)",
            bestWhen: "You want concise, idiomatic production Python.",
            tradeoff: "It hides the accumulator invariant that the explicit loop is designed to teach."
        )],
        "arrays.pair-indices": [alternative(
            "two-pass-map", "Build the value map first", .sameBigO,
            "Store every value's index in one pass, then search for each complement in a second pass.",
            time: "O(n) expected", space: "O(n)",
            bestWhen: "You want lookup construction separated from answer selection.",
            tradeoff: "Duplicate values need careful index handling, and the two-pass version cannot return as early as the streaming map."
        )],
        "arrays.longest-consecutive": [alternative(
            "sort-runs", "Sort and scan runs", .simplerButSlower,
            "Sort the distinct values, then count adjacent runs while skipping duplicates.",
            time: "O(n log n)", space: "O(n) normally",
            bestWhen: "Deterministic ordering or low-level in-place sorting matters more than expected linear time.",
            tradeoff: "It is easier to trace but gives up the hash-set solution's expected O(n) time."
        )],
        "arrays.same-character-counts": [alternative(
            "counter-equality", "Compare two Counter objects", .sameBigO,
            "collections.Counter directly represents each string's character multiset, so equality states the requirement almost verbatim.",
            time: "O(n + m)", space: "O(k)",
            bestWhen: "You want the clearest idiomatic Python and library use is allowed.",
            tradeoff: "It builds two complete tables and cannot reject an exhausted character early; the reference keeps one table and may stop sooner.",
            code: """
            from collections import Counter

            def same_character_counts(first, second):
                if len(first) != len(second):
                    return False
                return Counter(first) == Counter(second)
            """
        )],
        "arrays.product-except-self": [alternative(
            "two-arrays", "Separate prefix and suffix arrays", .sameBigO,
            "Precompute the product before and after every index, then multiply the two arrays position by position.",
            time: "O(n)", space: "O(n) auxiliary",
            bestWhen: "You are learning the decomposition or want prefix/suffix values for later queries.",
            tradeoff: "It is easier to visualize but uses two extra arrays; the reference reuses the output and one rolling suffix product."
        )],
        "arrays.has-duplicate": [alternative(
            "set-length", "Compare with a set's length", .sameBigO,
            "Return len(set(numbers)) != len(numbers), letting set construction perform all membership work.",
            time: "O(n) expected", space: "O(n)",
            bestWhen: "Brevity matters and the whole set may be built anyway.",
            tradeoff: "It always consumes the full input and full set, whereas the explicit scan can stop at the first duplicate."
        )],
        "arrays.group-anagrams": [alternative(
            "count-key", "Use a 26-count tuple key", .constraintDependent,
            "For lowercase a-z words, use the tuple of 26 character counts as the hash-map key instead of a sorted string.",
            time: "O(n · k)", space: "O(n · k)",
            bestWhen: "The alphabet is fixed and words may be long.",
            tradeoff: "It improves the sorting bound but is less general, more verbose, and must change for Unicode or a different alphabet."
        )],
        "arrays.top-frequent": [alternative(
            "bounded-heap", "Keep a heap of size k", .timeSpaceTradeoff,
            "Count values, then retain only the best k candidates in a min-heap instead of sorting every distinct value.",
            time: "O(n + m log k)", space: "O(m + k)",
            bestWhen: "k is much smaller than the number m of distinct values.",
            tradeoff: "Tie-breaking is easier to get wrong, and a full sort is simpler and often faster when k is large."
        )],
        "arrays.longest-target-sum": [alternative(
            "prefix-pairs", "Check all prefix-sum pairs", .simplerButSlower,
            "Build prefix sums and test every possible start/end difference for the target.",
            time: "O(n²)", space: "O(n)",
            bestWhen: "You want a small-input oracle to validate the optimized solution.",
            tradeoff: "It makes the prefix-difference equation obvious but does not scale to the 100,000-element constraint."
        )],

        // MARK: Two pointers

        "pointers.clean-palindrome": [alternative(
            "normalize-reverse", "Normalize, then compare with reverse", .sameBigO,
            "Build a cleaned lowercase string and compare it with cleaned[::-1].",
            time: "O(n)", space: "O(n)",
            bestWhen: "Readability is more important than auxiliary memory.",
            tradeoff: "It is wonderfully concise but allocates the normalized string and its reverse; two pointers can use O(1) extra space."
        )],
        "pointers.sorted-pair": [alternative(
            "hash-complements", "Use a complement set", .timeSpaceTradeoff,
            "Ignore the sorted-order advantage and search complements with a set in one pass.",
            time: "O(n) expected", space: "O(n)",
            bestWhen: "The input may become unsorted or you need a reusable unsorted-array technique.",
            tradeoff: "It matches linear time but spends memory; opposite pointers are deterministic and O(1) space because the list is sorted."
        )],
        "pointers.water-container": [alternative(
            "all-pairs", "Measure every pair", .simplerButSlower,
            "Enumerate both walls and compute each possible container area.",
            time: "O(n²)", space: "O(1)",
            bestWhen: "You need a brute-force oracle for randomized testing.",
            tradeoff: "It is exhaustive but misses the proof that only moving the shorter wall can improve the answer."
        )],
        "pointers.three-sum": [alternative(
            "hash-third", "Fix one value and hash the other two", .timeSpaceTradeoff,
            "For each first value, scan the suffix with a complement set and canonicalize found triples.",
            time: "O(n²) expected", space: "O(n) plus deduplication",
            bestWhen: "You want to reuse the two-sum hash pattern without relying on pointer movement.",
            tradeoff: "It has the same headline time but duplicate suppression and deterministic output are more awkward than sort plus two pointers."
        )],
        "pointers.trapped-water": [alternative(
            "prefix-maxima", "Precompute left and right maxima", .sameBigO,
            "Store the tallest wall seen from each side; water at an index is min(left_max, right_max) minus its height.",
            time: "O(n)", space: "O(n)",
            bestWhen: "You want the most direct per-index formula or need the water depth at every index.",
            tradeoff: "The proof is straightforward, but two pointers compress both maximum arrays into O(1) state."
        )],
        "pointers.move-zeros": [alternative(
            "filter-concatenate", "Filter nonzeros, then append zeros", .sameBigO,
            "Collect the nonzero values and concatenate the required number of zeros.",
            time: "O(n)", space: "O(n) output",
            bestWhen: "You want concise immutable-style Python.",
            tradeoff: "It may allocate multiple temporary lists; the indexed output buffer performs one predictable allocation."
        )],
        "pointers.sorted-squares": [alternative(
            "square-sort", "Square everything, then sort", .simplerButSlower,
            "Transform each number to its square and call sorted on the result.",
            time: "O(n log n)", space: "O(n)",
            bestWhen: "Inputs are small and clarity outweighs exploiting sorted order.",
            tradeoff: "It is one line but discards the monotonic structure that enables the O(n) two-pointer merge."
        )],
        "pointers.closest-pair": [alternative(
            "binary-partner", "Binary-search a partner for each value", .simplerButSlower,
            "For every left value, binary-search the suffix for the closest complement to target.",
            time: "O(n log n)", space: "O(1)",
            bestWhen: "You are extending the idea to repeated independent queries on a fixed sorted list.",
            tradeoff: "It is locally intuitive but slower for one query than the coordinated O(n) pointer scan."
        )],
        "pointers.four-sum": [alternative(
            "pair-sums", "Index pair sums", .timeSpaceTradeoff,
            "Group index pairs by sum, then match complementary sum buckets while enforcing four distinct indices.",
            time: "O(n²) average plus output", space: "O(n²)",
            bestWhen: "n is moderate and memory is available to reduce repeated pair work.",
            tradeoff: "It can beat the O(n³) pointer reduction, but deduplication, index disjointness, and ordered output become substantially harder."
        )],

        // MARK: Sliding window

        "window.best-fixed-sum": [alternative(
            "prefix-queries", "Prefix-sum every window", .sameBigO,
            "Build prefix sums so each fixed window sum is one subtraction.",
            time: "O(n)", space: "O(n)",
            bestWhen: "You will answer many different window or range-sum queries on the same input.",
            tradeoff: "For one fixed size, the rolling sum is equally fast and uses O(1) extra memory."
        )],
        "window.longest-unique": [alternative(
            "last-seen", "Jump with last-seen indices", .sameBigO,
            "Map each character to its latest index and jump the left boundary past a repeated character in one step.",
            time: "O(n)", space: "O(k)",
            bestWhen: "Long runs of repeated characters would otherwise trigger many single-step removals.",
            tradeoff: "The set-based window is easier to generalize; last-seen indices require careful max logic to avoid moving left backward."
        )],
        "window.minimum-cover": [alternative(
            "counter-window", "Use Counter subtraction semantics", .sameBigO,
            "Track required and current counts with Counter while maintaining how many requirements are satisfied.",
            time: "O(n + m)", space: "O(k)",
            bestWhen: "You want expressive multiset operations and library use is allowed.",
            tradeoff: "Counter makes the intent concise but does not remove the subtle formed/required invariant and adds object-level overhead."
        )],
        "window.longest-replacement": [alternative(
            "recompute-max", "Recompute the window's maximum frequency", .timeSpaceTradeoff,
            "After each update, calculate max(counts.values()) instead of retaining a monotonic historical maximum.",
            time: "O(n · k)", space: "O(k)",
            bestWhen: "The alphabet is tiny and you value an invariant that exactly reflects the current window.",
            tradeoff: "It is conceptually direct but slower for large alphabets; the stale maximum is safe and keeps the reference linear."
        )],
        "window.permutation-starts": [alternative(
            "counter-equality", "Compare window Counters", .timeSpaceTradeoff,
            "Maintain a Counter for the pattern and each moving window, comparing the two count maps at every position.",
            time: "O(n · k) worst case", space: "O(k)",
            bestWhen: "Patterns are short and clarity matters more than strict linear time.",
            tradeoff: "The code is shorter, but full map equality per window can cost O(k); tracking matched categories keeps the reference O(n)."
        )],
        "window.min-positive-sum": [alternative(
            "prefix-bisect", "Prefix sums plus binary search", .simplerButSlower,
            "Positive values make prefix sums increasing, so binary-search the earliest sufficient endpoint for each start.",
            time: "O(n log n)", space: "O(n)",
            bestWhen: "You are practicing binary search on monotonic prefix sums or reusing stored prefixes.",
            tradeoff: "It works, but the positivity condition supports a faster O(n), O(1)-space sliding window."
        )],
        "window.max-ones": [alternative(
            "zero-indices", "Queue the zero positions", .sameBigO,
            "Keep the indices of zeros in the window; when there are too many, jump left past the oldest zero.",
            time: "O(n)", space: "O(k)",
            bestWhen: "You want boundary jumps to be explicit or the valid/invalid items are sparse.",
            tradeoff: "It can make shrinking clearer but uses a queue; counting zeros needs only O(1) state."
        )],
        "window.repeated-dna": [alternative(
            "rolling-bits", "Encode a rolling 2-bit hash", .constraintDependent,
            "Encode A/C/G/T as two bits and update the fixed-length window with shifts and a bit mask.",
            time: "O(n)", space: "O(n) seen hashes",
            bestWhen: "The alphabet and window length are fixed and substring allocation is expensive.",
            tradeoff: "It reduces key size and allocations but is less readable and tightly coupled to the four-character alphabet."
        )],
        "window.maximum-values": [alternative(
            "heap-window", "Use a max-heap with lazy deletion", .timeSpaceTradeoff,
            "Push each value/index and discard heap entries that have left the window before reading the maximum.",
            time: "O(n log n)", space: "O(n)",
            bestWhen: "You already need a priority queue or are generalizing to richer priorities.",
            tradeoff: "It is familiar but slower and larger than the monotonic deque's O(n) time and O(k) space."
        )],

        // MARK: Stacks

        "stack.balanced-brackets": [alternative(
            "expected-closers", "Push expected closing brackets", .sameBigO,
            "When an opener appears, push its matching closer; a closer is valid only when it equals stack.pop().",
            time: "O(n)", space: "O(n)",
            bestWhen: "You want fewer dictionary lookups during closing-bracket handling.",
            tradeoff: "It is compact but slightly less explicit than storing openers and comparing opener/closer pairs."
        )],
        "stack.warmer-waits": [alternative(
            "jump-table", "Jump through previously computed waits", .sameBigO,
            "Scan from right to left and use earlier answers to jump over days that cannot be warmer.",
            time: "O(n) amortized", space: "O(n) output",
            bestWhen: "You want to avoid an explicit stack and are comfortable proving jump progress.",
            tradeoff: "It can use only the output array, but its correctness and edge cases are harder to see than a monotonic stack."
        )],
        "stack.largest-histogram": [alternative(
            "boundaries", "Precompute nearest smaller boundaries", .sameBigO,
            "Use two monotonic passes to find each bar's first smaller neighbor on both sides, then compute every maximal width.",
            time: "O(n)", space: "O(n)",
            bestWhen: "You need each bar's span explicitly for explanation or later queries.",
            tradeoff: "The calculation is direct but uses two boundary arrays; the one-pass stack computes areas as bars close."
        )],
        "stack.remove-adjacent": [alternative(
            "repeated-replace", "Repeatedly remove matching pairs", .simplerButSlower,
            "Apply local pair removals until a complete pass makes no change.",
            time: "O(n²) worst case", space: "O(n)",
            bestWhen: "You are creating a tiny-input specification or debugging oracle.",
            tradeoff: "It mirrors the wording but rescans; the stack resolves every character once in O(n)."
        )],
        "stack.evaluate-postfix": [alternative(
            "operator-table", "Dispatch through an operator table", .sameBigO,
            "Map operator tokens to functions from the operator module while retaining the same operand stack.",
            time: "O(n)", space: "O(n)",
            bestWhen: "The operator set is extensible and library dispatch improves maintainability.",
            tradeoff: "It removes branching but can obscure operand order, especially for subtraction and division."
        )],
        "stack.min-add-parentheses": [alternative(
            "balance-counter", "Track balance without a stack", .sameBigO,
            "Count unmatched openers and increment additions whenever a closer arrives with zero balance.",
            time: "O(n)", space: "O(1)",
            bestWhen: "There is only one bracket type, so nesting identity is irrelevant.",
            tradeoff: "This is more memory-efficient than a literal stack but does not generalize to multiple bracket types."
        )],
        "stack.asteroid-collisions": [alternative(
            "linked-survivors", "Maintain survivors in a linked structure", .sameBigO,
            "Keep live neighbors in linked nodes and resolve collisions by deleting destroyed nodes.",
            time: "O(n)", space: "O(n)",
            bestWhen: "The simulation later requires insertions or references to stable nodes.",
            tradeoff: "It matches asymptotic time but adds allocation and pointer complexity; a list already gives the required stack behavior."
        )],
        "stack.decode-string": [alternative(
            "recursive-parser", "Recursive descent parser", .sameBigO,
            "Parse characters recursively until a closing bracket returns the decoded inner segment to its caller.",
            time: "O(output size)", space: "O(n) recursion/output",
            bestWhen: "The grammar may grow beyond repetition into more nested constructs.",
            tradeoff: "The structure follows the grammar naturally, but deep nesting risks recursion limits; the explicit stack is safer."
        )],
        "stack.next-greater-circular": [alternative(
            "duplicate-array", "Scan a doubled array", .sameBigO,
            "Run the ordinary next-greater stack algorithm over numbers + numbers and keep answers only for original indices.",
            time: "O(n)", space: "O(n) extra if materialized",
            bestWhen: "You want to reuse a non-circular implementation with minimal control-flow changes.",
            tradeoff: "It is easy to reason about but may allocate the doubled input; modular indexing avoids that copy."
        )],

        // MARK: Binary search

        "binary.first-position": [alternative(
            "bisect-left", "Use bisect_left", .sameBigO,
            "Python's bisect_left returns the insertion point of target; verify that the value there actually equals target.",
            time: "O(log n)", space: "O(1)",
            bestWhen: "Standard-library use is allowed and you want concise, well-tested boundary logic.",
            tradeoff: "It is production-friendly but hides the lower-bound invariant the exercise is meant to teach."
        )],
        "binary.rotated-minimum": [alternative(
            "linear-min", "Call min or scan", .simplerButSlower,
            "Ignore the rotation structure and take the minimum over all values.",
            time: "O(n)", space: "O(1)",
            bestWhen: "Inputs are small, duplicates invalidate the strict binary-search proof, or simplicity dominates.",
            tradeoff: "It is robust and obvious but gives up the promised logarithmic search."
        )],
        "binary.minimum-speed": [alternative(
            "incremental-speed", "Try speeds in order", .simplerButSlower,
            "Evaluate every speed from 1 upward and stop at the first feasible one.",
            time: "O(n · maxPile)", space: "O(1)",
            bestWhen: "You need a brute-force oracle for tiny randomized inputs.",
            tradeoff: "It validates the feasibility predicate but ignores its monotonicity, which is exactly what binary search exploits."
        )],
        "binary.search-rotated": [alternative(
            "pivot-then-search", "Find the pivot, then binary-search", .sameBigO,
            "Locate the rotation index first, choose the sorted half that could contain target, then run ordinary binary search.",
            time: "O(log n)", space: "O(1)",
            bestWhen: "You want to separate rotation reasoning from standard binary search.",
            tradeoff: "The phases are easier to test independently but perform two searches and need more boundary code than the one-pass method."
        )],
        "binary.ship-capacity": [alternative(
            "capacity-scan", "Test every capacity", .simplerButSlower,
            "Starting at the heaviest package, increase capacity until the greedy day simulation becomes feasible.",
            time: "O(n · answer range)", space: "O(1)",
            bestWhen: "You are validating the monotone feasibility function on small cases.",
            tradeoff: "The simulation is identical, but linear answer search is far slower than binary-searching the capacity range."
        )],
        "binary.exact-search": [alternative(
            "bisect-index", "Use bisect_left", .sameBigO,
            "Find target's insertion index with bisect_left and return it only when the indexed value matches.",
            time: "O(log n)", space: "O(1)",
            bestWhen: "You are writing application Python rather than demonstrating the algorithm.",
            tradeoff: "It is concise and reliable but does not expose why each discarded half is safe."
        )],
        "binary.integer-root": [alternative(
            "newton", "Newton's integer iteration", .sameBigO,
            "Iteratively replace x with (x + number // x) // 2 until the estimate stops decreasing.",
            time: "O(log number)", space: "O(1)",
            bestWhen: "You want fast numerical convergence and are comfortable with the algebraic invariant.",
            tradeoff: "It often uses fewer iterations, but binary search has simpler bounds and is easier to generalize to other monotone predicates."
        )],
        "binary.peak-index": [alternative(
            "linear-peak", "Scan for the maximum", .simplerButSlower,
            "Return the index of the largest value; a global maximum is necessarily a valid peak under the problem's boundary rules.",
            time: "O(n)", space: "O(1)",
            bestWhen: "You need deterministic choice of a particular peak or inputs are tiny.",
            tradeoff: "It is simpler but misses the local slope information that permits O(log n) search."
        )],

        // MARK: Intervals

        "intervals.merge-ranges": [alternative(
            "event-sweep", "Sweep start/end events", .timeSpaceTradeoff,
            "Convert intervals into boundary events, sort them, and emit covered spans while active count is positive.",
            time: "O(n log n)", space: "O(n)",
            bestWhen: "You also need overlap counts or other event-based statistics.",
            tradeoff: "It is more general but requires careful handling of closed endpoints; sorting intervals directly is simpler for merging alone."
        )],
        "intervals.insert-range": [alternative(
            "append-sort-merge", "Append, sort, then merge", .simplerButSlower,
            "Add the new interval to the list and run the ordinary merge-intervals algorithm.",
            time: "O(n log n)", space: "O(n) output",
            bestWhen: "The existing intervals are not guaranteed sorted or code reuse matters most.",
            tradeoff: "It is robust and short but discards the sorted, non-overlapping guarantee that enables the O(n) reference."
        )],
        "intervals.meeting-rooms": [alternative(
            "start-end-sweep", "Separate sorted starts and ends", .sameBigO,
            "Sort start times and end times independently; move two pointers to count how many meetings are active.",
            time: "O(n log n)", space: "O(n)",
            bestWhen: "You only need the maximum room count, not the actual room assignment.",
            tradeoff: "It often has lower constants than a heap but cannot tell which room becomes free or construct a schedule."
        )],
        "intervals.intersection": [alternative(
            "nested-check", "Check every interval pair", .simplerButSlower,
            "Intersect each interval from the first list with every interval in the second.",
            time: "O(n · m)", space: "O(output)",
            bestWhen: "Inputs are unsorted, tiny, or used as an oracle.",
            tradeoff: "It needs no pointer proof but ignores that both lists are sorted and internally disjoint."
        )],
        "intervals.erase-overlaps": [alternative(
            "dp-selection", "Dynamic-programming interval selection", .simplerButSlower,
            "After sorting, compute the largest compatible subset and remove everything else.",
            time: "O(n²) directly", space: "O(n)",
            bestWhen: "Intervals later gain weights, where the greedy earliest-finish rule no longer suffices.",
            tradeoff: "It generalizes to weighted scheduling but is unnecessary and slower for equal-value intervals."
        )],
        "intervals.can-attend": [alternative(
            "active-heap", "Track active meetings with a heap", .timeSpaceTradeoff,
            "Process meetings by start time and keep their end times in a min-heap, rejecting whenever more than one is active.",
            time: "O(n log n)", space: "O(n)",
            bestWhen: "You expect to extend the task to room counts or assignments.",
            tradeoff: "It is extensible but more machinery than comparing adjacent intervals after sorting."
        )],
        "intervals.covered-queries": [alternative(
            "binary-merged", "Merge intervals, then binary-search queries", .timeSpaceTradeoff,
            "Merge coverage first and binary-search the final disjoint ranges for every query point.",
            time: "O(n log n + q log n)", space: "O(n)",
            bestWhen: "Queries arrive online after preprocessing or cannot all be sorted together.",
            tradeoff: "It supports independent queries, while an offline joint sweep can answer a known batch more linearly after sorting."
        )],
        "intervals.minimum-groups": [alternative(
            "event-count", "Sweep overlap events", .sameBigO,
            "Sort starts and ends (or signed events) and take the maximum number of simultaneously active intervals.",
            time: "O(n log n)", space: "O(n)",
            bestWhen: "You only need the group count rather than an explicit assignment.",
            tradeoff: "The sweep is compact, but inclusive endpoints require precise event ordering; a heap mirrors actual group reuse."
        )],

        // MARK: Trees

        "trees.maximum-depth": [alternative(
            "breadth-levels", "Count breadth-first levels", .sameBigO,
            "Traverse the tree level by level with a queue and increment depth after each complete level.",
            time: "O(n)", space: "O(w)",
            bestWhen: "Recursion depth may exceed Python's limit or you already need level-order data.",
            tradeoff: "It avoids call-stack risk but may retain an entire wide level; recursive DFS uses O(h) stack and is more direct."
        )],
        "trees.level-averages": [alternative(
            "dfs-depth-sums", "DFS with per-depth sums", .sameBigO,
            "Traverse depth-first while accumulating a sum and count for each depth, then divide after traversal.",
            time: "O(n)", space: "O(h + levels)",
            bestWhen: "You prefer recursion or are collecting several depth-indexed statistics together.",
            tradeoff: "It avoids a breadth queue but stores aggregate arrays and does not naturally emit completed levels as BFS does."
        )],
        "trees.valid-search-tree": [alternative(
            "inorder-monotonic", "Check increasing inorder values", .sameBigO,
            "An inorder traversal of a valid BST must be strictly increasing; compare each value with the previous one.",
            time: "O(n)", space: "O(h)",
            bestWhen: "You are already using inorder traversal or want a single previous-value invariant.",
            tradeoff: "It is compact, but lower/upper bounds explain the ancestor constraints more explicitly and adapt better to custom duplicate rules."
        )],
        "trees.inorder-values": [alternative(
            "recursive-inorder", "Recursive inorder traversal", .sameBigO,
            "Visit left subtree, node, then right subtree using the call stack.",
            time: "O(n)", space: "O(h) plus output",
            bestWhen: "Tree height is safe and the traversal order is the main teaching goal.",
            tradeoff: "It is shorter, but a skewed tree can hit Python's recursion limit; the explicit stack is robust."
        )],
        "trees.search-tree-ancestor": [alternative(
            "root-paths", "Compare root-to-node paths", .sameBigO,
            "Find the BST path to each value and return the final shared node.",
            time: "O(h)", space: "O(h)",
            bestWhen: "You also need the paths or want an approach that generalizes to parent-free ordinary trees.",
            tradeoff: "It is easy to visualize but stores two paths; the BST split rule finds the ancestor in O(1) extra space."
        )],
        "trees.preorder-values": [alternative(
            "recursive-preorder", "Recursive preorder traversal", .sameBigO,
            "Append the node, then recursively traverse its left and right children.",
            time: "O(n)", space: "O(h) plus output",
            bestWhen: "The tree is shallow and you want code matching the definition exactly.",
            tradeoff: "It is clearer, but the explicit stack avoids recursion limits and makes visitation state visible."
        )],
        "trees.same-tree": [alternative(
            "queue-pairs", "Compare node pairs breadth-first", .sameBigO,
            "Queue corresponding node pairs and reject any shape or value mismatch as soon as it appears.",
            time: "O(n)", space: "O(w)",
            bestWhen: "Trees may be deep or you want iterative control.",
            tradeoff: "It avoids recursion depth but can hold a wide level; recursive pair comparison is more compact."
        )],
        "trees.diameter": [alternative(
            "two-bfs", "Two farthest-node searches", .constraintDependent,
            "For an undirected tree, search from any node to a farthest node, then search again from there; the second distance is the diameter.",
            time: "O(n)", space: "O(n)",
            bestWhen: "The tree is represented as an undirected adjacency list rather than rooted child links.",
            tradeoff: "It is iterative and elegant for graph-form trees, but requires parent edges; postorder heights fit the app's rooted representation."
        )],

        // MARK: Graphs

        "graphs.island-count": [alternative(
            "bfs-flood", "Breadth-first flood fill", .sameBigO,
            "Start a queue at every unvisited land cell and mark its full component before continuing the grid scan.",
            time: "O(rows · columns)", space: "O(rows · columns) worst case",
            bestWhen: "You want to avoid recursion limits or later need distances from the island seed.",
            tradeoff: "BFS is robust but may store a wide frontier; iterative or recursive DFS expresses component exploration more compactly."
        )],
        "graphs.route-exists": [alternative(
            "breadth-route", "Breadth-first search", .sameBigO,
            "Explore vertices in increasing edge distance with a queue until the destination is found.",
            time: "O(V + E)", space: "O(V)",
            bestWhen: "You may extend the task to shortest unweighted paths.",
            tradeoff: "For mere reachability it offers no asymptotic gain over DFS and can hold a larger frontier."
        )],
        "graphs.course-cycle": [alternative(
            "dfs-colors", "Three-color DFS", .sameBigO,
            "Mark nodes unvisited, visiting, or finished; an edge to a visiting node proves a directed cycle.",
            time: "O(V + E)", space: "O(V)",
            bestWhen: "You want an explicit cycle witness or naturally think in recursion.",
            tradeoff: "It matches Kahn's algorithm, but recursive depth can be unsafe; indegree BFS is iterative and also constructs a topological order."
        )],
        "graphs.bipartite": [alternative(
            "dfs-color", "Depth-first coloring", .sameBigO,
            "Recursively or iteratively assign opposite colors along edges and reject a same-color neighbor.",
            time: "O(V + E)", space: "O(V)",
            bestWhen: "You already have a DFS component traversal scaffold.",
            tradeoff: "It is equivalent to BFS coloring; recursion depth and stack order differ, but the two-color invariant is identical."
        )],
        "graphs.shortest-grid-path": [alternative(
            "bidirectional-bfs", "Bidirectional BFS", .timeSpaceTradeoff,
            "Search simultaneously from the start and goal, stopping when the visited frontiers meet.",
            time: "O(V + E) worst case", space: "O(V)",
            bestWhen: "The grid is large, movement is reversible, and start and goal are both known.",
            tradeoff: "It can explore far fewer cells, but meeting logic and distance accounting are more complex than one-source BFS."
        )],
        "graphs.components": [alternative(
            "union-find", "Union-Find components", .sameBigO,
            "Create a disjoint-set node for every vertex, union edge endpoints, then count distinct roots.",
            time: "O((V + E) α(V))", space: "O(V)",
            bestWhen: "Edges arrive incrementally or many connectivity queries follow.",
            tradeoff: "It is nearly linear and update-friendly, but DFS/BFS is simpler for one static component count."
        )],
        "graphs.flood-fill": [alternative(
            "recursive-fill", "Recursive DFS fill", .sameBigO,
            "Recolor the current cell and recursively visit matching four-directional neighbors.",
            time: "O(rows · columns)", space: "O(component size) stack",
            bestWhen: "Images are small and matching the mathematical flood-fill definition aids clarity.",
            tradeoff: "It is concise but large regions can exceed Python's recursion limit; the explicit queue is safer."
        )],
        "graphs.word-ladder": [alternative(
            "bidirectional-ladder", "Bidirectional BFS", .timeSpaceTradeoff,
            "Expand the smaller frontier from either the start or target word until the two searches meet.",
            time: "O(dictionary · wordLength · alphabet) worst case", space: "O(dictionary)",
            bestWhen: "The dictionary is large and the target is known.",
            tradeoff: "It often cuts the explored state space dramatically, but frontier swapping and meeting distances add complexity."
        )],

        // MARK: Backtracking

        "backtracking.all-subsets": [alternative(
            "iterative-doubling", "Iteratively double the subset list", .sameBigO,
            "For each value, append copies of every existing subset with that value added.",
            time: "O(n · 2ⁿ)", space: "O(n · 2ⁿ) output",
            bestWhen: "You want to avoid recursion and see the power-set growth directly.",
            tradeoff: "It is concise and output-optimal, but explicit choose/skip recursion better teaches the decision tree."
        )],
        "backtracking.target-combinations": [alternative(
            "count-dp", "Dynamic programming for counts only", .timeSpaceTradeoff,
            "If only the number of combinations is required, fill a one-dimensional target-sum DP instead of materializing paths.",
            time: "O(candidates · target)", space: "O(target)",
            bestWhen: "The output can be a count rather than the actual combinations.",
            tradeoff: "It can be much faster, but it solves a weaker problem and cannot reconstruct all requested combinations without extra state."
        )],
        "backtracking.queens-count": [alternative(
            "bitmask-queens", "Represent attacks with bit masks", .sameBigO,
            "Track occupied columns and diagonals as integers; shifts produce the available positions for each row.",
            time: "O(n!) worst case", space: "O(n) recursion",
            bestWhen: "n is large enough that set operations dominate and you are comfortable with bit reasoning.",
            tradeoff: "It is substantially faster in practice but much less transparent than three sets."
        )],
        "backtracking.permutations": [alternative(
            "itertools", "Use itertools.permutations", .sameBigO,
            "Delegate permutation generation to the standard library and convert tuples to the required output form.",
            time: "O(n · n!)", space: "O(n) excluding output",
            bestWhen: "Library use is allowed and production clarity matters.",
            tradeoff: "It is optimized and concise but hides the swap/choice state that interviewers usually want you to explain."
        )],
        "backtracking.word-search": [alternative(
            "visited-set", "Use a visited-coordinate set", .sameBigO,
            "Keep the board unchanged and track cells in the current path with a set.",
            time: "O(rows · columns · 4ˡ)", space: "O(l)",
            bestWhen: "The input must be immutable or concurrent readers may inspect it.",
            tradeoff: "It is safer semantically, but in-place sentinel marking has smaller constant factors and avoids hash lookups."
        )],
        "backtracking.phone-letters": [alternative(
            "product", "Cartesian product with itertools", .sameBigO,
            "Map each digit to its letters and use itertools.product to enumerate one choice from every group.",
            time: "O(output · digits)", space: "O(digits) excluding output",
            bestWhen: "You want concise production Python and library enumeration is acceptable.",
            tradeoff: "It states the combinatorics cleanly but hides the backtracking template and makes custom pruning harder."
        )],
        "backtracking.generate-parentheses": [alternative(
            "catalan-filter", "Generate all bit choices, then filter", .simplerButSlower,
            "Enumerate every length-2n parenthesis string and retain those whose running balance never becomes negative and ends at zero.",
            time: "O(4ⁿ · n)", space: "O(n)",
            bestWhen: "You need a brute-force oracle for very small n.",
            tradeoff: "The validator is simple, but constrained backtracking avoids constructing the vast majority of invalid strings."
        )],
        "backtracking.palindrome-partitions": [alternative(
            "palindrome-table", "Precompute palindrome ranges", .timeSpaceTradeoff,
            "Build a boolean table for every palindromic substring, then let backtracking test a candidate cut in O(1).",
            time: "O(n² + output)", space: "O(n²)",
            bestWhen: "Repeated palindrome slicing dominates or the input is long enough to justify preprocessing.",
            tradeoff: "It speeds repeated checks but uses quadratic memory; direct checks are simpler and can be adequate for short strings."
        )],

        // MARK: Dynamic programming

        "dp.climb-ways": [alternative(
            "memo-recursion", "Top-down memoization", .sameBigO,
            "Define ways(step) recursively and cache each step after combining the previous two states.",
            time: "O(n)", space: "O(n)",
            bestWhen: "The recurrence is easier to discover recursively or many states may be unreachable.",
            tradeoff: "It mirrors the recurrence but uses cache and call-stack memory; the two-variable bottom-up solution is O(1) space."
        )],
        "dp.max-non-adjacent": [alternative(
            "dp-array", "Store the full DP array", .sameBigO,
            "Let dp[i] record the best result through index i, choosing between skipping and taking the current value.",
            time: "O(n)", space: "O(n)",
            bestWhen: "You need to reconstruct which values were selected or want every state visible for debugging.",
            tradeoff: "It is easier to inspect, but two rolling states are enough when only the optimum value is required."
        )],
        "dp.fewest-coins": [alternative(
            "amount-bfs", "Breadth-first search over amounts", .sameBigO,
            "Treat each reachable amount as a node and each coin addition as an unweighted edge; the first visit to target uses the fewest coins.",
            time: "O(target · coins)", space: "O(target)",
            bestWhen: "The shortest-path interpretation is clearer or you want an early exit once target is reached.",
            tradeoff: "It matches DP asymptotically but queue/set overhead is higher; bottom-up DP is usually simpler and cache-friendly."
        )],
        "dp.unique-paths": [alternative(
            "combinatorics", "Compute a binomial coefficient", .timeSpaceTradeoff,
            "Every route is an ordering of rows-1 downward moves and columns-1 rightward moves, so choose where one move type occurs.",
            time: "O(min(rows, columns))", space: "O(1)",
            bestWhen: "The grid has no obstacles and exact integer arithmetic is available.",
            tradeoff: "It is faster and elegant but less general; DP adapts immediately to blocked cells, weights, or changed movement rules."
        )],
        "dp.longest-common-subsequence": [alternative(
            "top-down-lcs", "Memoized index-pair recursion", .sameBigO,
            "Recursively compare the current characters and cache the answer for each pair of indices.",
            time: "O(n · m)", space: "O(n · m)",
            bestWhen: "You want the recurrence to read directly from the mathematical definition.",
            tradeoff: "It may skip unreachable states, but function-call overhead and recursion depth are higher than bottom-up iteration."
        )],
        "dp.min-climbing-cost": [alternative(
            "cost-array", "Keep every minimum-cost state", .sameBigO,
            "Store the cheapest cost to arrive at each step before choosing the final one of the last two states.",
            time: "O(n)", space: "O(n)",
            bestWhen: "You need to reconstruct the chosen steps or inspect the transition table.",
            tradeoff: "The state table is pedagogically useful, but the recurrence depends on only two previous values."
        )],
        "dp.decode-ways": [alternative(
            "memo-decode", "Top-down decoding", .sameBigO,
            "At each string index, recurse by consuming one valid digit or two valid digits and memoize the suffix count.",
            time: "O(n)", space: "O(n)",
            bestWhen: "You want invalid leading-zero and two-digit rules localized in a recursive state.",
            tradeoff: "It closely matches the decision tree but uses recursion/cache memory; rolling DP needs O(1) space."
        )],
        "dp.longest-palindrome-subsequence": [alternative(
            "lcs-reverse", "LCS against the reversed string", .sameBigO,
            "Compute the longest common subsequence between text and text[::-1].",
            time: "O(n²)", space: "O(n²), or O(n) optimized",
            bestWhen: "You already have a trusted LCS implementation and want code reuse.",
            tradeoff: "It is concise conceptually but obscures the palindrome-specific interval recurrence and allocates the reversed string."
        )],

        // MARK: Greedy

        "greedy.reach-end": [alternative(
            "backward-goal", "Move the goal backward", .sameBigO,
            "Scan from right to left; whenever an index can reach the current goal, make that index the new goal.",
            time: "O(n)", space: "O(1)",
            bestWhen: "The proof feels clearer as a chain of positions that can reach the end.",
            tradeoff: "It is equivalent to tracking farthest reach, but it does not naturally expose the earliest point where forward progress stalls."
        )],
        "greedy.max-meetings": [alternative(
            "weighted-dp", "Interval scheduling DP", .simplerButSlower,
            "Sort meetings and compute the best compatible count ending at or before each meeting.",
            time: "O(n²) directly", space: "O(n)",
            bestWhen: "Meetings may later have different values or profits.",
            tradeoff: "It generalizes to weighted scheduling, but equal-value meeting count has the stronger earliest-finish greedy solution."
        )],
        "greedy.gas-start": [alternative(
            "try-each-station", "Simulate every start", .simplerButSlower,
            "For each station, drive a full circuit until fuel becomes negative or the route succeeds.",
            time: "O(n²)", space: "O(1)",
            bestWhen: "You need a small-input oracle or want to observe why failed prefixes eliminate starts.",
            tradeoff: "It is exhaustive but repeats work; the greedy proof collapses all failed starts into one O(n) scan."
        )],
        "greedy.minimum-arrows": [alternative(
            "sort-start-intersection", "Maintain the shared overlap", .sameBigO,
            "Sort by start and keep the current group's common intersection; fire an arrow when the next interval no longer overlaps it.",
            time: "O(n log n)", space: "O(1) excluding sort",
            bestWhen: "Thinking in explicit overlap groups is more intuitive than earliest endpoints.",
            tradeoff: "It is equivalent but carries two intersection bounds; sorting by end needs only the last arrow position."
        )],
        "greedy.partition-labels": [alternative(
            "interval-merge", "Merge each character's span", .sameBigO,
            "Turn every character into a first-to-last interval, merge overlapping intervals, and return merged lengths.",
            time: "O(n + k log k)", space: "O(k)",
            bestWhen: "You want to connect the problem explicitly to interval merging.",
            tradeoff: "For bounded alphabets it is effectively linear, but the direct last-occurrence scan is simpler and avoids sorting spans."
        )],
        "greedy.stock-profit": [alternative(
            "suffix-maximum", "Precompute future sell prices", .sameBigO,
            "Build the maximum price from each index to the end, then evaluate buying at every day.",
            time: "O(n)", space: "O(n)",
            bestWhen: "You also need the best future sell value for other queries.",
            tradeoff: "It makes every candidate profit explicit, but one running minimum finds the same answer in O(1) space."
        )],
        "greedy.candy": [alternative(
            "slope-count", "Count increasing and decreasing slopes", .sameBigO,
            "Process rating slopes in one pass, using triangular-number sums for rising and falling runs.",
            time: "O(n)", space: "O(1)",
            bestWhen: "Auxiliary memory is tightly constrained and you can justify peak correction carefully.",
            tradeoff: "It improves space over two arrays but is much harder to derive and debug, especially around equal ratings and peaks."
        )],
        "greedy.task-scheduler": [alternative(
            "frequency-formula", "Use the idle-slot formula", .timeSpaceTradeoff,
            "Arrange the most frequent task into frames and compute max(task count, (maxFrequency-1)·(cooldown+1)+numberOfMaxTasks).",
            time: "O(n + k)", space: "O(k)",
            bestWhen: "You only need the minimum length, not the actual task order.",
            tradeoff: "It is faster and compact, but the proof is less operational; heap simulation generalizes to producing a schedule."
        )],

        // MARK: Advanced synthesis

        "advanced.longest-increasing": [alternative(
            "quadratic-lis", "DP ending at every index", .simplerButSlower,
            "Let dp[i] be the longest increasing subsequence ending at i and examine every earlier smaller value.",
            time: "O(n²)", space: "O(n)",
            bestWhen: "You need to reconstruct a subsequence or are first deriving the state transition.",
            tradeoff: "It is transparent and adaptable, but patience-sorting tails reduce time to O(n log n)."
        )],
        "advanced.edit-distance": [alternative(
            "memo-edit", "Memoized suffix recursion", .sameBigO,
            "Recursively align suffixes, branching to insert, delete, or replace only when characters differ, and cache index pairs.",
            time: "O(n · m)", space: "O(n · m)",
            bestWhen: "You want the recurrence to follow the edit choices directly.",
            tradeoff: "It may feel clearer, but bottom-up iteration avoids recursion depth and can compress memory to one row."
        )],
        "advanced.median-sorted": [alternative(
            "merge-until-middle", "Merge only to the middle", .simplerButSlower,
            "Advance two merge pointers until reaching the one or two middle positions without materializing the complete merge.",
            time: "O(n + m)", space: "O(1)",
            bestWhen: "Inputs are moderate and implementation reliability matters more than logarithmic time.",
            tradeoff: "It is much easier to verify, but the partition binary search is required for O(log min(n,m))."
        )],
        "advanced.word-break": [alternative(
            "memo-segmentation", "Top-down suffix search", .sameBigO,
            "From each index, try dictionary words that match the next prefix and memoize whether the remaining suffix can be segmented.",
            time: "O(n²) typical", space: "O(n)",
            bestWhen: "Prefix matching and early success make many states unreachable.",
            tradeoff: "It can prune naturally but uses recursion and substring work; bottom-up DP has predictable iteration."
        )],
        "advanced.maximum-product-subarray": [alternative(
            "prefix-suffix-products", "Scan products from both ends", .sameBigO,
            "Multiply a running prefix and suffix, resetting after zeros; the best product appears in one direction after excluding one negative edge.",
            time: "O(n)", space: "O(1)",
            bestWhen: "You want a compact alternative and only the maximum value is required.",
            tradeoff: "It works but is less explanatory around sign changes; tracking both current maximum and minimum states generalizes more clearly."
        )],
        "advanced.kth-largest": [alternative(
            "quickselect", "Quickselect in place", .timeSpaceTradeoff,
            "Partition around pivots until the target order-statistic index reaches its final position.",
            time: "O(n) expected, O(n²) worst case", space: "O(1) iterative",
            bestWhen: "You have one selection query, can mutate the input, and want expected linear time.",
            tradeoff: "It can beat a heap, but performance is nondeterministic and implementation is easier to get wrong."
        )],
        "advanced.merge-sorted-lists": [alternative(
            "divide-conquer-merge", "Merge lists in balanced pairs", .sameBigO,
            "Repeatedly merge list pairs so each value participates in only log k merge levels.",
            time: "O(N log k)", space: "O(N) output",
            bestWhen: "You want no heap dependency or merges can run in parallel by level.",
            tradeoff: "It matches heap asymptotics and has sequential memory access, but is less suitable when lists arrive as a stream."
        )],
        "advanced.longest-valid-parentheses": [alternative(
            "two-direction-counters", "Scan with left/right counters", .sameBigO,
            "Scan left-to-right resetting when closes exceed opens, then right-to-left resetting for the symmetric imbalance.",
            time: "O(n)", space: "O(1)",
            bestWhen: "You only need the maximum length and want constant auxiliary space.",
            tradeoff: "It is space-optimal but less intuitive and cannot directly recover the substring boundaries as naturally as the index stack."
        )],

        // MARK: Mastery blueprints · core families

        "mastery.arrays-hashing.missing-number": [alternative(
            "xor-missing", "XOR indices and values", .sameBigO,
            "XOR every index from 0 through n with every observed value; paired values cancel and leave the missing number.",
            time: "O(n)", space: "O(1)",
            bestWhen: "You want to avoid arithmetic overflow in fixed-width languages or practice XOR cancellation.",
            tradeoff: "It has the same optimal bounds but is less immediately readable than expected sum minus actual sum."
        )],
        "mastery.arrays-hashing.majority": [alternative(
            "counter-majority", "Count every value", .timeSpaceTradeoff,
            "Use Counter or a dictionary and return the value whose count exceeds half the input length.",
            time: "O(n)", space: "O(k)",
            bestWhen: "You also need frequencies or the majority guarantee must be verified explicitly.",
            tradeoff: "It is straightforward but loses Boyer-Moore's O(1) space advantage."
        )],
        "mastery.arrays-hashing.target-subarrays": [alternative(
            "quadratic-prefix", "Enumerate prefix-sum pairs", .simplerButSlower,
            "Build prefix sums and test the sum of every start/end interval.",
            time: "O(n²)", space: "O(n)",
            bestWhen: "You need a clear oracle for small tests or are deriving the prefix difference identity.",
            tradeoff: "It is easy to verify but does not scale; frequency-counted prefixes aggregate all valid starts in O(n)."
        )],
        "mastery.two-pointers.merge-sorted": [alternative(
            "heapq-merge", "Use heapq.merge", .sameBigO,
            "Delegate the lazy two-way merge to heapq.merge and materialize its iterator as a list.",
            time: "O(n + m)", space: "O(n + m) output",
            bestWhen: "Library use is allowed and production concision matters.",
            tradeoff: "It is tested and lazy, but hides the two-pointer invariant the exercise teaches."
        )],
        "mastery.two-pointers.subsequence": [alternative(
            "iterator-membership", "Consume a text iterator", .sameBigO,
            "Create iter(text) and check all(character in iterator for character in candidate); membership resumes from the prior iterator position.",
            time: "O(n)", space: "O(1)",
            bestWhen: "You understand Python iterator consumption and want a compact idiom.",
            tradeoff: "It is elegant but surprising to many readers and much harder to translate or explain in an interview."
        )],
        "mastery.two-pointers.pairs-below": [alternative(
            "bisect-partners", "Binary-search each partner boundary", .simplerButSlower,
            "For every left index, bisect the suffix for the first value that would make the sum reach target.",
            time: "O(n log n)", space: "O(1)",
            bestWhen: "You are practicing boundary searches or answering isolated queries against a reusable sorted structure.",
            tradeoff: "It is locally simple but slower than counting an entire valid pointer range at once."
        )],
        "mastery.sliding-window.max-vowels": [alternative(
            "vowel-prefix", "Prefix-sum vowel indicators", .sameBigO,
            "Convert each character to 0/1, build prefix sums, and subtract endpoints for every fixed window.",
            time: "O(n)", space: "O(n)",
            bestWhen: "Many different window-size queries will reuse the same text.",
            tradeoff: "It supports arbitrary range queries, but a single rolling window needs only O(1) extra space."
        )],
        "mastery.sliding-window.minimum-positive": [alternative(
            "positive-prefix-bisect", "Increasing prefixes plus bisect", .simplerButSlower,
            "Build increasing prefix sums and binary-search the first endpoint reaching startPrefix + target for each start.",
            time: "O(n log n)", space: "O(n)",
            bestWhen: "You want to connect positivity with monotone binary search.",
            tradeoff: "It is valid but the expand/shrink window is faster and uses constant auxiliary memory."
        )],
        "mastery.sliding-window.k-distinct": [alternative(
            "last-position-eviction", "Evict the least-recent distinct value", .sameBigO,
            "Store each character's last index; when distinct count exceeds k, remove the character with the smallest last index and jump left.",
            time: "O(n · k) with min, O(n log k) with heap", space: "O(k)",
            bestWhen: "k is tiny or boundary jumps make the state easier to understand.",
            tradeoff: "It can skip removals, but finding the oldest category adds work; frequency-based shrinking stays strictly O(n)."
        )],
        "mastery.stack.simplify-path": [alternative(
            "pure-posix-path", "Use a POSIX path normalizer", .constraintDependent,
            "A standard-library POSIX path normalizer can collapse separators, dots, and parent components.",
            time: "O(n)", space: "O(n)",
            bestWhen: "You are normalizing real paths under exactly the library's documented semantics.",
            tradeoff: "Library behavior for leading slashes and platform paths may differ from interview rules; the explicit stack is portable and auditable."
        )],
        "mastery.stack.next-smaller": [alternative(
            "jump-answers", "Jump through known answers", .sameBigO,
            "Scan right-to-left and follow previously computed next-smaller links until a smaller value is found.",
            time: "O(n) amortized with careful compression", space: "O(n) output",
            bestWhen: "You want to encode the monotonic structure in the output rather than an explicit stack.",
            tradeoff: "It can save a separate stack but is harder to prove and easier to break around equal values."
        )],
        "mastery.stack.validate-sequences": [alternative(
            "reuse-pushed", "Reuse the pushed array as stack storage", .sameBigO,
            "Overwrite the processed prefix of pushed with the simulated stack and keep a stack-size pointer.",
            time: "O(n)", space: "O(1) auxiliary",
            bestWhen: "Mutation is allowed and auxiliary memory must be minimized.",
            tradeoff: "It improves space but destroys the input and is less readable than a normal list stack."
        )],
        "mastery.binary-search.lower-bound": [alternative(
            "stdlib-bisect-left", "Use bisect_left", .sameBigO,
            "bisect_left implements exactly the first-index-with-value-at-least-target contract.",
            time: "O(log n)", space: "O(1)",
            bestWhen: "You are writing production Python and custom comparison behavior is unnecessary.",
            tradeoff: "It is the ideal library solution but hides the half-open search invariant being practiced."
        )],
        "mastery.binary-search.kth-missing": [alternative(
            "linear-missing", "Walk values and missing gaps", .simplerButSlower,
            "Scan the sorted values while accumulating gaps until the gap containing the k-th missing number is reached.",
            time: "O(n)", space: "O(1)",
            bestWhen: "n is small or you want the missing-count formula to be explicit before binary search.",
            tradeoff: "It is easy to reason about but gives up logarithmic search over the monotone missing-count function."
        )],
        "mastery.binary-search.split-largest": [alternative(
            "partition-dp", "DP over split positions", .timeSpaceTradeoff,
            "Use prefix sums and let dp[parts][end] minimize the largest segment across every previous cut.",
            time: "O(parts · n²)", space: "O(parts · n)",
            bestWhen: "Values may be negative or you need to reconstruct the partition boundaries.",
            tradeoff: "It is far slower, but the greedy feasibility used by binary search relies on nonnegative values and does not retain cuts automatically."
        )],
        "mastery.intervals.union-length": [alternative(
            "coverage-events", "Signed boundary sweep", .sameBigO,
            "Sort start/end events, add distance whenever active coverage is positive, and update the active count at each boundary.",
            time: "O(n log n)", space: "O(n)",
            bestWhen: "You also need overlap depth or weighted coverage information.",
            tradeoff: "It is more general, but event ordering is subtler than merging sorted intervals."
        )],
        "mastery.intervals.max-overlap": [alternative(
            "end-heap", "Track active end times", .sameBigO,
            "Sort by start, discard ended intervals from a min-heap, and record the largest heap size.",
            time: "O(n log n)", space: "O(n)",
            bestWhen: "You may later assign resources or need active interval identities.",
            tradeoff: "It supports richer scheduling output, while separate start/end pointers have smaller constants for the count alone."
        )],
        "mastery.intervals.carpool": [alternative(
            "difference-road", "Difference array over locations", .constraintDependent,
            "When locations have a small bounded maximum, add passengers at pickup and subtract at drop-off in a location-indexed array.",
            time: "O(trips + maxLocation)", space: "O(maxLocation)",
            bestWhen: "The coordinate range is small and dense.",
            tradeoff: "It can be faster than sorting events, but wastes memory or becomes impossible when coordinates are large and sparse."
        )],
        "mastery.trees.leaf-count": [alternative(
            "leaf-bfs", "Count leaves breadth-first", .sameBigO,
            "Traverse nodes with a queue and increment the count for nodes with no children.",
            time: "O(n)", space: "O(w)",
            bestWhen: "Trees may be too deep for recursion or level data is also useful.",
            tradeoff: "It avoids call-stack limits but may store a wide frontier; DFS uses O(h) memory."
        )],
        "mastery.trees.right-view": [alternative(
            "right-first-dfs", "Right-first DFS", .sameBigO,
            "Visit right children first and record the first node encountered at every depth.",
            time: "O(n)", space: "O(h)",
            bestWhen: "The tree is narrow/deep or you want no breadth queue.",
            tradeoff: "It is elegant but recursion depth can fail; BFS makes the last node of each level explicit."
        )],
        "mastery.trees.max-path": [alternative(
            "iterative-postorder", "Explicit postorder stack", .sameBigO,
            "Use visited flags on a stack, then compute each node's downward gain after both children have been processed.",
            time: "O(n)", space: "O(n)",
            bestWhen: "Tree depth may exceed Python's recursion limit.",
            tradeoff: "It is robust but requires a gain map and traversal-state bookkeeping; recursion mirrors postorder naturally."
        )],
        "mastery.graphs.provinces": [alternative(
            "province-dsu", "Union-Find", .sameBigO,
            "Union every connected pair in the matrix and count unique roots afterward.",
            time: "O(n² α(n))", space: "O(n)",
            bestWhen: "Connections arrive incrementally or follow-up connectivity queries are expected.",
            tradeoff: "It is update-friendly, but DFS/BFS is simpler for one static adjacency matrix."
        )],
        "mastery.graphs.network-delay": [alternative(
            "bellman-ford", "Bellman-Ford relaxation", .simplerButSlower,
            "Relax every directed edge up to V-1 times, stopping early when no distance changes.",
            time: "O(V · E)", space: "O(V)",
            bestWhen: "Edges may have negative weights or you want a simpler shortest-path oracle.",
            tradeoff: "It handles a broader weight model but is much slower than Dijkstra for this problem's nonnegative delays."
        )],
        "mastery.graphs.safe-nodes": [alternative(
            "reverse-topology", "Reverse-graph topological elimination", .sameBigO,
            "Start from terminal nodes, remove their outgoing influence through reversed edges, and mark every node whose outdegree reaches zero safe.",
            time: "O(V + E)", space: "O(V + E)",
            bestWhen: "You prefer iterative processing or need to avoid recursive color-state DFS.",
            tradeoff: "It is recursion-safe and constructive, but building the reversed graph uses extra memory."
        )],
        "mastery.backtracking.combinations": [alternative(
            "itertools-combinations", "Use itertools.combinations", .sameBigO,
            "Generate the size-k combinations with the standard library and convert tuples if the output requires lists.",
            time: "O(k · C(n,k))", space: "O(k) excluding output",
            bestWhen: "Library use is allowed and no custom pruning or constraints are needed.",
            tradeoff: "It is concise and optimized but hides the choose/skip recursion and pruning bounds."
        )],
        "mastery.backtracking.restore-address": [alternative(
            "three-cut-loops", "Enumerate the three cut positions", .sameBigO,
            "Because an address has exactly four short parts, loop over the bounded lengths of the first three parts and validate the fourth.",
            time: "O(1) bounded search", space: "O(1) excluding output",
            bestWhen: "The format is fixed at four segments and you want minimal recursion machinery.",
            tradeoff: "It is compact for this exact format, while backtracking generalizes to a variable number of segments or different grammars."
        )],
        "mastery.backtracking.letter-cases": [alternative(
            "case-bitmask", "Bit-mask the letter choices", .sameBigO,
            "Collect letter positions, then use each mask from 0 to 2^letters-1 to choose lower or upper case.",
            time: "O(output · n)", space: "O(n) excluding output",
            bestWhen: "You want iterative enumeration and the independent binary choices are explicit.",
            tradeoff: "It avoids recursion but repeatedly copies/transforms strings; backtracking updates one path incrementally."
        )],
        "mastery.dynamic-programming.knapsack": [alternative(
            "memo-knapsack", "Top-down item/capacity memoization", .sameBigO,
            "Recursively choose whether to skip or take each item and cache the result for (index, remainingCapacity).",
            time: "O(items · capacity)", space: "O(items · capacity)",
            bestWhen: "Many capacity states are unreachable or the choice recurrence is easier to derive recursively.",
            tradeoff: "It may compute fewer states but uses more memory and call overhead than the one-dimensional bottom-up update."
        )],
        "mastery.dynamic-programming.equal-partition": [alternative(
            "reachable-bitset", "Represent reachable sums as bits", .timeSpaceTradeoff,
            "Keep an integer bitset whose set bits are reachable sums and update it with bits |= bits << number.",
            time: "O(n · target / wordSize)", space: "O(target / wordSize)",
            bestWhen: "Values are nonnegative and Python's arbitrary-precision bit operations are allowed.",
            tradeoff: "It is extremely fast and compact in practice but less portable and less transparent than a boolean DP array."
        )],
        "mastery.dynamic-programming.max-square": [alternative(
            "histogram-square", "Row histograms plus monotonic stacks", .sameBigO,
            "Treat each row as histogram heights and find the largest square supported by every bar's span.",
            time: "O(rows · columns)", space: "O(columns)",
            bestWhen: "You already need histogram spans or are connecting matrix and stack patterns.",
            tradeoff: "It matches optimal time but is much more complex than the local three-neighbor DP recurrence."
        )],
        "mastery.greedy.cookies": [alternative(
            "frequency-buckets", "Match frequency buckets", .constraintDependent,
            "When greed and resource sizes lie in a small integer range, count both and match sizes with two bucket pointers.",
            time: "O(n + range)", space: "O(range)",
            bestWhen: "Values are bounded and sorting cost is material.",
            tradeoff: "It can beat O(n log n) sorting but depends on a small dense value range and uses less familiar code."
        )],
        "mastery.greedy.minimum-jumps": [alternative(
            "jump-dp", "Minimum jumps to every index", .simplerButSlower,
            "Store the fewest jumps needed to reach each position and relax every destination reachable from it.",
            time: "O(n²)", space: "O(n)",
            bestWhen: "You are deriving correctness, need path reconstruction, or jump rules will gain weights.",
            tradeoff: "It is explicit and general, but the interval-frontier greedy solution collapses each BFS layer into O(n) total work."
        )],
        "mastery.greedy.reorganize": [alternative(
            "even-odd-placement", "Place the most frequent characters first", .constraintDependent,
            "Sort characters by frequency, fill even output positions first, then odd positions.",
            time: "O(n + k log k)", space: "O(n + k)",
            bestWhen: "You only need one valid arrangement and can reason from the max-frequency feasibility condition.",
            tradeoff: "It can be simpler than repeated heap operations, but the placement proof and tie behavior are less intuitive; a heap generalizes better."
        )],
        "mastery.advanced.circular-sum": [alternative(
            "prefix-suffix", "Combine best prefix and suffix sums", .sameBigO,
            "Precompute the best suffix sum from each index and combine it with a growing prefix to represent wrapped subarrays.",
            time: "O(n)", space: "O(n)",
            bestWhen: "You want the wrapped structure shown explicitly or need candidate boundaries.",
            tradeoff: "It is direct but allocates an array; max-normal versus total-minus-min compresses the same reasoning to O(1) state."
        )],
        "mastery.advanced.wildcard": [alternative(
            "memo-wildcard", "Memoized pattern/text indices", .sameBigO,
            "Recursively match suffixes and branch when '*' consumes zero characters or one more character, caching index pairs.",
            time: "O(n · m)", space: "O(n · m)",
            bestWhen: "You want wildcard semantics to map directly onto recursive choices.",
            tradeoff: "It is easier to derive but uses more memory and recursion; bottom-up or greedy specialized matching can be leaner."
        )],
        "mastery.advanced.distinct-subsequences": [alternative(
            "memo-subsequences", "Top-down source/target recursion", .sameBigO,
            "At each pair of indices, skip the source character or also match it when characters agree, then memoize the count.",
            time: "O(n · m)", space: "O(n · m)",
            bestWhen: "You want the include/skip recurrence to be explicit.",
            tradeoff: "It may avoid unused states, but one-dimensional bottom-up DP uses O(m) memory and avoids recursion."
        )],

        // MARK: Mastery blueprints · additional modules

        "mastery.linked-lists.middle-node": [alternative(
            "collect-nodes", "Collect nodes, then index the middle", .timeSpaceTradeoff,
            "Traverse once into an array and return the node at len(nodes) // 2.",
            time: "O(n)", space: "O(n)",
            bestWhen: "You will need random access to nodes again or want the simplest correctness argument.",
            tradeoff: "It is straightforward but spends linear memory; slow/fast pointers find the same node in O(1) space."
        )],
        "mastery.linked-lists.reverse-values": [alternative(
            "collect-reverse", "Collect values and reverse them", .sameBigO,
            "Read values in traversal order and return values[::-1].",
            time: "O(n)", space: "O(n) output",
            bestWhen: "The task asks only for reversed values, not rewired nodes.",
            tradeoff: "It is concise and appropriate for immutable nodes, but it does not teach pointer reversal or support returning a reversed list structure."
        )],
        "mastery.linked-lists.cycle-entry": [alternative(
            "visited-nodes", "Store visited node identities", .timeSpaceTradeoff,
            "Walk next links while recording each node; the first repeated node is the cycle entry.",
            time: "O(n)", space: "O(n)",
            bestWhen: "Clarity, debugging information, or cycle-path reconstruction matters more than memory.",
            tradeoff: "It is simpler than Floyd's proof but loses the O(1)-space advantage."
        )],
        "mastery.queues-heaps.kth-smallest": [alternative(
            "quickselect-smallest", "Quickselect", .timeSpaceTradeoff,
            "Partition values until index k-1 contains the same value it would have after sorting.",
            time: "O(n) expected, O(n²) worst case", space: "O(1) iterative",
            bestWhen: "There is one query, mutation is allowed, and expected linear time is desirable.",
            tradeoff: "It can outperform a heap but has unstable worst-case time and more implementation risk."
        )],
        "mastery.queues-heaps.closest-points": [alternative(
            "sort-all-points", "Sort every point by distance", .simplerButSlower,
            "Sort with a deterministic (distance, coordinates) key and take the first k.",
            time: "O(n log n)", space: "O(n)",
            bestWhen: "k is large, deterministic ordering is important, or simplicity dominates.",
            tradeoff: "It is easy to get right but does unnecessary ordering when k is much smaller than n."
        )],
        "mastery.queues-heaps.running-medians": [alternative(
            "bisect-list", "Maintain one sorted list", .simplerButSlower,
            "Insert each incoming value with bisect.insort and read the middle element or pair.",
            time: "O(n²) total", space: "O(n)",
            bestWhen: "Streams are small and the simplest reliable implementation is preferred.",
            tradeoff: "Median lookup is trivial, but list insertion shifts O(n) elements; two heaps reduce each update to O(log n)."
        )],
        "mastery.tries-strings.kmp-index": [alternative(
            "rabin-karp", "Rolling-hash substring search", .timeSpaceTradeoff,
            "Hash the pattern and each equal-length text window, checking characters only when hashes match.",
            time: "O(n + m) expected, O(n · m) worst case", space: "O(1)",
            bestWhen: "You need to search many fixed-length patterns or rolling hashes are already available.",
            tradeoff: "It is often concise and fast, but collisions require verification and lose KMP's deterministic linear guarantee."
        )],
        "mastery.tries-strings.prefix-counts": [alternative(
            "prefix-hash", "Hash every observed prefix", .timeSpaceTradeoff,
            "For each word, increment a dictionary entry for each of its prefixes; answer queries with direct lookup.",
            time: "O(total characters) construction, depending on slicing", space: "O(total distinct prefixes · prefix length)",
            bestWhen: "The dataset is static, modest, and implementation simplicity matters.",
            tradeoff: "Queries are simple, but repeated prefix strings use much more memory than shared trie nodes."
        )],
        "mastery.tries-strings.unique-prefixes": [alternative(
            "sorted-neighbor-lcp", "Compare sorted neighbors", .timeSpaceTradeoff,
            "Sort words; a word's shortest unique prefix is one longer than its maximum common prefix with its immediate neighbors.",
            time: "O(total characters + n log n)", space: "O(n)",
            bestWhen: "All words are known in advance and lexicographic sorting is convenient.",
            tradeoff: "It avoids a trie and can be memory-friendly, but does not support efficient online insertions or prefix queries."
        )],
        "mastery.bit-math.popcount": [alternative(
            "int-bit-count", "Use int.bit_count()", .sameBigO,
            "Python exposes the population count directly as number.bit_count().",
            time: "O(number of machine words)", space: "O(1)",
            bestWhen: "You are writing production Python and library methods are allowed.",
            tradeoff: "It is clearer and highly optimized but hides Brian Kernighan's lowest-set-bit identity."
        )],
        "mastery.bit-math.single-number": [alternative(
            "counter-single", "Count occurrences", .timeSpaceTradeoff,
            "Use Counter and return the value with frequency one.",
            time: "O(n)", space: "O(k)",
            bestWhen: "The exact pairing guarantee may change or you need validation/frequencies.",
            tradeoff: "It is general and obvious but loses XOR's O(1) space and cancellation elegance."
        )],
        "mastery.bit-math.mod-power": [alternative(
            "builtin-mod-pow", "Use three-argument pow", .sameBigO,
            "Python's pow(base, exponent, modulus) performs efficient modular exponentiation without creating the full power.",
            time: "O(log exponent)", space: "O(1) conceptually",
            bestWhen: "You need robust, optimized production behavior for large integers.",
            tradeoff: "It is the practical best choice but hides exponentiation by squaring, which is the learning objective."
        )],
        "mastery.union-find.redundant-edge": [alternative(
            "path-before-edge", "Search for an existing path", .simplerButSlower,
            "Before adding each edge, run DFS/BFS to see whether its endpoints are already connected.",
            time: "O(E · (V + E))", space: "O(V + E)",
            bestWhen: "Graphs are tiny or you need the actual pre-existing path that forms the cycle.",
            tradeoff: "It returns richer evidence but repeats traversal; Union-Find answers connectivity nearly instantly."
        )],
        "mastery.union-find.component-stream": [alternative(
            "recount-components", "Rebuild graph components after each edge", .simplerButSlower,
            "Add the edge to an adjacency list, then traverse the whole graph to recount components.",
            time: "O(E · (V + E))", space: "O(V + E)",
            bestWhen: "You need a correctness oracle or component member lists after every update.",
            tradeoff: "It is direct but wasteful; Union-Find updates the count in almost constant amortized time."
        )],
        "mastery.union-find.mst-cost": [alternative(
            "prim-mst", "Prim's frontier heap", .sameBigO,
            "Grow one connected tree by repeatedly choosing the cheapest edge leaving the visited vertices.",
            time: "O(E log V)", space: "O(V + E)",
            bestWhen: "The graph is already in adjacency-list form or is dense around a starting component.",
            tradeoff: "It matches Kruskal asymptotically; Prim grows by vertices, while Kruskal's edge sort plus Union-Find is often simpler for an edge list."
        )],
        "mastery.advanced-data-structures.fenwick-prefix": [alternative(
            "segment-tree", "Segment tree", .sameBigO,
            "Store combined range values in a binary tree so point updates and prefix/range queries both visit O(log n) nodes.",
            time: "O(log n) update/query", space: "O(n)",
            bestWhen: "You expect richer associative queries, range updates, or custom node aggregates.",
            tradeoff: "It is more flexible but uses more memory and code; a Fenwick tree is smaller and faster for invertible prefix sums."
        )],
        "mastery.advanced-data-structures.range-add": [alternative(
            "offline-difference", "Apply an offline difference array", .constraintDependent,
            "Record +delta at each range start and -delta after each end, then take one prefix pass after all updates.",
            time: "O(updates + n)", space: "O(n)",
            bestWhen: "All updates are known before any point query must be answered.",
            tradeoff: "It is simpler and faster offline, but cannot interleave updates and queries as the Fenwick-based method can."
        )],
        "mastery.advanced-data-structures.lru": [alternative(
            "ordered-dict", "Use collections.OrderedDict", .sameBigO,
            "Store key/value pairs in OrderedDict, moving touched keys to the end and popping the oldest item on overflow.",
            time: "O(1) average per operation", space: "O(capacity)",
            bestWhen: "Standard-library use is allowed and production concision matters.",
            tradeoff: "It is reliable and short but hides the hash-map plus doubly-linked-list design interviewers often want demonstrated."
        )],
    ]
}
