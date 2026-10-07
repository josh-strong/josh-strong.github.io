import Foundation

/// A second, independently unlocked curriculum for research scientist and
/// research engineer interviews. The implementations deliberately use plain
/// Python lists so the tensor mechanics remain visible and run fully offline.
enum MLInterviewCurriculum {
    static let modules: [CurriculumModule] = [
        CurriculumModule(
            id: "ml-tensor-foundations",
            title: "Tensor & Numerical Foundations",
            symbol: "square.grid.3x3.fill",
            summary: "Translate vectorized equations into stable, shape-correct Python.",
            recognitionCues: [
                "An equation must become explicit tensor loops",
                "Large logits can overflow naive exponentials",
                "Every dimension needs a precise semantic meaning"
            ],
            problems: [matrixMultiply, stableSoftmax, batchCrossEntropy, linearForward, meanPoolEmbeddings]
        ),
        CurriculumModule(
            id: "ml-training-mechanics",
            title: "Training Mechanics",
            symbol: "waveform.path.ecg.rectangle.fill",
            summary: "Implement normalization, regularization, backpropagation, and optimization.",
            recognitionCues: [
                "Training and inference use different statistics or scaling",
                "A forward equation must be differentiated by hand",
                "Optimizer state changes on every update"
            ],
            problems: [layerNorm, batchNormTrain, invertedDropout, mlpBackward, adamStep]
        ),
        CurriculumModule(
            id: "ml-neural-architectures",
            title: "Neural Architecture Primitives",
            symbol: "point.3.filled.connected.trianglepath.dotted",
            summary: "Build convolution and attention from their mathematical definitions.",
            recognitionCues: [
                "Local receptive fields slide over spatial data",
                "Queries score keys before mixing values",
                "Masks change which positions a model may use"
            ],
            problems: [validConvolution, maxPooling, scaledAttention, causalAttention, multiHeadAttention]
        ),
        CurriculumModule(
            id: "ml-research-engineering",
            title: "Research Engineering & Evaluation",
            symbol: "chart.xyaxis.line",
            summary: "Code experimental plumbing and evaluation logic that can silently invalidate results.",
            recognitionCues: [
                "An evaluation metric needs explicit edge-case policy",
                "Variable-length or microbatched data needs correct weighting",
                "Approximate decoding or iterative estimation needs deterministic rules"
            ],
            problems: [kMeansStep, macroF1, beamSearch, padSequences, accumulateGradients]
        )
    ]

    static let allProblems = modules.flatMap(\.problems)

    static let researchSources: [LearningResearchSource] = [
        source(
            id: "openai-interview-guide",
            title: "OpenAI interview guide",
            authors: "OpenAI",
            takeaway: "Engineering interviews assess solution design, code quality, performance, and testing—not only whether a sample output is correct.",
            url: "https://openai.com/interview-guide/"
        ),
        source(
            id: "deepmind-research-engineering",
            title: "Research engineering at Google DeepMind",
            authors: "Google DeepMind",
            takeaway: "Research engineers bridge theory and implementation, optimize frontier models, and build reliable systems around experiments.",
            url: "https://deepmind.google/careers/"
        ),
        source(
            id: "cs224n",
            title: "CS224N: NLP with Deep Learning",
            authors: "Stanford University",
            takeaway: "The current sequence connects tensor derivatives, self-attention and Transformers, then benchmarking and evaluation.",
            url: "https://web.stanford.edu/class/cs224n/index.html"
        ),
        source(
            id: "cs231n",
            title: "CS231n assignments",
            authors: "Stanford University",
            takeaway: "Classic interview-ready implementations include softmax, neural nets, normalization, dropout, convolution, and sequence models.",
            url: "https://cs231n.stanford.edu/2021/assignments.html"
        ),
        source(
            id: "pytorch-sdpa",
            title: "Scaled dot-product attention tutorial",
            authors: "PyTorch",
            takeaway: "Use the reference equation to connect a readable implementation to optimized fused attention kernels and causal masking.",
            url: "https://docs.pytorch.org/tutorials/intermediate/scaled_dot_product_attention_tutorial"
        )
    ]

    // MARK: Tensor foundations

    private static let matrixMultiply = problem(
        id: "ml.matrix-multiply", title: "Matrix Multiplication from Scratch", difficulty: .medium, minutes: 40,
        why: "Shape reasoning and dot products sit underneath linear layers, attention projections, and nearly every tensor program.",
        prompt: "Implement matrix multiplication from first principles for two rectangular matrices stored as nested Python lists. If left has shape m × k and right has shape k × n, return a new m × n matrix. Do not mutate either input and do not delegate the multiplication to NumPy, PyTorch, einsum, or another matrix-multiplication helper.",
        signature: "matrix_multiply(left, right)",
        examples: [.init(input: "left = [[1, 2], [3, 4]], right = [[5], [6]]", output: "[[17], [39]]", explanation: "Each output value is the dot product of one row of left and one column of right.")],
        constraints: ["Matrices are non-empty and rectangular", "len(left[0]) == len(right)", "Use explicit Python iteration for the dot products—no NumPy, PyTorch, einsum, or matmul helper", "Return a newly allocated nested list"],
        hints: ["Name the dimensions m, k, and n before writing a loop.", "One output cell combines left[row][inner] with right[inner][column].", "Use three loops or pre-transpose right for easier column access."],
        solution: """
        def matrix_multiply(left, right):
            rows = len(left)
            inner = len(right)
            columns = len(right[0])
            output = [[0 for _ in range(columns)] for _ in range(rows)]
            for row in range(rows):
                for shared in range(inner):
                    value = left[row][shared]
                    for column in range(columns):
                        output[row][column] += value * right[shared][column]
            return output
        """,
        explanation: "Output[row][column] is the sum over the shared dimension. Looping through the shared value before columns also reuses one left-side value across a whole output row.",
        time: "O(mkn)", space: "O(mn) for the required output",
        tests: derivedTests([
            ("square by column", "[[[1,2],[3,4]],[[5],[6]]]"),
            ("rectangular", "[[[1,0,-1],[2,3,1]],[[2,1],[1,0],[4,-2]]]"),
            ("one by one", "[[[7]],[[8]]]"),
            ("identity", "[[[3,-2],[5,4]],[[1,0],[0,1]]]")
        ])
    )

    private static let stableSoftmax = problem(
        id: "ml.stable-softmax", title: "Numerically Stable Softmax", difficulty: .medium, minutes: 35,
        why: "A mathematically correct formula can still fail in finite-precision arithmetic; stable logits handling is a core ML implementation habit.",
        prompt: "Convert a non-empty vector of logits into probabilities using softmax. Subtract the maximum logit before exponentiating so very large values do not overflow. Return one probability per logit; the values must sum to 1 within floating-point tolerance.",
        signature: "stable_softmax(logits)",
        examples: [.init(input: "[1.0, 2.0, 3.0]", output: "approximately [0.090031, 0.244728, 0.665241]")],
        constraints: ["1 ≤ len(logits) ≤ 10,000", "Every logit is a finite number", "Use math.exp; do not use NumPy"],
        hints: ["Softmax is invariant to adding or subtracting the same constant from every logit.", "Use max(logits) as the shift.", "Normalize the exponentials by their sum."],
        solution: """
        def stable_softmax(logits):
            import math
            shift = max(logits)
            exponentials = [math.exp(value - shift) for value in logits]
            total = sum(exponentials)
            return [value / total for value in exponentials]
        """,
        explanation: "After subtracting the maximum, every exponent is at most zero, so exp cannot overflow. The common shift cancels between numerator and denominator and does not change the distribution.",
        time: "O(n)", space: "O(n)",
        tests: derivedTests([
            ("ordinary logits", "[[1.0,2.0,3.0]]"),
            ("large positive logits", "[[1000.0,1001.0,999.0]]"),
            ("large negative logits", "[[-1000.0,-1000.0]]"),
            ("single class", "[[42.0]]")
        ])
    )

