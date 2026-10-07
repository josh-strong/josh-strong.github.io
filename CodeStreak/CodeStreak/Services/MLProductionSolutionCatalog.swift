import Foundation

/// Learner-facing framework comparisons for the ML interview lab.
///
/// The primary examples use conventional PyTorch operations. A separate
/// einsum formulation is offered only when named contractions materially
/// clarify the tensor geometry (the attention exercises). The dependency-free
/// plain-Python oracle remains the executable reference inside CodeStreak.
enum MLProductionSolutionCatalog {
    static func solution(for problemID: String) -> ProductionSolution? {
        guard let code = pytorchCodeByProblemID[problemID] else { return nil }

        let einsumAlternative = einsumCodeByProblemID[problemID].map { code in
            EinsumSolution(
                title: "Optional named-axis solution · einops einsum",
                summary: einsumSummaries[problemID]
                    ?? "Name each contraction axis explicitly when that makes the tensor equation easier to verify.",
                requirements: "Python with PyTorch and einops installed",
                code: code,
                documentationURL: einopsDocumentationURL
            )
        }

        return ProductionSolution(
            title: "Production comparison · conventional PyTorch (no einsum)",
            summary: summaries[problemID]
                ?? "Use the framework's ordinary tensor operations so the production implementation remains direct and idiomatic.",
            requirements: "Python with PyTorch installed",
            runtimeNote: "CodeStreak's offline runner intentionally has no native PyTorch backend. Run this comparison in a normal Python environment; the dependency-free executable oracle remains available below.",
            code: code,
            documentationLabel: "Open the official PyTorch guide",
            documentationURL: pytorchDocumentationURL,
            einsumAlternative: einsumAlternative
        )
    }

    static var coveredProblemIDs: Set<String> { Set(pytorchCodeByProblemID.keys) }
    static var einsumProblemIDs: Set<String> { Set(einsumCodeByProblemID.keys) }

    private static let pytorchDocumentationURL = URL(string: "https://docs.pytorch.org/docs/stable/torch.html")!
    private static let einopsDocumentationURL = URL(string: "https://einops.rocks/api/einsum/")!

    private static let summaries: [String: String] = [
        "ml.stable-softmax": "Use ordinary PyTorch reductions to show the stabilizing shift and normalization directly.",
        "ml.batch-cross-entropy": "Use logsumexp and indexed selection without materializing an avoidably fragile manual softmax.",
        "ml.linear-forward": "Use PyTorch's standard linear primitive; a simple affine layer does not benefit from einsum notation.",
        "ml.mean-pool-embeddings": "Use indexing, broadcasting, and reductions along explicit dimensions.",
        "ml.layer-norm": "Keep the feature-axis statistics visible with dim and keepdim arguments.",
        "ml.batch-norm-train": "Reduce statistics over the batch dimension and rely on normal broadcasting over features.",
        "ml.inverted-dropout": "Elementwise multiplication and scaling are clearer than disguising the operation as a contraction.",
        "ml.mlp-backward": "Write the chain rule with matrix multiplication, transposes, and broadcasting—the operations used in an ordinary derivation.",
        "ml.adam-step": "Use direct elementwise tensor arithmetic for optimizer state; einsum would add notation without adding insight.",
        "ml.conv2d-valid": "Use the production convolution primitive after learning the window arithmetic in the offline oracle.",
        "ml.max-pool2d": "Use the framework pooling primitive; this is a window reduction, not a tensor contraction.",
        "ml.scaled-attention": "Start with familiar matrix multiplication for QKᵀ and probability-value mixing; compare the named-axis form below.",
        "ml.causal-self-attention": "Use projections, transposed matmul, masking, and softmax directly; compare the equivalent einsum equations below.",
        "ml.multi-head-causal-attention": "Use reshape, transpose, and batched matmul explicitly before comparing how named axes reduce layout mistakes.",
        "ml.kmeans-step": "Use broadcasting to construct point-centroid differences and reduce squared distances over features.",
        "ml.macro-f1": "Broadcast labels over the class dimension and reduce boolean counts with standard PyTorch operations.",
        "ml.beam-search": "Use ordinary reshape for the beam-vocabulary frontier while keeping deterministic Python tie-breaking visible.",
        "ml.pad-sequences": "Use tensor construction, expand, and comparison; no contraction notation is needed.",
        "ml.accumulate-gradients": "Use simple broadcasting and a sum for the sample-weighted average."
    ]

