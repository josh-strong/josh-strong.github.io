import Foundation

/// Translates compact interview terminology into literal rules. The curriculum
/// can stay concise while every workspace still states what may be skipped,
/// whether order matters, and how boundaries behave.
enum ProblemLanguageGuide {
    static func notes(for problem: AlgorithmProblem) -> [ProblemReadingNote] {
        let canonicalID = SolutionComparisonCatalog.canonicalID(for: problem.id)
        let source = ([problem.title, problem.prompt] + problem.constraints)
            .joined(separator: " ")
            .lowercased()
        var notes = specificNotes[canonicalID] ?? []

        func add(_ id: String, _ term: String, _ explanation: String, when condition: Bool) {
            guard condition, !notes.contains(where: { $0.id == id }) else { return }
            notes.append(ProblemReadingNote(id: id, term: term, explanation: explanation))
        }

        add(
            "contiguous-subarray", "Contiguous subarray",
            "Choose one uninterrupted range of list positions from a start index through an end index. You may not skip an element inside that range.",
            when: source.contains("contiguous subarray")
        )
        add(
            "substring", "Substring",
            "A substring is one uninterrupted range of characters. The characters must be next to each other in the original text.",
            when: source.contains("substring")
        )
        add(
            "subsequence", "Subsequence",
            "You may skip items, but every chosen item must remain in its original left-to-right order.",
            when: source.contains("subsequence")
        )
        add(
            "contiguous-positions", "Contiguous / consecutive positions",
            "The selected items must occupy neighboring input positions; no positions may be skipped.",
            when: source.contains("contiguous")
                && !source.contains("contiguous subarray")
                && !source.contains("substring")
        )
        add(
            "consecutive-values", "Consecutive numeric values",
            "The values differ by exactly 1, such as 3, 4, 5. They do not need to be adjacent or ordered that way in the input list.",
            when: source.contains("consecutive values")
        )
        add(
            "consecutive-positions", "Consecutive positions",
            "This describes neighboring positions in the input, not numbers that differ by 1.",
            when: source.contains("consecutive")
                && !source.contains("consecutive values")
                && !source.contains("contiguous")
        )
        add(
            "strict", "Strict comparison",
            "“Strictly” excludes equality: strictly greater means >, and strictly increasing means every next chosen value must be larger, not equal.",
            when: source.contains("strictly")
        )
        add(
            "indices", "Index numbering",
            "Indices are zero-based unless the prompt explicitly says otherwise: the first position is index 0.",
            when: source.contains("index") || source.contains("indices")
        )
        add(
            "lexicographic", "Lexicographic order",
            "Compare from left to right; the first differing item decides which result comes first, like dictionary order.",
            when: source.contains("lexicographic")
        )
        add(
            "half-open", "Half-open interval [start, end)",
            "The start is included and the end is excluded. Therefore [1, 3) and [3, 5) touch but do not overlap.",
            when: source.contains("half-open") || source.contains("closed-open") || source.contains("[start, end)")
        )
        add(
            "closed-interval", "Closed interval [start, end]",
            "Both endpoints are included. Two closed intervals that share an endpoint overlap at that point unless the prompt gives a different rule.",
            when: (source.contains("closed interval") || source.contains("closed range"))
                && !source.contains("closed-open")
        )
        add(
            "heap-indexed-tree", "Heap-indexed tree array",
            "A node at array index i has children at 2i + 1 and 2i + 2. A null entry is a missing node, not a value to visit.",
            when: source.contains("heap-indexed")
        )
        add(
            "level-order-tree", "Level-order tree array",
            "The array lists tree positions one depth at a time from left to right; null placeholders preserve later child positions.",
            when: source.contains("level-order") && !source.contains("heap-indexed")
        )
        add(
            "four-directional", "Four-directional movement",
            "A move may go up, down, left, or right by one cell. Diagonal moves are not allowed.",
            when: source.contains("four-direction")
        )
        add(
            "circular", "Circular input",
            "After the final position, moving forward continues at position 0. Each physical position still appears only once per full circuit unless stated otherwise.",
            when: source.contains("circular") || source.contains("cyclic")
        )
        add(
            "palindrome", "Palindrome",
            "The chosen characters read identically from left to right and right to left.",
            when: source.contains("palindrome")
        )
        add(
            "permutation", "Permutation",
            "A permutation reorders all supplied items using each occurrence exactly once; it does not choose only a subset.",
            when: source.contains("permutation")
        )
        add(
            "prefix", "Prefix",
            "A prefix starts at the first item and ends anywhere later; it cannot start in the middle.",
            when: source.contains("prefix")
        )
        add(
            "floor", "Floor",
            "floor(x) is the greatest integer less than or equal to x; it rounds downward rather than to the nearest integer.",
            when: source.contains("floor(")
        )
        add(
            "mutation", "Input mutation",
            "Build and return the requested result without changing the supplied input value.",
            when: source.contains("do not mutate")
        )
        add(
            "tensor-shape", "Tensor shape",
            "A shape names the length of each axis in order. For a matrix, rows × columns means the outer list has one entry per row and each inner list has one entry per column.",
            when: source.contains("shape") || source.contains("matrix") || source.contains("tensor")
        )
        add(
            "logits", "Logits",
            "Logits are unrestricted scores before normalization. They are not probabilities and do not need to be positive or sum to 1.",
            when: source.contains("logit")
        )
        add(
            "stable-numerics", "Numerical stability",
            "Algebraically equivalent formulas can behave differently with finite-precision numbers. Re-centering exponentials around a maximum prevents overflow without changing the intended result.",
            when: source.contains("numerically stable") || source.contains("stable softmax") || source.contains("log-sum-exp")
        )
        add(
            "mask-semantics", "Mask convention",
            "For this problem, 1 means the position participates and 0 means it is excluded. Follow the local contract because some libraries use the opposite boolean convention.",
            when: source.contains("mask")
        )
        add(
            "population-variance", "Population variance",
            "Divide the sum of squared deviations by the full number of reduced values, not n - 1. This is the variance convention stated by the layer operation.",
            when: source.contains("population variance")
        )

        if notes.isEmpty {
            notes.append(ProblemReadingNote(
                id: "literal-contract",
                term: "Exact function contract",
                explanation: "Use the named arguments shown below and return the requested Python value. Do not read extra input or print the answer."
            ))
        }
        return notes
    }

    private static let specificNotes: [String: [ProblemReadingNote]] = [
        "arrays.longest-consecutive": [
            ProblemReadingNote(
                id: "consecutive-values",
                term: "Consecutive values—not adjacent positions",
                explanation: "Find values x, x + 1, x + 2, … anywhere in the list. Input order is irrelevant: [3, 5, 4] contains the length-3 sequence 3, 4, 5."
            )
        ],
        "pointers.sorted-pair": [
            ProblemReadingNote(
                id: "widest-valid-pair",
                term: "Widest valid pair",
                explanation: "If several index pairs sum to target, compare right - left and return the pair with the greatest distance. For [1, 3, 4, 8, 10] and target 11, [0, 4] is required over [1, 3]."
            )
        ],
        "pointers.water-container": [
            ProblemReadingNote(
                id: "container-area",
                term: "Width × limiting height",
                explanation: "For boundaries left and right, width is right - left. Water can rise only to the shorter boundary, so area is (right - left) × min(heights[left], heights[right]). A wider pair can still hold less area when one side is short."
            ),
            ProblemReadingNote(
                id: "interior-lines-ignored",
                term: "Interior lines do not split the container",
                explanation: "This problem scores only the two selected boundary lines. Heights between them neither increase nor decrease the calculated area; this is different from the Trapped Rain Water problem."
            )
        ],
        "window.minimum-cover": [
            ProblemReadingNote(
                id: "earliest-minimum-window",
                term: "Tie between minimum windows",
                explanation: "First minimize window length. If two covering windows have that same length, return the one beginning at the smaller zero-based index."
            )
        ]
    ]
}

/// The teaching layer shared by the Path, every problem workspace, and the
/// research-backed Learning Guide. The wording is intentionally about decisions
/// and invariants rather than memorising finished code.
enum LearningGuidance {
    static func lesson(for moduleID: String) -> PatternLesson {
        lessons[moduleID] ?? PatternLesson(
            mentalModel: "Turn the prompt into a small state you can update and explain.",
            recognitionQuestions: [
                "What information must be remembered?",
                "What repeated work can be removed?",
                "What must remain true after each step?"
            ],
            strategySteps: [
                "Write a correct brute-force approach and estimate its cost.",
                "Name the state and the invariant before choosing a data structure.",
                "Test the smallest, boundary, and adversarial cases by hand."
            ],
            commonPitfalls: [
                "Choosing a technique from a keyword without checking its invariant.",
                "Coding before the input, output, and edge cases are precise.",
                "Quoting complexity without counting the work actually performed."
            ],
            complexityTarget: "Let the constraints determine the required time and space bounds."
        )
    }

    static let researchSources: [LearningResearchSource] = [
        source(
            id: "worked-example-effect",
            title: "Effects of worked examples, example-problem, and problem-example pairs on novices’ learning",
            authors: "Van Gog, Kester & Paas, 2011",
            takeaway: "Novices learned more efficiently from worked examples than from unsupported problem solving. CodeStreak now teaches and demonstrates a technique before expecting independent use.",
            url: "https://doi.org/10.1016/j.cedpsych.2010.10.004"
        ),
        source(
            id: "faded-examples",
            title: "Fading worked solution steps",
            authors: "Renkl et al., 2004",
            takeaway: "Gradually removing solution steps can bridge example study and independent problem solving. Modules now move from named guidance to practice and finally a blind check.",
            url: "https://eric.ed.gov/?id=EJ732331"
        ),
        source(
            id: "retrieval",
            title: "Retrieval practice produces more learning than elaborative studying",
            authors: "Karpicke & Blunt, 2011",
            takeaway: "Reconstructing an idea from memory can build more durable learning than another passive reread. In CodeStreak, close the reference and rebuild the solution later.",
            url: "https://pubmed.ncbi.nlm.nih.gov/21252317/"
        ),
        source(
            id: "spacing",
            title: "Distributed practice: a review and quantitative synthesis",
            authors: "Cepeda et al., 2006",
            takeaway: "Practice spread across time generally retains better than the same work crammed together. That is why solved problems return on later days.",
            url: "https://pubmed.ncbi.nlm.nih.gov/16719566/"
        ),
        source(
            id: "interleaving",
            title: "Learning concepts and categories: is spacing the enemy of induction?",
            authors: "Kornell & Bjork, 2008",
            takeaway: "Interleaved examples can improve category discrimination. After learning a set in a short block, mix reviews so you must decide which pattern applies.",
            url: "https://pubmed.ncbi.nlm.nih.gov/18578849/"
        ),
        source(
            id: "self-explanation",
            title: "Self-explanations: how students study and use examples",
            authors: "Chi et al., 1989",
            takeaway: "Strong learners generated explanations that connected solution actions to principles. Use notes to explain the invariant and why each update is safe.",
            url: "https://doi.org/10.1207/s15516709cog1302_1"
        ),
        source(
            id: "worked-examples",
            title: "Worked examples for programming and algorithm design",
            authors: "Vieira, Yan & Magana, 2015",
            takeaway: "Novice programmers benefited from carefully designed worked examples, especially when prompted to self-explain. Attempt first, inspect the reference, then annotate its decisions.",
            url: "https://jocse.org/articles/6/1/1/"
        ),
        source(
            id: "learning-techniques",
            title: "Improving students' learning with effective learning techniques",
            authors: "Dunlosky et al., 2013",
            takeaway: "This broad review rates practice testing and distributed practice highly while also examining self-explanation and interleaving. Use the guide as a repeatable system, not a one-off tip list.",
            url: "https://pubmed.ncbi.nlm.nih.gov/26173288/"
        )
    ]

