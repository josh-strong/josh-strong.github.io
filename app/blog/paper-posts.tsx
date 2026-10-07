import type { ReactNode } from "react";
import { Latex } from "../latex";

function PaperFigure({
  src,
  alt,
  width,
  height,
  children,
  className = "",
}: {
  src: string;
  alt: string;
  width: number;
  height: number;
  children: ReactNode;
  className?: string;
}) {
  return (
    <figure className={`paper-figure ${className}`.trim()}>
      <div className="paper-figure-frame">
        {/* Static paper crops are already web-sized; serve them directly. */}
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src={src} alt={alt} width={width} height={height} />
      </div>
      <figcaption>{children}</figcaption>
    </figure>
  );
}

export function L2DSurveyPost() {
  return (
    <div className="blog-post-body paper-story survey-post">
      <section>
        <h2>Why the field needed a map</h2>
        <p>
          Learning to defer began with a deceptively compact question: should a
          model answer this case, or pass it to an expert? The literature now
          spans joint and modular training, different notions of consistency,
          regression and sequential decisions, changing expert pools, capacity
          constraints, fairness, and safety.
        </p>
        <p>
          Those developments are useful, but they also made papers difficult to
          compare. The same system can be described through different
          architectures, losses, assumptions, and evaluation protocols. Our
          survey gives that work a common map—and makes the design choices behind
          a deferral system easier to see.
        </p>
        <aside className="method-note">
          <strong>The organising question:</strong> what is being learned, under
          which assumptions, and what must remain true when the system meets the
          constraints of a real human–AI workflow?
        </aside>
      </section>

      <section>
        <h2>Four branches, one decision problem</h2>
        <PaperFigure
          src="/paper-figures/l2d-survey-taxonomy.png"
          alt="Taxonomy of learning to defer research, organised into methodological frameworks, theoretical foundations, task generalisations, and real-world adaptations"
          width={1000}
          height={895}
          className="survey-taxonomy-figure wide-paper-figure"
        >
          The survey&apos;s four-branch taxonomy. The branches are not a ranking;
          they are a way to locate the assumption a paper changes. Adapted from
          Figure 2 of the survey.
        </PaperFigure>

        <div className="branch-grid">
          <article>
            <span>01</span>
            <h3>Methodological frameworks</h3>
            <p>
              Is the predictor learned jointly with the deferral policy, kept
              fixed, or fine-tuned after pretraining?
            </p>
          </article>
          <article>
            <span>02</span>
            <h3>Optimisation &amp; theory</h3>
            <p>
              Which surrogate loss recovers the intended decision rule, and what
              kind of consistency or regret guarantee does it provide?
            </p>
          </article>
          <article>
            <span>03</span>
            <h3>Task generalisations</h3>
            <p>
              How does deferral change for regression, multi-task outputs,
              committees, sequences, or causal pipelines?
            </p>
          </article>
          <article>
            <span>04</span>
            <h3>Real-world adaptations</h3>
            <p>
              What happens when annotations are scarce, experts rotate, budgets
              bind, or robustness and fairness become operational requirements?
            </p>
          </article>
        </div>
      </section>

      <section>
        <h2>Three ways to build the system</h2>
        <p>
          A useful first distinction is not the loss function but which parts of
          the system can actually be changed. This determines what the predictor
          and rejector can learn about one another.
        </p>
        <div className="framework-track" role="list">
          <article role="listitem">
            <div className="framework-track-label"><b>1</b> Joint</div>
            <h3>One-stage learning</h3>
            <p>
              Train predictor and deferral mechanism together from scratch. They
              can specialise to one another, which is powerful but can make the
              system brittle when experts or constraints change.
            </p>
          </article>
          <article role="listitem">
            <div className="framework-track-label"><b>2</b> Frozen</div>
            <h3>Two-stage learning</h3>
            <p>
              Keep an existing predictor fixed and learn a router around it. This
              is the natural choice for deployed models and black-box APIs, and
              is easier to update when the expert pool changes.
            </p>
          </article>
          <article role="listitem">
            <div className="framework-track-label"><b>3</b> Adapted</div>
            <h3>Post-hoc fine-tuning</h3>
            <p>
              Start from a pretrained predictor, then jointly adapt it with a new
              rejector. This sits between modularity and co-adaptation.
            </p>
          </article>
        </div>
      </section>

      <section>
        <h2>A practical reading of the theory</h2>
        <p>
          A consistent surrogate is valuable because improving its training loss
          should move the learned policy toward the Bayes-optimal handover rule.
          But the guarantee is conditional: it depends on the architecture,
          training framework, cost definition, hypothesis class, and expert
          assumptions. A theorem for a fixed expert and joint training does not
          automatically transfer to a frozen predictor or a changing expert pool.
        </p>
        <div className="implementation-card">
          <h3>Before choosing a loss, write down:</h3>
          <ul className="check-list">
            <li>Whether the predictor is trainable, frozen, or accessible only through an API.</li>
            <li>What an expert query costs—and whether that cost changes with workload.</li>
            <li>Whether expert correctness can be estimated and calibrated on the cases that matter.</li>
            <li>Which constraints apply at inference: budgets, fairness, latency, or routing policy.</li>
            <li>Which system-level curves and failure modes will be reported beyond headline accuracy.</li>
          </ul>
        </div>
      </section>

      <section className="post-conclusion">
        <h2>Conclusion</h2>
        <p>
          The survey&apos;s main message is that learning to defer is no longer a
          single loss-function problem. It is a family of allocation problems,
          and each formulation encodes a view of the predictor, the expert, the
          cost of consultation, and the world in which they will operate. The
          right method is the one whose assumptions match that world.
        </p>
      </section>
    </div>
  );
}

