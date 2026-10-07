export function L2DIntroPost() {
  return (
    <div className="blog-post-body notebook-post">
      <section>
        <h2>The question</h2>
        <p>
          A conventional classifier always returns an answer. A learning-to-defer
          system gets another option: pass a decision to a person when that person
          is more likely to be right. The important comparison is therefore not
          simply “is the model uncertain?” but “is the available expert more
          likely to be correct than the model on this case?”
        </p>
        <p>
          This experiment compares two ways to rank cases for deferral. The first
          is a calibrated-confidence baseline, which sends the model&apos;s least
          confident findings to a radiologist. The second is one-vs-all learning
          to defer (OvA-L2D), which explicitly learns both class correctness and
          expert correctness.
        </p>
      </section>

      <section>
        <h2>The data, briefly</h2>
        <p>
          I use 6,125 chest X-rays from the radiologist-annotated{" "}
          <a href="https://doi.org/10.1038/s41597-022-01498-w">VinDr-CXR dataset</a>.
          Reader R9 is treated as the expert to whom the model can defer. The two
          other readers define the experimental reference: a finding is positive
          only when both mark it present, and a tie counts as absent. R9 never
          contributes to the reference used to judge R9.
        </p>
        <p>
          I retain 17 findings with sufficient training support and split the data
          into 3,701 training, 1,209 validation, and 1,215 test images. This is an
          annotation reference, not adjudicated clinical truth. A deferral applies
          to one finding on one X-ray—not necessarily the entire image.
        </p>
        <div className="post-facts" aria-label="Experiment summary">
          <div><strong>6,125</strong><span>R9-annotated images</span></div>
          <div><strong>17</strong><span>chest X-ray findings</span></div>
          <div><strong>1,215</strong><span>held-out test images</span></div>
        </div>
      </section>

      <section>
        <h2>The model</h2>
        <p>
          Both methods start from the same randomly initialised ResNet-18. Its
          image representation passes through a shared 256-unit layer, followed
          by one head per finding. The confidence baseline emits one binary logit
          per finding. OvA emits three: <em>absent</em>, <em>present</em>, and{" "}
          <em>defer</em>. The encoder and every head are trained end to end.
        </p>
        <pre className="code-block" aria-label="Simplified PyTorch model">
          <code>{`class L2DModel(nn.Module):
    def __init__(self, n_findings=17):
        super().__init__()
        self.encoder = resnet18(weights=None)
        self.encoder.fc = nn.Identity()
        self.shared = nn.Sequential(
            nn.Linear(512, 256), nn.ReLU(),
            nn.Dropout(0.1), nn.LayerNorm(256)
        )
        self.heads = nn.ModuleList([
            nn.Linear(256, 3) for _ in range(n_findings)
        ])

    def forward(self, images):
        h = self.shared(self.encoder(images))
        return torch.stack([head(h) for head in self.heads], dim=1)`}</code>
        </pre>
        <p>
          The three outputs are not a softmax over mutually exclusive actions.
          OvA treats them as independent binary questions, each transformed by a
          sigmoid. That distinction is what lets the defer output represent an
          estimate of expert correctness.
        </p>
      </section>

      <section>
        <h2>The one-vs-all deferral loss</h2>
        <p>
          For a binary finding, let <em>y</em> be the reference label, <em>m</em> the
          expert&apos;s answer, and <em>g</em><sub>0</sub>, <em>g</em><sub>1</sub>, and{" "}
          <em>g</em><sub>⊥</sub> the absent, present, and defer logits. The targets
          are deliberately simple:
        </p>
        <div className="loss-table" role="table" aria-label="One-vs-all loss targets">
          <div className="loss-row loss-header" role="row">
            <span role="columnheader">Output</span>
            <span role="columnheader">Target</span>
            <span role="columnheader">What it learns</span>
          </div>
          <div className="loss-row" role="row">
            <span role="cell">Absent, g<sub>0</sub></span>
            <span role="cell">𝟙[y = 0]</span>
            <span role="cell">Probability that absent is correct</span>
          </div>
          <div className="loss-row" role="row">
            <span role="cell">Present, g<sub>1</sub></span>
            <span role="cell">𝟙[y = 1]</span>
            <span role="cell">Probability that present is correct</span>
          </div>
          <div className="loss-row" role="row">
            <span role="cell">Defer, g<sub>⊥</sub></span>
            <span role="cell">𝟙[m = y]</span>
            <span role="cell">Probability that the expert is correct</span>
          </div>
        </div>
        <div className="equation" aria-label="The one-vs-all loss is binary cross entropy for the absent, present, and expert-correctness targets">
          L<sub>OvA</sub> = BCE(g<sub>0</sub>, 𝟙[y=0]) + BCE(g<sub>1</sub>, 𝟙[y=1]) + BCE(g<sub>⊥</sub>, 𝟙[m=y])
        </div>
        <p>
          In the notebook, the three binary cross-entropies are summed for each
          image–finding pair, averaged across the batch, and divided by ln&nbsp;2 so
          the loss is measured in bits. A numerically stable PyTorch version is:
        </p>
        <pre className="code-block" aria-label="Simplified one-vs-all loss in PyTorch">
          <code>{`def ova_loss(logits, y, expert):
    class_targets = F.one_hot(y.long(), num_classes=2).float()
    expert_correct = (expert == y).float()

    class_loss = F.binary_cross_entropy_with_logits(
        logits[..., :2], class_targets, reduction="none"
    ).sum(-1)
    defer_loss = F.binary_cross_entropy_with_logits(
        logits[..., 2], expert_correct, reduction="none"
    )
    return (class_loss + defer_loss).mean() / math.log(2)`}</code>
        </pre>
        <p>
          This loss comes from{" "}
          <a href="https://proceedings.mlr.press/v162/verma22c.html">
            Verma and Nalisnick, “Calibrated Learning to Defer with One-vs-All
            Classifiers” (ICML 2022)
          </a>. Their key result is that the OvA construction can yield calibrated
          estimates of expert correctness and is a consistent surrogate for the
          multiclass learning-to-defer objective. The notebook follows their{" "}
          <a href="https://github.com/rajevv/OvA-L2D/blob/main/losses/losses.py">
            released loss implementation
          </a>.
        </p>
      </section>

      <section>
        <h2>How the two methods decide what to defer</h2>
        <p>
          OvA turns each logit into an independent probability q = σ(g). The
          machine&apos;s predicted class is the larger of g<sub>0</sub> and g<sub>1</sub>.
          Its deferral priority is:
        </p>
        <div className="equation">
          priority<sub>OvA</sub> = q<sub>⊥</sub> − max(q<sub>0</sub>, q<sub>1</sub>)
        </div>
        <p>
          In words: defer where estimated expert correctness most exceeds
          estimated machine correctness. The confidence baseline instead trains a
          standard binary classifier, fits one temperature per finding using only
          validation data, and defers the least confident predictions first:
        </p>
        <div className="equation">
          priority<sub>confidence</sub> = −max(p, 1 − p)
        </div>
        <p>
          The baseline can identify model uncertainty, but it never learns where
          R9 is likely to help. That is the conceptual difference this comparison
          is designed to isolate.
        </p>
      </section>

      <section>
        <h2>What happened?</h2>
        <figure className="experiment-figure">
          <img
            src="/l2d-ova-vs-confidence.png"
            alt="Line chart comparing OvA learning to defer with calibrated confidence across deferral budgets. OvA has the higher normalized F1 area under the curve."
            width="1600"
            height="1000"
          />
          <figcaption>
            Test-set system performance as individual finding decisions are
            replaced by R9&apos;s answers. Higher is better.
          </figcaption>
        </figure>
        <p>
          At 0%, each method uses all of its own predictions. At 100%, every
          finding is sent to the same expert, so the curves meet. Between those
          endpoints, OvA produces the better routing curve in this run. Its
          normalized F1 area under the curve is 0.8707, compared with 0.8543 for
          calibrated confidence.
        </p>
        <aside className="method-note">
          <strong>How to read this result.</strong> The area integrates system F1
          across deferral budgets; it is not ROC AUC. Neither training objective
          directly optimises F1. This is a single-seed, matched experiment, so it
          illustrates the routing behaviour rather than establishing statistical
          superiority.
        </aside>
      </section>

      <section className="post-references">
        <h2>References</h2>
        <ol>
          <li>
            R. Verma and E. Nalisnick. “Calibrated Learning to Defer with
            One-vs-All Classifiers.” <em>Proceedings of ICML</em>, 2022.{" "}
            <a href="https://proceedings.mlr.press/v162/verma22c.html">Paper</a>
          </li>
          <li>
            H. Q. Nguyen et al. “VinDr-CXR: An open dataset of chest X-rays with
            radiologist&apos;s annotations.” <em>Scientific Data</em> 9, 429, 2022.{" "}
            <a href="https://doi.org/10.1038/s41597-022-01498-w">Paper</a>
          </li>
        </ol>
      </section>
    </div>
  );
}
