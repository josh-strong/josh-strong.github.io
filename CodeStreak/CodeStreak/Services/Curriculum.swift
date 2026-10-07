import Foundation

enum Curriculum {
    static let modules: [CurriculumModule] = MasteryCurriculum.orderedModules(from: [
        CurriculumModule(
            id: "arrays-hashing",
            title: "Arrays & Hashing",
            symbol: "number.square.fill",
            summary: "Build fast lookups, count values, and trade memory for speed.",
            recognitionCues: ["You need membership or frequency checks", "A nested scan feels too slow", "Order is less important than fast lookup"],
            problems: [sumPositive, pairIndices, sameCharacterCounts, longestConsecutive, productExceptSelf] + ExtendedCurriculum.problems(for: "arrays-hashing") + MasteryCurriculum.problems(for: "arrays-hashing")
        ),
        CurriculumModule(
            id: "two-pointers",
            title: "Two Pointers",
            symbol: "arrow.left.and.right",
            summary: "Move two indices with purpose instead of repeatedly rescanning an array.",
            recognitionCues: ["The input is sorted", "You compare opposite ends", "A pair or compacted sequence is required"],
            problems: [cleanPalindrome, sortedPair, waterContainer, threeSum, trappedWater] + ExtendedCurriculum.problems(for: "two-pointers") + MasteryCurriculum.problems(for: "two-pointers")
        ),
        CurriculumModule(
            id: "sliding-window",
            title: "Sliding Window",
            symbol: "rectangle.and.hand.point.up.left.fill",
            summary: "Maintain just enough state for a moving contiguous range.",
            recognitionCues: ["The answer is a contiguous subarray or substring", "The window grows and sometimes shrinks", "Recomputing every range repeats work"],
            problems: [bestWindowSum, longestUnique, longestReplacement, permutationStarts, minimumCover] + ExtendedCurriculum.problems(for: "sliding-window") + MasteryCurriculum.problems(for: "sliding-window")
        ),
        CurriculumModule(
            id: "stack",
            title: "Stacks",
            symbol: "square.stack.3d.up.fill",
            summary: "Use last-in-first-out state for nesting and unresolved earlier items.",
            recognitionCues: ["Nested pairs must close correctly", "Each item waits for a future answer", "Nearest greater or smaller values matter"],
            problems: [balancedBrackets, removeAdjacentDuplicates, warmerWaits, evaluatePostfix, largestHistogram] + ExtendedCurriculum.problems(for: "stack") + MasteryCurriculum.problems(for: "stack")
        ),
        CurriculumModule(
            id: "binary-search",
            title: "Binary Search",
            symbol: "arrow.up.left.and.arrow.down.right",
            summary: "Discard half of an ordered search space after every decision.",
            recognitionCues: ["The data or answer space is monotonic", "You need a first or minimum feasible value", "A linear scan is the bottleneck"],
            problems: [firstPosition, rotatedMinimum, searchRotated, minimumSpeed, shipCapacity] + ExtendedCurriculum.problems(for: "binary-search") + MasteryCurriculum.problems(for: "binary-search")
        ),
        CurriculumModule(
            id: "intervals",
            title: "Intervals",
            symbol: "timeline.selection",
            summary: "Sort ranges, then reason about overlap using their boundaries.",
            recognitionCues: ["Inputs have start and end points", "Overlaps must merge", "You need simultaneous-event counts"],
            problems: [mergeRanges, insertRange, intervalIntersection, eraseOverlaps, meetingRooms] + ExtendedCurriculum.problems(for: "intervals") + MasteryCurriculum.problems(for: "intervals")
        ),
        CurriculumModule(
            id: "trees",
            title: "Trees",
            symbol: "tree.fill",
            summary: "Apply the same small decision recursively to each subtree.",
            recognitionCues: ["The input has parent-child structure", "A subtree can return a useful summary", "Breadth-first levels matter"],
            problems: [treeDepth, inorderValues, levelAverages, searchTreeAncestor, validSearchTree] + ExtendedCurriculum.problems(for: "trees") + MasteryCurriculum.problems(for: "trees")
        ),
        CurriculumModule(
            id: "graphs",
            title: "Graphs",
            symbol: "point.3.connected.trianglepath.dotted",
            summary: "Explore connected state while marking what you have already visited.",
            recognitionCues: ["Relationships form arbitrary connections", "You need components or reachability", "Cycles can cause repeated work"],
            problems: [islandCount, routeExists, bipartiteGraph, shortestGridPath, canFinishCourses] + ExtendedCurriculum.problems(for: "graphs") + MasteryCurriculum.problems(for: "graphs")
        ),
        CurriculumModule(
            id: "backtracking",
            title: "Backtracking",
            symbol: "arrow.triangle.branch",
            summary: "Choose, explore, and undo to enumerate constrained possibilities.",
            recognitionCues: ["The output contains all valid arrangements", "Each step branches into choices", "Invalid partial choices can be pruned"],
            problems: [allSubsets, permutations, targetCombinations, wordSearch, queensCount] + ExtendedCurriculum.problems(for: "backtracking") + MasteryCurriculum.problems(for: "backtracking")
        ),
        CurriculumModule(
            id: "dynamic-programming",
            title: "Dynamic Programming",
            symbol: "tablecells.fill",
            summary: "Cache answers to overlapping subproblems and build larger answers from them.",
            recognitionCues: ["The same state is solved repeatedly", "The task asks for a best or counted result", "A choice leaves a smaller version of the problem"],
            problems: [climbWays, uniquePaths, maxNonAdjacent, fewestCoins, longestCommonSubsequence] + ExtendedCurriculum.problems(for: "dynamic-programming") + MasteryCurriculum.problems(for: "dynamic-programming")
        ),
        CurriculumModule(
            id: "greedy",
            title: "Greedy Reasoning",
            symbol: "scope",
            summary: "Prove that the best local choice preserves a globally optimal path.",
            recognitionCues: ["One choice dominates alternatives", "Sorting exposes the safest next move", "You only need to preserve feasibility"],
            problems: [canReachEnd, maxMeetings, minimumArrows, partitionLabels, gasStart] + ExtendedCurriculum.problems(for: "greedy") + MasteryCurriculum.problems(for: "greedy")
        ),
        CurriculumModule(
            id: "advanced",
            title: "Advanced Synthesis",
            symbol: "brain.head.profile.fill",
            summary: "Combine patterns and recognize the state representation hidden inside harder tasks.",
            recognitionCues: ["A straightforward solution is quadratic or worse", "Two sequences must be aligned", "A partition condition divides the answer space"],
            problems: [longestIncreasing, wordBreak, editDistance, maximumProductSubarray, medianSorted] + ExtendedCurriculum.problems(for: "advanced") + MasteryCurriculum.problems(for: "advanced")
        )
    ])

    /// The classic pattern curriculum remains one independently unlocked path.
    static let algorithmProblems: [AlgorithmProblem] = modules.flatMap(\.problems)

    /// Research-role exercises unlock in parallel, so a learner can begin them
    /// without first completing every general algorithms problem.
    static let mlInterviewModules = MLInterviewCurriculum.modules
    static let mlInterviewProblems = MLInterviewCurriculum.allProblems
    static let allModules = modules + mlInterviewModules
    static let allProblems: [AlgorithmProblem] = algorithmProblems + mlInterviewProblems

    static func problem(withID id: String) -> AlgorithmProblem? {
        allProblems.first { $0.id == id }
    }

    static func index(of problemID: String) -> Int? {
        allProblems.firstIndex { $0.id == problemID }
    }

    static func module(containing problemID: String) -> CurriculumModule? {
        allModules.first { module in module.problems.contains { $0.id == problemID } }
    }

    /// Returns end-of-module checks only after every earlier problem they rely
    /// on is solved. The caller presents these outside their module card so the
    /// module name cannot give the pattern away.
    static func readyBlindProblems(
        solvedIDs: Set<String>,
        accessibleIDs: Set<String>
    ) -> [AlgorithmProblem] {
        let candidates = modules.flatMap { module in
            module.problems.filter { problem in
                let placement = module.learningPlacement(for: problem.id)
                return placement.mode == .blindAssessment
                    && (accessibleIDs.contains(problem.id) || solvedIDs.contains(problem.id))
                    && placement.recommendedProblemIDs.allSatisfy(solvedIDs.contains)
            }
        }

        return candidates.sorted { first, second in
            let firstSolved = solvedIDs.contains(first.id)
            let secondSolved = solvedIDs.contains(second.id)
            if firstSolved != secondSolved { return !firstSolved }
            return (index(of: first.id) ?? .max) < (index(of: second.id) ?? .max)
        }
    }

    private static func problem(
        id: String,
        title: String,
        difficulty: ProblemDifficulty,
        minutes: Int,
        why: String,
        prompt: String,
        signature: String,
        examples: [ProblemExample],
        constraints: [String],
        hints: [String],
        solution: String,
        explanation: String,
        time: String,
        space: String,
        tests: [AlgorithmTestCase]
    ) -> AlgorithmProblem {
        let pythonSignature = pythonSignatures[id] ?? expandedPythonSignatures[id] ?? signature
        let functionName = String(pythonSignature.prefix { $0 != "(" })
        return AlgorithmProblem(
            id: id,
            title: title,
            difficulty: difficulty,
            estimatedMinutes: minutes,
            whyItMatters: why,
            prompt: prompt,
            examples: examples,
            constraints: constraints,
            functionName: functionName,
            starterCode: "def \(pythonSignature):\n    # Write your solution here.\n    pass\n",
            hints: hints,
            referenceSolution: pythonSolutions[id] ?? expandedPythonSolutions[id] ?? solution,
            solutionExplanation: explanation,
            timeComplexity: time,
            spaceComplexity: space,
            tests: tests
        )
    }

    private static func test(_ name: String, _ arguments: String, _ expected: String) -> AlgorithmTestCase {
        AlgorithmTestCase(name: name, argumentsJSON: arguments, expectedJSON: expected)
    }

    // MARK: Arrays & Hashing

    private static let sumPositive = problem(
        id: "arrays.sum-positive", title: "Positive Total", difficulty: .easy, minutes: 15,
        why: "A clean single pass is the foundation for nearly every later array pattern.",
        prompt: "Return the sum of every value greater than zero. Ignore zero and negative values.",
        signature: "sumPositive(numbers)",
        examples: [.init(input: "[-2, 5, 0, 3]", output: "8")],
        constraints: ["0 ≤ len(numbers) ≤ 100,000", "Every value is an integer"],
        hints: ["Keep one running total.", "Inspect each number exactly once.", "Only add a value when it is greater than zero."],
        solution: """
        function sumPositive(numbers) {
          let total = 0;
          for (const number of numbers) {
            if (number > 0) total += number;
          }
          return total;
        }
        """,
        explanation: "The accumulator is the complete answer for the prefix already visited. Each new positive value extends that invariant.",
        time: "O(n)", space: "O(1)",
        tests: [test("mixed values", "[[-2,5,0,3]]", "8"), test("all negative", "[[-4,-1]]", "0"), test("empty", "[[]]", "0"), test("all positive", "[[1,2,3,4]]", "10")]
    )

    private static let pairIndices = problem(
        id: "arrays.pair-indices", title: "Target Pair", difficulty: .easy, minutes: 25,
        why: "The complement lookup is the archetypal hash-map interview move.",
        prompt: "Return [earlier_index, current_index] for the first pair of different positions whose values sum to target. Scan left to right by current_index and, when more than one earlier position matches, prefer the smallest earlier matching index. A position may not be paired with itself. Return [-1, -1] when no pair exists.",
        signature: "pairIndices(numbers, target)",
        examples: [.init(input: "[4, 7, 2, 9], 11", output: "[0, 1]")],
        constraints: ["2 ≤ numbers.length ≤ 100,000", "Indices are zero-based and must satisfy earlier_index < current_index", "Duplicate values are allowed; exactly one answer is not guaranteed"],
        hints: ["For a value x, the missing partner is target - x.", "Store values you have already seen.", "Check for the complement before storing the current value."],
        solution: """
        function pairIndices(numbers, target) {
          const seen = new Map();
          for (let i = 0; i < numbers.length; i++) {
            const complement = target - numbers[i];
            if (seen.has(complement)) return [seen.get(complement), i];
            if (!seen.has(numbers[i])) seen.set(numbers[i], i);
          }
          return [-1, -1];
        }
        """,
        explanation: "At index i, the map contains exactly the earlier values. A complement hit therefore produces the required earliest-left pair without a nested scan.",
        time: "O(n)", space: "O(n)",
        tests: [
            test("basic pair", "[[4,7,2,9],11]", "[0,1]"),
            test("two duplicate positions form a pair", "[[3,3],6]", "[0,1]"),
            test("same-index match is forbidden before a real pair", "[[5,1,9],10]", "[1,2]"),
            test("lone half-target cannot pair with itself", "[[1,5,8],10]", "[-1,-1]"),
            test("earliest duplicate index is preserved", "[[1,1,4],5]", "[0,2]"),
            test("two zero positions form a pair", "[[0,0,2],0]", "[0,1]"),
            test("first pair discovered wins", "[[1,4,2,3],5]", "[0,1]"),
            test("no pair", "[[1,2,4],8]", "[-1,-1]"),
            test("negative", "[[-3,4,1,7],4]", "[0,3]")
        ]
    )

    private static let longestConsecutive = problem(
        id: "arrays.longest-consecutive", title: "Longest Consecutive-Value Sequence", difficulty: .medium, minutes: 35,
        why: "It teaches how choosing the right starting states turns an apparent sort into linear work.",
        prompt: "Return the number of distinct integer values in the longest sequence x, x + 1, x + 2, … that can be formed from values anywhere in the list. The values do not need to be adjacent or appear in sequence order in the input. Repeated values count only once.",
        signature: "longestConsecutive(numbers)",
        examples: [
            .init(
                input: "[8, 3, 5, 4, 20]",
                output: "3",
                explanation: "The values 3, 4, and 5 are all present, so they form a length-3 numeric sequence. Their input positions and order do not matter."
            ),
            .init(
                input: "[3, 5, 7]",
                output: "1",
                explanation: "These input items are adjacent positions, but no two values differ by 1. Each value therefore forms only a length-1 sequence."
            )
        ],
        constraints: [
            "0 ≤ numbers.length ≤ 100,000",
            "Consecutive describes numeric values that differ by 1, not neighboring list positions",
            "Aim for expected O(n) time"
        ],
        hints: ["Put every value in a Set.", "Only start counting at values whose predecessor is absent.", "Walk forward from each true start until the run ends."],
        solution: """
        function longestConsecutive(numbers) {
          const values = new Set(numbers);
          let best = 0;
          for (const value of values) {
            if (values.has(value - 1)) continue;
            let length = 1;
            while (values.has(value + length)) length++;
            best = Math.max(best, length);
          }
          return best;
        }
        """,
        explanation: "Only the smallest value in a run launches a walk. Although there is a nested while loop, every distinct value belongs to one launched run, so total work is linear on average.",
        time: "O(n) expected", space: "O(n)",
        tests: [
            test("input order does not matter", "[[8,3,5,4,20]]", "3"),
            test("neighboring positions are not enough", "[[3,5,7]]", "1"),
            test("duplicates count once", "[[1,2,2,3]]", "3"),
            test("empty list", "[[]]", "0"),
            test("multiple numeric sequences", "[[10,5,12,3,55,11,4]]", "3")
        ]
    )

    // MARK: Two Pointers

