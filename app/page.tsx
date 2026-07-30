import { FaGithub, FaLinkedinIn } from "react-icons/fa6";
import { FiMail } from "react-icons/fi";

const publications = [
  {
    year: "2026",
    title: "Human-AI Collaboration in Healthcare: A Scoping Review",
    authors:
      "Joshua Strong, Harry Rogers, Emma Sun, Anna Louise Todsen, Jody Ede, Cherry Lumley, Nick Yeung, Helen Higham, and J. Alison Noble",
    venue: "npj Digital Medicine",
    href: "https://www.nature.com/articles/s41746-026-02918-6",
  },
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
    <>
      <header className="site-header">
        <div className="nav-inner">
          <a className="wordmark" href="#about" aria-label="Joshua Strong, home">
            Joshua Strong
          </a>
          <nav aria-label="Primary navigation">
            <a className="active" href="#about">
              About
            </a>
            <a href="#research">Research</a>
            <a href="#publications">Publications</a>
            <a href="#cv">CV</a>
          </nav>
        </div>
      </header>

      <main className="site-main">
        <section id="about" className="about-section">
          <h1>About me</h1>
          <div className="bio">
            <figure className="profile-photo">
              <img
                src="/joshua-strong.png"
                alt="Portrait of Joshua Strong"
                width="800"
                height="1000"
              />
            </figure>
            <p>
              I am a DPhil student in Engineering Science at the University of
              Oxford, working on trustworthy artificial intelligence for
              healthcare. My research focuses on how people and AI systems can
              collaborate safely and effectively in clinical decision-making.
            </p>
            <p>
              I develop learning-to-defer systems that recognise when human
              expertise is needed, including guided deferral with language
              models and deferral to previously unseen experts.
            </p>
            <p>
              Before starting my DPhil, I was a Data Scientist at NHS England,
              where I built a Bayesian hierarchical early warning system for
              national COVID metrics and took machine learning products from
              large-scale data preparation through production deployment.
            </p>
          </div>
          <div className="profile-links" aria-label="External links">
            <a href="mailto:joshua.strong@eng.ox.ac.uk">
              <FiMail aria-hidden="true" data-icon="mail" size={15} />
              <span>Email</span>
            </a>
            <a href="https://github.com/josh-strong">
              <FaGithub aria-hidden="true" data-icon="github" size={15} />
              <span>GitHub</span>
            </a>
            <a href="https://www.linkedin.com/in/josh-strong">
              <FaLinkedinIn
                aria-hidden="true"
                data-icon="linkedin"
                size={15}
              />
              <span>LinkedIn</span>
            </a>
          </div>
        </section>

        <section id="research" className="content-section">
          <h2>Research</h2>
          <div className="research-list">
            {researchAreas.map((area) => (
              <article className="research-item" key={area.number}>
                <h3>{area.title}</h3>
                <p>{area.text}</p>
              </article>
            ))}
          </div>
        </section>

        <section id="publications" className="content-section">
          <h2>Selected publications</h2>
          <div className="publication-list">
            {publications.map((publication) => (
              <article className="publication" key={publication.title}>
                <p className="publication-title">
                  <strong>[{publication.year}]</strong>{" "}
                  <a href={publication.href}>{publication.title}</a>
                </p>
                <p>{publication.authors}</p>
                <p className="venue">{publication.venue}</p>
              </article>
            ))}
          </div>
        </section>

        <section id="cv" className="content-section">
          <h2>CV</h2>

          <div className="cv-group">
            <h3 className="subheading">Experience</h3>
            <article className="cv-entry">
              <div>
                <strong>Data Scientist</strong>
                <p className="institution">NHS England</p>
              </div>
              <time>2020–2022</time>
              <p className="cv-detail">
                Built a Bayesian hierarchical early warning system for national
                COVID forecasting, led machine learning products from data
                preparation to deployment, and mentored junior analysts and MSc
                researchers.
              </p>
            </article>
          </div>

          <div className="cv-group">
            <h3 className="subheading">Education</h3>
            {education.map((item) => (
              <article className="cv-entry" key={item.institution}>
                <div>
                  <strong>{item.qualification}</strong>
                  <p className="institution">{item.institution}</p>
                </div>
                <time>{item.dates.replace("-", "–")}</time>
                <p className="cv-detail">{item.detail}</p>
              </article>
            ))}
          </div>

          <div className="cv-group">
            <h3 className="subheading">Teaching &amp; service</h3>
            <p>
              Graduate Teaching Assistant for group-based AI projects on
              doctoral training programmes and international visits.
            </p>
            <p>
              Reviewer for NeurIPS 2024, ICML 2024, and ICLR 2025.
            </p>
          </div>
        </section>

        <section id="contact" className="content-section contact-section">
          <h2>Contact</h2>
          <p>
            The best way to reach me is by email at{" "}
            <a href="mailto:joshua.strong@eng.ox.ac.uk">
              joshua.strong@eng.ox.ac.uk
            </a>
            .
          </p>
        </section>
      </main>

      <footer>
        <span>© {new Date().getFullYear()} Joshua Strong</span>
      </footer>
    </>
  );
}
