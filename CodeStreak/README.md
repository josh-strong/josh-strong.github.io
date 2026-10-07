# CodeStreak

CodeStreak is an offline, multiplatform SwiftUI learning app for becoming consistent and capable at interview-style algorithm problems. It combines a strict pattern-based curriculum, on-device Python execution, progressive hints, notes, reference solutions, spaced review, daily streaks, reminders, and encrypted nearby sync.

The problem set is original LeetCode-style educational content; it does not copy LeetCode’s proprietary statements or solution library.

## Learning experience

The app contains 174 genuinely distinct problems across two independently unlocked tracks: 154 general algorithm problems in 18 ordered modules, plus a 20-problem ML/deep-learning interview lab in four grouped sets. Repetition is handled by scheduled retrieval reviews; practice modes are never counted as new problems merely because their labels change:

1. Arrays & Hashing
2. Two Pointers
3. Sliding Window
4. Stacks
5. Linked Lists
6. Binary Search
7. Intervals
8. Trees
9. Queues & Heaps
10. Tries & String Algorithms
11. Graphs
12. Union-Find & Connectivity
13. Backtracking
14. Bits & Mathematics
15. Dynamic Programming
16. Greedy Reasoning
17. Advanced Synthesis
18. Advanced Data Structures

The parallel ML / Deep Learning Interview Lab groups longer, locally executable Python builds into tensor and numerical foundations, training mechanics, neural architecture primitives, and research engineering/evaluation. It begins independently of the algorithm path and progresses from stable softmax and matrix operations through hand-derived backpropagation, Adam, convolution, scaled/causal/multi-head attention, beam search, clustering, batching, and metrics.

