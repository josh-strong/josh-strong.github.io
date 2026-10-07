import Foundation

enum ExtendedCurriculum {
    static func problems(for moduleID: String) -> [AlgorithmProblem] {
        switch moduleID {
        case "arrays-hashing": arraysAndHashing
        case "two-pointers": twoPointers
        case "sliding-window": slidingWindow
        case "stack": stacks
        case "binary-search": binarySearch
        case "intervals": intervals
        case "trees": trees
        case "graphs": graphs
        case "backtracking": backtracking
        case "dynamic-programming": dynamicProgramming
        case "greedy": greedy
        case "advanced": advanced
        default: []
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
        exampleInput: String,
        exampleOutput: String,
        constraints: [String],
        hints: [String],
        solution: String,
        explanation: String,
        time: String,
        space: String,
        tests: [(String, String, String)]
    ) -> AlgorithmProblem {
        let functionName = String(signature.prefix { $0 != "(" })
        return AlgorithmProblem(
            id: id,
            title: title,
            difficulty: difficulty,
            estimatedMinutes: minutes,
            whyItMatters: why,
            prompt: prompt,
            examples: [.init(input: exampleInput, output: exampleOutput)],
            constraints: constraints,
            functionName: functionName,
            starterCode: "def \(signature):\n    # Write your solution here.\n    pass\n",
            hints: hints,
            referenceSolution: solution,
            solutionExplanation: explanation,
            timeComplexity: time,
            spaceComplexity: space,
            tests: tests.map { AlgorithmTestCase(name: $0.0, argumentsJSON: $0.1, expectedJSON: $0.2) }
        )
    }

    // MARK: Arrays & Hashing

    private static let arraysAndHashing = [
        problem(
            id: "arrays.has-duplicate", title: "Detect a Duplicate", difficulty: .easy, minutes: 15,
            why: "It turns a repeated comparison into a one-pass membership check.",
            prompt: "Return true when any integer appears more than once; otherwise return false.",
            signature: "has_duplicate(numbers)", exampleInput: "[4, 2, 7, 4]", exampleOutput: "true",
            constraints: ["0 ≤ len(numbers) ≤ 100,000", "Values may be negative"],
            hints: ["Remember values already visited.", "A set answers membership in expected constant time.", "Return immediately when the current value is already in the set."],
            solution: """
            def has_duplicate(numbers):
                seen = set()
                for number in numbers:
                    if number in seen:
                        return True
                    seen.add(number)
                return False
            """,
            explanation: "The set contains exactly the values in the processed prefix. Encountering a member again proves a duplicate immediately.",
            time: "O(n) expected", space: "O(n)",
            tests: [("duplicate", "[[4,2,7,4]]", "true"), ("unique", "[[1,2,3]]", "false"), ("empty", "[[]]", "false"), ("adjacent", "[[-1,-1]]", "true")]
        ),
        problem(
            id: "arrays.group-anagrams", title: "Group Rearranged Words", difficulty: .medium, minutes: 35,
            why: "Canonical keys let complex objects share one hash-map bucket.",
            prompt: "Group words that contain the same letters with the same counts. Preserve the first-seen group order and the input order inside each group.",
            signature: "group_anagrams(words)", exampleInput: "[\"eat\", \"tea\", \"tan\", \"ate\"]", exampleOutput: "[[\"eat\", \"tea\", \"ate\"], [\"tan\"]]",
            constraints: ["Words contain lowercase a-z", "0 ≤ len(words) ≤ 20,000"],
            hints: ["Every anagram needs the same canonical representation.", "A sorted word is a simple reliable key.", "Create a group only the first time its key appears."],
            solution: """
            def group_anagrams(words):
                groups = {}
                order = []
                for word in words:
                    key = "".join(sorted(word))
                    if key not in groups:
                        groups[key] = []
                        order.append(key)
                    groups[key].append(word)
                return [groups[key] for key in order]
            """,
            explanation: "Sorting removes the original letter order while preserving multiplicity. Equal keys therefore identify exactly one anagram group.",
            time: "O(n · k log k)", space: "O(n · k)",
            tests: [("mixed", "[[\"eat\",\"tea\",\"tan\",\"ate\"]]", "[[\"eat\",\"tea\",\"ate\"],[\"tan\"]]"), ("single", "[[\"abc\"]]", "[[\"abc\"]]"), ("empty words", "[[\"\",\"\"]]", "[[\"\",\"\"]]"), ("no matches", "[[\"a\",\"b\",\"c\"]]", "[[\"a\"],[\"b\"],[\"c\"]]")]
        ),
        problem(
            id: "arrays.top-frequent", title: "Most Frequent Values", difficulty: .medium, minutes: 35,
            why: "Frequency tables plus deliberate tie-breaking appear throughout interview problems.",
            prompt: "Return the k most frequent distinct values, ordered by decreasing frequency and then increasing numeric value.",
            signature: "top_frequent(numbers, k)", exampleInput: "[1, 1, 1, 2, 2, 3], 2", exampleOutput: "[1, 2]",
            constraints: ["1 ≤ k ≤ number of distinct values", "0 ≤ len(numbers) ≤ 100,000"],
            hints: ["Count every distinct value first.", "Sort pairs rather than the original array.", "Use (-frequency, value) as the ordering key."],
            solution: """
            def top_frequent(numbers, k):
                counts = {}
                for number in numbers:
                    counts[number] = counts.get(number, 0) + 1
                ordered = sorted(counts, key=lambda value: (-counts[value], value))
                return ordered[:k]
            """,
            explanation: "Counting separates frequency from position. The compound sort key makes both priority rules explicit and deterministic.",
            time: "O(n + m log m)", space: "O(m)",
            tests: [("classic", "[[1,1,1,2,2,3],2]", "[1,2]"), ("tie", "[[4,4,2,2,9],2]", "[2,4]"), ("one", "[[7,7,8],1]", "[7]"), ("all", "[[3,1,2],3]", "[1,2,3]")]
        ),
        problem(
            id: "arrays.longest-target-sum", title: "Longest Target-Sum Span", difficulty: .medium, minutes: 45,
            why: "Prefix sums turn any subarray sum into a difference between two checkpoints.",
            prompt: "Return the maximum length of a contiguous subarray whose values sum exactly to target. Return 0 when none exists.",
            signature: "longest_target_sum(numbers, target)", exampleInput: "[1, -1, 5, -2, 3], 3", exampleOutput: "4",
            constraints: ["Values may be positive, zero, or negative", "0 ≤ len(numbers) ≤ 100,000"],
            hints: ["Track the running prefix sum.", "A span ending now sums to target when an earlier prefix equals current - target.", "Store only the earliest index for each prefix sum to maximize length."],
            solution: """
            def longest_target_sum(numbers, target):
                first_index = {0: -1}
                prefix = 0
                best = 0
                for index, number in enumerate(numbers):
                    prefix += number
                    needed = prefix - target
                    if needed in first_index:
                        best = max(best, index - first_index[needed])
                    if prefix not in first_index:
                        first_index[prefix] = index
                return best
            """,
            explanation: "Subtracting an earlier prefix removes everything before the desired span. Keeping its earliest occurrence gives the longest possible ending at each index.",
            time: "O(n) expected", space: "O(n)",
            tests: [("mixed", "[[1,-1,5,-2,3],3]", "4"), ("negatives", "[[-2,-1,2,1],1]", "2"), ("none", "[[1,2,3],9]", "0"), ("whole", "[[2,-2,2,-2],0]", "4")]
        )
    ]

    // MARK: Two Pointers

    private static let twoPointers = [
        problem(
            id: "pointers.move-zeros", title: "Move Zeros Right", difficulty: .easy, minutes: 20,
            why: "A write pointer compacts useful values without repeated deletion or shifting.",
            prompt: "Return a new array with all nonzero values in their original order followed by every zero.",
            signature: "move_zeros(numbers)", exampleInput: "[0, 1, 0, 3, 12]", exampleOutput: "[1, 3, 12, 0, 0]",
            constraints: ["0 ≤ len(numbers) ≤ 100,000", "Preserve nonzero order"],
            hints: ["One pointer reads every value.", "A second pointer marks where the next nonzero belongs.", "After copying nonzeros, fill the remaining positions with zero."],
            solution: """
            def move_zeros(numbers):
                result = [0] * len(numbers)
                write = 0
                for number in numbers:
                    if number != 0:
                        result[write] = number
                        write += 1
                return result
            """,
            explanation: "The prefix before write is always the stable sequence of nonzero values seen so far. Unwritten positions remain zero.",
            time: "O(n)", space: "O(n) output",
            tests: [("mixed", "[[0,1,0,3,12]]", "[1,3,12,0,0]"), ("none", "[[1,2]]", "[1,2]"), ("all", "[[0,0]]", "[0,0]"), ("empty", "[[]]", "[]")]
        ),
        problem(
            id: "pointers.sorted-squares", title: "Sorted Squares", difficulty: .easy, minutes: 25,
            why: "Opposite ends reveal the next largest magnitude even when negatives are present.",
            prompt: "Given ascending integers, return their squares in ascending order.",
            signature: "sorted_squares(numbers)", exampleInput: "[-4, -1, 0, 3, 10]", exampleOutput: "[0, 1, 9, 16, 100]",
            constraints: ["numbers is sorted ascending", "0 ≤ len(numbers) ≤ 100,000"],
            hints: ["The largest square comes from one of the two ends.", "Compare absolute values at left and right.", "Fill the result backward from its largest position."],
            solution: """
            def sorted_squares(numbers):
                result = [0] * len(numbers)
                left, right = 0, len(numbers) - 1
                for write in range(len(numbers) - 1, -1, -1):
                    if abs(numbers[left]) > abs(numbers[right]):
                        result[write] = numbers[left] * numbers[left]
                        left += 1
                    else:
                        result[write] = numbers[right] * numbers[right]
                        right -= 1
                return result
            """,
            explanation: "All remaining values lie between the pointers, so the greatest remaining magnitude must be at an end. Filling backward preserves sorted output.",
            time: "O(n)", space: "O(n) output",
            tests: [("mixed", "[[-4,-1,0,3,10]]", "[0,1,9,16,100]"), ("negative", "[[-3,-2,-1]]", "[1,4,9]"), ("positive", "[[1,2,4]]", "[1,4,16]"), ("empty", "[[]]", "[]")]
        ),
        problem(
            id: "pointers.closest-pair", title: "Closest Pair to Target", difficulty: .medium, minutes: 35,
            why: "Pointer movement can optimize a value, not only search for an exact match.",
            prompt: "Given ascending integers, return the two values whose sum is closest to target. On equal distance, return the lexicographically smaller pair.",
            signature: "closest_pair(numbers, target)", exampleInput: "[1, 3, 4, 7, 10], 12", exampleOutput: "[1, 10]",
            constraints: ["numbers is ascending", "len(numbers) ≥ 2"],
            hints: ["Start with the widest pair.", "Update the best pair before moving a pointer.", "A sum below target needs a larger left value; a sum above needs a smaller right value."],
            solution: """
            def closest_pair(numbers, target):
                left, right = 0, len(numbers) - 1
                best = [numbers[left], numbers[right]]
                while left < right:
                    pair = [numbers[left], numbers[right]]
                    distance = abs(sum(pair) - target)
                    best_distance = abs(sum(best) - target)
                    if distance < best_distance or (distance == best_distance and pair < best):
                        best = pair
                    if sum(pair) < target:
                        left += 1
                    else:
                        right -= 1
                return best
            """,
            explanation: "Sorted order makes one pointer direction the only possible improvement after each sum. Tie comparison keeps the output deterministic.",
            time: "O(n)", space: "O(1)",
            tests: [("near", "[[1,3,4,7,10],12]", "[1,10]"), ("exact", "[[-5,-2,1,8],6]", "[-2,8]"), ("tie", "[[1,4,7,10],8]", "[1,7]"), ("two", "[[2,9],20]", "[2,9]")]
        ),
        problem(
            id: "pointers.four-sum", title: "Four-Value Target", difficulty: .hard, minutes: 60,
            why: "It generalizes duplicate-safe sorting and two-pointer reduction to a deeper search.",
            prompt: "Return every unique ascending quadruplet whose values sum to target. Return quadruplets in lexicographic order.",
            signature: "four_sum(numbers, target)", exampleInput: "[1, 0, -1, 0, -2, 2], 0", exampleOutput: "[[-2, -1, 1, 2], [-2, 0, 0, 2], [-1, 0, 0, 1]]",
            constraints: ["0 ≤ len(numbers) ≤ 300", "Do not return duplicate value combinations"],
            hints: ["Sort the values.", "Fix the first two positions, then use opposite pointers for the remaining target.", "Skip duplicates at every fixed and moving position."],
            solution: """
            def four_sum(numbers, target):
                values = sorted(numbers)
                result = []
                for first in range(len(values) - 3):
                    if first > 0 and values[first] == values[first - 1]:
                        continue
                    for second in range(first + 1, len(values) - 2):
                        if second > first + 1 and values[second] == values[second - 1]:
                            continue
                        left, right = second + 1, len(values) - 1
                        while left < right:
                            total = values[first] + values[second] + values[left] + values[right]
                            if total < target:
                                left += 1
                            elif total > target:
                                right -= 1
                            else:
                                result.append([values[first], values[second], values[left], values[right]])
                                left += 1
                                right -= 1
                                while left < right and values[left] == values[left - 1]:
                                    left += 1
                                while left < right and values[right] == values[right + 1]:
                                    right -= 1
                return result
            """,
            explanation: "Sorting fixes a canonical order. Two outer choices reduce the rest to a monotonic pair search, while duplicate skipping emits each quadruplet once.",
            time: "O(n³)", space: "O(n) for sorting/output",
            tests: [("classic", "[[1,0,-1,0,-2,2],0]", "[[-2,-1,1,2],[-2,0,0,2],[-1,0,0,1]]"), ("duplicates", "[[2,2,2,2,2],8]", "[[2,2,2,2]]"), ("none", "[[1,2,3],6]", "[]"), ("mixed", "[[-3,-1,0,2,4,5],2]", "[[-3,-1,2,4]]")]
        )
    ]

    // MARK: Sliding Window

    private static let slidingWindow = [
        problem(
            id: "window.min-positive-sum", title: "Shortest Sum Window", difficulty: .medium, minutes: 35,
            why: "Positive values make a shrinking window provably monotonic.",
            prompt: "Given positive integers, return the smallest length of a contiguous subarray with sum at least target. Return 0 if impossible.",
            signature: "shortest_sum_window(numbers, target)", exampleInput: "[2, 3, 1, 2, 4, 3], 7", exampleOutput: "2",
            constraints: ["Every number is positive", "target is positive"],
            hints: ["Expand the right edge until the sum qualifies.", "Once qualified, move left while recording smaller windows.", "Positivity guarantees removing left can only reduce the sum."],
            solution: """
            def shortest_sum_window(numbers, target):
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
            """,
            explanation: "Each right edge grows the sum and each left move finds the shortest qualifying window ending there. Both pointers only move forward.",
            time: "O(n)", space: "O(1)",
            tests: [("classic", "[[2,3,1,2,4,3],7]", "2"), ("single", "[[1,4,4],4]", "1"), ("none", "[[1,1,1],5]", "0"), ("whole", "[[2,2,2],6]", "3")]
        ),
        problem(
            id: "window.max-ones", title: "Longest Ones After Flips", difficulty: .medium, minutes: 35,
            why: "It reframes a modification budget as the count of violations inside a window.",
            prompt: "A binary array allows at most k zeros to be changed to ones. Return the longest possible contiguous run of ones.",
            signature: "longest_ones(numbers, k)", exampleInput: "[1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0], 2", exampleOutput: "6",
            constraints: ["Every value is 0 or 1", "k ≥ 0"],
            hints: ["Zeros are the only window cost.", "Expand right and count zeros.", "Shrink left only while the zero count exceeds k."],
            solution: """
            def longest_ones(numbers, k):
                left = zeros = best = 0
                for right, number in enumerate(numbers):
                    if number == 0:
                        zeros += 1
                    while zeros > k:
                        if numbers[left] == 0:
                            zeros -= 1
                        left += 1
                    best = max(best, right - left + 1)
                return best
            """,
            explanation: "The maintained window always costs at most k flips. Shrinking just enough preserves the longest valid candidate for each right edge.",
            time: "O(n)", space: "O(1)",
            tests: [("classic", "[[1,1,1,0,0,0,1,1,1,1,0],2]", "6"), ("all zero", "[[0,0,0],1]", "1"), ("no flips", "[[1,0,1,1],0]", "2"), ("empty", "[[],3]", "0")]
        ),
        problem(
            id: "window.repeated-dna", title: "Repeated DNA Windows", difficulty: .medium, minutes: 40,
            why: "Fixed-size substring fingerprints are a direct sliding-window application.",
            prompt: "Return every length-10 substring that occurs more than once in DNA. Order results by when each substring is first confirmed as repeated.",
            signature: "repeated_dna(text)", exampleInput: "\"AAAAACCCCCAAAAACCCCCCAAAAAGGGTTT\"", exampleOutput: "[\"AAAAACCCCC\", \"CCCCCAAAAA\"]",
            constraints: ["text contains only A, C, G, T", "0 ≤ len(text) ≤ 100,000"],
            hints: ["Every candidate has exactly ten characters.", "Track windows seen once and windows already reported.", "Append only on the second occurrence."],
            solution: """
            def repeated_dna(text):
                seen = set()
                reported = set()
                result = []
                for start in range(len(text) - 9):
                    window = text[start:start + 10]
                    if window in seen and window not in reported:
                        result.append(window)
                        reported.add(window)
                    seen.add(window)
                return result
            """,
            explanation: "Each start produces one fixed window. Separate seen and reported sets prevent both missed repeats and duplicate output.",
            time: "O(n)", space: "O(n)",
            tests: [("classic", "[\"AAAAACCCCCAAAAACCCCCCAAAAAGGGTTT\"]", "[\"AAAAACCCCC\",\"CCCCCAAAAA\"]"), ("same", "[\"AAAAAAAAAAA\"]", "[\"AAAAAAAAAA\"]"), ("short", "[\"ACGT\"]", "[]"), ("none", "[\"ACGTACGTAC\"]", "[]")]
        ),
        problem(
            id: "window.maximum-values", title: "Maximum of Every Window", difficulty: .hard, minutes: 55,
            why: "A monotonic deque keeps only candidates that can still become a future maximum.",
            prompt: "Return the maximum value in every contiguous window of width k, from left to right. Return [] when k < 1 or k > len(numbers).",
            signature: "window_maximums(numbers, k)", exampleInput: "[1, 3, -1, -3, 5, 3, 6, 7], 3", exampleOutput: "[3, 3, 5, 5, 6, 7]",
            constraints: ["0 ≤ len(numbers) ≤ 100,000", "A valid k satisfies 1 ≤ k ≤ len(numbers)"],
            hints: ["Store indices in decreasing value order.", "Remove indices that leave the left edge.", "Before adding a value, discard smaller values from the back because they can never win again."],
            solution: """
            def window_maximums(numbers, k):
                if k < 1 or k > len(numbers):
                    return []
                queue = []
                head = 0
                result = []
                for right, number in enumerate(numbers):
                    while head < len(queue) and queue[head] <= right - k:
                        head += 1
                    while len(queue) > head and numbers[queue[-1]] <= number:
                        queue.pop()
                    queue.append(right)
                    if right >= k - 1:
                        result.append(numbers[queue[head]])
                return result
            """,
            explanation: "The deque front is always the largest live value. Smaller values behind a newer larger value are dominated and safely removed.",
            time: "O(n)", space: "O(k)",
            tests: [("classic", "[[1,3,-1,-3,5,3,6,7],3]", "[3,3,5,5,6,7]"), ("one", "[[4,2],1]", "[4,2]"), ("whole", "[[2,1,5],3]", "[5]"), ("invalid", "[[1,2],3]", "[]")]
        )
    ]

    // MARK: Stacks

    private static let stacks = [
        problem(
            id: "stack.min-add-parentheses", title: "Parentheses to Add", difficulty: .easy, minutes: 20,
            why: "It reduces stack state to two counters when there is only one bracket type.",
            prompt: "Return the minimum number of parentheses that must be inserted to make a string of ( and ) valid.",
            signature: "minimum_parentheses_additions(text)", exampleInput: "\"()))((\"", exampleOutput: "4",
            constraints: ["text contains only ( and )", "0 ≤ len(text) ≤ 100,000"],
            hints: ["Track unmatched opening parentheses.", "A closing parenthesis with no opener requires an insertion.", "At the end, every remaining opener also requires one insertion."],
            solution: """
            def minimum_parentheses_additions(text):
                open_count = additions = 0
                for character in text:
                    if character == "(":
                        open_count += 1
                    elif open_count > 0:
                        open_count -= 1
                    else:
                        additions += 1
                return additions + open_count
            """,
            explanation: "open_count represents closers still needed for the prefix. A closer at zero cannot be matched later, so it forces an opening insertion now.",
            time: "O(n)", space: "O(1)",
            tests: [("mixed", "[\"()))((\"]", "4"), ("valid", "[\"()()\"]", "0"), ("open", "[\"(((\"]", "3"), ("empty", "[\"\"]", "0")]
        ),
        problem(
            id: "stack.asteroid-collisions", title: "Asteroid Collisions", difficulty: .medium, minutes: 40,
            why: "A stack models unresolved objects whose fate depends on future input.",
            prompt: "Asteroids are listed from left to right. Positive values move right and negative values move left at equal speed. Only a right-moving asteroid to the left of a left-moving asteroid can collide. The smaller magnitude disappears; equal magnitudes both disappear. Return surviving values in their original relative order.",
            signature: "asteroid_collisions(asteroids)", exampleInput: "[5, 10, -5]", exampleOutput: "[5, 10]",
            constraints: ["No asteroid has value 0", "Order survivors as they remain"],
            hints: ["A collision is possible only when the stack top moves right and the new asteroid moves left.", "Keep resolving while the new asteroid survives.", "Equal magnitudes remove both; a larger stack top removes the new asteroid."],
            solution: """
            def asteroid_collisions(asteroids):
                stack = []
                for asteroid in asteroids:
                    alive = True
                    while alive and stack and stack[-1] > 0 and asteroid < 0:
                        if stack[-1] < -asteroid:
                            stack.pop()
                        elif stack[-1] == -asteroid:
                            stack.pop()
                            alive = False
                        else:
                            alive = False
                    if alive:
                        stack.append(asteroid)
                return stack
            """,
            explanation: "The stack contains survivors from the processed prefix. Only its right-moving top can meet a new left-moving asteroid, so repeated top resolution is complete.",
            time: "O(n)", space: "O(n)",
            tests: [("survivor", "[[5,10,-5]]", "[5,10]"), ("equal", "[[8,-8]]", "[]"), ("chain", "[[10,2,-5]]", "[10]"), ("apart", "[[-2,-1,1,2]]", "[-2,-1,1,2]")]
        ),
        problem(
            id: "stack.decode-string", title: "Decode Repeated Text", difficulty: .medium, minutes: 40,
            why: "Nested encoded sections map directly to stacked outer contexts.",
            prompt: "Decode strings where k[segment] repeats segment k times. Encodings may nest; input is valid.",
            signature: "decode_repeated_text(text)", exampleInput: "\"3[a2[c]]\"", exampleOutput: "\"accaccacc\"",
            constraints: ["Repeat counts are positive integers", "The decoded result fits in memory"],
            hints: ["Build a current text and current repeat number.", "On [, save the outer text and count.", "On ], restore the outer text plus the repeated current segment."],
            solution: """
            def decode_repeated_text(text):
                stack = []
                current = ""
                count = 0
                for character in text:
                    if character.isdigit():
                        count = count * 10 + int(character)
                    elif character == "[":
                        stack.append([current, count])
                        current = ""
                        count = 0
                    elif character == "]":
                        outer, repeats = stack.pop()
                        current = outer + current * repeats
                    else:
                        current += character
                return current
            """,
            explanation: "Each stack entry freezes the context outside one bracket. Closing that bracket completes exactly one nested segment before returning outward.",
            time: "O(decoded length)", space: "O(decoded length + depth)",
            tests: [("nested", "[\"3[a2[c]]\"]", "\"accaccacc\""), ("several", "[\"2[abc]3[cd]ef\"]", "\"abcabccdcdcdef\""), ("plain", "[\"hello\"]", "\"hello\""), ("multi digit", "[\"10[a]\"]", "\"aaaaaaaaaa\"")]
        ),
        problem(
            id: "stack.next-greater-circular", title: "Circular Next Greater", difficulty: .medium, minutes: 45,
            why: "A second virtual pass lets a monotonic stack resolve circular dependencies.",
            prompt: "For each value in a circular array, return the first strictly greater value encountered moving right, or -1 if none exists.",
            signature: "next_greater_circular(numbers)", exampleInput: "[1, 2, 1]", exampleOutput: "[2, -1, 2]",
            constraints: ["0 ≤ len(numbers) ≤ 100,000", "Return one answer per input value"],
            hints: ["Store unresolved indices in decreasing value order.", "Scan indices twice using index modulo n.", "Only push indices during the first pass; the second pass exists only to resolve them."],
            solution: """
            def next_greater_circular(numbers):
                size = len(numbers)
                result = [-1] * size
                stack = []
                for index in range(size * 2):
                    actual = index % size
                    while stack and numbers[actual] > numbers[stack[-1]]:
                        result[stack.pop()] = numbers[actual]
                    if index < size:
                        stack.append(actual)
                return result
            """,
            explanation: "The decreasing stack holds indices still waiting for a larger value. A virtual second copy exposes wraparound candidates without duplicating entries.",
            time: "O(n)", space: "O(n)",
            tests: [("simple", "[[1,2,1]]", "[2,-1,2]"), ("descending", "[[5,4,3,2,1]]", "[-1,5,5,5,5]"), ("equal", "[[2,2]]", "[-1,-1]"), ("empty", "[[]]", "[]")]
        )
    ]

    // MARK: Binary Search

    private static let binarySearch = [
        problem(
            id: "binary.exact-search", title: "Exact Binary Search", difficulty: .easy, minutes: 20,
            why: "A precise closed-interval template prevents the most common binary-search bugs.",
            prompt: "Return target's index in a strictly increasing array, or -1 if absent.",
            signature: "exact_binary_search(numbers, target)", exampleInput: "[-1, 0, 3, 5, 9, 12], 9", exampleOutput: "4",
            constraints: ["numbers is strictly increasing", "0 ≤ len(numbers) ≤ 100,000"],
            hints: ["Maintain an inclusive [left, right] search interval.", "Compare target with the middle value.", "Discard middle and the impossible half after a mismatch."],
            solution: """
            def exact_binary_search(numbers, target):
                left, right = 0, len(numbers) - 1
                while left <= right:
                    middle = left + (right - left) // 2
                    if numbers[middle] == target:
                        return middle
                    if numbers[middle] < target:
                        left = middle + 1
                    else:
                        right = middle - 1
                return -1
            """,
            explanation: "The inclusive interval contains every remaining candidate. Each comparison removes middle and one half, so the interval shrinks geometrically.",
            time: "O(log n)", space: "O(1)",
            tests: [("found", "[[-1,0,3,5,9,12],9]", "4"), ("absent", "[[1,3,5],2]", "-1"), ("first", "[[2,4,6],2]", "0"), ("empty", "[[],1]", "-1")]
        ),
        problem(
            id: "binary.integer-root", title: "Integer Square Root", difficulty: .easy, minutes: 25,
            why: "It practices binary search over an answer space with a last-feasible boundary.",
            prompt: "Given a nonnegative integer value, return floor(sqrt(value)) without using a square-root function.",
            signature: "integer_square_root(value)", exampleInput: "17", exampleOutput: "4",
            constraints: ["0 ≤ value ≤ 2,000,000,000", "Return an integer"],
            hints: ["The answer lies between 0 and value.", "A candidate is feasible when candidate² ≤ value.", "Search for the last feasible candidate."],
            solution: """
            def integer_square_root(value):
                left, right = 0, value
                answer = 0
                while left <= right:
                    middle = left + (right - left) // 2
                    if middle * middle <= value:
                        answer = middle
                        left = middle + 1
                    else:
                        right = middle - 1
                return answer
            """,
            explanation: "Feasibility is true for every integer through the floor root and false afterward. Recording feasible middle values finds that last true boundary.",
            time: "O(log value)", space: "O(1)",
            tests: [("non square", "[17]", "4"), ("square", "[144]", "12"), ("zero", "[0]", "0"), ("one", "[1]", "1")]
        ),
        problem(
            id: "binary.peak-index", title: "Find a Peak", difficulty: .medium, minutes: 35,
            why: "Local slope direction can guide binary search even without globally sorted data.",
            prompt: "The nonempty list has different adjacent values and is guaranteed to contain exactly one peak. Return that peak's zero-based index. A peak is greater than every neighbor that exists, so index 0 compares only with index 1, the final index compares only with its predecessor, and a one-element list has its peak at index 0.",
            signature: "peak_index(numbers)", exampleInput: "[1, 2, 3, 1]", exampleOutput: "2",
            constraints: ["numbers is nonempty", "Adjacent values differ"],
            hints: ["Compare middle with the value immediately to its right.", "An upward slope guarantees a peak on the right side.", "A downward slope keeps middle or a peak to its left."],
            solution: """
            def peak_index(numbers):
                left, right = 0, len(numbers) - 1
                while left < right:
                    middle = left + (right - left) // 2
                    if numbers[middle] < numbers[middle + 1]:
                        left = middle + 1
                    else:
                        right = middle
                return left
            """,
            explanation: "Following an upward slope cannot run forever without reaching a peak; on a downward slope, a peak exists at middle or before it.",
            time: "O(log n)", space: "O(1)",
            tests: [("middle", "[[1,2,3,1]]", "2"), ("first", "[[5,3,1]]", "0"), ("last", "[[1,3,5]]", "2"), ("single", "[[7]]", "0")]
        )
    ]

    // MARK: Intervals

    private static let intervals = [
        problem(
            id: "intervals.can-attend", title: "Can Attend Every Meeting", difficulty: .easy, minutes: 20,
            why: "Sorting turns an all-pairs overlap question into adjacent comparisons.",
            prompt: "Return true when no closed-open meeting ranges overlap. Meetings that touch are compatible.",
            signature: "can_attend_all(meetings)", exampleInput: "[[0, 30], [35, 40], [30, 35]]", exampleOutput: "true",
            constraints: ["Every meeting has start < end", "Input may be unsorted"],
            hints: ["Sort meetings by start time.", "Only neighboring meetings can overlap after sorting.", "An overlap exists when the next start is less than the previous end."],
            solution: """
            def can_attend_all(meetings):
                ordered = sorted(meetings)
                for index in range(1, len(ordered)):
                    if ordered[index][0] < ordered[index - 1][1]:
                        return False
                return True
            """,
            explanation: "After sorting, any overlap with an earlier meeting must also conflict with the latest-ending adjacent predecessor encountered first.",
            time: "O(n log n)", space: "O(n)",
            tests: [("touching", "[[[0,30],[35,40],[30,35]]]", "true"), ("overlap", "[[[0,30],[5,10],[15,20]]]", "false"), ("one", "[[[1,2]]]", "true"), ("empty", "[[]]", "true")]
        ),
        problem(
            id: "intervals.covered-queries", title: "Covered Query Points", difficulty: .medium, minutes: 35,
            why: "Merging first avoids repeating the same overlap work for every query.",
            prompt: "Given closed ranges and query points, return a boolean for each query indicating whether it lies inside at least one range.",
            signature: "covered_queries(ranges, queries)", exampleInput: "[[1, 4], [6, 8]], [2, 5, 8]", exampleOutput: "[true, false, true]",
            constraints: ["Ranges and queries contain integers", "Input ranges may overlap"],
            hints: ["Merge overlapping ranges first.", "Sort queries together with their original indices.", "Advance one range pointer as query values increase."],
            solution: """
            def covered_queries(ranges, queries):
                ordered = sorted(ranges)
                merged = []
                for start, end in ordered:
                    if not merged or start > merged[-1][1]:
                        merged.append([start, end])
                    else:
                        merged[-1][1] = max(merged[-1][1], end)
                answers = [False] * len(queries)
                range_index = 0
                for query, original_index in sorted([[value, index] for index, value in enumerate(queries)]):
                    while range_index < len(merged) and merged[range_index][1] < query:
                        range_index += 1
                    if range_index < len(merged) and merged[range_index][0] <= query:
                        answers[original_index] = True
                return answers
            """,
            explanation: "Merged ranges are disjoint, and sorted queries move only forward. Restoring original indices preserves the requested output order.",
            time: "O((n + q) log(n + q))", space: "O(n + q)",
            tests: [("mixed", "[[[1,4],[6,8]],[2,5,8]]", "[true,false,true]"), ("overlap", "[[[1,5],[3,9]],[0,4,10]]", "[false,true,false]"), ("empty ranges", "[[],[1,2]]", "[false,false]"), ("empty queries", "[[[1,2]],[]]", "[]")]
        ),
        problem(
            id: "intervals.minimum-groups", title: "Minimum Overlap Groups", difficulty: .medium, minutes: 45,
            why: "A sweep line converts overlapping intervals into a maximum-active-events count.",
            prompt: "Closed intervals that share any point conflict. Return the minimum number of groups needed so intervals within a group never conflict.",
            signature: "minimum_interval_groups(ranges)", exampleInput: "[[5, 10], [6, 8], [1, 5], [2, 3], [1, 10]]", exampleOutput: "3",
            constraints: ["Every range has start ≤ end", "Touching closed intervals conflict"],
            hints: ["Create a +1 event at each start.", "Create a -1 event just after each end.", "The answer is the maximum number of simultaneously active intervals."],
            solution: """
            def minimum_interval_groups(ranges):
                events = []
                for start, end in ranges:
                    events.append([start, 1])
                    events.append([end, -1])
                events.sort(key=lambda event: (event[0], -event[1]))
                active = best = 0
                for _, change in events:
                    active += change
                    best = max(best, active)
                return best
            """,
            explanation: "At a shared endpoint, starts are processed before ends because closed intervals still overlap there. Maximum concurrency is exactly the required group count.",
            time: "O(n log n)", space: "O(n)",
            tests: [("mixed", "[[[5,10],[6,8],[1,5],[2,3],[1,10]]]", "3"), ("touch", "[[[1,2],[2,3]]]", "2"), ("disjoint", "[[[1,1],[2,2],[3,3]]]", "1"), ("empty", "[[]]", "0")]
        )
    ]

    // MARK: Trees

    private static let trees = [
        problem(
            id: "trees.preorder-values", title: "Preorder Values", difficulty: .easy, minutes: 25,
            why: "Changing traversal order becomes mechanical once the recursive contract is clear.",
            prompt: "A binary tree is a heap-indexed level-order array with null missing nodes. Return values in root-left-right preorder.",
            signature: "preorder_values(tree)", exampleInput: "[1, 2, 3, 4, 5]", exampleOutput: "[1, 2, 4, 5, 3]",
            constraints: ["Children of i are 2i+1 and 2i+2", "null nodes have no descendants"],
            hints: ["Write visit(index).", "Return for an out-of-range or null node.", "Append before visiting left and right children."],
            solution: """
            def preorder_values(tree):
                result = []
                def visit(index):
                    if index >= len(tree) or tree[index] is None:
                        return
                    result.append(tree[index])
                    visit(index * 2 + 1)
                    visit(index * 2 + 2)
                visit(0)
                return result
            """,
            explanation: "Each call emits its entire subtree. Appending before the recursive calls directly encodes root-left-right order.",
            time: "O(n)", space: "O(h)",
            tests: [("balanced", "[[1,2,3,4,5]]", "[1,2,4,5,3]"), ("single", "[[9]]", "[9]"), ("partial", "[[1,null,2,null,null,3]]", "[1,2,3]"), ("empty", "[[]]", "[]")]
        ),
        problem(
            id: "trees.same-tree", title: "Same Tree Shape and Values", difficulty: .easy, minutes: 25,
            why: "Paired recursion is the basis for comparing and transforming tree structures.",
            prompt: "Two binary trees use heap-indexed arrays with null missing nodes. Return true when they have identical structure and equal values.",
            signature: "same_tree(first, second)", exampleInput: "[1, 2, 3], [1, 2, 3]", exampleOutput: "true",
            constraints: ["null nodes have no descendants", "Values are compared exactly"],
            hints: ["Compare corresponding indices.", "Two absent nodes match; one absent node does not.", "Equal current values are not enough—both child pairs must also match."],
            solution: """
            def same_tree(first, second):
                def value_at(tree, index):
                    return None if index >= len(tree) else tree[index]
                def compare(index):
                    first_value = value_at(first, index)
                    second_value = value_at(second, index)
                    if first_value is None or second_value is None:
                        return first_value is None and second_value is None
                    if first_value != second_value:
                        return False
                    return compare(index * 2 + 1) and compare(index * 2 + 2)
                return compare(0)
            """,
            explanation: "The recursive invariant is that compare(i) decides equality of both subtrees rooted at i, combining the current values and corresponding children.",
            time: "O(n)", space: "O(h)",
            tests: [("same", "[[1,2,3],[1,2,3]]", "true"), ("value", "[[1,2],[1,3]]", "false"), ("shape", "[[1,2],[1,null,2]]", "false"), ("empty", "[[],[]]", "true")]
        ),
        problem(
            id: "trees.diameter", title: "Tree Diameter", difficulty: .medium, minutes: 45,
            why: "It demonstrates returning one subtree summary while updating a different global answer.",
            prompt: "A binary tree uses a heap-indexed array. Return the number of edges in its longest path between any two non-null nodes.",
            signature: "tree_diameter(tree)", exampleInput: "[1, 2, 3, 4, 5]", exampleOutput: "3",
            constraints: ["Children of i are 2i+1 and 2i+2", "An empty or one-node tree has diameter 0"],
            hints: ["Let each subtree return its height in nodes.", "A path through a node combines left height and right height.", "Update a shared best diameter before returning one plus the larger height."],
            solution: """
            def tree_diameter(tree):
                best = [0]
                def height(index):
                    if index >= len(tree) or tree[index] is None:
                        return 0
                    left = height(index * 2 + 1)
                    right = height(index * 2 + 2)
                    best[0] = max(best[0], left + right)
                    return 1 + max(left, right)
                height(0)
                return best[0]
            """,
            explanation: "A subtree exposes one downward height to its parent, while left + right counts the longest path through its own root in edges.",
            time: "O(n)", space: "O(h)",
            tests: [("balanced", "[[1,2,3,4,5]]", "3"), ("single", "[[1]]", "0"), ("chain", "[[1,2,null,3]]", "2"), ("empty", "[[]]", "0")]
        )
    ]

    // MARK: Graphs

    private static let graphs = [
        problem(
            id: "graphs.components", title: "Connected Components", difficulty: .easy, minutes: 30,
            why: "Restarting traversal from every unseen node handles disconnected graphs cleanly.",
            prompt: "An undirected graph has node_count nodes and edge pairs. Return the number of connected components.",
            signature: "connected_components(node_count, edges)", exampleInput: "5, [[0, 1], [1, 2], [3, 4]]", exampleOutput: "2",
            constraints: ["Nodes are 0 through node_count-1", "Edges are undirected"],
            hints: ["Build an adjacency list.", "Each traversal marks exactly one component.", "Start a traversal whenever a node is still unseen and increment the count."],
            solution: """
            def connected_components(node_count, edges):
                graph = [[] for _ in range(node_count)]
                for first, second in edges:
                    graph[first].append(second)
                    graph[second].append(first)
                seen = set()
                count = 0
                for start in range(node_count):
                    if start in seen:
                        continue
                    count += 1
                    stack = [start]
                    seen.add(start)
                    while stack:
                        node = stack.pop()
                        for neighbor in graph[node]:
                            if neighbor not in seen:
                                seen.add(neighbor)
                                stack.append(neighbor)
                return count
            """,
            explanation: "Every unseen starting node belongs to a new component. Its traversal marks the entire component so no member is counted twice.",
            time: "O(V + E)", space: "O(V + E)",
            tests: [("two", "[5,[[0,1],[1,2],[3,4]]]", "2"), ("none", "[3,[]]", "3"), ("connected", "[4,[[0,1],[1,2],[2,3]]]", "1"), ("empty", "[0,[]]", "0")]
        ),
        problem(
            id: "graphs.flood-fill", title: "Flood Fill", difficulty: .easy, minutes: 30,
            why: "Grid painting is graph traversal with an especially visible visited-state rule.",
            prompt: "Starting at the valid zero-based position [row, column], recolor every cell in its four-directionally connected region that has the starting cell's original color. Return a newly allocated image with all other cells unchanged; do not mutate the supplied image.",
            signature: "flood_fill(image, row, column, new_color)", exampleInput: "[[1,1,1],[1,1,0],[1,0,1]], 1, 1, 2", exampleOutput: "[[2,2,2],[2,2,0],[2,0,1]]",
            constraints: ["image is nonempty and rectangular", "The start coordinate is valid"],
            hints: ["Copy the image before changing it.", "Remember the original starting color.", "Traverse only in-bounds neighbors that still have that original color."],
            solution: """
            def flood_fill(image, row, column, new_color):
                result = [line[:] for line in image]
                original = result[row][column]
                if original == new_color:
                    return result
                stack = [[row, column]]
                result[row][column] = new_color
                while stack:
                    current_row, current_column = stack.pop()
                    for row_step, column_step in [[1,0],[-1,0],[0,1],[0,-1]]:
                        next_row = current_row + row_step
                        next_column = current_column + column_step
                        if 0 <= next_row < len(result) and 0 <= next_column < len(result[0]):
                            if result[next_row][next_column] == original:
                                result[next_row][next_column] = new_color
                                stack.append([next_row, next_column])
                return result
            """,
            explanation: "Recoloring when a cell is discovered doubles as the visited mark. Only cells connected through the original color enter the traversal.",
            time: "O(rows · columns)", space: "O(rows · columns)",
            tests: [("region", "[[[1,1,1],[1,1,0],[1,0,1]],1,1,2]", "[[2,2,2],[2,2,0],[2,0,1]]"), ("same", "[[[0]],0,0,0]", "[[0]]"), ("corner", "[[[1,0],[0,0]],0,0,9]", "[[9,0],[0,0]]"), ("all", "[[[3,3],[3,3]],0,1,4]", "[[4,4],[4,4]]")]
        ),
        problem(
            id: "graphs.word-ladder", title: "Word Transformation Steps", difficulty: .hard, minutes: 55,
            why: "Breadth-first search over implicit neighbors is a core graph-modeling skill.",
            prompt: "Change exactly one letter per step from start to end. The start word need not be in dictionary, but every word after it—including end—must be in dictionary. Return the number of words in the shortest sequence, counting both start and end. Return 0 if end is absent from dictionary or no sequence exists; when start == end and end is present, return 1.",
            signature: "word_ladder_length(start, end, dictionary)", exampleInput: "\"hit\", \"cog\", [\"hot\",\"dot\",\"dog\",\"lot\",\"log\",\"cog\"]", exampleOutput: "5",
            constraints: ["All words have equal lowercase length", "start may be absent from dictionary"],
            hints: ["Words are graph nodes; one-letter changes are edges.", "Use BFS because every change has equal cost.", "Generate neighbors by trying a-z at each position and remove visited words."],
            solution: """
            def word_ladder_length(start, end, dictionary):
                available = set(dictionary)
                if end not in available:
                    return 0
                queue = [[start, 1]]
                head = 0
                available.discard(start)
                alphabet = "abcdefghijklmnopqrstuvwxyz"
                while head < len(queue):
                    word, distance = queue[head]
                    head += 1
                    if word == end:
                        return distance
                    for index in range(len(word)):
                        for letter in alphabet:
                            candidate = word[:index] + letter + word[index + 1:]
                            if candidate in available:
                                available.remove(candidate)
                                queue.append([candidate, distance + 1])
                return 0
            """,
            explanation: "BFS explores transformations by sequence length. Removing a word when enqueued prevents cycles and ensures its first visit is shortest.",
            time: "O(n · wordLength · 26)", space: "O(n)",
            tests: [("classic", "[\"hit\",\"cog\",[\"hot\",\"dot\",\"dog\",\"lot\",\"log\",\"cog\"]]", "5"), ("missing", "[\"hit\",\"cog\",[\"hot\",\"dot\"]]", "0"), ("direct", "[\"a\",\"c\",[\"a\",\"b\",\"c\"]]", "2"), ("same", "[\"same\",\"same\",[\"same\"]]", "1")]
        )
    ]

    // MARK: Backtracking

    private static let backtracking = [
        problem(
            id: "backtracking.phone-letters", title: "Phone Letter Combinations", difficulty: .medium, minutes: 35,
            why: "It is a compact choose-explore-undo tree with a different choice set at each depth.",
            prompt: "Use this phone mapping: 2→abc, 3→def, 4→ghi, 5→jkl, 6→mno, 7→pqrs, 8→tuv, 9→wxyz. Choose one letter for each input digit and return every resulting string in depth-first keypad order, iterating each digit's letters left to right. Return [] for empty input.",
            signature: "phone_letter_combinations(digits)", exampleInput: "\"23\"", exampleOutput: "[\"ad\",\"ae\",\"af\",\"bd\",\"be\",\"bf\",\"cd\",\"ce\",\"cf\"]",
            constraints: ["digits contains only 2-9", "0 ≤ len(digits) ≤ 8"],
            hints: ["Each recursion depth chooses a letter for one digit.", "Append a completed path when its length equals len(digits).", "Iterate mappings in keypad order for deterministic output."],
            solution: """
            def phone_letter_combinations(digits):
                if not digits:
                    return []
                letters = {"2":"abc", "3":"def", "4":"ghi", "5":"jkl", "6":"mno", "7":"pqrs", "8":"tuv", "9":"wxyz"}
                result = []
                path = []
                def search(index):
                    if index == len(digits):
                        result.append("".join(path))
                        return
                    for letter in letters[digits[index]]:
                        path.append(letter)
                        search(index + 1)
                        path.pop()
                search(0)
                return result
            """,
            explanation: "The path contains one choice per processed digit. Undoing the final letter restores the exact state needed for the next sibling branch.",
            time: "O(4ⁿ · n)", space: "O(n) excluding output",
            tests: [("two", "[\"23\"]", "[\"ad\",\"ae\",\"af\",\"bd\",\"be\",\"bf\",\"cd\",\"ce\",\"cf\"]"), ("one", "[\"7\"]", "[\"p\",\"q\",\"r\",\"s\"]"), ("empty", "[\"\"]", "[]"), ("mixed", "[\"29\"]", "[\"aw\",\"ax\",\"ay\",\"az\",\"bw\",\"bx\",\"by\",\"bz\",\"cw\",\"cx\",\"cy\",\"cz\"]")]
        ),
        problem(
            id: "backtracking.generate-parentheses", title: "Generate Parentheses", difficulty: .medium, minutes: 40,
            why: "Constraints can prune invalid partial constructions before they become full candidates.",
            prompt: "Return every valid string containing n pairs of parentheses, ordered by trying ( before ).",
            signature: "generate_parentheses(n)", exampleInput: "3", exampleOutput: "[\"((()))\",\"(()())\",\"(())()\",\"()(())\",\"()()()\"]",
            constraints: ["0 ≤ n ≤ 9", "For n = 0 return [\"\"]"],
            hints: ["Track how many opens and closes have been used.", "Add ( while opens < n.", "Add ) only while closes < opens, so no prefix becomes invalid."],
            solution: """
            def generate_parentheses(n):
                result = []
                path = []
                def search(open_count, close_count):
                    if len(path) == n * 2:
                        result.append("".join(path))
                        return
                    if open_count < n:
                        path.append("(")
                        search(open_count + 1, close_count)
                        path.pop()
                    if close_count < open_count:
                        path.append(")")
                        search(open_count, close_count + 1)
                        path.pop()
                search(0, 0)
                return result
            """,
            explanation: "open_count and close_count describe all validity information for the prefix. The closing rule prunes every impossible branch immediately.",
            time: "O(Catalan(n) · n)", space: "O(n) excluding output",
            tests: [("three", "[3]", "[\"((()))\",\"(()())\",\"(())()\",\"()(())\",\"()()()\"]"), ("one", "[1]", "[\"()\"]"), ("zero", "[0]", "[\"\"]"), ("two", "[2]", "[\"(())\",\"()()\"]")]
        ),
        problem(
            id: "backtracking.palindrome-partitions", title: "Palindrome Partitions", difficulty: .medium, minutes: 45,
            why: "It combines substring validation with exhaustive partition-boundary choices.",
            prompt: "Return every partition of text where each piece is a palindrome. Order the partitions by depth-first search, trying each next piece from shortest to longest.",
            signature: "palindrome_partitions(text)", exampleInput: "\"aab\"", exampleOutput: "[[\"a\",\"a\",\"b\"],[\"aa\",\"b\"]]",
            constraints: ["0 ≤ len(text) ≤ 16", "Character comparison is exact"],
            hints: ["At a start index, try every possible end index.", "Recurse only when the chosen substring equals its reverse.", "A partition is complete when start reaches len(text)."],
            solution: """
            def palindrome_partitions(text):
                result = []
                path = []
                def search(start):
                    if start == len(text):
                        result.append(path[:])
                        return
                    for end in range(start + 1, len(text) + 1):
                        piece = text[start:end]
                        if piece == piece[::-1]:
                            path.append(piece)
                            search(end)
                            path.pop()
                search(0)
                return result
            """,
            explanation: "Every recursive level fixes the next partition boundary. Palindrome checking prunes invalid pieces before exploring their suffixes.",
            time: "O(n · 2ⁿ)", space: "O(n) excluding output",
            tests: [("mixed", "[\"aab\"]", "[[\"a\",\"a\",\"b\"],[\"aa\",\"b\"]]"), ("single", "[\"z\"]", "[[\"z\"]]"), ("empty", "[\"\"]", "[[]]"), ("all", "[\"aaa\"]", "[[\"a\",\"a\",\"a\"],[\"a\",\"aa\"],[\"aa\",\"a\"],[\"aaa\"]]")]
        )
    ]

    // MARK: Dynamic Programming

    private static let dynamicProgramming = [
        problem(
            id: "dp.min-climbing-cost", title: "Minimum Climbing Cost", difficulty: .easy, minutes: 30,
            why: "It introduces rolling state where each position depends on only two earlier answers.",
            prompt: "You may begin on stair 0 or stair 1 without paying for any earlier stair. Pay cost[i] whenever you step on stair i, then move one or two stairs. Moving from either of the final two stairs to the position just beyond the list finishes the climb without an additional cost. Return the minimum total paid.",
            signature: "minimum_climbing_cost(cost)", exampleInput: "[10, 15, 20]", exampleOutput: "15",
            constraints: ["2 ≤ len(cost) ≤ 100,000", "Costs are nonnegative"],
            hints: ["The cost to reach a step comes from one or two positions back.", "You only need the previous two minimum totals.", "The top can be reached from either of the final two stairs."],
            solution: """
            def minimum_climbing_cost(cost):
                two_back = one_back = 0
                for stair_cost in cost:
                    current = stair_cost + min(two_back, one_back)
                    two_back, one_back = one_back, current
                return min(two_back, one_back)
            """,
            explanation: "Before each stair, the two rolling values are the cheapest totals for the two reachable predecessors. The final top similarly chooses either predecessor.",
            time: "O(n)", space: "O(1)",
            tests: [("small", "[[10,15,20]]", "15"), ("long", "[[1,100,1,1,1,100,1,1,100,1]]", "6"), ("zeros", "[[0,0]]", "0"), ("two", "[[5,7]]", "5")]
        ),
        problem(
            id: "dp.decode-ways", title: "Decode Digit Messages", difficulty: .medium, minutes: 40,
            why: "It demonstrates DP transitions with one-character and two-character choices.",
            prompt: "Digits map 1→A through 26→Z. Return the number of valid decodings of a nonempty digit string; 0 cannot decode alone.",
            signature: "decode_ways(digits)", exampleInput: "\"226\"", exampleOutput: "3",
            constraints: ["digits is nonempty and contains 0-9", "The answer fits in an integer"],
            hints: ["Count decodings ending just before the current position.", "A nonzero current digit extends every decoding one step back.", "A two-digit value from 10 through 26 extends every decoding two steps back."],
            solution: """
            def decode_ways(digits):
                two_back, one_back = 1, 0 if digits[0] == "0" else 1
                for index in range(1, len(digits)):
                    current = 0
                    if digits[index] != "0":
                        current += one_back
                    pair = int(digits[index - 1:index + 1])
                    if 10 <= pair <= 26:
                        current += two_back
                    two_back, one_back = one_back, current
                return one_back
            """,
            explanation: "Every complete decoding ends with either one valid digit or one valid two-digit code. Those disjoint cases add their preceding counts.",
            time: "O(n)", space: "O(1)",
            tests: [("three", "[\"226\"]", "3"), ("zero", "[\"06\"]", "0"), ("pair", "[\"12\"]", "2"), ("embedded zero", "[\"2101\"]", "1")]
        ),
        problem(
            id: "dp.longest-palindrome-subsequence", title: "Longest Palindromic Subsequence", difficulty: .medium, minutes: 50,
            why: "Interval DP makes decisions using smaller inner substrings and neighboring ranges.",
            prompt: "Return the length of the longest subsequence of text that reads the same forward and backward.",
            signature: "longest_palindrome_subsequence(text)", exampleInput: "\"bbbab\"", exampleOutput: "4",
            constraints: ["0 ≤ len(text) ≤ 1,000", "A subsequence need not be contiguous"],
            hints: ["A palindrome can pair equal characters at both ends.", "If ends differ, discard one end and keep the better result.", "Fill start indices backward so inner ranges are already known."],
            solution: """
            def longest_palindrome_subsequence(text):
                if not text:
                    return 0
                size = len(text)
                table = [[0] * size for _ in range(size)]
                for start in range(size - 1, -1, -1):
                    table[start][start] = 1
                    for end in range(start + 1, size):
                        if text[start] == text[end]:
                            table[start][end] = 2 + (table[start + 1][end - 1] if end > start + 1 else 0)
                        else:
                            table[start][end] = max(table[start + 1][end], table[start][end - 1])
                return table[0][size - 1]
            """,
            explanation: "Equal ends can safely wrap the best inner subsequence. Unequal ends cannot both participate together, so the better one-end-discarded range is optimal.",
            time: "O(n²)", space: "O(n²)",
            tests: [("classic", "[\"bbbab\"]", "4"), ("pair", "[\"cbbd\"]", "2"), ("empty", "[\"\"]", "0"), ("unique", "[\"abc\"]", "1")]
        )
    ]

    // MARK: Greedy

    private static let greedy = [
        problem(
            id: "greedy.stock-profit", title: "Best Single Trade", difficulty: .easy, minutes: 20,
            why: "Maintaining the best prior choice is the simplest greedy optimization pattern.",
            prompt: "Given daily prices, buy once before selling once. Return the maximum profit, or 0 when no profitable trade exists.",
            signature: "best_trade_profit(prices)", exampleInput: "[7, 1, 5, 3, 6, 4]", exampleOutput: "5",
            constraints: ["0 ≤ len(prices) ≤ 100,000", "Prices are nonnegative"],
            hints: ["For each selling day, only the cheapest earlier price matters.", "Track that minimum while scanning.", "Compare today's possible profit with the best seen."],
            solution: """
            def best_trade_profit(prices):
                minimum = float("inf")
                best = 0
                for price in prices:
                    minimum = min(minimum, price)
                    best = max(best, price - minimum)
                return best
            """,
            explanation: "The cheapest prefix price dominates every more expensive earlier buy. Evaluating each price as a sale therefore considers the best trade ending that day.",
            time: "O(n)", space: "O(1)",
            tests: [("profit", "[[7,1,5,3,6,4]]", "5"), ("falling", "[[7,6,4,3,1]]", "0"), ("two", "[[2,9]]", "7"), ("empty", "[[]]", "0")]
        ),
        problem(
            id: "greedy.candy", title: "Minimum Rewards", difficulty: .hard, minutes: 50,
            why: "Two directional greedy passes satisfy local constraints from both neighbors.",
            prompt: "Give each child at least one reward. A child with a higher rating than an adjacent child must receive more rewards. Return the minimum total.",
            signature: "minimum_rewards(ratings)", exampleInput: "[1, 0, 2]", exampleOutput: "5",
            constraints: ["ratings is nonempty", "Ratings are integers"],
            hints: ["Start everyone with one reward.", "A left-to-right pass satisfies comparisons with the left neighbor.", "A right-to-left pass satisfies the right neighbor using max so earlier work is preserved."],
            solution: """
            def minimum_rewards(ratings):
                rewards = [1] * len(ratings)
                for index in range(1, len(ratings)):
                    if ratings[index] > ratings[index - 1]:
                        rewards[index] = rewards[index - 1] + 1
                for index in range(len(ratings) - 2, -1, -1):
                    if ratings[index] > ratings[index + 1]:
                        rewards[index] = max(rewards[index], rewards[index + 1] + 1)
                return sum(rewards)
            """,
            explanation: "Each directional pass establishes one side's inequalities with minimum increments. max in the reverse pass preserves already-required larger rewards.",
            time: "O(n)", space: "O(n)",
            tests: [("valley", "[[1,0,2]]", "5"), ("plateau", "[[1,2,2]]", "4"), ("single", "[[5]]", "1"), ("mountain", "[[1,2,3,2,1]]", "9")]
        ),
        problem(
            id: "greedy.task-scheduler", title: "Task Cooling Schedule", difficulty: .medium, minutes: 45,
            why: "The most frequent task determines a lower-bound frame that other tasks can fill.",
            prompt: "Tasks are capital letters. Identical tasks need at least cooldown other intervals between executions. Return the minimum total intervals, including idle time.",
            signature: "task_schedule_length(tasks, cooldown)", exampleInput: "[\"A\",\"A\",\"A\",\"B\",\"B\",\"B\"], 2", exampleOutput: "8",
            constraints: ["cooldown ≥ 0", "0 ≤ len(tasks) ≤ 100,000"],
            hints: ["Count task frequencies.", "Place the most frequent tasks as separators of a frame.", "The frame size is (max_count - 1) * (cooldown + 1) plus the number of tasks tied for maximum."],
            solution: """
            def task_schedule_length(tasks, cooldown):
                if not tasks:
                    return 0
                counts = {}
                for task in tasks:
                    counts[task] = counts.get(task, 0) + 1
                maximum = max(counts.values())
                tied = sum(1 for count in counts.values() if count == maximum)
                frame = (maximum - 1) * (cooldown + 1) + tied
                return max(len(tasks), frame)
            """,
            explanation: "All but the final copies of maximum-frequency tasks create mandatory gaps. Other tasks fill those gaps; if they overflow, the raw task count becomes the answer.",
            time: "O(n)", space: "O(k)",
            tests: [("idle", "[[\"A\",\"A\",\"A\",\"B\",\"B\",\"B\"],2]", "8"), ("none", "[[\"A\",\"A\",\"B\"],0]", "3"), ("filled", "[[\"A\",\"A\",\"A\",\"B\",\"B\",\"B\"],1]", "6"), ("empty", "[[],3]", "0")]
        )
    ]

    // MARK: Advanced Synthesis

    private static let advanced = [
        problem(
            id: "advanced.kth-largest", title: "Kth Largest Value", difficulty: .medium, minutes: 30,
            why: "Order-statistic questions force you to separate rank from original position.",
            prompt: "Return the kth largest value in an unsorted array, counting duplicates as separate positions.",
            signature: "kth_largest(numbers, k)", exampleInput: "[3, 2, 1, 5, 6, 4], 2", exampleOutput: "5",
            constraints: ["1 ≤ k ≤ len(numbers)", "Values may repeat"],
            hints: ["A sorted copy gives a simple baseline solution.", "Descending rank k corresponds to ascending index len(numbers) - k.", "Do not remove duplicates."],
            solution: """
            def kth_largest(numbers, k):
                ordered = sorted(numbers)
                return ordered[len(ordered) - k]
            """,
            explanation: "Sorting places every occurrence in rank order. Translating kth-from-the-end to a zero-based index returns the requested value directly.",
            time: "O(n log n)", space: "O(n)",
            tests: [("basic", "[[3,2,1,5,6,4],2]", "5"), ("duplicates", "[[3,2,3,1,2,4,5,5,6],4]", "4"), ("first", "[[7,1],1]", "7"), ("last", "[[7,1],2]", "1")]
        ),
        problem(
            id: "advanced.merge-sorted-lists", title: "Merge Many Sorted Lists", difficulty: .hard, minutes: 50,
            why: "It combines multiple ordered frontiers and makes the value of a priority queue concrete.",
            prompt: "Merge several ascending integer lists into one ascending list. Empty lists are allowed.",
            signature: "merge_sorted_lists(lists)", exampleInput: "[[1,4,5],[1,3,4],[2,6]]", exampleOutput: "[1,1,2,3,4,4,5,6]",
            constraints: ["Every inner list is ascending", "Total values ≤ 100,000"],
            hints: ["Only the current front value of each list can be next.", "Track one index per list.", "Repeatedly choose the smallest available front and advance that list."],
            solution: """
            def merge_sorted_lists(lists):
                positions = [0] * len(lists)
                result = []
                while True:
                    best_list = -1
                    best_value = None
                    for index in range(len(lists)):
                        if positions[index] < len(lists[index]):
                            value = lists[index][positions[index]]
                            if best_list == -1 or value < best_value:
                                best_list = index
                                best_value = value
                    if best_list == -1:
                        return result
                    result.append(best_value)
                    positions[best_list] += 1
            """,
            explanation: "Each list contributes only its smallest unmerged value as a candidate. Choosing the smallest frontier preserves global ordering before advancing that source.",
            time: "O(totalValues · numberOfLists)", space: "O(numberOfLists) excluding output",
            tests: [("classic", "[[[1,4,5],[1,3,4],[2,6]]]", "[1,1,2,3,4,4,5,6]"), ("empty lists", "[[[],[1],[]]]", "[1]"), ("all empty", "[[[],[]]]", "[]"), ("negative", "[[[-3,2],[-2,4]]]", "[-3,-2,2,4]")]
        ),
        problem(
            id: "advanced.longest-valid-parentheses", title: "Longest Valid Parentheses", difficulty: .hard, minutes: 55,
            why: "A sentinel stack turns unmatched boundaries into direct span lengths.",
            prompt: "Return the length of the longest contiguous substring of balanced parentheses.",
            signature: "longest_valid_parentheses(text)", exampleInput: "\")()())\"", exampleOutput: "4",
            constraints: ["text contains only ( and )", "0 ≤ len(text) ≤ 100,000"],
            hints: ["Store indices rather than characters.", "Begin with sentinel index -1 as the boundary before a valid span.", "On ), pop; if the stack empties, push the new invalid boundary, otherwise measure from the top."],
            solution: """
            def longest_valid_parentheses(text):
                stack = [-1]
                best = 0
                for index, character in enumerate(text):
                    if character == "(":
                        stack.append(index)
                    else:
                        stack.pop()
                        if not stack:
                            stack.append(index)
                        else:
                            best = max(best, index - stack[-1])
                return best
            """,
            explanation: "The stack top after a matched close is the last unmatched boundary before the current valid suffix. Their index difference is its length.",
            time: "O(n)", space: "O(n)",
            tests: [("mixed", "[\")()())\"]", "4"), ("prefix", "[\"(()\"]", "2"), ("nested", "[\"()(())\"]", "6"), ("empty", "[\"\"]", "0")]
        )
    ]
}
