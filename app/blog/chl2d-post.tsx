import { Latex } from "../latex";

export function CHL2DPost() {
  return (
    <div className="blog-post-body chl2d-post">
      <section>
        <h2>The handover is part of the prediction</h2>
        <p>
          A chest X-ray can contain several related findings at once. A model may
          predict a broad category such as <em>lung opacity</em>, more specific
          children such as <em>consolidation</em> or <em>oedema</em>, and decide
          independently for each finding whether to answer or defer to a
          radiologist.
        </p>
        <p>
          That last step sounds like ordinary multi-label learning to defer, but
          the labels form a taxonomy. If consolidation is present, then lung
          opacity—and, above it, abnormality—must also be present. A set of
          individually sensible actions can therefore describe an impossible or
          confusing handover when combined.
        </p>
        <aside className="method-note">
          <strong>The central question:</strong> can the AI allocate individual
          findings between itself and a reader while keeping the complete set of
          predictions and deferrals logically coherent?
        </aside>
      </section>

      <section>
        <h2>Three ways independent deferral can break</h2>
        <p>
          Suppose a parent and child can each be marked absent (<Latex>{"0"}</Latex>),
          present (<Latex>{"1"}</Latex>), or deferred (<Latex>{"\\perp"}</Latex>).
          Treating those two nodes independently creates three distinct failure
          modes.
        </p>
        <div className="coherence-cards">
          <article className="coherence-card coherence-card-taxonomy">
            <div className="coherence-tree" aria-hidden="true">
              <span><small>Parent</small>0</span>
              <i />
              <span><small>Child</small>1</span>
            </div>
            <h3>Taxonomic contradiction</h3>
            <p>
              The model says a parent is absent while asserting that one of its
              children is present.
            </p>
          </article>
          <article className="coherence-card coherence-card-delegation">
            <div className="coherence-tree" aria-hidden="true">
              <span><small>Parent</small>⊥</span>
              <i />
              <span><small>Child</small>1</span>
            </div>
            <h3>Delegation violation</h3>
            <p>
              The parent is handed to the reader, but a child prediction already
              implies the parent&apos;s value.
            </p>
          </article>
          <article className="coherence-card coherence-card-deductive">
            <div className="coherence-tree" aria-hidden="true">
              <span><small>Parent</small>0</span>
              <i />
              <span><small>Child</small>⊥</span>
            </div>
            <h3>Deductive defect</h3>
            <p>
              The model defers a child even though its own parent assertion has
              already forced the answer.
            </p>
          </article>
        </div>
        <p>
          These are not just quirks of imperfect training. We show that a
          Bayes-consistent node-wise model can still produce delegation violations
          and deductive defects because its independence structure never reasons
          about the handover as a whole.
        </p>
      </section>

      <section>
        <h2>Defining a coherent action</h2>
        <p>
          We formalise a selective-exclusion handoff contract. Let
          <Latex>{"\\mathcal{A}=\\{0,1,\\perp\\}"}</Latex> be the actions at
          each node. The parent action determines which child actions are allowed:
        </p>
        <Latex display>
          {"\\Gamma(0)=\\{0\\},\\qquad " +
            "\\Gamma(1)=\\mathcal{A},\\qquad " +
            "\\Gamma(\\perp)=\\{0,\\perp\\}."}
        </Latex>
        <p>
          An absent parent forces an absent child; a present parent leaves all
          options open; and a deferred parent permits an absent or deferred child,
          but not a present child that would answer the delegated question
          indirectly. The coherent action set is therefore
        </p>
        <Latex display>
          {"\\mathcal{C}=\\left\\{\\mathbf a\\in\\mathcal A^{|\\mathcal V|}:" +
            "\\;a_c\\in\\Gamma(a_p)\\;\\text{for every edge }p\\to c\\right\\}."}
        </Latex>
        <p>
          This turns coherence into a precise contract rather than a vague wish
          that neighbouring predictions should agree.
        </p>
      </section>

      <section>
        <h2>Two ways to enforce the contract</h2>
        <p>
          Both methods begin with the same primitive outputs: for each node, a
          learning-to-defer head estimates scores for absent, present, and defer.
          They differ in where the hierarchy enters the system.
        </p>
        <div className="method-comparison" role="table" aria-label="Comparison of coherent hierarchical learning-to-defer methods">
          <div className="method-comparison-row method-comparison-head" role="row">
            <span role="columnheader">Method</span>
            <span role="columnheader">Projection</span>
            <span role="columnheader">TBP + RPO</span>
          </div>
          <div className="method-comparison-row" role="row">
            <strong role="rowheader">Idea</strong>
            <span role="cell">Repair local outputs</span>
            <span role="cell">Learn through the hierarchy</span>
          </div>
          <div className="method-comparison-row" role="row">
            <strong role="rowheader">Coherence enters</strong>
            <span role="cell">At inference</span>
            <span role="cell">Forward pass and training</span>
          </div>
          <div className="method-comparison-row" role="row">
            <strong role="rowheader">Guarantee</strong>
            <span role="cell">Exactly coherent</span>
            <span role="cell">Near-coherent fast decoding; exact with MAP</span>
          </div>
          <div className="method-comparison-row" role="row">
            <strong role="rowheader">Best suited to</strong>
            <span role="cell">A safe retrofit</span>
            <span role="cell">A learned, higher-utility deployment</span>
          </div>
        </div>

        <h3>1. Exact coherent projection</h3>
        <p>
          Projection chooses the highest-scoring joint action from
          <Latex>{"\\mathcal C"}</Latex>. A brute-force search would examine
          <Latex>{"3^{|\\mathcal V|}"}</Latex> action vectors, which becomes
          impossible even for a modest taxonomy. Because the labels form a tree,
          dynamic programming can solve the same optimisation exactly in
          <Latex>{"\\mathcal O(|\\mathcal V||\\mathcal A|^2)"}</Latex> time—
          effectively linear in the number of findings.
        </p>
        <p>
          This is attractive when an existing node-wise model needs a reliable
          safety layer: no retraining is required, and every final action vector
          is coherent.
        </p>

        <h3>2. Taxonomic Belief Propagation with Recursive Policy Optimisation</h3>
        <p>
          Projection repairs a policy after it has been learned. Taxonomic Belief
          Propagation (TBP) instead pushes probability mass down the tree according
          to the allowed transitions. Recursive Policy Optimisation (RPO) then
          trains through that recursion, so losses at descendants also teach
          ancestors which actions preserve useful downstream options.
        </p>
        <p>
          The result is a hierarchy-aware policy rather than a collection of
          independent heads. Its fast decoder is near-coherent; pairing the learned
          marginals with exact MAP decoding restores a hard coherence guarantee.
        </p>
      </section>

      <section>
        <h2>What happens empirically</h2>
        <p>
          We evaluate on four medical-imaging settings spanning real readers and
          controlled experts. The two plots below show the central trade-off on
          VinDr-CXR: system utility as more finding-level decisions are deferred,
          and the rate at which any incoherence appears.
        </p>
        <figure className="experiment-figure chl2d-result-figure">
          <a href="/chl2d-system-f1.png" aria-label="Open the system F1 result at full resolution">
            <img
              src="/chl2d-system-f1.png"
              alt="System label F1 against deferral fraction on VinDr-CXR. Recursive Policy Optimisation and coherent projection retain strong utility across deferral budgets."
              width="3535"
              height="2406"
            />
          </a>
          <figcaption>
            System F1 as the fraction of delegated finding decisions increases.
            The learned TBP + RPO policy is labelled BR-RPO in the figure.
          </figcaption>
        </figure>
        <figure className="experiment-figure chl2d-result-figure">
          <a href="/chl2d-incoherence-rate.png" aria-label="Open the incoherence result at full resolution">
            <img
              src="/chl2d-incoherence-rate.png"
              alt="Any incoherence rate against deferral fraction on VinDr-CXR. Independent binary relevance methods are incoherent, exact projection remains at zero, and Recursive Policy Optimisation stays close to zero."
              width="3540"
              height="2406"
            />
          </a>
          <figcaption>
            Any-incoherence rate. Exact projection remains at zero by construction;
            TBP + RPO drives incoherence close to zero while the independent
            baselines fail much more often.
          </figcaption>
        </figure>
        <p>
          Across VinDr-CXR, CheXpert, PadChest, and ADPv2, exact projection removes
          incoherence by construction. TBP + RPO is almost coherent under fast
          decoding and often provides the strongest utility. That distinction is
          useful in practice: projection is a dependable guardrail, while joint
          training can learn a better division of work.
        </p>
      </section>

      <section>
        <h2>What I take from the paper</h2>
        <p>
          The main lesson is not limited to chest X-rays. A deferral system is
          defining a boundary of responsibility. Whenever decisions have
          structure—taxonomies, prerequisites, temporal dependencies, or shared
          constraints—that boundary should be represented explicitly.
        </p>
        <p>
          Maximising the number of correct AI predictions is only part of the
          objective. A clinically useful handover must also be understandable:
          the reader should know what the model has decided, what remains open,
          and why their input is still needed. Coherence is one concrete step
          toward that more human-centred notion of utility.
        </p>
      </section>
    </div>
  );
}
