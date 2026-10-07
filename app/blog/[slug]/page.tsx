import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { SiteHeader } from "../../site-header";
import { blogPosts, getBlogPost } from "../posts";

type BlogPostPageProps = {
  params: Promise<{ slug: string }>;
};

export function generateStaticParams() {
  return blogPosts.map((post) => ({ slug: post.slug }));
}

export async function generateMetadata({
  params,
}: BlogPostPageProps): Promise<Metadata> {
  const { slug } = await params;
  const post = getBlogPost(slug);

  if (!post) {
    return { title: "Blog | Joshua Strong" };
  }

  return {
    title: `${post.title} | Joshua Strong`,
    description: post.description,
  };
}

export default async function BlogPostPage({ params }: BlogPostPageProps) {
  const { slug } = await params;
  const post = getBlogPost(slug);

  if (!post) {
    notFound();
  }

  return (
    <>
      <SiteHeader active="blog" />
      <main className="site-main blog-post-main">
        <Link className="blog-back" href="/blog">
          <span aria-hidden="true">←</span> All blogs
        </Link>

        <article className="blog-post">
          <header className="blog-post-header">
            <div className="post-meta">
              <span>{post.label}</span>
              <span>{post.year}</span>
              <span>{post.readTime}</span>
            </div>
            <h1>{post.title}</h1>
            <p className="blog-deck">{post.description}</p>
          </header>

          <div className="blog-post-body">
            {post.sections.map((section) => (
              <section key={section.heading}>
                <h2>{section.heading}</h2>
                {section.paragraphs.map((paragraph) => (
                  <p key={paragraph}>{paragraph}</p>
                ))}
              </section>
            ))}
          </div>

          {post.paperUrl && (
            <aside className="paper-callout">
              <span>Original research</span>
              <a href={post.paperUrl}>{post.paperLabel ?? "Read the paper"} <span aria-hidden="true">↗</span></a>
            </aside>
          )}
        </article>

        <nav className="post-footer-nav" aria-label="Blog navigation">
          <Link href="/blog">
            Browse all blogs <span aria-hidden="true">→</span>
          </Link>
        </nav>
      </main>
      <footer>
        <span>© {new Date().getFullYear()} Joshua Strong</span>
      </footer>
    </>
  );
}