    private static let cleanPalindrome = problem(
        id: "pointers.clean-palindrome", title: "Clean Palindrome", difficulty: .easy, minutes: 20,
        why: "Opposing pointers are ideal when invalid characters can be skipped in place.",
        prompt: "Return true when the letters and digits in text read the same forward and backward, ignoring punctuation, spaces, and letter case.",
        signature: "isCleanPalindrome(text)",
        examples: [.init(input: "\"Never odd, or even!\"", output: "true")],
        constraints: ["text contains ordinary Unicode text", "Treat A-Z and a-z case-insensitively"],
        hints: ["Use one pointer at each end.", "Skip characters that are not ASCII letters or digits.", "Compare lowercase characters, then move both pointers inward."],
        solution: """
        function isCleanPalindrome(text) {
          let left = 0, right = text.length - 1;
          const valid = c => /[a-z0-9]/i.test(c);
          while (left < right) {
            while (left < right && !valid(text[left])) left++;
            while (left < right && !valid(text[right])) right--;
            if (text[left].toLowerCase() !== text[right].toLowerCase()) return false;
            left++; right--;
          }
          return true;
        }
        """,
        explanation: "Everything outside the current pointers has already matched. Skipping irrelevant characters preserves that invariant without allocating a cleaned copy.",
        time: "O(n)", space: "O(1)",
        tests: [test("phrase", "[\"Never odd, or even!\"]", "true"), test("not palindrome", "[\"algorithm\"]", "false"), test("punctuation only", "[\"...\"]", "true"), test("digits", "[\"1a2A1\"]", "true")]
    )

    private static let sortedPair = problem(
        id: "pointers.sorted-pair", title: "Sorted Target Pair", difficulty: .easy, minutes: 20,
        why: "Sorted order lets one comparison determine which pointer can safely move.",
        prompt: "Given ascending numbers, return the zero-based indices [left, right] of two values whose sum is target. If several pairs work, return the pair with the greatest index distance right - left (the widest pair). Return [-1, -1] if no pair exists.",
        signature: "sortedPair(numbers, target)",
        examples: [.init(input: "[1, 3, 4, 8, 10], 11", output: "[0, 4]", explanation: "Both indices [0, 4] (1 + 10) and [1, 3] (3 + 8) work. Return [0, 4] because its index distance 4 is greater than 2.")],
        constraints: ["0 ≤ len(numbers) ≤ 100,000; numbers is sorted ascending and may contain duplicates", "Indices are zero-based and left must be strictly less than right; one position cannot be used twice", "Use constant extra space"],
        hints: ["Start at both ends.", "If the sum is too small, only the left pointer can improve it.", "If the sum is too large, move the right pointer."],
        solution: """
        function sortedPair(numbers, target) {
          let left = 0, right = numbers.length - 1;
          while (left < right) {
            const sum = numbers[left] + numbers[right];
            if (sum === target) return [left, right];
            if (sum < target) left++; else right--;
          }
          return [-1, -1];
        }
        """,
        explanation: "With a sum below target, pairing the same left value with any smaller right value cannot work, so discarding left is safe; the opposite argument handles a large sum.",
        time: "O(n)", space: "O(1)",
        tests: [
            test("widest of two pairs", "[[1,3,4,8,10],11]", "[0,4]"),
            test("middle pair", "[[2,5,7,12],12]", "[1,2]"),
            test("duplicate endpoints are widest", "[[1,1,9,9],10]", "[0,3]"),
            test("two half-target positions form a pair", "[[5,5],10]", "[0,1]"),
            test("pointers must not meet at one half-target", "[[1,5,8],10]", "[-1,-1]"),
            test("one position cannot pair with itself", "[[5],10]", "[-1,-1]"),
            test("empty input", "[[],10]", "[-1,-1]"),
            test("no pair", "[[1,2,3],10]", "[-1,-1]"),
            test("negative", "[[-5,-2,0,4,9],7]", "[1,4]")
        ]
    )

    private static let waterContainer = problem(
        id: "pointers.water-container", title: "Maximum-Area Water Container", difficulty: .medium, minutes: 35,
        why: "This is the classic proof-driven two-pointer elimination pattern.",
        prompt: "Each heights[i] is the height of a vertical line at horizontal position i. Choose two different zero-based indices left < right. Those lines form the container's sides: its width is right - left, its water height is min(heights[left], heights[right]), and its area is (right - left) * min(heights[left], heights[right]). Lines between the chosen sides do not change this calculation. Return the greatest possible area as a number, not the chosen indices.",
        signature: "maxWater(heights)",
        examples: [.init(input: "[1, 7, 2, 5, 4, 7, 3, 6]", output: "36", explanation: "Choose indices 1 and 7. Their width is 7 - 1 = 6, and the shorter height is min(7, 6) = 6, so the area is 6 * 6 = 36. Indices 0 and 7 are farther apart, but their area is only 7 * min(1, 6) = 7.")],
        constraints: ["2 ≤ len(heights) ≤ 100,000", "Every height is nonnegative and adjacent positions are one unit apart", "Choose exactly two different positions; return only the maximum area"],
        hints: ["Area is width times the shorter height.", "Begin with maximum possible width.", "Move the shorter line; moving the taller one cannot improve the limiting height."],
        solution: """
        function maxWater(heights) {
          let left = 0, right = heights.length - 1, best = 0;
          while (left < right) {
            best = Math.max(best, (right - left) * Math.min(heights[left], heights[right]));
            if (heights[left] <= heights[right]) left++; else right--;
          }
          return best;
        }
        """,
        explanation: "Width always shrinks, so only replacing the shorter boundary could compensate with a taller limiting height. The discarded shorter line cannot participate in a better remaining pair.",
        time: "O(n)", space: "O(1)",
        tests: [test("mixed", "[[1,7,2,5,4,7,3,6]]", "36"), test("two", "[[5,5]]", "5"), test("descending", "[[5,4,3,2,1]]", "6"), test("zeros", "[[0,0,0]]", "0")]
    )

    // MARK: Sliding Window

    private static let bestWindowSum = problem(
        id: "window.best-fixed-sum", title: "Best Fixed Window", difficulty: .easy, minutes: 20,
        why: "It introduces removing the outgoing value while adding the incoming one.",
        prompt: "Return the largest sum of exactly width consecutive values. Return null when width < 1 or width > len(numbers).",
        signature: "bestWindowSum(numbers, width)",
        examples: [.init(input: "[2, 1, 5, 1, 3, 2], 3", output: "9")],
        constraints: ["numbers may contain negative values", "1 ≤ width ≤ numbers.length for a valid window"],
        hints: ["Compute the first window once.", "Slide by adding the new right value and subtracting the old left value.", "Track the best sum after each slide."],
        solution: """
        function bestWindowSum(numbers, width) {
          if (width < 1 || width > numbers.length) return null;
          let sum = 0;
          for (let i = 0; i < width; i++) sum += numbers[i];
          let best = sum;
          for (let right = width; right < numbers.length; right++) {
            sum += numbers[right] - numbers[right - width];
            best = Math.max(best, sum);
          }
          return best;
        }
        """,
        explanation: "Adjacent windows share all but two values. Updating those two boundaries makes every new window constant work.",
        time: "O(n)", space: "O(1)",
        tests: [test("basic", "[[2,1,5,1,3,2],3]", "9"), test("negative", "[[-4,-2,-7],2]", "-6"), test("whole array", "[[1,2,3],3]", "6"), test("invalid", "[[1,2],3]", "null")]
    )

    private static let longestUnique = problem(
        id: "window.longest-unique", title: "Longest Unique Span", difficulty: .medium, minutes: 35,
        why: "It is the central variable-size window: expand, detect a violation, then move left just enough.",
        prompt: "Return the length of the longest contiguous substring containing no repeated character.",
        signature: "longestUniqueSpan(text)",
        examples: [.init(input: "\"abcaef\"", output: "5", explanation: "The span bcaef has no repeats.")],
        constraints: ["0 ≤ text.length ≤ 100,000", "Characters are compared exactly"],
        hints: ["Track the most recent index of each character.", "The left boundary never moves backward.", "On a repeat inside the window, jump left past the previous occurrence."],
        solution: """
        function longestUniqueSpan(text) {
          const lastSeen = new Map();
          let left = 0, best = 0;
          for (let right = 0; right < text.length; right++) {
            const previous = lastSeen.get(text[right]);
            if (previous !== undefined && previous >= left) left = previous + 1;
            lastSeen.set(text[right], right);
            best = Math.max(best, right - left + 1);
          }
          return best;
        }
        """,
        explanation: "The current window is always duplicate-free. Last-seen indices let left jump directly to the earliest valid position after a repeated character.",
        time: "O(n)", space: "O(k)",
        tests: [test("repeat", "[\"abcaef\"]", "5"), test("all same", "[\"aaaa\"]", "1"), test("empty", "[\"\"]", "0"), test("overlap", "[\"dvdf\"]", "3")]
    )

    private static let minimumCover = problem(
        id: "window.minimum-cover", title: "Smallest Covering Window", difficulty: .hard, minutes: 55,
        why: "It combines frequency maps with a shrinkable window and precise validity accounting.",
        prompt: "Return the shortest contiguous substring of text containing every character of required with multiplicity. If several valid substrings have the same minimum length, return the one with the smallest start index. Return an empty string when required is empty or no covering substring exists.",
        signature: "minimumCover(text, required)",
        examples: [.init(input: "\"ADOBECODEBANC\", \"ABC\"", output: "\"BANC\"")],
        constraints: ["Character comparison is case-sensitive", "required may contain duplicates"],
        hints: ["Count how many copies of each character are needed.", "Track how many distinct requirements are currently satisfied.", "Once valid, shrink from the left until removing more would break validity."],
        solution: """
        function minimumCover(text, required) {
          if (required.length === 0) return "";
          const need = new Map();
          for (const c of required) need.set(c, (need.get(c) || 0) + 1);
          const have = new Map();
          let formed = 0, left = 0, bestStart = 0, bestLength = Infinity;
          for (let right = 0; right < text.length; right++) {
            const c = text[right];
            have.set(c, (have.get(c) || 0) + 1);
            if (need.has(c) && have.get(c) === need.get(c)) formed++;
            while (formed === need.size) {
              if (right - left + 1 < bestLength) { bestStart = left; bestLength = right - left + 1; }
              const outgoing = text[left++];
              if (need.has(outgoing) && have.get(outgoing) === need.get(outgoing)) formed--;
              have.set(outgoing, have.get(outgoing) - 1);
            }
          }
          return bestLength === Infinity ? "" : text.slice(bestStart, bestStart + bestLength);
        }
        """,
        explanation: "formed counts satisfied character categories rather than every character. That makes window validity O(1) to check while the two boundaries each move at most n times.",
        time: "O(n + m)", space: "O(k)",
        tests: [test("classic", "[\"ADOBECODEBANC\",\"ABC\"]", "\"BANC\""), test("duplicates", "[\"aaab\",\"aab\"]", "\"aab\""), test("equal length chooses earliest", "[\"abxxab\",\"ab\"]", "\"ab\""), test("impossible", "[\"abc\",\"zz\"]", "\"\""), test("empty required", "[\"abc\",\"\"]", "\"\"")]
    )

    // MARK: Stacks

    private static let balancedBrackets = problem(
        id: "stack.balanced-brackets", title: "Balanced Brackets", difficulty: .easy, minutes: 20,
        why: "Nesting is the purest signal for a stack.",
        prompt: "Return true when a string containing only ()[]{} is correctly opened and closed in nested order.",
        signature: "balancedBrackets(text)",
        examples: [.init(input: "\"{[()]}\"", output: "true")],
        constraints: ["text contains only bracket characters", "An empty string is valid"],
        hints: ["Push opening brackets.", "A closing bracket must match the most recent unmatched opener.", "The stack must be empty at the end."],
        solution: """
        function balancedBrackets(text) {
          const match = { ")": "(", "]": "[", "}": "{" };
          const stack = [];
          for (const c of text) {
            if (c === "(" || c === "[" || c === "{") stack.push(c);
            else if (stack.pop() !== match[c]) return false;
          }
          return stack.length === 0;
        }
        """,
        explanation: "The top of the stack is the only opener the next closer may legally match. Any mismatch proves invalidity immediately.",
        time: "O(n)", space: "O(n)",
        tests: [test("nested", "[\"{[()]}\"]", "true"), test("crossed", "[\"([)]\"]", "false"), test("unfinished", "[\"((\"]", "false"), test("empty", "[\"\"]", "true")]
    )

    private static let warmerWaits = problem(
        id: "stack.warmer-waits", title: "Wait for a Warmer Day", difficulty: .medium, minutes: 35,
        why: "A monotonic stack stores unresolved indices until the first useful future value arrives.",
        prompt: "For each daily temperature, return how many days pass until a strictly warmer temperature. Use 0 when none arrives.",
        signature: "warmerWaits(temperatures)",
        examples: [.init(input: "[20, 22, 21, 25]", output: "[1, 2, 1, 0]")],
        constraints: ["0 ≤ temperatures.length ≤ 100,000", "Return one wait value per input"],
        hints: ["Store indices, not just temperatures.", "Keep unresolved indices in decreasing-temperature order.", "A warmer value resolves every smaller index on top of the stack."],
        solution: """
        function warmerWaits(temperatures) {
          const answer = Array(temperatures.length).fill(0);
          const stack = [];
          for (let i = 0; i < temperatures.length; i++) {
            while (stack.length && temperatures[i] > temperatures[stack[stack.length - 1]]) {
              const previous = stack.pop();
              answer[previous] = i - previous;
            }
            stack.push(i);
          }
          return answer;
        }
        """,
        explanation: "Each index is pushed and popped at most once. The decreasing stack guarantees the current warmer day is the first warmer answer for every popped index.",
        time: "O(n)", space: "O(n)",
        tests: [test("mixed", "[[20,22,21,25]]", "[1,2,1,0]"), test("descending", "[[5,4,3]]", "[0,0,0]"), test("ascending", "[[1,2,3]]", "[1,1,0]"), test("duplicates", "[[4,4,5]]", "[2,1,0]")]
    )

    private static let largestHistogram = problem(
        id: "stack.largest-histogram", title: "Largest Histogram Block", difficulty: .hard, minutes: 55,
        why: "It is the full monotonic-stack pattern: delay an answer until a boundary proves it.",
        prompt: "Given unit-width histogram bar heights, return the largest rectangular area formed by consecutive bars.",
        signature: "largestHistogram(heights)",
        examples: [.init(input: "[2, 1, 5, 6, 2, 3]", output: "10")],
        constraints: ["0 ≤ heights.length ≤ 100,000", "Every height is nonnegative"],
        hints: ["Maintain increasing bar heights with their earliest usable start.", "When a shorter bar arrives, it is the right boundary for taller bars.", "Append a conceptual zero-height bar to flush the stack."],
        solution: """
        function largestHistogram(heights) {
          const stack = [];
          let best = 0;
          for (let i = 0; i <= heights.length; i++) {
            const height = i === heights.length ? 0 : heights[i];
            let start = i;
            while (stack.length && stack[stack.length - 1][1] > height) {
              const [index, previousHeight] = stack.pop();
              best = Math.max(best, previousHeight * (i - index));
              start = index;
            }
            stack.push([start, height]);
          }
          return best;
        }
        """,
        explanation: "A stack entry stores the earliest index at which its height can begin. A shorter bar closes every taller rectangle, and its own start inherits the earliest popped boundary.",
        time: "O(n)", space: "O(n)",
        tests: [test("classic", "[[2,1,5,6,2,3]]", "10"), test("flat", "[[3,3,3]]", "9"), test("single", "[[7]]", "7"), test("empty", "[[]]", "0")]
    )

    // MARK: Binary Search

    private static let firstPosition = problem(
        id: "binary.first-position", title: "First Position", difficulty: .easy, minutes: 25,
        why: "Boundary search is more transferable than merely finding any matching item.",
        prompt: "Return the first index of target in an ascending array, or -1 when absent.",
        signature: "firstPosition(numbers, target)",
        examples: [.init(input: "[1, 2, 2, 2, 5], 2", output: "1")],
        constraints: ["numbers is sorted ascending", "Duplicates are allowed"],
        hints: ["A match may still have another match to its left.", "On numbers[mid] >= target, keep the left half including mid.", "After convergence, verify that target is actually present."],
        solution: """
        function firstPosition(numbers, target) {
          let left = 0, right = numbers.length;
          while (left < right) {
            const mid = left + Math.floor((right - left) / 2);
            if (numbers[mid] < target) left = mid + 1; else right = mid;
          }
          return left < numbers.length && numbers[left] === target ? left : -1;
        }
        """,
        explanation: "The half-open interval [left, right) always contains the first possible target position. Values below target permanently move the lower boundary right.",
        time: "O(log n)", space: "O(1)",
        tests: [test("duplicates", "[[1,2,2,2,5],2]", "1"), test("absent", "[[1,3,5],2]", "-1"), test("first", "[[4,4,8],4]", "0"), test("empty", "[[],1]", "-1")]
    )