    private static let batchCrossEntropy = problem(
        id: "ml.batch-cross-entropy", title: "Stable Batch Cross-Entropy", difficulty: .medium, minutes: 45,
        why: "Research code frequently works directly with logits, where a stable log-sum-exp avoids both overflow and log(0).",
        prompt: "Given a batch of class-logit rows and one zero-based correct-class label per row, return the mean multiclass cross-entropy directly from the logits. For row z and label y, the loss is log(sum(exp(z))) - z[y]. Use a numerically stable log-sum-exp and do not first form rounded probabilities.",
        signature: "batch_cross_entropy(logits, labels)",
        examples: [.init(input: "logits = [[2.0, 1.0, 0.0]], labels = [0]", output: "approximately 0.407606")],
        constraints: ["The batch and class dimensions are non-empty", "Every row has the same class count", "len(labels) == len(logits) and every label is valid"],
        hints: ["Compute a separate maximum for each row.", "log(sum(exp(row))) = maximum + log(sum(exp(value - maximum))).", "Accumulate maximum + log_shifted_sum - correct_logit, then divide by batch size."],
        solution: """
        def batch_cross_entropy(logits, labels):
            import math
            total_loss = 0.0
            for row, label in zip(logits, labels):
                maximum = max(row)
                shifted_sum = sum(math.exp(value - maximum) for value in row)
                total_loss += maximum + math.log(shifted_sum) - row[label]
            return total_loss / len(logits)
        """,
        explanation: "The log-sum-exp rewrite preserves the exact expression while keeping its exponentials bounded. Subtracting the correct-class logit gives negative log likelihood without ever computing log of a near-zero probability.",
        time: "O(batch · classes)", space: "O(1) beyond iteration",
        tests: derivedTests([
            ("confident correct class", "[[[2.0,1.0,0.0]],[0]]"),
            ("two examples", "[[[1.0,3.0],[2.0,-1.0]],[1,0]]"),
            ("large equal logits", "[[[1000.0,1000.0],[999.0,1001.0]],[0,1]]"),
            ("one class", "[[[7.0],[-4.0]],[0,0]]")
        ])
    )

    private static let linearForward = problem(
        id: "ml.linear-forward", title: "Batched Linear Layer", difficulty: .medium, minutes: 45,
        why: "Linear projections recur in MLPs, classifiers, and every query/key/value projection in a Transformer.",
        prompt: "Implement a batched linear layer y = x Wᵀ + b using nested lists. batch has shape batch_size × input_features. weights has shape output_features × input_features—one row per output neuron—and bias has length output_features. Return batch_size × output_features without mutating inputs.",
        signature: "linear_forward(batch, weights, bias)",
        examples: [.init(input: "batch = [[1, 2]], weights = [[3, 4], [-1, 2]], bias = [1, 0]", output: "[[12, 3]]")],
        constraints: ["All tensors are non-empty and shape-compatible", "Weights are stored output-feature first", "Do not use NumPy"],
        hints: ["Each example is multiplied by every weight row.", "Initialize the dot product from that output neuron's bias.", "Reuse your matrix-multiplication reasoning, but notice the transpose implied by the weight layout."],
        solution: """
        def linear_forward(batch, weights, bias):
            output = []
            for example in batch:
                row = []
                for neuron, offset in zip(weights, bias):
                    value = offset
                    for feature, weight in zip(example, neuron):
                        value += feature * weight
                    row.append(value)
                output.append(row)
            return output
        """,
        explanation: "Each weight row describes one output feature. Taking its dot product with an example and adding the matching bias implements x Wᵀ + b without materializing the transpose.",
        time: "O(batch · input · output)", space: "O(batch · output)",
        tests: derivedTests([
            ("one example", "[[[1,2]],[[3,4],[-1,2]],[1,0]]"),
            ("two examples", "[[[1,0,-1],[2,3,1]],[[2,1,0],[0,-1,4]],[0.5,-2.0]]"),
            ("single feature", "[[[2],[-3]],[[4]],[1]]"),
            ("zero weights use bias", "[[[5,6]],[[0,0],[0,0]],[3,-4]]")
        ])
    )

    private static let meanPoolEmbeddings = problem(
        id: "ml.mean-pool-embeddings", title: "Masked Mean Embedding Pool", difficulty: .medium, minutes: 45,
        why: "Variable-length batches require masks; silently averaging padding tokens is a common source of incorrect representations.",
        prompt: "Map each token ID to its embedding and return the mean embedding for each token sequence, excluding every occurrence of pad_id. token_batches is a rectangular padded batch and embedding_table[token_id] is a vector. If a row contains only padding, return a zero vector of the embedding dimension.",
        signature: "mean_pool_embeddings(token_batches, embedding_table, pad_id)",
        examples: [.init(input: "tokens = [[1, 2, 0]], table = [[0,0], [2,0], [0,4]], pad_id = 0", output: "[[1, 2]]")],
        constraints: ["The embedding table is non-empty and rectangular", "Every token ID is a valid table index", "Padding may appear anywhere in a row"],
        hints: ["Maintain a vector sum and a non-padding count for each row.", "Do not divide by the padded sequence length.", "Handle count == 0 explicitly."],
        solution: """
        def mean_pool_embeddings(token_batches, embedding_table, pad_id):
            dimension = len(embedding_table[0])
            output = []
            for tokens in token_batches:
                total = [0.0] * dimension
                count = 0
                for token in tokens:
                    if token == pad_id:
                        continue
                    count += 1
                    for index in range(dimension):
                        total[index] += embedding_table[token][index]
                if count == 0:
                    output.append([0.0] * dimension)
                else:
                    output.append([value / count for value in total])
            return output
        """,
        explanation: "The mask changes both the sum and its denominator. Treating an all-padding example explicitly avoids division by zero and gives a deterministic neutral representation.",
        time: "O(batch · sequence · dimension)", space: "O(batch · dimension)",
        tests: derivedTests([
            ("trailing padding", "[[[1,2,0]],[[0,0],[2,0],[0,4]],0]"),
            ("mixed row lengths", "[[[1,0,2],[2,2,0]],[[9,9],[1,3],[5,-1]],0]"),
            ("all padding", "[[[0,0]],[[0,0,0],[1,2,3]],0]"),
            ("padding in middle", "[[[1,0,1]],[[8,8],[2,4]],0]")
        ])
    )

    // MARK: Training mechanics

    private static let layerNorm = problem(
        id: "ml.layer-norm", title: "Layer Normalization Forward Pass", difficulty: .medium, minutes: 50,
        why: "Layer normalization is central to Transformers and tests whether you understand normalization axes rather than only library calls.",
        prompt: "Normalize each row independently across its feature dimension, then apply per-feature scale gamma and shift beta. For each row use its population variance: mean((x - mean)²). Return gamma[j] * (x[j] - mean) / sqrt(variance + epsilon) + beta[j].",
        signature: "layer_norm(batch, gamma, beta, epsilon)",
        examples: [.init(input: "batch = [[1, 2, 3]], gamma = [1,1,1], beta = [0,0,0]", output: "approximately [[-1.224745, 0, 1.224745]]")],
        constraints: ["batch is non-empty and rectangular", "len(gamma) == len(beta) == feature count", "epsilon > 0"],
        hints: ["Layer norm computes a different mean and variance for every row.", "Use population variance, so divide by the feature count.", "Apply gamma and beta only after normalization."],
        solution: """
        def layer_norm(batch, gamma, beta, epsilon):
            import math
            output = []
            for row in batch:
                mean = sum(row) / len(row)
                variance = sum((value - mean) ** 2 for value in row) / len(row)
                denominator = math.sqrt(variance + epsilon)
                output.append([
                    gamma[index] * (value - mean) / denominator + beta[index]
                    for index, value in enumerate(row)
                ])
            return output
        """,
        explanation: "Layer norm's reduction axis is the feature axis within one example. Gamma and beta restore a learnable scale and offset after standardization.",
        time: "O(batch · features)", space: "O(batch · features)",
        tests: derivedTests([
            ("one row", "[[[1.0,2.0,3.0]],[1.0,1.0,1.0],[0.0,0.0,0.0],0.00001]"),
            ("two different rows", "[[[1.0,1.0],[0.0,4.0]],[2.0,0.5],[1.0,-1.0],0.001]"),
            ("constant row", "[[[5.0,5.0]],[1.0,1.0],[3.0,-2.0],0.00001]"),
            ("single feature", "[[[-7.0]],[4.0],[2.5],0.01]")
        ])
    )