export function HealthcareReviewPost() {
  return (
    <div className="blog-post-body paper-story review-post">
      <section>
        <h2>The evidence is about teams, not tools</h2>
        <p>
          Calling a system “human in the loop” says very little about how people
          and AI actually share a task. The AI may act as a second reader,
          prioritise cases, draft an output for verification, or influence a
          treatment decision. Each arrangement changes what success means.
        </p>
        <p>
          We therefore reviewed empirical human–AI collaboration studies across
          healthcare rather than asking whether AI was accurate in isolation. The
          review covers work published from January 2015 to October 2025 and maps
          where collaboration was tested, how it was evaluated, and which
          technical, human, and organisational factors shaped the result.
        </p>

        <div className="evidence-stats" aria-label="Scoping review at a glance">
          <article><strong>17,463</strong><span>records identified</span></article>
          <article><strong>140</strong><span>studies included</span></article>
          <article><strong>88</strong><span>diagnostic interpretation studies</span></article>
          <article><strong>57</strong><span>studies measuring trust</span></article>
        </div>
      </section>

      <section>
        <h2>Where the evidence is concentrated</h2>
        <PaperFigure
          src="/paper-figures/haic-study-map.png"
          alt="Alluvial diagram linking clinical task context, evaluation design, and reported outcome direction across 140 studies"
          width={1040}
          height={490}
          className="wide-paper-figure"
        >
          How the 140 included studies move from clinical task to evaluation
          design and reported outcome direction. Task categories are not mutually
          exclusive. From Figure ii of the paper (CC BY 4.0).
        </PaperFigure>
        <p>
          Diagnostic interpretation dominates the literature. Eighty-six studies
          made a direct human-only versus human-plus-AI comparison; the rest used
          qualitative, survey, implementation, or other non-comparative designs.
          Positive-direction findings were common, but that should not be read as
          a pooled estimate of effectiveness: tasks, designs, and outcomes were
          heterogeneous, and many studies were controlled reader experiments.
        </p>
        <aside className="method-note">
          <strong>A useful warning:</strong> “positive” can mean better diagnostic
          accuracy, faster work, higher acceptance, or another study-defined
          outcome. It does not necessarily mean better patient or system outcomes.
        </aside>
      </section>

      <section>
        <h2>What makes collaboration work?</h2>
        <p>
          Benefits depended on alignment between the technology, the person using
          it, and the organisation around them. Four recurring determinants cut
          across the literature.
        </p>
        <div className="determinant-grid">
          <article>
            <span>Task</span>
            <h3>Complement the judgement</h3>
            <p>Bounded subtasks—prioritisation, highlighting, drafting, or pre-segmentation—were the clearest fit.</p>
          </article>
          <article>
            <span>Interface</span>
            <h3>Communicate uncertainty</h3>
            <p>Explanations sometimes helped, but could also add cognitive load or invite unwarranted certainty.</p>
          </article>
          <article>
            <span>People</span>
            <h3>Train for appropriate use</h3>
            <p>Onboarding and continuing support matter, especially when users must detect when the AI is wrong.</p>
          </article>
          <article>
            <span>Organisation</span>
            <h3>Fit the real workflow</h3>
            <p>Integration, leadership, escalation routes, and shared success criteria shape whether a tool is usable.</p>
          </article>
        </div>
      </section>

      <section>
        <h2>Trust is not the same as reliance</h2>
        <PaperFigure
          src="/paper-figures/haic-trust-evidence.png"
          alt="Bar charts showing how trust was measured and which trust-related effects were reported in 57 healthcare human-AI studies"
          width={1040}
          height={450}
          className="wide-paper-figure"
        >
          Trust was usually measured by self-report; only six studies used
          calibration metrics. Increased acceptance was much more often reported
          than calibrated or appropriate trust. From Figure iii of the paper (CC
          BY 4.0).
        </PaperFigure>
        <p>
          The goal should not be to maximise trust. It should be to support
          <em> appropriately calibrated trust</em>: reliance when the AI is likely
          to help, and scrutiny or override when it is not. A stronger evaluation
          triangulates subjective ratings, observed behaviour such as advice-taking
          and escalation, and calibration against objective correctness.
        </p>
      </section>

      <section>
        <h2>What better evidence would look like</h2>
        <div className="evidence-layers">
          <article><span>Decision</span><p>Accuracy, time, workload, cognitive burden, and reliance at the point of use.</p></article>
          <article><span>Workflow</span><p>Adoption, escalation, override, equity, and how work is redistributed across a service.</p></article>
          <article><span>Patient &amp; system</span><p>Clinical outcomes, resource use, safety events, and whether benefits persist over time.</p></article>
          <article><span>Governance</span><p>Traceability, contestability, accountability, and explicit control over how AI shapes decisions.</p></article>
        </div>
        <p>
          Only 11 of the 140 studies used implementation-focused designs.
          Accountability and safety were often discussed but rarely tested. The
          evidence base now needs to move beyond short-term task comparisons
          toward longitudinal, in-situ studies of the complete clinical system.
        </p>
      </section>

      <section className="post-conclusion">
        <h2>Conclusion</h2>
        <p>
          Human oversight is not a safety property by itself. Collaboration works
          when the task is well matched, the interface supports appropriate
          reliance, the workflow makes intervention possible, and governance
          gives people meaningful control. The unit of evaluation must therefore
          be the human–AI system in context—not the model alone.
        </p>
      </section>
    </div>
  );
}

