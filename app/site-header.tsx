import Link from "next/link";
import { ThemeToggle } from "./theme-toggle";

type SiteHeaderProps = {
  active?: "home" | "blog";
};

export function SiteHeader({ active = "home" }: SiteHeaderProps) {
  return (
    <header className="site-header">
      <div className="nav-inner">
        <Link className="wordmark" href="/" aria-label="Joshua Strong, home">
          Joshua Strong
        </Link>
        <div className="nav-actions">
          <nav aria-label="Primary navigation">
            <Link className={active === "home" ? "active" : undefined} href="/#about">
              About
            </Link>
            <Link href="/#research">Research</Link>
            <Link href="/#publications">Publications</Link>
            <Link href="/#cv">CV</Link>
            <Link className={active === "blog" ? "active" : undefined} href="/blog">
              Blogs
            </Link>
          </nav>
          <ThemeToggle />
        </div>
      </div>
    </header>
  );
}