    private static let rotatedMinimum = problem(
        id: "binary.rotated-minimum", title: "Rotated Minimum", difficulty: .medium, minutes: 35,
        why: "It teaches binary search when only one side—not the whole array—is predictably ordered.",
        prompt: "A strictly increasing array was rotated at an unknown point. Return its minimum value. The input is nonempty and has no duplicates.",
        signature: "rotatedMinimum(numbers)",
        examples: [.init(input: "[6, 7, 1, 2, 3, 4]", output: "1")],
        constraints: ["1 ≤ numbers.length ≤ 100,000", "All values are distinct"],
        hints: ["Compare the middle value with the rightmost value.", "If middle is greater, the minimum is strictly to its right.", "Otherwise the minimum is at middle or to its left."],
        solution: """
        function rotatedMinimum(numbers) {
          let left = 0, right = numbers.length - 1;
          while (left < right) {
            const mid = left + Math.floor((right - left) / 2);
            if (numbers[mid] > numbers[right]) left = mid + 1; else right = mid;
          }
          return numbers[left];
        }
        """,
        explanation: "The rightmost value identifies which side of the rotation contains mid. Each comparison retains the pivot while removing half the candidates.",
        time: "O(log n)", space: "O(1)",
        tests: [test("rotated", "[[6,7,1,2,3,4]]", "1"), test("not rotated", "[[1,2,3]]", "1"), test("two", "[[2,1]]", "1"), test("single", "[[9]]", "9")]
    )

    private static let minimumSpeed = problem(
        id: "binary.minimum-speed", title: "Minimum Eating Speed", difficulty: .medium, minutes: 45,
        why: "Searching a monotonic answer space is one of the most valuable binary-search variants.",
        prompt: "There are piles of items. At integer speed k, one pile takes ceil(pile/k) hours. Return the smallest positive k that finishes all piles within hours.",
        signature: "minimumSpeed(piles, hours)",
        examples: [.init(input: "[3, 6, 7, 11], 8", output: "4")],
        constraints: ["piles is nonempty", "hours ≥ piles.length", "All values are positive integers"],
        hints: ["The answer lies between 1 and the largest pile.", "Feasibility becomes permanently true as speed increases.", "Binary search for the first feasible speed."],
        solution: """
        function minimumSpeed(piles, hours) {
          let left = 1, right = Math.max(...piles);
          while (left < right) {
            const speed = left + Math.floor((right - left) / 2);
            let used = 0;
            for (const pile of piles) used += Math.ceil(pile / speed);
            if (used <= hours) right = speed; else left = speed + 1;
          }
          return left;
        }
        """,
        explanation: "If a speed works, every faster speed works too. That monotonic predicate lets binary search locate the first feasible integer.",
        time: "O(n log m)", space: "O(1)",
        tests: [test("classic", "[[3,6,7,11],8]", "4"), test("ample time", "[[10,10],20]", "1"), test("tight", "[[10,10],2]", "10"), test("single", "[[25],5]", "5")]
    )

    // MARK: Intervals

    private static let mergeRanges = problem(
        id: "intervals.merge-ranges", title: "Merge Busy Ranges", difficulty: .medium, minutes: 35,
        why: "Sorting by start time turns a global overlap problem into one local comparison.",
        prompt: "Merge every overlapping or touching [start, end] range. Return ranges sorted by start.",
        signature: "mergeRanges(ranges)",
        examples: [.init(input: "[[1, 3], [2, 6], [8, 10]]", output: "[[1, 6], [8, 10]]")],
        constraints: ["start ≤ end", "The input may be unsorted"],
        hints: ["Sort by start time first.", "Compare each range only with the last merged range.", "Overlap exists when next.start ≤ last.end."],
        solution: """
        function mergeRanges(ranges) {
          if (!ranges.length) return [];
          const sorted = ranges.map(r => r.slice()).sort((a, b) => a[0] - b[0]);
          const merged = [sorted[0]];
          for (let i = 1; i < sorted.length; i++) {
            const last = merged[merged.length - 1];
            if (sorted[i][0] <= last[1]) last[1] = Math.max(last[1], sorted[i][1]);
            else merged.push(sorted[i]);
          }
          return merged;
        }
        """,
        explanation: "After sorting, a new interval can only overlap the final merged interval. Earlier merged intervals end no later and are already disjoint.",
        time: "O(n log n)", space: "O(n)",
        tests: [test("overlap", "[[[1,3],[2,6],[8,10]]]", "[[1,6],[8,10]]"), test("touch", "[[[1,2],[2,4]]]", "[[1,4]]"), test("contained", "[[[1,9],[3,5]]]", "[[1,9]]"), test("empty", "[[]]", "[]")]
    )

    private static let insertRange = problem(
        id: "intervals.insert-range", title: "Insert Busy Range", difficulty: .medium, minutes: 40,
        why: "It divides interval work into before, overlap, and after phases.",
        prompt: "Sorted non-overlapping ranges receive one new range. Insert and merge it, returning sorted non-overlapping ranges.",
        signature: "insertRange(ranges, incoming)",
        examples: [.init(input: "[[1, 2], [5, 7]], [2, 6]", output: "[[1, 7]]")],
        constraints: ["Existing ranges are sorted and disjoint", "Touching ranges should merge"],
        hints: ["First copy ranges ending before incoming starts.", "Merge every range whose start is at most incoming.end.", "Copy the remaining ranges unchanged."],
        solution: """
        function insertRange(ranges, incoming) {
          const result = [];
          let i = 0, merged = incoming.slice();
          while (i < ranges.length && ranges[i][1] < merged[0]) result.push(ranges[i++].slice());
          while (i < ranges.length && ranges[i][0] <= merged[1]) {
            merged[0] = Math.min(merged[0], ranges[i][0]);
            merged[1] = Math.max(merged[1], ranges[i][1]);
            i++;
          }
          result.push(merged);
          while (i < ranges.length) result.push(ranges[i++].slice());
          return result;
        }
        """,
        explanation: "Sorted disjoint input creates three contiguous regions. Each existing range is inspected once and placed or merged exactly once.",
        time: "O(n)", space: "O(n)",
        tests: [test("bridges", "[[[1,2],[5,7]],[2,6]]", "[[1,7]]"), test("before", "[[[3,5]],[1,2]]", "[[1,2],[3,5]]"), test("after", "[[[1,2]],[4,6]]", "[[1,2],[4,6]]"), test("empty", "[[],[2,3]]", "[[2,3]]")]
    )

    private static let meetingRooms = problem(
        id: "intervals.meeting-rooms", title: "Rooms Required", difficulty: .medium, minutes: 45,
        why: "Separating start and end events makes simultaneous-resource questions mechanical.",
        prompt: "Each [start, end] meeting occupies one room on [start, end). Return the minimum rooms required. A meeting ending at time t frees its room for one starting at t.",
        signature: "roomsRequired(meetings)",
        examples: [.init(input: "[[0, 30], [5, 10], [15, 20]]", output: "2")],
        constraints: ["start < end", "Times are finite numbers"],
        hints: ["Sort all start times and all end times separately.", "A start before the earliest current end needs another room.", "An end at or before a start frees a room first."],
        solution: """
        function roomsRequired(meetings) {
          if (!meetings.length) return 0;
          const starts = meetings.map(m => m[0]).sort((a, b) => a - b);
          const ends = meetings.map(m => m[1]).sort((a, b) => a - b);
          let s = 0, e = 0, active = 0, best = 0;
          while (s < starts.length) {
            if (starts[s] < ends[e]) { active++; best = Math.max(best, active); s++; }
            else { active--; e++; }
          }
          return best;
        }
        """,
        explanation: "The next chronological event is either a start, which consumes a room, or an end at/before it, which releases one. The maximum active count is the answer.",
        time: "O(n log n)", space: "O(n)",
        tests: [test("overlap", "[[[0,30],[5,10],[15,20]]]", "2"), test("touching", "[[[1,3],[3,5]]]", "1"), test("all overlap", "[[[1,5],[2,6],[3,7]]]", "3"), test("empty", "[[]]", "0")]
    )

    // MARK: Trees (level-order arrays use heap indices: children of i are 2i+1 and 2i+2)

    private static let treeDepth = problem(
        id: "trees.maximum-depth", title: "Maximum Tree Depth", difficulty: .easy, minutes: 25,
        why: "It introduces the recursive contract: ask each child for the same smaller answer.",
        prompt: "A binary tree is a level-order array using heap indices; null means no node. Return its maximum node depth. An empty tree has depth 0.",
        signature: "treeDepth(tree)",
        examples: [.init(input: "[3, 9, 20, null, null, 15, 7]", output: "3")],
        constraints: ["Children of index i are 2i+1 and 2i+2", "null nodes have no descendants"],
        hints: ["Define depth(index) for one subtree.", "A missing index or null value contributes 0.", "A real node contributes 1 plus the larger child depth."],
        solution: """
        function treeDepth(tree) {
          function depth(index) {
            if (index >= tree.length || tree[index] === null) return 0;
            return 1 + Math.max(depth(index * 2 + 1), depth(index * 2 + 2));
          }
          return depth(0);
        }
        """,
        explanation: "The recursive function promises the maximum depth below one index. Combining the two child promises with max produces the parent answer.",
        time: "O(n)", space: "O(h)",
        tests: [test("balanced", "[[3,9,20,null,null,15,7]]", "3"), test("single", "[[1]]", "1"), test("empty", "[[]]", "0"), test("left chain", "[[1,2,null,3]]", "3")]
    )

    private static let levelAverages = problem(
        id: "trees.level-averages", title: "Level Averages", difficulty: .medium, minutes: 35,
        why: "Breadth-first search is the natural tool when output is grouped by depth.",
        prompt: "For a heap-indexed level-order binary tree, return the numeric average of values on each nonempty depth from root downward.",
        signature: "levelAverages(tree)",
        examples: [.init(input: "[3, 9, 20, null, null, 15, 7]", output: "[3, 14.5, 11]")],
        constraints: ["Children of index i are 2i+1 and 2i+2", "Every non-null value is numeric"],
        hints: ["Use a queue of valid indices.", "Capture the queue length at the start of each level.", "Consume exactly that many nodes before recording an average."],
        solution: """
        function levelAverages(tree) {
          if (!tree.length || tree[0] === null) return [];
          const queue = [0], result = [];
          let head = 0;
          while (head < queue.length) {
            const count = queue.length - head;
            let sum = 0;
            for (let i = 0; i < count; i++) {
              const index = queue[head++];
              sum += tree[index];
              const left = index * 2 + 1, right = index * 2 + 2;
              if (left < tree.length && tree[left] !== null) queue.push(left);
              if (right < tree.length && tree[right] !== null) queue.push(right);
            }
            result.push(sum / count);
          }
          return result;
        }
        """,
        explanation: "The queue contains nodes in breadth-first order. Freezing its current unread count separates one level from the children appended for the next.",
        time: "O(n)", space: "O(w)",
        tests: [test("three levels", "[[3,9,20,null,null,15,7]]", "[3,14.5,11]"), test("single", "[[8]]", "[8]"), test("empty", "[[]]", "[]"), test("partial", "[[2,4,6,8,null,null,10]]", "[2,5,9]")]
    )

    private static let validSearchTree = problem(
        id: "trees.valid-search-tree", title: "Valid Search Tree", difficulty: .medium, minutes: 40,
        why: "It demonstrates passing constraints down a recursion rather than checking only local relationships.",
        prompt: "Return true when a heap-indexed binary tree obeys strict search-tree ordering: every left descendant is smaller and every right descendant is larger.",
        signature: "validSearchTree(tree)",
        examples: [.init(input: "[5, 3, 8, 2, 4, 7, 9]", output: "true")],
        constraints: ["Duplicate values make the tree invalid", "null represents a missing subtree"],
        hints: ["Checking only a node against its parent is insufficient.", "Pass an allowed lower and upper bound into each subtree.", "A left child inherits the upper bound of its parent value."],
        solution: """
        function validSearchTree(tree) {
          function valid(index, low, high) {
            if (index >= tree.length || tree[index] === null) return true;
            const value = tree[index];
            if (value <= low || value >= high) return false;
            return valid(index * 2 + 1, low, value) && valid(index * 2 + 2, value, high);
          }
          return valid(0, -Infinity, Infinity);
        }
        """,
        explanation: "Each ancestor narrows the legal interval. Carrying the full interval catches deep violations that a parent-only comparison misses.",
        time: "O(n)", space: "O(h)",
        tests: [test("valid", "[[5,3,8,2,4,7,9]]", "true"), test("deep violation", "[[5,3,8,null,null,4,9]]", "false"), test("duplicate", "[[2,2,3]]", "false"), test("empty", "[[]]", "true")]
    )

    // MARK: Graphs

    private static let islandCount = problem(
        id: "graphs.island-count", title: "Island Count", difficulty: .medium, minutes: 40,
        why: "Grid traversal is graph search with implicit neighbors.",
        prompt: "A rectangular grid contains 1 for land and 0 for water. Return the number of four-directionally connected land components. Do not mutate the input.",
        signature: "islandCount(grid)",
        examples: [.init(input: "[[1,1,0],[0,1,0],[1,0,1]]", output: "3")],
        constraints: ["The grid may be empty", "Diagonal cells are not connected"],
        hints: ["Scan every cell.", "Each unvisited land cell begins one new component.", "From that cell, mark all reachable land with DFS or BFS."],
        solution: """
        function islandCount(grid) {
          if (!grid.length) return 0;
          const seen = new Set();
          const key = (r, c) => r + "," + c;
          let count = 0;
          function visit(r, c) {
            if (r < 0 || c < 0 || r >= grid.length || c >= grid[0].length || grid[r][c] !== 1 || seen.has(key(r,c))) return;
            seen.add(key(r,c));
            visit(r+1,c); visit(r-1,c); visit(r,c+1); visit(r,c-1);
          }
          for (let r = 0; r < grid.length; r++) for (let c = 0; c < grid[0].length; c++) {
            if (grid[r][c] === 1 && !seen.has(key(r,c))) { count++; visit(r,c); }
          }
          return count;
        }
        """,
        explanation: "The outer scan finds component seeds; traversal consumes the entire component so it can never be counted again.",
        time: "O(rows × columns)", space: "O(rows × columns)",
        tests: [test("three", "[[[1,1,0],[0,1,0],[1,0,1]]]", "3"), test("all land", "[[[1,1],[1,1]]]", "1"), test("all water", "[[[0,0]]]", "0"), test("empty", "[[]]", "0")]
    )

    private static let routeExists = problem(
        id: "graphs.route-exists", title: "Route Exists", difficulty: .easy, minutes: 30,
        why: "It separates graph representation from a standard reachability traversal.",
        prompt: "Nodes are numbered 0 through nodeCount-1 and edges are undirected pairs. Return whether any route connects start to end.",
        signature: "routeExists(nodeCount, edges, start, end)",
        examples: [.init(input: "5, [[0,1],[1,2],[3,4]], 0, 2", output: "true")],
        constraints: ["All edge endpoints are valid node numbers", "A node is reachable from itself"],
        hints: ["Build an adjacency list.", "Start DFS or BFS from start.", "Mark nodes before adding their neighbors so cycles cannot loop forever."],
        solution: """
        function routeExists(nodeCount, edges, start, end) {
          const graph = Array.from({length: nodeCount}, () => []);
          for (const [a,b] of edges) { graph[a].push(b); graph[b].push(a); }
          const queue = [start], seen = new Set([start]);
          for (let head = 0; head < queue.length; head++) {
            const node = queue[head];
            if (node === end) return true;
            for (const next of graph[node]) if (!seen.has(next)) { seen.add(next); queue.push(next); }
          }
          return false;
        }
        """,
        explanation: "The adjacency list makes neighbors explicit. The visited set guarantees each node enters the queue at most once.",
        time: "O(V + E)", space: "O(V + E)",
        tests: [test("connected", "[5,[[0,1],[1,2],[3,4]],0,2]", "true"), test("separate", "[5,[[0,1],[1,2],[3,4]],0,4]", "false"), test("same", "[3,[],2,2]", "true"), test("cycle", "[3,[[0,1],[1,2],[2,0]],0,2]", "true")]
    )