export function IdentityFreePost() {
  return (
    <div className="blog-post-body paper-story ifd-post">
      <section>
        <h2>The expert has changed</h2>
        <p>
          A learning-to-defer system may be trained around one group of experts,
          then deployed with people it has never seen: staff rotate, trainees
          progress, and specialities differ between sites. A few examples of a new
          expert&apos;s past decisions can help—but only if the model learns the right
          thing from them.
        </p>
        <p>
          Population-based methods typically encode class-indexed context into an
          expert embedding. That exposes absolute label identities to the router.
          It can learn a shortcut such as “defer when class 3 is strong” rather
          than the transferable rule “defer on whichever class this expert is
          best at.” A harmless relabelling can then break the policy.
        </p>

        <div className="identity-contrast" aria-label="Identity-conditioned and identity-free routing compared">
          <article>
            <span className="contrast-kicker">Fixed coordinates</span>
            <h3>Identity-conditioned</h3>
            <div className="identity-vector" aria-hidden="true"><b>C0</b><b>C1</b><b className="active">C2</b><b>C3</b></div>
            <p>The router can attach behaviour to a class index. Rename the classes and the shortcut no longer means the same thing.</p>
          </article>
          <div className="contrast-arrow" aria-hidden="true">→</div>
          <article>
            <span className="contrast-kicker">Structural roles</span>
            <h3>Identity-free</h3>
            <div className="role-vector" aria-hidden="true"><b>model top</b><b>expert best</b><b>mean</b></div>
            <p>The router receives only transferable roles and symmetric summaries. Class names never enter the decision.</p>
          </article>
        </div>
      </section>

      <section>
        <h2>A competence profile, not an identity</h2>
        <p>
          Identity-Free Deferral (IFD) builds a Bayesian competence profile from
          a small context set of the expert&apos;s previous predictions. For each
          class, a Beta posterior represents both estimated competence and how
          uncertain that estimate remains:
        </p>
        <Latex display>{"\\theta_k^E \\mid \\mathcal D_C^E \\sim \\operatorname{Beta}(\\alpha_k^E,\\beta_k^E)"}</Latex>
        <p>
          The rejector does not see the vector in its original class order. It
          reads values at roles such as the model&apos;s top class and the expert&apos;s
          estimated best class, alongside symmetric aggregates. Training uses a
          lower-confidence signal—roughly
          {" "}<Latex>{"L_k^E=[\\mu_k^E-\\alpha\\sigma_k^E]_+"}</Latex>—so poorly
          observed competence profiles are naturally downweighted.
        </p>
        <div className="profile-steps" role="list">
          <article role="listitem"><b>1</b><span><strong>Observe</strong>A few labelled past decisions from the new expert.</span></article>
          <article role="listitem"><b>2</b><span><strong>Profile</strong>Estimate per-class competence and posterior uncertainty.</span></article>
          <article role="listitem"><b>3</b><span><strong>Re-index</strong>Convert class coordinates into structural roles.</span></article>
          <article role="listitem"><b>4</b><span><strong>Route</strong>Compare model confidence with the expert&apos;s relevant skill.</span></article>
        </div>
      </section>

      <section>
        <h2>The shortcut, made visible</h2>
        <PaperFigure
          src="/paper-figures/ifd-expert-shift.png"
          alt="Toy experiment comparing L2D-Pop and Identity-Free Deferral when expert proficiency shifts from class 0 to class 2"
          width={720}
          height={830}
          className="ifd-shift-figure"
        >
          Large markers are deferred examples. L2D-Pop&apos;s pattern remains tied
          to the original class identity (top row); IFD moves its deferrals with
          the expert&apos;s speciality (bottom row). From Figure 2 of the paper.
        </PaperFigure>
        <p>
          This controlled experiment holds the data and classifier fixed, then
          changes only which class the expert handles well. The baseline keeps
          deferring to the old identity. IFD&apos;s handovers move to the new
          speciality—the permutation-invariant behaviour the problem requires.
        </p>
      </section>

      <section>
        <h2>More context should mean a better handover</h2>
        <PaperFigure
          src="/paper-figures/ifd-context-scaling.png"
          alt="Six line charts showing Identity-Free Deferral improving as the number of expert context examples increases"
          width={820}
          height={280}
          className="wide-paper-figure"
        >
          IFD (green) converts additional test-time context into higher-quality
          routing for both in-distribution and out-of-distribution experts. The
          population baselines remain comparatively flat. From Figure 3 of the
          paper.
        </PaperFigure>
        <p>
          Across dermatology, blood-cell microscopy, liver imaging, and
          ImageNet-16H with real human annotations, IFD matched or exceeded the
          alternatives. The largest gains occurred for variable specialists and
          out-of-distribution experts—precisely where an identity shortcut is
          most damaging. On the liver-tumour benchmark, the improvement in area
          under system accuracy reached 0.10 over the next-best method.
        </p>
        <aside className="method-note">
          <strong>Annotation efficiency matters:</strong> IFD learns from the
          context labels alone. It does not require an expert response for every
          training query, which removes the dense query-time annotation burden of
          competing population encoders.
        </aside>
      </section>

      <section className="post-conclusion">
        <h2>Conclusion</h2>
        <p>
          Generalising to a new expert is not only a data problem; it is an
          invariance problem. If class identity should not determine a handover,
          the architecture should make that dependence impossible. IFD does this
          by replacing names with roles—and gains a policy that follows expertise
          when the expert changes.
        </p>
      </section>
    </div>
  );
}