    static let lessonModuleIDs: Set<String> = Set(lessons.keys)

    private static func source(
        id: String,
        title: String,
        authors: String,
        takeaway: String,
        url: String
    ) -> LearningResearchSource {
        guard let destination = URL(string: url) else {
            preconditionFailure("Invalid research URL: \(url)")
        }
        return LearningResearchSource(
            id: id,
            title: title,
            authorsAndYear: authors,
            takeaway: takeaway,
            url: destination
        )
    }

    private static let lessons: [String: PatternLesson] = [
        "arrays-hashing": PatternLesson(
            mentalModel: "Pay a little memory to remember what the scan has already learned. A set answers ‘have I seen this?’; a dictionary attaches a count, index, or other fact to each key.",
            recognitionQuestions: [
                "Do I repeatedly ask whether a value, complement, or key has appeared?",
                "Would counts or first/last indices remove a nested scan?",
                "Can I process left to right while summarising only the prefix already seen?"
            ],
            strategySteps: [
                "State exactly what each set entry or key-value pair means.",
                "Scan once and query the stored prefix before doing repeated work.",
                "Choose the update order deliberately—checking before inserting often matters for pairs and duplicates.",
                "Trace empty input, repeated values, missing answers, and negative values."
            ],
            commonPitfalls: [
                "Overwriting an earlier index when the problem asks for the first valid pair.",
                "Sorting and accidentally losing original positions or required order.",
                "Claiming O(1) space when the lookup can grow with the input."
            ],
            complexityTarget: "Usually O(n) expected time and O(n) extra space instead of an O(n²) nested scan."
        ),
        "two-pointers": PatternLesson(
            mentalModel: "Two indices describe the unexplored region or separate reading from writing. Every pointer move must safely discard possibilities or place one item permanently.",
            recognitionQuestions: [
                "Is the input sorted, symmetric, or naturally examined from both ends?",
                "Can one pointer read while another marks the next write position?",
                "Does comparing the ends tell me which side can no longer improve the answer?"
            ],
            strategySteps: [
                "Define what lies outside the pointers and why it is already settled.",
                "Write the stopping condition before the movement rules.",
                "Move only the pointer whose movement is justified by the comparison.",
                "Check equal values, crossed pointers, and all-skipped input."
            ],
            commonPitfalls: [
                "Moving both pointers when only one side can be ruled out.",
                "Using the wrong strict/non-strict comparison around duplicates.",
                "Forgetting whether the answer needs values, indices, or in-place mutation."
            ],
            complexityTarget: "Often O(n) time and O(1) extra space after sorting; include O(n log n) if you sort first."
        ),
        "sliding-window": PatternLesson(
            mentalModel: "Reuse the answer for one contiguous range when its right edge advances. Add the new item, remove items from the left, and keep only the state needed by the current window.",
            recognitionQuestions: [
                "Must the answer be a contiguous subarray or substring?",
                "Is the window fixed-size, or can validity be restored by moving the left edge?",
                "Can counts, a sum, or a small map be updated when one item enters or leaves?"
            ],
            strategySteps: [
                "Define the window precisely, usually the inclusive range [left, right].",
                "Add the right item to the state.",
                "For variable windows, shrink with a while-loop until the invariant is valid again.",
                "Record the answer only at the moment required: while valid, exactly sized, or after shrinking."
            ],
            commonPitfalls: [
                "Using if instead of while when several left items must leave.",
                "Updating the best length before the window is valid.",
                "Leaving zero counts or a stale maximum in the state without proving it is harmless."
            ],
            complexityTarget: "Usually O(n): each element enters once and leaves at most once, even though a while-loop is nested."
        ),
        "stack": PatternLesson(
            mentalModel: "A stack remembers unresolved items in last-in-first-out order. A monotonic stack additionally keeps values increasing or decreasing so one new item can settle several older ones.",
            recognitionQuestions: [
                "Are there nested structures that must close in reverse order?",
                "Does each item wait for the next greater, smaller, or matching item?",
                "Is the most recently unresolved item always the first one I can resolve?"
            ],
            strategySteps: [
                "Decide whether the stack stores values, indices, pairs, or partial results.",
                "Write the exact condition that makes the top item resolvable.",
                "Pop and finish resolved items, then push the current item if it remains useful.",
                "Decide what unanswered items mean after the scan ends."
            ],
            commonPitfalls: [
                "Choosing < versus <= incorrectly when duplicates exist.",
                "Storing values when distances or original positions require indices.",
                "Reading the top of an empty stack or forgetting remaining entries."
            ],
            complexityTarget: "Usually O(n) time because each item is pushed and popped at most once, with O(n) stack space."
        ),
        "linked-lists": PatternLesson(
            mentalModel: "The structure lives in links, not contiguous positions. Preserve the next link before rewiring, and use sentinel or fast/slow pointers to simplify awkward boundaries.",
            recognitionQuestions: [
                "Can the result be produced by changing links instead of copying values?",
                "Would a dummy head remove special handling for the first node?",
                "Can fast and slow movement expose a midpoint, offset, or cycle?"
            ],
            strategySteps: [
                "Draw three or four nodes and label every pointer before changing one.",
                "Save the next node before overwriting a link.",
                "Use a dummy node for deletions or merges that may change the head.",
                "Trace empty, one-node, two-node, and cyclic cases."
            ],
            commonPitfalls: [
                "Losing the remainder of the list during reversal.",
                "Dereferencing a missing next node in a fast-pointer loop.",
                "Returning the old head after an operation changes it."
            ],
            complexityTarget: "Most pointer passes are O(n) time and O(1) extra space; recursion may add O(n) call-stack space."
        ),
        "binary-search": PatternLesson(
            mentalModel: "Search a monotonic yes/no boundary, not just a sorted array. Every comparison proves that one half cannot contain the desired boundary.",
            recognitionQuestions: [
                "Is there an ordered value space or a monotonic feasible/not-feasible answer space?",
                "Am I looking for any match, the first true value, or the last true value?",
                "Can I write a predicate whose answer changes direction only once?"
            ],
            strategySteps: [
                "Write the search interval convention and keep it consistent.",
                "Define the monotonic predicate separately from the search loop.",
                "Use the midpoint result to discard a proven half while preserving the boundary.",
                "Test no match, one item, two items, and a boundary at each end."
            ],
            commonPitfalls: [
                "Using binary search when the predicate is not monotonic.",
                "Mixing inclusive and exclusive bounds and creating an infinite loop.",
                "Returning the last midpoint rather than the maintained boundary."
            ],
            complexityTarget: "O(log n) decisions over n ordered candidates; multiply by the cost of a feasibility check for answer-space searches."
        ),
        "intervals": PatternLesson(
            mentalModel: "Sorting turns two-dimensional ranges into a left-to-right story. Keep one active boundary summary and decide whether the next interval overlaps, extends, or starts fresh.",
            recognitionQuestions: [
                "Does each item represent a start and end time or coordinate?",
                "Do I need merged coverage, intersections, removals, or peak overlap?",
                "Will sorting by start or end expose a safe local decision?"
            ],
            strategySteps: [
                "Write what touching endpoints mean before coding the overlap test.",
                "Choose and justify the sort key: starts for merging, often ends for scheduling.",
                "Maintain the smallest summary needed—the active end, merged range, or event count.",
                "Trace nested, touching, disjoint, and identical intervals."
            ],
            commonPitfalls: [
                "Reasoning about neighbors before sorting.",
                "Using < when <= is required, or vice versa, for endpoint semantics.",
                "Comparing with the previous raw interval instead of the merged active end."
            ],
            complexityTarget: "Typically O(n log n) for sorting followed by an O(n) scan; some pre-sorted variants are O(n)."
        ),
        "trees": PatternLesson(
            mentalModel: "Give each recursive call a contract: it solves one subtree and returns exactly the summary its parent needs. Use breadth-first search when level order or shortest depth is central.",
            recognitionQuestions: [
                "Can the answer for a node be combined from answers for its children?",
                "Does traversal order matter, or only the returned subtree summary?",
                "Is the question about levels, in which case a queue may be clearer?"
            ],
            strategySteps: [
                "State the recursive function’s input and returned meaning in one sentence.",
                "Write the empty-tree base case so it has the correct identity value.",
                "Ask children for their summaries, then combine locally.",
                "Test a leaf, a chain, a balanced tree, and an empty tree."
            ],
            commonPitfalls: [
                "Using shared mutable state when a returned value would be safer.",
                "Choosing the wrong base value for max, min, count, or validity.",
                "Confusing binary-search-tree ordering with ordinary binary-tree structure."
            ],
            complexityTarget: "Usually O(n) time to visit every node; auxiliary space is O(h) for DFS or O(w) for BFS."
        ),
        "queues-heaps": PatternLesson(
            mentalModel: "A queue preserves arrival order; a heap exposes only the next highest-priority item. Keep enough candidates to choose the next action without repeatedly sorting everything.",
            recognitionQuestions: [
                "Do I repeatedly need the smallest, largest, or next scheduled item?",
                "Is this a top-k or streaming problem where only k candidates matter?",
                "Does level order or first-in-first-out processing define correctness?"
            ],
            strategySteps: [
                "Define what an item in the queue or heap represents.",
                "Choose min-heap versus max-heap and document any sign inversion.",
                "For top-k, keep the heap bounded and evict the least useful candidate.",
                "Handle stale entries explicitly if priorities can change after insertion."
            ],
            commonPitfalls: [
                "Reversing heap priority and discarding the best candidate.",
                "Sorting the entire collection after every update.",
                "Marking breadth-first states too late and enqueueing duplicates."
            ],
            complexityTarget: "Queue traversals are commonly O(n); n heap operations are O(n log n), or O(n log k) with a bounded heap."
        ),
        "tries-strings": PatternLesson(
            mentalModel: "Represent how much text has matched so far. A trie shares prefixes across many words; prefix/failure information lets string algorithms resume instead of restarting every comparison.",
            recognitionQuestions: [
                "Are many words queried by prefix or sharing the same beginnings?",
                "Does naive matching restart comparisons after a partial match?",
                "Can a state mean ‘the first k characters already match’?"
            ],
            strategySteps: [
                "Choose the state: trie node, matched-prefix length, or rolling summary.",
                "Define the transition for a matching and non-matching next character.",
                "Separate ‘this prefix exists’ from ‘a complete word ends here’.",
                "Test empty text, repeated characters, overlapping matches, and prefix-only words."
            ],
            commonPitfalls: [
                "Treating every prefix as a complete stored word.",
                "Restarting from zero when previous prefix information can be reused.",
                "Ignoring whether matching is case-sensitive or character boundaries matter."
            ],
            complexityTarget: "Trie operations are O(L) in query length; efficient matching aims for O(text + pattern) rather than O(text × pattern)."
        ),
        "graphs": PatternLesson(
            mentalModel: "Model states as vertices and allowed moves as edges. Explore each reachable state once; choose DFS for structural exploration and BFS for shortest paths in unweighted graphs.",
            recognitionQuestions: [
                "Are relationships arbitrary rather than strictly parent-child?",
                "Is the task about reachability, components, cycles, ordering, or shortest moves?",
                "What uniquely identifies a state so it can be marked visited?"
            ],
            strategySteps: [
                "Write the vertices, edges, and whether each edge is directed.",
                "Choose DFS, BFS, or topological processing based on the requested property.",
                "Mark a state when it is scheduled, not after repeated scheduling.",
                "Handle disconnected components and trace a cycle."
            ],
            commonPitfalls: [
                "Forgetting the reverse edge in an undirected graph.",
                "Marking visited on dequeue and filling the queue with duplicates.",
                "Using ordinary BFS for weighted shortest paths."
            ],
            complexityTarget: "Adjacency-list traversal is O(V + E) time and O(V) auxiliary space."
        ),
        "union-find": PatternLesson(
            mentalModel: "Each component has a representative root. Find discovers a root; union merges two roots, while path compression and size/rank keep the forest shallow.",
            recognitionQuestions: [
                "Do groups merge over time while connectivity is queried repeatedly?",
                "Does a new edge form a cycle exactly when its endpoints are already connected?",
                "Do I need components, but not the actual path between vertices?"
            ],
            strategySteps: [
                "Initialize every item as its own parent.",
                "Make find return a root and compress the path on the way back.",
                "Union roots—not raw nodes—and attach the smaller tree to the larger.",
                "Maintain a component count only when a merge truly occurs."
            ],
            commonPitfalls: [
                "Comparing immediate parents rather than canonical roots.",
                "Decrementing component count when two nodes were already connected.",
                "Using union-find for deletions, shortest paths, or traversal order."
            ],
            complexityTarget: "Near-constant amortized time per operation, O(α(n)), with O(n) parent and size storage."
        ),
        "backtracking": PatternLesson(
            mentalModel: "Walk a decision tree: choose, recurse, and undo. The path is a partial candidate; pruning stops branches that can no longer lead to a valid answer.",
            recognitionQuestions: [
                "Does the output require all valid combinations, arrangements, or placements?",
                "Can I describe the next legal choices from a partial solution?",
                "Can constraints reject a branch before it becomes a full candidate?"
            ],
            strategySteps: [
                "Define the path/state, the next choices, and the completion condition.",
                "Choose one option and update all constraint state.",
                "Recurse, then undo every mutation before trying the next option.",
                "Prune impossible branches and copy the path when recording an answer."
            ],
            commonPitfalls: [
                "Appending the same mutable path object to every result.",
                "Forgetting to undo one set, count, or path mutation.",
                "Generating duplicate branches when the input contains duplicates."
            ],
            complexityTarget: "Often exponential; express the branching factor and depth, then show how pruning reduces explored states."
        ),
        "bit-math": PatternLesson(
            mentalModel: "Use the representation itself as state. XOR cancels equal pairs, masks inspect selected bits, and exponentiation by squaring removes repeated multiplication.",
            recognitionQuestions: [
                "Do values pair off, or do parity and individual binary digits matter?",
                "Can a mask encode a small set of boolean choices?",
                "Can repeated arithmetic be halved at each step?"
            ],
            strategySteps: [
                "Write tiny values in binary and simulate the operator by hand.",
                "Name the identity being used before compressing the code.",
                "Use masks and shifts with explicit parentheses.",
                "Check zero, sign behavior, overflow assumptions, and Python’s unbounded integers."
            ],
            commonPitfalls: [
                "Relying on an XOR cancellation when the frequency promise is different.",
                "Misreading operator precedence in mixed arithmetic and bit expressions.",
                "Assuming fixed-width overflow behavior that Python does not have."
            ],
            complexityTarget: "Many identities give O(n) scans or O(log n) arithmetic; bit-count loops depend on the number of set bits or word size."
        ),
        "dynamic-programming": PatternLesson(
            mentalModel: "A DP state is a precise question whose answer is reused. The transition combines already-solved smaller states; base cases anchor the recurrence.",
            recognitionQuestions: [
                "Does a choice leave a smaller problem with the same structure?",
                "Would a brute-force recursion solve the same state repeatedly?",
                "Is the output a best value, number of ways, feasibility result, or sequence alignment?"
            ],
            strategySteps: [
                "First write the recursive question in words and list everything that identifies a state.",
                "Write the choices, transition, and base cases before optimising storage.",
                "Memoize the recursion, then derive a bottom-up order only if it improves clarity or space.",
                "Trace unreachable states and verify where the final answer lives."
            ],
            commonPitfalls: [
                "Adding dimensions that do not affect future decisions—or omitting one that does.",
                "Iterating bottom-up states before their dependencies are ready.",
                "Updating a compressed one-dimensional table in the wrong direction."
            ],
            complexityTarget: "Number of distinct states × work per transition; space is the stored state table plus any recursion stack."
        ),
        "greedy": PatternLesson(
            mentalModel: "Make the locally best safe choice only when you can prove an optimal solution can include it. Sorting often exposes that choice; an exchange or stays-ahead argument justifies it.",
            recognitionQuestions: [
                "Does one candidate leave at least as much room as every alternative?",
                "Can I swap my local choice into an optimal solution without making it worse?",
                "Does sorting by an endpoint, cost, or benefit reveal a dominant next move?"
            ],
            strategySteps: [
                "Separate the objective from the feasibility constraints.",
                "Propose a local rule and try to break it with the smallest counterexample.",
                "Prove the rule using exchange, dominance, or a stays-ahead invariant.",
                "Implement the resulting scan and re-check tie behavior."
            ],
            commonPitfalls: [
                "Calling an intuitive choice greedy without proving it is safe.",
                "Sorting by start when finishing earliest is the property that preserves options.",
                "Forcing greedy onto a problem where choices interact and DP is required."
            ],
            complexityTarget: "Often O(n log n) from sorting plus an O(n) decision scan; already ordered inputs may allow O(n)."
        ),
        "ml-tensor-foundations": PatternLesson(
            mentalModel: "Treat every tensor axis as a named loop and every equation as a sequence of shape-preserving transformations. Correctness comes before vectorization; numerical stability is part of correctness.",
            recognitionQuestions: [
                "What does each axis represent, and which axes are reduced?",
                "What are the input and output shapes of every intermediate?",
                "Can an exponential, logarithm, division, or variance calculation become unstable?"
            ],
            strategySteps: [
                "Annotate every argument with its shape and name the shared/reduced dimensions.",
                "Work one scalar output cell from the equation before generalizing loops.",
                "Add the stability transform, then prove it does not change the mathematical result.",
                "Test one-element, rectangular, large-magnitude, and masked inputs."
            ],
            commonPitfalls: [
                "Multiplying compatible-looking dimensions in the wrong orientation.",
                "Treating logits as probabilities or exponentiating them without a shift.",
                "Averaging over padded values or over the wrong tensor axis."
            ],
            complexityTarget: "State costs using named dimensions—for example O(batch · input · output)—instead of collapsing every axis into n."
        ),
        "ml-training-mechanics": PatternLesson(
            mentalModel: "A training primitive has a forward definition, a reduction convention, and often persistent state. Backpropagation applies the chain rule in reverse while preserving every parameter's shape.",
            recognitionQuestions: [
                "Which axes define the statistics or mean loss?",
                "Which forward intermediates are needed by the backward pass?",
                "Is this value a parameter, gradient, activation, or optimizer state?"
            ],
            strategySteps: [
                "Write the scalar loss and exact mean/sum convention.",
                "Draw the computational graph and propagate one upstream gradient backward at a time.",
                "Accumulate shared-parameter gradients across examples before updating anything.",
                "Test zero loss, inactive nonlinearities, constant inputs, and the first optimizer step."
            ],
            commonPitfalls: [
                "Reducing layer norm over the batch or batch norm over features.",
                "Losing the factor introduced by a mean loss or squared error.",
                "Using stale optimizer moments or applying bias correction with a zero-based step."
            ],
            complexityTarget: "Backward should normally have the same asymptotic order as forward; account separately for saved activation and optimizer-state memory."
        ),
        "ml-neural-architectures": PatternLesson(
            mentalModel: "Architecture code is mostly careful geometry: sliding receptive fields or query-key connectivity define which values may interact, and learned projections define how.",
            recognitionQuestions: [
                "Which input positions contribute to this output position?",
                "What is the exact valid output size or causal boundary?",
                "Where are features split, mixed, concatenated, or projected?"
            ],
            strategySteps: [
                "Derive output shapes before allocating a result.",
                "Implement one receptive field or one query row and verify it by hand.",
                "Make masking explicit before normalization so forbidden positions get zero probability.",
                "Check identity projections, a one-token sequence, and an all-negative spatial window."
            ],
            commonPitfalls: [
                "Flipping a kernel when the ML contract asks for cross-correlation.",
                "Applying softmax over the feature dimension instead of over keys.",
                "Letting the first causal position depend on a future token or concatenating heads in the wrong order."
            ],
            complexityTarget: "Separate projection cost O(sequence · d²) from attention cost O(sequence² · d), and express convolution cost in output and kernel dimensions."
        ),
        "ml-research-engineering": PatternLesson(
            mentalModel: "Experimental plumbing is part of the scientific result. Make tie-breaking, empty cases, weighting, stopping rules, and metric averaging explicit so runs are correct and reproducible.",
            recognitionQuestions: [
                "What policy is needed when a class, cluster, or sequence is empty?",
                "Are means weighted by examples, batches, classes, or something else?",
                "Which deterministic tie and stopping rules make this experiment reproducible?"
            ],
            strategySteps: [
                "Write the semantic unit of every count, sum, and mean.",
                "Specify edge-case behavior before choosing a data structure.",
                "Use log-space scores and compound ordering keys where ranking must be stable.",
                "Test imbalance, ties, padding-only rows, unequal microbatches, and completed hypotheses."
            ],
            commonPitfalls: [
                "Reporting micro F1 when the contract asks for an equal class average.",
                "Averaging microbatch means equally despite different sample counts.",
                "Re-expanding completed beams or silently moving an empty K-means centroid."
            ],
            complexityTarget: "State both core arithmetic and selection/sorting costs; evaluation correctness is more important than premature vectorization."
        ),
        "advanced": PatternLesson(
            mentalModel: "Harder problems often hide a familiar core behind a less obvious state or combine two patterns. Let constraints rule out approaches, then isolate and verify each component.",
            recognitionQuestions: [
                "What time bound do the input limits demand?",
                "Which familiar pattern solves most of the task, and what extra state is missing?",
                "Can the problem become monotonic, a graph, or a DP after changing representation?"
            ],
            strategySteps: [
                "Estimate the maximum affordable complexity before designing the algorithm.",
                "Write the brute-force state and identify exactly where work repeats.",
                "Name the primary pattern and the secondary technique separately.",
                "Validate each invariant on a tiny adversarial example before composing them."
            ],
            commonPitfalls: [
                "Stacking advanced techniques before the state is precise.",
                "Ignoring a hidden logarithmic or linear operation inside a loop.",
                "Memorising a famous solution without being able to derive its boundary conditions."
            ],
            complexityTarget: "Derive the target from constraints and account for every composed stage rather than quoting one familiar component."
        ),
        "advanced-data-structures": PatternLesson(
            mentalModel: "Maintain summaries as data changes so queries do not start from scratch. The right structure follows from the exact operations and their required complexity budget.",
            recognitionQuestions: [
                "Are there many interleaved updates and range, rank, or recency queries?",
                "Can summaries of neighboring segments be combined associatively?",
                "Would a map plus linked ordering or a tree of aggregates maintain the answer?"
            ],
            strategySteps: [
                "List every operation and its required frequency before choosing a structure.",
                "Write what each node, index, or cache entry summarises.",
                "Implement update and query against the same invariant.",
                "Trace index boundaries, repeated updates, eviction, and an empty structure."
            ],
            commonPitfalls: [
                "Mixing zero-based inputs with one-based Fenwick-tree indices.",
                "Updating a leaf or cache entry without refreshing all dependent summaries.",
                "Choosing a powerful structure whose operations do not match the prompt."
            ],
            complexityTarget: "Common targets are O(log n) updates/queries for range structures or O(1) average lookup and recency changes for hash-map hybrids."
        )
    ]
}

