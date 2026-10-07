import type { Metadata } from "next";
import Link from "next/link";
import { SiteHeader } from "../site-header";
import { blogPosts } from "./posts";

export const metadata: Metadata = {
  title: "Blogs | Joshua Strong",
  description:
    "Accessible notes on Joshua Strong's research in learning to defer and human-AI collaboration in healthcare.",
};

export default function BlogIndex() {
  const [primer, ...publicationNotes] = blogPosts;

  return (
    <>
      <SiteHeader active="blog" />
      <main className="site-main blog-main">
        <header className="blog-intro">
          <p className="eyebrow">Research notes</p>
          <h1>Blogs</h1>
          <p className="blog-deck">
            Plain-language introductions to learning to defer, human–AI
            collaboration, and the ideas behind my publications.
          </p>
        </header>

        <Link className="featured-post" href={`/blog/${primer.slug}`}>
          <div className="post-meta">
            <span>{primer.label}</span>
            <span>{primer.readTime}</span>
          </div>
          <h2>{primer.title}</h2>
          <p>{primer.description}</p>
          <span className="read-more">Start here <span aria-hidden="true">→</span></span>
        </Link>

        <section className="blog-archive" aria-labelledby="publication-notes">
          <h2 id="publication-notes">Behind the papers</h2>
          <div className="blog-list">
            {publicationNotes.map((post) => (
              <article className="blog-card" key={post.slug}>
                <Link href={`/blog/${post.slug}`}>
                  <div className="post-meta">
                    <span>{post.year}</span>
                    <span>{post.readTime}</span>
                  </div>
                  <h3>{post.title}</h3>
                  <p>{post.description}</p>
                  <span className="read-more">Read note <span aria-hidden="true">→</span></span>
                </Link>
              </article>
            ))}
          </div>
        </section>
      </main>
      <footer>
        <span>© {new Date().getFullYear()} Joshua Strong</span>
      </footer>
    </>
  );
}
