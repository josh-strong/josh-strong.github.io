const publications = [
  {
    year: "2026",
    title: "Identity-Free Deferral for Unseen Experts",
    authors:
      "Joshua Strong, Pramit Saha, Yasin Ibrahim, Cheng Ouyang, and J. Alison Noble",
    venue: "International Conference on Learning Representations (ICLR)",
    href: "https://openreview.net/forum?id=4YG9ufFg58",
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
    title: "Human-AI collaboration",
    text: "My DPhil research studies how people and AI systems can work together safely and effectively in healthcare, with responsibility allocated to the right decision-maker.",
  },
  {
    number: "02",
    title: "Learning to defer",
    text: "I develop machine learning systems that recognise when human expertise is needed, including guided deferral with language models and deferral to previously unseen experts.",
  },
  {
    number: "03",
    title: "Applied clinical data science",
    text: "My work is grounded in practical healthcare settings, including experience building and deploying national-scale forecasting systems at NHS England.",
  },
];

const education = [
  {
    dates: "2022-present",
    institution: "University of Oxford",
    qualification: "DPhil in Engineering Science",
    detail:
      "Thesis: Human AI Collaboration in Healthcare. Supervised by Professor Alison Noble CBE FRS FREng FIET and Professor Helen Higham. Fully funded EPSRC Studentship.",
  },
  {
    dates: "2019-2020",
    institution: "University College London",
    qualification: "MSc in Data Science, Distinction",
    detail:
      "Thesis: Model-Agnostic Meta-Learning for Few-Shot Deep Learning.",
  },
  {
    dates: "2015-2018",
    institution: "University of York",
    qualification: "BSc (Hons) in Mathematics, First Class",
    detail: "Ranked second in cohort.",
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
          <a href="#cv">CV</a>
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
              <span>DPhil student</span>
            </div>
            <div className="hero-links">
              <a href="mailto:joshua.strong@eng.ox.ac.uk">Email</a>
              <a href="/joshua-strong-cv.pdf">
                CV <span aria-hidden="true">↗</span>
              </a>
              <a href="https://github.com/josh-strong">GitHub</a>
              <a href="https://www.linkedin.com/in/josh-strong">LinkedIn</a>
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
              My DPhil in Engineering Science at the University of Oxford
              focuses on human-AI collaboration in healthcare.
            </p>
            <p>
              Before starting my DPhil, I was a Data Scientist at NHS England,
              where I built a Bayesian hierarchical early warning system for
              national COVID metrics and took machine learning products from
              large-scale data preparation through production deployment.
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
              <a className="text-link" href="/joshua-strong-cv.pdf">
                Download CV <span aria-hidden="true">↗</span>
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

        <section id="cv" className="section cv">
          <div className="section-label">CV</div>
          <div className="section-content">
            <div className="section-heading-row">
              <h2>Experience &amp; education</h2>
              <a className="text-link" href="/joshua-strong-cv.pdf">
                PDF version <span aria-hidden="true">↗</span>
              </a>
            </div>

            <div className="cv-group">
              <h3 className="cv-group-title">Experience</h3>
              <article className="cv-entry">
                <div className="cv-dates">2020-2022</div>
                <div>
                  <h3>Data Scientist</h3>
                  <p className="cv-institution">NHS England</p>
                  <p>
                    Built a Bayesian hierarchical early warning system for
                    national COVID forecasting, led machine learning products
                    from data preparation to deployment, and mentored junior
                    analysts and MSc researchers.
                  </p>
                </div>
              </article>
            </div>

            <div className="cv-group">
              <h3 className="cv-group-title">Education</h3>
              {education.map((item) => (
                <article className="cv-entry" key={item.institution}>
                  <div className="cv-dates">{item.dates}</div>
                  <div>
                    <h3>{item.qualification}</h3>
                    <p className="cv-institution">{item.institution}</p>
                    <p>{item.detail}</p>
                  </div>
                </article>
              ))}
            </div>

            <div className="cv-group compact">
              <h3 className="cv-group-title">Teaching &amp; service</h3>
              <div className="service-grid">
                <div>
                  <span>Teaching</span>
                  <p>
                    Graduate Teaching Assistant for group-based AI projects on
                    doctoral training programmes and international visits.
                  </p>
                </div>
                <div>
                  <span>Reviewing</span>
                  <p>NeurIPS 2024, ICML 2024, and ICLR 2025.</p>
                </div>
              </div>
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