    private static let batchNormTrain = problem(
        id: "ml.batch-norm-train", title: "Batch Normalization Training Step", difficulty: .hard, minutes: 65,
        why: "Batch normalization combines reduction-axis reasoning with state updates that differ between training and inference.",
        prompt: "For a batch shaped batch_size × features, compute each feature's batch mean and population variance across examples, normalize the batch, and apply gamma and beta. Also update running_mean and running_variance as momentum * old + (1 - momentum) * batch_stat. Return [normalized_output, new_running_mean, new_running_variance].",
        signature: "batch_norm_train(batch, gamma, beta, running_mean, running_variance, momentum, epsilon)",
        examples: [.init(input: "batch = [[1, 2], [3, 4]], gamma = [1,1], beta = [0,0], running stats = [0,0], [1,1], momentum = 0.5", output: "[approximately [[-1,-1],[1,1]], [1,1.5], [1,1]]")],
        constraints: ["batch is non-empty and rectangular", "All feature vectors have matching length", "0 ≤ momentum ≤ 1 and epsilon > 0"],
        hints: ["Unlike layer norm, reduce down the batch axis separately for each feature.", "Use batch statistics for the returned normalized values.", "Update running statistics after computing the batch statistics; do not normalize with the running values during training."],
        solution: """
        def batch_norm_train(batch, gamma, beta, running_mean, running_variance, momentum, epsilon):
            import math
            batch_size = len(batch)
            features = len(batch[0])
            means = [sum(batch[row][column] for row in range(batch_size)) / batch_size for column in range(features)]
            variances = [
                sum((batch[row][column] - means[column]) ** 2 for row in range(batch_size)) / batch_size
                for column in range(features)
            ]
            output = []
            for row in batch:
                output.append([
                    gamma[column] * (row[column] - means[column]) / math.sqrt(variances[column] + epsilon) + beta[column]
                    for column in range(features)
                ])
            new_mean = [momentum * old + (1 - momentum) * current for old, current in zip(running_mean, means)]
            new_variance = [momentum * old + (1 - momentum) * current for old, current in zip(running_variance, variances)]
            return [output, new_mean, new_variance]
        """,
        explanation: "Training normalizes with the current mini-batch while maintaining exponential moving averages for later inference. The feature axis is preserved; statistics reduce across examples.",
        time: "O(batch · features)", space: "O(batch · features)",
        tests: derivedTests([
            ("two by two", "[[[1.0,2.0],[3.0,4.0]],[1.0,1.0],[0.0,0.0],[0.0,0.0],[1.0,1.0],0.5,0.00001]"),
            ("scale and shift", "[[[0.0,4.0],[2.0,8.0]],[-1.0,2.0],[3.0,-2.0],[1.0,1.0],[2.0,2.0],0.9,0.001]"),
            ("single example", "[[[5.0,-3.0]],[2.0,4.0],[1.0,2.0],[0.0,0.0],[1.0,1.0],0.0,0.01]"),
            ("momentum one", "[[[1.0],[3.0]],[1.0],[0.0],[7.0],[9.0],1.0,0.00001]")
        ])
    )

    private static let invertedDropout = problem(
        id: "ml.inverted-dropout", title: "Deterministic Inverted Dropout", difficulty: .medium, minutes: 35,
        why: "Interviewers often replace randomness with a supplied mask so you can demonstrate the exact training-time scaling rule.",
        prompt: "Apply a supplied 0/1 mask to a rectangular batch of activations using inverted dropout. During training, kept values are divided by 1 - drop_probability so no further rescaling is needed at inference. Return a new matrix and do not generate randomness.",
        signature: "inverted_dropout(values, mask, drop_probability)",
        examples: [.init(input: "values = [[2, 4]], mask = [[1, 0]], drop_probability = 0.5", output: "[[4, 0]]")],
        constraints: ["values and mask have identical non-empty shapes", "Every mask entry is 0 or 1", "0 ≤ drop_probability < 1"],
        hints: ["The keep probability is 1 - drop_probability.", "A kept value becomes value / keep_probability.", "At drop_probability == 0, the result should equal the input values."],
        solution: """
        def inverted_dropout(values, mask, drop_probability):
            keep_probability = 1.0 - drop_probability
            return [
                [value * keep / keep_probability for value, keep in zip(row, mask_row)]
                for row, mask_row in zip(values, mask)
            ]
        """,
        explanation: "Multiplying by the Bernoulli mask removes dropped activations. Dividing surviving activations by the keep probability preserves their expected magnitude during training.",
        time: "O(batch · features)", space: "O(batch · features)",
        tests: derivedTests([
            ("half dropout", "[[[2.0,4.0]],[[1,0]],0.5]"),
            ("two rows", "[[[1.0,-2.0],[3.0,4.0]],[[1,1],[0,1]],0.25]"),
            ("no dropout", "[[[5.0,6.0]],[[1,1]],0.0]"),
            ("high dropout", "[[[0.5,-1.0]],[[0,1]],0.8]")
        ])
    )

    private static let mlpBackward = problem(
        id: "ml.mlp-backward", title: "Two-Layer MLP Backward Pass", difficulty: .hard, minutes: 90,
        why: "Deriving and implementing backpropagation reveals whether you can move between computational graphs, tensor shapes, and code.",
        prompt: "Implement gradients for a two-layer scalar-regression MLP. For each input x: hidden = ReLU(W1 x + b1), prediction = dot(w2, hidden) + b2. The loss is the mean of (prediction - target)² over the batch. W1 is hidden × input and w2 has one value per hidden unit. Return [dW1, db1, dw2, db2] in matching shapes. ReLU's derivative at exactly zero is 0.",
        signature: "mlp_backward(batch, targets, w1, b1, w2, b2)",
        examples: [.init(input: "batch = [[1,2]], targets = [3], W1 = [[1,0],[0,1]], b1 = [0,0], w2 = [1,1], b2 = 0", output: "all-zero gradients because the prediction is already 3")],
        constraints: ["All tensors are non-empty and shape-compatible", "Targets contain one scalar per example", "Return gradients only; do not update the parameters"],
        hints: ["Start with d_prediction = 2 * (prediction - target) / batch_size.", "dw2[h] accumulates d_prediction * hidden[h].", "The gradient entering hidden h is d_prediction * w2[h], then becomes zero when that pre-activation was not positive."],
        solution: """
        def mlp_backward(batch, targets, w1, b1, w2, b2):
            batch_size = len(batch)
            hidden_size = len(w1)
            input_size = len(w1[0])
            dw1 = [[0.0] * input_size for _ in range(hidden_size)]
            db1 = [0.0] * hidden_size
            dw2 = [0.0] * hidden_size
            db2 = 0.0
            for example, target in zip(batch, targets):
                preactivation = []
                for hidden in range(hidden_size):
                    value = b1[hidden]
                    for feature in range(input_size):
                        value += w1[hidden][feature] * example[feature]
                    preactivation.append(value)
                activation = [max(0.0, value) for value in preactivation]
                prediction = b2 + sum(w2[hidden] * activation[hidden] for hidden in range(hidden_size))
                dprediction = 2.0 * (prediction - target) / batch_size
                db2 += dprediction
                for hidden in range(hidden_size):
                    dw2[hidden] += dprediction * activation[hidden]
                    dpreactivation = dprediction * w2[hidden] if preactivation[hidden] > 0 else 0.0
                    db1[hidden] += dpreactivation
                    for feature in range(input_size):
                        dw1[hidden][feature] += dpreactivation * example[feature]
            return [dw1, db1, dw2, db2]
        """,
        explanation: "Reverse mode starts at the scalar loss and propagates one adjoint backward through the output dot product, the ReLU gate, and the first linear layer. Parameter gradients sum contributions from every example; the mean-loss factor is applied once at the start.",
        time: "O(batch · hidden · input)", space: "O(hidden · input) for returned gradients",
        tests: derivedTests([
            ("zero loss", "[[[1.0,2.0]],[3.0],[[1.0,0.0],[0.0,1.0]],[0.0,0.0],[1.0,1.0],0.0]"),
            ("active and inactive units", "[[[1.0,-2.0]],[0.0],[[1.0,1.0],[-1.0,0.0]],[0.0,0.0],[2.0,-1.0],0.5]"),
            ("two-example mean", "[[[1.0,0.0],[0.0,2.0]],[1.0,-1.0],[[1.0,-1.0],[0.5,1.0]],[0.0,-0.5],[1.5,-2.0],0.25]"),
            ("relu boundary", "[[[1.0]],[2.0],[[0.0]],[0.0],[3.0],1.0]")
        ])
    )

