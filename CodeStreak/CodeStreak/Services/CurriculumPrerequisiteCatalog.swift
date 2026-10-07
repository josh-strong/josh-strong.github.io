import Foundation

/// The single source of truth for what a learner must know before attempting
/// each problem. Keeping this explicit prevents a broad module label from
/// hiding a genuinely new algorithm inside a later exercise.
enum ProblemPrerequisiteCatalog {
    static func techniqueIDs(for problemID: String) -> [String] {
        TechniqueDependencyCatalog.expandedTechniqueIDs(from: directTechniqueIDs(for: problemID))
    }

    /// The algorithms selected specifically for this problem. `techniqueIDs`
    /// expands these through the dependency graph so the learner also sees the
    /// foundations those algorithms rely on.
    static func directTechniqueIDs(for problemID: String) -> [String] {
        entries[problemID] ?? []
    }

    static var coveredProblemIDs: Set<String> { Set(entries.keys) }
    static var referencedTechniqueIDs: Set<String> {
        Set(entries.keys.flatMap { techniqueIDs(for: $0) })
    }

    private static let entries: [String: [String]] = [
        // Arrays & Hashing
        "arrays.sum-positive": ["linear-accumulator"],
        "arrays.pair-indices": ["hash-map"],
        "arrays.longest-consecutive": ["hash-set", "sequence-start-expansion"],
        "arrays.same-character-counts": ["hash-map"],
        "arrays.product-except-self": ["prefix-suffix"],
        "arrays.has-duplicate": ["hash-set"],
        "arrays.group-anagrams": ["canonical-key", "hash-map"],
        "arrays.top-frequent": ["hash-map", "deterministic-ranking"],
        "arrays.longest-target-sum": ["prefix-sums", "hash-map"],
        "mastery.arrays-hashing.missing-number": ["known-total"],
        "mastery.arrays-hashing.majority": ["boyer-moore"],
        "mastery.arrays-hashing.target-subarrays": ["prefix-sums", "hash-map"],

        // Two Pointers
        "pointers.clean-palindrome": ["opposing-pointers"],
        "pointers.sorted-pair": ["opposing-pointers"],
        "pointers.water-container": ["opposing-pointers", "boundary-extremes"],
        "pointers.three-sum": ["sorted-k-sum", "opposing-pointers"],
        "pointers.trapped-water": ["opposing-pointers", "two-sided-water"],
        "pointers.move-zeros": ["read-write-pointers"],
        "pointers.sorted-squares": ["opposing-pointers"],
        "pointers.closest-pair": ["opposing-pointers"],
        "pointers.four-sum": ["sorted-k-sum", "opposing-pointers"],
        "mastery.two-pointers.merge-sorted": ["merge-streams"],
        "mastery.two-pointers.subsequence": ["subsequence-scan"],
        "mastery.two-pointers.pairs-below": ["opposing-pointers", "pair-batch-counting"],

        // Sliding Window
        "window.best-fixed-sum": ["fixed-window"],
        "window.longest-unique": ["variable-window"],
        "window.minimum-cover": ["variable-window", "requirement-counts"],
        "window.longest-replacement": ["variable-window", "stale-window-maximum"],
        "window.permutation-starts": ["fixed-window", "requirement-counts"],
        "window.min-positive-sum": ["variable-window"],
        "window.max-ones": ["variable-window"],
        "window.repeated-dna": ["fixed-window", "hash-set"],
        "window.maximum-values": ["fixed-window", "monotonic-deque"],
        "mastery.sliding-window.max-vowels": ["fixed-window"],
        "mastery.sliding-window.minimum-positive": ["variable-window"],
        "mastery.sliding-window.k-distinct": ["variable-window", "requirement-counts"],

        // Stack
        "stack.balanced-brackets": ["lifo-stack"],
        "stack.warmer-waits": ["monotonic-stack"],
        "stack.largest-histogram": ["monotonic-stack", "monotonic-span-boundaries"],
        "stack.remove-adjacent": ["lifo-stack"],
        "stack.evaluate-postfix": ["lifo-stack"],
        "stack.min-add-parentheses": ["balance-counter"],
        "stack.asteroid-collisions": ["lifo-stack"],
        "stack.decode-string": ["nested-frames"],
        "stack.next-greater-circular": ["monotonic-stack", "circular-scan"],
        "mastery.stack.simplify-path": ["lifo-stack"],
        "mastery.stack.next-smaller": ["monotonic-stack"],
        "mastery.stack.validate-sequences": ["lifo-stack"],

        // Linked Lists
        "mastery.linked-lists.middle-node": ["linked-traversal", "fast-slow"],
        "mastery.linked-lists.reverse-values": ["linked-traversal"],
        "mastery.linked-lists.cycle-entry": ["fast-slow", "floyd-cycle-entry"],

        // Binary Search
        "binary.first-position": ["boundary-search"],
        "binary.rotated-minimum": ["rotated-search"],
        "binary.minimum-speed": ["answer-search"],
        "binary.search-rotated": ["rotated-search"],
        "binary.ship-capacity": ["answer-search"],
        "binary.exact-search": ["boundary-search"],
        "binary.integer-root": ["answer-search"],
        "binary.peak-index": ["slope-search"],
        "mastery.binary-search.lower-bound": ["boundary-search"],
        "mastery.binary-search.kth-missing": ["boundary-search"],
        "mastery.binary-search.split-largest": ["answer-search"],

        // Intervals
        "intervals.merge-ranges": ["sort-merge"],
        "intervals.insert-range": ["sort-merge"],
        "intervals.meeting-rooms": ["sweep-events"],
        "intervals.intersection": ["interval-streams"],
        "intervals.erase-overlaps": ["interval-scheduling"],
        "intervals.can-attend": ["sort-merge"],
        "intervals.covered-queries": ["sort-merge", "sorted-query-sweep"],
        "intervals.minimum-groups": ["sweep-events"],
        "mastery.intervals.union-length": ["sort-merge"],
        "mastery.intervals.max-overlap": ["sweep-events"],
        "mastery.intervals.carpool": ["sweep-events"],

        // Trees
        "trees.maximum-depth": ["tree-dfs"],
        "trees.level-averages": ["tree-bfs"],
        "trees.valid-search-tree": ["bst-invariants"],
        "trees.inorder-values": ["traversal-orders"],
        "trees.search-tree-ancestor": ["bst-invariants"],
        "trees.preorder-values": ["traversal-orders"],
        "trees.same-tree": ["tree-dfs"],
        "trees.diameter": ["postorder-aggregation"],
        "mastery.trees.leaf-count": ["heap-array-tree"],
        "mastery.trees.right-view": ["heap-level-scan"],
        "mastery.trees.max-path": ["postorder-aggregation"],

        // Queues & Heaps
        "mastery.queues-heaps.kth-smallest": ["heap"],
        "mastery.queues-heaps.closest-points": ["heap", "deterministic-ranking"],
        "mastery.queues-heaps.running-medians": ["dual-heaps"],

        // Tries & String Search
        "mastery.tries-strings.kmp-index": ["prefix-fallback"],
        "mastery.tries-strings.prefix-counts": ["counted-trie"],
        "mastery.tries-strings.unique-prefixes": ["counted-trie"],

        // Graphs
        "graphs.island-count": ["graph-search"],
        "graphs.route-exists": ["graph-search"],
        "graphs.course-cycle": ["topological-sort"],
        "graphs.bipartite": ["graph-coloring"],
        "graphs.shortest-grid-path": ["graph-search"],
        "graphs.components": ["graph-search"],
        "graphs.flood-fill": ["graph-search"],
        "graphs.word-ladder": ["graph-search"],
        "mastery.graphs.provinces": ["graph-search"],
        "mastery.graphs.network-delay": ["dijkstra"],
        "mastery.graphs.safe-nodes": ["dfs-cycle-states"],

        // Union-Find
        "mastery.union-find.redundant-edge": ["disjoint-set"],
        "mastery.union-find.component-stream": ["disjoint-set"],
        "mastery.union-find.mst-cost": ["disjoint-set", "kruskal"],

        // Backtracking
        "backtracking.all-subsets": ["choose-explore-undo"],
        "backtracking.target-combinations": ["combination-search"],
        "backtracking.queens-count": ["constraint-pruning"],
        "backtracking.permutations": ["permutation-search"],
        "backtracking.word-search": ["constraint-pruning"],
        "backtracking.phone-letters": ["combination-search"],
        "backtracking.generate-parentheses": ["constraint-pruning"],
        "backtracking.palindrome-partitions": ["partition-search"],
        "mastery.backtracking.combinations": ["combination-search"],
        "mastery.backtracking.restore-address": ["constraint-pruning"],
        "mastery.backtracking.letter-cases": ["choose-explore-undo"],

        // Bit Manipulation & Math
        "mastery.bit-math.popcount": ["popcount"],
        "mastery.bit-math.single-number": ["xor-cancellation"],
        "mastery.bit-math.mod-power": ["fast-power"],

        // Dynamic Programming
        "dp.climb-ways": ["memo-tabulation", "rolling-recurrence"],
        "dp.max-non-adjacent": ["take-skip-dp"],
        "dp.fewest-coins": ["unbounded-amount-dp"],
        "dp.unique-paths": ["grid-dp"],
        "dp.longest-common-subsequence": ["sequence-dp"],
        "dp.min-climbing-cost": ["rolling-recurrence"],
        "dp.decode-ways": ["rolling-recurrence"],
        "dp.longest-palindrome-subsequence": ["interval-dp"],
        "mastery.dynamic-programming.knapsack": ["take-skip-dp"],
        "mastery.dynamic-programming.equal-partition": ["take-skip-dp"],
        "mastery.dynamic-programming.max-square": ["grid-dp"],

        // Greedy
        "greedy.reach-end": ["greedy-frontier"],
        "greedy.max-meetings": ["interval-scheduling"],
        "greedy.gas-start": ["deficit-reset"],
        "greedy.minimum-arrows": ["interval-scheduling"],
        "greedy.partition-labels": ["last-occurrence-partitions"],
        "greedy.stock-profit": ["running-extreme"],
        "greedy.candy": ["two-pass-constraints"],
        "greedy.task-scheduler": ["cooldown-frame-counting"],
        "mastery.greedy.cookies": ["greedy-choice"],
        "mastery.greedy.minimum-jumps": ["greedy-frontier"],
        "mastery.greedy.reorganize": ["greedy-priority"],

        // Advanced Synthesis
        "advanced.longest-increasing": ["lis-tails"],
        "advanced.edit-distance": ["sequence-dp"],
        "advanced.median-sorted": ["partition-binary-search"],
        "advanced.word-break": ["sequence-dp"],
        "advanced.maximum-product-subarray": ["paired-product-extremes"],
        "advanced.kth-largest": ["quickselect"],
        "advanced.merge-sorted-lists": ["multiway-merge"],
        "advanced.longest-valid-parentheses": ["lifo-stack", "sentinel-index-boundary"],
        "mastery.advanced.circular-sum": ["kadane"],
        "mastery.advanced.wildcard": ["sequence-dp"],
        "mastery.advanced.distinct-subsequences": ["sequence-dp"],

        // Advanced Data Structures
        "mastery.advanced-data-structures.fenwick-prefix": ["fenwick-tree"],
        "mastery.advanced-data-structures.range-add": ["difference-array"],
        "mastery.advanced-data-structures.lru": ["lru-map-list"],

        // ML: Tensor & Numerical Foundations
        "ml.matrix-multiply": ["shape-indexing"],
        "ml.stable-softmax": ["stable-normalization"],
        "ml.batch-cross-entropy": ["log-likelihood"],
        "ml.linear-forward": ["shape-indexing"],
        "ml.mean-pool-embeddings": ["masked-reduction"],

        // ML: Training Mechanics
        "ml.layer-norm": ["normalization"],
        "ml.batch-norm-train": ["normalization"],
        "ml.inverted-dropout": ["stochastic-training"],
        "ml.mlp-backward": ["computation-graph"],
        "ml.adam-step": ["optimizer-state"],

        // ML: Neural Architectures
        "ml.conv2d-valid": ["receptive-field"],
        "ml.max-pool2d": ["pooling"],
        "ml.scaled-attention": ["attention", "attention-masking"],
        "ml.causal-self-attention": ["attention", "attention-masking"],
        "ml.multi-head-causal-attention": ["attention", "attention-masking", "multihead-reshape"],

        // ML: Research Engineering
        "ml.kmeans-step": ["clustering"],
        "ml.macro-f1": ["metric-accounting"],
        "ml.beam-search": ["ranked-state"],
        "ml.pad-sequences": ["padding-masks"],
        "ml.accumulate-gradients": ["gradient-accumulation"]
    ]
}

/// A prerequisite graph between techniques. Problem mappings name the most
/// specific algorithms; this graph supplies their transitive foundations.
/// Keeping the graph separate makes omissions testable and prevents a lesson
/// such as “Dijkstra” from silently assuming heaps and graph traversal.
enum TechniqueDependencyCatalog {
    static func directPrerequisiteIDs(for techniqueID: String) -> [String] {
        dependencies[techniqueID] ?? []
    }

    static var dependentTechniqueIDs: Set<String> { Set(dependencies.keys) }
    static var referencedTechniqueIDs: Set<String> { Set(dependencies.values.flatMap { $0 }) }

    static func expandedTechniqueIDs(from directIDs: [String]) -> [String] {
        var ordered: [String] = []
        var visited: Set<String> = []

        func visit(_ techniqueID: String) {
            guard visited.insert(techniqueID).inserted else { return }
            for prerequisiteID in directPrerequisiteIDs(for: techniqueID) {
                visit(prerequisiteID)
            }
            ordered.append(techniqueID)
        }

        for techniqueID in directIDs {
            visit(techniqueID)
        }
        return ordered
    }