    private static let canFinishCourses = problem(
        id: "graphs.course-cycle", title: "Finish Every Course", difficulty: .medium, minutes: 45,
        why: "Dependency scheduling is cycle detection in a directed graph.",
        prompt: "Courses are 0..<count. Each pair [course, prerequisite] is a dependency. Return true when every course can be completed.",
        signature: "canFinishCourses(count, prerequisites)",
        examples: [.init(input: "3, [[1,0],[2,1]]", output: "true")],
        constraints: ["All course numbers are valid", "Repeated dependency pairs may appear"],
        hints: ["Track each course's incoming prerequisite count.", "Start with every zero-indegree course.", "If topological processing visits fewer than count nodes, a cycle remains."],
        solution: """
        function canFinishCourses(count, prerequisites) {
          const graph = Array.from({length: count}, () => []);
          const indegree = Array(count).fill(0);
          const unique = new Set();
          for (const [course, pre] of prerequisites) {
            const key = pre + ":" + course;
            if (unique.has(key)) continue;
            unique.add(key); graph[pre].push(course); indegree[course]++;
          }
          const queue = [];
          for (let i = 0; i < count; i++) if (indegree[i] === 0) queue.push(i);
          let visited = 0;
          for (let head = 0; head < queue.length; head++) {
            const course = queue[head]; visited++;
            for (const next of graph[course]) if (--indegree[next] === 0) queue.push(next);
          }
          return visited === count;
        }
        """,
        explanation: "Removing zero-indegree nodes repeatedly is a topological sort. A directed cycle never exposes a zero-indegree member, so an incomplete visit count detects it.",
        time: "O(V + E)", space: "O(V + E)",
        tests: [test("chain", "[3,[[1,0],[2,1]]]", "true"), test("cycle", "[2,[[1,0],[0,1]]]", "false"), test("none", "[4,[]]", "true"), test("duplicate", "[2,[[1,0],[1,0]]]", "true")]
    )

    // MARK: Backtracking

    private static let allSubsets = problem(
        id: "backtracking.all-subsets", title: "All Subsets", difficulty: .medium, minutes: 35,
        why: "Include-or-skip is the simplest complete decision tree.",
        prompt: "Return every subset of distinct numbers in this exact recursive order: explore excluding the current value first, then including it.",
        signature: "allSubsets(numbers)",
        examples: [.init(input: "[1, 2]", output: "[[], [2], [1], [1, 2]]")],
        constraints: ["All numbers are distinct", "0 ≤ numbers.length ≤ 15"],
        hints: ["At each index there are exactly two choices.", "At the end, copy the current path into the result.", "After exploring include, pop the chosen value to restore state."],
        solution: """
        function allSubsets(numbers) {
          const result = [], path = [];
          function search(index) {
            if (index === numbers.length) { result.push(path.slice()); return; }
            search(index + 1);
            path.push(numbers[index]); search(index + 1); path.pop();
          }
          search(0);
          return result;
        }
        """,
        explanation: "Every element contributes one binary decision. Backtracking reuses one path array while copying only at complete leaves.",
        time: "O(n · 2ⁿ)", space: "O(n) excluding output",
        tests: [test("two", "[[1,2]]", "[[],[2],[1],[1,2]]"), test("one", "[[7]]", "[[],[7]]"), test("empty", "[[]]", "[[]]"), test("three", "[[1,2,3]]", "[[],[3],[2],[2,3],[1],[1,3],[1,2],[1,2,3]]")]
    )

    private static let targetCombinations = problem(
        id: "backtracking.target-combinations", title: "Target Combinations", difficulty: .medium, minutes: 45,
        why: "It adds pruning and reusable choices to the backtracking template.",
        prompt: "Distinct positive candidates may be reused. Return all nondecreasing combinations summing to target, ordered by depth-first search over candidates in ascending order.",
        signature: "targetCombinations(candidates, target)",
        examples: [.init(input: "[2, 3, 6, 7], 7", output: "[[2, 2, 3], [7]]")],
        constraints: ["Candidates are distinct positive integers", "Sort candidates before searching"],
        hints: ["Sort so an oversized candidate lets you stop a loop.", "Pass the current candidate index again to allow reuse.", "Move to later indices to avoid permuting the same combination."],
        solution: """
        function targetCombinations(candidates, target) {
          const values = candidates.slice().sort((a,b) => a-b), result = [], path = [];
          function search(start, remaining) {
            if (remaining === 0) { result.push(path.slice()); return; }
            for (let i = start; i < values.length; i++) {
              if (values[i] > remaining) break;
              path.push(values[i]); search(i, remaining - values[i]); path.pop();
            }
          }
          search(0, target);
          return result;
        }
        """,
        explanation: "The start index enforces nondecreasing combinations, so permutations never arise. Positive sorted candidates enable immediate pruning.",
        time: "Exponential in target", space: "O(target / minCandidate)",
        tests: [test("classic", "[[2,3,6,7],7]", "[[2,2,3],[7]]"), test("two ways", "[[2,3,5],8]", "[[2,2,2,2],[2,3,3],[3,5]]"), test("none", "[[4,6],5]", "[]"), test("exact", "[[5],10]", "[[5,5]]")]
    )

    private static let queensCount = problem(
        id: "backtracking.queens-count", title: "Count Queen Layouts", difficulty: .hard, minutes: 55,
        why: "It builds disciplined constraint sets and aggressive pruning into search.",
        prompt: "Return the number of ways to place n queens on an n×n board so no two share a row, column, or diagonal.",
        signature: "queensCount(n)",
        examples: [.init(input: "4", output: "2")],
        constraints: ["1 ≤ n ≤ 10", "Place exactly one queen in each row"],
        hints: ["Process one row at a time.", "Track occupied columns plus row-column and row+column diagonals.", "Add a choice, recurse, then remove it."],
        solution: """
        function queensCount(n) {
          const columns = new Set(), down = new Set(), up = new Set();
          function place(row) {
            if (row === n) return 1;
            let total = 0;
            for (let column = 0; column < n; column++) {
              if (columns.has(column) || down.has(row-column) || up.has(row+column)) continue;
              columns.add(column); down.add(row-column); up.add(row+column);
              total += place(row + 1);
              columns.delete(column); down.delete(row-column); up.delete(row+column);
            }
            return total;
          }
          return place(0);
        }
        """,
        explanation: "One queen per row eliminates row conflicts. Three sets test all remaining constraints in constant time and are restored after each branch.",
        time: "O(n!) upper bound", space: "O(n)",
        tests: [test("one", "[1]", "1"), test("four", "[4]", "2"), test("five", "[5]", "10"), test("six", "[6]", "4")]
    )

    // MARK: Dynamic Programming

    private static let climbWays = problem(
        id: "dp.climb-ways", title: "Ways Up the Stairs", difficulty: .easy, minutes: 25,
        why: "It turns a small recurrence into constant-space iterative dynamic programming.",
        prompt: "Starting below a staircase of n steps, each move climbs 1 or 2 steps. Return the number of distinct move sequences reaching exactly the top. For n=0, return 1.",
        signature: "climbWays(n)",
        examples: [.init(input: "4", output: "5")],
        constraints: ["0 ≤ n ≤ 45", "The answer fits a safe integer"],
        hints: ["A route to step i came from i-1 or i-2.", "The recurrence is ways(i)=ways(i-1)+ways(i-2).", "Only the previous two values are needed."],
        solution: """
        function climbWays(n) {
          let previous = 1, current = 1;
          for (let step = 1; step <= n; step++) {
            const next = previous + current;
            previous = current; current = next;
          }
          return previous;
        }
        """,
        explanation: "The two variables represent consecutive DP states. Advancing one step discards the only state that will never be used again.",
        time: "O(n)", space: "O(1)",
        tests: [test("zero", "[0]", "1"), test("one", "[1]", "1"), test("four", "[4]", "5"), test("ten", "[10]", "89")]
    )

    private static let maxNonAdjacent = problem(
        id: "dp.max-non-adjacent", title: "Best Non-Adjacent Total", difficulty: .medium, minutes: 35,
        why: "Take-or-skip is a core one-dimensional DP decision.",
        prompt: "Return the largest sum obtainable from nonnegative numbers without choosing adjacent positions. Choosing nothing is allowed.",
        signature: "maxNonAdjacent(numbers)",
        examples: [.init(input: "[2, 7, 9, 3, 1]", output: "12")],
        constraints: ["All values are nonnegative", "0 ≤ numbers.length ≤ 100,000"],
        hints: ["At each value, either skip it or take it and skip the previous position.", "Keep the best answer through the previous and previous-previous positions.", "The new best is max(previous, previousPrevious + value)."],
        solution: """
        function maxNonAdjacent(numbers) {
          let twoBack = 0, oneBack = 0;
          for (const value of numbers) {
            const current = Math.max(oneBack, twoBack + value);
            twoBack = oneBack; oneBack = current;
          }
          return oneBack;
        }
        """,
        explanation: "Every optimal prefix solution either excludes its last value or includes it, forcing exclusion of the previous one. Those are exactly the two compared states.",
        time: "O(n)", space: "O(1)",
        tests: [test("classic", "[[2,7,9,3,1]]", "12"), test("empty", "[[]]", "0"), test("two", "[[5,1]]", "5"), test("alternating", "[[10,1,10,1,10]]", "30")]
    )

    private static let fewestCoins = problem(
        id: "dp.fewest-coins", title: "Fewest Coins", difficulty: .medium, minutes: 45,
        why: "It teaches bottom-up state construction and unreachable sentinel values.",
        prompt: "Unlimited positive coin denominations are available. Return the fewest coins needed to make amount exactly, or -1 when impossible.",
        signature: "fewestCoins(coins, amount)",
        examples: [.init(input: "[1, 3, 4], 6", output: "2")],
        constraints: ["amount ≥ 0", "Every coin is a positive integer"],
        hints: ["Let dp[x] be the fewest coins needed for x.", "Initialize dp[0]=0 and all other states as unreachable.", "For each amount, try ending with every coin no larger than it."],
        solution: """
        function fewestCoins(coins, amount) {
          const dp = Array(amount + 1).fill(Infinity);
          dp[0] = 0;
          for (let value = 1; value <= amount; value++) {
            for (const coin of coins) if (coin <= value) dp[value] = Math.min(dp[value], dp[value - coin] + 1);
          }
          return dp[amount] === Infinity ? -1 : dp[amount];
        }
        """,
        explanation: "Every solution for value ends with some coin. Removing that coin exposes an already-solved smaller amount, so bottom-up iteration covers every final choice.",
        time: "O(amount × coins)", space: "O(amount)",
        tests: [test("two coins", "[[1,3,4],6]", "2"), test("impossible", "[[2],3]", "-1"), test("zero", "[[2,5],0]", "0"), test("canonical trap", "[[1,3,4],10]", "3")]
    )

    // MARK: Greedy

    private static let canReachEnd = problem(
        id: "greedy.reach-end", title: "Reach the End", difficulty: .medium, minutes: 30,
        why: "A single farthest-reachable frontier replaces an exponential choice tree.",
        prompt: "At index i, numbers[i] is the maximum forward jump length. Return whether index 0 can reach the final index.",
        signature: "canReachEnd(numbers)",
        examples: [.init(input: "[2, 3, 1, 1, 4]", output: "true")],
        constraints: ["numbers is nonempty", "Every value is nonnegative"],
        hints: ["Track the farthest index reachable so far.", "If the current index is beyond that frontier, it is unreachable.", "Update the frontier with i + numbers[i]."],
        solution: """
        function canReachEnd(numbers) {
          let farthest = 0;
          for (let i = 0; i < numbers.length; i++) {
            if (i > farthest) return false;
            farthest = Math.max(farthest, i + numbers[i]);
            if (farthest >= numbers.length - 1) return true;
          }
          return true;
        }
        """,
        explanation: "Only the union of reachable positions matters, and with forward jumps it is a continuous prefix. The farthest boundary summarizes every earlier choice.",
        time: "O(n)", space: "O(1)",
        tests: [test("reachable", "[[2,3,1,1,4]]", "true"), test("blocked", "[[3,2,1,0,4]]", "false"), test("single", "[[0]]", "true"), test("exact", "[[1,1,0]]", "true")]
    )

    private static let maxMeetings = problem(
        id: "greedy.max-meetings", title: "Maximum Meetings", difficulty: .medium, minutes: 35,
        why: "Earliest finishing time is the canonical greedy exchange argument.",
        prompt: "Choose the largest number of non-overlapping [start, end] meetings for one room. A meeting may start when the previous one ends.",
        signature: "maxMeetings(meetings)",
        examples: [.init(input: "[[1, 4], [2, 3], [3, 5], [5, 7]]", output: "3")],
        constraints: ["start < end", "The input may be unsorted"],
        hints: ["Sort by end time, not start time.", "Always take the next meeting that finishes earliest and remains compatible.", "An earlier finish leaves at least as much room for every future meeting."],
        solution: """
        function maxMeetings(meetings) {
          const sorted = meetings.slice().sort((a,b) => a[1] - b[1] || a[0] - b[0]);
          let count = 0, end = -Infinity;
          for (const meeting of sorted) if (meeting[0] >= end) { count++; end = meeting[1]; }
          return count;
        }
        """,
        explanation: "If an optimal schedule begins with a later-finishing compatible meeting, exchanging it for the earliest-finishing one cannot invalidate any later choice.",
        time: "O(n log n)", space: "O(n)",
        tests: [test("three", "[[[1,4],[2,3],[3,5],[5,7]]]", "3"), test("all overlap", "[[[1,5],[2,6],[3,7]]]", "1"), test("touch", "[[[1,2],[2,3],[3,4]]]", "3"), test("empty", "[[]]", "0")]
    )

    private static let gasStart = problem(
        id: "greedy.gas-start", title: "Complete the Fuel Circuit", difficulty: .medium, minutes: 45,
        why: "It demonstrates eliminating a whole range of impossible starts after one failed prefix.",
        prompt: "At station i you gain gas[i] fuel and spend cost[i] to reach station (i + 1) mod n. Start with an empty tank. Return the starting index that completes one full circuit without the tank becoming negative, or -1 if impossible. Inputs with a solution are guaranteed to have exactly one valid start.",
        signature: "gasStart(gas, cost)",
        examples: [.init(input: "[1, 2, 3, 4, 5], [3, 4, 5, 1, 2]", output: "3")],
        constraints: ["gas and cost have equal nonzero length", "If a solution exists, return the unique valid start"],
        hints: ["A solution is impossible when total gas is below total cost.", "Track fuel since the current candidate start.", "When that fuel becomes negative at i, no station from the candidate through i can be valid; restart at i+1."],
        solution: """
        function gasStart(gas, cost) {
          let total = 0, tank = 0, start = 0;
          for (let i = 0; i < gas.length; i++) {
            const gain = gas[i] - cost[i];
            total += gain; tank += gain;
            if (tank < 0) { start = i + 1; tank = 0; }
          }
          return total >= 0 ? start : -1;
        }
        """,
        explanation: "A negative segment balance means every start inside that segment reaches the same deficit with no more initial fuel. The global balance separately proves whether any circuit is possible.",
        time: "O(n)", space: "O(1)",
        tests: [test("classic", "[[1,2,3,4,5],[3,4,5,1,2]]", "3"), test("impossible", "[[2,3,4],[3,4,3]]", "-1"), test("single", "[[5],[4]]", "0"), test("later", "[[2,0,4],[3,1,1]]", "2")]
    )