    private static let adamStep = problem(
        id: "ml.adam-step", title: "Adam Optimizer Update", difficulty: .hard, minutes: 60,
        why: "Optimizers are compact state machines; off-by-one bias correction and epsilon placement are common interview bugs.",
        prompt: "Perform one Adam update on one-dimensional parameter, gradient, first-moment, and second-moment vectors. First update m and v, then bias-correct them using the supplied one-based step, and compute parameter - learning_rate * m_hat / (sqrt(v_hat) + epsilon). Return [new_parameters, new_m, new_v].",
        signature: "adam_step(parameters, gradients, m, v, step, learning_rate, beta1, beta2, epsilon)",
        examples: [.init(input: "parameters = [1], gradients = [0.5], m = [0], v = [0], step = 1, lr = 0.1", output: "parameter approximately 0.9 with standard beta values")],
        constraints: ["All four vectors have equal non-zero length", "step ≥ 1", "0 ≤ beta1, beta2 < 1 and epsilon > 0"],
        hints: ["new_m and new_v use the current gradient before bias correction.", "m_hat divides by 1 - beta1 ** step; v_hat uses beta2.", "Epsilon belongs outside sqrt(v_hat) for this contract."],
        solution: """
        def adam_step(parameters, gradients, m, v, step, learning_rate, beta1, beta2, epsilon):
            import math
            new_m = []
            new_v = []
            updated = []
            for parameter, gradient, first, second in zip(parameters, gradients, m, v):
                next_first = beta1 * first + (1 - beta1) * gradient
                next_second = beta2 * second + (1 - beta2) * gradient * gradient
                first_hat = next_first / (1 - beta1 ** step)
                second_hat = next_second / (1 - beta2 ** step)
                updated.append(parameter - learning_rate * first_hat / (math.sqrt(second_hat) + epsilon))
                new_m.append(next_first)
                new_v.append(next_second)
            return [updated, new_m, new_v]
        """,
        explanation: "The moving averages begin biased toward zero, so early steps need time-dependent correction. Adam divides the corrected first moment by an adaptive scale from the corrected second moment.",
        time: "O(p)", space: "O(p) for returned state",
        tests: derivedTests([
            ("first step", "[[1.0],[0.5],[0.0],[0.0],1,0.1,0.9,0.999,0.00000001]"),
            ("signed gradients", "[[1.0,-2.0],[0.5,-0.25],[0.0,0.0],[0.0,0.0],1,0.001,0.9,0.999,0.00000001]"),
            ("later state", "[[0.8],[0.2],[0.1],[0.04],5,0.01,0.8,0.9,0.000001]"),
            ("zero gradient with momentum", "[[3.0],[0.0],[0.5],[0.25],2,0.1,0.9,0.99,0.00000001]")
        ])
    )

    // MARK: Architecture primitives

    private static let validConvolution = problem(
        id: "ml.conv2d-valid", title: "Single-Channel 2D Convolution", difficulty: .hard, minutes: 70,
        why: "Writing convolution exposes receptive fields, stride arithmetic, parameter sharing, and the difference between mathematical convolution and ML cross-correlation.",
        prompt: "Apply a single-channel 2D valid cross-correlation (the operation commonly called convolution in deep learning). Slide kernel over image with the supplied positive stride, multiply entries without flipping the kernel, sum them, add bias, and return only positions where the kernel fits completely.",
        signature: "conv2d_valid(image, kernel, bias, stride)",
        examples: [.init(input: "image = [[1,2],[3,4]], kernel = [[1,0],[0,1]], bias = 0, stride = 1", output: "[[5]]")],
        constraints: ["image and kernel are non-empty rectangular matrices", "The kernel fits inside the image", "stride ≥ 1"],
        hints: ["Output height is floor((height - kernel_height) / stride) + 1.", "Map output[row][column] back to image row * stride and column * stride.", "Do not reverse the kernel for this deep-learning cross-correlation contract."],
        solution: """
        def conv2d_valid(image, kernel, bias, stride):
            image_height = len(image)
            image_width = len(image[0])
            kernel_height = len(kernel)
            kernel_width = len(kernel[0])
            output_height = (image_height - kernel_height) // stride + 1
            output_width = (image_width - kernel_width) // stride + 1
            output = []
            for output_row in range(output_height):
                row = []
                for output_column in range(output_width):
                    total = bias
                    image_row = output_row * stride
                    image_column = output_column * stride
                    for kernel_row in range(kernel_height):
                        for kernel_column in range(kernel_width):
                            total += image[image_row + kernel_row][image_column + kernel_column] * kernel[kernel_row][kernel_column]
                    row.append(total)
                output.append(row)
            return output
        """,
        explanation: "Each output coordinate owns one receptive field whose top-left input coordinate is scaled by stride. Valid padding means every indexed image cell exists, and parameter sharing reuses the same kernel everywhere.",
        time: "O(output_height · output_width · kernel_height · kernel_width)", space: "O(output_height · output_width)",
        tests: derivedTests([
            ("diagonal kernel", "[[[1,2],[3,4]],[[1,0],[0,1]],0,1]"),
            ("rectangular image", "[[[1,2,3],[4,5,6],[7,8,9]],[[1,-1],[0,2]],0.5,1]"),
            ("stride two", "[[[1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,16]],[[1,1],[1,1]],0,2]"),
            ("kernel fills image", "[[[2,-1,3],[0,4,5]],[[1,2,0],[-1,1,2]],-3,1]")
        ])
    )

    private static let maxPooling = problem(
        id: "ml.max-pool2d", title: "2D Max Pooling", difficulty: .medium, minutes: 45,
        why: "Pooling tests window geometry and output-shape calculation without hiding behind a framework operator.",
        prompt: "Apply valid square max pooling to a rectangular feature map. Each pooling window has side length pool_size and starts stride cells after the previous window. Return maxima only for complete windows; overlapping windows are allowed when stride < pool_size.",
        signature: "max_pool2d(feature_map, pool_size, stride)",
        examples: [.init(input: "map = [[1,4],[3,2]], pool_size = 2, stride = 2", output: "[[4]]")],
        constraints: ["feature_map is non-empty and rectangular", "1 ≤ pool_size ≤ both input dimensions", "stride ≥ 1"],
        hints: ["Use the same valid output-size formula as convolution.", "Compute the top-left input coordinate from the output coordinate.", "Initialize the maximum from a real window entry so negative-only windows work."],
        solution: """
        def max_pool2d(feature_map, pool_size, stride):
            height = len(feature_map)
            width = len(feature_map[0])
            output_height = (height - pool_size) // stride + 1
            output_width = (width - pool_size) // stride + 1
            output = []
            for output_row in range(output_height):
                row = []
                for output_column in range(output_width):
                    start_row = output_row * stride
                    start_column = output_column * stride
                    maximum = feature_map[start_row][start_column]
                    for offset_row in range(pool_size):
                        for offset_column in range(pool_size):
                            maximum = max(maximum, feature_map[start_row + offset_row][start_column + offset_column])
                    row.append(maximum)
                output.append(row)
            return output
        """,
        explanation: "Pooling shares convolution's sliding-window geometry but has no learned weights. Initializing from the window rather than zero is essential for negative activations.",
        time: "O(output_height · output_width · pool_size²)", space: "O(output_height · output_width)",
        tests: derivedTests([
            ("single window", "[[[1,4],[3,2]],2,2]"),
            ("four windows", "[[[1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,16]],2,2]"),
            ("overlapping", "[[[1,5,2],[4,3,8],[0,6,7]],2,1]"),
            ("negative values", "[[[-5,-2,-9],[-4,-8,-3]],2,1]")
        ])
    )

