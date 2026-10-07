import { Latex } from "../latex";

export function L2DIntroPost() {
  return (
    <div className="blog-post-body notebook-post">
      <section>
        <h2>What this example demonstrates</h2>
        <p>
          Imagine a model reviewing a chest X-ray for several possible findings.
          It can answer every question itself, or it can pass selected decisions
          to a radiologist. The useful system is not necessarily the one that
          automates the most. It is the one that gives each decision to whoever is
          more likely to get it right.
        </p>
        <p>
          This retrospective experiment uses real chest X-rays and real human
          annotations to make that idea concrete. I compare a familiar baseline—
          send the model&apos;s least confident findings to a radiologist—with
          one-vs-all learning to defer (OvA-L2D). OvA learns something more useful
          than uncertainty alone: how likely the model and the available expert
          are to be correct on each decision.
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
          into 3,701 training, 1,209 validation, and 1,215 test images. A deferral
          applies to one finding on one X-ray—not necessarily the entire image.
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
          I use the notation from Verma and Nalisnick&apos;s paper first. Let{" "}
          <Latex>{"\\mathcal{Y}=\\{1,\\ldots,K\\}"}</Latex> be the class set,{" "}
          <Latex>{"y\\in\\mathcal{Y}"}</Latex> the reference label,{" "}
          <Latex>{"m\\in\\mathcal{Y}"}</Latex> the expert&apos;s answer, and{" "}
          <Latex>{"g_1(x),\\ldots,g_K(x),g_\\perp(x)"}</Latex> the class and
          defer logits. Their point-wise OvA surrogate is Equation&nbsp;(8):
        </p>
        <Latex display>
          {"\\begin{aligned}\n" +
            "\\psi_{\\mathrm{OvA}}&(g_1,\\ldots,g_K,g_\\perp;\\,x,y,m) \\\\\n" +
            "&= \\phi\\!\\left(g_y(x)\\right)\n" +
            "+ \\sum_{\\substack{y'\\in\\mathcal{Y}\\\\y'\\neq y}}\n" +
            "  \\phi\\!\\left(-g_{y'}(x)\\right)\n" +
            "+ \\phi\\!\\left(-g_\\perp(x)\\right) \\\\\n" +
            "&\\quad\n" +
            "+ \\mathbb{I}[m=y]\\!\n" +
            "  \\left[\n" +
            "    \\phi\\!\\left(g_\\perp(x)\\right)\n" +
            "    - \\phi\\!\\left(-g_\\perp(x)\\right)\n" +
            "  \\right].\n" +
            "\\end{aligned}"}
        </Latex>
        <p>
          Here <Latex>{"\\phi"}</Latex> can be any suitable binary surrogate.
          The notebook uses the logistic loss:
        </p>
        <Latex display>
          {"\\phi(t)=\\log\\!\\left(1+\\exp(-t)\\right)."}
        </Latex>
        <p>
          The first two terms form <Latex>{"K"}</Latex> one-vs-all class
          problems. The final line forms one more binary problem for expert
          correctness. When <Latex>{"m=y"}</Latex>, it reduces to{" "}
          <Latex>{"\\phi(g_\\perp(x))"}</Latex>; otherwise it reduces to{" "}
          <Latex>{"\\phi(-g_\\perp(x))"}</Latex>. This is exactly why the defer
          output is trained against whether the expert was correct.
        </p>
        <p>
          For each binary chest X-ray finding in this notebook,{" "}
          <Latex>{"\\mathcal{Y}=\\{0,1\\}"}</Latex>. Equation&nbsp;(8) is therefore
          implemented as three binary-cross-entropy-with-logits terms:
        </p>
        <Latex display>
          {"\\begin{aligned}\n" +
            "\\mathcal{L}_{\\mathrm{binary}}\n" +
            "={}&\\operatorname{BCELogit}\\!\\left(g_0,\\mathbb{I}[y=0]\\right) \\\\\n" +
            "&+\\operatorname{BCELogit}\\!\\left(g_1,\\mathbb{I}[y=1]\\right) \\\\\n" +
            "&+\\operatorname{BCELogit}\\!\\left(g_\\perp,\\mathbb{I}[m=y]\\right).\n" +
            "\\end{aligned}"}
        </Latex>
        <p>The three targets can be read directly as:</p>
        <div className="loss-table" role="table" aria-label="One-vs-all loss targets">
          <div className="loss-row loss-header" role="row">
            <span role="columnheader">Output</span>
            <span role="columnheader">Target</span>
            <span role="columnheader">What it learns</span>
          </div>
          <div className="loss-row" role="row">
            <span role="cell">Absent, <Latex>{"g_0"}</Latex></span>
            <span role="cell"><Latex>{"\\mathbb{I}[y=0]"}</Latex></span>
            <span role="cell">Probability that absent is correct</span>
          </div>
          <div className="loss-row" role="row">
            <span role="cell">Present, <Latex>{"g_1"}</Latex></span>
            <span role="cell"><Latex>{"\\mathbb{I}[y=1]"}</Latex></span>
            <span role="cell">Probability that present is correct</span>
          </div>
          <div className="loss-row" role="row">
            <span role="cell">Defer, <Latex>{"g_\\perp"}</Latex></span>
            <span role="cell"><Latex>{"\\mathbb{I}[m=y]"}</Latex></span>
            <span role="cell">Probability that the expert is correct</span>
          </div>
        </div>
        <p>
          In the notebook, the three binary cross-entropies are summed for each
          image–finding pair, averaged across the batch, and divided by{" "}
          <Latex>{"\\ln 2"}</Latex> so the loss is measured in bits. That final
          scaling does not change the minimiser. A numerically stable PyTorch
          version is:
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
        <h2>Two ways to decide when to ask a human</h2>
        <p>
          The paper defines the classifier and hard rejector directly from the
          logits:
        </p>
        <Latex display>
          {"\\hat y=h(x)=\\arg\\max_{k\\in\\{0,1\\}}g_k(x),\n" +
            "\\qquad\n" +
            "r(x)=\\mathbb{I}\\!\\left[\n" +
            "g_\\perp(x)\\geq\\max_{k\\in\\{0,1\\}}g_k(x)\n" +
            "\\right]."}
        </Latex>
        <p>
          With logistic loss, the independent sigmoid outputs estimate class
          probability and expert correctness:
        </p>
        <Latex display>
          {"\\hat p_k(x)=\\sigma(g_k(x)),\n" +
            "\\qquad\n" +
            "\\hat p_m(x)=\\sigma(g_\\perp(x))."}
        </Latex>
        <p>
          To draw a full performance curve across many deferral budgets, the
          notebook uses the corresponding continuous advantage score:
        </p>
        <Latex display>
          {"s_{\\mathrm{OvA}}(x)\n" +
            "=\\sigma(g_\\perp(x))\n" +
            "-\\max_{k\\in\\{0,1\\}}\\sigma(g_k(x))."}
        </Latex>
        <p>
          In words: defer where estimated expert correctness most exceeds
          estimated machine correctness. The confidence baseline instead trains a
          standard binary classifier, fits one temperature per finding using only
          validation data, and defers the least confident predictions first:
        </p>
        <Latex display>
          {"s_{\\mathrm{confidence}}(x)\n" +
            "=-\\max\\!\\left(p(x),1-p(x)\\right)."}
        </Latex>
        <p>
          The baseline can identify model uncertainty, but it never learns where
          R9 is likely to help. That is the conceptual difference this comparison
          is designed to isolate.
        </p>
      </section>

      <section>
        <h2>How deferral helps</h2>
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
          endpoints, system performance initially improves as useful cases are
          handed to R9. OvA produces the better routing curve in this run because
          its ranking can account for where the radiologist is likely to help—not
          merely where the model is unsure. Its normalized F1 area under the curve
          is 0.8707, compared with 0.8543 for calibrated confidence.
        </p>
        <p>
          That is the practical promise of learning to defer: a handover policy
          can improve the combined human–AI system without assuming that either
          participant is always better. It learns a division of work from their
          complementary patterns of success and failure.
        </p>
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

      <section className="post-limitations">
        <h2>Limitations</h2>
        <p>
          This is a useful demonstration, not a prospective clinical evaluation.
          Several limitations matter when interpreting it:
        </p>
        <ul className="limitations-list">
          <li>
            The experimental “ground truth” is agreement between only two
            clinicians, with ties counted as absent. It is an annotation reference,
            not an adjudicated diagnosis or patient-level clinical truth.
          </li>
          <li>
            Each of the 17 findings is deferred independently. Related findings
            can therefore be handed over in logically inconsistent ways—for
            example, predicting a specific child finding while deferring its
            implied parent. This is the problem we tackle in our next NeurIPS
            paper,{" "}
            <a href="/blog/coherent-hierarchical-learning-to-defer">
              Coherent Hierarchical Multi-Label Learning to Defer
            </a>.
          </li>
          <li>
            R9 is a single, fixed expert observed during training. A deployed
            system would encounter clinicians with different expertise, workloads,
            and availability, including people it had never seen before.
          </li>
          <li>
            The analysis is retrospective. It does not measure how deferral would
            change a clinical workflow, turnaround time, radiologist behaviour, or
            patient outcomes.
          </li>
          <li>
            The comparison uses one matched training seed and a pooled binary
            macro-F1 summary. The area integrates F1 across deferral budgets; it is
            not ROC AUC, and it should not be read as evidence of statistical
            superiority.
          </li>
        </ul>
      </section>
    </div>
  );
}