    // MARK: Advanced

    private static let longestIncreasing = problem(
        id: "advanced.longest-increasing", title: "Longest Increasing Subsequence", difficulty: .medium, minutes: 50,
        why: "It combines a greedy invariant with binary search for an important O(n log n) upgrade.",
        prompt: "Return the length of the longest strictly increasing subsequence. Chosen values need not be contiguous.",
        signature: "longestIncreasing(numbers)",
        examples: [.init(input: "[10, 9, 2, 5, 3, 7, 101, 18]", output: "4")],
        constraints: ["0 ≤ numbers.length ≤ 100,000", "Aim for O(n log n) time"],
        hints: ["Maintain tails[length-1] as the smallest possible tail for that subsequence length.", "A smaller tail is always at least as useful as a larger one.", "Binary search the first tail greater than or equal to the current number."],
        solution: """
        function longestIncreasing(numbers) {
          const tails = [];
          for (const number of numbers) {
            let left = 0, right = tails.length;
            while (left < right) {
              const mid = left + Math.floor((right - left) / 2);
              if (tails[mid] < number) left = mid + 1; else right = mid;
            }
            tails[left] = number;
          }
          return tails.length;
        }
        """,
        explanation: "tails is not necessarily an actual subsequence, but its length is correct. Replacing a tail with a smaller value preserves length while maximizing future extension opportunities.",
        time: "O(n log n)", space: "O(n)",
        tests: [test("classic", "[[10,9,2,5,3,7,101,18]]", "4"), test("decreasing", "[[5,4,3,2]]", "1"), test("duplicates", "[[2,2,2]]", "1"), test("empty", "[[]]", "0")]
    )

    private static let editDistance = problem(
        id: "advanced.edit-distance", title: "Edit Distance", difficulty: .hard, minutes: 60,
        why: "Two-dimensional DP becomes manageable once each cell has a precise prefix meaning.",
        prompt: "Return the minimum single-character inserts, deletes, or replacements needed to transform source into target.",
        signature: "editDistance(source, target)",
        examples: [.init(input: "\"horse\", \"ros\"", output: "3")],
        constraints: ["Comparison is case-sensitive", "Either string may be empty"],
        hints: ["Let dp[i][j] describe prefixes source[0..<i] and target[0..<j].", "Matching final characters add no operation.", "Otherwise take 1 + min(delete, insert, replace)."],
        solution: """
        function editDistance(source, target) {
          let previous = Array.from({length: target.length + 1}, (_, i) => i);
          for (let i = 1; i <= source.length; i++) {
            const current = [i];
            for (let j = 1; j <= target.length; j++) {
              if (source[i-1] === target[j-1]) current[j] = previous[j-1];
              else current[j] = 1 + Math.min(previous[j], current[j-1], previous[j-1]);
            }
            previous = current;
          }
          return previous[target.length];
        }
        """,
        explanation: "Each prefix pair ends with either matching characters or one final edit. Only the previous DP row is needed because every transition comes from left, above, or diagonal.",
        time: "O(nm)", space: "O(m)",
        tests: [test("horse", "[\"horse\",\"ros\"]", "3"), test("same", "[\"code\",\"code\"]", "0"), test("empty", "[\"\",\"abc\"]", "3"), test("replace", "[\"cat\",\"cut\"]", "1")]
    )

    private static let medianSorted = problem(
        id: "advanced.median-sorted", title: "Median of Two Sorted Arrays", difficulty: .hard, minutes: 65,
        why: "Partition search is a demanding synthesis of invariants, boundaries, and binary search.",
        prompt: "Treat the two ascending arrays as one combined sorted multiset without fully merging them. If the total length is odd, return its middle value. If it is even, return the arithmetic mean of its two middle values. At least one array is nonempty.",
        signature: "medianSorted(a, b)",
        examples: [.init(input: "[1, 3], [2]", output: "2")],
        constraints: ["Both arrays are sorted ascending", "Target O(log(min(n,m))) time"],
        hints: ["Binary search a partition in the shorter array.", "Choose the other partition so the combined left side holds half the values.", "A valid partition has both left boundary values ≤ the opposite right boundary values."],
        solution: """
        function medianSorted(a, b) {
          if (a.length > b.length) return medianSorted(b, a);
          let left = 0, right = a.length;
          const half = Math.floor((a.length + b.length + 1) / 2);
          while (left <= right) {
            const i = Math.floor((left + right) / 2), j = half - i;
            const aLeft = i === 0 ? -Infinity : a[i-1];
            const aRight = i === a.length ? Infinity : a[i];
            const bLeft = j === 0 ? -Infinity : b[j-1];
            const bRight = j === b.length ? Infinity : b[j];
            if (aLeft <= bRight && bLeft <= aRight) {
              if ((a.length + b.length) % 2) return Math.max(aLeft, bLeft);
              return (Math.max(aLeft, bLeft) + Math.min(aRight, bRight)) / 2;
            }
            if (aLeft > bRight) right = i - 1; else left = i + 1;
          }
          return null;
        }
        """,
        explanation: "A valid partition places exactly half the combined values on the left and orders both cross-boundaries. Binary search adjusts the shorter-array partition until those conditions hold.",
        time: "O(log(min(n, m)))", space: "O(1)",
        tests: [test("odd", "[[1,3],[2]]", "2"), test("even", "[[1,2],[3,4]]", "2.5"), test("one empty", "[[],[5,7,9]]", "7"), test("uneven", "[[1,2],[3,4,5,6]]", "3.5")]
    )

    // MARK: Expanded practice set

    private static let sameCharacterCounts = problem(
        id: "arrays.same-character-counts", title: "Same Character Counts", difficulty: .easy, minutes: 20,
        why: "Frequency equality is a reusable hash-map invariant for strings and multisets.",
        prompt: "Return true when first and second contain exactly the same characters with the same multiplicities. Comparison is case-sensitive.",
        signature: "sameCharacterCounts(first, second)",
        examples: [.init(input: "\"listen\", \"silent\"", output: "true")],
        constraints: ["0 ≤ len(first), len(second) ≤ 100,000", "Characters are compared exactly"],
        hints: ["Different lengths can never match.", "Count each character in the first string.", "Decrement while scanning the second; reject a missing or exhausted count."],
        solution: "", explanation: "One frequency table represents the unmatched characters from the first string. Every character in the second must consume one available copy.",
        time: "O(n)", space: "O(k)",
        tests: [test("anagram", "[\"listen\",\"silent\"]", "true"), test("different counts", "[\"abb\",\"aab\"]", "false"), test("empty", "[\"\",\"\"]", "true"), test("case sensitive", "[\"Ab\",\"ab\"]", "false")]
    )

    private static let productExceptSelf = problem(
        id: "arrays.product-except-self", title: "Product Around Each Index", difficulty: .medium, minutes: 35,
        why: "Prefix and suffix summaries remove division and handle zeros naturally.",
        prompt: "Return an array where result[i] is the product of every input value except numbers[i]. Do not use division.",
        signature: "productExceptSelf(numbers)",
        examples: [.init(input: "[1, 2, 3, 4]", output: "[24, 12, 8, 6]")],
        constraints: ["2 ≤ len(numbers) ≤ 100,000", "Products fit in a safe integer", "Do not use division"],
        hints: ["Store the product strictly to the left of every index.", "Walk backward with one running suffix product.", "Multiply the stored prefix by the current suffix before extending the suffix."],
        solution: "", explanation: "The output first stores left products. A reverse pass combines each with the product to its right, using the output array as the only O(n) storage.",
        time: "O(n)", space: "O(1) excluding output",
        tests: [test("positive", "[[1,2,3,4]]", "[24,12,8,6]"), test("one zero", "[[-1,1,0,-3,3]]", "[0,0,9,0,0]"), test("two", "[[2,3]]", "[3,2]"), test("two zeros", "[[0,2,0]]", "[0,0,0]")]
    )

    private static let threeSum = problem(
        id: "pointers.three-sum", title: "Three Values to Zero", difficulty: .medium, minutes: 45,
        why: "Sorting converts a three-way search into fixed choices plus a two-pointer scan.",
        prompt: "Return every unique ascending triplet summing to zero. Return triplets in lexicographic order and include no duplicates.",
        signature: "threeSum(numbers)",
        examples: [.init(input: "[-1, 0, 1, 2, -1, -4]", output: "[[-1, -1, 2], [-1, 0, 1]]")],
        constraints: ["0 ≤ len(numbers) ≤ 3,000", "Each triplet must be ascending"],
        hints: ["Sort the values first.", "Fix one value, then solve a two-value target with opposite pointers.", "Skip repeated fixed values and repeated pointer values after a match."],
        solution: "", explanation: "After sorting, each fixed first value leaves a monotonic pair search. Duplicate skipping makes each value triplet appear exactly once.",
        time: "O(n²)", space: "O(n) for sorting/output",
        tests: [test("classic", "[[-1,0,1,2,-1,-4]]", "[[-1,-1,2],[-1,0,1]]"), test("zeros", "[[0,0,0,0]]", "[[0,0,0]]"), test("none", "[[1,2,-2,-1]]", "[]"), test("several", "[[-2,0,1,1,2]]", "[[-2,0,2],[-2,1,1]]")]
    )

    private static let trappedWater = problem(
        id: "pointers.trapped-water", title: "Trapped Rain Water", difficulty: .hard, minutes: 55,
        why: "It requires recognizing that the smaller boundary alone determines the safe local answer.",
        prompt: "Bar heights have unit width. Return the total water trapped after rain between the bars.",
        signature: "trappedWater(heights)",
        examples: [.init(input: "[0, 1, 0, 2, 1, 0, 1, 3]", output: "5")],
        constraints: ["0 ≤ len(heights) ≤ 100,000", "Every height is nonnegative"],
        hints: ["Water above a position depends on the lower of its best left and right walls.", "Track the maximum wall seen from each end.", "Process the side with the smaller current maximum; the opposite side is already tall enough."],
        solution: "", explanation: "When the left maximum is no greater than the right maximum, the left position's water is fully determined by left_max. The symmetric rule handles the other side.",
        time: "O(n)", space: "O(1)",
        tests: [test("valleys", "[[0,1,0,2,1,0,1,3]]", "5"), test("classic", "[[4,2,0,3,2,5]]", "9"), test("monotonic", "[[1,2,3,4]]", "0"), test("empty", "[[]]", "0")]
    )

    private static let longestReplacement = problem(
        id: "window.longest-replacement", title: "Longest Replaceable Run", difficulty: .medium, minutes: 40,
        why: "A deliberately stale maximum can still maintain the correct sliding-window answer.",
        prompt: "You may replace at most k characters in text. Return the longest substring that can be made entirely one repeated character.",
        signature: "longestReplacement(text, k)",
        examples: [.init(input: "\"AABABBA\", 1", output: "4")],
        constraints: ["0 ≤ len(text) ≤ 100,000", "k ≥ 0", "Comparison is case-sensitive"],
        hints: ["Track character counts inside the window.", "A window needs length - largest_frequency replacements.", "Shrink while that required number exceeds k."],
        solution: "", explanation: "The most frequent character supplies the positions kept unchanged. A nondecreasing max frequency may leave an temporarily oversized window, but never creates a false larger optimum.",
        time: "O(n)", space: "O(kinds)",
        tests: [test("classic", "[\"AABABBA\",1]", "4"), test("two changes", "[\"ABAB\",2]", "4"), test("none", "[\"ABCDE\",0]", "1"), test("empty", "[\"\",3]", "0")]
    )

    private static let permutationStarts = problem(
        id: "window.permutation-starts", title: "Permutation Starts", difficulty: .medium, minutes: 45,
        why: "Fixed-size windows plus frequency equality solve many substring-permutation tasks.",
        prompt: "Return every start index where a substring of text is a permutation of pattern. Indices must be ascending.",
        signature: "permutationStarts(text, pattern)",
        examples: [.init(input: "\"cbaebabacd\", \"abc\"", output: "[0, 6]")],
        constraints: ["pattern is nonempty", "Character comparison is case-sensitive"],
        hints: ["Every candidate window has len(pattern) characters.", "Build the pattern frequency table and a table for the first window.", "Slide by removing one outgoing character and adding one incoming character."],
        solution: "", explanation: "Only windows with the pattern's exact length can qualify. Incremental frequency updates avoid recounting each candidate substring.",
        time: "O(n · k) with map comparison", space: "O(k)",
        tests: [test("two matches", "[\"cbaebabacd\",\"abc\"]", "[0,6]"), test("overlap", "[\"abab\",\"ab\"]", "[0,1,2]"), test("none", "[\"hello\",\"xyz\"]", "[]"), test("pattern longer", "[\"ab\",\"abcd\"]", "[]")]
    )

    private static let removeAdjacentDuplicates = problem(
        id: "stack.remove-adjacent", title: "Remove Adjacent Pairs", difficulty: .easy, minutes: 20,
        why: "A stack captures cascading cancellations that a single neighboring comparison misses.",
        prompt: "Repeatedly remove adjacent equal character pairs until none remain. Return the final string.",
        signature: "removeAdjacentDuplicates(text)",
        examples: [.init(input: "\"abbaca\"", output: "\"ca\"")],
        constraints: ["0 ≤ len(text) ≤ 100,000", "Comparison is case-sensitive"],
        hints: ["The reduced prefix is all you need to remember.", "If the new character matches the stack top, pop it.", "Otherwise push the character."],
        solution: "", explanation: "The stack is always the fully reduced form of the prefix processed so far. A new character can only interact with its top.",
        time: "O(n)", space: "O(n)",
        tests: [test("cascade", "[\"abbaca\"]", "\"ca\""), test("all removed", "[\"azxxzy\"]", "\"ay\""), test("none", "[\"abc\"]", "\"abc\""), test("empty", "[\"\"]", "\"\"")]
    )

    private static let evaluatePostfix = problem(
        id: "stack.evaluate-postfix", title: "Evaluate Postfix", difficulty: .medium, minutes: 35,
        why: "Postfix expressions make operand ordering and stack reduction explicit.",
        prompt: "Evaluate tokens in Reverse Polish notation. Operators are +, -, *, /. Division truncates toward zero.",
        signature: "evaluatePostfix(tokens)",
        examples: [.init(input: "[\"2\", \"1\", \"+\", \"3\", \"*\"]", output: "9")],
        constraints: ["The expression is valid", "Every operator has two operands", "Division by zero does not occur"],
        hints: ["Push numeric tokens.", "For an operator, pop the right operand first and the left operand second.", "Push the computed result back so later operators can use it."],
        solution: "", explanation: "Every completed subexpression collapses to one stack value. Operand pop order matters for subtraction and division.",
        time: "O(n)", space: "O(n)",
        tests: [test("basic", "[[\"2\",\"1\",\"+\",\"3\",\"*\"]]", "9"), test("division", "[[\"4\",\"13\",\"5\",\"/\",\"+\"]]", "6"), test("negative truncation", "[[\"7\",\"-3\",\"/\"]]", "-2"), test("single", "[[\"42\"]]", "42")]
    )

    private static let searchRotated = problem(
        id: "binary.search-rotated", title: "Search Rotated Values", difficulty: .medium, minutes: 40,
        why: "One half remains sorted even when a rotation breaks global order.",
        prompt: "A strictly increasing array was rotated and has no duplicates. Return target's index, or -1 when absent.",
        signature: "searchRotated(numbers, target)",
        examples: [.init(input: "[4, 5, 6, 7, 0, 1, 2], 0", output: "4")],
        constraints: ["All values are distinct", "Target O(log n) time"],
        hints: ["At least one side of middle is sorted.", "Determine whether target lies inside that sorted side's bounds.", "Keep the matching side; otherwise discard it."],
        solution: "", explanation: "The sorted half provides reliable membership bounds. Each step either selects that half or proves target must be in the other half.",
        time: "O(log n)", space: "O(1)",
        tests: [test("found", "[[4,5,6,7,0,1,2],0]", "4"), test("absent", "[[4,5,6,7,0,1,2],3]", "-1"), test("not rotated", "[[1,2,3,4],3]", "2"), test("single", "[[1],0]", "-1")]
    )