    private static let scaledAttention = problem(
        id: "ml.scaled-attention", title: "Scaled Dot-Product Attention", difficulty: .hard, minutes: 75,
        why: "This is the central Transformer primitive and a frequent bridge between a mathematical definition and production tensor code.",
        prompt: "Implement masked Attention(Q,K,V) = softmax(masked(QKᵀ / sqrt(d_key))) V using nested lists. query has shape queries × d_key, key has keys × d_key, and value has keys × d_value. mask has shape queries × keys: 1 keeps a score and 0 excludes it exactly as if that score were negative infinity before softmax. Apply a stable softmax only over allowed keys in each query row; every row has at least one allowed key.",
        signature: "scaled_dot_product_attention(query, key, value, mask)",
        examples: [.init(input: "Q = [[1,0]], K = [[1,0],[0,1]], V = [[10,0],[0,20]], mask = [[1,1]]", output: "a weighted mixture closer to [10,0]")],
        constraints: ["All matrices are non-empty, rectangular, and shape-compatible", "mask entries are 0 or 1", "Every query can attend to at least one key"],
        hints: ["First produce one score for every query-key pair.", "Divide scores by sqrt(d_key) before softmax.", "Exclude masked positions from both the stable-softmax maximum and denominator, then use each probability to mix value rows.", "Production note: PyTorch can express these products with @, while einops.einsum can name the query, key, and feature axes. The revealed reference compares both after you build the list-based mechanics."],
        solution: """
        def scaled_dot_product_attention(query, key, value, mask):
            import math
            scale = math.sqrt(len(query[0]))
            output = []
            for query_index, query_row in enumerate(query):
                scores = []
                for key_row in key:
                    scores.append(sum(left * right for left, right in zip(query_row, key_row)) / scale)
                allowed_scores = [scores[index] for index in range(len(scores)) if mask[query_index][index] == 1]
                maximum = max(allowed_scores)
                weights = [0.0] * len(scores)
                denominator = 0.0
                for index, score in enumerate(scores):
                    if mask[query_index][index] == 1:
                        weights[index] = math.exp(score - maximum)
                        denominator += weights[index]
                weights = [weight / denominator for weight in weights]
                mixed = []
                for dimension in range(len(value[0])):
                    mixed.append(sum(weights[index] * value[index][dimension] for index in range(len(value))))
                output.append(mixed)
            return output
        """,
        explanation: "Attention first converts query-key compatibility into a probability distribution over allowed keys. The scale controls score magnitude as key dimension grows; the final matrix product is a probability-weighted mixture of value vectors.",
        time: "O(queries · keys · (d_key + d_value))", space: "O(queries · d_value + keys) beyond inputs",
        tests: derivedTests([
            ("two keys", "[[[1.0,0.0]],[[1.0,0.0],[0.0,1.0]],[[10.0,0.0],[0.0,20.0]],[[1,1]]]"),
            ("masked key", "[[[1.0,1.0]],[[1.0,1.0],[10.0,10.0]],[[2.0,3.0],[99.0,99.0]],[[1,0]]]"),
            ("two queries", "[[[1.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]],[[1.0],[3.0]],[[1,1],[1,1]]]"),
            ("large scores remain stable", "[[[1000.0,0.0]],[[1000.0,0.0],[999.0,0.0]],[[1.0,2.0],[3.0,4.0]],[[1,1]]]")
        ])
    )

    private static let causalAttention = problem(
        id: "ml.causal-self-attention", title: "Causal Self-Attention Block", difficulty: .hard, minutes: 90,
        why: "This combines learned projections, scaled attention, and autoregressive masking—the first complete Transformer-style block in the lab.",
        prompt: "Project token rows into Q, K, and V using q = tokens Wq, k = tokens Wk, v = tokens Wv, where every weight is d_model × d_model. Then apply scaled dot-product self-attention with a causal mask: output position i may use key positions 0 through i only. Return the attended rows; do not add residuals or an output projection.",
        signature: "causal_self_attention(tokens, wq, wk, wv)",
        examples: [.init(input: "two token rows with identity projection matrices", output: "row 0 equals its own value; row 1 may mix rows 0 and 1")],
        constraints: ["tokens and all weights are non-empty rectangular matrices", "tokens has width d_model and every weight is d_model × d_model", "Use stable softmax and no NumPy"],
        hints: ["Write one helper for rows × weight matrix.", "At query position i, compute scores only for key indices ≤ i.", "The first output row must depend only on the first value row—this is a powerful sanity check.", "Production note: compare ordinary PyTorch matmul with the optional einops.einsum reference after solving; named query/key axes are useful here, but einops is not part of the offline runner."],
        solution: """
        def causal_self_attention(tokens, wq, wk, wv):
            import math
            def project(rows, weights):
                return [[sum(row[inner] * weights[inner][column] for inner in range(len(row))) for column in range(len(weights[0]))] for row in rows]
            query = project(tokens, wq)
            key = project(tokens, wk)
            value = project(tokens, wv)
            scale = math.sqrt(len(query[0]))
            output = []
            for query_index in range(len(query)):
                scores = [
                    sum(query[query_index][dimension] * key[key_index][dimension] for dimension in range(len(query[0]))) / scale
                    for key_index in range(query_index + 1)
                ]
                maximum = max(scores)
                weights = [math.exp(score - maximum) for score in scores]
                denominator = sum(weights)
                weights = [weight / denominator for weight in weights]
                output.append([
                    sum(weights[key_index] * value[key_index][dimension] for key_index in range(query_index + 1))
                    for dimension in range(len(value[0]))
                ])
            return output
        """,
        explanation: "All three projections come from the same token sequence, which makes this self-attention. Restricting the score row to the prefix is equivalent to adding negative infinity above the causal diagonal, and prevents information leakage from future tokens.",
        time: "O(sequence · d_model² + sequence² · d_model)", space: "O(sequence · d_model + sequence²) conceptually",
        tests: derivedTests([
            ("identity projections", "[[[1.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]]]"),
            ("one token", "[[[2.0,-1.0]],[[1.0,0.0],[0.0,1.0]],[[2.0,0.0],[0.0,0.5]],[[0.0,1.0],[1.0,0.0]]]"),
            ("three-token causal prefix", "[[[1.0,0.0],[1.0,1.0],[0.0,2.0]],[[1.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]]]"),
            ("nonidentity projections", "[[[1.0,2.0],[-1.0,1.0]],[[1.0,1.0],[0.0,1.0]],[[2.0,0.0],[1.0,-1.0]],[[0.5,0.0],[0.0,2.0]]]" )
        ])
    )

    private static let multiHeadAttention = problem(
        id: "ml.multi-head-causal-attention", title: "Multi-Head Causal Self-Attention", difficulty: .hard, minutes: 120,
        why: "A full multi-head implementation tests tensor layout, head slicing, causal masking, concatenation, and output projection in one interview-scale task.",
        prompt: "Implement multi-head causal self-attention for token rows of width d_model. Compute full Q, K, V projections as tokens Wq/Wk/Wv. Split each projected row into num_heads contiguous heads of width d_model / num_heads. Within each head apply causal scaled dot-product attention, concatenate head outputs in original head order, then apply Wo. Return sequence × d_model.",
        signature: "multi_head_causal_attention(tokens, wq, wk, wv, wo, num_heads)",
        examples: [.init(input: "identity projections, d_model = 2, num_heads = 2", output: "each one-dimensional head attends causally and the two head outputs are concatenated")],
        constraints: ["All projection matrices are d_model × d_model", "d_model is divisible by num_heads", "num_heads ≥ 1; use stable softmax and no NumPy"],
        hints: ["First verify the num_heads = 1 case against ordinary causal attention.", "For head h, slice columns h * head_dim through (h + 1) * head_dim.", "Build one output vector per token by extending it with each head's result, then multiply by Wo.", "Production note: this is the strongest einsum use case. The revealed references place conventional PyTorch reshape/transpose/matmul beside einops.rearrange + einsum so you can compare the layouts."],
        solution: """
        def multi_head_causal_attention(tokens, wq, wk, wv, wo, num_heads):
            import math
            def project(rows, matrix):
                return [[sum(row[inner] * matrix[inner][column] for inner in range(len(row))) for column in range(len(matrix[0]))] for row in rows]
            query = project(tokens, wq)
            key = project(tokens, wk)
            value = project(tokens, wv)
            model_dimension = len(query[0])
            head_dimension = model_dimension // num_heads
            concatenated = [[] for _ in tokens]
            for head in range(num_heads):
                start = head * head_dimension
                end = start + head_dimension
                scale = math.sqrt(head_dimension)
                for query_index in range(len(tokens)):
                    scores = []
                    for key_index in range(query_index + 1):
                        score = sum(query[query_index][dimension] * key[key_index][dimension] for dimension in range(start, end)) / scale
                        scores.append(score)
                    maximum = max(scores)
                    attention_weights = [math.exp(score - maximum) for score in scores]
                    denominator = sum(attention_weights)
                    attention_weights = [weight / denominator for weight in attention_weights]
                    head_output = [
                        sum(attention_weights[key_index] * value[key_index][dimension] for key_index in range(query_index + 1))
                        for dimension in range(start, end)
                    ]
                    concatenated[query_index].extend(head_output)
            return project(concatenated, wo)
        """,
        explanation: "Each head owns a separate lower-dimensional similarity space and value mixture. Concatenation restores d_model, and Wo lets the model combine information across heads. The causal boundary is enforced independently but identically in every head.",
        time: "O(sequence · d_model² + sequence² · d_model)", space: "O(sequence · d_model + sequence²) conceptually",
        tests: derivedTests([
            ("two one-dimensional heads", "[[[1.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]],2]"),
            ("one head", "[[[1.0,2.0],[-1.0,0.5]],[[1.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]],1]"),
            ("output projection swaps features", "[[[1.0,2.0],[3.0,4.0]],[[1.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]],[[0.0,1.0],[1.0,0.0]],2]"),
            ("four-dimensional two-head", "[[[1.0,0.0,1.0,0.0],[0.0,1.0,0.0,1.0]],[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]],[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]],[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]],[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]],2]")
        ])
    )