/// The explicit, novice-facing syllabus for every curriculum module. A learner
/// should never have to infer what a named algorithm means from a reference
/// solution. Each module teaches its expected tools before using them.
enum ModuleTeachingCatalog {
    static func course(for moduleID: String, fallback: PatternLesson) -> ModuleCourse {
        if let base = courses[moduleID] {
            return ModuleCourse(
                prerequisites: base.prerequisites,
                techniques: TechniqueDependencyCatalog.topologicallyOrdered(
                    base.techniques + SupplementalTechniqueCatalog.techniques(for: moduleID)
                )
            )
        }

        return ModuleCourse(
            prerequisites: ["Python functions, loops, conditionals, lists, and dictionaries"],
            techniques: [technique(
                id: "state-invariant",
                name: "State and invariant",
                meaning: fallback.mentalModel,
                math: "Replace the full history by a smaller state S. After each update, state exactly which proposition about S remains true.",
                use: fallback.recognitionQuestions,
                avoid: "Do not optimize until you can describe a correct direct method and the work it repeats.",
                invariant: fallback.strategySteps.first ?? "The stored state summarizes everything processed so far.",
                template: """
                def solve(values):
                    state = None  # define what this summarizes
                    for value in values:
                        state = update(state, value)
                    return state
                """,
                drill: "What does your state know after processing the first i inputs?",
                hint: "Write a complete sentence beginning: After i steps…",
                answer: "A useful invariant names precisely what the state represents for the processed prefix."
            )]
        )
    }

