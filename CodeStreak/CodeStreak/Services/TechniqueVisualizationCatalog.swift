import Foundation

enum TechniqueVisualRole: String, Hashable, Sendable {
    case neutral
    case active
    case candidate
    case resolved
    case warning
}

struct TechniqueVisualCell: Hashable, Sendable {
    let label: String
    let note: String?
    let role: TechniqueVisualRole
}

struct TechniqueVisualStage: Hashable, Sendable {
    let label: String
    let detail: String?
    let role: TechniqueVisualRole
}

struct TechniqueVisualNode: Identifiable, Hashable, Sendable {
    let id: String
    let label: String
    let x: Double
    let y: Double
    let role: TechniqueVisualRole
}

struct TechniqueVisualEdge: Identifiable, Hashable, Sendable {
    var id: String { "\(from)->\(to)-\(label ?? "")" }
    let from: String
    let to: String
    let label: String?
    let isDirected: Bool
    let role: TechniqueVisualRole
}

struct TechniqueVisualInterval: Identifiable, Hashable, Sendable {
    let id: String
    let label: String
    let start: Double
    let end: Double
    let role: TechniqueVisualRole
}

enum TechniqueVisualKind: Hashable, Sendable {
    case sequence([TechniqueVisualCell])
    case flow([TechniqueVisualStage])
    case stack([TechniqueVisualCell], isQueue: Bool)
    case graph(nodes: [TechniqueVisualNode], edges: [TechniqueVisualEdge])
    case intervals([TechniqueVisualInterval])
    case matrix([[TechniqueVisualCell]])
}

struct TechniqueVisualizationSpec: Hashable, Sendable {
    let title: String
    let takeaway: String
    let kind: TechniqueVisualKind
}

/// Small, worked pictures for every algorithm lesson. Each picture isolates
/// the invariant or state transition a learner should be able to redraw on
/// paper before attempting the associated problems.
enum TechniqueVisualizationCatalog {
    static func spec(for techniqueID: String) -> TechniqueVisualizationSpec? {
        specs[techniqueID]
    }

    static var techniqueIDs: Set<String> { Set(specs.keys) }

    private static func c(
        _ label: String,
        _ role: TechniqueVisualRole = .neutral,
        note: String? = nil
    ) -> TechniqueVisualCell {
        TechniqueVisualCell(label: label, note: note, role: role)
    }

    private static func sequence(
        _ title: String,
        _ takeaway: String,
        _ cells: [TechniqueVisualCell]
    ) -> TechniqueVisualizationSpec {
        TechniqueVisualizationSpec(title: title, takeaway: takeaway, kind: .sequence(cells))
    }

    private static func flow(
        _ title: String,
        _ takeaway: String,
        _ stages: [(String, String?, TechniqueVisualRole)]
    ) -> TechniqueVisualizationSpec {
        TechniqueVisualizationSpec(
            title: title,
            takeaway: takeaway,
            kind: .flow(stages.map { TechniqueVisualStage(label: $0.0, detail: $0.1, role: $0.2) })
        )
    }

    private static func stack(
        _ title: String,
        _ takeaway: String,
        _ cells: [TechniqueVisualCell],
        queue: Bool = false
    ) -> TechniqueVisualizationSpec {
        TechniqueVisualizationSpec(title: title, takeaway: takeaway, kind: .stack(cells, isQueue: queue))
    }

    private static func n(
        _ id: String,
        _ label: String,
        _ x: Double,
        _ y: Double,
        _ role: TechniqueVisualRole = .neutral
    ) -> TechniqueVisualNode {
        TechniqueVisualNode(id: id, label: label, x: x, y: y, role: role)
    }

    private static func e(
        _ from: String,
        _ to: String,
        _ label: String? = nil,
        directed: Bool = true,
        role: TechniqueVisualRole = .neutral
    ) -> TechniqueVisualEdge {
        TechniqueVisualEdge(from: from, to: to, label: label, isDirected: directed, role: role)
    }

    private static func graph(
        _ title: String,
        _ takeaway: String,
        _ nodes: [TechniqueVisualNode],
        _ edges: [TechniqueVisualEdge]
    ) -> TechniqueVisualizationSpec {
        TechniqueVisualizationSpec(title: title, takeaway: takeaway, kind: .graph(nodes: nodes, edges: edges))
    }

    private static func intervals(
        _ title: String,
        _ takeaway: String,
        _ rows: [(String, Double, Double, TechniqueVisualRole)]
    ) -> TechniqueVisualizationSpec {
        TechniqueVisualizationSpec(
            title: title,
            takeaway: takeaway,
            kind: .intervals(rows.enumerated().map { index, row in
                TechniqueVisualInterval(
                    id: "\(index)-\(row.0)", label: row.0,
                    start: row.1, end: row.2, role: row.3
                )
            })
        )
    }

    private static func matrix(
        _ title: String,
        _ takeaway: String,
        _ rows: [[TechniqueVisualCell]]
    ) -> TechniqueVisualizationSpec {
        TechniqueVisualizationSpec(title: title, takeaway: takeaway, kind: .matrix(rows))
    }