    // MARK: Research engineering

    private static let kMeansStep = problem(
        id: "ml.kmeans-step", title: "One K-Means Iteration", difficulty: .medium, minutes: 55,
        why: "This compact unsupervised-learning task tests vector distance, deterministic tie-breaking, grouped reductions, and empty-cluster policy.",
        prompt: "Perform one assignment-and-update iteration of K-means using squared Euclidean distance. Assign each point to the nearest centroid; distance ties choose the lower centroid index. Replace each non-empty centroid with the coordinate-wise mean of its assigned points. An empty centroid stays unchanged. Return [assignments, new_centroids].",
        signature: "kmeans_step(points, centroids)",
        examples: [.init(input: "points = [[0,0],[2,0],[10,0]], centroids = [[0,0],[10,0]]", output: "[[0,0,1], [[1,0],[10,0]]]")],
        constraints: ["points and centroids are non-empty and share one dimension", "Coordinates are finite numbers", "Do not mutate the original centroids"],
        hints: ["Squared distance gives the same nearest centroid without square roots.", "Store sums and counts for each cluster after assignment.", "Copy the old centroid when its count is zero."],
        solution: """
        def kmeans_step(points, centroids):
            assignments = []
            for point in points:
                best_index = 0
                best_distance = sum((point[d] - centroids[0][d]) ** 2 for d in range(len(point)))
                for index in range(1, len(centroids)):
                    distance = sum((point[d] - centroids[index][d]) ** 2 for d in range(len(point)))
                    if distance < best_distance:
                        best_distance = distance
                        best_index = index
                assignments.append(best_index)
            sums = [[0.0] * len(points[0]) for _ in centroids]
            counts = [0] * len(centroids)
            for point, cluster in zip(points, assignments):
                counts[cluster] += 1
                for dimension in range(len(point)):
                    sums[cluster][dimension] += point[dimension]
            updated = []
            for index, centroid in enumerate(centroids):
                if counts[index] == 0:
                    updated.append(list(centroid))
                else:
                    updated.append([value / counts[index] for value in sums[index]])
            return [assignments, updated]
        """,
        explanation: "The E-like assignment step fixes cluster membership under current centers; the update step minimizes within-cluster squared distance by taking means. Explicit tie and empty-cluster policies make the result reproducible.",
        time: "O(points · clusters · dimensions)", space: "O(points + clusters · dimensions)",
        tests: derivedTests([
            ("two clusters", "[[[0,0],[2,0],[10,0]],[[0,0],[10,0]]]"),
            ("tie chooses lower", "[[[1.0,0.0]],[[0.0,0.0],[2.0,0.0]]]"),
            ("empty cluster stays", "[[[0.0],[1.0]],[[0.0],[10.0],[100.0]]]"),
            ("two dimensions", "[[[-1.0,2.0],[1.0,4.0],[9.0,8.0]],[[0.0,0.0],[10.0,10.0]]]")
        ])
    )

    private static let macroF1 = problem(
        id: "ml.macro-f1", title: "Multiclass Macro F1", difficulty: .medium, minutes: 50,
        why: "Metrics code can change model conclusions; research interviews expect precise averaging and defensible zero-division behavior.",
        prompt: "Compute macro F1 for class IDs 0 through num_classes - 1. For each class count true positives, false positives, and false negatives, then use F1 = 2TP / (2TP + FP + FN). If that denominator is zero, that class's F1 is 0. Return the unweighted mean across all num_classes, including absent classes.",
        signature: "macro_f1_score(true_labels, predicted_labels, num_classes)",
        examples: [.init(input: "true = [0,1,1], predicted = [0,0,1], num_classes = 2", output: "approximately 0.666667")],
        constraints: ["The two label arrays have equal length", "num_classes ≥ 1", "Every supplied label is in range"],
        hints: ["Treat each class as one-vs-rest.", "You can compute F1 directly from TP, FP, FN without separately dividing precision and recall.", "Macro averaging gives every class equal weight, not every example."],
        solution: """
        def macro_f1_score(true_labels, predicted_labels, num_classes):
            total = 0.0
            for target_class in range(num_classes):
                true_positive = 0
                false_positive = 0
                false_negative = 0
                for truth, prediction in zip(true_labels, predicted_labels):
                    if prediction == target_class and truth == target_class:
                        true_positive += 1
                    elif prediction == target_class:
                        false_positive += 1
                    elif truth == target_class:
                        false_negative += 1
                denominator = 2 * true_positive + false_positive + false_negative
                total += 0.0 if denominator == 0 else 2.0 * true_positive / denominator
            return total / num_classes
        """,
        explanation: "One-vs-rest counts define a separate F1 for every class. Averaging those scores equally is macro F1; the explicit absent-class rule prevents library-default ambiguity.",
        time: "O(examples · classes)", space: "O(1)",
        tests: derivedTests([
            ("mixed errors", "[[0,1,1],[0,0,1],2]"),
            ("perfect", "[[0,1,2,1],[0,1,2,1],3]"),
            ("absent class included", "[[0,0],[0,0],3]"),
            ("all wrong", "[[0,0,1,1],[1,1,0,0],2]")
        ])
    )

    private static let beamSearch = problem(
        id: "ml.beam-search", title: "Deterministic Beam Search Decoder", difficulty: .hard, minutes: 85,
        why: "Approximate decoding tests priority management, completed-hypothesis handling, log-space scores, and reproducibility.",
        prompt: "Decode with a fixed transition log-probability matrix. transition_log_probs[previous_token][next_token] is added to a beam's score. Begin with [start_token] at score 0. For at most max_steps, carry beams already ending in eos_token unchanged and expand every other beam with every vocabulary token. Keep the best beam_width by higher score, breaking equal scores by lexicographically smaller token sequence. Stop early if every retained beam has ended. Return the best sequence without start_token, including eos_token if generated.",
        signature: "beam_search_decode(transition_log_probs, beam_width, start_token, eos_token, max_steps)",
        examples: [.init(input: "a small transition table with beam_width = 2", output: "the highest-scoring retained token sequence under the stated deterministic rules")],
        constraints: ["The transition matrix is non-empty and square", "beam_width ≥ 1 and max_steps ≥ 0", "start_token and eos_token are valid IDs"],
        hints: ["Represent each beam as (score, token_list).", "Completed beams compete for retention but must not be expanded again.", "Sort with the compound key (-score, tokens) so ties are deterministic."],
        solution: """
        def beam_search_decode(transition_log_probs, beam_width, start_token, eos_token, max_steps):
            beams = [(0.0, [start_token])]
            vocabulary_size = len(transition_log_probs)
            for _ in range(max_steps):
                candidates = []
                for score, tokens in beams:
                    if tokens[-1] == eos_token:
                        candidates.append((score, tokens))
                        continue
                    previous = tokens[-1]
                    for token in range(vocabulary_size):
                        candidates.append((score + transition_log_probs[previous][token], tokens + [token]))
                candidates.sort(key=lambda beam: (-beam[0], beam[1]))
                beams = candidates[:beam_width]
                if all(tokens[-1] == eos_token for _, tokens in beams):
                    break
            beams.sort(key=lambda beam: (-beam[0], beam[1]))
            return beams[0][1:]
        """,
        explanation: "Using log probabilities turns path products into sums. The beam prunes globally after expanding the current frontier, while retaining finished hypotheses prevents them from being forced into extra tokens. Explicit tie-breaking makes experiments reproducible.",
        time: "O(max_steps · beam_width · vocabulary · log(beam_width · vocabulary))", space: "O(beam_width · vocabulary · max_steps)",
        tests: derivedTests([
            ("greedy-sized beam", "[[[-5.0,-0.1,-1.0],[-5.0,-1.0,-0.1],[-5.0,-5.0,0.0]],1,0,2,4]"),
            ("beam recovers delayed reward", "[[[-9.0,-0.1,-0.2],[-9.0,-4.0,-4.0],[-9.0,-0.01,-3.0]],2,0,1,3]"),
            ("lexicographic tie", "[[[-9.0,-0.5,-0.5],[-9.0,0.0,-9.0],[-9.0,-9.0,0.0]],2,0,2,1]"),
            ("zero steps", "[[[0.0,-1.0],[-1.0,0.0]],2,0,1,0]")
        ])
    )