    /// Orders the lessons shown inside one module so same-module foundations
    /// appear before the techniques that depend on them. Dependencies taught
    /// in earlier modules are intentionally absent from this local list.
    static func topologicallyOrdered(_ techniques: [AlgorithmTechnique]) -> [AlgorithmTechnique] {
        let byID = Dictionary(uniqueKeysWithValues: techniques.map { ($0.id, $0) })
        var ordered: [AlgorithmTechnique] = []
        var visited: Set<String> = []

        func visit(_ technique: AlgorithmTechnique) {
            guard visited.insert(technique.id).inserted else { return }
            for prerequisiteID in directPrerequisiteIDs(for: technique.id) {
                if let prerequisite = byID[prerequisiteID] {
                    visit(prerequisite)
                }
            }
            ordered.append(technique)
        }

        for technique in techniques {
            visit(technique)
        }
        return ordered
    }

    /// The dependency graph is deliberately sparse: an entry is present only
    /// when its lesson genuinely assumes another named algorithm. General
    /// Python and mathematical prerequisites remain visible at module level.
    private static let dependencies: [String: [String]] = [
        "canonical-key": ["hash-map"],
        "sequence-start-expansion": ["hash-set"],
        "prefix-suffix": ["linear-accumulator"],

        "boundary-extremes": ["opposing-pointers"],
        "sorted-k-sum": ["opposing-pointers"],
        "two-sided-water": ["opposing-pointers"],
        "pair-batch-counting": ["opposing-pointers"],
        "sorted-query-sweep": ["sort-merge", "opposing-pointers"],

        "requirement-counts": ["hash-map"],
        "monotonic-deque": ["fixed-window"],
        "stale-window-maximum": ["variable-window", "hash-map"],

        "monotonic-span-boundaries": ["monotonic-stack"],
        "circular-scan": ["monotonic-stack"],
        "sentinel-index-boundary": ["lifo-stack"],

        "floyd-cycle-entry": ["fast-slow"],

        "rotated-search": ["boundary-search"],
        "slope-search": ["boundary-search"],
        "partition-binary-search": ["boundary-search"],

        "interval-streams": ["opposing-pointers"],

        "tree-dfs": ["heap-array-tree"],
        "tree-bfs": ["heap-array-tree"],
        "traversal-orders": ["tree-dfs"],
        "bst-invariants": ["heap-array-tree"],
        "postorder-aggregation": ["tree-dfs"],
        "heap-level-scan": ["heap-array-tree"],

        "dual-heaps": ["heap"],
        "counted-trie": ["trie"],

        "graph-coloring": ["graph-search"],
        "dijkstra": ["graph-search", "heap"],
        "dfs-cycle-states": ["graph-search"],
        "kruskal": ["disjoint-set"],

        "combination-search": ["choose-explore-undo"],
        "permutation-search": ["choose-explore-undo"],
        "constraint-pruning": ["choose-explore-undo"],
        "partition-search": ["choose-explore-undo"],

        "popcount": ["bit-mask"],
        "xor-cancellation": ["bit-mask"],

        "rolling-recurrence": ["memo-tabulation"],
        "take-skip-dp": ["memo-tabulation"],
        "unbounded-amount-dp": ["memo-tabulation"],
        "grid-dp": ["memo-tabulation"],
        "sequence-dp": ["memo-tabulation"],
        "interval-dp": ["memo-tabulation"],

        "greedy-frontier": ["greedy-choice"],
        "running-extreme": ["greedy-choice"],
        "two-pass-constraints": ["greedy-choice"],
        "greedy-priority": ["greedy-choice"],
        "cooldown-frame-counting": ["greedy-choice", "hash-map"],
        "deficit-reset": ["greedy-choice"],
        "last-occurrence-partitions": ["greedy-choice", "hash-map"],

        "multiway-merge": ["heap", "merge-streams"],
        "kadane": ["memo-tabulation"],
        "paired-product-extremes": ["memo-tabulation"],
        "difference-array": ["prefix-sums"],

        "log-likelihood": ["stable-normalization"],
        "normalization": ["shape-indexing"],
        "computation-graph": ["shape-indexing"],
        "receptive-field": ["shape-indexing"],
        "pooling": ["receptive-field"],
        "attention": ["shape-indexing", "stable-normalization"],
        "attention-masking": ["stable-normalization"],
        "multihead-reshape": ["shape-indexing"],
        "padding-masks": ["shape-indexing"],
        "gradient-accumulation": ["metric-accounting"]
    ]
}

/// Lessons added by the prerequisite audit. They live separately from the
/// original module introductions so the audit remains reviewable: each entry
/// below exists because at least one real curriculum problem needs it.
enum SupplementalTechniqueCatalog {
    static func techniques(for moduleID: String) -> [AlgorithmTechnique] {
        byModule[moduleID] ?? []
    }

    static var allTechniques: [AlgorithmTechnique] { byModule.values.flatMap { $0 } }

    static func moduleID(containing techniqueID: String) -> String? {
        byModule.first { _, techniques in techniques.contains { $0.id == techniqueID } }?.key
    }

    private static func lesson(
        _ id: String,
        _ name: String,
        meaning: String,
        math: String,
        use: [String],
        avoid: String,
        invariant: String,
        template: String,
        drill: String,
        hint: String,
        answer: String
    ) -> AlgorithmTechnique {
        AlgorithmTechnique(
            id: id,
            name: name,
            plainLanguageMeaning: meaning,
            mathematicalView: math,
            useWhen: use,
            doNotUseWhen: avoid,
            invariant: invariant,
            pythonTemplate: template,
            drillPrompt: drill,
            drillHint: hint,
            drillAnswer: answer
        )
    }