    private static let einsumSummaries: [String: String] = [
        "ml.scaled-attention": "The query/key and attention/value axis names mirror the two equations, which helps prevent accidental transposes.",
        "ml.causal-self-attention": "Named query, key, token, and model axes make each projection and contraction auditable while leaving masking unchanged.",
        "ml.multi-head-causal-attention": "This is the strongest use case: named head, token, and feature axes avoid a brittle chain of reshape and transpose operations."
    ]

    private static let pytorchCodeByProblemID: [String: String] = [
        "ml.stable-softmax": """
        def stable_softmax(logits):
            import torch

            logits = torch.as_tensor(logits, dtype=torch.float64)
            shifted = logits - logits.max()
            exponentials = torch.exp(shifted)
            return (exponentials / exponentials.sum()).tolist()
        """,

        "ml.batch-cross-entropy": """
        def batch_cross_entropy(logits, labels):
            import torch

            logits = torch.as_tensor(logits, dtype=torch.float64)
            labels = torch.as_tensor(labels, dtype=torch.long)
            row_indices = torch.arange(logits.shape[0])
            correct_logits = logits[row_indices, labels]
            losses = torch.logsumexp(logits, dim=1) - correct_logits
            return losses.mean().item()
        """,

        "ml.linear-forward": """
        def linear_forward(batch, weights, bias):
            import torch
            import torch.nn.functional as F

            batch = torch.as_tensor(batch, dtype=torch.float64)
            weights = torch.as_tensor(weights, dtype=torch.float64)
            bias = torch.as_tensor(bias, dtype=torch.float64)
            return F.linear(batch, weights, bias).tolist()
        """,

        "ml.mean-pool-embeddings": """
        def mean_pool_embeddings(token_batches, embedding_table, pad_id):
            import torch

            tokens = torch.as_tensor(token_batches, dtype=torch.long)
            table = torch.as_tensor(embedding_table, dtype=torch.float64)
            embedded = table[tokens]
            valid = tokens.ne(pad_id).unsqueeze(-1)
            totals = (embedded * valid).sum(dim=1)
            counts = valid.sum(dim=1)
            means = totals / counts.clamp_min(1)
            means = torch.where(counts > 0, means, torch.zeros_like(means))
            return means.tolist()
        """,

        "ml.layer-norm": """
        def layer_norm(batch, gamma, beta, epsilon):
            import torch

            batch = torch.as_tensor(batch, dtype=torch.float64)
            gamma = torch.as_tensor(gamma, dtype=torch.float64)
            beta = torch.as_tensor(beta, dtype=torch.float64)
            mean = batch.mean(dim=-1, keepdim=True)
            variance = ((batch - mean) ** 2).mean(dim=-1, keepdim=True)
            normalized = (batch - mean) / torch.sqrt(variance + epsilon)
            return (normalized * gamma + beta).tolist()
        """,

        "ml.batch-norm-train": """
        def batch_norm_train(batch, gamma, beta, running_mean, running_variance, momentum, epsilon):
            import torch

            batch = torch.as_tensor(batch, dtype=torch.float64)
            gamma = torch.as_tensor(gamma, dtype=torch.float64)
            beta = torch.as_tensor(beta, dtype=torch.float64)
            running_mean = torch.as_tensor(running_mean, dtype=torch.float64)
            running_variance = torch.as_tensor(running_variance, dtype=torch.float64)
            mean = batch.mean(dim=0)
            centered = batch - mean
            variance = (centered ** 2).mean(dim=0)
            output = gamma * centered / torch.sqrt(variance + epsilon) + beta
            new_mean = momentum * running_mean + (1 - momentum) * mean
            new_variance = momentum * running_variance + (1 - momentum) * variance
            return [output.tolist(), new_mean.tolist(), new_variance.tolist()]
        """,

        "ml.inverted-dropout": """
        def inverted_dropout(values, mask, drop_probability):
            import torch

            values = torch.as_tensor(values, dtype=torch.float64)
            mask = torch.as_tensor(mask, dtype=torch.float64)
            return (values * mask / (1.0 - drop_probability)).tolist()
        """,

        "ml.mlp-backward": """
        def mlp_backward(batch, targets, w1, b1, w2, b2):
            import torch

            x = torch.as_tensor(batch, dtype=torch.float64)
            targets = torch.as_tensor(targets, dtype=torch.float64)
            w1 = torch.as_tensor(w1, dtype=torch.float64)
            b1 = torch.as_tensor(b1, dtype=torch.float64)
            w2 = torch.as_tensor(w2, dtype=torch.float64)

            preactivation = x @ w1.T + b1
            hidden = torch.relu(preactivation)
            prediction = hidden @ w2 + b2

            d_prediction = 2 * (prediction - targets) / x.shape[0]
            d_w2 = hidden.T @ d_prediction
            d_b2 = d_prediction.sum()
            d_hidden = d_prediction[:, None] * w2[None, :]
            d_preactivation = d_hidden * (preactivation > 0)
            d_w1 = d_preactivation.T @ x
            d_b1 = d_preactivation.sum(dim=0)
            return [d_w1.tolist(), d_b1.tolist(), d_w2.tolist(), d_b2.item()]
        """,

        "ml.adam-step": """
        def adam_step(parameters, gradients, m, v, step, learning_rate, beta1, beta2, epsilon):
            import torch

            parameters = torch.as_tensor(parameters, dtype=torch.float64)
            gradients = torch.as_tensor(gradients, dtype=torch.float64)
            m = torch.as_tensor(m, dtype=torch.float64)
            v = torch.as_tensor(v, dtype=torch.float64)
            new_m = beta1 * m + (1 - beta1) * gradients
            new_v = beta2 * v + (1 - beta2) * gradients.square()
            m_hat = new_m / (1 - beta1 ** step)
            v_hat = new_v / (1 - beta2 ** step)
            updated = parameters - learning_rate * m_hat / (torch.sqrt(v_hat) + epsilon)
            return [updated.tolist(), new_m.tolist(), new_v.tolist()]
        """,

        "ml.conv2d-valid": """
        def conv2d_valid(image, kernel, bias, stride):
            import torch
            import torch.nn.functional as F

            image = torch.as_tensor(image, dtype=torch.float64)[None, None, :, :]
            kernel = torch.as_tensor(kernel, dtype=torch.float64)[None, None, :, :]
            bias = torch.as_tensor([bias], dtype=torch.float64)
            output = F.conv2d(image, kernel, bias=bias, stride=stride)
            return output[0, 0].tolist()
        """,

        "ml.max-pool2d": """
        def max_pool2d(feature_map, pool_size, stride):
            import torch
            import torch.nn.functional as F

            feature_map = torch.as_tensor(feature_map, dtype=torch.float64)[None, None, :, :]
            output = F.max_pool2d(feature_map, kernel_size=pool_size, stride=stride)
            return output[0, 0].tolist()
        """,

        "ml.scaled-attention": """
        def scaled_dot_product_attention(query, key, value, mask):
            import math
            import torch

            query = torch.as_tensor(query, dtype=torch.float64)
            key = torch.as_tensor(key, dtype=torch.float64)
            value = torch.as_tensor(value, dtype=torch.float64)
            mask = torch.as_tensor(mask, dtype=torch.bool)
            scores = (query @ key.transpose(-2, -1)) / math.sqrt(query.shape[-1])
            probabilities = torch.softmax(scores.masked_fill(~mask, -torch.inf), dim=-1)
            return (probabilities @ value).tolist()
        """,

        "ml.causal-self-attention": """
        def causal_self_attention(tokens, wq, wk, wv):
            import math
            import torch

            tokens = torch.as_tensor(tokens, dtype=torch.float64)
            wq = torch.as_tensor(wq, dtype=torch.float64)
            wk = torch.as_tensor(wk, dtype=torch.float64)
            wv = torch.as_tensor(wv, dtype=torch.float64)
            query = tokens @ wq
            key = tokens @ wk
            value = tokens @ wv
            scores = (query @ key.transpose(-2, -1)) / math.sqrt(query.shape[-1])
            causal = torch.ones_like(scores, dtype=torch.bool).tril()
            probabilities = torch.softmax(scores.masked_fill(~causal, -torch.inf), dim=-1)
            return (probabilities @ value).tolist()
        """,

        "ml.multi-head-causal-attention": """
        def multi_head_causal_attention(tokens, wq, wk, wv, wo, num_heads):
            import math
            import torch

            tokens = torch.as_tensor(tokens, dtype=torch.float64)
            matrices = [torch.as_tensor(matrix, dtype=torch.float64) for matrix in (wq, wk, wv)]
            sequence_length = tokens.shape[0]
            model_width = matrices[0].shape[1]
            head_width = model_width // num_heads

            projected = [tokens @ matrix for matrix in matrices]
            query, key, value = [
                tensor.reshape(sequence_length, num_heads, head_width).transpose(0, 1)
                for tensor in projected
            ]
            scores = (query @ key.transpose(-2, -1)) / math.sqrt(head_width)
            causal = torch.ones(sequence_length, sequence_length, dtype=torch.bool).tril()
            probabilities = torch.softmax(scores.masked_fill(~causal, -torch.inf), dim=-1)
            attended = probabilities @ value
            concatenated = attended.transpose(0, 1).contiguous().reshape(sequence_length, model_width)
            output = concatenated @ torch.as_tensor(wo, dtype=torch.float64)
            return output.tolist()
        """,

        "ml.kmeans-step": """
        def kmeans_step(points, centroids):
            import torch

            points = torch.as_tensor(points, dtype=torch.float64)
            centroids = torch.as_tensor(centroids, dtype=torch.float64)
            differences = points[:, None, :] - centroids[None, :, :]
            distances = differences.square().sum(dim=-1)
            assignments = distances.argmin(dim=1)
            updated = centroids.clone()
            for cluster in range(centroids.shape[0]):
                members = points[assignments == cluster]
                if len(members):
                    updated[cluster] = members.mean(dim=0)
            return [assignments.tolist(), updated.tolist()]
        """,

        "ml.macro-f1": """
        def macro_f1_score(true_labels, predicted_labels, num_classes):
            import torch

            truth = torch.as_tensor(true_labels, dtype=torch.long)[:, None]
            prediction = torch.as_tensor(predicted_labels, dtype=torch.long)[:, None]
            classes = torch.arange(num_classes)[None, :]
            true_mask = truth == classes
            predicted_mask = prediction == classes
            true_positive = (true_mask & predicted_mask).sum(dim=0)
            false_positive = (~true_mask & predicted_mask).sum(dim=0)
            false_negative = (true_mask & ~predicted_mask).sum(dim=0)
            denominator = 2 * true_positive + false_positive + false_negative
            scores = torch.where(denominator > 0, 2 * true_positive / denominator, 0.0)
            return scores.mean().item()
        """,

        "ml.beam-search": """
        def beam_search_decode(transition_log_probs, beam_width, start_token, eos_token, max_steps):
            import torch

            transitions = torch.as_tensor(transition_log_probs, dtype=torch.float64)
            beams = [(0.0, [start_token])]
            for _ in range(max_steps):
                active = [(score, tokens) for score, tokens in beams if tokens[-1] != eos_token]
                completed = [(score, tokens) for score, tokens in beams if tokens[-1] == eos_token]
                candidates = list(completed)
                if active:
                    previous = torch.tensor([tokens[-1] for _, tokens in active])
                    base = torch.tensor([score for score, _ in active])[:, None]
                    flat_scores = (base + transitions[previous]).reshape(-1)
                    for flat_index, score in enumerate(flat_scores.tolist()):
                        beam_index, token = divmod(flat_index, transitions.shape[0])
                        candidates.append((score, active[beam_index][1] + [token]))
                candidates.sort(key=lambda beam: (-beam[0], beam[1]))
                beams = candidates[:beam_width]
                if all(tokens[-1] == eos_token for _, tokens in beams):
                    break
            beams.sort(key=lambda beam: (-beam[0], beam[1]))
            return beams[0][1:]
        """,

        "ml.pad-sequences": """
        def pad_sequences(sequences, pad_value):
            import torch

            lengths = torch.tensor([len(sequence) for sequence in sequences])
            width = int(lengths.max())
            padded = torch.full((len(sequences), width), pad_value, dtype=torch.long)
            for row, sequence in enumerate(sequences):
                if sequence:
                    padded[row, :len(sequence)] = torch.tensor(sequence)
            positions = torch.arange(width).unsqueeze(0).expand(len(sequences), -1)
            mask = positions < lengths.unsqueeze(1)
            return [padded.tolist(), mask.to(torch.int64).tolist(), lengths.tolist()]
        """,

        "ml.accumulate-gradients": """
        def accumulate_gradients(gradient_batches, batch_sizes):
            import torch

            gradients = torch.as_tensor(gradient_batches, dtype=torch.float64)
            sizes = torch.as_tensor(batch_sizes, dtype=torch.float64)
            weighted_sum = (gradients * sizes[:, None]).sum(dim=0)
            return (weighted_sum / sizes.sum()).tolist()
        """
    ]