    private static let padSequences = problem(
        id: "ml.pad-sequences", title: "Pad a Variable-Length Batch", difficulty: .medium, minutes: 40,
        why: "Batch construction is deceptively important: masks and lengths determine whether padding leaks into losses and attention.",
        prompt: "Pad a non-empty list of integer sequences to the maximum sequence length in the batch. Append pad_value on the right. Return [padded, attention_mask, lengths], where mask entries are 1 for original tokens and 0 for padding. Empty individual sequences are allowed.",
        signature: "pad_sequences(sequences, pad_value)",
        examples: [.init(input: "sequences = [[4,5], [7], []], pad_value = 0", output: "[[[4,5],[7,0],[0,0]], [[1,1],[1,0],[0,0]], [2,1,0]]")],
        constraints: ["The outer batch is non-empty", "Every sequence is a list of integers", "Do not mutate the supplied sequences"],
        hints: ["Compute lengths before changing any rows.", "The target width is max(lengths); it may be zero.", "A row needs target_width - current_length padding entries."],
        solution: """
        def pad_sequences(sequences, pad_value):
            lengths = [len(sequence) for sequence in sequences]
            width = max(lengths)
            padded = []
            mask = []
            for sequence, length in zip(sequences, lengths):
                padding = width - length
                padded.append(list(sequence) + [pad_value] * padding)
                mask.append([1] * length + [0] * padding)
            return [padded, mask, lengths]
        """,
        explanation: "Lengths capture the unpadded batch, while the mask makes valid positions explicit for later attention or loss calculations. Copying each sequence keeps input data immutable.",
        time: "O(batch · maximum_length)", space: "O(batch · maximum_length)",
        tests: derivedTests([
            ("mixed lengths", "[[[4,5],[7],[]],0]"),
            ("already rectangular", "[[[1,2],[3,4]],-1]"),
            ("all empty", "[[[],[]],99]"),
            ("pad value resembles token", "[[[0],[0,1,0]],0]")
        ])
    )

    private static let accumulateGradients = problem(
        id: "ml.accumulate-gradients", title: "Sample-Weighted Gradient Accumulation", difficulty: .medium, minutes: 50,
        why: "Microbatching should reproduce the full-batch mean gradient; averaging microbatch means equally is wrong when microbatch sizes differ.",
        prompt: "Each row in gradient_batches is the mean gradient vector produced by one microbatch, and batch_sizes gives that microbatch's positive example count. Return the mean gradient over all individual examples. Weight each microbatch mean by its batch size, sum, then divide by the total number of examples.",
        signature: "accumulate_gradients(gradient_batches, batch_sizes)",
        examples: [.init(input: "gradients = [[1,3], [5,7]], sizes = [3,1]", output: "[2,4]", explanation: "The first mean represents three examples, so (3*[1,3] + 1*[5,7]) / 4 = [2,4].")],
        constraints: ["gradient_batches is non-empty and rectangular", "len(batch_sizes) == len(gradient_batches)", "Every batch size is a positive integer"],
        hints: ["Do not divide by the number of microbatches.", "Recover each microbatch's summed gradient by multiplying its mean by its size.", "Normalize once using sum(batch_sizes)."],
        solution: """
        def accumulate_gradients(gradient_batches, batch_sizes):
            total_examples = sum(batch_sizes)
            accumulated = [0.0] * len(gradient_batches[0])
            for gradient, batch_size in zip(gradient_batches, batch_sizes):
                for index, value in enumerate(gradient):
                    accumulated[index] += value * batch_size
            return [value / total_examples for value in accumulated]
        """,
        explanation: "A reported microbatch mean already divided by its local sample count. Multiplying back by that count reconstructs its contribution to the global sum; one final division exactly matches full-batch mean reduction.",
        time: "O(microbatches · parameters)", space: "O(parameters)",
        tests: derivedTests([
            ("unequal sizes", "[[[1.0,3.0],[5.0,7.0]],[3,1]]"),
            ("equal sizes", "[[[-1.0,2.0],[3.0,4.0]],[2,2]]"),
            ("one microbatch", "[[[0.5,-0.25,8.0]],[7]]"),
            ("strongly imbalanced", "[[[0.0,10.0],[100.0,-10.0]],[99,1]]")
        ])
    )

    // MARK: Curated comparisons and challenge inputs

    static let alternatives: [String: [SolutionAlternative]] = [
        "ml.matrix-multiply": [alt("transpose-right", "Transpose right first", .sameBigO, "Prebuild right's columns, then express every output cell as a dot product over zip.", "O(mkn)", "O(kn + mn)", "Clarity and contiguous column access matter more than minimizing allocations.", "The equation is easier to read, but the copied transpose adds memory and setup work.")],
        "ml.stable-softmax": [alt("online-normalizer", "Streaming normalizer", .constraintDependent, "Maintain a running maximum and rescaled exponential sum without storing all exponentials.", "O(n)", "O(1) beyond output", "Logits arrive as a stream or an extra exponentials array is undesirable.", "It is harder to derive and still needs another pass or stored logits to emit every probability.")],
        "ml.batch-cross-entropy": [alt("softmax-then-log", "Softmax followed by negative log", .simplerButSlower, "Compute stable probabilities, select each correct-class probability, then take -log and average.", "O(batch · classes)", "O(batch · classes)", "You also need the probabilities for another computation.", "It materializes probabilities and may lose precision near zero; direct log-sum-exp is more robust.")],
        "ml.linear-forward": [alt("matmul-transpose", "Reuse general matmul", .sameBigO, "Transpose the output-first weights and call a tested matrix-multiplication helper before adding bias.", "O(batch · input · output)", "O(input · output + batch · output)", "A reliable tensor primitive already exists and composition improves maintainability.", "It allocates a transpose and intermediate, while the fused loops can add bias during accumulation.")],
        "ml.mean-pool-embeddings": [alt("masked-sums", "Precompute mask and lengths", .sameBigO, "Build a boolean mask, sum masked embeddings, and divide by per-row valid lengths with a clamped denominator.", "O(batch · sequence · dimension)", "O(batch · sequence)", "The same mask and lengths are reused by later layers.", "It stores more state; clamping must still restore the specified zero vector for empty rows.")],
        "ml.layer-norm": [alt("one-pass-variance", "Welford variance", .sameBigO, "Use Welford's online updates to compute mean and variance in one numerically stable pass.", "O(batch · features)", "O(batch · features)", "Rows are long or values have large offsets and variance accuracy matters.", "The recurrence is less transparent than the two-pass definition and still needs a pass to normalize.")],
        "ml.batch-norm-train": [alt("sum-and-square", "Sum and squared-sum statistics", .sameBigO, "Compute variance as E[x²] - E[x]² from feature sums and squared sums.", "O(batch · features)", "O(features)", "Fused kernels or distributed all-reduce need compact sufficient statistics.", "It is vulnerable to cancellation for large, nearly equal values; centered deviations are clearer and safer here.")],
        "ml.inverted-dropout": [alt("inference-scaling", "Scale weights at inference", .constraintDependent, "Leave kept activations unchanged in training, then multiply by keep probability during inference.", "O(batch · features)", "O(batch · features)", "Reproducing the older non-inverted dropout convention.", "It moves special handling into inference; modern libraries generally prefer inverted dropout.")],
        "ml.mlp-backward": [alt("cached-forward", "Cache forward intermediates", .timeSpaceTradeoff, "Have forward return preactivations and activations for backward instead of recomputing them.", "O(batch · hidden · input)", "O(batch · hidden)", "Training throughput matters and a forward cache naturally belongs to the autograd graph.", "It uses more activation memory; recomputation can be preferable in memory-constrained training.")],
        "ml.adam-step": [alt("adamw", "Decoupled weight decay (AdamW)", .constraintDependent, "Apply weight decay directly to parameters rather than adding an L2 term to the adaptive gradient.", "O(p)", "O(p)", "Training modern neural networks with explicit weight decay.", "It intentionally implements a different optimizer contract and introduces an additional hyperparameter.")],
        "ml.conv2d-valid": [alt("im2col", "Lower windows to matrix multiplication", .timeSpaceTradeoff, "Flatten every receptive field into a row and use a matrix multiply against flattened kernels.", "Same arithmetic order; optimized matmul in practice", "Large lowered matrix", "A high-performance BLAS/GPU matrix multiply is available.", "The duplicated im2col representation can consume substantial memory; direct loops expose geometry better.")],
        "ml.max-pool2d": [alt("deque-pooling", "Separable monotonic deques", .timeSpaceTradeoff, "For large windows, compute row then column sliding maxima with monotonic deques.", "O(height · width)", "O(height · width)", "Pool windows are large and stride/window rules permit reuse.", "It is much more complex and less direct than scanning the small windows typical in interviews.")],
        "ml.scaled-attention": [alt("fused-sdpa", "Framework fused SDPA", .constraintDependent, "Delegate to an optimized scaled-dot-product-attention kernel that can fuse masking, softmax, and value mixing.", "O(queries · keys · dimension) arithmetic", "Can avoid full score materialization", "Production PyTorch/JAX code targets GPU efficiency.", "The kernel is preferable in production but hides the equation, shapes, and stable masking an interview may ask you to demonstrate.")],
        "ml.causal-self-attention": [alt("explicit-mask", "Build the full causal mask", .sameBigO, "Create a lower-triangular mask and reuse a general masked-attention function.", "O(sequence² · d_model + sequence · d_model²)", "O(sequence²)", "Composition and test reuse matter more than minimizing temporary storage.", "It is modular but allocates scores for forbidden future positions that prefix-only loops never create.")],
        "ml.multi-head-causal-attention": [alt("batched-head-axis", "Treat heads as a batch axis", .sameBigO, "Reshape to sequence × heads × head_dim and compute all heads with batched tensor operations.", "O(sequence² · d_model + sequence · d_model²)", "Framework-dependent", "Writing production vectorized tensor code.", "It is faster and idiomatic in frameworks, but manual slicing makes head layout and concatenation easier to verify in an interview.")],
        "ml.kmeans-step": [alt("vectorized-distances", "Broadcast all distances", .timeSpaceTradeoff, "Materialize the point-by-centroid distance matrix, then reduce by argmin and grouped means.", "O(points · clusters · dimensions)", "O(points · clusters)", "Vectorized accelerator execution matters more than intermediate memory.", "It is concise in NumPy/PyTorch but can create a very large distance matrix.")],
        "ml.macro-f1": [alt("confusion-matrix", "Build a confusion matrix", .timeSpaceTradeoff, "Count truth/prediction pairs once, then derive every class's TP, FP, and FN from rows and columns.", "O(examples + classes²)", "O(classes²)", "You need several metrics or per-class diagnostics from the same evaluation.", "It is faster for many classes but allocates a quadratic table when only macro F1 is needed.")],
        "ml.beam-search": [alt("heap-pruning", "Keep candidates in a bounded heap", .timeSpaceTradeoff, "Use a heap to retain only the best beam_width candidates instead of fully sorting every expansion.", "O(max_steps · beam · vocab · log beam)", "O(beam)", "Vocabulary is large and deterministic heap tie keys are carefully designed.", "It saves sorting work but is easier to get wrong around equal scores and lexicographic ordering.")],
        "ml.pad-sequences": [alt("packed-sequence", "Keep a packed representation", .constraintDependent, "Store concatenated tokens plus offsets/lengths instead of materializing padding.", "O(total tokens)", "O(total tokens + batch)", "The downstream model supports ragged or packed batches.", "It avoids padding work but many attention kernels require a rectangular tensor and explicit mask.")],
        "ml.accumulate-gradients": [alt("loss-scaling", "Scale each microbatch loss", .sameBigO, "Multiply each mean loss by microbatch_size / total_size before backward, so accumulated gradients are already normalized.", "O(microbatches · parameters)", "O(parameters)", "An autograd framework accumulates parameter gradients in place.", "It avoids a post-hoc vector pass but requires knowing the total size and applying the scale correctly before each backward call.")]
    ]