ML problems include a conventional PyTorch comparison when a framework implementation adds useful production context. The explicitly from-scratch matrix-multiplication exercise remains dependency-free throughout. Attention exercises additionally show an optional [einops](https://einops.rocks/) `einsum` formulation beside the normal PyTorch `matmul` version, because named head, token, and feature axes can make those contractions easier to audit. Framework examples remain separate from the plain-Python oracle used by CodeStreak's offline tests because PyTorch and einops are not bundled into the iPhone learning runtime.

Each module now includes a dedicated pattern mini-lesson: a mental model, recognition questions, a solving playbook, common traps, and a realistic complexity target. A compact version also appears inside every problem so the learner practises choosing and justifying the pattern before writing code. Only the next new problem is unlocked, while solved problems remain available for review. The difficulty progresses from easy to medium and hard without random jumping between unrelated techniques.

Every workspace includes:

- an original statement, constraints, example, and pattern motivation;
- a persistent Python starter and code editor;
- four or more on-device tests with named inputs, expected output, the learner's return value, and useful Python-error context;
- progressive hints revealed one at a time;
- a focus coach that changes guidance after 10 and 20 minutes;
- persistent learning notes;
- an intentional reveal before the reference solution;
- a reference explanation plus time and space complexity;
- automatic daily-practice credit when all tests pass.

On Mac, the entire interface and Python editor can be resized with `⌘+` and `⌘−`; `⌘0` returns to the system text size. The adjustment is remembered locally, respects the system size as its baseline, and is also available through Appearance settings on Mac and iPhone.

The Today tab prioritizes due retrieval reviews before new material. A first solve returns after one day; successful reviews then use approximately 3, 7, 14, 30, and 60-day intervals.

The Learning Guide tab turns the research into a practical 30-minute problem loop, a controlled hint ladder, blocked-then-interleaved pattern practice, a spaced-review rhythm, and an error-log template. It also links directly to the research records so the rationale is inspectable rather than presented as folklore.

## Why the learning design works this way

- Retrieval practice improves durable learning more than passive restudy: [Karpicke & Blunt, 2011](https://pubmed.ncbi.nlm.nih.gov/21252317/).
- Distributed practice has a robust retention advantage: [Cepeda et al., 2006](https://pubmed.ncbi.nlm.nih.gov/16719566/).
- Interleaving helps learners discriminate between categories: [Kornell & Bjork, 2008](https://pubmed.ncbi.nlm.nih.gov/18578849/).
- Worked examples and faded guidance help novices form a schema before independent problem solving. CodeStreak implements this with pattern cues, examples, staged hints, reference comparison, and progressively delayed reviews.
- Self-explanation connects solution steps to underlying principles: [Chi et al., 1989](https://doi.org/10.1207/s15516709cog1302_1).
- Worked examples designed for programming can particularly support novices, especially alongside explanation: [Vieira, Yan & Magana, 2015](https://jocse.org/articles/6/1/1/).

## On-device Python

Solutions are written in Python 3 syntax and run locally on the Mac or iPhone CPU. CodeStreak bundles the MIT-licensed [Skulpt](https://skulpt.org/) learning runtime and loads it inside Apple’s JavaScriptCore framework. No code, tests, or output are sent to a server.

The runner supports the Python features used by typical data-structure and algorithm practice: functions, recursion, lists, dictionaries, sets, tuples, loops, comprehensions, lambdas, sorting, slicing, numeric/string operations, and the included pure-Python standard-library modules. Native CPython extension packages such as NumPy are intentionally out of scope. Executions receive a 2.5-second guard and drafts are limited to 50,000 characters.

Apple permits executable code in educational coding apps under the conditions in App Review Guideline 2.5.2. Python’s official iOS documentation also explains that Python must be embedded rather than assumed to exist as a system executable. CodeStreak uses a bundled learning interpreter so behavior is consistent on both platforms.

Third-party notice: `CodeStreak/Resources/Skulpt/LICENSE` contains the bundled runtime’s MIT license.

## Progress and consistency

The Progress tab shows:

- total curriculum completion;
- seven-day problem activity;
- easy/medium/hard balance;
- progress through each algorithm pattern and ML interview set;
- test runs, hints used, and completed reviews.

The original daily streak remains. A day can be marked manually after 15 minutes of practice, and passing a problem marks it automatically. The streak calculator preserves the today/yesterday grace rule and uses calendar-safe date arithmetic.

The daily new-problem target is configurable as one or two problems. Local notification reminders remain optional and are requested only when enabled.

## Home Screen and Lock Screen widgets

CodeStreak includes a WidgetKit extension with five iPhone layouts:

- small and medium Home Screen widgets;
- inline, circular, and rectangular Lock Screen widgets.

Depending on the available space, the widget shows today's completion state, the current streak, solved problems out of the 174-problem curriculum, progress, due reviews, and the next problem. Passing a solution, manually changing today's completion, receiving a nearby sync, or reopening the app refreshes the shared snapshot. The widget also refreshes just after midnight so yesterday's completion is not shown as today's.

The Home Screen designs emphasize the next consistency action—start a due review or solve today's problem—rather than making the slow-moving curriculum total dominant. Their color state changes after practice, streak messaging advances from “make it day N” to “momentum secured,” and each medium widget shows a nearby 25-problem milestone. Lock Screen versions use the same daily-momentum language in a compact monochrome layout.

To add it on iPhone after installing and opening the latest build once:

1. **Home Screen:** touch and hold an empty area, tap **Edit** > **Add Widget**, search for **CodeStreak**, choose small or medium, then tap **Add Widget**.
2. **Lock Screen:** touch and hold the Lock Screen, tap **Customize** > **Lock Screen**, tap the widget area below the clock, choose **CodeStreak**, and select the inline, circle, or rectangle design.

The app and widget share only a small read-only progress summary through the `group.com.jstrong.CodeStreak` App Group. Python code and notes are not copied into the widget store.

## Storage and nearby sync

SwiftData stores two models:

- `CompletionRecord`: daily practice state, including undo tombstones and conflict metadata;
- `LearningProgressRecord`: Python draft, notes, attempts, hint/reference state, solve time, review schedule, and conflict metadata for one problem.

Nearby sync uses Multipeer Connectivity with required encryption. It merges streak history and learning records directly between a paired iPhone and Mac. Both apps must be open; no account, backend, or internet access is involved. For each record, the newest edit wins with a deterministic device-ID tie-breaker.

### Pairing

1. Install and open the same CodeStreak build on the Mac and iPhone.
2. Tap **Enable and sync** on both devices.
3. Allow Local Network access on iPhone.
4. Confirm the matching six-digit code.
5. Wait for both devices to show **Up to date** or **Synced**.

Future syncs require opening both apps and pressing **Sync nearby** on either device.

## Architecture

- **Models:** curriculum value types plus SwiftData completion and learning-progress records.
- **Services:** pure streak and plan engines, Python execution, SwiftData mutations, reminders, curriculum content, and nearby sync/merge.
- **Views:** Today, Learning Path, Pattern Mini-Lessons, Problem Workspace, Progress, Learning Guide, History, and Settings.
- **Resources:** the bundled offline Python learning runtime and its license.

The Xcode target is shared across iOS and macOS, uses Swift 6 strict concurrency, and has no network-time package resolution.

## Requirements

- iOS 17 or later
- macOS 14 or later
- Xcode with the iOS platform component
- For a physical iPhone: an Apple Account configured in Xcode and Developer Mode when requested

## Build and run

1. Open `CodeStreak.xcodeproj`.
2. Select the **CodeStreak** scheme.
3. Choose **My Mac**, a simulator, or a connected iPhone.
4. Press **Run** (`⌘R`).

For a personal iPhone, automatic signing must cover both the **CodeStreak** and **CodeStreakWidgets** targets. Both targets must use the same team and the `group.com.jstrong.CodeStreak` App Group. The checked-in project is already configured for the current development team.

Build macOS without signing:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild -project CodeStreak.xcodeproj \
  -scheme CodeStreak \
  -destination 'platform=macOS,arch=arm64' \
  CODE_SIGNING_ALLOWED=NO build
```

Run the full app test suite:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild -project CodeStreak.xcodeproj \
  -scheme CodeStreak \
  -destination 'platform=macOS,arch=arm64' \
  -parallel-testing-enabled NO test
```

Run the portable curriculum and calendar tests:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

## Test coverage

The suite verifies:

- every bundled Python reference solution against every built-in test case;
- invalid Python and wrong-answer reporting;
- curriculum completeness, unique IDs, hints, tests, difficulty coverage, all 18 pattern mini-lessons, and research-link integrity;
- strict next-problem unlocking and spaced-review scheduling;
- learning draft/note synchronization;
- completion duplication, undo, re-completion, sync conflicts, and tombstones;
- streak behavior across gaps, time zones, DST, leap days, months, and years.
- widget completion, progress clamping, and streak-expiry behavior.

## Privacy

- Code and notes stay on the user’s devices.
- No account, analytics, advertising, tracking, or telemetry.
- No external code-execution service.
- No problem or solution data is downloaded at runtime.
- Nearby sync sends encrypted progress only to the explicitly paired device.
- Notification permission is used only for the reminder chosen by the user.

## Known limitations

- Nearby sync requires both apps to be open and nearby.
- The Python learning runtime is intentionally smaller than desktop CPython and does not include native extension packages.
- A repeating notification may still appear after practice is completed that day.
- Personal Team installations may require periodic rebuilding or re-signing.