    private static let specs: [String: TechniqueVisualizationSpec] = [
        "state-invariant": flow(
            "Compress history into one trustworthy state",
            "The state changes; the sentence describing what it means stays true.",
            [("prefix 0…i", "processed", .resolved), ("state Sᵢ", "summary", .active), ("next aᵢ", "update", .candidate)]
        ),
        "hash-set": flow(
            "Ask the set instead of rescanning",
            "A value either reaches an existing bucket or creates one new distinct entry.",
            [("value 7", "query", .candidate), ("{2, 7, 9}", "seen", .active), ("present", "O(1) avg", .resolved)]
        ),
        "hash-map": flow(
            "A key points directly to its meaning",
            "Decide what the stored value represents before writing the update.",
            [("'a'", "key", .candidate), ("dictionary", "lookup", .active), ("count = 3", "value", .resolved)]
        ),
        "opposing-pointers": sequence(
            "Discard a dominated boundary",
            "After each comparison, every candidate outside L…R has been proved impossible.",
            [c("1", .candidate, note: "L"), c("3"), c("4", .active), c("8"), c("10", .candidate, note: "R")]
        ),
        "read-write-pointers": sequence(
            "Read ahead; write only accepted values",
            "Everything before write is already the final compacted output.",
            [c("2", .resolved), c("5", .resolved), c("_", .active, note: "write"), c("0", .warning), c("7", .candidate, note: "read")]
        ),
        "fixed-window": sequence(
            "Slide by removing one and adding one",
            "The window width never changes, so only the two boundary values affect the next sum.",
            [c("4", .warning, note: "−4"), c("2", .active), c("7", .active), c("1", .active), c("5", .candidate, note: "+5")]
        ),
        "variable-window": sequence(
            "Expand, then shrink until valid again",
            "Each boundary moves only forward, even when shrinking happens inside the scan.",
            [c("a", .resolved), c("b", .candidate, note: "L"), c("c", .active), c("a", .active), c("d", .candidate, note: "R")]
        ),
        "lifo-stack": stack(
            "The latest unresolved item is handled first",
            "A closing event can interact only with the item currently on top.",
            [c("(", .neutral), c("[", .neutral), c("{", .active, note: "top")]
        ),
        "monotonic-stack": stack(
            "Pop values that can no longer matter",
            "The surviving stack is ordered; every removed value has just found its boundary.",
            [c("8", .neutral), c("5", .neutral), c("3", .active, note: "top"), c("4", .warning, note: "pop 3")]
        ),
        "sentinel-rewiring": graph(
            "A dummy node makes the first edit ordinary",
            "Every deletion rewires predecessor.next, including deletion of the original head.",
            [n("s", "dummy", 0.12, 0.5, .active), n("a", "A", 0.40, 0.5, .warning), n("b", "B", 0.68, 0.5, .resolved), n("z", "∅", 0.90, 0.5)],
            [e("s", "a"), e("a", "b", "skip A", role: .warning), e("s", "b", "rewire", role: .active), e("b", "z")]
        ),
        "fast-slow": graph(
            "Different speeds must meet inside a cycle",
            "Once both pointers are in the loop, their relative distance changes by one each round.",
            [n("a", "1", 0.10, 0.5), n("b", "2", 0.32, 0.5), n("c", "3", 0.55, 0.25, .active), n("d", "4", 0.82, 0.5, .candidate), n("e", "5", 0.55, 0.78)],
            [e("a", "b"), e("b", "c"), e("c", "d"), e("d", "e"), e("e", "c")]
        ),
        "boundary-search": sequence(
            "Keep the transition inside [lo, hi)",
            "One comparison removes half of the remaining answer positions.",
            [c("F", .resolved), c("F", .resolved), c("F", .candidate, note: "lo"), c("T", .active, note: "mid"), c("T"), c("T", .candidate, note: "hi")]
        ),
        "answer-search": sequence(
            "Binary-search a monotone answer space",
            "Search values, not array positions: infeasible answers precede feasible ones.",
            [c("2", .resolved), c("3", .resolved), c("4", .warning), c("5", .active, note: "first ✓"), c("6", .candidate), c("7", .candidate)]
        ),
        "sort-merge": intervals(
            "Sorted starts expose overlaps locally",
            "Only the current merged interval can overlap the next interval.",
            [("current", 0.08, 0.56, .active), ("next", 0.42, 0.82, .candidate), ("merged", 0.08, 0.82, .resolved)]
        ),
        "sweep-events": intervals(
            "Turn intervals into ordered +1 and −1 events",
            "The running prefix total is exactly the number of active intervals.",
            [("A  +1", 0.10, 0.55, .active), ("B  +1", 0.32, 0.78, .candidate), ("active = 2", 0.32, 0.55, .resolved)]
        ),
        "tree-dfs": graph(
            "Children return summaries to their parent",
            "Postorder guarantees both child results exist before F(node) is computed.",
            [n("r", "F(r)", 0.50, 0.14, .active), n("l", "F(L)", 0.25, 0.58, .resolved), n("q", "F(R)", 0.75, 0.58, .resolved)],
            [e("l", "r", "return", role: .resolved), e("q", "r", "return", role: .resolved)]
        ),
        "tree-bfs": graph(
            "The queue contains one frontier at a time",
            "Capture the queue length before expanding to separate depth d from depth d+1.",
            [n("r", "0", 0.50, 0.12, .resolved), n("a", "1", 0.25, 0.50, .active), n("b", "1", 0.75, 0.50, .active), n("c", "2", 0.12, 0.86, .candidate), n("d", "2", 0.38, 0.86, .candidate)],
            [e("r", "a"), e("r", "b"), e("a", "c"), e("a", "d")]
        ),
        "fifo-queue": stack(
            "First in, first out",
            "Remove from the front while new work joins at the back.",
            [c("A", .active, note: "front"), c("B"), c("C", .candidate, note: "back")],
            queue: true
        ),
        "heap": graph(
            "The minimum is always at the root",
            "Only one root-to-leaf path needs repair after insertion or removal.",
            [n("r", "2", 0.50, 0.12, .active), n("a", "5", 0.26, 0.52), n("b", "7", 0.74, 0.52), n("c", "9", 0.12, 0.87), n("d", "8", 0.40, 0.87)],
            [e("r", "a", directed: false), e("r", "b", directed: false), e("a", "c", directed: false), e("a", "d", directed: false)]
        ),
        "trie": graph(
            "Shared prefixes share nodes",
            "Following one character edge consumes one character of the query.",
            [n("r", "•", 0.08, 0.48), n("c", "c", 0.30, 0.48, .active), n("a", "a", 0.52, 0.28), n("o", "o", 0.52, 0.68), n("t", "t", 0.78, 0.28, .resolved), n("w", "w", 0.78, 0.68)],
            [e("r", "c"), e("c", "a"), e("c", "o"), e("a", "t"), e("o", "w")]
        ),
        "prefix-fallback": sequence(
            "Reuse the longest prefix that is also a suffix",
            "On mismatch, π tells you the next viable matched length without rereading text.",
            [c("a", .resolved), c("b", .resolved), c("a", .active), c("b", .active), c("a", .candidate, note: "π=3"), c("c", .warning)]
        ),
        "graph-search": graph(
            "Mark a node when it enters the frontier",
            "Visited prevents cycles and guarantees each vertex is expanded at most once.",
            [n("a", "A", 0.12, 0.50, .resolved), n("b", "B", 0.38, 0.20, .active), n("c", "C", 0.38, 0.80, .active), n("d", "D", 0.72, 0.50, .candidate)],
            [e("a", "b", directed: false), e("a", "c", directed: false), e("b", "d", directed: false), e("c", "d", directed: false)]
        ),
        "topological-sort": graph(
            "Only zero-indegree nodes are ready",
            "Removing a ready node deletes its outgoing obligations and may unlock another node.",
            [n("a", "A · 0", 0.12, 0.50, .active), n("b", "B · 1", 0.48, 0.25, .candidate), n("c", "C · 1", 0.48, 0.75, .candidate), n("d", "D · 2", 0.84, 0.50)],
            [e("a", "b"), e("a", "c"), e("b", "d"), e("c", "d")]
        ),
        "disjoint-set": graph(
            "Each component has one representative",
            "Union changes a root pointer; find follows roots to test connectivity.",
            [n("r", "root", 0.50, 0.12, .active), n("a", "A", 0.20, 0.54), n("b", "B", 0.50, 0.54), n("c", "C", 0.80, 0.54), n("d", "D", 0.20, 0.88)],
            [e("a", "r"), e("b", "r"), e("c", "r"), e("d", "a")]
        ),
        "choose-explore-undo": graph(
            "A search tree is reversible state change",
            "Undo restores the exact parent state before the next sibling choice.",
            [n("r", "[]", 0.50, 0.12), n("a", "[1]", 0.25, 0.50, .active), n("b", "[2]", 0.75, 0.50, .candidate), n("c", "[1,2]", 0.12, 0.86, .resolved), n("d", "[1,3]", 0.38, 0.86)],
            [e("r", "a", "choose 1"), e("r", "b", "choose 2"), e("a", "c"), e("a", "d")]
        ),
        "bit-mask": sequence(
            "One bit records one yes/no membership",
            "Testing bit i answers whether element i belongs to the represented subset.",
            [c("1", .active, note: "3"), c("0", note: "2"), c("1", .active, note: "1"), c("0", note: "0")]
        ),
        "fast-power": flow(
            "Square the base; halve the exponent",
            "An odd exponent contributes one current base before the next halving.",
            [("3¹³", nil, .candidate), ("3 · 9⁶", "odd", .active), ("3 · 81³", "square", .active), ("result", "log n steps", .resolved)]
        ),
        "memo-tabulation": graph(
            "Compute each distinct state once",
            "Many recursion paths can point to the same subproblem; memoization merges them.",
            [n("a", "F(5)", 0.50, 0.12), n("b", "F(4)", 0.28, 0.50, .active), n("c", "F(3)", 0.72, 0.50, .active), n("d", "F(2)", 0.50, 0.86, .resolved)],
            [e("a", "b"), e("a", "c"), e("b", "c", "reuse", role: .active), e("b", "d"), e("c", "d", "reuse", role: .active)]
        ),
        "greedy-choice": flow(
            "Commit only after proving the exchange",
            "Replace an optimum's first choice with the greedy one without making it worse.",
            [("unknown optimum", "O", .neutral), ("exchange", "swap first", .active), ("contains greedy", "O′", .resolved)]
        ),
        "lis-tails": sequence(
            "tails stores best endings, not one subsequence",
            "A smaller ending leaves more room for a future value to extend that length.",
            [c("2", .resolved, note: "len 1"), c("5", .resolved, note: "len 2"), c("7", .warning), c("6", .active, note: "replace"), c("9", .candidate)]
        ),
        "synthesis": flow(
            "Let n rule out unaffordable designs",
            "Estimate cost before coding, then inspect every nested operation.",
            [("n = 10⁵", "constraint", .candidate), ("n²", "too large", .warning), ("n log n", "possible", .active), ("n", "ideal", .resolved)]
        ),
        "fenwick-tree": graph(
            "Each index owns a power-of-two suffix block",
            "lowbit determines both the stored range and the next query/update container.",
            [n("8", "8", 0.50, 0.10), n("4", "4", 0.25, 0.45, .active), n("6", "6", 0.62, 0.45), n("2", "2", 0.12, 0.82), n("5", "5", 0.48, 0.82, .candidate), n("7", "7", 0.78, 0.82)],
            [e("2", "4"), e("4", "8"), e("5", "6"), e("6", "8"), e("7", "8")]
        ),
        "lru-map-list": graph(
            "Lookup and recency are two views of the same nodes",
            "The map finds a node; the linked list moves it to the most-recent end.",
            [n("m", "map", 0.12, 0.24, .active), n("a", "A", 0.25, 0.68, .warning), n("b", "B", 0.50, 0.68), n("c", "C", 0.76, 0.68, .resolved)],
            [e("m", "b", "lookup"), e("a", "b", "LRU", directed: false), e("b", "c", "MRU", directed: false)]
        ),
        "shape-indexing": matrix(
            "One output cell contracts one row with one column",
            "The k axis disappears because its products are summed; i and j remain.",
            [[c("A[i,0]", .active), c("A[i,1]", .active), c("A[i,2]", .active)], [c("×", .neutral), c("B[0…2,j]", .candidate), c("→ C[i,j]", .resolved)]]
        ),
        "stable-normalization": sequence(
            "Shift logits before exponentiating",
            "Subtracting the maximum preserves probabilities while keeping the largest exponent at 1.",
            [c("1002", .candidate), c("1001"), c("999"), c("−max", .active), c("0", .resolved), c("−1", .resolved), c("−3", .resolved)]
        ),
        "computation-graph": graph(
            "Gradients flow backward through local derivatives",
            "When paths merge, their gradient contributions add.",
            [n("x", "x", 0.10, 0.50), n("g", "g", 0.36, 0.50, .candidate), n("f", "f", 0.63, 0.50, .active), n("l", "L", 0.90, 0.50, .resolved)],
            [e("x", "g", "∂g/∂x"), e("g", "f", "∂f/∂g"), e("f", "l", "∂L/∂f")]
        ),
        "optimizer-state": flow(
            "Adam carries two histories per parameter",
            "The first moment tracks direction; the second tracks squared magnitude.",
            [("gradient gₜ", nil, .candidate), ("mₜ", "mean", .active), ("vₜ", "square", .active), ("parameter", "update", .resolved)]
        ),
        "receptive-field": matrix(
            "A kernel sees one local patch at a time",
            "Multiply aligned patch and kernel entries, sum them, then slide to the next output location.",
            [[c("1"), c("2", .active), c("3", .active), c("4")], [c("5"), c("6", .active), c("7", .active), c("8")], [c("9"), c("10"), c("11"), c("12")]]
        ),
        "attention": flow(
            "Queries score keys, then mix values",
            "The softmax row is a probability distribution over which values one query reads.",
            [("Q · Kᵀ", "scores", .candidate), ("÷ √d + mask", "stabilize", .active), ("softmax", "weights", .active), ("weights · V", "output", .resolved)]
        ),
        "metric-accounting": flow(
            "Weight each group by how many examples it represents",
            "A mean of batch means is correct only when every batch has equal size.",
            [("2 × 0.4", "small batch", .candidate), ("8 × 0.8", "large batch", .active), ("÷ 10", nil, .neutral), ("0.72", "global mean", .resolved)]
        ),
        "ranked-state": sequence(
            "A complete key makes ties deterministic",
            "Primary score orders quality; the second field fixes equal-score order.",
            [c("(−9, A)", .resolved), c("(−9, B)", .resolved), c("(−7, C)", .candidate), c("(−5, D)")]
        ),

        "linear-accumulator": flow(
            "One pass updates only the needed summary",
            "The accumulator after i items is already the correct answer for that prefix.",
            [("[−2,4,3]", "stream", .candidate), ("0 → 0 → 4 → 7", "total", .active), ("7", "answer", .resolved)]
        ),
        "canonical-key": flow(
            "Equivalent objects collapse to one signature",
            "The signature must preserve exactly the distinctions the problem cares about.",
            [("tea", nil, .candidate), ("sort", nil, .active), ("(a,e,t)", "key", .resolved), ("eat", "same group", .resolved)]
        ),
        "prefix-sums": sequence(
            "Range sums become boundary subtraction",
            "P[r] contains the left prefix too, so subtract P[l] to remove it.",
            [c("0", .resolved, note: "P0"), c("3", note: "P1"), c("8", .active, note: "P2 = l"), c("10"), c("17", .candidate, note: "P4 = r")]
        ),
        "prefix-suffix": sequence(
            "Combine everything left with everything right",
            "Two directional passes avoid recomputing either side for every excluded index.",
            [c("Lᵢ", .resolved, note: "prefix"), c("aᵢ", .warning, note: "exclude"), c("Rᵢ", .candidate, note: "suffix"), c("Lᵢ·Rᵢ", .active, note: "answer")]
        ),
        "known-total": flow(
            "Compare the expected whole with the observed part",
            "The domain guarantee turns one missing value into one subtraction.",
            [("0+1+2+3", "expected 6", .active), ("0+1+3", "observed 4", .candidate), ("6−4", nil, .neutral), ("2", "missing", .resolved)]
        ),
        "boyer-moore": flow(
            "Cancel unequal pairs",
            "A strict majority cannot be completely cancelled by all non-majority values.",
            [("A A B A C A A", nil, .candidate), ("cancel A/B", nil, .warning), ("cancel A/C", nil, .warning), ("A", "candidate", .resolved)]
        ),
        "deterministic-ranking": sequence(
            "Make every tie-break part of the key",
            "Sorting the compound key yields the same answer on every run.",
            [c("b:2", .candidate), c("a:2", .candidate), c("c:1"), c("a:2", .resolved, note: "first"), c("b:2", .resolved)]
        ),
        "sequence-start-expansion": sequence(
            "Walk only from true run starts",
            "If x−1 exists, another start will account for x; beginning here would repeat work.",
            [c("3", .active, note: "start"), c("4", .resolved), c("5", .resolved), c("8", .candidate, note: "start"), c("20", .candidate, note: "start")]
        ),
        "boundary-extremes": sequence(
            "Move the shorter wall",
            "With width shrinking, keeping the limiting height cannot improve area.",
            [c("2", .warning, note: "L move"), c("8"), c("6", .active), c("7"), c("5", .candidate, note: "R")]
        ),
        "sorted-k-sum": sequence(
            "Fix one value; solve a monotone residual",
            "Sorting turns the remaining two-value search into safe pointer moves.",
            [c("−2", .active, note: "fixed"), c("0", .candidate, note: "L"), c("1"), c("3"), c("4", .candidate, note: "R")]
        ),
        "merge-streams": sequence(
            "Emit the smaller stream head",
            "The chosen head is no larger than any unconsumed value in either sorted stream.",
            [c("1A", .resolved), c("2B", .resolved), c("4B", .candidate, note: "j"), c("5A", .candidate, note: "i"), c("8A")]
        ),
        "subsequence-scan": sequence(
            "Advance the target only on a match",
            "matched is the longest target prefix embedded in the source seen so far.",
            [c("a", .resolved), c("x", .neutral), c("b", .resolved), c("y"), c("c", .active, note: "matched=3")]
        ),
        "two-sided-water": sequence(
            "Water is limited by the lower side maximum",
            "Once one side's maximum is lower, the opposite side cannot change that position's answer.",
            [c("4", .candidate, note: "left max"), c("1", .active, note: "+3"), c("2", .active, note: "+2"), c("5", .candidate, note: "right max")]
        ),
        "pair-batch-counting": sequence(
            "One inequality proves a whole batch",
            "If the largest partner at r works, every smaller partner between l and r works too.",
            [c("1", .active, note: "L"), c("2", .resolved), c("3", .resolved), c("5", .resolved), c("7", .candidate, note: "R")]
        ),
        "requirement-counts": flow(
            "Track satisfied categories, not repeated full comparisons",
            "formed changes only when a category crosses its required threshold.",
            [("need A×2, B×1", nil, .neutral), ("window A×2", "A formed", .active), ("+ B", "B formed", .candidate), ("formed = 2", "valid", .resolved)]
        ),
        "monotonic-deque": sequence(
            "Keep only possible future maxima",
            "Smaller values behind a newer larger value can never become a window maximum.",
            [c("9", .resolved, note: "front max"), c("7"), c("3", .warning, note: "pop"), c("6", .active, note: "new")]
        ),
        "stale-window-maximum": sequence(
            "A historical maximum still bounds the best length",
            "It may not describe the current window exactly, but it never causes the optimum length to be missed.",
            [c("A", .active), c("A", .active), c("B"), c("A", .active), c("C", .candidate, note: "replace 2")]
        ),
        "balance-counter": flow(
            "A single bracket type needs only net balance",
            "Negative balance exposes a close with no earlier opener immediately.",
            [("(", "1", .active), ("(", "2", .active), (")", "1", .resolved), (")", "0", .resolved)]
        ),
        "nested-frames": stack(
            "Each opener suspends one complete context",
            "Closing a frame restores the exact count and text owned by its parent.",
            [c("root", .neutral), c("3×", .neutral), c("2×", .active, note: "current")]
        ),
        "monotonic-span-boundaries": sequence(
            "A shorter bar closes taller rectangles",
            "The saved start index remembers how far each surviving height may extend left.",
            [c("2@0"), c("5@1", .warning, note: "pop"), c("6@2", .warning, note: "pop"), c("2@1", .active, note: "extend"), c("3", .candidate)]
        ),
        "circular-scan": sequence(
            "Two logical passes expose one wraparound future",
            "Modulo revisits values without duplicating the answer array or stack entries.",
            [c("1₀", .resolved), c("2₁", .resolved), c("1₂", .active), c("1₀", .candidate, note: "wrap"), c("2₁", .candidate)]
        ),
        "sentinel-index-boundary": sequence(
            "Store the boundary before a valid suffix",
            "The sentinel −1 makes a valid prefix use the same length formula i−b.",
            [c("−1", .active, note: "base"), c("(", .neutral), c("(", .neutral), c(")", .resolved), c(")", .resolved, note: "length 4")]
        ),
        "linked-traversal": graph(
            "Follow next pointers, not storage positions",
            "The path order can be completely different from the array's physical order.",
            [n("0", "slot 0", 0.12, 0.25), n("2", "slot 2", 0.50, 0.72, .active), n("1", "slot 1", 0.84, 0.25, .resolved)],
            [e("0", "2", "next"), e("2", "1", "next")]
        ),
        "floyd-cycle-entry": graph(
            "Reset one pointer to find the cycle entrance",
            "After the meeting, equal-speed distances to the entrance are congruent.",
            [n("h", "head", 0.08, 0.50, .candidate), n("u", "μ", 0.34, 0.50), n("e", "entry", 0.58, 0.24, .active), n("m", "meet", 0.86, 0.50, .resolved), n("z", "loop", 0.58, 0.80)],
            [e("h", "u"), e("u", "e"), e("e", "m"), e("m", "z"), e("z", "e")]
        ),
        "rotated-search": sequence(
            "At least one half is normally sorted",
            "Use the sorted half's bounds to decide which half can contain the target.",
            [c("6", .active, note: "lo"), c("7"), c("1", .candidate, note: "mid"), c("2"), c("3"), c("4", .candidate, note: "hi")]
        ),
        "slope-search": sequence(
            "Follow an uphill side toward some peak",
            "An increasing neighbor guarantees a local maximum exists in that direction.",
            [c("1"), c("3", .candidate), c("5", .active, note: "mid"), c("8", .resolved, note: "go right"), c("4")]
        ),
        "sorted-query-sweep": intervals(
            "Move one pointer through ordered ranges and queries",
            "Neither stream rewinds, so the post-sort sweep is linear.",
            [("range 1", 0.05, 0.35, .resolved), ("range 2", 0.48, 0.84, .active), ("query →", 0.60, 0.62, .candidate)]
        ),
        "interval-streams": intervals(
            "Emit the overlap; advance the interval that ends first",
            "The earlier-ending interval cannot overlap anything later in the other stream after this step.",
            [("A", 0.10, 0.62, .active), ("B", 0.42, 0.88, .candidate), ("A ∩ B", 0.42, 0.62, .resolved)]
        ),
        "interval-scheduling": intervals(
            "Choose the compatible interval that finishes first",
            "The earliest finish leaves at least as much room for every later choice.",
            [("chosen", 0.08, 0.34, .resolved), ("reject", 0.18, 0.58, .warning), ("next", 0.40, 0.67, .active), ("later", 0.72, 0.92, .candidate)]
        ),
        "active-interval-heap": intervals(
            "The heap is the live frontier at the query point",
            "Expire intervals that end before q; the heap root answers the chosen priority among survivors.",
            [("expired", 0.05, 0.28, .warning), ("active A", 0.22, 0.70, .active), ("active B", 0.48, 0.90, .candidate), ("q", 0.56, 0.58, .resolved)]
        ),
        "heap-array-tree": graph(
            "Array indices encode the complete-tree edges",
            "Null structural slots cannot be removed without changing every descendant relationship.",
            [n("0", "0", 0.50, 0.12, .active), n("1", "1", 0.25, 0.50), n("2", "2", 0.75, 0.50), n("3", "3", 0.12, 0.87), n("4", "4", 0.38, 0.87)],
            [e("0", "1", "2i+1"), e("0", "2", "2i+2"), e("1", "3"), e("1", "4")]
        ),
        "heap-level-scan": sequence(
            "Level endpoints double predictably",
            "Once you know one level's final index e, the next level ends at 2e+2.",
            [c("0", .resolved, note: "d0"), c("1", .active), c("2", .active, note: "end 2"), c("3"), c("4"), c("5"), c("6", .candidate, note: "end 6")]
        ),
        "traversal-orders": graph(
            "The visit point defines the traversal",
            "Preorder visits before children, inorder between them, and postorder after both.",
            [n("r", "N", 0.50, 0.15, .active), n("l", "L", 0.24, 0.68, .candidate), n("q", "R", 0.76, 0.68, .candidate)],
            [e("r", "l", directed: false), e("r", "q", directed: false)]
        ),
        "bst-invariants": graph(
            "Ancestor bounds travel down the tree",
            "A node must satisfy the whole interval, not merely compare correctly with its parent.",
            [n("r", "10", 0.50, 0.14), n("l", "5", 0.25, 0.55, .active), n("q", "15", 0.75, 0.55), n("x", "12", 0.38, 0.88, .warning)],
            [e("r", "l", "(−∞,10)"), e("r", "q", "(10,∞)"), e("l", "x", "must <10", role: .warning)]
        ),
        "postorder-aggregation": graph(
            "Return one branch; score two branches locally",
            "A parent may extend only a single path, while the global answer may pass through both children.",
            [n("r", "+4", 0.50, 0.14, .active), n("l", "+6", 0.25, 0.62, .resolved), n("q", "+5", 0.75, 0.62, .resolved)],
            [e("l", "r", "return 6"), e("q", "r", "return 5"), e("l", "q", "through = 15", directed: false, role: .active)]
        ),
        "dual-heaps": sequence(
            "Split the stream around the median",
            "Every lower value is ≤ every upper value, and heap sizes differ by at most one.",
            [c("1", .resolved, note: "max-heap"), c("3", .active, note: "lower top"), c("|", .neutral), c("5", .candidate, note: "upper top"), c("8", .neutral)]
        ),
        "counted-trie": graph(
            "The first count-1 prefix is unique",
            "Counts describe how many inserted words still share each prefix node.",
            [n("r", "• 3", 0.08, 0.50), n("c", "c · 3", 0.32, 0.50), n("a", "a · 2", 0.56, 0.28), n("o", "o · 1", 0.56, 0.72, .active), n("t", "t · 1", 0.82, 0.28, .candidate)],
            [e("r", "c"), e("c", "a"), e("c", "o"), e("a", "t")]
        ),
        "graph-coloring": graph(
            "Every edge must cross between two colors",
            "A same-color edge is the explicit witness that this component is not bipartite.",
            [n("a", "0", 0.18, 0.24, .active), n("b", "1", 0.72, 0.24, .candidate), n("c", "0", 0.18, 0.78, .active), n("d", "1", 0.72, 0.78, .candidate)],
            [e("a", "b", directed: false), e("a", "d", directed: false), e("c", "b", directed: false), e("c", "d", directed: false)]
        ),
        "dijkstra": graph(
            "Finalize the smallest tentative distance",
            "Nonnegative edges ensure no later route can improve a node removed from the min-heap.",
            [n("s", "S·0", 0.10, 0.50, .resolved), n("a", "A·2", 0.42, 0.22, .active), n("b", "B·5", 0.42, 0.78, .candidate), n("t", "T·6", 0.82, 0.50)],
            [e("s", "a", "2"), e("s", "b", "5"), e("a", "t", "4"), e("b", "t", "1")]
        ),
        "dfs-cycle-states": graph(
            "A back edge targets an active ancestor",
            "Finished nodes are safe; only the current recursion stack witnesses a directed cycle.",
            [n("a", "A active", 0.18, 0.24, .active), n("b", "B active", 0.68, 0.24, .active), n("c", "C active", 0.68, 0.76, .active), n("d", "D done", 0.18, 0.76, .resolved)],
            [e("a", "b"), e("b", "c"), e("c", "a", "back", role: .warning), e("a", "d")]
        ),
        "kruskal": graph(
            "Take the lightest edge that joins components",
            "Rejecting within-component edges prevents cycles; accepted edges merge components.",
            [n("a", "A", 0.15, 0.30, .active), n("b", "B", 0.42, 0.70, .active), n("c", "C", 0.68, 0.25, .candidate), n("d", "D", 0.88, 0.72, .candidate)],
            [e("a", "b", "1", directed: false, role: .resolved), e("b", "c", "2", directed: false, role: .active), e("c", "d", "4", directed: false), e("a", "c", "5 reject", directed: false, role: .warning)]
        ),
        "combination-search": graph(
            "The start index prevents reordered duplicates",
            "Children may choose only the current or later candidates, so [1,2] and [2,1] are one combination.",
            [n("r", "start 0", 0.50, 0.12), n("a", "[1] · 1", 0.25, 0.52, .active), n("b", "[2] · 2", 0.75, 0.52, .candidate), n("c", "[1,2]", 0.25, 0.88, .resolved)],
            [e("r", "a"), e("r", "b"), e("a", "c")]
        ),
        "permutation-search": graph(
            "Each level chooses one unused item",
            "Order matters, so choosing A then B and B then A are distinct branches.",
            [n("r", "[]", 0.50, 0.10), n("a", "[A]", 0.24, 0.48, .active), n("b", "[B]", 0.76, 0.48, .candidate), n("c", "[A,B]", 0.12, 0.86, .resolved), n("d", "[A,C]", 0.38, 0.86)],
            [e("r", "a"), e("r", "b"), e("a", "c"), e("a", "d")]
        ),
        "constraint-pruning": graph(
            "A proof can remove an entire subtree",
            "Prune only when no descendant can repair the violated necessary condition.",
            [n("r", "state", 0.50, 0.10), n("a", "valid", 0.25, 0.48, .active), n("b", "C=false", 0.75, 0.48, .warning), n("c", "continue", 0.25, 0.86, .resolved), n("d", "×", 0.75, 0.86, .warning)],
            [e("r", "a"), e("r", "b"), e("a", "c"), e("b", "d", "prune", role: .warning)]
        ),
        "partition-search": graph(
            "Valid substrings form edges between boundaries",
            "A complete partition is simply a path from boundary 0 to boundary n.",
            [n("0", "0", 0.08, 0.50, .resolved), n("1", "1", 0.35, 0.24, .active), n("2", "2", 0.62, 0.72, .candidate), n("3", "n", 0.90, 0.50, .resolved)],
            [e("0", "1", "a"), e("0", "2", "aa"), e("1", "3", "ab"), e("2", "3", "b")]
        ),
        "popcount": sequence(
            "x & (x−1) clears exactly the lowest set bit",
            "The loop runs once per 1-bit rather than once per bit position.",
            [c("1", .neutral), c("0"), c("1", .active, note: "lowest 1"), c("0"), c("0", .resolved, note: "after AND")]
        ),
        "xor-cancellation": flow(
            "Equal pairs cancel regardless of order",
            "Associativity and commutativity let every repeated value meet its twin.",
            [("4 ⊕ 1 ⊕ 2 ⊕ 1 ⊕ 2", nil, .candidate), ("1⊕1 = 0", nil, .active), ("2⊕2 = 0", nil, .active), ("4", "unpaired", .resolved)]
        ),
        "unbounded-amount-dp": sequence(
            "Each amount asks which coin could be last",
            "Because coins are reusable, dp[a−c] may already include coin c.",
            [c("0", .resolved, note: "dp=0"), c("1", .resolved), c("2", .active), c("3", .candidate, note: "1+dp[1]"), c("4")]
        ),
        "rolling-recurrence": flow(
            "Discard states once their last consumer has used them",
            "Two variables are enough when dp[i] depends only on the previous two values.",
            [("older", "dp[i−2]", .neutral), ("newer", "dp[i−1]", .active), ("f(·)", "compute", .candidate), ("shift", "next pair", .resolved)]
        ),
        "take-skip-dp": graph(
            "Every state compares two decisions",
            "Write what changes in the take branch before deciding loop order or reuse policy.",
            [n("s", "state s", 0.50, 0.12), n("a", "skip", 0.25, 0.56, .candidate), n("b", "take +v", 0.75, 0.56, .active), n("m", "best", 0.50, 0.90, .resolved)],
            [e("s", "a"), e("s", "b"), e("a", "m"), e("b", "m")]
        ),
        "grid-dp": matrix(
            "Each cell combines already-solved predecessors",
            "Choose a fill order in which every arrow points from known state to new state.",
            [[c("1", .resolved), c("→", .resolved), c("3", .resolved)], [c("↓", .resolved), c("↘", .active), c("?", .candidate)], [c("2", .resolved), c("?", .candidate), c("?", .neutral)]]
        ),
        "sequence-dp": matrix(
            "A table cell compares two prefixes",
            "Matching symbols use the diagonal; a mismatch drops one final symbol from either prefix.",
            [[c("", .neutral), c("A"), c("B"), c("C")], [c("A"), c("↖ +1", .active), c("←/↑", .candidate), c("←/↑", .candidate)], [c("C"), c("←/↑"), c("←/↑"), c("↖ +1", .resolved)]]
        ),
        "interval-dp": matrix(
            "Fill shorter intervals before longer ones",
            "Every dependency lies closer to the diagonal, so increasing length is a valid order.",
            [[c("1", .resolved), c("2", .resolved), c("3", .active), c("4", .candidate)], [c("·"), c("1", .resolved), c("2", .resolved), c("3", .active)], [c("·"), c("·"), c("1", .resolved), c("2", .resolved)]]
        ),
        "cooldown-frame-counting": sequence(
            "Most-frequent tasks create a minimum frame",
            "Other tasks fill the gaps; if they overflow, total task count becomes the answer.",
            [c("A", .active), c("_", .candidate, note: "cool"), c("_", .candidate), c("A", .active), c("_", .candidate), c("_", .candidate), c("A", .resolved)]
        ),
        "greedy-frontier": sequence(
            "Scan every position in the current jump layer",
            "Commit a jump only at current_end, after finding the farthest reach from the whole frontier.",
            [c("0", .resolved), c("1", .active), c("2", .active, note: "current end"), c("3", .candidate), c("4", .candidate, note: "farthest")]
        ),
        "running-extreme": sequence(
            "Pair the current value with the best earlier extreme",
            "Compute the answer before updating the extreme when an item may not pair with itself.",
            [c("7", .resolved, note: "min=7"), c("2", .active, note: "new min"), c("9", .candidate, note: "9−2=7"), c("4")]
        ),
        "two-pass-constraints": sequence(
            "One pass enforces each direction",
            "The pointwise maximum is the smallest allocation satisfying both neighbor constraints.",
            [c("L: 1", .candidate), c("L: 2", .candidate), c("L: 1"), c("max", .active), c("R: 1"), c("R: 2", .resolved)]
        ),
        "greedy-priority": flow(
            "Use the largest eligible frequency, then cool it",
            "The heap chooses available work; the cooldown queue remembers when used work returns.",
            [("max-heap", "A:3 B:2", .active), ("run A", "time t", .candidate), ("cooldown", "eligible t+c+1", .warning), ("heap", "next B", .resolved)]
        ),
        "deficit-reset": sequence(
            "A negative segment invalidates every start inside it",
            "Reset just after the deficit; no skipped position could have survived that same prefix.",
            [c("+3", .resolved, note: "start"), c("−1", .resolved), c("−4", .warning, note: "sum < 0"), c("|", .active, note: "reset"), c("+5", .candidate)]
        ),
        "last-occurrence-partitions": sequence(
            "Every symbol inside may extend the boundary",
            "Close only when the scan reaches the maximum last occurrence seen in the segment.",
            [c("a", .active, note: "last 3"), c("b", .candidate, note: "last 4"), c("a"), c("a"), c("b", .resolved, note: "close")]
        ),
        "partition-binary-search": sequence(
            "Partition both arrays around one combined half",
            "The partition is correct when both left maxima are ≤ the opposite right minima.",
            [c("A left", .resolved), c("A right", .candidate), c("|", .active), c("B left", .resolved), c("B right", .candidate)]
        ),
        "quickselect": sequence(
            "Partition; recurse only into the side containing k",
            "Unlike quicksort, the other partition never needs to be solved.",
            [c("< pivot", .resolved), c("< pivot", .resolved), c("pivot", .active), c("> pivot", .candidate, note: "k here"), c("> pivot", .candidate)]
        ),
        "multiway-merge": flow(
            "The heap stores one head from each stream",
            "After emitting a head, advance only that stream and restore at most k candidates.",
            [("A:1", nil, .candidate), ("B:2", nil, .candidate), ("C:4", nil, .candidate), ("min-heap → 1", "then A advances", .resolved)]
        ),
        "kadane": sequence(
            "Either extend the previous subarray or restart here",
            "ending[i] is the best nonempty subarray forced to end at i.",
            [c("−2", .warning), c("3", .resolved, note: "restart"), c("−1", .active, note: "extend=2"), c("4", .resolved, note: "extend=6"), c("−5", .candidate)]
        ),
        "paired-product-extremes": flow(
            "A negative value swaps the useful extreme",
            "Keep both maximum and minimum products because a later negative can reverse their roles.",
            [("old max 6", nil, .active), ("old min −8", nil, .warning), ("× −3", "sign flip", .candidate), ("new max 24", nil, .resolved)]
        ),
        "difference-array": sequence(
            "Record changes only at range boundaries",
            "One final prefix sum spreads each boundary delta across its intended interval.",
            [c("0"), c("+3", .active, note: "l"), c("0", .candidate), c("0", .candidate), c("−3", .warning, note: "r+1"), c("0")]
        ),
        "log-likelihood": flow(
            "Combine log-softmax and target selection stably",
            "Subtract the row maximum before log-sum-exp; never compute log(softmax) naively.",
            [("logits z", nil, .candidate), ("z−max(z)", "shift", .active), ("log-sum-exp", nil, .active), ("−log pᵧ", "loss", .resolved)]
        ),
        "masked-reduction": matrix(
            "The mask controls both numerator and denominator",
            "Only valid positions contribute, and a fully masked row follows the declared zero policy.",
            [[c("2", .active), c("5", .warning), c("8", .active)], [c("1", .resolved), c("0", .warning), c("1", .resolved)], [c("sum=10", .candidate), c("÷2", .candidate), c("mean=5", .resolved)]]
        ),
        "normalization": flow(
            "Reduction axes define the normalization",
            "Layer norm reduces features per example; batch norm reduces examples/spatial positions per channel.",
            [("x", "chosen axes", .candidate), ("μ, σ²", "reduce", .active), ("standardize", nil, .active), ("γ · + β", "affine", .resolved)]
        ),
        "stochastic-training": flow(
            "Drop during training; rescale survivors",
            "Dividing by 1−p preserves the expected activation, while evaluation is the identity.",
            [("x", nil, .candidate), ("mask m", "Bernoulli", .active), ("m·x/(1−p)", "train", .resolved), ("x", "eval", .resolved)]
        ),
        "pooling": matrix(
            "Reduce one non-overlapping or strided patch",
            "Output shape follows kernel, stride, and padding—not merely the input shape.",
            [[c("1", .active), c("7", .active), c("2"), c("3")], [c("4", .active), c("5", .active), c("8"), c("0")], [c("max", .candidate), c("→ 7", .resolved), c("next", .neutral), c("→", .neutral)]]
        ),
        "attention-masking": matrix(
            "Mask forbidden scores before softmax",
            "Putting −∞ above the causal diagonal makes every forbidden probability exactly zero.",
            [[c("✓", .resolved), c("×", .warning), c("×", .warning)], [c("✓", .resolved), c("✓", .resolved), c("×", .warning)], [c("✓", .resolved), c("✓", .resolved), c("✓", .active)]]
        ),
        "multihead-reshape": flow(
            "Split D into named head and feature axes",
            "Reshape alone is insufficient: transpose H before T, then apply the exact inverse afterward.",
            [("(B,T,D)", nil, .candidate), ("(B,T,H,d)", "reshape", .active), ("(B,H,T,d)", "transpose", .active), ("(B,T,D)", "inverse", .resolved)]
        ),
        "clustering": flow(
            "Alternate assignment and centroid updates",
            "Each phase holds the other fixed, so the objective cannot increase under the usual update.",
            [("centroids μ", nil, .candidate), ("nearest μ", "assign", .active), ("cluster means", "update", .active), ("repeat", "until stable", .resolved)]
        ),
        "padding-masks": matrix(
            "Lengths distinguish real tokens from padding",
            "The pad value may be valid data, so preserve an explicit mask or the original lengths.",
            [[c("7", .active), c("2", .active), c("0", .warning), c("0", .warning)], [c("1", .resolved), c("1", .resolved), c("0", .warning), c("0", .warning)]]
        ),
        "gradient-accumulation": flow(
            "Accumulate weighted sums, then divide once",
            "Microbatch means need sample-count weights when batch sizes differ.",
            [("n₁g₁", nil, .candidate), ("+ n₂g₂", nil, .candidate), ("÷ (n₁+n₂)", nil, .active), ("global g", nil, .resolved)]
        )
    ]
}

extension AlgorithmTechnique {
    var visualization: TechniqueVisualizationSpec? {
        TechniqueVisualizationCatalog.spec(for: id)
    }
}