    static let adversarialArguments: [String: (String, String)] = [
        "ml.matrix-multiply": ("non-square shared dimension", "[[[1,2,3]],[[1,2],[3,4],[5,6]]]"),
        "ml.stable-softmax": ("dominant negative-shifted logit", "[[10000.0,9990.0,9980.0]]"),
        "ml.batch-cross-entropy": ("correct class has smallest huge logit", "[[[10000.0,9999.0,9998.0]],[2]]"),
        "ml.linear-forward": ("bias and negative weights", "[[[-2.0,3.0]],[[1.5,-2.0],[-1.0,-1.0]],[4.0,0.5]]"),
        "ml.mean-pool-embeddings": ("padding is not table row zero", "[[[2,1,2]],[[1.0],[3.0],[100.0]],2]"),
        "ml.layer-norm": ("large offset small variance", "[[[10000.0,10001.0,9999.0]],[1.0,1.0,1.0],[0.0,0.0,0.0],0.00001]"),
        "ml.batch-norm-train": ("feature axes differ", "[[[1.0,100.0],[3.0,200.0],[5.0,300.0]],[1.0,1.0],[0.0,0.0],[0.0,0.0],[1.0,1.0],0.75,0.00001]"),
        "ml.inverted-dropout": ("kept negative value", "[[[-3.0,2.0]],[[1,0]],0.6]"),
        "ml.mlp-backward": ("bias receives gradient with zero input", "[[[0.0]],[0.0],[[1.0]],[2.0],[3.0],-1.0]"),
        "ml.adam-step": ("bias correction at a large step", "[[1.0,2.0],[-1.0,2.0],[0.2,-0.1],[0.4,0.3],20,0.005,0.9,0.999,0.00000001]"),
        "ml.conv2d-valid": ("negative-only response with bias", "[[[-1,-2,-3],[-4,-5,-6]],[[1,1],[1,1]],-2,1]"),
        "ml.max-pool2d": ("stride leaves incomplete edge", "[[[1,2,9,4,5],[6,7,8,3,2],[0,1,2,3,4]],2,2]"),
        "ml.scaled-attention": ("different value width and partial mask", "[[[1.0,2.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0],[1.0,1.0]],[[1.0,2.0,3.0],[4.0,5.0,6.0],[7.0,8.0,9.0]],[[1,0,1],[0,1,1]]]"),
        "ml.causal-self-attention": ("future token cannot change first row", "[[[1.0,0.0],[999.0,999.0]],[[1.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]],[[1.0,0.0],[0.0,1.0]]]"),
        "ml.multi-head-causal-attention": ("three tokens and two heads", "[[[1.0,0.0],[0.5,1.0],[-1.0,2.0]],[[1,0],[0,1]],[[1,0],[0,1]],[[1,0],[0,1]],[[1,0],[0,1]],2]"),
        "ml.kmeans-step": ("duplicate centroids choose first", "[[[2.0,2.0],[3.0,3.0]],[[0.0,0.0],[0.0,0.0]]]"),
        "ml.macro-f1": ("imbalanced classes expose micro averaging", "[[0,0,0,0,1],[0,0,0,1,1],2]"),
        "ml.beam-search": ("completed beam is carried", "[[[-9.0,-0.1,-0.2],[-9.0,0.0,-9.0],[-9.0,-0.01,-0.5]],3,0,1,4]"),
        "ml.pad-sequences": ("long empty-leading batch", "[[[],[1,2,3],[]],-5]"),
        "ml.accumulate-gradients": ("three unequal microbatches", "[[[1.0,0.0],[0.0,2.0],[-3.0,4.0]],[8,1,3]]")
    ]

    // MARK: Construction helpers

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
        let functionName = String(signature.prefix { $0 != "(" })
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
            starterCode: "def \(signature):\n    # Work from shapes and invariants before optimizing.\n    pass\n",
            hints: hints,
            referenceSolution: solution,
            solutionExplanation: explanation,
            timeComplexity: time,
            spaceComplexity: space,
            tests: tests
        )
    }

    private static func derivedTests(_ values: [(String, String)]) -> [AlgorithmTestCase] {
        values.map { name, arguments in
            AlgorithmTestCase(name: name, argumentsJSON: arguments, expectedJSON: "null", derivesExpectedFromReference: true)
        }
    }

    private static func alt(
        _ id: String,
        _ title: String,
        _ kind: SolutionComparisonKind,
        _ summary: String,
        _ time: String,
        _ space: String,
        _ bestWhen: String,
        _ tradeoff: String
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
            code: nil
        )
    }

    private static func source(
        id: String,
        title: String,
        authors: String,
        takeaway: String,
        url: String
    ) -> LearningResearchSource {
        guard let destination = URL(string: url) else {
            preconditionFailure("Invalid ML interview source URL: \(url)")
        }
        return LearningResearchSource(
            id: id,
            title: title,
            authorsAndYear: authors,
            takeaway: takeaway,
            url: destination
        )
    }
}
