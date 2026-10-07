import Foundation

/// One additional boundary or counterexample for every distinct problem design.
/// Every curriculum entry has its own canonical catalog key; legacy mastery IDs
/// still resolve to that key while progress is migrated from older builds.
enum AdversarialTestCatalog {
    static func tests(for problemID: String) -> [AlgorithmTestCase] {
        let canonical = SolutionComparisonCatalog.canonicalID(for: problemID)
        if let entry = entries[canonical] {
            return [.adversarial("Challenge · \(entry.name)", entry.argumentsJSON)]
        }
        if let entry = MLInterviewCurriculum.adversarialArguments[canonical] {
            return [.adversarial("Challenge · \(entry.0)", entry.1)]
        }
        return []
    }

    static var coveredCanonicalIDs: Set<String> {
        Set(entries.keys).union(MLInterviewCurriculum.adversarialArguments.keys)
    }

    private struct Entry: Sendable {
        let name: String
        let argumentsJSON: String
    }

    private static func entry(_ name: String, _ argumentsJSON: String) -> Entry {
        Entry(name: name, argumentsJSON: argumentsJSON)
    }

    private static let entries: [String: Entry] = [
        // MARK: Arrays & hashing
        "arrays.sum-positive": entry("mixed signs with a large positive", #"[[-10,0,1,2,-3,20]]"#),
        "arrays.pair-indices": entry("first discovered pair wins", #"[[1,4,2,3],5]"#),
        "arrays.same-character-counts": entry("equal lengths but different multiplicities", #"["aab","abb"]"#),
        "arrays.longest-consecutive": entry("unsorted values with a duplicate", #"[[100,4,200,1,3,2,2]]"#),
        "arrays.product-except-self": entry("two zeros", #"[[-1,0,2,0]]"#),
        "arrays.has-duplicate": entry("duplicate values far apart", #"[[1,2,3,4,1]]"#),
        "arrays.group-anagrams": entry("group and member order both matter", #"[["bat","tab","eat","tea","tan"]]"#),
        "arrays.top-frequent": entry("frequency conflicts with numeric order", #"[[9,1,9,2,9,2],2]"#),
        "arrays.longest-target-sum": entry("several competing target spans", #"[[-1,2,3,-2,2,-3,3],3]"#),
        "mastery.arrays-hashing.missing-number": entry("unsorted missing interior value", #"[[4,2,1,0]]"#),
        "mastery.arrays-hashing.majority": entry("majority interrupted by several values", #"[[1,2,1,1,3,1,1]]"#),
        "mastery.arrays-hashing.target-subarrays": entry("overlapping zero-sum spans", #"[[0,0,0],0]"#),

        // MARK: Two pointers
        "pointers.clean-palindrome": entry("mixed case, spaces, and punctuation", #"["A man, a plan, a canal: Panama"]"#),
        "pointers.sorted-pair": entry("multiple pairs require the widest indices", #"[[1,2,3,4,6,8],10]"#),
        "pointers.water-container": entry("best walls are not the tallest adjacent pair", #"[[1,8,6,2,5,4,8,3,7]]"#),
        "pointers.three-sum": entry("duplicate values form one triplet", #"[[-2,0,0,2,2]]"#),
        "pointers.trapped-water": entry("several uneven basins", #"[[4,2,0,3,2,5]]"#),
        "pointers.move-zeros": entry("many separated zeros", #"[[0,1,0,0,2,3,0]]"#),
        "pointers.sorted-squares": entry("largest magnitude is negative", #"[[-7,-3,2,3,11]]"#),
        "pointers.closest-pair": entry("negative and positive candidates", #"[[-10,-2,1,3,8],0]"#),
        "pointers.four-sum": entry("all values identical", #"[[2,2,2,2,2],8]"#),
        "mastery.two-pointers.merge-sorted": entry("duplicates across both inputs", #"[[-3,1,4],[-2,1,5]]"#),
        "mastery.two-pointers.subsequence": entry("characters separated throughout text", #"["axbycz","abc"]"#),
        "mastery.two-pointers.pairs-below": entry("negative values and strict boundary", #"[[-3,-1,0,2,4],2]"#),

        // MARK: Sliding window
        "window.best-fixed-sum": entry("all window sums are negative", #"[[-5,-1,-3],2]"#),
        "window.longest-unique": entry("left boundary must never move backward", #"["abba"]"#),
        "window.longest-replacement": entry("stale maximum frequency remains valid", #"["AABABBA",1]"#),
        "window.permutation-starts": entry("overlapping permutations", #"["abab","ab"]"#),
        "window.minimum-cover": entry("extra copies before the shortest cover", #"["aaabdec","abc"]"#),
        "window.min-positive-sum": entry("answer begins late in the array", #"[[1,2,3,4,5],11]"#),
        "window.max-ones": entry("window must shrink more than once", #"[[0,0,1,1,0,1,1,1,0],2]"#),
        "window.repeated-dna": entry("one window repeats many times", #"["AAAAAAAAAAAAA"]"#),
        "window.maximum-values": entry("maximum repeatedly leaves the window", #"[[9,1,3,7,2,6],3]"#),
        "mastery.sliding-window.max-vowels": entry("every short window is all vowels", #"["aeiou",2]"#),
        "mastery.sliding-window.minimum-positive": entry("single late value meets target", #"[[1,1,1,1,10],10]"#),
        "mastery.sliding-window.k-distinct": entry("several forced left-boundary moves", #"[[1,2,1,3,4,2,3],2]"#),

        // MARK: Stacks and linked lists
        "stack.balanced-brackets": entry("several correctly nested bracket kinds", #"["(([]){})"]"#),
        "stack.remove-adjacent": entry("removals expose a new pair", #"["azxxzy"]"#),
        "stack.warmer-waits": entry("classic unresolved-stack cascade", #"[[73,74,75,71,69,72,76,73]]"#),
        "stack.evaluate-postfix": entry("division occurs before addition", #"[["4","13","5","/","+"]]"#),
        "stack.largest-histogram": entry("two increasing bars", #"[[2,4]]"#),
        "stack.min-add-parentheses": entry("unmatched closers then openers", #"[")))(("]"#),
        "stack.asteroid-collisions": entry("one right mover loses to repeated left movers", #"[[1,-2,-2,-2]]"#),
        "stack.decode-string": entry("nested repetition", #"["2[a3[b]]"]"#),
        "stack.next-greater-circular": entry("wraparound resolves the final small value", #"[[1,2,1]]"#),
        "mastery.stack.simplify-path": entry("dots and parent traversal", #"["/a/./b/../../c/"]"#),
        "mastery.stack.next-smaller": entry("a late minimum resolves several values", #"[[5,2,6,1,3]]"#),
        "mastery.stack.validate-sequences": entry("several delayed pops", #"[[1,2,3,4,5],[4,5,3,2,1]]"#),
        "mastery.linked-lists.middle-node": entry("even reordered chain chooses second middle", #"[[10,20,30,40],[2,3,1,-1],0]"#),
        "mastery.linked-lists.reverse-values": entry("head is not array index zero", #"[[5,6,7,8],[-1,0,3,1],2]"#),
        "mastery.linked-lists.cycle-entry": entry("tail enters a later cycle", #"[[1,2,3,4,2],0]"#),

        // MARK: Binary search
        "binary.first-position": entry("long duplicate run", #"[[1,2,2,2,2,3],2]"#),
        "binary.rotated-minimum": entry("pivot near the end", #"[[4,5,6,7,0,1,2]]"#),
        "binary.search-rotated": entry("target lies after the pivot", #"[[4,5,6,7,0,1,2],0]"#),
        "binary.minimum-speed": entry("rounding changes the feasible speed", #"[[30,11,23,4,20],6]"#),
        "binary.ship-capacity": entry("several days need balanced prefixes", #"[[1,2,3,4,5,6,7,8,9,10],5]"#),
        "binary.exact-search": entry("target in the right half", #"[[1,3,5,7,9],7]"#),
        "binary.integer-root": entry("large non-square near integer limits", #"[2147395599]"#),
        "binary.peak-index": entry("unique interior peak", #"[[1,2,3,1]]"#),
        "mastery.binary-search.lower-bound": entry("target falls between duplicate run and next value", #"[[1,2,2,4],3]"#),
        "mastery.binary-search.kth-missing": entry("several gaps before and after values", #"[[2,3,4,7,11],5]"#),
        "mastery.binary-search.split-largest": entry("optimal split is not equal length", #"[[7,2,5,10,8],2]"#),

        // MARK: Intervals
        "intervals.merge-ranges": entry("unsorted transitive overlaps", #"[[[1,4],[0,2],[3,5],[10,12],[11,11]]]"#),
        "intervals.insert-range": entry("new range bridges several intervals", #"[[[1,2],[5,7],[10,12]],[3,11]]"#),
        "intervals.intersection": entry("alternating intersections and touching endpoints", #"[[[0,2],[5,10],[13,23],[24,25]],[[1,5],[8,12],[15,24],[25,26]]]"#),
        "intervals.erase-overlaps": entry("greedy must keep earliest ending range", #"[[[1,2],[2,3],[3,4],[1,3]]]"#),
        "intervals.meeting-rooms": entry("rooms are released and reused at boundaries", #"[[[0,10],[5,15],[10,20],[15,25]]]"#),
        "intervals.can-attend": entry("unsorted touching meetings", #"[[[5,10],[0,5],[10,12]]]"#),
        "intervals.covered-queries": entry("negative overlapping ranges and boundary queries", #"[[[-5,-1],[-3,2]],[-6,-5,0,3]]"#),
        "intervals.minimum-groups": entry("closed intervals conflict at shared endpoints", #"[[[1,3],[3,5],[3,3],[6,8]]]"#),
        "mastery.intervals.union-length": entry("two overlapping clusters", #"[[[1,5],[2,6],[8,10],[9,12]]]"#),
        "mastery.intervals.max-overlap": entry("half-open boundary releases before a new start", #"[[[0,5],[1,4],[2,3],[5,8]]]"#),
        "mastery.intervals.carpool": entry("drop-off and pickup share a location", #"[[[2,1,5],[3,3,7],[2,5,8]],4]"#),

        // MARK: Trees and heaps
        "trees.maximum-depth": entry("deep branch after null gaps", #"[[1,2,3,4,null,null,7,8]]"#),
        "trees.inorder-values": entry("complete tree verifies traversal order", #"[[4,2,6,1,3,5,7]]"#),
        "trees.level-averages": entry("negative values and sparse levels", #"[[1,-2,3,null,4,null,5]]"#),
        "trees.search-tree-ancestor": entry("ancestor is below the root", #"[[6,2,8,0,4,7,9,null,null,3,5],3,5]"#),
        "trees.valid-search-tree": entry("deep descendant violates root bound", #"[[10,5,15,null,null,6,20]]"#),
        "trees.preorder-values": entry("sparse children preserve heap positions", #"[[1,2,3,null,4,5]]"#),
        "trees.same-tree": entry("same prefix but different deeper shape", #"[[1,2,3,null,4],[1,2,3,4]]"#),
        "trees.diameter": entry("longest path crosses the root", #"[[1,2,3,4,5]]"#),
        "mastery.trees.leaf-count": entry("leaves occur on different depths", #"[[1,2,3,4,null,null,7]]"#),
        "mastery.trees.right-view": entry("rightmost visible node comes from a left subtree", #"[[1,2,3,null,5,6,null]]"#),
        "mastery.trees.max-path": entry("best path excludes a negative root", #"[[-10,9,20,null,null,15,7]]"#),
        "mastery.queues-heaps.kth-smallest": entry("duplicate occupies multiple ranks", #"[[5,3,5,1,2],4]"#),
        "mastery.queues-heaps.closest-points": entry("equal distances require coordinate tie-breaks", #"[[[1,1],[-1,1],[0,2]],2]"#),
        "mastery.queues-heaps.running-medians": entry("values arrive above and below both heaps", #"[[5,15,1,3]]"#),

        // MARK: Tries and strings
        "mastery.tries-strings.kmp-index": entry("overlapping prefix forces fallback", #"["ababcabcabababd","ababd"]"#),
        "mastery.tries-strings.prefix-counts": entry("duplicate words and empty prefix", #"[["app","apple","app","ape"],["app","ap",""]]"#),
        "mastery.tries-strings.unique-prefixes": entry("one word is a prefix of another", #"[["dog","dove","dot"]]"#),

        // MARK: Graphs and union-find
        "graphs.island-count": entry("diagonal land remains disconnected", #"[[[1,0,1],[0,1,0],[1,0,1]]]"#),
        "graphs.route-exists": entry("route crosses several edges while another component is isolated", #"[6,[[0,1],[1,2],[2,3],[4,5]],0,3]"#),
        "graphs.bipartite": entry("disconnected graph contains an odd cycle", #"[[[1],[0],[3,4],[2,4],[2,3]]]"#),
        "graphs.shortest-grid-path": entry("shortest route bends around walls", #"[[[0,0,1,0],[1,0,1,0],[0,0,0,0]]]"#),
        "graphs.course-cycle": entry("three-course dependency cycle", #"[4,[[1,0],[2,1],[0,2],[3,2]]]"#),
        "graphs.components": entry("connected cluster plus isolated nodes", #"[6,[[0,1],[1,2],[3,4]]]"#),
        "graphs.flood-fill": entry("region touches through several turns", #"[[[1,1,0],[1,0,0],[1,1,1]],0,0,9]"#),
        "graphs.word-ladder": entry("multiple routes but only one shortest", #"["hit","cog",["hot","dot","dog","lot","log","cog","hog"]]"#),
        "mastery.graphs.provinces": entry("two nontrivial provinces", #"[[[1,1,0,0],[1,1,0,0],[0,0,1,1],[0,0,1,1]]]"#),
        "mastery.graphs.network-delay": entry("cheaper route uses an intermediate node", #"[4,[[0,1,1],[0,2,4],[1,2,2],[2,3,1]],0]"#),
        "mastery.graphs.safe-nodes": entry("cycle predecessors differ from terminal branches", #"[[[1,2],[2,3],[5],[0],[5],[],[]]]"#),
        "mastery.union-find.redundant-edge": entry("cycle appears only after a long chain", #"[5,[[0,1],[1,2],[2,3],[3,4],[0,4]]]"#),
        "mastery.union-find.component-stream": entry("redundant union leaves component count unchanged", #"[5,[[0,1],[1,2],[0,2],[3,4],[2,4]]]"#),
        "mastery.union-find.mst-cost": entry("cheapest edges include a non-obvious bridge", #"[5,[[0,1,3],[1,2,1],[0,2,4],[2,3,2],[3,4,1],[1,4,10]]]"#),

        // MARK: Backtracking and bit manipulation
        "backtracking.all-subsets": entry("input order differs from numeric order", #"[[3,1]]"#),
        "backtracking.permutations": entry("depth-first order follows input positions", #"[[2,1,3]]"#),
        "backtracking.target-combinations": entry("same target has several depths", #"[[2,3,5],8]"#),
        "backtracking.word-search": entry("path bends and cannot reuse a cell", #"[[["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]],"SEE"]"#),
        "backtracking.queens-count": entry("five-queen board", #"[5]"#),
        "backtracking.phone-letters": entry("two four-letter keypad digits", #"["79"]"#),
        "backtracking.generate-parentheses": entry("four pairs exercise deeper pruning", #"[4]"#),
        "backtracking.palindrome-partitions": entry("whole string and single letters both work", #"["efe"]"#),
        "mastery.backtracking.combinations": entry("middle-sized lexicographic combination set", #"[5,3]"#),
        "mastery.backtracking.restore-address": entry("zeros create several valid splits", #"["101023"]"#),
        "mastery.backtracking.letter-cases": entry("mixed existing case and digits", #"["a1B2"]"#),
        "mastery.bit-math.popcount": entry("many adjacent set bits", #"[1023]"#),
        "mastery.bit-math.single-number": entry("unpaired value is between repeated pairs", #"[[4,1,2,1,2]]"#),
        "mastery.bit-math.mod-power": entry("large exponent wraps repeatedly", #"[2,100,1000]"#),

        // MARK: Dynamic programming
        "dp.climb-ways": entry("larger staircase exposes recurrence errors", #"[7]"#),
        "dp.unique-paths": entry("rectangular grid", #"[4,5]"#),
        "dp.max-non-adjacent": entry("best choices are separated unevenly", #"[[2,1,4,9]]"#),
        "dp.fewest-coins": entry("greedy largest-first choice is suboptimal", #"[[1,5,10,12],15]"#),
        "dp.longest-common-subsequence": entry("repeated characters offer competing alignments", #"["abcba","abcbcba"]"#),
        "dp.min-climbing-cost": entry("cheap final interior step changes the start choice", #"[[10,15,20,1]]"#),
        "dp.decode-ways": entry("zero is valid only as part of a pair", #"["11106"]"#),
        "dp.longest-palindrome-subsequence": entry("best palindrome skips interior characters", #"["agbdba"]"#),
        "mastery.dynamic-programming.knapsack": entry("best value is a combination, not one item", #"[[2,3,4,5],[3,4,5,8],7]"#),
        "mastery.dynamic-programming.equal-partition": entry("partition exists without equal halves by position", #"[[1,5,11,5]]"#),
        "mastery.dynamic-programming.max-square": entry("largest square begins away from origin", #"[[[0,1,1,1],[1,1,1,1],[0,1,1,1]]]"#),

        // MARK: Greedy
        "greedy.reach-end": entry("large early jumps still hit a dead end", #"[[3,2,1,0,4]]"#),
        "greedy.max-meetings": entry("short meetings beat one long meeting", #"[[[1,10],[2,3],[3,4],[4,5],[5,6]]]"#),
        "greedy.minimum-arrows": entry("one interval bridges only part of the set", #"[[[1,6],[2,8],[7,12],[10,16]]]"#),
        "greedy.partition-labels": entry("early character reappears near the end", #"["abacbc"]"#),
        "greedy.gas-start": entry("only a late station can recover the deficit", #"[[1,2,3,4,5],[3,4,5,1,2]]"#),
        "greedy.stock-profit": entry("best sale is not the final day", #"[[3,1,4,8,2,5]]"#),
        "greedy.candy": entry("descending suffix requires a reverse pass", #"[[1,3,4,5,2]]"#),
        "greedy.task-scheduler": entry("most frequent task dominates cooldown", #"[["A","A","A","A","B","B","C"],2]"#),
        "mastery.greedy.cookies": entry("small resources must be matched deliberately", #"[[1,2,3],[1,1,3]]"#),
        "mastery.greedy.minimum-jumps": entry("reachable path needs changing jump frontiers", #"[[2,3,1,1,4]]"#),
        "mastery.greedy.reorganize": entry("several tied frequencies require deterministic choices", #"["aaabbc"]"#),

        // MARK: Advanced synthesis and data structures
        "advanced.longest-increasing": entry("optimal subsequence replaces earlier tails", #"[[10,9,2,5,3,7,101,18]]"#),
        "advanced.word-break": entry("successful split differs from greedy longest prefix", #"["cars",["car","ca","rs"]]"#),
        "advanced.edit-distance": entry("all three operation types compete", #"["intention","execution"]"#),
        "advanced.maximum-product-subarray": entry("four negatives require tracking both extremes", #"[[-1,-2,-9,-6]]"#),
        "advanced.median-sorted": entry("even combined length", #"[[1,2],[3,4]]"#),
        "advanced.kth-largest": entry("duplicate large values occupy separate ranks", #"[[5,3,5,2,4],2]"#),
        "advanced.merge-sorted-lists": entry("negative values and repeated heads", #"[[[-5,1,4],[-5,2],[],[0,3]]]"#),
        "advanced.longest-valid-parentheses": entry("valid prefix followed by an unmatched closer", #"["(()())())"]"#),
        "mastery.advanced.circular-sum": entry("best subarray wraps around the boundary", #"[[5,-3,5]]"#),
        "mastery.advanced.wildcard": entry("stars absorb separated spans", #"["adceb","*a*b"]"#),
        "mastery.advanced.distinct-subsequences": entry("repeated source letters create several choices", #"["babgbag","bag"]"#),
        "mastery.advanced-data-structures.fenwick-prefix": entry("updates and queries alternate", #"[[2,-1,3,4],[[1,3],[0,1,5],[1,1],[0,3,-2],[1,3]]]"#),
        "mastery.advanced-data-structures.range-add": entry("overlapping positive and negative changes", #"[6,[[0,5,2],[1,3,-1],[3,5,4]],[0,1,3,5]]"#),
        "mastery.advanced-data-structures.lru": entry("get refreshes recency before eviction", #"[2,[["put",1,10],["put",2,20],["get",1],["put",3,30],["get",2],["get",1],["get",3]]]"#)
    ]
}