    private static let shipCapacity = problem(
        id: "binary.ship-capacity", title: "Smallest Shipping Capacity", difficulty: .medium, minutes: 45,
        why: "It reinforces first-feasible binary search with a greedy feasibility simulation.",
        prompt: "Packages must ship in order. A ship carries a consecutive daily prefix up to its capacity. Return the smallest capacity that ships all weights within days.",
        signature: "shipCapacity(weights, days)",
        examples: [.init(input: "[1, 2, 3, 1, 1], 4", output: "3")],
        constraints: ["weights is nonempty", "Every weight is positive", "1 ≤ days ≤ len(weights)"],
        hints: ["Capacity is at least the heaviest package and at most the total weight.", "Simulate how many days a candidate capacity needs.", "Feasibility is monotonic as capacity increases."],
        solution: "", explanation: "A greedy daily fill minimizes days for a fixed capacity. Since every larger capacity is also feasible, binary search finds the first feasible value.",
        time: "O(n log sum(weights))", space: "O(1)",
        tests: [test("four days", "[[1,2,3,1,1],4]", "3"), test("one day", "[[3,2,2,4,1,4],1]", "16"), test("three days", "[[3,2,2,4,1,4],3]", "6"), test("daily package", "[[5,1,2],3]", "5")]
    )

    private static let intervalIntersection = problem(
        id: "intervals.intersection", title: "Range Intersections", difficulty: .medium, minutes: 35,
        why: "Two ordered interval streams can be merged with the same pointer-elimination logic as sorted arrays.",
        prompt: "Two lists contain sorted, internally disjoint closed ranges. Return every intersection in ascending order.",
        signature: "intervalIntersection(first, second)",
        examples: [.init(input: "[[0,2],[5,10]], [[1,5],[8,12]]", output: "[[1,2],[5,5],[8,10]]")],
        constraints: ["Each input list is sorted and disjoint", "Closed ranges may intersect at one point"],
        hints: ["The overlap begins at the larger start and ends at the smaller end.", "Record it when start ≤ end.", "Advance whichever interval ends first; it cannot overlap any later interval from the other list."],
        solution: "", explanation: "At each pair, the earlier-ending interval has exhausted all possible overlap with the current and future opposite intervals, so advancing it is safe.",
        time: "O(n + m)", space: "O(1) excluding output",
        tests: [test("several", "[[[0,2],[5,10]],[[1,5],[8,12]]]", "[[1,2],[5,5],[8,10]]"), test("none", "[[[1,2]],[[3,4]]]", "[]"), test("contained", "[[[1,10]],[[2,3],[5,6]]]", "[[2,3],[5,6]]"), test("empty", "[[],[[1,2]]]", "[]")]
    )

    private static let eraseOverlaps = problem(
        id: "intervals.erase-overlaps", title: "Remove Overlapping Ranges", difficulty: .medium, minutes: 40,
        why: "It is interval scheduling viewed from the complementary question: what must be removed?",
        prompt: "Return the minimum number of closed-open [start, end) ranges to remove so the remainder do not overlap. Touching ranges are compatible.",
        signature: "eraseOverlaps(ranges)",
        examples: [.init(input: "[[1,2],[2,3],[3,4],[1,3]]", output: "1")],
        constraints: ["start < end", "The input may be unsorted"],
        hints: ["Maximizing kept ranges minimizes removals.", "Sort by end time.", "Keep the earliest-finishing compatible range and count every incompatible one as removed."],
        solution: "", explanation: "The earliest finishing compatible interval leaves maximal room for all later choices. Removed count is total minus this greedy maximum compatible set.",
        time: "O(n log n)", space: "O(n)",
        tests: [test("one removal", "[[[1,2],[2,3],[3,4],[1,3]]]", "1"), test("duplicates", "[[[1,2],[1,2],[1,2]]]", "2"), test("touching", "[[[1,2],[2,3]]]", "0"), test("empty", "[[]]", "0")]
    )

    private static let inorderValues = problem(
        id: "trees.inorder-values", title: "Inorder Values", difficulty: .easy, minutes: 25,
        why: "Traversal order becomes simple when the recursive visit contract is explicit.",
        prompt: "A binary tree is a heap-indexed level-order array with null missing nodes. Return its values in left-root-right inorder.",
        signature: "inorderValues(tree)",
        examples: [.init(input: "[4, 2, 6, 1, 3, 5, 7]", output: "[1, 2, 3, 4, 5, 6, 7]")],
        constraints: ["Children of i are 2i+1 and 2i+2", "null nodes have no descendants"],
        hints: ["Write a visit(index) helper.", "Return immediately for an absent or null index.", "Visit left, append the current value, then visit right."],
        solution: "", explanation: "The recursive call completely emits one subtree. Ordering those calls around the current append directly encodes inorder traversal.",
        time: "O(n)", space: "O(h) excluding output",
        tests: [test("balanced", "[[4,2,6,1,3,5,7]]", "[1,2,3,4,5,6,7]"), test("single", "[[9]]", "[9]"), test("empty", "[[]]", "[]"), test("partial", "[[1,null,2,null,null,3]]", "[1,3,2]")]
    )

    private static let searchTreeAncestor = problem(
        id: "trees.search-tree-ancestor", title: "Search-Tree Common Ancestor", difficulty: .medium, minutes: 35,
        why: "Search-tree ordering can replace general tree path tracking with one directed walk.",
        prompt: "Given a valid heap-indexed binary search tree and two values present in it, return their lowest common ancestor's value.",
        signature: "searchTreeAncestor(tree, first, second)",
        examples: [.init(input: "[6,2,8,0,4,7,9,null,null,3,5], 2, 8", output: "6")],
        constraints: ["The tree is a strict binary search tree", "Both values are present and distinct"],
        hints: ["Order the two target values as low and high.", "If both are smaller than the current node, move left.", "If both are larger, move right; otherwise the current node splits their paths."],
        solution: "", explanation: "The first node whose value lies between the two targets is exactly where their search paths diverge, making it their lowest common ancestor.",
        time: "O(h)", space: "O(1)",
        tests: [test("root", "[[6,2,8,0,4,7,9,null,null,3,5],2,8]", "6"), test("nested", "[[6,2,8,0,4,7,9,null,null,3,5],2,4]", "2"), test("right", "[[6,2,8,0,4,7,9],7,9]", "8"), test("small", "[[2,1,3],1,3]", "2")]
    )

    private static let bipartiteGraph = problem(
        id: "graphs.bipartite", title: "Two-Team Graph", difficulty: .medium, minutes: 40,
        why: "Graph coloring turns a global grouping requirement into local opposite-color constraints.",
        prompt: "An undirected graph is an adjacency list. Return true when nodes can be split into two teams so every edge crosses between teams.",
        signature: "bipartiteGraph(graph)",
        examples: [.init(input: "[[1,3],[0,2],[1,3],[0,2]]", output: "true")],
        constraints: ["Neighbors are valid node indices", "The graph may be disconnected"],
        hints: ["Assign one of two colors during BFS or DFS.", "Every uncolored neighbor receives the opposite color.", "A same-color edge proves impossibility; restart traversal for disconnected components."],
        solution: "", explanation: "Alternating colors along every edge is precisely the two-team constraint. Traversing each component either constructs a valid coloring or finds an odd-cycle contradiction.",
        time: "O(V + E)", space: "O(V)",
        tests: [test("square", "[[[1,3],[0,2],[1,3],[0,2]]]", "true"), test("triangle", "[[[1,2],[0,2],[0,1]]]", "false"), test("disconnected", "[[[1],[0],[]]]", "true"), test("empty", "[[]]", "true")]
    )

    private static let shortestGridPath = problem(
        id: "graphs.shortest-grid-path", title: "Shortest Grid Path", difficulty: .medium, minutes: 45,
        why: "Breadth-first search guarantees the first arrival is shortest in an unweighted graph.",
        prompt: "A rectangular grid uses 0 for open and 1 for blocked. Return the fewest four-directional moves from top-left to bottom-right, or -1 if impossible.",
        signature: "shortestGridPath(grid)",
        examples: [.init(input: "[[0,0,0],[1,1,0],[0,0,0]]", output: "4")],
        constraints: ["The grid is nonempty and rectangular", "The start or end may be blocked"],
        hints: ["Model each open cell as an unweighted graph node.", "BFS explores all positions at distance d before distance d+1.", "Mark a cell when enqueuing it so it enters the queue only once."],
        solution: "", explanation: "Every grid edge costs one move. BFS's layer order makes the first time the destination is removed from the queue its minimum possible distance.",
        time: "O(rows × columns)", space: "O(rows × columns)",
        tests: [test("around wall", "[[[0,0,0],[1,1,0],[0,0,0]]]", "4"), test("blocked", "[[[0,1],[1,0]]]", "-1"), test("single", "[[[0]]]", "0"), test("blocked start", "[[[1,0],[0,0]]]", "-1")]
    )

    private static let permutations = problem(
        id: "backtracking.permutations", title: "All Permutations", difficulty: .medium, minutes: 40,
        why: "It teaches using a choice set and restoring it exactly after each recursive branch.",
        prompt: "Return every permutation of distinct numbers in depth-first order, trying unused input positions from left to right.",
        signature: "permutations(numbers)",
        examples: [.init(input: "[1, 2]", output: "[[1,2],[2,1]]")],
        constraints: ["All values are distinct", "0 ≤ len(numbers) ≤ 8"],
        hints: ["A path is complete when its length equals len(numbers).", "Track which input positions are already used.", "Choose, recurse, then pop and unmark before the next choice."],
        solution: "", explanation: "Each recursion level fills one output position. The used set prevents repeats while backtracking makes every remaining choice available to sibling branches.",
        time: "O(n · n!)", space: "O(n) excluding output",
        tests: [test("two", "[[1,2]]", "[[1,2],[2,1]]"), test("three", "[[1,2,3]]", "[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]"), test("one", "[[7]]", "[[7]]"), test("empty", "[[]]", "[[]]")]
    )

    private static let wordSearch = problem(
        id: "backtracking.word-search", title: "Word Through the Grid", difficulty: .hard, minutes: 55,
        why: "It combines candidate starts, path-local visited state, and early pruning.",
        prompt: "Return true when word can be formed by four-directionally adjacent grid letters without reusing a cell in one path.",
        signature: "wordSearch(board, word)",
        examples: [.init(input: "[[\"A\",\"B\",\"C\"],[\"S\",\"F\",\"C\"],[\"A\",\"D\",\"E\"]], \"ABCCED\"", output: "true")],
        constraints: ["board is rectangular", "word is nonempty", "Do not mutate the returned board state"],
        hints: ["Try every cell as a possible first letter.", "A recursive state needs row, column, and word index.", "Mark a chosen cell for the current path, explore neighbors, then unmark it."],
        solution: "", explanation: "Backtracking explores only paths matching the word prefix. The path set prevents reuse and is restored so the same cell can participate in different candidate paths.",
        time: "O(rows × columns × 4ˡ)", space: "O(l)",
        tests: [test("found", "[[[\"A\",\"B\",\"C\"],[\"S\",\"F\",\"C\"],[\"A\",\"D\",\"E\"]],\"ABCCED\"]", "true"), test("other path", "[[[\"A\",\"B\",\"C\"],[\"S\",\"F\",\"C\"],[\"A\",\"D\",\"E\"]],\"SAD\"]", "true"), test("reuse forbidden", "[[[\"A\",\"B\"],[\"C\",\"D\"]],\"ABA\"]", "false"), test("single", "[[[\"X\"]],\"X\"]", "true")]
    )

    private static let uniquePaths = problem(
        id: "dp.unique-paths", title: "Unique Grid Paths", difficulty: .easy, minutes: 25,
        why: "A two-dimensional recurrence can often collapse to one reusable row.",
        prompt: "A robot starts at the top-left of a rows×columns grid and moves only right or down. Return the number of paths to the bottom-right.",
        signature: "uniquePaths(rows, columns)",
        examples: [.init(input: "3, 7", output: "28")],
        constraints: ["rows ≥ 1", "columns ≥ 1", "The result fits a safe integer"],
        hints: ["Every cell is reached from above or left.", "Initialize the first row to all ones.", "Updating left to right lets dp[column] keep above while dp[column-1] holds left."],
        solution: "", explanation: "The one-row DP stores path counts for the current frontier. Each update combines the unchanged value from above with the newly updated value from the left.",
        time: "O(rows × columns)", space: "O(columns)",
        tests: [test("three by seven", "[3,7]", "28"), test("square", "[3,3]", "6"), test("one row", "[1,8]", "1"), test("two by two", "[2,2]", "2")]
    )

    private static let longestCommonSubsequence = problem(
        id: "dp.longest-common-subsequence", title: "Longest Shared Subsequence", difficulty: .medium, minutes: 50,
        why: "It is the canonical two-sequence DP: match both ends or discard one candidate end.",
        prompt: "Return the length of the longest sequence appearing in both strings in order, not necessarily contiguously.",
        signature: "longestCommonSubsequence(first, second)",
        examples: [.init(input: "\"abcde\", \"ace\"", output: "3")],
        constraints: ["Comparison is case-sensitive", "Either string may be empty"],
        hints: ["Let a state describe prefixes of both strings.", "Matching final characters extend the diagonal state by one.", "Otherwise discard one final character and take the better result."],
        solution: "", explanation: "Every prefix pair either shares its final character in an optimal subsequence or an optimum excludes one of those final characters. Those cases form the recurrence.",
        time: "O(nm)", space: "O(m)",
        tests: [test("subsequence", "[\"abcde\",\"ace\"]", "3"), test("same", "[\"abc\",\"abc\"]", "3"), test("none", "[\"abc\",\"def\"]", "0"), test("empty", "[\"\",\"abc\"]", "0")]
    )

    private static let minimumArrows = problem(
        id: "greedy.minimum-arrows", title: "Minimum Arrows", difficulty: .medium, minutes: 35,
        why: "Choosing the earliest endpoint creates one point that covers the most remaining intervals safely.",
        prompt: "Each closed interval is a balloon's horizontal span. One vertical arrow at x bursts every interval containing x. Return the fewest arrows needed.",
        signature: "minimumArrows(intervals)",
        examples: [.init(input: "[[10,16],[2,8],[1,6],[7,12]]", output: "2")],
        constraints: ["Intervals are nonempty closed ranges", "The input may be unsorted"],
        hints: ["Sort balloons by their right endpoint.", "Shoot the first arrow at the earliest ending balloon's end.", "Only a balloon starting after the current arrow needs a new arrow."],
        solution: "", explanation: "Any solution must hit the earliest-ending balloon. Moving its hitting arrow to that endpoint cannot lose compatibility with a later-starting balloon it previously hit.",
        time: "O(n log n)", space: "O(n)",
        tests: [test("classic", "[[[10,16],[2,8],[1,6],[7,12]]]", "2"), test("separate", "[[[1,2],[3,4],[5,6]]]", "3"), test("touching", "[[[1,2],[2,3]]]", "1"), test("single", "[[[4,9]]]", "1")]
    )

