const publications = [
  {
    year: "2026",
    title: "Identity-Free Deferral for Unseen Experts",
    authors:
      "Joshua Strong, Pramit Saha, Yasin Ibrahim, Cheng Ouyang, and J. Alison Noble",
    venue: "International Conference on Learning Representations (ICLR), poster",
  },
  {
    year: "2026",
    title: "Human-AI Collaboration in Healthcare: A Scoping Review",
    authors:
      "Joshua Strong, Harry Rogers, Emma Sun, Anna Louise Todsen, Jody Ede, Cherry Lumley, Nick Yeung, Helen Higham, and J. Alison Noble",
    venue: "npj Digital Medicine, accepted",
  },
  {
    year: "2026",
    title: "Coherent Hierarchical Multi-Label Deferral for Medical Imaging",
    authors:
      "Joshua Strong, Pramit Saha, Emma Sun, Helen Higham, and J. Alison Noble",
    venue: "Manuscript under review",
  },
  {
    year: "2025",
    title:
      "Trustworthy and Practical AI for Healthcare: A Guided Deferral System with Large Language Models",
    authors: "Joshua Strong, Qianhui Men, and J. Alison Noble",
    venue: "Proceedings of the AAAI Conference on Artificial Intelligence",
    href: "https://doi.org/10.1609/aaai.v39i27.35063",
  },
];

const researchAreas = [
  {
    number: "01",
    title: "Dynamic deferral",
    text: "Clinical AI should do more than answer or abstain. I study systems that decide when to act, ask for missing information, retrieve evidence, or defer to the right clinician.",
  },
  {
    number: "02",
    title: "Human-AI evaluation",
    text: "I develop benchmarks for multi-step clinical reasoning that measure uncertainty, escalation, handoff quality, calibrated reliance, and the performance of the whole team.",
  },
  {
    number: "03",
    title: "Learning from handoffs",
    text: "Deferrals, corrections, and expert disagreements reveal what a model does not know. I use these signals to improve clinical models under noise, sparsity, and domain shift.",
  },
];

export default function Home() {
  return (
    <main>
      <header className="site-header">
        <a className="wordmark" href="#top" aria-label="Joshua Strong, home">
          Joshua Strong
        </a>
        <nav aria-label="Primary navigation">
          <a href="#about">About</a>
          <a href="#research">Research</a>
          <a href="#publications">Publications</a>
          <a href="mailto:joshua.strong@eng.ox.ac.uk">Contact</a>
        </nav>
      </header>

      <div id="top" className="page-shell">
        <section className="hero" aria-labelledby="hero-title">
          <div className="hero-copy">
            <p className="eyebrow">Trustworthy AI for healthcare</p>
            <h1 id="hero-title">Joshua Strong</h1>
            <p className="hero-statement">
              I design clinical AI systems that know when to act, when to ask,
              and when to defer.
            </p>
            <p className="hero-summary">
              My research focuses on learning to defer, human-AI collaboration,
              and expert-facing evaluation for safe clinical decision-making.
            </p>
            <div className="hero-meta" aria-label="Location and role">
              <span>Oxford, UK</span>
              <span>DPhil researcher</span>
            </div>
            <div className="hero-links">
              <a href="mailto:joshua.strong@eng.ox.ac.uk">Email</a>
              <a href="/joshua-strong-research-statement.pdf">
                Research statement <span aria-hidden="true">↗</span>
              </a>
            </div>
          </div>

          <figure className="portrait">
            <img
              src="/joshua-strong.png"
              alt="Joshua Strong presenting his research"
              width="192"
              height="256"
            />
            <figcaption>Presenting research on human-AI collaboration</figcaption>
          </figure>
        </section>

        <section id="about" className="section about">
          <div className="section-label">About</div>
          <div className="section-content about-copy">
            <h2>
              Building AI that allocates responsibility, rather than simply
              making predictions.
            </h2>
            <p>
              My work asks how clinical AI systems should collaborate with
              human experts when decisions are uncertain, information is
              incomplete, and responsibility cannot be handed over casually.
              The goal is practical AI that handles routine cases, communicates
              uncertainty, escalates urgent situations, and supports coherent
              handoffs to clinicians.
            </p>
            <p>
              Alongside methodological work in machine learning, I study how
              these systems affect reliance, workload, accountability, and
              clinical workflow. I also bring experience from NHS data science,
              working with real healthcare datasets and clinical and
              operational stakeholders.
            </p>
          </div>
        </section>

        <section id="research" className="section">
          <div className="section-label">Research</div>
          <div className="section-content">
            <h2>Current directions</h2>
            <div className="research-list">
              {researchAreas.map((area) => (
                <article className="research-item" key={area.number}>
                  <span className="item-number">{area.number}</span>
                  <div>
                    <h3>{area.title}</h3>
                    <p>{area.text}</p>
                  </div>
                </article>
              ))}
            </div>
          </div>
        </section>

        <section id="publications" className="section publications">
          <div className="section-label">Publications</div>
          <div className="section-content">
            <div className="section-heading-row">
              <h2>Selected work</h2>
              <a
                className="text-link"
                href="/joshua-strong-research-statement.pdf"
              >
                Full research statement <span aria-hidden="true">↗</span>
              </a>
            </div>
            <div className="publication-list">
              {publications.map((publication) => (
                <article className="publication" key={publication.title}>
                  <div className="publication-year">{publication.year}</div>
                  <div>
                    <h3>
                      {publication.href ? (
                        <a href={publication.href}>{publication.title}</a>
                      ) : (
                        publication.title
                      )}
                    </h3>
                    <p>{publication.authors}</p>
                    <p className="venue">{publication.venue}</p>
                  </div>
                </article>
              ))}
            </div>
          </div>
        </section>

        <section className="contact" aria-labelledby="contact-title">
          <p className="eyebrow">Contact</p>
          <h2 id="contact-title">Interested in working together?</h2>
          <a className="contact-link" href="mailto:joshua.strong@eng.ox.ac.uk">
            joshua.strong@eng.ox.ac.uk
          </a>
        </section>

        <footer>
          <span>© {new Date().getFullYear()} Joshua Strong</span>
          <a href="#top">Back to top ↑</a>
        </footer>
      </div>
    </main>
  );
}