export function GuidedDeferralPost() {
  return (
    <div className="blog-post-body paper-story guided-post">
      <section>
        <h2>A handover should carry something useful</h2>
        <p>
          Conventional deferral ends with a binary action: answer, or ask a
          human. In a clinical workflow, “I do not know” is an incomplete
          handover. The person receiving the case still has to reconstruct the
          model&apos;s reasoning, decide what to inspect, and judge whether the AI&apos;s
          uncertainty is meaningful.
        </p>
        <p>
          Guided deferral asks a more collaborative question: when the model is
          uncertain, can it pass the case on with targeted information that helps
          the human make the final decision?
        </p>
        <aside className="method-note">
          <strong>The design goal:</strong> preserve human responsibility for the
          uncertain cases while making the handover more informative than a bare
          rejection.
        </aside>
      </section>

      <section>
        <h2>From report to prediction—or guided referral</h2>
        <PaperFigure
          src="/paper-figures/guided-deferral-system.png"
          alt="Architecture of a guided deferral system that combines an LLM verbalised probability with a hidden-state classifier and supplies guidance on uncertain cases"
          width={965}
          height={400}
          className="wide-paper-figure guided-system-figure"
        >
          The guided-deferral pipeline. A medical report is parsed by an
          instruction-tuned language model; uncertain cases are deferred with
          generated guidance, while sufficiently certain cases are handled by the
          model. From Figure 1 of the paper.
        </PaperFigure>

        <div className="prediction-sources">
          <article>
            <span>Text</span>
            <h3>Verbalised prediction</h3>
            <p>The model states a probability in its generated answer, together with reasons a disorder might or might not be present.</p>
          </article>
          <article>
            <span>State</span>
            <h3>Hidden-state prediction</h3>
            <p>A small classifier reads the final-layer representation, extracting a second probability from what the model internally encodes.</p>
          </article>
          <article>
            <span>Team</span>
            <h3>Combined prediction</h3>
            <p>The two signals are averaged for classification; uncertainty can be measured with the signal best suited to routing.</p>
          </article>
        </div>
        <p>
          Confidence is measured by distance from the binary decision boundary.
          Cases closest to 0.5 are handed over first, so an operational threshold
          controls how much work remains autonomous and how much enters the guided
          pathway.
        </p>
      </section>

      <section>
        <h2>Calibration under imbalance</h2>
        <p>
          Clinical report labels are often overwhelmingly negative. Ordinary
          Expected Calibration Error weights each confidence bin by how many
          samples fall into it, so a dominant negative region can hide poor
          calibration elsewhere. The paper introduces Imbalanced ECE, blending
          empirical bin frequency with a uniform weight:
        </p>
        <Latex display>{"\\operatorname{ECE}_{\\mathrm{Imb}}=\\sum_{m=1}^{M}\\underbrace{\\left((1-\\gamma)\\frac{|B_m|}{n}+\\frac{\\gamma}{M}\\right)}_{\\text{balanced bin weight }\\Gamma_m}\\,\\underbrace{|\\bar h_m-\\bar y_m|}_{\\text{calibration gap}}"}</Latex>
        <p>
          When <Latex>{"\\gamma=0"}</Latex>, this is ordinary ECE. Moving
          <Latex>{"\\gamma"}</Latex> toward one gives sparse bins more influence.
          In this study, <Latex>{"\\gamma=0.3"}</Latex> exposed calibration error
          that standard ECE largely concealed in highly imbalanced data.
        </p>
      </section>

      <section>
        <h2>Did the guidance help people?</h2>
        <p>
          The pilot study involved 20 biomedical researchers who were not
          specialists in spinal disorders. Each reviewed 30 of the system&apos;s most
          uncertain report-level predictions. When a participant disagreed with
          the model, they received its guidance and could keep or revise their
          answer.
        </p>
        <PaperFigure
          src="/paper-figures/guided-pilot-result.png"
          alt="Box plots comparing participant accuracy without guidance and with AI guidance, against the language model's accuracy"
          width={520}
          height={320}
          className="guided-pilot-figure"
        >
          Participant accuracy before and after guidance; the dashed line is the
          language model alone. Every participant improved with guidance, and the
          paired difference was significant (<em>p</em> &lt; 0.01). From Figure 4
          of the paper.
        </PaperFigure>
        <div className="result-banner">
          <strong>20 / 20</strong>
          <span>participants improved with guidance</span>
        </div>
        <p>
          Importantly, guidance helped people respond to disagreement even when
          the model itself was wrong. That is the behaviour a collaborative
          system needs: the explanation should support judgement, not merely make
          the model more persuasive.
        </p>
      </section>

      <section className="post-limitations">
        <h2>What this does—and does not—show</h2>
        <ul className="limitations-list">
          <li>The pilot was small and involved biomedical researchers, not practising spinal specialists or a live clinical pathway.</li>
          <li>The task used retrospective reports and a fixed set of uncertain cases; workload, time pressure, and downstream consequences were not modelled.</li>
          <li>Generated guidance can still anchor users, omit important evidence, or sound more certain than warranted.</li>
          <li>Clinical use would require prospective evaluation, drift monitoring, clear escalation rules, and training about the model&apos;s limits.</li>
        </ul>
      </section>

      <section className="post-conclusion">
        <h2>Conclusion</h2>
        <p>
          Deferral is an interaction, not an error code. This study shows the
          promise of pairing uncertainty-aware routing with useful context for the
          person taking over. The next step is to test whether that richer
          handover remains safe, calibrated, and genuinely helpful in real
          clinical work.
        </p>
      </section>
    </div>
  );
}