    private static let partitionLabels = problem(
        id: "greedy.partition-labels", title: "Partition Character Labels", difficulty: .medium, minutes: 40,
        why: "Last occurrence positions turn character dependencies into greedily closed intervals.",
        prompt: "Split text into as many parts as possible so every character appears in at most one part. Return part lengths.",
        signature: "partitionLabels(text)",
        examples: [.init(input: "\"ababcbacadefegdehijhklij\"", output: "[9,7,8]")],
        constraints: ["0 ≤ len(text) ≤ 100,000", "Comparison is case-sensitive"],
        hints: ["Record the final index of each character.", "A part cannot end before the farthest last occurrence of any character seen inside it.", "When the current index reaches that boundary, close the part immediately."],
        solution: "", explanation: "The running boundary includes every required future occurrence. Closing at the first index that reaches it maximizes the number of valid parts.",
        time: "O(n)", space: "O(k)",
        tests: [test("classic", "[\"ababcbacadefegdehijhklij\"]", "[9,7,8]"), test("one part", "[\"eccbbbbdec\"]", "[10]"), test("individual", "[\"abc\"]", "[1,1,1]"), test("empty", "[\"\"]", "[]")]
    )

    private static let wordBreak = problem(
        id: "advanced.word-break", title: "Segment Into Known Words", difficulty: .medium, minutes: 45,
        why: "It hides a reachability graph inside string prefix states.",
        prompt: "Return true when text can be segmented into one or more words from dictionary. Words may be reused.",
        signature: "wordBreak(text, dictionary)",
        examples: [.init(input: "\"applepenapple\", [\"apple\",\"pen\"]", output: "true")],
        constraints: ["Dictionary words are nonempty", "Comparison is case-sensitive"],
        hints: ["Let reachable[i] mean text[:i] can be segmented.", "From every reachable index, try each dictionary word.", "Mark the end index when the word matches there."],
        solution: "", explanation: "String indices are graph nodes and matching words are directed edges. The DP marks every node reachable from index zero.",
        time: "O(n × words × word length)", space: "O(n + dictionary)",
        tests: [test("reused", "[\"applepenapple\",[\"apple\",\"pen\"]]", "true"), test("two words", "[\"leetcode\",[\"leet\",\"code\"]]", "true"), test("impossible", "[\"catsandog\",[\"cats\",\"dog\",\"sand\",\"and\",\"cat\"]]", "false"), test("empty", "[\"\",[\"a\"]]", "true")]
    )

    private static let maximumProductSubarray = problem(
        id: "advanced.maximum-product-subarray", title: "Maximum Product Subarray", difficulty: .hard, minutes: 50,
        why: "Negative numbers force every state to retain both its best and worst possibility.",
        prompt: "Return the largest product of a nonempty contiguous subarray.",
        signature: "maximumProductSubarray(numbers)",
        examples: [.init(input: "[2, 3, -2, 4]", output: "6")],
        constraints: ["numbers is nonempty", "Products fit a safe integer"],
        hints: ["A negative value can turn the smallest product into the largest.", "Track both maximum and minimum products ending at the current index.", "Each new state may start fresh or extend either previous extreme."],
        solution: "", explanation: "The product ending at each position has three possible origins. Retaining both extremes is necessary because multiplication by a negative swaps their roles.",
        time: "O(n)", space: "O(1)",
        tests: [test("mixed", "[[2,3,-2,4]]", "6"), test("zero split", "[[-2,0,-1]]", "0"), test("two negatives", "[[-2,3,-4]]", "24"), test("single", "[[-5]]", "-5")]
    )

    // Python is the learner-facing language. The original problem metadata stays independent
    // from the execution engine so the curriculum can be tested without loading the runtime.
    private static let pythonSignatures: [String: String] = [
        "arrays.sum-positive": "sum_positive(numbers)",
        "arrays.pair-indices": "pair_indices(numbers, target)",
        "arrays.longest-consecutive": "longest_consecutive(numbers)",
        "pointers.clean-palindrome": "is_clean_palindrome(text)",
        "pointers.sorted-pair": "sorted_pair(numbers, target)",
        "pointers.water-container": "max_water(heights)",
        "window.best-fixed-sum": "best_window_sum(numbers, width)",
        "window.longest-unique": "longest_unique_span(text)",
        "window.minimum-cover": "minimum_cover(text, required)",
        "stack.balanced-brackets": "balanced_brackets(text)",
        "stack.warmer-waits": "warmer_waits(temperatures)",
        "stack.largest-histogram": "largest_histogram(heights)",
        "binary.first-position": "first_position(numbers, target)",
        "binary.rotated-minimum": "rotated_minimum(numbers)",
        "binary.minimum-speed": "minimum_speed(piles, hours)",
        "intervals.merge-ranges": "merge_ranges(ranges)",
        "intervals.insert-range": "insert_range(ranges, incoming)",
        "intervals.meeting-rooms": "rooms_required(meetings)",
        "trees.maximum-depth": "tree_depth(tree)",
        "trees.level-averages": "level_averages(tree)",
        "trees.valid-search-tree": "valid_search_tree(tree)",
        "graphs.island-count": "island_count(grid)",
        "graphs.route-exists": "route_exists(node_count, edges, start, end)",
        "graphs.course-cycle": "can_finish_courses(count, prerequisites)",
        "backtracking.all-subsets": "all_subsets(numbers)",
        "backtracking.target-combinations": "target_combinations(candidates, target)",
        "backtracking.queens-count": "queens_count(n)",
        "dp.climb-ways": "climb_ways(n)",
        "dp.max-non-adjacent": "max_non_adjacent(numbers)",
        "dp.fewest-coins": "fewest_coins(coins, amount)",
        "greedy.reach-end": "can_reach_end(numbers)",
        "greedy.max-meetings": "max_meetings(meetings)",
        "greedy.gas-start": "gas_start(gas, cost)",
        "advanced.longest-increasing": "longest_increasing(numbers)",
        "advanced.edit-distance": "edit_distance(source, target)",
        "advanced.median-sorted": "median_sorted(a, b)"
    ]

    private static let pythonSolutions: [String: String] = [
        "arrays.sum-positive": """
        def sum_positive(numbers):
            total = 0
            for number in numbers:
                if number > 0:
                    total += number
            return total
        """,
        "arrays.pair-indices": """
        def pair_indices(numbers, target):
            seen = {}  # value -> earliest index strictly before the current one
            for index, number in enumerate(numbers):
                complement = target - number
                # Check before insertion so this position can never match itself.
                if complement in seen:
                    return [seen[complement], index]
                # Preserve the earliest index for the required deterministic tie-break.
                if number not in seen:
                    seen[number] = index
            return [-1, -1]
        """,
        "arrays.longest-consecutive": """
        def longest_consecutive(numbers):
            values = set(numbers)
            best = 0
            for value in values:
                if value - 1 in values:
                    continue
                length = 1
                while value + length in values:
                    length += 1
                best = max(best, length)
            return best
        """,
        "pointers.clean-palindrome": """
        def is_clean_palindrome(text):
            left, right = 0, len(text) - 1
            while left < right:
                while left < right and not text[left].isalnum():
                    left += 1
                while left < right and not text[right].isalnum():
                    right -= 1
                if text[left].lower() != text[right].lower():
                    return False
                left += 1
                right -= 1
            return True
        """,
        "pointers.sorted-pair": """
        def sorted_pair(numbers, target):
            left, right = 0, len(numbers) - 1
            # Strict < means the two pointers always represent different positions.
            while left < right:
                total = numbers[left] + numbers[right]
                if total == target:
                    return [left, right]
                if total < target:
                    left += 1
                else:
                    right -= 1
            return [-1, -1]
        """,
        "pointers.water-container": """
        def max_water(heights):
            left, right, best = 0, len(heights) - 1, 0
            while left < right:
                best = max(best, (right - left) * min(heights[left], heights[right]))
                if heights[left] <= heights[right]:
                    left += 1
                else:
                    right -= 1
            return best
        """,
        "window.best-fixed-sum": """
        def best_window_sum(numbers, width):
            if width < 1 or width > len(numbers):
                return None
            window = sum(numbers[:width])
            best = window
            for right in range(width, len(numbers)):
                window += numbers[right] - numbers[right - width]
                best = max(best, window)
            return best
        """,
        "window.longest-unique": """
        def longest_unique_span(text):
            last_seen = {}
            left = best = 0
            for right, character in enumerate(text):
                if character in last_seen and last_seen[character] >= left:
                    left = last_seen[character] + 1
                last_seen[character] = right
                best = max(best, right - left + 1)
            return best
        """,
        "window.minimum-cover": """
        def minimum_cover(text, required):
            if not required:
                return ""
            need = {}
            for character in required:
                need[character] = need.get(character, 0) + 1
            have = {}
            formed = left = 0
            best_start, best_length = 0, float("inf")
            for right, character in enumerate(text):
                have[character] = have.get(character, 0) + 1
                if character in need and have[character] == need[character]:
                    formed += 1
                while formed == len(need):
                    if right - left + 1 < best_length:
                        best_start, best_length = left, right - left + 1
                    outgoing = text[left]
                    left += 1
                    if outgoing in need and have[outgoing] == need[outgoing]:
                        formed -= 1
                    have[outgoing] -= 1
            if best_length == float("inf"):
                return ""
            return text[best_start:best_start + best_length]
        """,
        "stack.balanced-brackets": """
        def balanced_brackets(text):
            matching = {")": "(", "]": "[", "}": "{"}
            stack = []
            for character in text:
                if character in "([{":
                    stack.append(character)
                elif not stack or stack.pop() != matching[character]:
                    return False
            return len(stack) == 0
        """,
        "stack.warmer-waits": """
        def warmer_waits(temperatures):
            answer = [0] * len(temperatures)
            stack = []
            for index, temperature in enumerate(temperatures):
                while stack and temperature > temperatures[stack[-1]]:
                    previous = stack.pop()
                    answer[previous] = index - previous
                stack.append(index)
            return answer
        """,
        "stack.largest-histogram": """
        def largest_histogram(heights):
            stack = []
            best = 0
            for index in range(len(heights) + 1):
                height = 0 if index == len(heights) else heights[index]
                start = index
                while stack and stack[-1][1] > height:
                    previous_index, previous_height = stack.pop()
                    best = max(best, previous_height * (index - previous_index))
                    start = previous_index
                stack.append([start, height])
            return best
        """,
        "binary.first-position": """
        def first_position(numbers, target):
            left, right = 0, len(numbers)
            while left < right:
                middle = left + (right - left) // 2
                if numbers[middle] < target:
                    left = middle + 1
                else:
                    right = middle
            if left < len(numbers) and numbers[left] == target:
                return left
            return -1
        """,
        "binary.rotated-minimum": """
        def rotated_minimum(numbers):
            left, right = 0, len(numbers) - 1
            while left < right:
                middle = left + (right - left) // 2
                if numbers[middle] > numbers[right]:
                    left = middle + 1
                else:
                    right = middle
            return numbers[left]
        """,
        "binary.minimum-speed": """
        def minimum_speed(piles, hours):
            left, right = 1, max(piles)
            while left < right:
                speed = left + (right - left) // 2
                used = 0
                for pile in piles:
                    used += (pile + speed - 1) // speed
                if used <= hours:
                    right = speed
                else:
                    left = speed + 1
            return left
        """,
        "intervals.merge-ranges": """
        def merge_ranges(ranges):
            if not ranges:
                return []
            ordered = sorted([item[:] for item in ranges])
            merged = [ordered[0]]
            for start, end in ordered[1:]:
                if start <= merged[-1][1]:
                    merged[-1][1] = max(merged[-1][1], end)
                else:
                    merged.append([start, end])
            return merged
        """,
        "intervals.insert-range": """
        def insert_range(ranges, incoming):
            result = []
            index = 0
            merged = incoming[:]
            while index < len(ranges) and ranges[index][1] < merged[0]:
                result.append(ranges[index][:])
                index += 1
            while index < len(ranges) and ranges[index][0] <= merged[1]:
                merged[0] = min(merged[0], ranges[index][0])
                merged[1] = max(merged[1], ranges[index][1])
                index += 1
            result.append(merged)
            while index < len(ranges):
                result.append(ranges[index][:])
                index += 1
            return result
        """,
        "intervals.meeting-rooms": """
        def rooms_required(meetings):
            if not meetings:
                return 0
            starts = sorted(meeting[0] for meeting in meetings)
            ends = sorted(meeting[1] for meeting in meetings)
            start_index = end_index = active = best = 0
            while start_index < len(starts):
                if starts[start_index] < ends[end_index]:
                    active += 1
                    best = max(best, active)
                    start_index += 1
                else:
                    active -= 1
                    end_index += 1
            return best
        """,
        "trees.maximum-depth": """
        def tree_depth(tree):
            def depth(index):
                if index >= len(tree) or tree[index] is None:
                    return 0
                return 1 + max(depth(index * 2 + 1), depth(index * 2 + 2))
            return depth(0)
        """,
        "trees.level-averages": """
        def level_averages(tree):
            if not tree or tree[0] is None:
                return []
            queue = [0]
            head = 0
            result = []
            while head < len(queue):
                count = len(queue) - head
                total = 0
                for _ in range(count):
                    index = queue[head]
                    head += 1
                    total += tree[index]
                    left, right = index * 2 + 1, index * 2 + 2
                    if left < len(tree) and tree[left] is not None:
                        queue.append(left)
                    if right < len(tree) and tree[right] is not None:
                        queue.append(right)
                result.append(total / count)
            return result
        """,
        "trees.valid-search-tree": """
        def valid_search_tree(tree):
            def valid(index, low, high):
                if index >= len(tree) or tree[index] is None:
                    return True
                value = tree[index]
                if value <= low or value >= high:
                    return False
                return valid(index * 2 + 1, low, value) and valid(index * 2 + 2, value, high)
            return valid(0, float("-inf"), float("inf"))
        """,
        "graphs.island-count": """
        def island_count(grid):
            if not grid:
                return 0
            seen = set()
            def visit(row, column):
                if row < 0 or column < 0 or row >= len(grid) or column >= len(grid[0]):
                    return
                if grid[row][column] != 1 or (row, column) in seen:
                    return
                seen.add((row, column))
                visit(row + 1, column)
                visit(row - 1, column)
                visit(row, column + 1)
                visit(row, column - 1)
            count = 0
            for row in range(len(grid)):
                for column in range(len(grid[0])):
                    if grid[row][column] == 1 and (row, column) not in seen:
                        count += 1
                        visit(row, column)
            return count
        """,
        "graphs.route-exists": """
        def route_exists(node_count, edges, start, end):
            graph = [[] for _ in range(node_count)]
            for first, second in edges:
                graph[first].append(second)
                graph[second].append(first)
            queue = [start]
            seen = {start}
            head = 0
            while head < len(queue):
                node = queue[head]
                head += 1
                if node == end:
                    return True
                for neighbor in graph[node]:
                    if neighbor not in seen:
                        seen.add(neighbor)
                        queue.append(neighbor)
            return False
        """,
        "graphs.course-cycle": """
        def can_finish_courses(count, prerequisites):
            graph = [[] for _ in range(count)]
            indegree = [0] * count
            unique = set()
            for course, prerequisite in prerequisites:
                edge = (prerequisite, course)
                if edge in unique:
                    continue
                unique.add(edge)
                graph[prerequisite].append(course)
                indegree[course] += 1
            queue = [course for course in range(count) if indegree[course] == 0]
            head = visited = 0
            while head < len(queue):
                course = queue[head]
                head += 1
                visited += 1
                for next_course in graph[course]:
                    indegree[next_course] -= 1
                    if indegree[next_course] == 0:
                        queue.append(next_course)
            return visited == count
        """,
        "backtracking.all-subsets": """
        def all_subsets(numbers):
            result = []
            path = []
            def search(index):
                if index == len(numbers):
                    result.append(path[:])
                    return
                search(index + 1)
                path.append(numbers[index])
                search(index + 1)
                path.pop()
            search(0)
            return result
        """,
        "backtracking.target-combinations": """
        def target_combinations(candidates, target):
            values = sorted(candidates)
            result = []
            path = []
            def search(start, remaining):
                if remaining == 0:
                    result.append(path[:])
                    return
                for index in range(start, len(values)):
                    value = values[index]
                    if value > remaining:
                        break
                    path.append(value)
                    search(index, remaining - value)
                    path.pop()
            search(0, target)
            return result
        """,
        "backtracking.queens-count": """
        def queens_count(n):
            columns, down, up = set(), set(), set()
            def place(row):
                if row == n:
                    return 1
                total = 0
                for column in range(n):
                    if column in columns or row - column in down or row + column in up:
                        continue
                    columns.add(column)
                    down.add(row - column)
                    up.add(row + column)
                    total += place(row + 1)
                    columns.remove(column)
                    down.remove(row - column)
                    up.remove(row + column)
                return total
            return place(0)
        """,
        "dp.climb-ways": """
        def climb_ways(n):
            two_back, one_back = 1, 1
            for _ in range(n):
                two_back, one_back = one_back, two_back + one_back
            return two_back
        """,
        "dp.max-non-adjacent": """
        def max_non_adjacent(numbers):
            two_back = one_back = 0
            for value in numbers:
                current = max(one_back, two_back + value)
                two_back, one_back = one_back, current
            return one_back
        """,
        "dp.fewest-coins": """
        def fewest_coins(coins, amount):
            dp = [float("inf")] * (amount + 1)
            dp[0] = 0
            for value in range(1, amount + 1):
                for coin in coins:
                    if coin <= value:
                        dp[value] = min(dp[value], dp[value - coin] + 1)
            return -1 if dp[amount] == float("inf") else dp[amount]
        """,
        "greedy.reach-end": """
        def can_reach_end(numbers):
            farthest = 0
            for index, jump in enumerate(numbers):
                if index > farthest:
                    return False
                farthest = max(farthest, index + jump)
                if farthest >= len(numbers) - 1:
                    return True
            return True
        """,
        "greedy.max-meetings": """
        def max_meetings(meetings):
            ordered = sorted(meetings, key=lambda meeting: (meeting[1], meeting[0]))
            count = 0
            end = float("-inf")
            for start, finish in ordered:
                if start >= end:
                    count += 1
                    end = finish
            return count
        """,
        "greedy.gas-start": """
        def gas_start(gas, cost):
            total = tank = start = 0
            for index in range(len(gas)):
                gain = gas[index] - cost[index]
                total += gain
                tank += gain
                if tank < 0:
                    start = index + 1
                    tank = 0
            return start if total >= 0 else -1
        """,
        "advanced.longest-increasing": """
        def longest_increasing(numbers):
            tails = []
            for number in numbers:
                left, right = 0, len(tails)
                while left < right:
                    middle = left + (right - left) // 2
                    if tails[middle] < number:
                        left = middle + 1
                    else:
                        right = middle
                if left == len(tails):
                    tails.append(number)
                else:
                    tails[left] = number
            return len(tails)
        """,
        "advanced.edit-distance": """
        def edit_distance(source, target):
            previous = list(range(len(target) + 1))
            for source_index in range(1, len(source) + 1):
                current = [source_index]
                for target_index in range(1, len(target) + 1):
                    if source[source_index - 1] == target[target_index - 1]:
                        current.append(previous[target_index - 1])
                    else:
                        current.append(1 + min(previous[target_index], current[target_index - 1], previous[target_index - 1]))
                previous = current
            return previous[len(target)]
        """,
        "advanced.median-sorted": """
        def median_sorted(a, b):
            if len(a) > len(b):
                return median_sorted(b, a)
            left, right = 0, len(a)
            half = (len(a) + len(b) + 1) // 2
            while left <= right:
                first_cut = (left + right) // 2
                second_cut = half - first_cut
                a_left = float("-inf") if first_cut == 0 else a[first_cut - 1]
                a_right = float("inf") if first_cut == len(a) else a[first_cut]
                b_left = float("-inf") if second_cut == 0 else b[second_cut - 1]
                b_right = float("inf") if second_cut == len(b) else b[second_cut]
                if a_left <= b_right and b_left <= a_right:
                    if (len(a) + len(b)) % 2 == 1:
                        return max(a_left, b_left)
                    return (max(a_left, b_left) + min(a_right, b_right)) / 2
                if a_left > b_right:
                    right = first_cut - 1
                else:
                    left = first_cut + 1
            return None
        """
    ]

