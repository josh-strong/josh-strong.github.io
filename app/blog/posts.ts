export type BlogSection = {
  heading: string;
  paragraphs: string[];
};

export type BlogPost = {
  slug: string;
  title: string;
  description: string;
  label: string;
  year: string;
  readTime: string;
  paperUrl?: string;
  paperLabel?: string;
  sections: BlogSection[];
};

export const blogPosts: BlogPost[] = [
  {
    slug: "introduction-to-learning-to-defer",
    title:
      "Learning to defer in practice: A retrospective example with real chest X-rays and human annotations",
    description:
      "A concrete demonstration of how learning to defer can route individual chest X-ray findings between an AI model and a radiologist.",
    label: "Primer",
    year: "2026",
    readTime: "9 min read",
    sections: [
      {
        heading: "Prediction is not always the whole job",
        paragraphs: [
          "Most machine-learning systems are trained to make a prediction for every case. In many real settings, however, there is another sensible action: ask a person. Learning to defer gives a model this option. It learns both how to predict and when a human expert is likely to make the better decision.",
          "This is more than uncertainty estimation. A model can be uncertain on a case that is also difficult for the available expert, or confident on a case where a specialist has knowledge it cannot see. The useful question is comparative: who is best placed to decide this case?",
        ],
      },
      {
        heading: "Optimising the team",
        paragraphs: [
          "A learning-to-defer system usually contains a predictor and a rejector. The predictor produces the model's answer; the rejector chooses between that answer and one or more experts. They are evaluated as a joint decision system, so a good policy depends on the strengths, errors, availability, and cost of every decision-maker involved.",
          "That framing matters in healthcare. Clinical expertise is heterogeneous, workloads are limited, and the consequence of a mistake can vary sharply between cases. A useful system therefore needs to allocate responsibility—not simply automate as many decisions as possible.",
        ],
      },
      {
        heading: "What makes the problem difficult",
        paragraphs: [
          "Real deployments introduce questions that a simple classroom formulation does not answer. Experts change between shifts and hospitals. Their past labels may be scarce. Deferrals create workload. A policy can be accurate overall while treating groups unevenly, becoming poorly calibrated, or failing when its expert pool changes.",
          "My research looks at several of these edges: how to give people useful guidance when a model defers, how to adapt to experts the system has not seen before, and how to keep deferral decisions coherent when clinical labels form a hierarchy. The common goal is a human–AI system whose division of work is explicit, reliable, and useful in practice.",
        ],
      },
    ],
  },
  {
    slug: "coherent-hierarchical-learning-to-defer",
    title: "Coherent hierarchical learning to defer",
    description:
      "How clinical label hierarchies turn deferral into a structured decision—and how we prevent contradictory handovers.",
    label: "Publication note",
    year: "2026",
    readTime: "8 min read",
    paperUrl: "https://arxiv.org/abs/2605.02734",
    paperLabel: "Read the paper on arXiv",
    sections: [
      {
        heading: "When labels have structure",
        paragraphs: [
          "Medical-imaging findings are often organised in taxonomies: a specific finding implies a broader parent category, and several findings may be present at once. Standard learning-to-defer methods treat each label independently. In a hierarchy, that can produce an impossible action—for example, asserting a child finding while handing its implied parent to somebody else.",
          "We call these failures deferral incoherence. The problem is not merely that two labels disagree. Deferral is a delegation action, so the system also has to communicate a logically consistent scope of work to the reader receiving the case.",
        ],
      },
      {
        heading: "A coherent handoff contract",
        paragraphs: [
          "The paper formalises a Selective-Exclusion handoff contract: the model may make some assertions itself and delegate a coherent remainder. We characterise the Bayes-optimal rule under this contract and show why even individually optimal label decisions can be incoherent when combined.",
          "We then propose two remedies. Exact coherent projection uses dynamic programming to map independent decisions onto the valid action set. Taxonomic Belief Propagation with Recursive Policy Optimisation instead learns a joint, contract-aware policy through the same recursion used at inference.",
        ],
      },
      {
        heading: "The broader lesson",
        paragraphs: [
          "Across medical-imaging benchmarks with real readers and controlled experts, independent per-label deferral produced non-trivial incoherence. Projection removed it exactly, while the faster joint model drove it close to zero and retained strong utility.",
          "The broader point is that a handover has semantics. When decisions are related, a system should reason about the work it is delegating as a structured whole rather than as a collection of isolated yes-or-no choices.",
        ],
      },
    ],
  },
  {
    slug: "learning-to-defer-a-survey",
    title: "Learning to defer: a map of the field",
    description:
      "A reader's guide to a fast-growing literature, from core training frameworks to the practical constraints of human–AI systems.",
    label: "Publication note",
    year: "2026",
    readTime: "5 min read",
    paperUrl: "https://doi.org/10.5281/zenodo.17843044",
    paperLabel: "Read the survey",
    sections: [
      {
        heading: "Why the field needed a map",
        paragraphs: [
          "Learning to defer has grown from a compact classification problem into a broad family of methods for allocating decisions between AI systems and people. Papers often use different terminology, assumptions, loss functions, and evaluation settings, which can make closely related ideas look disconnected.",
          "Our survey brings this literature together around one central question: what must a system learn in order to decide whether it should act autonomously or involve an expert?",
        ],
      },
      {
        heading: "Four branches of work",
        paragraphs: [
          "We organise the field into four branches: methodological frameworks; optimisation and theory; task generalisations; and real-world adaptations. This connects score-based and predictor–rejector formulations, as well as one-stage, two-stage, and post-hoc training approaches.",
          "The taxonomy also follows the problem beyond standard classification. It covers regression, multi-task prediction, committees of experts, sequential decisions, and causal pipelines, alongside the theoretical guarantees used to justify common surrogate objectives.",
        ],
      },
      {
        heading: "From a loss function to a working system",
        paragraphs: [
          "The practical challenges are often where the most consequential research questions begin. Expert annotations are expensive, expert pools change, and workload and budget constraints shape which handovers are actually possible. Fairness, interpretability, robustness, and uncertainty handling cannot be bolted on after deployment.",
          "The survey's purpose is therefore not only to catalogue algorithms. It is to make assumptions visible and to identify the gap between a deferral method that performs well on a benchmark and a human–AI decision system that can be trusted in practice.",
        ],
      },
    ],
  },
  {
    slug: "human-ai-collaboration-in-healthcare",
    title: "What the evidence says about human–AI collaboration in healthcare",
    description:
      "A scoping review of 140 empirical studies—and why team performance depends on far more than an algorithm's accuracy.",
    label: "Publication note",
    year: "2026",
    readTime: "5 min read",
    paperUrl: "https://www.nature.com/articles/s41746-026-02918-6",
    paperLabel: "Read the paper in npj Digital Medicine",
    sections: [
      {
        heading: "Looking at teams, not tools",
        paragraphs: [
          "Claims about human–AI collaboration are common in healthcare, but collaboration is not created simply by placing an AI output beside a clinician's judgement. We reviewed empirical studies published from 2015 to October 2025 to understand where collaboration has been tested, how it has been evaluated, and what makes it effective.",
          "From 17,463 records, 140 studies met our inclusion criteria. Most evidence came from diagnostic interpretation, with much less work on screening and triage, treatment decisions, or administrative workflows.",
        ],
      },
      {
        heading: "Benefits depend on context",
        paragraphs: [
          "Most studies—especially those concerning diagnostic interpretation—reported benefits for human–AI teams. But the gains were not automatic. They depended on whether the AI fitted the task, how it was integrated into the workflow, what training users received, and whether people placed appropriately calibrated trust in its output.",
          "Effectiveness was also defined inconsistently. Evaluations commonly focused on short-term task metrics, while patient outcomes, organisational effects, and longer-term changes in professional practice were rarely measured.",
        ],
      },
      {
        heading: "Where evidence needs to go next",
        paragraphs: [
          "Accountability, safety, and governance appeared frequently in discussion, but were seldom evaluated empirically. That leaves an important mismatch between what researchers recognise as consequential and what studies are designed to measure.",
          "The next generation of evidence should be task-specific, longitudinal, and attentive to the surrounding clinical system. The relevant unit of evaluation is not the model alone: it is the people, technology, workflow, and governance arrangements acting together.",
        ],
      },
    ],
  },
  {
    slug: "identity-free-deferral",
    title: "Deferring to experts the model has never met",
    description:
      "Why expert identity can become a shortcut, and how an identity-free architecture adapts from only a small context set.",
    label: "Publication note",
    year: "2026",
    readTime: "4 min read",
    paperUrl:
      "https://proceedings.iclr.cc/paper_files/paper/2026/hash/4cddc8fc57039f8fe44e23aba1e4df40-Abstract-Conference.html",
    paperLabel: "Read the ICLR paper",
    sections: [
      {
        heading: "Experts change",
        paragraphs: [
          "A deployed system will encounter people who were not present during training. A new clinician may have a different pattern of strengths from the original expert population, yet the system still has to decide whether handing over a particular case will help.",
          "Existing population-based approaches can adapt from a small set of an expert's past decisions, but we found that they can struggle when a new expert is out of distribution. The underlying issue is architectural: class-indexed inputs let the model attach its policy to absolute identities and learn shortcuts that should not matter.",
        ],
      },
      {
        heading: "Removing the identity shortcut",
        paragraphs: [
          "Identity-Free Deferral enforces the problem's permutation symmetry by construction. From a few-shot context, it builds a Bayesian competence profile for each expert. The rejector sees only a low-dimensional, role-indexed summary—for example, the model's confidence in its top class and the expert's estimated competence for that same role—not the absolute class identity.",
          "An uncertainty-aware objective learns from those context profiles without needing an expert label for every training query. This matters because collecting dense expert annotations is often the most expensive part of building a deferral system.",
        ],
      },
      {
        heading: "Generalising the handover",
        paragraphs: [
          "On medical-imaging benchmarks and ImageNet-16H with real human annotators, the identity-free approach improved generalisation to unseen experts, particularly when their competence patterns differed from those seen in training, while using fewer annotations than alternative methods.",
          "The result illustrates a broader design principle: if a decision should not depend on a name or coordinate, the architecture should make that dependence impossible rather than merely hoping the model will ignore it.",
        ],
      },
    ],
  },
  {
    slug: "guided-deferral-with-language-models",
    title: "Guided deferral with language models",
    description:
      "A system that does more than say “ask a human”: it passes uncertain cases on with useful, targeted guidance.",
    label: "Publication note",
    year: "2025",
    readTime: "4 min read",
    paperUrl: "https://doi.org/10.1609/aaai.v39i27.35063",
    paperLabel: "Read the AAAI paper",
    sections: [
      {
        heading: "Deferral should help the recipient",
        paragraphs: [
          "In high-stakes settings, a system should not always force an answer. But a bare deferral—effectively, “I do not know”—leaves the human to begin again. Guided deferral asks whether the model can make the handover more useful by communicating relevant information alongside it.",
          "Our system uses an open-source language model to parse medical reports for disorder classification. When it is uncertain, it can defer the prediction and provide intelligent guidance to the person taking over the case.",
        ],
      },
      {
        heading: "Building for a healthcare setting",
        paragraphs: [
          "The work is motivated by two barriers to using large language models in healthcare: hallucination in critical decisions and reliance on proprietary services where data privacy is strict. We therefore focus on efficient, effective open-source models and on a workflow that combines human and model strengths instead of treating automation as the only objective.",
          "A pilot study demonstrates the proposed system in practice. The paper also examines calibration under class imbalance, where standard summary metrics can hide poor behaviour, and introduces Imbalanced Expected Calibration Error as a simple alternative.",
        ],
      },
      {
        heading: "From rejection to collaboration",
        paragraphs: [
          "The central idea is that deferral can be a constructive interaction rather than a failure state. A well-designed handover should make the model's limits visible and reduce the effort required for a person to continue the decision process.",
          "That changes how we think about trustworthy AI: reliability is not only the accuracy of autonomous outputs, but also the quality of the system's behaviour when autonomous prediction is not appropriate.",
        ],
      },
    ],
  },
];

export function getBlogPost(slug: string) {
  return blogPosts.find((post) => post.slug === slug);
}