    static let courseModuleIDs = Set(courses.keys)

    static var allTechniques: [AlgorithmTechnique] {
        courses.values.flatMap(\.techniques) + SupplementalTechniqueCatalog.allTechniques
    }

    static var allTechniqueIDs: Set<String> { Set(allTechniques.map(\.id)) }

    static func technique(for techniqueID: String) -> AlgorithmTechnique? {
        allTechniques.first { $0.id == techniqueID }
    }

    static func moduleID(containingTechniqueID techniqueID: String) -> String? {
        if let entry = courses.first(where: { _, course in
            course.techniques.contains { $0.id == techniqueID }
        }) {
            return entry.key
        }
        return SupplementalTechniqueCatalog.moduleID(containing: techniqueID)
    }

    private static func technique(
        id: String,
        name: String,
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

    private static let courses: [String: ModuleCourse] = [
        "arrays-hashing": ModuleCourse(
            prerequisites: ["Python lists and for-loops", "Equality: knowing when two values count as the same"],
            techniques: [
                technique(
                    id: "hash-set", name: "Set for fast membership",
                    meaning: "A set stores each distinct value once and answers ‘have I seen x?’ directly, instead of scanning everything seen so far.",
                    math: "It represents a finite subset S. Membership x ∈ S is O(1) average time in Python, rather than O(|S|) for a list scan.",
                    use: ["You need existence or duplicate checks", "Order and multiplicity do not matter", "A nested scan is repeatedly asking the same membership question"],
                    avoid: "Do not use a set when occurrence counts, original order, or sorted iteration is part of the contract.",
                    invariant: "After processing positions 0 through i - 1, seen contains exactly their distinct values.",
                    template: """
                    def contains_duplicate(values):
                        seen = set()
                        for value in values:
                            if value in seen:
                                return True
                            seen.add(value)
                        return False
                    """,
                    drill: "Scan [4, 1, 4]. What is seen immediately before the final membership test?",
                    hint: "Insert only the first two values.", answer: "seen is {4, 1}; therefore the final 4 is already present."
                ),
                technique(
                    id: "hash-map", name: "Dictionary for counts or remembered facts",
                    meaning: "A dictionary attaches a fact to each key—for example a count, last position, or matching index—so it can be retrieved without another scan.",
                    math: "It is a finite function key ↦ stored value. Choose what the value means before writing updates.",
                    use: ["You need frequencies", "You must remember where a value occurred", "A complement or previously computed result must be found quickly"],
                    avoid: "A dictionary is unnecessary when the key range is tiny and fixed, or when you only need yes/no membership.",
                    invariant: "After a processed prefix, table[x] has the one precise meaning you declared for x.",
                    template: """
                    def frequencies(values):
                        counts = {}
                        for value in values:
                            counts[value] = counts.get(value, 0) + 1
                        return counts
                    """,
                    drill: "For ['a', 'b', 'a'], what should counts mean after two characters?",
                    hint: "State both existing keys and their multiplicities.", answer: "counts is {'a': 1, 'b': 1}; it counts only the processed prefix."
                )
            ]
        ),
        "two-pointers": ModuleCourse(
            prerequisites: ["Arrays & Hashing module", "Python indexing and while-loops", "The difference between values and positions"],
            techniques: [
                technique(
                    id: "opposing-pointers", name: "Two pointers from opposite ends",
                    meaning: "Keep one index at each end of an ordered search space. A comparison proves which endpoint cannot participate, so that pointer moves inward.",
                    math: "Maintain an interval [L, R] containing every candidate not yet ruled out. Each step removes at least one boundary candidate.",
                    use: ["The input is sorted or the objective depends on two extremes", "You seek a pair", "The comparison gives a safe direction to move"],
                    avoid: "Without order or a monotonic rule, moving a pointer may discard a valid answer without proof.",
                    invariant: "No valid candidate exists outside the current [left, right] search interval unless it was already recorded.",
                    template: """
                    def find_pair(numbers, target):
                        left, right = 0, len(numbers) - 1
                        while left < right:
                            total = numbers[left] + numbers[right]
                            if total == target: return [left, right]
                            if total < target: left += 1
                            else: right -= 1
                        return []
                    """,
                    drill: "In sorted [1, 3, 8, 10], target 11, why may left move when the sum is 9?",
                    hint: "Fix the current left value and compare it with every smaller right value.", answer: "1 + 8 is already too small, and any earlier right endpoint is no larger; 1 cannot work, so discard it."
                ),
                technique(
                    id: "read-write-pointers", name: "Read and write pointers",
                    meaning: "One index inspects every input item; another marks where the next accepted item belongs. This compacts or transforms in one pass.",
                    math: "The prefix before write is the completed output for everything read so far.",
                    use: ["Filter or deduplicate in place", "Preserve accepted items' relative order", "The output is a compacted prefix"],
                    avoid: "Use a simple new output list when in-place mutation is not required and clarity matters more than auxiliary space.",
                    invariant: "values[:write] is exactly the desired result for values[:read].",
                    template: """
                    def keep_nonnegative(values):
                        write = 0
                        for read in range(len(values)):
                            if values[read] >= 0:
                                values[write] = values[read]
                                write += 1
                        return write
                    """,
                    drill: "After reading [3, -1, 5], what prefix and write value should remain?",
                    hint: "Only accepted values advance write.", answer: "The completed prefix is [3, 5] and write is 2."
                )
            ]
        ),
        "sliding-window": ModuleCourse(
            prerequisites: ["Two Pointers module", "Arrays & Hashing module", "Contiguous means no positions may be skipped"],
            techniques: [
                technique(
                    id: "fixed-window", name: "Fixed-size sliding window",
                    meaning: "For every neighboring block of k items, update the previous block by subtracting the item that leaves and adding the item that enters.",
                    math: "W(i + 1) = W(i) − a[i] + a[i + k], so each range costs O(1) after the first sum.",
                    use: ["Every candidate is a contiguous block of exactly k items", "Adjacent candidates overlap heavily", "The aggregate can remove and add boundary contributions"],
                    avoid: "It does not fit subsequences, non-contiguous choices, or ranges whose size must change.",
                    invariant: "window_sum equals the sum of exactly the k values ending at the current right boundary.",
                    template: """
                    def best_k_sum(values, k):
                        window = sum(values[:k])
                        best = window
                        for right in range(k, len(values)):
                            window += values[right] - values[right - k]
                            best = max(best, window)
                        return best
                    """,
                    drill: "Window [2, 5, 1] has sum 8. Slide right to include 4. What update is made?",
                    hint: "Remove the old left boundary and add the new right boundary.", answer: "8 - 2 + 4 = 10; the new window is [5, 1, 4]."
                ),
                technique(
                    id: "variable-window", name: "Grow-and-shrink sliding window",
                    meaning: "Move the right boundary to gain information, then move the left boundary only while needed to restore validity or minimality.",
                    math: "Each boundary moves at most n times, so two nested-looking while/for loops can still total O(n).",
                    use: ["The answer is a contiguous range", "Validity changes monotonically as a boundary moves", "Counts or a running total summarize the range"],
                    avoid: "If removing the left item does not predictably restore the condition—common with arbitrary negative sums—the window rule may be invalid.",
                    invariant: "The stored counts or total describe exactly values[left...right], and the stated validity rule holds at the point where an answer is recorded.",
                    template: """
                    def longest_with_sum_at_most(values, limit):
                        left = total = best = 0
                        for right, value in enumerate(values):
                            total += value
                            while total > limit:
                                total -= values[left]
                                left += 1
                            best = max(best, right - left + 1)
                        return best
                    """,
                    drill: "Why is the template unsafe if values may contain negative numbers?",
                    hint: "Ask whether shrinking always moves total in the needed direction.", answer: "Removing a negative number increases the total, so the monotonic restore-validity argument fails."
                )
            ]
        ),
        "stack": ModuleCourse(
            prerequisites: ["Python lists and append/pop", "Arrays & Hashing module"],
            techniques: [
                technique(
                    id: "lifo-stack", name: "Last-in, first-out stack",
                    meaning: "A stack remembers unfinished items so the most recently opened or deferred item is handled first. In Python, append pushes and pop removes the top.",
                    math: "It models properly nested structure: the next closing event must match the latest unmatched opening event.",
                    use: ["Nested brackets or calls must close correctly", "Undoing happens in reverse order", "A token consumes the most recent unfinished result"],
                    avoid: "A queue is needed when the earliest waiting item must be handled first.",
                    invariant: "The stack contains exactly the unfinished items, in their original order with the newest on top.",
                    template: """
                    def balanced(text):
                        matching = {')': '(', ']': '[', '}': '{'}
                        stack = []
                        for char in text:
                            if char in matching.values(): stack.append(char)
                            elif not stack or stack.pop() != matching[char]: return False
                        return not stack
                    """,
                    drill: "After scanning '([]', what is on the stack and what must close next?",
                    hint: "The most recent unmatched opening is on top.", answer: "The stack is ['(', '[']; ']' must close next before ')'."
                ),
                technique(
                    id: "monotonic-stack", name: "Monotonic stack",
                    meaning: "Keep only unresolved candidates in increasing or decreasing order. A new value resolves and removes candidates it defeats.",
                    math: "Every index is pushed once and popped at most once, giving O(n) total work despite a while-loop inside the scan.",
                    use: ["Nearest greater or smaller item", "Each earlier item waits for a future answer", "Dominated candidates can never matter again"],
                    avoid: "Do not choose the increasing/decreasing direction by memory; derive which candidates the new value resolves.",
                    invariant: "Indices in the stack are unresolved and their values follow the declared monotonic order.",
                    template: """
                    def next_greater(values):
                        answer = [-1] * len(values)
                        stack = []
                        for i, value in enumerate(values):
                            while stack and values[stack[-1]] < value:
                                answer[stack.pop()] = value
                            stack.append(i)
                        return answer
                    """,
                    drill: "For [3, 1, 4], which indices are popped when 4 arrives?",
                    hint: "Both unresolved values are smaller than 4.", answer: "Indices 1 and 0 pop; their next greater value is 4."
                )
            ]
        ),
        "linked-lists": ModuleCourse(
            prerequisites: ["References: a variable can point to an object", "The distinction between a node and the value stored in it"],
            techniques: [
                technique(
                    id: "sentinel-rewiring", name: "Sentinel node and pointer rewiring",
                    meaning: "A linked list stores each next location explicitly. A temporary dummy node before the head makes deleting or inserting at the first real node obey the same rule as every other position.",
                    math: "Treat next as a function from nodes to nodes or None; an edit changes a small number of function arrows.",
                    use: ["Insertions or deletions may affect the head", "You must preserve the rest of the chain", "Array indices are unavailable"],
                    avoid: "Do not overwrite a next pointer before saving the part of the chain that would become unreachable.",
                    invariant: "The processed prefix is correctly linked and current points to the first unprocessed node.",
                    template: """
                    def remove_value(head, target):
                        dummy = ListNode(0, head)
                        previous, current = dummy, head
                        while current:
                            if current.val == target: previous.next = current.next
                            else: previous = current
                            current = current.next
                        return dummy.next
                    """,
                    drill: "Why does dummy help when the original head must be deleted?",
                    hint: "Ask what node can play the role of previous.", answer: "dummy is a stable predecessor, so previous.next = head.next uses the ordinary deletion rule."
                ),
                technique(
                    id: "fast-slow", name: "Fast and slow pointers",
                    meaning: "Move one reference one step and another two steps. Their relative motion reveals a midpoint or cycle without storing every visited node.",
                    math: "In a cycle of length c, the distance between pointers changes by 1 modulo c each round, so they must eventually meet.",
                    use: ["Find a midpoint", "Detect a cycle", "Compare positions separated by a changing distance"],
                    avoid: "Check fast and fast.next before advancing two steps; otherwise short lists crash.",
                    invariant: "After t rounds, slow has moved t edges and fast has moved 2t edges whenever those nodes exist.",
                    template: """
                    def has_cycle(head):
                        slow = fast = head
                        while fast and fast.next:
                            slow = slow.next
                            fast = fast.next.next
                            if slow is fast: return True
                        return False
                    """,
                    drill: "Why is value equality insufficient for detecting a linked-list cycle?",
                    hint: "Different nodes may store the same number.", answer: "A cycle means revisiting the same node object, so compare identity, not stored values."
                )
            ]
        ),
        "binary-search": ModuleCourse(
            prerequisites: ["Two Pointers module", "Integer division and half-open intervals", "A monotonic predicate: once true, it stays true"],
            techniques: [
                technique(
                    id: "boundary-search", name: "Binary search for a boundary",
                    meaning: "When candidates are ordered, test the middle and discard the half that a proof says cannot contain the first valid answer.",
                    math: "Maintain a half-open interval [lo, hi) containing the boundary. Its length roughly halves each iteration.",
                    use: ["Sorted data", "Find first/last occurrence", "A yes/no condition changes only once from false to true"],
                    avoid: "Binary search is invalid when the predicate can alternate between true and false across the search space.",
                    invariant: "The desired first-true boundary remains inside [lo, hi).",
                    template: """
                    def first_true(lo, hi, condition):
                        while lo < hi:
                            mid = (lo + hi) // 2
                            if condition(mid): hi = mid
                            else: lo = mid + 1
                        return lo
                    """,
                    drill: "If condition(mid) is true and you seek the first true point, why keep mid?",
                    hint: "mid might itself be the first true candidate.", answer: "Set hi = mid; discard only values strictly to its right."
                ),
                technique(
                    id: "answer-search", name: "Binary search on the answer",
                    meaning: "Sometimes the input is not sorted, but possible answer values are. Ask whether a proposed capacity, speed, or distance is feasible.",
                    math: "Convert optimization into a monotonic predicate feasible(x), then locate its transition boundary.",
                    use: ["Minimize a feasible capacity or speed", "Maximize a feasible threshold", "Checking one candidate is much cheaper than trying all candidates"],
                    avoid: "You need a proof that feasibility is monotonic and correct lower/upper bounds.",
                    invariant: "The optimal answer remains within the current numeric bounds.",
                    template: """
                    def minimum_feasible(low, high, feasible):
                        while low < high:
                            mid = (low + high) // 2
                            if feasible(mid): high = mid
                            else: low = mid + 1
                        return low
                    """,
                    drill: "If a ship capacity C works, why do all larger capacities work?",
                    hint: "A larger ship can reproduce the smaller ship's loading plan.", answer: "Capacity only relaxes the constraint, establishing a false…false, true…true predicate."
                )
            ]
        ),
        "intervals": ModuleCourse(
            prerequisites: ["Python sorting with a key", "Boundary conventions such as closed [a, b] versus half-open [a, b)"],
            techniques: [
                technique(
                    id: "sort-merge", name: "Sort and merge intervals",
                    meaning: "Sort ranges by start time. Then only the most recently merged range can overlap the next one, so earlier ranges never need rescanning.",
                    math: "After sorting by starts, if next.start exceeds current.end there is a gap; otherwise extend current.end to max of both ends.",
                    use: ["Combine overlaps", "Find gaps", "Order of returned ranges can be chronological"],
                    avoid: "Clarify whether touching endpoints overlap before choosing < or ≤.",
                    invariant: "merged is disjoint and exactly covers all intervals processed so far.",
                    template: """
                    def merge(intervals):
                        intervals.sort(key=lambda pair: pair[0])
                        merged = []
                        for start, end in intervals:
                            if not merged or start > merged[-1][1]: merged.append([start, end])
                            else: merged[-1][1] = max(merged[-1][1], end)
                        return merged
                    """,
                    drill: "For closed intervals [1, 3] and [3, 5], merge or separate?",
                    hint: "The shared endpoint belongs to both closed intervals.", answer: "Merge them to [1, 5]. For half-open intervals the answer could differ."
                ),
                technique(
                    id: "sweep-events", name: "Sweep line with start/end events",
                    meaning: "Turn every interval boundary into a change event, sort the events, and carry a running number of active intervals.",
                    math: "active(t) is a prefix sum of +1 start events and −1 end events.",
                    use: ["Count simultaneous meetings", "Find maximum overlap", "Many ranges contribute add/remove changes"],
                    avoid: "Tie ordering at equal times must match the interval convention.",
                    invariant: "After processing all events through time t, active equals the number of intervals covering t under the stated convention.",
                    template: """
                    def max_overlap(intervals):
                        events = []
                        for start, end in intervals:
                            events += [(start, 1), (end, -1)]
                        active = best = 0
                        for _, change in sorted(events):
                            active += change
                            best = max(best, active)
                        return best
                    """,
                    drill: "For half-open meetings ending and starting at time 3, which event must occur first?",
                    hint: "[1, 3) no longer occupies time 3.", answer: "Process the end (−1) before the start (+1), so they do not falsely overlap."
                )
            ]
        ),
        "trees": ModuleCourse(
            prerequisites: ["Python functions and base cases", "Linked-list references help, but are not required"],
            techniques: [
                technique(
                    id: "tree-dfs", name: "Depth-first search (DFS) on a tree",
                    meaning: "Solve the same smaller question for each child subtree, then combine their answers at the parent. Recursion remembers the path for you.",
                    math: "Define F(node) from F(node.left) and F(node.right), with F(None) as the base case.",
                    use: ["A subtree can return a useful summary", "You need path or structural properties", "Children should be fully processed before combining"],
                    avoid: "Very deep trees can exceed Python's recursion limit; use an explicit stack then.",
                    invariant: "A recursive call returns the precisely defined correct result for its entire subtree.",
                    template: """
                    def depth(node):
                        if node is None: return 0
                        left_depth = depth(node.left)
                        right_depth = depth(node.right)
                        return 1 + max(left_depth, right_depth)
                    """,
                    drill: "What must depth(None) be so a leaf has depth 1?",
                    hint: "A leaf adds 1 to two empty subtrees.", answer: "0, making a leaf return 1 + max(0, 0) = 1."
                ),
                technique(
                    id: "tree-bfs", name: "Breadth-first search (BFS) by level",
                    meaning: "A queue processes nodes in increasing distance from the root: all of level d before level d + 1.",
                    math: "The queue is the current frontier. Capturing its length freezes exactly one level's nodes.",
                    use: ["Level order or level averages", "Minimum number of edges", "Nearest node satisfying a property"],
                    avoid: "DFS is often simpler when level order and shortest unweighted distance do not matter.",
                    invariant: "At the start of a level iteration, the queue contains exactly that level's nodes.",
                    template: """
                    def levels(root):
                        if root is None: return []
                        queue, answer = [root], []
                        while queue:
                            level = []
                            for _ in range(len(queue)):
                                node = queue.pop(0)
                                level.append(node.val)
                                if node.left: queue.append(node.left)
                                if node.right: queue.append(node.right)
                            answer.append(level)
                        return answer
                    """,
                    drill: "Why record len(queue) before processing a level?",
                    hint: "Children are appended during the loop.", answer: "The saved length prevents newly added next-level nodes from being processed in the current level."
                )
            ]
        ),
        "queues-heaps": ModuleCourse(
            prerequisites: ["Stacks module", "Trees module for understanding heap shape", "Python lists"],
            techniques: [
                technique(
                    id: "fifo-queue", name: "First-in, first-out queue",
                    meaning: "A queue serves the earliest waiting item first. It is the right memory model for waves, levels, and arrival order.",
                    math: "Items leave in the same order they enter, unlike a stack's reverse order.",
                    use: ["Breadth-first exploration", "Simulate arrivals", "Process tasks fairly in discovery order"],
                    avoid: "In production Python use collections.deque; list.pop(0) shifts all later elements and costs O(n).",
                    invariant: "The queue holds discovered but unprocessed items in discovery order.",
                    template: """
                    from collections import deque

                    def process(start):
                        queue = deque([start])
                        while queue:
                            item = queue.popleft()
                            for neighbor in neighbors(item):
                                queue.append(neighbor)
                    """,
                    drill: "A, then B, then C enter a queue. Which leaves first?",
                    hint: "FIFO means first in, first out.", answer: "A leaves first."
                ),
                technique(
                    id: "heap", name: "Heap for the next extreme",
                    meaning: "A heap maintains a collection so the smallest item can always be removed quickly, without fully sorting after every insertion.",
                    math: "The root is minimal; insert and removal repair a logarithmic-height tree in O(log n).",
                    use: ["Repeatedly need the next smallest/largest", "Keep only top k values", "Merge several sorted streams"],
                    avoid: "If you need the entire collection once in order, sorting once is often simpler and equally good asymptotically.",
                    invariant: "The heap property holds: every parent key is no greater than its children, so heap[0] is minimal.",
                    template: """
                    import heapq

                    def k_largest(values, k):
                        heap = []
                        for value in values:
                            heapq.heappush(heap, value)
                            if len(heap) > k: heapq.heappop(heap)
                        return sorted(heap, reverse=True)
                    """,
                    drill: "Why does a size-k min-heap retain the k largest values?",
                    hint: "When size exceeds k, which value is discarded?",
                    answer: "It discards the smallest retained value, leaving the largest k values seen so far."
                )
            ]
        ),
        "tries-strings": ModuleCourse(
            prerequisites: ["Arrays & Hashing module", "Trees module", "String indexing and prefixes"],
            techniques: [
                technique(
                    id: "trie", name: "Trie (prefix tree)",
                    meaning: "A trie shares the beginning of words. Each edge is one character, so all words with the same prefix follow the same initial path.",
                    math: "A node represents a prefix p; its child labelled c represents p + c.",
                    use: ["Many prefix queries", "Dictionary word search", "Words share prefixes and are inserted or queried repeatedly"],
                    avoid: "For a few exact membership checks, a set is much smaller and simpler.",
                    invariant: "Following characters c₀…cᵢ reaches the unique node representing that exact prefix.",
                    template: """
                    def insert(root, word):
                        node = root
                        for char in word:
                            node = node.setdefault(char, {})
                        node['#'] = True
                    """,
                    drill: "After inserting 'car' and 'cat', which prefix nodes are shared?",
                    hint: "Compare characters left to right until they differ.", answer: "The root → 'c' → 'a' path is shared; 'r' and 't' branch afterward."
                ),
                technique(
                    id: "prefix-fallback", name: "Prefix fallback (KMP idea)",
                    meaning: "While matching a pattern, remember how much of its beginning is also a suffix of what matched. A mismatch reuses that knowledge instead of restarting from zero.",
                    math: "prefix[i] is the longest proper prefix of pattern[:i+1] that is also its suffix.",
                    use: ["Linear-time substring search", "Repeated prefix/suffix structure", "Naive matching repeatedly rechecks characters"],
                    avoid: "For small inputs, Python's built-in substring operation is clearer; learn KMP when the algorithm itself is assessed.",
                    invariant: "matched is the length of the longest pattern prefix matching a suffix of text processed so far.",
                    template: """
                    def prefix_table(pattern):
                        table = [0] * len(pattern)
                        matched = 0
                        for i in range(1, len(pattern)):
                            while matched and pattern[i] != pattern[matched]:
                                matched = table[matched - 1]
                            if pattern[i] == pattern[matched]: matched += 1
                            table[i] = matched
                        return table
                    """,
                    drill: "Why does fallback use table[matched - 1] rather than matched -= 1?",
                    hint: "The table already knows the next longest viable border.", answer: "It skips impossible border lengths while preserving every prefix that could still match."
                )
            ]
        ),
        "graphs": ModuleCourse(
            prerequisites: ["Stacks and Queues modules", "Trees module", "Arrays & Hashing for the visited set"],
            techniques: [
                technique(
                    id: "graph-search", name: "Graph DFS and BFS",
                    meaning: "Explore neighbors while marking vertices already seen. DFS uses a stack and goes deep; BFS uses a queue and expands in distance layers.",
                    math: "A graph is vertices V and edges E. With a visited set, each vertex and edge is processed O(1) times: O(|V| + |E|).",
                    use: ["Reachability or connected components", "Arbitrary relationships rather than parent-child structure", "BFS for shortest path in an unweighted graph"],
                    avoid: "Mark nodes when they are scheduled, not later, or cycles can enqueue the same node many times.",
                    invariant: "visited is exactly the set already discovered; the frontier contains discovered but unfinished vertices.",
                    template: """
                    from collections import deque

                    def reachable(graph, start):
                        queue, visited = deque([start]), {start}
                        while queue:
                            node = queue.popleft()
                            for neighbor in graph[node]:
                                if neighbor not in visited:
                                    visited.add(neighbor)
                                    queue.append(neighbor)
                        return visited
                    """,
                    drill: "Why add a neighbor to visited when enqueuing rather than when removing it?",
                    hint: "Two current nodes may share the same neighbor.", answer: "Early marking prevents both parents from enqueuing duplicate work."
                ),
                technique(
                    id: "topological-sort", name: "Topological ordering",
                    meaning: "For directed prerequisites, repeatedly take an item with no unmet prerequisites. If all items are taken, the dependencies contain no directed cycle.",
                    math: "indegree[v] counts incoming edges from unprocessed vertices; removing u subtracts its outgoing contributions.",
                    use: ["Course or build prerequisites", "Find a valid dependency order", "Detect a cycle in a directed graph"],
                    avoid: "A topological order is not defined for undirected graphs or directed graphs containing a cycle.",
                    invariant: "The queue contains exactly available zero-indegree vertices, and indegrees count only remaining edges.",
                    template: """
                    def topo_order(graph, indegree):
                        queue = [v for v in graph if indegree[v] == 0]
                        order = []
                        for node in queue:
                            order.append(node)
                            for nxt in graph[node]:
                                indegree[nxt] -= 1
                                if indegree[nxt] == 0: queue.append(nxt)
                        return order if len(order) == len(graph) else []
                    """,
                    drill: "What proves there is a cycle if the queue empties early?",
                    hint: "Every remaining vertex still has an incoming edge from the remaining subgraph.", answer: "No remaining prerequisite can be removed first, so following dependencies must eventually repeat a vertex—a cycle."
                )
            ]
        ),
        "union-find": ModuleCourse(
            prerequisites: ["Graphs module", "Trees and parent references", "Arrays & Hashing"],
            techniques: [technique(
                id: "disjoint-set", name: "Disjoint-set union (union–find)",
                meaning: "Maintain a partition of items into connected groups. find gives a group's representative; union merges two groups when an edge connects them.",
                math: "The representatives encode an equivalence relation: reflexive, symmetric, and transitive connectivity.",
                use: ["Edges arrive over time", "Repeated ‘same component?’ queries", "Kruskal-style minimum spanning tree"],
                avoid: "It answers connectivity, not the actual path or shortest distance between vertices.",
                invariant: "Two items have the same root exactly when the processed edges connect them.",
                template: """
                def find(parent, x):
                    if parent[x] != x:
                        parent[x] = find(parent, parent[x])
                    return parent[x]

                def union(parent, a, b):
                    parent[find(parent, a)] = find(parent, b)
                """,
                drill: "If find(a) == find(b), what should union(a, b) change?",
                hint: "They already represent the same equivalence class.", answer: "Nothing; the new edge is redundant for connectivity."
            )]
        ),
        "backtracking": ModuleCourse(
            prerequisites: ["Tree DFS module", "Python list append/pop", "Sets for used choices"],
            techniques: [technique(
                id: "choose-explore-undo", name: "Choose → explore → undo",
                meaning: "Build one partial candidate, recursively try every legal next choice, then undo the choice so the same state can explore a different branch.",
                math: "The recursion tree contains partial solutions; pruning proves an entire subtree cannot contain a valid completion.",
                use: ["Return all combinations, permutations, or placements", "The problem naturally branches into choices", "Partial invalidity can be detected early"],
                avoid: "If only an optimal value is needed and many branches reach the same state, dynamic programming may avoid exponential repetition.",
                invariant: "path is exactly the choices on the current recursion branch; used records exactly what that path forbids reusing.",
                template: """
                def all_choices(values):
                    answer, path = [], []
                    def search(start):
                        answer.append(path.copy())
                        for i in range(start, len(values)):
                            path.append(values[i])
                            search(i + 1)
                            path.pop()
                    search(0)
                    return answer
                """,
                drill: "Why append path.copy() rather than path?",
                hint: "The same path list is mutated after every recursive return.", answer: "A copy freezes the current solution; storing path itself would make every result refer to one changing list."
            )]
        ),
        "bit-math": ModuleCourse(
            prerequisites: ["Binary place values", "Python integer arithmetic and //", "Arrays & Hashing"],
            techniques: [
                technique(
                    id: "bit-mask", name: "Bit mask",
                    meaning: "Use each binary digit as an independent yes/no flag. AND tests a flag, OR sets it, XOR toggles it.",
                    math: "An integer represents a subset: bit i is 1 exactly when element i belongs to the subset.",
                    use: ["A small collection of Boolean states", "Subset enumeration", "Parity or cancellation with XOR"],
                    avoid: "Ordinary sets are clearer when the universe is large, dynamic, or not naturally indexed by small integers.",
                    invariant: "Bit i has one declared meaning and every operation preserves that mapping.",
                    template: """
                    def contains(mask, index):
                        return (mask & (1 << index)) != 0

                    def add(mask, index):
                        return mask | (1 << index)
                    """,
                    drill: "What subset of {0,1,2,3} does binary 1010 represent?",
                    hint: "Read set-bit positions from the right, starting at 0.", answer: "{1, 3}."
                ),
                technique(
                    id: "fast-power", name: "Exponentiation by squaring",
                    meaning: "Square the base while halving the exponent, multiplying the answer only when the current binary digit is 1.",
                    math: "x^(2k) = (x²)^k and x^(2k+1) = x·(x²)^k, reducing n to ⌊n/2⌋ each step.",
                    use: ["Large integer exponents", "Repeated doubling/halving structure", "Modular powers"],
                    avoid: "Handle negative exponents and overflow/modular requirements explicitly.",
                    invariant: "answer × base^exponent equals the original requested power.",
                    template: """
                    def power(base, exponent):
                        answer = 1
                        while exponent:
                            if exponent % 2: answer *= base
                            base *= base
                            exponent //= 2
                        return answer
                    """,
                    drill: "For x^13, at which binary exponent bits is x's accumulated base multiplied in?",
                    hint: "13 is binary 1101.", answer: "At weights 1, 4, and 8, because 13 = 1 + 4 + 8."
                )
            ]
        ),
        "dynamic-programming": ModuleCourse(
            prerequisites: ["Recursion and tree DFS", "Arrays & Hashing for memo tables", "Writing a recurrence with a base case"],
            techniques: [technique(
                id: "memo-tabulation", name: "Dynamic programming: memoization and tabulation",
                meaning: "Name a smaller state whose answer is reused. Memoization caches recursive calls; tabulation computes states in an order where dependencies are already known.",
                math: "Define F(s) by a recurrence over smaller states. The number of distinct states times work per transition determines complexity.",
                use: ["The same state appears in many recursion branches", "Count ways or optimize a value", "A choice leaves a smaller version of the problem"],
                avoid: "Do not use DP merely because a prompt asks for a maximum; first identify overlapping subproblems and a sufficient state.",
                invariant: "Every stored dp[state] is the correct answer to the exact subproblem named by state.",
                template: """
                def climb(n):
                    if n <= 1: return 1
                    previous_two, previous_one = 1, 1
                    for _ in range(2, n + 1):
                        current = previous_one + previous_two
                        previous_two, previous_one = previous_one, current
                    return previous_one
                """,
                drill: "Why is ‘position i’ sufficient state for ordinary stair climbing, but not if some steps have limited-use coupons?",
                hint: "Can two histories reaching i have different futures?",
                answer: "Without coupons their future options match; with coupons, remaining coupon state also changes future choices and must join the DP state."
            )]
        ),
        "greedy": ModuleCourse(
            prerequisites: ["Sorting", "Intervals module", "Proof by exchange or contradiction"],
            techniques: [technique(
                id: "greedy-choice", name: "Greedy choice with an exchange proof",
                meaning: "Commit to the locally safest choice and never reconsider it—but only after proving any optimal solution can be changed to use that choice without becoming worse.",
                math: "An exchange argument transforms an unknown optimum O into another optimum O′ containing the greedy choice.",
                use: ["One choice leaves at least as much future freedom as alternatives", "Sorting exposes a dominant next choice", "Only feasibility or an extreme count/value must be preserved"],
                avoid: "A plausible local choice is not enough. If the exchange step fails, dynamic programming may be required.",
                invariant: "After each choice, the partial solution can still be extended to some globally optimal complete solution.",
                template: """
                def max_nonoverlapping(intervals):
                    intervals.sort(key=lambda interval: interval[1])
                    chosen, last_end = 0, float('-inf')
                    for start, end in intervals:
                        if start >= last_end:
                            chosen += 1
                            last_end = end
                    return chosen
                """,
                drill: "Why choose the compatible interval ending earliest rather than starting earliest?",
                hint: "Which choice leaves the largest remaining time region?",
                answer: "Replacing any first chosen interval by an earlier-ending compatible one cannot remove future options, so an optimum exists with the greedy choice."
            )]
        ),
        "advanced": ModuleCourse(
            prerequisites: ["Complete Arrays through Greedy modules", "Ability to derive time bounds from constraints", "Comfort combining two invariants"],
            techniques: [
                technique(
                    id: "lis-tails", name: "Increasing-subsequence tails",
                    meaning: "For each possible subsequence length, remember the smallest ending value found. A smaller tail leaves more room to extend later.",
                    math: "tails[k] is the minimum final value among increasing subsequences of length k + 1; tails remains sorted, enabling binary search.",
                    use: ["Longest increasing subsequence length", "Quadratic pair comparisons are too slow", "A dominated larger tail can be replaced safely"],
                    avoid: "tails does not itself store the actual subsequence unless predecessor information is added.",
                    invariant: "tails is increasing and stores the minimum achievable tail for every represented length.",
                    template: """
                    from bisect import bisect_left

                    def lis_length(values):
                        tails = []
                        for value in values:
                            i = bisect_left(tails, value)
                            if i == len(tails): tails.append(value)
                            else: tails[i] = value
                        return len(tails)
                    """,
                    drill: "Why may replacing tail 9 by 6 preserve the best length?",
                    hint: "Any future value greater than 9 is also greater than 6.", answer: "The length is unchanged and 6 can be extended by every value that extended 9, plus possibly more."
                ),
                technique(
                    id: "synthesis", name: "Constraint-driven synthesis",
                    meaning: "Hard problems often combine familiar tools. Use constraints to set a complexity budget, then name each component and its separate invariant.",
                    math: "If n ≈ 10⁵, O(n²) is usually impossible; seek O(n) or O(n log n) structure and account for every nested operation.",
                    use: ["A familiar core needs extra state", "Representation change creates monotonicity", "Two independently provable stages compose"],
                    avoid: "Do not stack sophisticated techniques before stating what each one contributes.",
                    invariant: "Each component maintains its own declared fact, and the interface between components preserves both facts.",
                    template: """
                    def solve(values):
                        # 1. State the required complexity from len(values).
                        # 2. Name component A and its invariant.
                        # 3. Name component B and its invariant.
                        raise NotImplementedError
                    """,
                    drill: "If n = 100,000, roughly how many pair checks does O(n²) make?",
                    hint: "Square 10^5.", answer: "About 10^10 checks, which rules out a direct all-pairs scan."
                )
            ]
        ),
        "advanced-data-structures": ModuleCourse(
            prerequisites: ["Arrays & Hashing", "Trees", "Binary representation", "Linked-list pointer rewiring"],
            techniques: [
                technique(
                    id: "fenwick-tree", name: "Fenwick tree (binary indexed tree)",
                    meaning: "Store overlapping prefix summaries so a point update and a prefix-sum query each visit only logarithmically many array cells.",
                    math: "Index i stores a block whose length is its least significant set bit; i += i & -i climbs update containers, i -= i & -i removes query blocks.",
                    use: ["Many interleaved point updates and prefix/range sums", "Values are indexed", "O(log n) per operation is required"],
                    avoid: "For static data, ordinary prefix sums are simpler and give O(1) range queries.",
                    invariant: "tree[i] equals the sum of the precise lowbit-sized range ending at i.",
                    template: """
                    def add(tree, index, delta):
                        index += 1
                        while index < len(tree):
                            tree[index] += delta
                            index += index & -index

                    def prefix_sum(tree, index):
                        total, index = 0, index + 1
                        while index:
                            total += tree[index]
                            index -= index & -index
                        return total
                    """,
                    drill: "Why does range_sum(left, right) equal prefix(right) - prefix(left - 1)?",
                    hint: "Write each prefix as a finite sum.", answer: "All terms before left occur in both prefixes and cancel, leaving exactly left through right."
                ),
                technique(
                    id: "lru-map-list", name: "Hash map + linked order for LRU",
                    meaning: "Combine a dictionary for direct lookup with a doubly linked list for recency order. Neither structure alone makes both operations constant time.",
                    math: "The map is key ↦ node; the list orders nodes from least to most recent. Each access performs a constant number of pointer edits.",
                    use: ["O(1) average lookup and eviction", "Recency changes on every access", "A capacity bound requires removing the oldest item"],
                    avoid: "A plain ordered list makes lookup O(n); a plain dictionary does not directly encode the least-recent item under the intended exercise model.",
                    invariant: "The map and list contain exactly the same live entries, and list order equals least-to-most recent access.",
                    template: """
                    def touch(cache, node):
                        # Detach node from its current neighbors.
                        node.prev.next = node.next
                        node.next.prev = node.prev
                        # Reinsert immediately before the most-recent sentinel.
                        insert_before_most_recent(node)
                    """,
                    drill: "When key x is read successfully, why must its node move even though its value did not change?",
                    hint: "LRU orders by access, not mutation.", answer: "The read makes x most recent; failing to move it could evict the wrong key later."
                )
            ]
        ),
        "ml-tensor-foundations": ModuleCourse(
            prerequisites: ["Python nested lists and loops", "Matrix multiplication and indexed sums", "Probability and logarithms"],
            techniques: [
                technique(
                    id: "shape-indexing", name: "Shape-first indexed computation",
                    meaning: "Name every axis before coding, write one output element as a sum, then translate each mathematical index into a loop.",
                    math: "For C = AB, C[i,j] = Σₖ A[i,k]B[k,j]; k is contracted while i and j remain output axes.",
                    use: ["Implement tensor operations from first principles", "Debug broadcasting or shape errors", "Translate equations into code"],
                    avoid: "Do not use einsum in exercises explicitly asking for from-scratch mechanics; vectorize only after the indexed definition is correct.",
                    invariant: "Each accumulator contains exactly the terms for one declared output coordinate.",
                    template: """
                    def matrix_multiply(a, b):
                        rows, inner, cols = len(a), len(b), len(b[0])
                        out = [[0.0] * cols for _ in range(rows)]
                        for i in range(rows):
                            for j in range(cols):
                                for k in range(inner):
                                    out[i][j] += a[i][k] * b[k][j]
                        return out
                    """,
                    drill: "For A shape (2, 3) and B shape (3, 4), what is C's shape and contracted axis?",
                    hint: "Keep the outer dimensions and sum over the equal inner dimensions.", answer: "C has shape (2, 4), and k ranges over the shared size 3 axis."
                ),
                technique(
                    id: "stable-normalization", name: "Numerically stable normalization",
                    meaning: "Algebraically shift scores before exponentiating so finite-precision arithmetic does not overflow, while leaving normalized ratios unchanged.",
                    math: "softmax(xᵢ) = exp(xᵢ − m) / Σⱼ exp(xⱼ − m), usually with m = max(x).",
                    use: ["Softmax, log-sum-exp, cross entropy", "Large logits", "Exponentials or logarithms"],
                    avoid: "Stability transformations must preserve the exact mathematical quantity; do not clamp silently without a stated policy.",
                    invariant: "Shifted exponentials have the same normalized ratios as the originals and at least one exponent is zero.",
                    template: """
                    from math import exp

                    def stable_softmax(logits):
                        maximum = max(logits)
                        weights = [exp(x - maximum) for x in logits]
                        total = sum(weights)
                        return [weight / total for weight in weights]
                    """,
                    drill: "Why does subtracting the same maximum not change softmax probabilities?",
                    hint: "Factor exp(-maximum) from numerator and denominator.", answer: "The common positive factor cancels from every ratio."
                )
            ]
        ),
        "ml-training-mechanics": ModuleCourse(
            prerequisites: ["Tensor & Numerical Foundations lab", "Single-variable and multivariable chain rule", "Means, variances, and gradients"],
            techniques: [
                technique(
                    id: "computation-graph", name: "Forward cache and reverse-mode chain rule",
                    meaning: "Break a model into simple operations, save forward quantities, then propagate how the loss changes backward through each local derivative.",
                    math: "If L = f(g(x)), then dL/dx = (dL/df)(df/dg)(dg/dx); shared paths add gradient contributions.",
                    use: ["Manual backpropagation", "Debug gradients", "Implement a layer's backward pass"],
                    avoid: "Match gradient shapes and sum over broadcast axes; a numerically plausible value can still have wrong semantics.",
                    invariant: "Each backward variable is the derivative of the final scalar loss with respect to the named forward quantity.",
                    template: """
                    def linear_backward(x, weights, grad_output):
                        # y[b, o] = sum_i x[b, i] * weights[i, o]
                        grad_x = matrix_multiply(grad_output, transpose(weights))
                        grad_weights = matrix_multiply(transpose(x), grad_output)
                        return grad_x, grad_weights
                    """,
                    drill: "If one parameter influences the loss along two graph paths, combine gradients how?",
                    hint: "Different infinitesimal effects superpose.", answer: "Add the two path contributions."
                ),
                technique(
                    id: "optimizer-state", name: "Stateful optimizer update",
                    meaning: "An optimizer may remember moving averages for each parameter. Update that state in the specified order, correct initialization bias, then change the parameter.",
                    math: "Adam tracks mₜ = β₁mₜ₋₁ +(1−β₁)gₜ and vₜ = β₂vₜ₋₁ +(1−β₂)gₜ² before bias correction.",
                    use: ["Implement SGD with momentum or Adam", "Reason about training checkpoints", "Understand per-parameter optimizer memory"],
                    avoid: "Do not mix step numbering or epsilon placement; small formula differences can change expected results.",
                    invariant: "Moment state summarizes gradients through the current step, and the parameter update uses state corrected for that same step.",
                    template: """
                    def momentum_step(parameter, gradient, velocity, rate, beta):
                        velocity = beta * velocity + (1 - beta) * gradient
                        parameter = parameter - rate * velocity
                        return parameter, velocity
                    """,
                    drill: "Why must optimizer state be saved in a training checkpoint?",
                    hint: "The next update depends on more than current parameters.", answer: "Without moments/velocity, resumed training follows a different update trajectory."
                )
            ]
        ),
        "ml-neural-architectures": ModuleCourse(
            prerequisites: ["Tensor & Numerical Foundations lab", "Training Mechanics lab", "Dot products, weighted averages, and tensor shapes"],
            techniques: [
                technique(
                    id: "receptive-field", name: "Sliding receptive field",
                    meaning: "A convolution reuses one small weight grid at every valid spatial location. Each output cell is a dot product between that grid and a local input patch.",
                    math: "Y[i,j] = ΣᵤΣᵥ X[i+u,j+v]K[u,v], with stride/padding determining valid indices.",
                    use: ["Convolution or pooling", "Local spatial patterns", "Weight sharing across positions"],
                    avoid: "Write output dimensions and padding conventions before loops; off-by-one errors otherwise dominate.",
                    invariant: "The current accumulator contains exactly one kernel-weighted input patch for one output coordinate.",
                    template: """
                    def valid_convolution(image, kernel):
                        out_h = len(image) - len(kernel) + 1
                        out_w = len(image[0]) - len(kernel[0]) + 1
                        return [[sum(image[i+u][j+v] * kernel[u][v]
                                    for u in range(len(kernel))
                                    for v in range(len(kernel[0])))
                                 for j in range(out_w)] for i in range(out_h)]
                    """,
                    drill: "A 5×5 image with a 3×3 kernel, stride 1, no padding gives what output shape?",
                    hint: "Each axis has input - kernel + 1 valid starts.", answer: "3×3."
                ),
                technique(
                    id: "attention", name: "Scaled dot-product attention",
                    meaning: "Each query scores every allowed key; softmax turns scores into weights; the weighted average of values becomes the output.",
                    math: "Attention(Q,K,V) = softmax(QKᵀ/√d + mask)V. einsum is useful because it names the axes explicitly.",
                    use: ["Content-dependent mixing across sequence positions", "Transformer attention", "Masks define allowed information flow"],
                    avoid: "Verify mask meaning, softmax axis, scale, and shapes before optimizing or using einsum.",
                    invariant: "For each query and head, allowed attention weights are nonnegative and sum to 1; masked positions receive zero weight.",
                    template: """
                    from einops import einsum

                    def attention_scores(query, key, scale):
                        # batch, query, feature × batch, key, feature
                        return einsum(query, key, 'b q d, b k d -> b q k') / scale
                    """,
                    drill: "For Q shape (b, q, d) and K shape (b, k, d), what shape has QKᵀ?",
                    hint: "Contract only the feature axis d.", answer: "(b, q, k): one score for every query-key pair in each batch."
                )
            ]
        ),
        "ml-research-engineering": ModuleCourse(
            prerequisites: ["Tensor & Numerical Foundations lab", "Probability/statistics and careful denominator definitions", "Heaps and deterministic tie-breaking"],
            techniques: [
                technique(
                    id: "metric-accounting", name: "Metric accounting by semantic unit",
                    meaning: "Accumulate numerators and denominators for the unit the metric actually defines—examples, tokens, classes, or batches—then divide at the correct level.",
                    math: "A weighted mean is Σᵢ nᵢmᵢ / Σᵢ nᵢ, not generally Σᵢmᵢ / number_of_batches.",
                    use: ["Unequal microbatches", "Macro versus micro metrics", "Masks and variable-length sequences"],
                    avoid: "Never average already-averaged numbers until you know their denominators are equal or you retain their weights.",
                    invariant: "Every accumulator's unit and population are explicit and unchanged across updates.",
                    template: """
                    def weighted_mean(batch_means, batch_sizes):
                        total = sum(mean * size for mean, size in zip(batch_means, batch_sizes))
                        count = sum(batch_sizes)
                        return total / count
                    """,
                    drill: "Batches of sizes 2 and 8 have losses 1 and 3. What is the example-weighted mean?",
                    hint: "Weight each mean by its example count.", answer: "(2×1 + 8×3)/10 = 2.6, not the unweighted batch mean 2."
                ),
                technique(
                    id: "ranked-state", name: "Ranked iterative state",
                    meaning: "In beam search or clustering, define exactly what one state contains, how candidates are ranked, how ties break, and when an item stops changing.",
                    math: "A compound ordering key such as (−score, token_sequence) makes selection reproducible under equal scores.",
                    use: ["Beam search", "K-means iterations", "Approximate algorithms with repeated select/update steps"],
                    avoid: "Unspecified ties, empty groups, or stopping rules make results platform-dependent or silently wrong.",
                    invariant: "At each iteration the retained states are exactly the top valid candidates under the declared total ordering and completion policy.",
                    template: """
                    def select_best(candidates, width):
                        # Highest score first; lexicographically smaller sequence wins ties.
                        candidates.sort(key=lambda item: (-item.score, item.sequence))
                        return candidates[:width]
                    """,
                    drill: "Why should a completed beam usually stop expanding?",
                    hint: "Appending tokens would change an already terminal hypothesis.", answer: "Completion is absorbing under the stated search policy; re-expansion invents invalid continuations and distorts ranking."
                )
            ]
        )
    ]
}
