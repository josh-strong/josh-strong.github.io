import { Latex } from "../latex";
import { PythonCodeBlock } from "../python-code";

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
          one-vs-all learning to defer (OvA-L2D), and include random deferral as
          a sanity check. OvA learns something more useful than uncertainty alone:
          how likely the model and the available expert are to be correct on each
          decision.
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
      </section>

      <section>
        <h2>The model</h2>
        <p>
          Both methods start from the same randomly initialised {" "}
          <a href="https://openaccess.thecvf.com/content_cvpr_2016/html/He_Deep_Residual_Learning_CVPR_2016_paper.html">
            ResNet-18
          </a>. Its image representation passes through a shared 256-unit layer,
          followed by one head per finding. The confidence baseline emits one
          binary logit per finding. OvA emits three: <em>absent</em>, {" "}
          <em>present</em>, and <em>defer</em>. The encoder and every head are
          trained end to end.
        </p>
        <p>
          The multi-label architecture below shows that structure explicitly.
          The X-ray is encoded once, then each pathology head makes its own
          three-way OvA-L2D assessment. Each head receives an independent
          deferral loss, and those per-finding losses are summed to train the
          full model.
        </p>
        <figure className="architecture-figure">
          <div className="architecture-figure-scroll">
            <img
              src="/multilabel-l2d-architecture.png"
              alt="Multi-label learning-to-defer architecture: a chest X-ray passes through a shared feature extractor and one head per pathology. Each head emits absent, present, and defer logits, receives an independent learning-to-defer loss, and the losses are summed."
              width="1045"
              height="357"
            />
          </div>
          <figcaption>
            Multi-label OvA-L2D architecture. For finding {" "}
            <Latex>{"i"}</Latex>, the head emits absent, present, and defer
            logits <Latex>{"(g_0^i,g_1^i,g_\\perp^i)"}</Latex>. Its loss depends
            on the reference label <Latex>{"y^i"}</Latex> and the expert label {" "}
            <Latex>{"m^i"}</Latex>; the model minimises the sum across all {" "}
            <Latex>{"\\ell"}</Latex> findings.
          </figcaption>
        </figure>
        <PythonCodeBlock
          label="Simplified PyTorch model"
          code={`class L2DModel(nn.Module):
    def __init__(self, n_findings=17):
        super().__init__()
        # Keep the image features; discard ResNet's original classifier.
        self.encoder = resnet18(weights=None)
        self.encoder.fc = nn.Identity()

        # Compress the shared representation before branching by finding.
        self.shared = nn.Sequential(
            nn.Linear(512, 256), nn.ReLU(),
            nn.Dropout(0.1), nn.LayerNorm(256)
        )

        # Each head emits: absent, present, and defer.
        self.heads = nn.ModuleList([
            nn.Linear(256, 3) for _ in range(n_findings)
        ])

    def forward(self, images):
        h = self.shared(self.encoder(images))
        # Output shape: [batch, findings, 3].
        return torch.stack([head(h) for head in self.heads], dim=1)`}
        />
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
            "\\psi_{\\mathrm{OvA}}(g_1,\\ldots,g_K,g_\\perp;\\,x,y,m)\n" +
            "&= \\phi\\!\\left(g_y(x)\\right)\n" +
            "+ \\sum_{\\substack{y'\\in\\mathcal{Y}\\\\y'\\neq y}}\n" +
            "  \\phi\\!\\left(-g_{y'}(x)\\right) \\\\\n" +
            "&\\quad + \\phi\\!\\left(-g_\\perp(x)\\right)\n" +
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
            "={}&\\operatorname{BCELogit}\\!\\left(g_0,\\mathbb{I}[y=0]\\right)\n" +
            "+\\operatorname{BCELogit}\\!\\left(g_1,\\mathbb{I}[y=1]\\right) \\\\\n" +
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
        <PythonCodeBlock
          label="Simplified one-vs-all loss in PyTorch"
          code={`def ova_loss(logits, y, expert):
    # Targets for the absent and present logits.
    class_targets = F.one_hot(y.long(), num_classes=2).float()

    # The defer logit learns when this expert is correct.
    expert_correct = (expert == y).float()

    class_loss = F.binary_cross_entropy_with_logits(
        logits[..., :2], class_targets, reduction="none"
    ).sum(-1)
    defer_loss = F.binary_cross_entropy_with_logits(
        logits[..., 2], expert_correct, reduction="none"
    )

    # Sum the three OvA terms and report the batch mean in bits.
    return (class_loss + defer_loss).mean() / math.log(2)`}
        />
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
        <h2>Three ways to decide when to ask a human</h2>
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
        <p>
          Random deferral uses that same calibrated classifier but chooses which
          individual finding decisions to hand to R9 uniformly at random. I
          average 200 independent random orderings (seed 1), sampled without
          replacement, so every point still defers exactly the requested number
          of decisions. The routing score uses no labels, confidence, or expert
          correctness: it is a deliberately uninformed baseline.
        </p>
      </section>

      <section>
        <h2>How deferral helps</h2>
        <figure className="experiment-figure">
          <img
            src="/l2d-ova-vs-confidence-random.png"
            alt="Line chart comparing OvA learning to defer, calibrated confidence, and random deferral across deferral budgets. OvA has the highest normalized F1 area under the curve, followed by calibrated confidence and random deferral."
            width="1600"
            height="1000"
          />
          <figcaption>
            Test-set system performance as individual finding decisions are
            replaced by R9&apos;s answers. Random deferral is the mean of 200
            independent orderings. Higher is better.
          </figcaption>
        </figure>
        <p>
          At 0%, each method uses machine predictions. Calibrated confidence and
          random deferral begin at exactly the same point because they use the
          same classifier. At 100%, every finding is sent to the same expert, so
          all three curves meet. Between those endpoints, random deferral shows
          what happens when the handovers contain no information about who is
          likely to be right.
        </p>
        <p>
          Calibrated confidence improves on random routing while holding the
          machine fixed, which isolates the value of sending uncertain decisions
          first. OvA produces the best routing curve in this run because its
          ranking can also account for where the radiologist is likely to help—not
          merely where the model is unsure. The normalized F1 areas under the
          curve are 0.8707 for OvA-L2D, 0.8543 for calibrated confidence, and
          0.8402 for random deferral.
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
            K. He, X. Zhang, S. Ren, and J. Sun. “Deep Residual Learning for
            Image Recognition.” <em>Proceedings of CVPR</em>, 2016. {" "}
            <a href="https://openaccess.thecvf.com/content_cvpr_2016/html/He_Deep_Residual_Learning_CVPR_2016_paper.html">
              Paper
            </a>
          </li>
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
            The learned models use one matched training seed, while the random
            baseline averages 200 routing permutations. Performance is summarised
            using pooled binary macro-F1. The area integrates F1 across deferral
            budgets; it is not ROC AUC, and it should not be read as evidence of
            statistical superiority.
          </li>
        </ul>
      </section>
    </div>
  );
}