    private static let expandedPythonSignatures: [String: String] = [
        "arrays.same-character-counts": "same_character_counts(first, second)",
        "arrays.product-except-self": "product_except_self(numbers)",
        "pointers.three-sum": "three_sum(numbers)",
        "pointers.trapped-water": "trapped_water(heights)",
        "window.longest-replacement": "longest_replacement(text, k)",
        "window.permutation-starts": "permutation_starts(text, pattern)",
        "stack.remove-adjacent": "remove_adjacent_duplicates(text)",
        "stack.evaluate-postfix": "evaluate_postfix(tokens)",
        "binary.search-rotated": "search_rotated(numbers, target)",
        "binary.ship-capacity": "ship_capacity(weights, days)",
        "intervals.intersection": "interval_intersection(first, second)",
        "intervals.erase-overlaps": "erase_overlaps(ranges)",
        "trees.inorder-values": "inorder_values(tree)",
        "trees.search-tree-ancestor": "search_tree_ancestor(tree, first, second)",
        "graphs.bipartite": "bipartite_graph(graph)",
        "graphs.shortest-grid-path": "shortest_grid_path(grid)",
        "backtracking.permutations": "permutations(numbers)",
        "backtracking.word-search": "word_search(board, word)",
        "dp.unique-paths": "unique_paths(rows, columns)",
        "dp.longest-common-subsequence": "longest_common_subsequence(first, second)",
        "greedy.minimum-arrows": "minimum_arrows(intervals)",
        "greedy.partition-labels": "partition_labels(text)",
        "advanced.word-break": "word_break(text, dictionary)",
        "advanced.maximum-product-subarray": "maximum_product_subarray(numbers)"
    ]

    private static let expandedPythonSolutions: [String: String] = [
        "arrays.same-character-counts": """
        def same_character_counts(first, second):
            if len(first) != len(second):
                return False
            counts = {}
            for character in first:
                counts[character] = counts.get(character, 0) + 1
            for character in second:
                if counts.get(character, 0) == 0:
                    return False
                counts[character] -= 1
            return True
        """,
        "arrays.product-except-self": """
        def product_except_self(numbers):
            result = [1] * len(numbers)
            prefix = 1
            for index in range(len(numbers)):
                result[index] = prefix
                prefix *= numbers[index]
            suffix = 1
            for index in range(len(numbers) - 1, -1, -1):
                result[index] *= suffix
                suffix *= numbers[index]
            return result
        """,
        "pointers.three-sum": """
        def three_sum(numbers):
            values = sorted(numbers)
            result = []
            for index in range(len(values) - 2):
                if index > 0 and values[index] == values[index - 1]:
                    continue
                left, right = index + 1, len(values) - 1
                while left < right:
                    total = values[index] + values[left] + values[right]
                    if total < 0:
                        left += 1
                    elif total > 0:
                        right -= 1
                    else:
                        result.append([values[index], values[left], values[right]])
                        left += 1
                        right -= 1
                        while left < right and values[left] == values[left - 1]:
                            left += 1
                        while left < right and values[right] == values[right + 1]:
                            right -= 1
            return result
        """,
        "pointers.trapped-water": """
        def trapped_water(heights):
            left, right = 0, len(heights) - 1
            left_max = right_max = total = 0
            while left <= right:
                if left_max <= right_max:
                    left_max = max(left_max, heights[left])
                    total += left_max - heights[left]
                    left += 1
                else:
                    right_max = max(right_max, heights[right])
                    total += right_max - heights[right]
                    right -= 1
            return total
        """,
        "window.longest-replacement": """
        def longest_replacement(text, k):
            counts = {}
            left = best = most_frequent = 0
            for right, character in enumerate(text):
                counts[character] = counts.get(character, 0) + 1
                most_frequent = max(most_frequent, counts[character])
                while right - left + 1 - most_frequent > k:
                    counts[text[left]] -= 1
                    left += 1
                best = max(best, right - left + 1)
            return best
        """,
        "window.permutation-starts": """
        def permutation_starts(text, pattern):
            if len(pattern) > len(text):
                return []
            need = {}
            window = {}
            for character in pattern:
                need[character] = need.get(character, 0) + 1
            for character in text[:len(pattern)]:
                window[character] = window.get(character, 0) + 1
            result = []
            if window == need:
                result.append(0)
            for right in range(len(pattern), len(text)):
                outgoing = text[right - len(pattern)]
                window[outgoing] -= 1
                if window[outgoing] == 0:
                    del window[outgoing]
                incoming = text[right]
                window[incoming] = window.get(incoming, 0) + 1
                if window == need:
                    result.append(right - len(pattern) + 1)
            return result
        """,
        "stack.remove-adjacent": """
        def remove_adjacent_duplicates(text):
            stack = []
            for character in text:
                if stack and stack[-1] == character:
                    stack.pop()
                else:
                    stack.append(character)
            return "".join(stack)
        """,
        "stack.evaluate-postfix": """
        def evaluate_postfix(tokens):
            stack = []
            for token in tokens:
                if token not in ["+", "-", "*", "/"]:
                    stack.append(int(token))
                    continue
                right = stack.pop()
                left = stack.pop()
                if token == "+":
                    stack.append(left + right)
                elif token == "-":
                    stack.append(left - right)
                elif token == "*":
                    stack.append(left * right)
                else:
                    stack.append(int(left / right))
            return stack[-1]
        """,
        "binary.search-rotated": """
        def search_rotated(numbers, target):
            left, right = 0, len(numbers) - 1
            while left <= right:
                middle = left + (right - left) // 2
                if numbers[middle] == target:
                    return middle
                if numbers[left] <= numbers[middle]:
                    if numbers[left] <= target < numbers[middle]:
                        right = middle - 1
                    else:
                        left = middle + 1
                else:
                    if numbers[middle] < target <= numbers[right]:
                        left = middle + 1
                    else:
                        right = middle - 1
            return -1
        """,
        "binary.ship-capacity": """
        def ship_capacity(weights, days):
            left, right = max(weights), sum(weights)
            while left < right:
                capacity = left + (right - left) // 2
                used_days = 1
                load = 0
                for weight in weights:
                    if load + weight > capacity:
                        used_days += 1
                        load = 0
                    load += weight
                if used_days <= days:
                    right = capacity
                else:
                    left = capacity + 1
            return left
        """,
        "intervals.intersection": """
        def interval_intersection(first, second):
            first_index = second_index = 0
            result = []
            while first_index < len(first) and second_index < len(second):
                start = max(first[first_index][0], second[second_index][0])
                end = min(first[first_index][1], second[second_index][1])
                if start <= end:
                    result.append([start, end])
                if first[first_index][1] < second[second_index][1]:
                    first_index += 1
                else:
                    second_index += 1
            return result
        """,
        "intervals.erase-overlaps": """
        def erase_overlaps(ranges):
            ordered = sorted(ranges, key=lambda item: item[1])
            removed = 0
            end = float("-inf")
            for start, finish in ordered:
                if start >= end:
                    end = finish
                else:
                    removed += 1
            return removed
        """,
        "trees.inorder-values": """
        def inorder_values(tree):
            result = []
            def visit(index):
                if index >= len(tree) or tree[index] is None:
                    return
                visit(index * 2 + 1)
                result.append(tree[index])
                visit(index * 2 + 2)
            visit(0)
            return result
        """,
        "trees.search-tree-ancestor": """
        def search_tree_ancestor(tree, first, second):
            low, high = min(first, second), max(first, second)
            index = 0
            while index < len(tree) and tree[index] is not None:
                value = tree[index]
                if high < value:
                    index = index * 2 + 1
                elif low > value:
                    index = index * 2 + 2
                else:
                    return value
            return None
        """,
        "graphs.bipartite": """
        def bipartite_graph(graph):
            colors = [0] * len(graph)
            for start in range(len(graph)):
                if colors[start] != 0:
                    continue
                colors[start] = 1
                queue = [start]
                head = 0
                while head < len(queue):
                    node = queue[head]
                    head += 1
                    for neighbor in graph[node]:
                        if colors[neighbor] == 0:
                            colors[neighbor] = -colors[node]
                            queue.append(neighbor)
                        elif colors[neighbor] == colors[node]:
                            return False
            return True
        """,
        "graphs.shortest-grid-path": """
        def shortest_grid_path(grid):
            rows, columns = len(grid), len(grid[0])
            if grid[0][0] == 1 or grid[rows - 1][columns - 1] == 1:
                return -1
            queue = [[0, 0, 0]]
            seen = {(0, 0)}
            head = 0
            while head < len(queue):
                row, column, distance = queue[head]
                head += 1
                if row == rows - 1 and column == columns - 1:
                    return distance
                for row_step, column_step in [[1,0],[-1,0],[0,1],[0,-1]]:
                    next_row, next_column = row + row_step, column + column_step
                    if 0 <= next_row < rows and 0 <= next_column < columns:
                        if grid[next_row][next_column] == 0 and (next_row, next_column) not in seen:
                            seen.add((next_row, next_column))
                            queue.append([next_row, next_column, distance + 1])
            return -1
        """,
        "backtracking.permutations": """
        def permutations(numbers):
            result = []
            path = []
            used = set()
            def search():
                if len(path) == len(numbers):
                    result.append(path[:])
                    return
                for index in range(len(numbers)):
                    if index in used:
                        continue
                    used.add(index)
                    path.append(numbers[index])
                    search()
                    path.pop()
                    used.remove(index)
            search()
            return result
        """,
        "backtracking.word-search": """
        def word_search(board, word):
            rows, columns = len(board), len(board[0])
            path = set()
            def search(row, column, index):
                if index == len(word):
                    return True
                if row < 0 or column < 0 or row >= rows or column >= columns:
                    return False
                if board[row][column] != word[index] or (row, column) in path:
                    return False
                path.add((row, column))
                found = (search(row + 1, column, index + 1) or
                         search(row - 1, column, index + 1) or
                         search(row, column + 1, index + 1) or
                         search(row, column - 1, index + 1))
                path.remove((row, column))
                return found
            for row in range(rows):
                for column in range(columns):
                    if search(row, column, 0):
                        return True
            return False
        """,
        "dp.unique-paths": """
        def unique_paths(rows, columns):
            paths = [1] * columns
            for _ in range(1, rows):
                for column in range(1, columns):
                    paths[column] += paths[column - 1]
            return paths[-1]
        """,
        "dp.longest-common-subsequence": """
        def longest_common_subsequence(first, second):
            previous = [0] * (len(second) + 1)
            for first_character in first:
                current = [0]
                for second_index in range(1, len(second) + 1):
                    if first_character == second[second_index - 1]:
                        current.append(previous[second_index - 1] + 1)
                    else:
                        current.append(max(previous[second_index], current[second_index - 1]))
                previous = current
            return previous[-1]
        """,
        "greedy.minimum-arrows": """
        def minimum_arrows(intervals):
            ordered = sorted(intervals, key=lambda item: item[1])
            arrows = 0
            arrow_position = float("-inf")
            for start, end in ordered:
                if start > arrow_position:
                    arrows += 1
                    arrow_position = end
            return arrows
        """,
        "greedy.partition-labels": """
        def partition_labels(text):
            last = {}
            for index, character in enumerate(text):
                last[character] = index
            result = []
            start = end = 0
            for index, character in enumerate(text):
                end = max(end, last[character])
                if index == end:
                    result.append(end - start + 1)
                    start = index + 1
            return result
        """,
        "advanced.word-break": """
        def word_break(text, dictionary):
            reachable = [False] * (len(text) + 1)
            reachable[0] = True
            for index in range(len(text) + 1):
                if not reachable[index]:
                    continue
                for word in dictionary:
                    end = index + len(word)
                    if end <= len(text) and text[index:end] == word:
                        reachable[end] = True
            return reachable[len(text)]
        """,
        "advanced.maximum-product-subarray": """
        def maximum_product_subarray(numbers):
            current_max = current_min = best = numbers[0]
            for number in numbers[1:]:
                candidates = [number, current_max * number, current_min * number]
                current_max = max(candidates)
                current_min = min(candidates)
                best = max(best, current_max)
            return best
        """
    ]
}