    private static let einsumCodeByProblemID: [String: String] = [
        "ml.scaled-attention": """
        def scaled_dot_product_attention(query, key, value, mask):
            import math
            import torch
            from einops import einsum

            query = torch.as_tensor(query, dtype=torch.float64)
            key = torch.as_tensor(key, dtype=torch.float64)
            value = torch.as_tensor(value, dtype=torch.float64)
            mask = torch.as_tensor(mask, dtype=torch.bool)
            scores = einsum(
                query, key,
                "queries feature, keys feature -> queries keys",
            ) / math.sqrt(query.shape[-1])
            probabilities = torch.softmax(scores.masked_fill(~mask, -torch.inf), dim=-1)
            output = einsum(
                probabilities, value,
                "queries keys, keys value_feature -> queries value_feature",
            )
            return output.tolist()
        """,

        "ml.causal-self-attention": """
        def causal_self_attention(tokens, wq, wk, wv):
            import math
            import torch
            from einops import einsum

            tokens = torch.as_tensor(tokens, dtype=torch.float64)
            wq = torch.as_tensor(wq, dtype=torch.float64)
            wk = torch.as_tensor(wk, dtype=torch.float64)
            wv = torch.as_tensor(wv, dtype=torch.float64)
            query = einsum(tokens, wq, "token input, input model -> token model")
            key = einsum(tokens, wk, "token input, input model -> token model")
            value = einsum(tokens, wv, "token input, input model -> token model")
            scores = einsum(
                query, key,
                "query model, key model -> query key",
            ) / math.sqrt(query.shape[-1])
            causal = torch.ones_like(scores, dtype=torch.bool).tril()
            probabilities = torch.softmax(scores.masked_fill(~causal, -torch.inf), dim=-1)
            output = einsum(
                probabilities, value,
                "query key, key model -> query model",
            )
            return output.tolist()
        """,

        "ml.multi-head-causal-attention": """
        def multi_head_causal_attention(tokens, wq, wk, wv, wo, num_heads):
            import math
            import torch
            from einops import einsum, rearrange

            tokens = torch.as_tensor(tokens, dtype=torch.float64)
            matrices = [torch.as_tensor(matrix, dtype=torch.float64) for matrix in (wq, wk, wv)]
            query, key, value = [
                einsum(tokens, matrix, "token input, input model -> token model")
                for matrix in matrices
            ]
            query, key, value = [
                rearrange(tensor, "token (head feature) -> head token feature", head=num_heads)
                for tensor in (query, key, value)
            ]
            scores = einsum(
                query, key,
                "head query feature, head key feature -> head query key",
            ) / math.sqrt(query.shape[-1])
            causal = torch.ones(scores.shape[-2:], dtype=torch.bool).tril()
            probabilities = torch.softmax(scores.masked_fill(~causal, -torch.inf), dim=-1)
            attended = einsum(
                probabilities, value,
                "head query key, head key feature -> head query feature",
            )
            concatenated = rearrange(attended, "head token feature -> token (head feature)")
            output = einsum(
                concatenated, torch.as_tensor(wo, dtype=torch.float64),
                "token input, input output -> token output",
            )
            return output.tolist()
        """
    ]
}