    private static let byModule: [String: [AlgorithmTechnique]] = [
        "arrays-hashing": [
            lesson(
                "linear-accumulator", "Linear scan with an accumulator",
                meaning: "Read each value once and keep only the summary needed for the final answer, such as a total, count, minimum, or best-so-far.",
                math: "After i values, state is a fold: Sᵢ = update(Sᵢ₋₁, aᵢ). A constant-size state gives O(n) time and O(1) extra space.",
                use: ["Every item contributes independently", "Only a running summary is needed", "A second pass or stored copy adds no information"],
                avoid: "Do not force one accumulator when later decisions need detailed history; store the specific history those decisions require.",
                invariant: "After processing the first i values, the accumulator is exactly the requested summary of that prefix.",
                template: """
                def positive_total(values):
                    total = 0
                    for value in values:
                        if value > 0:
                            total += value
                    return total
                """,
                drill: "Trace positive_total([-2, 4, 3]). What is total after each step?",
                hint: "A rejected value leaves the state unchanged.",
                answer: "The totals are 0, 4, and 7; the invariant holds after every prefix."
            ),
            lesson(
                "canonical-key", "Canonical representation as a dictionary key",
                meaning: "Transform equivalent objects into the same stable representation, then group or compare that representation instead of repeatedly comparing whole objects.",
                math: "Choose f so x ~ y exactly when f(x) = f(y). For anagrams, f can be a sorted character tuple or a frequency vector.",
                use: ["Group values by an equivalence relation", "Input order should be ignored", "A stable hashable signature is cheaper to compare repeatedly"],
                avoid: "A signature is unsafe if different semantic groups can collide, or if it discards information the contract cares about.",
                invariant: "Every item stored under key k is equivalent under the problem's exact definition, and every equivalent item produces k.",
                template: """
                def group_anagrams(words):
                    groups = {}
                    for word in words:
                        key = tuple(sorted(word))
                        groups.setdefault(key, []).append(word)
                    return list(groups.values())
                """,
                drill: "What canonical key do 'eat' and 'tea' share?",
                hint: "Sort their characters, not the list of words.",
                answer: "Both produce ('a', 'e', 't'), so they enter the same group."
            ),
            lesson(
                "prefix-sums", "Prefix sums and prefix-state lookup",
                meaning: "Store the total before every boundary. A range total becomes the difference between two stored totals; a dictionary can remember earlier totals that would make a target.",
                math: "P[0] = 0 and P[i+1] = P[i] + a[i], so sum(a[l:r]) = P[r] - P[l]. A target range ends at r when P[l] = P[r] - target.",
                use: ["Many contiguous-range sum questions", "Negative values prevent a monotonic sliding window", "A target range can be expressed as a difference of prefix states"],
                avoid: "For one simple whole-array total, a running accumulator is enough; prefix sums do not directly solve non-contiguous subsequences.",
                invariant: "prefix equals the sum of exactly the processed values; stored[p] describes only positions at which that prefix total occurred.",
                template: """
                def count_target_ranges(values, target):
                    seen = {0: 1}
                    prefix = answer = 0
                    for value in values:
                        prefix += value
                        answer += seen.get(prefix - target, 0)
                        seen[prefix] = seen.get(prefix, 0) + 1
                    return answer
                """,
                drill: "Why must seen begin with {0: 1}?",
                hint: "Consider a valid range that starts at index 0.",
                answer: "It represents the empty prefix before the array, allowing prefix == target to count a range beginning at 0."
            ),
            lesson(
                "prefix-suffix", "Prefix and suffix contributions",
                meaning: "When an answer at each position depends on everything to its left and right, sweep once from each direction and combine the two summaries.",
                math: "answer[i] = L[i] · R[i], where L[i] summarizes a[:i] and R[i] summarizes a[i+1:].",
                use: ["Each output excludes its own position", "The operation combines associative left/right summaries", "Division is forbidden or zeros make division awkward"],
                avoid: "Do not use this pattern when excluding one item cannot be represented by combining independent left and right summaries.",
                invariant: "Before updating position i, the running product contains exactly the values strictly on the swept side of i.",
                template: """
                def product_except_self(values):
                    answer = [1] * len(values)
                    left = 1
                    for i in range(len(values)):
                        answer[i] = left
                        left *= values[i]
                    right = 1
                    for i in range(len(values) - 1, -1, -1):
                        answer[i] *= right
                        right *= values[i]
                    return answer
                """,
                drill: "For [2, 3, 4], what are the left contributions before the reverse pass?",
                hint: "Each position stores the product strictly before it.",
                answer: "[1, 2, 6]. The reverse pass multiplies these by [12, 4, 1]."
            ),
            lesson(
                "known-total", "Recover a missing value from a known total",
                meaning: "If the complete set of values is known and exactly one contribution is missing, subtract the observed contributions from the complete total.",
                math: "For 0…n, expected = n(n+1)/2. missing = expected − Σ observed. XOR is an alternative with no large integer sum.",
                use: ["Exactly one known-domain value is absent", "Every other value occurs exactly once", "The complete domain has a closed-form total or cancellable XOR"],
                avoid: "Duplicates, multiple missing values, or an unknown domain invalidate the one-equation argument.",
                invariant: "remaining equals the total contribution of domain values not yet cancelled by processed observations.",
                template: """
                def missing_number(values):
                    remaining = len(values) * (len(values) + 1) // 2
                    for value in values:
                        remaining -= value
                    return remaining
                """,
                drill: "For [3, 0, 1], what total is expected and what remains?",
                hint: "The domain is 0 through len(values).",
                answer: "The expected total is 6; subtracting 4 leaves the missing value 2."
            ),
            lesson(
                "boyer-moore", "Boyer–Moore majority cancellation",
                meaning: "Pair each occurrence of the eventual majority with a different value. Because the majority occupies more than half the array, at least one copy must survive cancellation.",
                math: "Removing pairs of unequal values preserves any strict majority. Maintain one candidate and its unmatched vote balance.",
                use: ["A strict majority is guaranteed", "You need O(1) extra space", "Values are arbitrary hashable or comparable items"],
                avoid: "If a majority is not guaranteed, make a second pass to verify candidate frequency; this does not find an arbitrary mode.",
                invariant: "The candidate represents the unmatched value after cancelling unequal pairs in the processed prefix.",
                template: """
                def majority_value(values):
                    candidate = None
                    votes = 0
                    for value in values:
                        if votes == 0:
                            candidate = value
                        votes += 1 if value == candidate else -1
                    return candidate
                """,
                drill: "Trace candidate and votes for [2, 1, 2].",
                hint: "At zero votes, the current value becomes the new candidate.",
                answer: "States are (2,1), (2,0), then (2,1); 2 survives."
            ),
            lesson(
                "deterministic-ranking", "Deterministic compound ranking",
                meaning: "Turn every tie rule into one sortable key so selection is correct and repeatable, rather than depending on set or dictionary iteration order.",
                math: "A lexicographic key such as (−frequency, value) defines a total order: higher frequency first, then smaller value.",
                use: ["The prompt specifies tie-breaking", "Top-k output must be reproducible", "Several attributes determine priority"],
                avoid: "Do not sort an entire large collection when only k items are needed and a bounded heap meets the same ordering contract.",
                invariant: "Comparing two keys always gives the same order and exactly matches every priority rule in the prompt.",
                template: """
                def rank_counts(counts):
                    return sorted(counts, key=lambda value: (-counts[value], value))
                """,
                drill: "Counts are {2: 3, 1: 3, 9: 1}. What is the order?",
                hint: "Frequency is descending; value breaks equal-frequency ties ascending.",
                answer: "[1, 2, 9]."
            ),
            lesson(
                "sequence-start-expansion", "Expand only from true sequence starts",
                meaning: "A set makes every value available by membership rather than position. Begin a consecutive-value walk only when the predecessor is absent, so the same numeric run is never rescanned from its middle.",
                math: "x starts a maximal run exactly when x−1 ∉ S. The walks from such starts partition S, so all inner-loop steps total O(|S|).",
                use: ["Values form consecutive numeric chains", "Input order and duplicates do not matter", "Sorting is disallowed by an expected-linear target"],
                avoid: "Do not launch a walk from every set value; that repeats long suffixes and can become O(n²).",
                invariant: "Every launched walk begins at the smallest value of one maximal run, and completed runs never need visiting again.",
                template: """
                def longest_consecutive(values):
                    available = set(values)
                    best = 0
                    for value in available:
                        if value - 1 in available:
                            continue
                        length = 1
                        while value + length in available:
                            length += 1
                        best = max(best, length)
                    return best
                """,
                drill: "In {3,4,5,8}, which values launch a walk?",
                hint: "Check whether each value's predecessor is absent.",
                answer: "3 and 8 launch walks; 4 and 5 are skipped because their predecessors exist."
            )
        ],

        "two-pointers": [
            lesson(
                "boundary-extremes", "Boundary-extreme elimination",
                meaning: "When an objective is limited by the weaker boundary, moving the stronger boundary cannot repair that bottleneck. Move the weaker one and retain the best value seen.",
                math: "For area = (r-l)·min(h[l],h[r]), shrinking width while keeping the smaller height cannot improve area; only replacing that smaller height might.",
                use: ["Two boundaries define a candidate", "The objective uses min or max of boundary values", "One boundary can be proven incapable of improvement"],
                avoid: "Do not move an endpoint based on intuition alone; derive which family of candidates is dominated first.",
                invariant: "best covers all discarded boundary pairs, and every potentially better pair remains between left and right.",
                template: """
                def widest_container(heights):
                    left, right, best = 0, len(heights) - 1, 0
                    while left < right:
                        best = max(best, (right - left) * min(heights[left], heights[right]))
                        if heights[left] <= heights[right]: left += 1
                        else: right -= 1
                    return best
                """,
                drill: "If the left wall is shorter, why not move the right wall?",
                hint: "Width shrinks and the unchanged shorter wall still limits height.",
                answer: "No pair with that left wall and a nearer right wall can do better, so discard the left wall."
            ),
            lesson(
                "sorted-k-sum", "Sorted k-sum with anchors",
                meaning: "Sort once, fix one or more earlier values, then reduce the remaining exact-sum search to opposing pointers while skipping duplicate values deliberately.",
                math: "Fix a[i]; the remaining target becomes T-a[i]. Sorted order makes the two-sum residual monotonic in each pointer.",
                use: ["Find unique triples or quadruples", "Reordering values is allowed", "The residual problem becomes sorted two-sum"],
                avoid: "Sorting loses original positions unless you carry them; do not skip duplicates before recording the first valid combination.",
                invariant: "All combinations with earlier anchors are complete; within this anchor, candidates outside [left,right] are ruled out.",
                template: """
                def three_sum(values, target):
                    values.sort()
                    answer = []
                    for i in range(len(values) - 2):
                        if i and values[i] == values[i - 1]: continue
                        left, right = i + 1, len(values) - 1
                        while left < right:
                            total = values[i] + values[left] + values[right]
                            if total < target: left += 1
                            elif total > target: right -= 1
                            else:
                                answer.append([values[i], values[left], values[right]])
                                left += 1; right -= 1
                    return answer
                """,
                drill: "Why skip a repeated anchor value?",
                hint: "The same suffix search was already performed for its previous equal copy.",
                answer: "It would generate duplicate value combinations without creating any new one."
            ),
            lesson(
                "merge-streams", "Merge two sorted streams",
                meaning: "Compare the next unused value of each sorted input, emit the smaller, and advance only the stream that supplied it.",
                math: "The smallest remaining overall value is min(a[i], b[j]); each comparison permanently determines one output position.",
                use: ["Two inputs are already sorted", "Preserve all values including duplicates", "You need linear time rather than sorting the concatenation"],
                avoid: "If inputs are not sorted, this local choice is not safe; validate or sort first if the contract permits.",
                invariant: "output is the sorted merge of the consumed prefixes, and both unconsumed suffixes remain sorted.",
                template: """
                def merge_sorted(a, b):
                    i = j = 0
                    output = []
                    while i < len(a) and j < len(b):
                        if a[i] <= b[j]: output.append(a[i]); i += 1
                        else: output.append(b[j]); j += 1
                    return output + a[i:] + b[j:]
                """,
                drill: "Merging [1,4] and [2,3], which stream advances first?",
                hint: "Compare only their first unused values.",
                answer: "The first stream emits 1 and advances; the second then emits 2 and 3."
            ),
            lesson(
                "subsequence-scan", "Subsequence scan",
                meaning: "Advance through the source once; advance the target pointer only when its next required value appears. Gaps in the source are allowed, reordering is not.",
                math: "matched is the maximum prefix length of target that can be embedded in the processed source prefix.",
                use: ["Check whether order is preserved", "Characters or values may be skipped", "One sequence is the pattern sought inside another"],
                avoid: "This checks a subsequence, not a contiguous substring and not an unordered subset.",
                invariant: "matched is the longest target prefix matched in order using only processed source positions.",
                template: """
                def is_subsequence(target, source):
                    matched = 0
                    for value in source:
                        if matched < len(target) and value == target[matched]:
                            matched += 1
                    return matched == len(target)
                """,
                drill: "Is 'ace' a subsequence of 'abcde'?",
                hint: "You may skip b and d but cannot move backward.",
                answer: "Yes: match a, then c, then e in increasing source positions."
            ),
            lesson(
                "two-sided-water", "Two-sided maxima for trapped water",
                meaning: "Water at a bar is limited by the lower of the best wall on each side. Process the side with the smaller known maximum: the opposite boundary is already high enough to make that side's water final.",
                math: "water[i] = max(0, min(leftMax[i],rightMax[i])−height[i]). Two pointers avoid storing both maximum arrays.",
                use: ["Measure water between bars", "Each position depends on best boundaries on both sides", "O(1) auxiliary space is desired"],
                avoid: "Do not compare only the current bar heights after losing their running maxima; the maxima are the true boundaries.",
                invariant: "Processed outside positions have final water; left_max and right_max summarize every wall seen from their respective sides.",
                template: """
                def trapped_water(heights):
                    left, right = 0, len(heights) - 1
                    left_max = right_max = total = 0
                    while left <= right:
                        left_max = max(left_max, heights[left])
                        right_max = max(right_max, heights[right])
                        if left_max <= right_max:
                            total += left_max - heights[left]; left += 1
                        else:
                            total += right_max - heights[right]; right -= 1
                    return total
                """,
                drill: "If left_max is 3 and right_max is 7, which side can be finalized?",
                hint: "The lower wall limits min(left_max,right_max).",
                answer: "The left side; its water is determined by left_max = 3 regardless of unseen details behind the taller right boundary."
            ),
            lesson(
                "pair-batch-counting", "Count a whole batch of sorted pairs",
                meaning: "If the smallest and largest remaining values already satisfy a monotonic inequality, pairing the smallest with every value through the largest also satisfies it. Count that entire batch, then advance once.",
                math: "For sorted a and a[l]+a[r]<T, every j with l<j≤r has a[l]+a[j]≤a[l]+a[r]<T, contributing r−l pairs.",
                use: ["Count pairs below or above a threshold", "Values are sorted", "One extreme comparison proves many interior pairs at once"],
                avoid: "This batch proof does not apply to exact-sum counting or a non-monotonic pair condition.",
                invariant: "All pairs involving discarded endpoints have been counted exactly once; all uncounted pairs remain between the pointers.",
                template: """
                def count_pairs_below(values, target):
                    values.sort()
                    left, right, count = 0, len(values) - 1, 0
                    while left < right:
                        if values[left] + values[right] < target:
                            count += right - left
                            left += 1
                        else:
                            right -= 1
                    return count
                """,
                drill: "Sorted [1,2,4,6], target 8: when 1+6 qualifies, how many pairs are counted?",
                hint: "Pair 1 with every value from index left+1 through right.",
                answer: "3 pairs: (1,2), (1,4), and (1,6)."
            )
        ],

        "sliding-window": [
            lesson(
                "requirement-counts", "Requirement counts in a window",
                meaning: "Track how many required categories are currently satisfied, so window validity can be updated when one boundary character enters or leaves.",
                math: "A category c is satisfied when window[c] meets required[c]. Maintain formed rather than rechecking every category each step.",
                use: ["A window must contain required multiplicities", "The alphabet may be large", "Validity changes at exact count thresholds"],
                avoid: "A set is insufficient when duplicates matter; distinguish number of distinct required keys from total required items.",
                invariant: "formed equals exactly the number of required keys whose counts currently meet their required counts.",
                template: """
                def covers(window, required):
                    formed = 0
                    for key, needed in required.items():
                        if window.get(key, 0) >= needed:
                            formed += 1
                    return formed == len(required)
                """,
                drill: "Required is {'a': 2, 'b': 1}; does window {'a': 1, 'b': 4} cover it?",
                hint: "Extra b values cannot replace the missing a.",
                answer: "No. Only b is satisfied, so formed is 1 of 2."
            ),
            lesson(
                "monotonic-deque", "Monotonic deque for window extremes",
                meaning: "Keep only indices that could still become the maximum. Remove expired indices from the front and values dominated by a newer, larger value from the back.",
                math: "Deque indices increase by position while their values decrease. Each index enters and leaves at most once, giving O(n) total work.",
                use: ["Maximum or minimum for every fixed window", "Adjacent windows overlap", "You need O(n), not a scan or sort per window"],
                avoid: "Store indices, not only values, because expiration depends on position; use a heap if arbitrary deletions/priorities dominate.",
                invariant: "The deque contains unexpired candidate indices in position order and decreasing value order; its front is the window maximum.",
                template: """
                from collections import deque

                def window_max(values, k):
                    candidates, answer = deque(), []
                    for right, value in enumerate(values):
                        while candidates and candidates[0] <= right - k: candidates.popleft()
                        while candidates and values[candidates[-1]] <= value: candidates.pop()
                        candidates.append(right)
                        if right + 1 >= k: answer.append(values[candidates[0]])
                    return answer
                """,
                drill: "When 5 enters after candidate values [4, 2], what remains?",
                hint: "A newer 5 outlives and exceeds both older values.",
                answer: "Both are removed from the back; only the index of 5 remains."
            ),
            lesson(
                "stale-window-maximum", "Safe stale maximum in replacement windows",
                meaning: "For the longest replaceable-character window, keep the largest frequency ever seen while expanding. It may be stale after shrinking, but it cannot manufacture a best length larger than one that was genuinely feasible earlier.",
                math: "A window needs length−max_frequency replacements. A nondecreasing historical maximum is sufficient for the maximum-length objective, though not for reporting the current window's exact validity.",
                use: ["Maximize a repeated-character window after at most k replacements", "Only the best length is requested", "Avoid rescanning frequency counts after every shrink"],
                avoid: "Do not reuse this shortcut when the exact current window, its characters, or minimum valid window must be returned.",
                invariant: "The maintained length never exceeds a length supported by some observed frequency; shrinking prevents growth beyond the replacement budget bound.",
                template: """
                def longest_replacement(text, k):
                    counts = {}
                    left = best = max_frequency = 0
                    for right, char in enumerate(text):
                        counts[char] = counts.get(char, 0) + 1
                        max_frequency = max(max_frequency, counts[char])
                        while right - left + 1 - max_frequency > k:
                            counts[text[left]] -= 1; left += 1
                        best = max(best, right - left + 1)
                    return best
                """,
                drill: "Why is the stale maximum unsuitable for returning the exact final valid substring?",
                hint: "Its most frequent character may already have left the window.",
                answer: "The current window can appear valid under historical information even though its true current frequency is smaller."
            )
        ],

        "stack": [
            lesson(
                "balance-counter", "Balance counter for one bracket type",
                meaning: "For a single open/close bracket type, a number can replace the whole stack: increment on open and consume it on close, counting repairs when none is available.",
                math: "balance = opens_seen − matched_closes. It must never be negative after repairing an unmatched close.",
                use: ["Only one bracket type exists", "You need counts rather than exact nesting symbols", "Every close matches the most recent indistinguishable open"],
                avoid: "With multiple bracket types, a count cannot remember which opener is on top; use a stack.",
                invariant: "balance is the number of unmatched opens in the processed prefix; repairs counts unmatched closes already fixed.",
                template: """
                def minimum_additions(text):
                    balance = repairs = 0
                    for char in text:
                        if char == '(': balance += 1
                        elif balance: balance -= 1
                        else: repairs += 1
                    return repairs + balance
                """,
                drill: "Why does the final answer add balance?",
                hint: "Those opens never found closes.",
                answer: "Each unmatched opening bracket needs one closing bracket appended."
            ),
            lesson(
                "nested-frames", "Stack frames for nested parsing",
                meaning: "When a nested expression begins, save the outer partial result and its control data. When it closes, restore that frame and combine the completed inner result.",
                math: "The stack is the suspended call context for each unmatched opening delimiter.",
                use: ["Nested repetition or arithmetic", "Inner results must be combined with outer state", "Opening and closing delimiters define scopes"],
                avoid: "Specify exactly which fields a frame stores; mixing counts and text on an unstructured stack causes type/order bugs.",
                invariant: "Each stack frame contains the complete outer state immediately before one unmatched opening delimiter.",
                template: """
                def decode(text):
                    stack = []
                    current, number = '', 0
                    for char in text:
                        if char.isdigit(): number = number * 10 + int(char)
                        elif char == '[': stack.append((current, number)); current, number = '', 0
                        elif char == ']':
                            outer, repeat = stack.pop(); current = outer + current * repeat
                        else: current += char
                    return current
                """,
                drill: "What frame is saved on reading 'ab3['?",
                hint: "Save what must resume after the matching ].",
                answer: "('ab', 3); the inner current string then starts empty."
            ),
            lesson(
                "monotonic-span-boundaries", "Monotonic stack with span boundaries",
                meaning: "For each increasing histogram bar, store the earliest index from which its height remains valid. A shorter bar closes taller rectangles and inherits their earliest start; a final zero closes every remaining rectangle.",
                math: "When height h started at s and closes before i, its maximal area is h·(i−s). Each bar is pushed and popped once.",
                use: ["Largest histogram rectangle", "A value's answer needs nearest smaller boundaries", "Popped candidates transfer an earliest valid boundary"],
                avoid: "A next-greater stack that stores only unresolved indices is not enough; define the width represented by every entry.",
                invariant: "Stack heights are nondecreasing, and each entry's start is the earliest position at which its height can span to the current boundary.",
                template: """
                def largest_histogram(heights):
                    stack = []
                    best = 0
                    for index in range(len(heights) + 1):
                        height = heights[index] if index < len(heights) else 0
                        start = index
                        while stack and stack[-1][1] > height:
                            start, previous = stack.pop()
                            best = max(best, previous * (index - start))
                        stack.append((start, height))
                    return best
                """,
                drill: "Why does a new shorter bar inherit the earliest popped start?",
                hint: "It is no taller than every popped bar.",
                answer: "The shorter height was valid throughout all those popped spans, so its future rectangle may begin there too."
            ),
            lesson(
                "circular-scan", "Simulate a circular scan with modular indices",
                meaning: "Traverse up to two copies of the index range so values near the end can see candidates near the beginning, while pushing original indices only during the first copy.",
                math: "At step t, inspect index t mod n. Two passes cover every later position around one full cycle without duplicating answers.",
                use: ["Next greater value in a circular array", "A wraparound search spans at most one cycle", "Reuse a linear stack algorithm on a ring"],
                avoid: "Do not keep pushing during every pass or unresolved state grows with duplicates; define whether an item may answer itself.",
                invariant: "The stack holds original indices still lacking an answer after every circular candidate inspected so far.",
                template: """
                def next_greater_circular(values):
                    answer = [-1] * len(values)
                    stack = []
                    for step in range(2 * len(values)):
                        index = step % len(values)
                        while stack and values[stack[-1]] < values[index]:
                            answer[stack.pop()] = values[index]
                        if step < len(values): stack.append(index)
                    return answer
                """,
                drill: "Why are indices pushed only in the first pass?",
                hint: "Each original position needs exactly one unresolved entry.",
                answer: "The second pass supplies wraparound candidates; pushing again would duplicate the same questions."
            ),
            lesson(
                "sentinel-index-boundary", "Sentinel index for valid-span length",
                meaning: "Store indices of unmatched opening brackets and keep a sentinel for the most recent invalid boundary. After a matched close, subtract that boundary from the current index to obtain the valid suffix length.",
                math: "If b is the last unmatched boundary before a valid suffix ending at i, its length is i−b. Start with b=−1.",
                use: ["Longest valid-parentheses substring", "Matched spans must cross nested groups", "An unmatched close resets the valid boundary"],
                avoid: "A stack of characters validates the whole string but cannot calculate span lengths; indices are essential.",
                invariant: "The stack bottom/top identifies the last unmatched boundary before the current valid suffix; opening indices above it remain unmatched.",
                template: """
                def longest_valid_parentheses(text):
                    stack = [-1]
                    best = 0
                    for index, char in enumerate(text):
                        if char == '(':
                            stack.append(index)
                        else:
                            stack.pop()
                            if not stack: stack.append(index)
                            else: best = max(best, index - stack[-1])
                    return best
                """,
                drill: "Why does the initial sentinel equal -1?",
                hint: "Measure a valid prefix ending at index i.",
                answer: "i−(−1)=i+1, the correct length of a valid substring beginning at index 0."
            )
        ],

        "linked-lists": [
            lesson(
                "linked-traversal", "Linked traversal by following references",
                meaning: "A linked list's order comes from next links, not storage position. CodeStreak represents a reference by an integer index: head is the first node and next_indices[i] is its next index, with −1 playing the role of None.",
                math: "The reachable list is a path head=v₀ → v₁ → … → −1 even when the arrays store those nodes in another order; traversal is O(number of reachable nodes).",
                use: ["Read every reachable node in link order", "Parallel arrays stand in for node objects and references", "Search without mutating links"],
                avoid: "Do not scan array positions as though they were list order, and do not follow a cyclic list without cycle protection.",
                invariant: "All nodes before current on the reachable chain have been processed exactly once; current is the next linked node, regardless of its numeric array position.",
                template: """
                def linked_values(values, next_indices, head):
                    result = []
                    current = head
                    while current != -1:
                        result.append(values[current])
                        current = next_indices[current]
                    return result
                """,
                drill: "If head=0 and next_indices=[2, -1, 1], in what index order are nodes visited?",
                hint: "Follow next_indices rather than counting upward.",
                answer: "0, then 2, then 1, then −1 ends the traversal."
            ),
            lesson(
                "floyd-cycle-entry", "Floyd's cycle-entry proof",
                meaning: "First let slow and fast meet inside a cycle. Then place one pointer at the head and move both one step; their next meeting is the cycle entrance.",
                math: "If distance to entry is μ and meeting is λ steps into a cycle of length c, the meeting equation implies μ ≡ −λ (mod c). Equal-speed motion closes those distances at the entry.",
                use: ["Return the actual cycle entry", "O(1) extra space is required", "Node identity can be compared"],
                avoid: "A fast/slow meeting alone proves a cycle but does not identify its entrance; return None if the first phase reaches the end.",
                invariant: "Phase one establishes a meeting in the cycle; in phase two, both pointers are equally far modulo the cycle from the entry.",
                template: """
                def cycle_entry(next_indices, head):
                    slow = fast = head
                    while fast != -1 and next_indices[fast] != -1:
                        slow = next_indices[slow]
                        fast = next_indices[next_indices[fast]]
                        if slow == fast:
                            seeker = head
                            while seeker != slow:
                                seeker = next_indices[seeker]
                                slow = next_indices[slow]
                            return seeker
                    return -1
                """,
                drill: "After slow and fast meet, should fast keep moving two steps in phase two?",
                hint: "The modular distance argument uses equal speeds.",
                answer: "No. Move the head pointer and meeting pointer one step each."
            )
        ],

        "binary-search": [
            lesson(
                "rotated-search", "Binary search in a rotated sorted array",
                meaning: "Although the whole array is not sorted, at least one half around the midpoint is sorted. Identify that half, test whether the target lies inside its value range, and discard the other half.",
                math: "With distinct values, a[lo] ≤ a[mid] identifies a sorted left half; otherwise the right half is sorted.",
                use: ["A sorted array was rotated once", "Values are distinct or duplicate handling is specified", "You need logarithmic search or the rotated minimum"],
                avoid: "Heavy duplicates can make both halves indistinguishable and may require shrinking bounds, degrading to O(n).",
                invariant: "If the target exists, it remains within [lo, hi]; the discarded sorted half provably excludes it.",
                template: """
                def search_rotated(values, target):
                    lo, hi = 0, len(values) - 1
                    while lo <= hi:
                        mid = (lo + hi) // 2
                        if values[mid] == target: return mid
                        if values[lo] <= values[mid]:
                            if values[lo] <= target < values[mid]: hi = mid - 1
                            else: lo = mid + 1
                        else:
                            if values[mid] < target <= values[hi]: lo = mid + 1
                            else: hi = mid - 1
                    return -1
                """,
                drill: "In [4,5,6,1,2,3], mid is 6 and target is 2. Which half survives?",
                hint: "The left half [4,5,6] is sorted but does not contain 2.",
                answer: "Keep the right half [1,2,3] by setting lo = mid + 1."
            ),
            lesson(
                "slope-search", "Binary search on a local slope",
                meaning: "At a midpoint, compare it with its neighbor. If values rise to the right, a peak must exist on the right; otherwise a peak exists at or left of the midpoint.",
                math: "For a finite sequence, following an increasing slope cannot continue beyond the boundary without reaching a local maximum.",
                use: ["Find any peak", "The objective has a directional local comparison", "A global sorted order is absent but one half is guaranteed to contain an answer"],
                avoid: "This finds a guaranteed local extremum, not necessarily the global maximum or a specified peak among ties.",
                invariant: "The closed interval [lo, hi] always contains at least one peak.",
                template: """
                def peak_index(values):
                    lo, hi = 0, len(values) - 1
                    while lo < hi:
                        mid = (lo + hi) // 2
                        if values[mid] < values[mid + 1]: lo = mid + 1
                        else: hi = mid
                    return lo
                """,
                drill: "Why is mid + 1 safe to read while lo < hi?",
                hint: "mid is floor((lo+hi)/2).",
                answer: "When lo < hi, mid is strictly less than hi, so mid + 1 remains in bounds."
            )
        ],

        "intervals": [
            lesson(
                "sorted-query-sweep", "Offline sweep over sorted queries",
                meaning: "When every query asks about the same static intervals, sort the queries while remembering their original positions. Advance one interval pointer monotonically, answer each query, then restore output order.",
                math: "After merging disjoint ranges, both ranges and queries are ordered streams. Each range pointer advances at most once, so the sweep after sorting is O(n + q).",
                use: ["Many point queries share one fixed interval set", "Queries may be answered offline in sorted order", "Answers must ultimately return in original query order"],
                avoid: "Use an online search structure when queries and updates interleave or answers must be emitted before later queries are known.",
                invariant: "Before answering sorted query x, every skipped interval ends before x and the current interval is the first one that could contain x.",
                template: """
                def covered_queries(ranges, queries):
                    merged = merge_ranges(ranges)
                    answers = [False] * len(queries)
                    interval = 0
                    for query, original in sorted((value, i) for i, value in enumerate(queries)):
                        while interval < len(merged) and merged[interval][1] < query:
                            interval += 1
                        if interval < len(merged) and merged[interval][0] <= query:
                            answers[original] = True
                    return answers
                """,
                drill: "Why carry each query's original index through the sort?",
                hint: "The requested output order is not sorted-query order.",
                answer: "The saved index lets each computed boolean return to the position belonging to its original query."
            ),
            lesson(
                "interval-streams", "Two-pointer intersection of interval streams",
                meaning: "For two lists of disjoint sorted intervals, compare their current ranges. Emit their overlap, then advance whichever interval ends first because it cannot overlap anything later in the other stream.",
                math: "Intersection is [max(a.start,b.start), min(a.end,b.end)] when the lower endpoint does not exceed the upper endpoint.",
                use: ["Both interval lists are sorted", "Intervals within each list are disjoint", "Find pairwise intersections in linear time"],
                avoid: "If either list contains unsorted overlaps, normalize it first or the one-pass advance proof fails.",
                invariant: "Every possible intersection involving an interval before i or j has already been emitted.",
                template: """
                def interval_intersections(first, second):
                    i = j = 0
                    answer = []
                    while i < len(first) and j < len(second):
                        start = max(first[i][0], second[j][0])
                        end = min(first[i][1], second[j][1])
                        if start <= end: answer.append([start, end])
                        if first[i][1] < second[j][1]: i += 1
                        else: j += 1
                    return answer
                """,
                drill: "After comparing [1,4] with [2,8], which pointer advances?",
                hint: "Which interval can no longer reach any later part of the other stream?",
                answer: "Advance [1,4], the interval that ends first."
            ),
            lesson(
                "interval-scheduling", "Earliest-finish interval scheduling",
                meaning: "Choose the compatible interval that finishes earliest. It leaves at least as much future room as any competing first choice, so the choice can be exchanged into an optimal schedule.",
                math: "Sorting by end time yields a maximum-size non-overlapping subset; equivalently it minimizes removals from a fixed set.",
                use: ["Maximize number of non-overlapping intervals", "Minimize removals", "A point at the current overlap end can cover many intervals"],
                avoid: "Earliest start or shortest duration is not generally optimal; weighted interval rewards require dynamic programming.",
                invariant: "The selected intervals are compatible, and the last selected end is no later than an optimal schedule for the processed prefix.",
                template: """
                def max_non_overlapping(intervals):
                    intervals.sort(key=lambda pair: pair[1])
                    chosen, last_end = 0, float('-inf')
                    for start, end in intervals:
                        if start >= last_end:
                            chosen += 1
                            last_end = end
                    return chosen
                """,
                drill: "Why prefer [1,3] over [1,8] when both are available?",
                hint: "Compare how much timeline remains after each choice.",
                answer: "Ending at 3 leaves every opportunity that ending at 8 leaves, plus possibly more."
            ),
            lesson(
                "active-interval-heap", "Active intervals in a min-heap",
                meaning: "Process queries or starts in sorted order while a heap tracks active interval endings. Add newly eligible intervals and remove those that can no longer answer the current point.",
                math: "The heap represents a changing frontier ordered by end or length; each interval is inserted and removed at most once.",
                use: ["Minimum interval covering each query", "Minimum simultaneous groups", "Intervals become eligible in sorted start order and expire by end"],
                avoid: "Define the heap key and expiration inequality from the interval boundary convention; the smallest end and smallest length are different priorities.",
                invariant: "Before answering the current event, the heap contains exactly eligible, unexpired candidates ordered by the requested priority.",
                template: """
                import heapq

                def minimum_groups(intervals):
                    active = []
                    best = 0
                    for start, end in sorted(intervals):
                        while active and active[0] < start: heapq.heappop(active)
                        heapq.heappush(active, end)
                        best = max(best, len(active))
                    return best
                """,
                drill: "For closed intervals, does an interval ending at start expire before the new one?",
                hint: "Both include the shared endpoint.",
                answer: "No. Expire only end < start; end == start still overlaps."
            )
        ],

        "trees": [
            lesson(
                "heap-array-tree", "Navigate an array-backed binary tree",
                meaning: "CodeStreak stores a binary tree in level-order slots rather than node objects. For a present slot i, its children are 2i+1 and 2i+2; an out-of-range or null slot is an absent subtree.",
                math: "Level d occupies indices 2^d−1 through 2^(d+1)−2. Parent(i)=⌊(i−1)/2⌋ for i>0, left(i)=2i+1, and right(i)=2i+2.",
                use: ["The prompt says heap-indexed or level-order with preserved null slots", "Recursive child navigation starts from an array index", "You must distinguish an absent slot from a stored value"],
                avoid: "Do not compact away null entries: that changes descendant indices. A serialization that omits null slots needs a different decoder.",
                invariant: "Every recursive or queued index denotes exactly one structural tree position; invalid or null indices contribute an empty subtree.",
                template: """
                def tree_depth(tree):
                    def depth(index):
                        if index >= len(tree) or tree[index] is None:
                            return 0
                        return 1 + max(depth(2 * index + 1), depth(2 * index + 2))
                    return depth(0)
                """,
                drill: "In heap-indexed storage, where are the children of index 3?",
                hint: "Use 2i+1 and 2i+2.",
                answer: "They are indices 7 and 8; either may still be absent or beyond the array."
            ),
            lesson(
                "heap-level-scan", "Scan heap-array level boundaries",
                meaning: "Heap-indexed arrays already list structural positions level by level. Track the final index of the current depth while scanning; the last present value encountered within that boundary is the right-side view for that depth.",
                math: "The final structural index at depth d is 2^(d+1)−2. From one level end e, the next is 2e+2.",
                use: ["The tree is stored in heap-index order", "You need one aggregate per depth", "Null placeholders preserve the structural positions"],
                avoid: "Use an ordinary BFS queue for pointer-based trees or compact serializations where array positions no longer encode depth.",
                invariant: "depth and level_end identify the current structural level; the saved value for that depth is the rightmost present slot scanned so far.",
                template: """
                def right_view(tree):
                    view, depth, level_end = [], 0, 0
                    for index, value in enumerate(tree):
                        while index > level_end:
                            depth += 1
                            level_end = 2 * level_end + 2
                        if value is not None:
                            if depth == len(view): view.append(value)
                            else: view[depth] = value
                    return view
                """,
                drill: "What structural indices make up depth 2?",
                hint: "Depth 2 starts after index 2 and ends at 2^(2+1)−2.",
                answer: "Indices 3 through 6. Null slots still occupy their structural positions."
            ),
            lesson(
                "traversal-orders", "Tree traversal order",
                meaning: "Choose when to process a node relative to its children: preorder before both, inorder between them, postorder after both. The order is part of the algorithm, not presentation trivia.",
                math: "Preorder: node,L,R. Inorder: L,node,R. Postorder: L,R,node. In a BST, inorder visits values in sorted order.",
                use: ["Return values in a named traversal", "BST sorted order is useful", "Parent work must occur before, between, or after child work"],
                avoid: "Do not substitute one traversal because it visits the same nodes; output order and available child information differ.",
                invariant: "The output contains exactly the completed traversal segments in the chosen recursive order.",
                template: """
                def inorder(node, output):
                    if node is None:
                        return
                    inorder(node.left, output)
                    output.append(node.val)
                    inorder(node.right, output)
                """,
                drill: "For root 2 with children 1 and 3, what is inorder output?",
                hint: "Left, node, right.",
                answer: "[1, 2, 3]."
            ),
            lesson(
                "bst-invariants", "Binary-search-tree bounds",
                meaning: "Every node inherits an allowed value interval from all its ancestors, not merely a comparison with its parent. Descending left tightens the upper bound; right tightens the lower bound.",
                math: "Validate low < node.val < high recursively. An ancestor's bound can rule out a value even when its parent comparison passes.",
                use: ["Validate a BST", "Search using ordered branches", "Find an ancestor by comparing both targets with the current value"],
                avoid: "Checking only node.left < node < node.right misses violations deeper in a subtree; define duplicate policy explicitly.",
                invariant: "Every node in the current subtree must lie inside the bounds passed from all ancestors.",
                template: """
                def is_valid_bst(node, low=float('-inf'), high=float('inf')):
                    if node is None: return True
                    if not low < node.val < high: return False
                    return (is_valid_bst(node.left, low, node.val)
                            and is_valid_bst(node.right, node.val, high))
                """,
                drill: "Why is 6 invalid as a left-descendant of root 5 even if its parent is 4?",
                hint: "The root's upper bound applies to the entire left subtree.",
                answer: "Every left-subtree value must be below 5; comparing only 6 > 4 would miss the ancestor violation."
            ),
            lesson(
                "postorder-aggregation", "Postorder aggregation with a global best",
                meaning: "A child returns the best one-ended contribution its parent can extend, while the parent may combine two children into a complete path that cannot itself be extended upward.",
                math: "returnable = node + max(0,left,right); through-node = node + max(0,left) + max(0,right).",
                use: ["Tree diameter", "Maximum path sum", "An answer may pass through a node using both subtrees"],
                avoid: "Do not return a two-branch path to the parent: that would fork and cease to be a single path.",
                invariant: "Each completed child has returned its best extendable arm, and best records every complete path entirely inside processed subtrees.",
                template: """
                def maximum_path(root):
                    best = float('-inf')
                    def arm(node):
                        nonlocal best
                        if node is None: return 0
                        left = max(0, arm(node.left))
                        right = max(0, arm(node.right))
                        best = max(best, node.val + left + right)
                        return node.val + max(left, right)
                    arm(root)
                    return best
                """,
                drill: "Why may the local best use both child arms while the return value uses one?",
                hint: "Imagine attaching the returned shape to the parent.",
                answer: "A returned fork plus the parent would not be a path; a completed path through the node may legitimately use both arms."
            )
        ],

        "queues-heaps": [
            lesson(
                "dual-heaps", "Two heaps for a running median",
                meaning: "Split seen values into a max-heap for the lower half and min-heap for the upper half. Rebalance so their sizes differ by at most one; the middle value or values sit at the roots.",
                math: "Require max(lower) ≤ min(upper) and |len(lower)-len(upper)| ≤ 1. Store negatives to emulate a max-heap with heapq.",
                use: ["Median after every insertion", "A stream cannot be sorted once at the end", "O(log n) update and O(1) median are desired"],
                avoid: "For a single final median, sorting once is simpler; deletion of arbitrary old values needs lazy-deletion bookkeeping.",
                invariant: "All lower values are no greater than all upper values, and heap sizes are balanced.",
                template: """
                import heapq

                def add_number(lower, upper, value):
                    heapq.heappush(lower, -value)
                    heapq.heappush(upper, -heapq.heappop(lower))
                    if len(upper) > len(lower):
                        heapq.heappush(lower, -heapq.heappop(upper))
                """,
                drill: "With lower size 2 and upper size 3 after insertion, what rebalancing is needed?",
                hint: "The chosen convention keeps lower equally large or one larger.",
                answer: "Move upper's minimum to lower, making sizes 3 and 2."
            )
        ],

        "tries-strings": [
            lesson(
                "counted-trie", "Trie with prefix counts",
                meaning: "Augment every trie node with how many inserted words pass through it. A prefix query or shortest-unique-prefix decision then reads the count along one path.",
                math: "node.count = number of inserted words having node.prefix as a prefix. A prefix becomes unique at the first node with count 1.",
                use: ["Repeated prefix counts", "Shortest unique prefixes", "Words are inserted before many prefix queries"],
                avoid: "Clarify duplicate-word semantics: word frequency and number of distinct words are not the same count.",
                invariant: "After insertion, each visited prefix node's count equals the declared number of words passing through that prefix.",
                template: """
                def insert(root, word):
                    node = root
                    for char in word:
                        node = node.setdefault(char, {'count': 0})
                        node['count'] += 1
                """,
                drill: "After inserting 'dog' and 'dot', what are counts at prefixes 'd', 'do', and 'dog'?",
                hint: "Count how many words pass through each node.",
                answer: "2, 2, and 1 respectively; 'dog' becomes unique at its third character."
            )
        ],

        "graphs": [
            lesson(
                "graph-coloring", "Graph coloring for bipartiteness",
                meaning: "Assign one of two colors to a start node, then force every neighbor to take the opposite color. A same-color edge proves the graph cannot be split into two sides.",
                math: "Seek c(v) ∈ {0,1} with c(u) ≠ c(v) for every edge (u,v). Run from every uncolored component.",
                use: ["Split conflicts into two groups", "Detect odd-cycle obstruction", "The graph may have multiple components"],
                avoid: "A visited set alone is insufficient because you must remember which side each visited node occupies.",
                invariant: "Every processed edge among colored nodes joins opposite colors; queued nodes have a consistent assigned color.",
                template: """
                from collections import deque

                def is_bipartite(graph):
                    color = {}
                    for start in graph:
                        if start in color: continue
                        color[start] = 0; queue = deque([start])
                        while queue:
                            node = queue.popleft()
                            for neighbor in graph[node]:
                                if neighbor not in color:
                                    color[neighbor] = 1 - color[node]; queue.append(neighbor)
                                elif color[neighbor] == color[node]: return False
                    return True
                """,
                drill: "Why is a triangle not bipartite?",
                hint: "Alternate two colors around its three edges.",
                answer: "The third edge joins two nodes forced to have the same color, revealing the odd cycle."
            ),
            lesson(
                "dijkstra", "Dijkstra's shortest paths",
                meaning: "Always expand the unsettled node with the smallest known distance. With nonnegative edges, no later route can improve a node once that minimum-distance entry is accepted.",
                math: "Relax edge u→v by proposed = dist[u]+w. A min-heap orders frontier states by proposed distance.",
                use: ["Weighted shortest paths", "All edge weights are nonnegative", "One source must reach many destinations"],
                avoid: "Negative edges break the greedy proof; unweighted graphs need only BFS, and stale heap entries must be skipped.",
                invariant: "Every settled distance is final; heap entries are candidate path lengths to unsettled nodes.",
                template: """
                import heapq

                def shortest_paths(graph, start):
                    distance = {start: 0}
                    heap = [(0, start)]
                    while heap:
                        cost, node = heapq.heappop(heap)
                        if cost != distance[node]: continue
                        for neighbor, weight in graph[node]:
                            proposed = cost + weight
                            if proposed < distance.get(neighbor, float('inf')):
                                distance[neighbor] = proposed
                                heapq.heappush(heap, (proposed, neighbor))
                    return distance
                """,
                drill: "Why may an older, larger heap entry for a node be ignored?",
                hint: "Compare it with the current distance dictionary value.",
                answer: "A shorter route was already discovered and queued; expanding the stale route cannot improve any nonnegative extension."
            ),
            lesson(
                "dfs-cycle-states", "DFS states for directed cycles",
                meaning: "Use three states: unseen, currently on the recursion path, and completely proven safe. Reaching an on-path node finds a directed cycle; only fully completed nodes may be memoized safe.",
                math: "A back edge to the active DFS stack is exactly a directed cycle witness. Finished nodes have no path to a cycle under the solved recurrence.",
                use: ["Directed cycle detection", "Eventually safe nodes", "Memoize whether future paths terminate"],
                avoid: "A single visited boolean confuses an active ancestor with a completed node reached by another branch.",
                invariant: "Active nodes are exactly the current recursion path; safe nodes have had every outgoing path proven cycle-free.",
                template: """
                def safe_nodes(graph):
                    state = [0] * len(graph)  # 0 unseen, 1 active, 2 safe
                    def safe(node):
                        if state[node]: return state[node] == 2
                        state[node] = 1
                        if any(not safe(next_node) for next_node in graph[node]): return False
                        state[node] = 2
                        return True
                    return [node for node in range(len(graph)) if safe(node)]
                """,
                drill: "Why must a node stay active while exploring all outgoing edges?",
                hint: "A descendant may point back to it.",
                answer: "That back edge is the cycle evidence; marking it finished early would hide the cycle."
            )
        ],

        "union-find": [
            lesson(
                "kruskal", "Kruskal's minimum spanning tree",
                meaning: "Consider edges from cheapest to most expensive. Add an edge exactly when it connects two previously separate components; union-find detects whether it would create a cycle.",
                math: "The cut property says the lightest edge crossing any component cut is safe. A spanning tree ends after n−1 accepted edges.",
                use: ["Minimum-cost undirected connectivity", "Edges are easier to sort than vertices to grow", "Disconnectedness must be detected"],
                avoid: "This is not a shortest-path algorithm and directed graphs do not have the same spanning-tree contract.",
                invariant: "Accepted edges form an acyclic forest of minimum possible cost for its current component partition.",
                template: """
                def mst_cost(node_count, edges, dsu):
                    cost = used = 0
                    for weight, left, right in sorted(edges):
                        if dsu.union(left, right):
                            cost += weight; used += 1
                    return cost if used == node_count - 1 else -1
                """,
                drill: "Why reject an edge whose endpoints already share a component?",
                hint: "There is already a path between them.",
                answer: "Adding it would create a cycle and cannot be necessary for connectivity."
            )
        ],

        "backtracking": [
            lesson(
                "combination-search", "Combination search with a start index",
                meaning: "Build choices in increasing input-index order. A start index prevents revisiting earlier choices, removing permutations of the same combination from the search tree.",
                math: "State (start,path) represents all combinations extending path using candidates at indices start or later.",
                use: ["Order of selected items does not matter", "Choose a subset of fixed or target-dependent size", "Duplicates can be skipped at one recursion depth"],
                avoid: "If order matters, use permutation state; decide explicitly whether a candidate may be reused.",
                invariant: "path is a valid partial combination and every future choice has an allowed index at least start.",
                template: """
                def combinations(values, k):
                    answer, path = [], []
                    def search(start):
                        if len(path) == k: answer.append(path.copy()); return
                        for i in range(start, len(values)):
                            path.append(values[i]); search(i + 1); path.pop()
                    search(0)
                    return answer
                """,
                drill: "Why recurse with i + 1 when values cannot be reused?",
                hint: "The selected index and every earlier one must become unavailable.",
                answer: "It guarantees increasing indices, preventing reuse and reordered duplicates."
            ),
            lesson(
                "permutation-search", "Permutation search with used choices",
                meaning: "At every position, try each value not already used on the current path. Backtracking releases it so another branch can place it elsewhere.",
                math: "The search tree has n choices, then n−1, giving n! leaves for n distinct items.",
                use: ["Output order matters", "Every item is used once", "Assignments occupy distinct positions"],
                avoid: "For combinations, permutations duplicate equivalent selections; duplicate input values need a sorted skip rule or counts.",
                invariant: "path contains exactly the indices marked used, in the order assigned so far.",
                template: """
                def permutations(values):
                    answer, path, used = [], [], [False] * len(values)
                    def search():
                        if len(path) == len(values): answer.append(path.copy()); return
                        for i, value in enumerate(values):
                            if used[i]: continue
                            used[i] = True; path.append(value)
                            search()
                            path.pop(); used[i] = False
                    search(); return answer
                """,
                drill: "What must be undone after a recursive permutation branch returns?",
                hint: "Restore both representations of the choice.",
                answer: "Pop the path value and mark its input index unused."
            ),
            lesson(
                "constraint-pruning", "Constraint-aware pruning",
                meaning: "Before recursing, reject a partial choice that can no longer extend to any valid complete answer. Good pruning is a proof of impossibility, not a guess.",
                math: "Search only states satisfying necessary constraints C(state); this removes entire descendant subtrees while preserving every solution.",
                use: ["Partial states already violate a rule", "Remaining capacity gives lower/upper bounds", "Board, bracket, or segment constraints are locally checkable"],
                avoid: "Never prune merely because a branch looks unlikely; write why no descendant can recover.",
                invariant: "Every explored path is valid so far, and every skipped branch has a stated impossibility proof.",
                template: """
                def generate_parentheses(n):
                    answer = []
                    def search(text, opened, closed):
                        if len(text) == 2 * n: answer.append(text); return
                        if opened < n: search(text + '(', opened + 1, closed)
                        if closed < opened: search(text + ')', opened, closed + 1)
                    search('', 0, 0)
                    return answer
                """,
                drill: "Why may closed never exceed opened in a partial bracket string?",
                hint: "A future opening bracket cannot match an earlier close.",
                answer: "That prefix is already invalid and no suffix can repair its unmatched close."
            ),
            lesson(
                "partition-search", "Backtracking over valid partitions",
                meaning: "Choose the next segment beginning at the current boundary, validate it, then recurse from its end. Reaching the input end records one complete partition.",
                math: "Edges i→j represent valid segment text[i:j]; the task enumerates paths from boundary 0 to n in this DAG.",
                use: ["Split a string or array into valid pieces", "All partitions are requested", "Segment validity can be checked or precomputed"],
                avoid: "Repeated expensive segment validation can dominate; precompute a table when constraints require it.",
                invariant: "path partitions exactly the prefix before start, and every segment in path satisfies the contract.",
                template: """
                def palindrome_partitions(text):
                    answer, path = [], []
                    def search(start):
                        if start == len(text): answer.append(path.copy()); return
                        for end in range(start + 1, len(text) + 1):
                            piece = text[start:end]
                            if piece == piece[::-1]:
                                path.append(piece); search(end); path.pop()
                    search(0); return answer
                """,
                drill: "For 'aab', which first segments are valid palindromes?",
                hint: "Try boundaries after one, two, and three characters.",
                answer: "'a' and 'aa' are valid; 'aab' is not."
            )
        ],

        "bit-math": [
            lesson(
                "popcount", "Count set bits by clearing the lowest one",
                meaning: "The operation n & (n−1) removes exactly the lowest 1 bit. Repeat until zero and count the removals.",
                math: "Subtracting one flips the lowest 1 to 0 and lower zeros to 1; AND with the original clears that 1 and preserves higher bits.",
                use: ["Count 1 bits", "Iterate only over set bits", "Bitmask density may be low"],
                avoid: "Define behavior for negative integers because Python uses an unbounded signed representation.",
                invariant: "count is the number of cleared original 1 bits; n contains exactly the uncleared ones.",
                template: """
                def popcount(number):
                    count = 0
                    while number:
                        number &= number - 1
                        count += 1
                    return count
                """,
                drill: "What does 0b10100 become after one clearing step?",
                hint: "Clear its lowest set bit.",
                answer: "0b10000."
            ),
            lesson(
                "xor-cancellation", "XOR cancellation",
                meaning: "XORing a value with itself produces zero, and XOR with zero leaves a value unchanged. Because order and grouping do not matter, pairs cancel anywhere in the sequence.",
                math: "x⊕x=0, x⊕0=x, and ⊕ is associative and commutative.",
                use: ["Every value except one appears exactly twice", "Pair cancellation solves the exact multiplicity contract", "O(1) extra space is desired"],
                avoid: "Different occurrence counts require a different bit argument; XOR does not compute a mode or preserve ordering.",
                invariant: "accumulator is the XOR of exactly the processed values; all complete equal pairs within them have cancelled.",
                template: """
                def single_number(values):
                    answer = 0
                    for value in values:
                        answer ^= value
                    return answer
                """,
                drill: "Evaluate 4 XOR 1 XOR 4.",
                hint: "Reorder equal values next to each other.",
                answer: "(4 XOR 4) XOR 1 = 0 XOR 1 = 1."
            )
        ],

        "dynamic-programming": [
            lesson(
                "unbounded-amount-dp", "Unbounded amount dynamic programming",
                meaning: "Let dp[amount] answer the problem for one exact total. To allow a denomination repeatedly, build a larger amount from an already solved smaller amount without consuming the denomination globally.",
                math: "For minimum coins, dp[a]=1+min(dp[a−c]) over coins c≤a with reachable a−c; dp[0]=0 and impossible states begin at infinity.",
                use: ["Choices may be reused without limit", "The state is an exact amount or capacity", "Every solution can be classified by its final chosen item"],
                avoid: "For 0/1 choices, update in an order that prevents same-iteration reuse; distinguish minimum, count, and feasibility recurrences.",
                invariant: "When amount a is finalized, dp[a] is the optimum over every legal final coin and each referenced smaller amount is already correct.",
                template: """
                def fewest_coins(coins, target):
                    unreachable = target + 1
                    dp = [0] + [unreachable] * target
                    for amount in range(1, target + 1):
                        for coin in coins:
                            if coin <= amount:
                                dp[amount] = min(dp[amount], 1 + dp[amount - coin])
                    return -1 if dp[target] == unreachable else dp[target]
                """,
                drill: "Why may dp[6] use dp[3] plus coin 3 even if dp[3] also used coin 3?",
                hint: "The problem allows unlimited copies of each denomination.",
                answer: "Reuse is legal, so the smaller optimal state remains a valid predecessor for another copy of the same coin."
            ),
            lesson(
                "rolling-recurrence", "Rolling one-dimensional recurrence",
                meaning: "When the next answer depends on only a few immediately previous states, keep those states in variables instead of an entire table.",
                math: "For dp[i] = f(dp[i−1], dp[i−2]), update older,newer = newer,f(newer,older) after defining base cases.",
                use: ["Climbing-step recurrences", "Decode or cost states depend on a fixed recent window", "Only the final value is requested"],
                avoid: "Keep a table when reconstruction or distant states are needed; handle empty and one-item base cases before rolling.",
                invariant: "Before computing position i, the rolling variables equal the exact DP values for the preceding required positions.",
                template: """
                def climb_ways(n):
                    older, newer = 1, 1
                    for _ in range(2, n + 1):
                        older, newer = newer, older + newer
                    return newer
                """,
                drill: "Why do the simultaneous assignments matter?",
                hint: "The new value needs both old values.",
                answer: "They evaluate the right side before overwriting either prior state."
            ),
            lesson(
                "take-skip-dp", "Take-or-skip dynamic programming",
                meaning: "At each item or capacity, compare solutions that exclude the current choice with solutions that include it and therefore inherit a smaller compatible subproblem.",
                math: "dp[state] = best(skip, value + dp[reduced_state]). Loop direction distinguishes 0/1 use from unlimited reuse.",
                use: ["Non-adjacent selection", "Knapsack or subset sum", "Coin choices combine toward a target"],
                avoid: "Do not copy a recurrence without defining whether each item is reusable and what impossible states contain.",
                invariant: "After processing a declared item prefix, dp[s] is the optimal answer for state s using exactly the allowed items and multiplicities.",
                template: """
                def can_make_sum(values, target):
                    possible = [False] * (target + 1)
                    possible[0] = True
                    for value in values:
                        for total in range(target, value - 1, -1):
                            possible[total] |= possible[total - value]
                    return possible[target]
                """,
                drill: "Why iterate totals downward for 0/1 subset sum?",
                hint: "Ask whether the current item could feed a state later in the same iteration.",
                answer: "Descending order prevents one item from being reused to create multiple states in its own iteration."
            ),
            lesson(
                "grid-dp", "Grid dynamic programming",
                meaning: "Define a state for each cell using already solved neighboring cells, choose an iteration order that respects those dependencies, and treat boundaries explicitly.",
                math: "A common recurrence is dp[r][c] = combine(dp[r−1][c], dp[r][c−1]); other grids may require diagonal state too.",
                use: ["Paths through a grid", "Largest square or local shape", "Movement constraints create an acyclic dependency order"],
                avoid: "If movement can cycle, plain row-major DP is invalid without adding state or changing the graph formulation.",
                invariant: "When a cell is computed, every predecessor named by its recurrence is final and the cell now solves its exact subgrid state.",
                template: """
                def unique_paths(rows, columns):
                    ways = [1] * columns
                    for _ in range(1, rows):
                        for column in range(1, columns):
                            ways[column] += ways[column - 1]
                    return ways[-1]
                """,
                drill: "What does ways[column] mean after updating one row?",
                hint: "It combines the old value from above and new value from the left.",
                answer: "It is the number of valid paths to that cell in the current row."
            ),
            lesson(
                "sequence-dp", "Dynamic programming over sequence prefixes",
                meaning: "Let each state answer the problem for prefixes of one or two sequences. Equal final symbols often extend a smaller answer; unequal symbols branch among deletions, insertions, skips, or matches.",
                math: "For LCS, dp[i][j] uses prefixes a[:i], b[:j]: equal symbols give 1+dp[i−1][j−1], otherwise max(dp[i−1][j],dp[i][j−1]).",
                use: ["Compare or align sequences", "Segmentation such as word break", "Edit, wildcard, or subsequence counting"],
                avoid: "State semantics and base row/column differ by problem; similar-looking tables do not justify copying a recurrence.",
                invariant: "Each filled cell is the exact answer for the prefix pair named by its indices.",
                template: """
                def lcs_length(first, second):
                    dp = [[0] * (len(second) + 1) for _ in range(len(first) + 1)]
                    for i in range(1, len(first) + 1):
                        for j in range(1, len(second) + 1):
                            if first[i - 1] == second[j - 1]: dp[i][j] = 1 + dp[i - 1][j - 1]
                            else: dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
                    return dp[-1][-1]
                """,
                drill: "Why does dp have one extra row and column?",
                hint: "What state represents an empty prefix?",
                answer: "Index 0 represents an empty prefix and supplies explicit base cases without negative indexing."
            ),
            lesson(
                "interval-dp", "Interval dynamic programming",
                meaning: "Solve every shorter contiguous interval before longer intervals. A state for [left,right] decides how its two endpoints interact and reuses interior intervals.",
                math: "dp[l][r] depends on states such as dp[l+1][r], dp[l][r−1], and dp[l+1][r−1], all shorter than r−l+1.",
                use: ["Palindromic subsequences", "Optimal parenthesization or interval games", "Choices are made at both ends of a range"],
                avoid: "This is about subranges, not arbitrary subsets; fill by increasing interval length so dependencies exist.",
                invariant: "Before computing intervals of length L, every state for a shorter interval is correct.",
                template: """
                def longest_palindrome_subsequence(text):
                    n = len(text)
                    dp = [[0] * n for _ in range(n)]
                    for left in range(n - 1, -1, -1):
                        dp[left][left] = 1
                        for right in range(left + 1, n):
                            if text[left] == text[right]: dp[left][right] = 2 + dp[left + 1][right - 1]
                            else: dp[left][right] = max(dp[left + 1][right], dp[left][right - 1])
                    return dp[0][n - 1] if n else 0
                """,
                drill: "Why is a one-character interval initialized to 1?",
                hint: "A character is itself a palindrome.",
                answer: "Its longest palindromic subsequence has length exactly 1."
            )
        ],

        "greedy": [
            lesson(
                "cooldown-frame-counting", "Count a cooldown schedule frame",
                meaning: "The most frequent tasks create separators that any valid schedule must contain. Count the slots forced by those copies, let other tasks fill the gaps, and compare that lower bound with the raw task count.",
                math: "If maximum frequency is f and m task types tie at f, the frame lower bound is (f−1)(cooldown+1)+m. The answer is max(number of tasks, frame).",
                use: ["Only the minimum schedule length is requested", "Equal tasks require a fixed cooldown", "Task identity matters only through frequencies"],
                avoid: "Use an explicit heap/cooldown simulation when an actual schedule must be returned or task cooldowns differ.",
                invariant: "The f−1 complete frames separate every copy of a maximum-frequency task; the m final copies occupy the last frame without requiring trailing idle slots.",
                template: """
                def schedule_length(tasks, cooldown):
                    if not tasks: return 0
                    counts = {}
                    for task in tasks: counts[task] = counts.get(task, 0) + 1
                    maximum = max(counts.values())
                    tied = sum(count == maximum for count in counts.values())
                    frame = (maximum - 1) * (cooldown + 1) + tied
                    return max(len(tasks), frame)
                """,
                drill: "For AAA, BBB and cooldown 2, what frame length is forced?",
                hint: "Here f=3 and m=2.",
                answer: "(3−1)(2+1)+2 = 8, corresponding to a schedule such as A B idle A B idle A B."
            ),
            lesson(
                "greedy-frontier", "Greedy reachability frontier",
                meaning: "Scan every position currently reachable and extend the farthest reachable boundary. For minimum jumps, freeze a layer boundary and count a jump only when the scan exhausts that layer.",
                math: "farthest = max(farthest, i + reach[i]). Positions through current_end are one BFS-like jump layer.",
                use: ["Array values give forward reach", "Need reachability or minimum jumps", "All positions up to a frontier are equivalent candidates for the next expansion"],
                avoid: "Choosing the locally longest jump immediately is different and can fail; update from every position in the current frontier.",
                invariant: "farthest is the greatest index reachable using positions processed so far; no unprocessed reachable position is skipped.",
                template: """
                def can_reach_end(jumps):
                    farthest = 0
                    for index, jump in enumerate(jumps):
                        if index > farthest: return False
                        farthest = max(farthest, index + jump)
                    return True
                """,
                drill: "In [2,0,1], what is farthest after index 0?",
                hint: "Add the index and its reach.",
                answer: "2, so every position through the final index is reachable."
            ),
            lesson(
                "running-extreme", "Best-so-far running extreme",
                meaning: "Keep the most favorable earlier state—such as the lowest price or lowest prefix—and combine it with the current value before updating it.",
                math: "best_at_i = current − min(previous values), or reset when a prefix becomes a liability. The precise extreme follows from the objective.",
                use: ["One earlier choice pairs with the current position", "Profit or contribution depends on a previous minimum/maximum", "A bad accumulated prefix should be discarded"],
                avoid: "Update order matters when the current item cannot pair with itself; write the invariant before compressing the loop.",
                invariant: "Before evaluating position i, extreme summarizes exactly the eligible earlier positions and best covers all completed pairs.",
                template: """
                def best_profit(prices):
                    lowest = float('inf')
                    best = 0
                    for price in prices:
                        best = max(best, price - lowest)
                        lowest = min(lowest, price)
                    return best
                """,
                drill: "Why calculate profit before or alongside updating lowest?",
                hint: "The buy must not occur after the sale.",
                answer: "lowest must describe an eligible current-or-earlier buy; the ordering preserves the time constraint."
            ),
            lesson(
                "two-pass-constraints", "Two directional passes for neighbor constraints",
                meaning: "When each position must satisfy a rule relative to both neighbors, one pass enforces the left rule and a reverse pass enforces the right rule; take the stronger requirement.",
                math: "allocation[i] = max(left_requirement[i], right_requirement[i]). Each direction creates a minimal feasible lower bound.",
                use: ["Constraints point both left and right", "Each directional constraint is locally monotonic", "Need the minimum assignment satisfying all neighbors"],
                avoid: "One pass cannot generally foresee a decreasing run ahead; circular neighbor constraints need additional handling.",
                invariant: "After each directional pass, its corresponding neighbor inequalities are satisfied minimally.",
                template: """
                def candy(ratings):
                    count = len(ratings)
                    rewards = [1] * count
                    for i in range(1, count):
                        if ratings[i] > ratings[i - 1]: rewards[i] = rewards[i - 1] + 1
                    for i in range(count - 2, -1, -1):
                        if ratings[i] > ratings[i + 1]: rewards[i] = max(rewards[i], rewards[i + 1] + 1)
                    return sum(rewards)
                """,
                drill: "Why use max in the reverse pass instead of overwriting?",
                hint: "The left-neighbor constraint must remain satisfied.",
                answer: "max preserves the earlier lower bound while adding the right-neighbor lower bound."
            ),
            lesson(
                "greedy-priority", "Greedy scheduling by remaining priority",
                meaning: "Repeatedly choose the task whose remaining demand is most constraining, while temporarily withholding choices that would violate cooldown or adjacency rules.",
                math: "A max-heap exposes the largest remaining frequency; a cooldown queue records the earliest step at which a task becomes eligible again.",
                use: ["Rearrange to avoid equal neighbors", "Schedule with cooldowns", "Largest remaining multiplicity is the bottleneck"],
                avoid: "State the feasibility/tie rules and release timing; an arbitrary frequent choice can still violate the contract.",
                invariant: "The heap contains exactly eligible tasks by remaining count, and withheld tasks cannot yet be legally selected.",
                template: """
                import heapq

                def alternating_order(counts):
                    heap = [(-count, value) for value, count in counts.items()]
                    heapq.heapify(heap)
                    output, previous = [], None
                    while heap:
                        count, value = heapq.heappop(heap)
                        output.append(value); count += 1
                        if previous is not None: heapq.heappush(heap, previous)
                        previous = (count, value) if count < 0 else None
                    return output
                """,
                drill: "Why hold the previously used task out for one selection?",
                hint: "It cannot be adjacent to itself.",
                answer: "Withholding makes it temporarily ineligible, forcing a different next task."
            ),
            lesson(
                "deficit-reset", "Reset after an impossible prefix",
                meaning: "Track the balance from a candidate start. If it becomes negative at position i, neither that candidate nor any later start inside the failed segment can reach i with more fuel; restart after i. Check global balance separately.",
                math: "If every earlier prefix from start was nonnegative but the sum through i is negative, removing one of those nonnegative prefixes cannot make a start inside the segment succeed.",
                use: ["Circular gas-station feasibility", "A failed cumulative segment rules out all starts inside it", "A separate total sum decides global existence"],
                avoid: "The reset proof depends on additive balances and prefix nonnegativity; it is not a general rule for arbitrary circular searches.",
                invariant: "Every index before candidate_start is proven invalid, tank is the balance since candidate_start, and total is the whole processed balance.",
                template: """
                def gas_start(gas, cost):
                    total = tank = start = 0
                    for index in range(len(gas)):
                        gain = gas[index] - cost[index]
                        total += gain; tank += gain
                        if tank < 0:
                            start = index + 1; tank = 0
                    return start if total >= 0 else -1
                """,
                drill: "When the balance from candidate 2 becomes negative at index 5, which candidates are eliminated?",
                hint: "Every start inside that failed segment reaches index 5 with no extra positive prefix.",
                answer: "Candidates 2 through 5 are eliminated; the next possible start is 6."
            ),
            lesson(
                "last-occurrence-partitions", "Close a segment at its last required occurrence",
                meaning: "Precompute every symbol's final position. While scanning a segment, extend its required end to the farthest last occurrence of any symbol seen; close exactly when the scan reaches that end.",
                math: "end = max(last[text[j]]) over the current segment. At i=end, no symbol in the segment occurs later.",
                use: ["Partition so each label occurs in only one segment", "Need the maximum number of valid segments", "Future obligations are represented by last positions"],
                avoid: "Closing at the first repeated symbol is unsafe; every symbol already inside the segment may extend its boundary.",
                invariant: "end is the farthest future occurrence required by every character scanned since the segment start.",
                template: """
                def partition_labels(text):
                    last = {char: index for index, char in enumerate(text)}
                    start = end = 0
                    lengths = []
                    for index, char in enumerate(text):
                        end = max(end, last[char])
                        if index == end:
                            lengths.append(end - start + 1); start = index + 1
                    return lengths
                """,
                drill: "Why is index == end sufficient to close a segment?",
                hint: "What does end summarize for every character already scanned?",
                answer: "All their last occurrences are at or before end, so none can cross into a later segment."
            )
        ],

        "advanced": [
            lesson(
                "partition-binary-search", "Binary-search a valid partition",
                meaning: "Choose how many left-side elements come from each sorted array. Binary-search one cut until every left value is no greater than every right value; then the median lies on the partition boundaries.",
                math: "Pick i in A and j = half−i in B. Validity requires A[i−1] ≤ B[j] and B[j−1] ≤ A[i], using ±∞ at boundaries.",
                use: ["Median of two sorted arrays", "Need logarithmic time in the smaller input", "A partition condition changes monotonically with one cut"],
                avoid: "This is specialized and boundary-heavy; merging is safer when linear time meets constraints.",
                invariant: "The correct cut in the smaller array remains inside the binary-search bounds, and j preserves the required left size.",
                template: """
                def partition_median(a, b):
                    if len(a) > len(b): return partition_median(b, a)
                    total = len(a) + len(b); half = (total + 1) // 2
                    lo, hi = 0, len(a)
                    while lo <= hi:
                        i = (lo + hi) // 2; j = half - i
                        a_left = a[i - 1] if i else float('-inf')
                        a_right = a[i] if i < len(a) else float('inf')
                        b_left = b[j - 1] if j else float('-inf')
                        b_right = b[j] if j < len(b) else float('inf')
                        if a_left <= b_right and b_left <= a_right: return max(a_left, b_left)
                        if a_left > b_right: hi = i - 1
                        else: lo = i + 1
                """,
                drill: "Why binary-search the shorter array?",
                hint: "The other cut j must stay within its array.",
                answer: "It simplifies valid cut bounds and gives O(log min(m,n)) time."
            ),
            lesson(
                "quickselect", "Quickselect by partition",
                meaning: "Partition values around a pivot. Only recurse into the side containing the desired rank, because the pivot's final position tells how many values are smaller.",
                math: "Expected T(n)=T(n/2)+O(n)=O(n); adversarial pivots can produce O(n²).",
                use: ["Find one kth element", "Average linear time is acceptable", "Mutating or copying the input is allowed"],
                avoid: "Use a heap for streams/top-k maintenance or sorting when deterministic simplicity is more important than expected time.",
                invariant: "After partition, every value left of pivot is on the chosen comparison side and the pivot occupies its final sorted rank.",
                template: """
                def quickselect(values, rank):
                    lo, hi = 0, len(values) - 1
                    while True:
                        pivot = values[hi]; write = lo
                        for i in range(lo, hi):
                            if values[i] <= pivot:
                                values[write], values[i] = values[i], values[write]; write += 1
                        values[write], values[hi] = values[hi], values[write]
                        if write == rank: return values[write]
                        if write < rank: lo = write + 1
                        else: hi = write - 1
                """,
                drill: "After pivot reaches rank 5 but desired rank is 2, which side remains?",
                hint: "All values right of rank 5 are even larger in the partition order.",
                answer: "Search only the left partition."
            ),
            lesson(
                "multiway-merge", "Heap merge of many sorted streams",
                meaning: "Put the first item from every nonempty sorted stream into a heap. Removing the smallest item reveals which stream should contribute its next item.",
                math: "With k streams and N total values, the heap holds at most k entries, giving O(N log k) time.",
                use: ["Merge k sorted lists", "Repeatedly select the smallest stream head", "Inputs can be consumed incrementally"],
                avoid: "Include a deterministic tie field when payload nodes are not comparable; for two streams, plain two pointers is simpler.",
                invariant: "The heap contains exactly the first unconsumed item of every nonempty stream; therefore its minimum is globally next.",
                template: """
                import heapq

                def merge_streams(streams):
                    heap, output = [], []
                    for source, values in enumerate(streams):
                        if values: heapq.heappush(heap, (values[0], source, 0))
                    while heap:
                        value, source, index = heapq.heappop(heap); output.append(value)
                        if index + 1 < len(streams[source]):
                            heapq.heappush(heap, (streams[source][index + 1], source, index + 1))
                    return output
                """,
                drill: "Why push only one item per stream initially?",
                hint: "Sortedness tells which item could be next from that stream.",
                answer: "Later items cannot precede the current head, so they become candidates only after it is consumed."
            ),
            lesson(
                "kadane", "Kadane's best-ending-here recurrence",
                meaning: "At each position, decide whether to extend the previous contiguous range or start fresh at the current value. Keep both the best ending here and best anywhere.",
                math: "ending[i] = max(a[i], ending[i−1]+a[i]); best = max(best, ending[i]). A circular answer compares ordinary maximum with total−minimum subarray.",
                use: ["Maximum contiguous sum", "Circular maximum via complement", "A harmful prefix should be discarded"],
                avoid: "For circular arrays, handle the all-negative case because selecting the complement of the whole array would mean an empty range.",
                invariant: "ending is the maximum sum of a nonempty subarray ending at the current position; best covers all endings processed.",
                template: """
                def maximum_subarray(values):
                    ending = best = values[0]
                    for value in values[1:]:
                        ending = max(value, ending + value)
                        best = max(best, ending)
                    return best
                """,
                drill: "At value 4 after ending = -3, extend or restart?",
                hint: "Compare 4 with -3 + 4.",
                answer: "Restart at 4 because 4 > 1."
            ),
            lesson(
                "paired-product-extremes", "Paired maximum and minimum products",
                meaning: "A negative value swaps usefulness: the smallest product ending previously can become the largest. Carry both extremes, and at each position consider starting fresh or extending either one.",
                math: "newMax=max(x,x·oldMax,x·oldMin); newMin=min(x,x·oldMax,x·oldMin).",
                use: ["Maximum product of a contiguous subarray", "Multiplication by negatives reverses order", "Zero can reset a multiplicative run"],
                avoid: "Tracking only the maximum loses a large-magnitude negative state that a later negative could make optimal.",
                invariant: "maximum and minimum are respectively the extreme products of all nonempty subarrays ending at the current position; best covers every ending seen.",
                template: """
                def maximum_product(values):
                    maximum = minimum = best = values[0]
                    for value in values[1:]:
                        candidates = (value, value * maximum, value * minimum)
                        maximum, minimum = max(candidates), min(candidates)
                        best = max(best, maximum)
                    return best
                """,
                drill: "If previous extremes are 6 and -12 and the new value is -2, what are the new extremes?",
                hint: "Compare -2, -12, and 24.",
                answer: "The new maximum is 24 and the new minimum is -12."
            )
        ],

        "advanced-data-structures": [
            lesson(
                "difference-array", "Difference array for range updates",
                meaning: "Record only where a range addition starts and where it stops. One final prefix sum reconstructs the value at every position.",
                math: "To add Δ on inclusive [l,r], diff[l]+=Δ and diff[r+1]−=Δ when r+1 exists. Then value[i]=Σ₀ⁱ diff.",
                use: ["Many range additions", "Final point values are requested after updates", "Updates can be processed offline"],
                avoid: "If point queries must interleave online with updates, use a Fenwick or segment tree; confirm inclusive versus half-open endpoints.",
                invariant: "diff records every change in running contribution at exact boundaries; its prefix sum equals all active updates.",
                template: """
                def apply_range_additions(length, updates):
                    diff = [0] * (length + 1)
                    for left, right, change in updates:
                        diff[left] += change
                        diff[right + 1] -= change
                    values, running = [], 0
                    for i in range(length):
                        running += diff[i]; values.append(running)
                    return values
                """,
                drill: "To add 3 on inclusive [1,3], which diff entries change?",
                hint: "Start at 1 and stop immediately after 3.",
                answer: "diff[1] += 3 and diff[4] -= 3."
            )
        ],

        "ml-tensor-foundations": [
            lesson(
                "log-likelihood", "Stable negative log-likelihood",
                meaning: "Convert logits into log-probabilities without first forming tiny probabilities: subtract a per-row log-sum-exp, select the target class, negate, then reduce over examples.",
                math: "log softmax(z)ᵧ = zᵧ − (m + log Σⱼ exp(zⱼ−m)), where m=max(z). Cross-entropy is the mean negative target log-probability.",
                use: ["Multiclass cross-entropy from logits", "Large logits require numerical stability", "Targets are class indices"],
                avoid: "Do not take log(softmax(logits)) naively; define reduction, batch axis, target bounds, and empty-batch behavior.",
                invariant: "Each example is normalized only across its class axis, and contributes exactly one target-class negative log-probability.",
                template: """
                import math

                def cross_entropy_row(logits, target):
                    maximum = max(logits)
                    log_partition = maximum + math.log(sum(math.exp(x - maximum) for x in logits))
                    return log_partition - logits[target]
                """,
                drill: "Why subtract the row maximum inside exp?",
                hint: "Softmax is unchanged by adding one constant to every logit.",
                answer: "It prevents overflow while the normalization algebra cancels the shift exactly."
            ),
            lesson(
                "masked-reduction", "Masked reduction with the correct denominator",
                meaning: "Multiply out invalid positions and divide by the number of valid items, not by the padded width. Keep numerator and denominator shapes explicit.",
                math: "mean = Σᵢ maskᵢxᵢ / max(Σᵢ maskᵢ, 1). For vector features, reduce mask over positions and preserve the feature axis.",
                use: ["Variable-length padded batches", "Mean pooling valid tokens", "Metrics or losses exclude selected positions"],
                avoid: "A zero-valid-item row needs a declared result; broadcasting the mask over the wrong axis silently corrupts values.",
                invariant: "Only valid elements contribute to the numerator, and the denominator counts those same semantic elements.",
                template: """
                def masked_mean(sequence, mask):
                    width = len(sequence[0])
                    total = [0.0] * width
                    count = 0
                    for vector, valid in zip(sequence, mask):
                        if valid:
                            total = [a + b for a, b in zip(total, vector)]
                            count += 1
                    return [value / count for value in total] if count else total
                """,
                drill: "Two real tokens and two padding tokens are present. What denominator should mean pooling use?",
                hint: "Padding represents no observation.",
                answer: "2, the count of real tokens—not the padded length 4."
            )
        ],

        "ml-training-mechanics": [
            lesson(
                "normalization", "Normalization axes and train/eval state",
                meaning: "Choose which axes define one normalization population, compute mean and variance there, normalize with epsilon, then optionally apply learned scale and shift. Batch normalization also updates running statistics only during training.",
                math: "y = γ(x−μ)/√(σ²+ε)+β. Layer norm reduces feature axes per example; batch norm reduces batch/spatial axes per channel.",
                use: ["Layer normalization", "Batch normalization", "Feature standardization with explicit axes"],
                avoid: "Do not copy reduction axes between layer norm and batch norm; distinguish biased batch variance from any running-variance convention.",
                invariant: "Each μ and σ² describe exactly the declared population; output scaling broadcasts only across its matching feature/channel axis.",
                template: """
                def normalize(values, epsilon=1e-5):
                    mean = sum(values) / len(values)
                    variance = sum((value - mean) ** 2 for value in values) / len(values)
                    return [(value - mean) / (variance + epsilon) ** 0.5 for value in values]
                """,
                drill: "Across which axis does layer norm usually normalize a (batch, features) tensor?",
                hint: "Each example receives its own statistics.",
                answer: "Across features within each batch example."
            ),
            lesson(
                "stochastic-training", "Stochastic training behavior",
                meaning: "Some layers deliberately behave differently during training and evaluation. In inverted dropout, sample a mask during training and scale retained activations so their expectation matches evaluation.",
                math: "y = mask·x/(1−p), mask~Bernoulli(1−p), so E[y]=x. During evaluation y=x.",
                use: ["Implement dropout", "Reproducibility needs an explicit random seed", "Train/eval modes change computation"],
                avoid: "Handle p=0 and reject p≥1; never sample dropout masks during evaluation.",
                invariant: "Each training element is independently retained under the stated RNG, and expected activation scale is preserved.",
                template: """
                import random

                def inverted_dropout(values, probability, training=True):
                    if not training or probability == 0: return values[:]
                    keep = 1 - probability
                    return [value / keep if random.random() < keep else 0.0 for value in values]
                """,
                drill: "With dropout p=0.25, by what factor is a retained activation scaled?",
                hint: "Divide by keep probability.",
                answer: "1 / 0.75 = 4/3."
            )
        ],

        "ml-neural-architectures": [
            lesson(
                "pooling", "Pooling windows and boundary conventions",
                meaning: "Move a fixed spatial window by a stated stride and reduce each patch, usually by maximum or mean. Unlike convolution, pooling has no learned kernel weights.",
                math: "For no padding, output = floor((input−kernel)/stride)+1 on each axis.",
                use: ["Spatial downsampling", "Local maximum or average", "Translation-tolerant summary of fixed patches"],
                avoid: "Do not assume stride equals kernel size or that partial boundary windows are included; define padding and tie behavior.",
                invariant: "Each output cell reduces exactly the input coordinates belonging to its declared window.",
                template: """
                def max_pool_1d(values, width, stride):
                    output = []
                    for start in range(0, len(values) - width + 1, stride):
                        output.append(max(values[start:start + width]))
                    return output
                """,
                drill: "Length 5, width 2, stride 2, no padding: how many outputs?",
                hint: "Valid starts are 0 and 2; start 4 lacks a full window.",
                answer: "2 outputs."
            ),
            lesson(
                "attention-masking", "Attention masks before softmax",
                meaning: "Mark forbidden query-key pairs in score space before normalization, so softmax assigns them zero probability and renormalizes only over allowed keys.",
                math: "softmax(scores + mask), where forbidden entries receive −∞. A causal mask permits key index k ≤ query index q.",
                use: ["Causal self-attention", "Padding tokens must be ignored", "Different examples have different allowed key sets"],
                avoid: "Masking after softmax without renormalizing leaks probability mass; fully masked rows require an explicit convention.",
                invariant: "Every allowed row's probabilities sum to 1 and every forbidden key has exactly zero weight.",
                template: """
                import math

                def causal_softmax_row(scores, query_index):
                    allowed = scores[:query_index + 1]
                    maximum = max(allowed)
                    weights = [math.exp(value - maximum) for value in allowed]
                    total = sum(weights)
                    return [value / total for value in weights] + [0.0] * (len(scores) - len(allowed))
                """,
                drill: "For query position 2, which key positions are allowed by a standard causal mask?",
                hint: "A token may see itself and the past, not the future.",
                answer: "Keys 0, 1, and 2 are allowed; later keys are masked."
            ),
            lesson(
                "multihead-reshape", "Split, transpose, and merge attention heads",
                meaning: "Project the model dimension, reshape it into head and per-head dimensions, move the head axis beside batch, run attention independently, then invert that layout exactly.",
                math: "D = H·d. (B,T,D) → (B,T,H,d) → (B,H,T,d), then reverse after attention.",
                use: ["Multi-head attention", "An operation runs independently per head", "einops can make axis transformations auditable"],
                avoid: "Never reshape without checking element order; D must be divisible by H and the inverse permutation must match.",
                invariant: "Every feature belongs to exactly one head, while batch and token identities are unchanged across the layout transform.",
                template: """
                def split_heads(sequence, head_count):
                    # Plain Python shape sketch: (tokens, model) -> (heads, tokens, head_dim)
                    head_dim = len(sequence[0]) // head_count
                    return [[[row[h * head_dim + d] for d in range(head_dim)]
                             for row in sequence] for h in range(head_count)]
                """,
                drill: "Input shape (B,T,12) with 3 heads becomes what attention layout?",
                hint: "Each head receives 12/3 features.",
                answer: "(B,3,T,4)."
            )
        ],

        "ml-research-engineering": [
            lesson(
                "clustering", "K-means assignment and centroid update",
                meaning: "Alternate two explicit steps: assign each point to its nearest centroid, then replace every centroid by the mean of its assigned points. Define ties and empty clusters.",
                math: "assignmentᵢ = argminₖ ||xᵢ−μₖ||²; μₖ = mean{xᵢ: assignmentᵢ=k}.",
                use: ["One K-means iteration", "Unsupervised centroid clustering", "Vectorized distance computation"],
                avoid: "The algorithm finds a local optimum; initialization, equal-distance ties, and empty clusters materially affect results.",
                invariant: "Assignments correspond to the old centroid set; every nonempty updated centroid is the exact mean of its assigned points.",
                template: """
                def nearest_centroid(point, centroids):
                    distances = [sum((x - center) ** 2 for x, center in zip(point, centroid))
                                 for centroid in centroids]
                    return min(range(len(centroids)), key=lambda index: (distances[index], index))
                """,
                drill: "Why include index in the argmin tie key?",
                hint: "Two centroids may be equally distant.",
                answer: "It declares a deterministic smallest-index tie rule."
            ),
            lesson(
                "padding-masks", "Padding variable-length sequences",
                meaning: "Allocate a rectangular batch using the longest selected length, copy each sequence into its valid prefix, and create a parallel mask that distinguishes real tokens from padding.",
                math: "padded has shape (B,Lmax,…); mask[b,t]=1 exactly when t < original_length[b]. Truncation changes that effective length.",
                use: ["Batch variable-length sequences", "Build attention masks", "Downstream reductions must ignore padding"],
                avoid: "A padding token value alone may also be legitimate data; preserve lengths or an explicit boolean mask.",
                invariant: "For every batch row, mask true positions correspond one-to-one with copied source items after the declared truncation policy.",
                template: """
                def pad_sequences(sequences, pad_value=0):
                    width = max((len(sequence) for sequence in sequences), default=0)
                    padded, mask = [], []
                    for sequence in sequences:
                        missing = width - len(sequence)
                        padded.append(sequence + [pad_value] * missing)
                        mask.append([True] * len(sequence) + [False] * missing)
                    return padded, mask
                """,
                drill: "Why return a mask if the pad value is 0?",
                hint: "Could 0 be a real token or measurement?",
                answer: "Yes. The mask records validity independently of the chosen filler value."
            ),
            lesson(
                "gradient-accumulation", "Gradient accumulation with sample weighting",
                meaning: "Combine microbatch gradients using the same denominator as the intended full-batch loss, then perform one optimizer step. Unequal microbatches must contribute in proportion to their example or token counts.",
                math: "g = (Σᵢ nᵢgᵢ)/(Σᵢ nᵢ) when each gᵢ is a mean over nᵢ units.",
                use: ["Simulate a larger batch under memory limits", "Microbatches have unequal sizes", "Masked token losses have different valid counts"],
                avoid: "Do not average microbatch means equally unless denominators match; zero gradients and optimizer stepping frequency are separate concerns.",
                invariant: "The accumulated numerator and denominator describe the exact semantic population of the intended combined loss.",
                template: """
                def combine_mean_gradients(gradients, counts):
                    total_count = sum(counts)
                    combined = [0.0] * len(gradients[0])
                    for gradient, count in zip(gradients, counts):
                        for i, value in enumerate(gradient):
                            combined[i] += value * count
                    return [value / total_count for value in combined]
                """,
                drill: "Microbatches of 2 and 8 examples have mean gradients 1 and 3. What is the combined scalar gradient?",
                hint: "Weight each mean by its example count.",
                answer: "(2×1 + 8×3)/10 = 2.6."
            )
        ]
    ]
}
