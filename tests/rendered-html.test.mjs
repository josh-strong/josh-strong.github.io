import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

async function render(path = "/") {
  const workerUrl = new URL("../dist/server/index.js", import.meta.url);
  workerUrl.searchParams.set("test", `${process.pid}-${Date.now()}`);
  const { default: worker } = await import(workerUrl.href);

  return worker.fetch(
    new Request(`http://localhost${path}`, {
      headers: { accept: "text/html" },
    }),
    {
      ASSETS: {
        fetch: async () => new Response("Not found", { status: 404 }),
      },
    },
    {
      waitUntil() {},
      passThroughOnException() {},
    },
  );
}

test("server-renders Joshua Strong's academic website", async () => {
  const response = await render();
  assert.equal(response.status, 200);
  assert.match(response.headers.get("content-type") ?? "", /^text\/html\b/i);

  const html = await response.text();
  assert.match(
    html,
    /<title>Joshua Strong \| Trustworthy AI for Healthcare<\/title>/i,
  );
  assert.match(html, /<h1>About<\/h1>/i);
  assert.doesNotMatch(
    html,
    /Thesis: Model-Agnostic Meta-Learning for Few-Shot Deep Learning/i,
  );
  assert.match(html, /Human-AI Collaboration in Healthcare: A Scoping Review/);
  assert.match(html, /https:\/\/www\.nature\.com\/articles\/s41746-026-02918-6/);
  assert.match(
    html,
    /Coherent Hierarchical Multi-Label Learning to Defer for Medical Imaging/,
  );
  assert.match(html, /https:\/\/arxiv\.org\/abs\/2605\.02734/);
  assert.match(html, /Learning to Defer: A Survey/);
  assert.match(html, /https:\/\/doi\.org\/10\.5281\/zenodo\.17843044/);
  assert.match(html, /Advances in Neural Information Processing Systems \(NeurIPS\)/);
  assert.match(html, /ACM Computing Surveys/);
  assert.match(html, /class="author-self">Joshua Strong<\/strong>/);
  assert.doesNotMatch(html, /joshua-strong-cv\.pdf/);
  assert.match(
    html,
    /src="\/joshua-strong\.png" alt="Portrait of Joshua Strong" width="192" height="256"/,
  );
  assert.match(html, /data-icon="google-scholar"/);
  assert.match(html, /data-icon="github"/);
  assert.match(html, /data-icon="linkedin"/);
  assert.match(html, /data-theme-toggle="true"/);
  assert.match(html, /href="\/blog">Blogs<\/a>/);
  assert.match(html, /Toggle light and dark mode/);
  assert.match(
    html,
    /scholar\.google\.co\.uk\/citations\?user=vFoP8mIAAAAJ&amp;hl=en/,
  );
  assert.match(html, /https:\/\/github\.com\/josh-strong/);
  assert.match(html, /https:\/\/www\.linkedin\.com\/in\/josh-strong\//);
  assert.doesNotMatch(html, /joshua\.strong@eng\.ox\.ac\.uk|mailto:/i);
  assert.doesNotMatch(html, /Ranked second in cohort/i);
  assert.match(html, /Please feel free to get in touch via/);
  assert.match(html, /worked as a data scientist across NHS England and an NHS trust/i);
  assert.match(html, /contributed to a Bayesian hierarchical early warning system/i);
  assert.doesNotMatch(html, /built a Bayesian hierarchical early warning system/i);
  assert.match(html, /content="http:\/\/localhost(?::3000)?\/og-dark\.png"/);
  assert.doesNotMatch(html, /codex-preview|Building your site/);
});

test("supports system-aware light and dark themes with responsive guardrails", async () => {
  const [css, page, layout, themeToggle, siteHeader] = await Promise.all([
    readFile(new URL("../app/globals.css", import.meta.url), "utf8"),
    readFile(new URL("../app/page.tsx", import.meta.url), "utf8"),
    readFile(new URL("../app/layout.tsx", import.meta.url), "utf8"),
    readFile(new URL("../app/theme-toggle.tsx", import.meta.url), "utf8"),
    readFile(new URL("../app/site-header.tsx", import.meta.url), "utf8"),
  ]);

  assert.match(css, /--background:\s*#f6f6f3/);
  assert.match(css, /font-family:\s*"Linux Libertine"/);
  assert.match(css, /linux-libertine-regular\.woff2/);
  assert.match(css, /linux-libertine-bold\.woff2/);
  assert.match(css, /html\[data-theme="dark"\]/);
  assert.match(css, /@media \(prefers-color-scheme:\s*dark\)/);
  assert.match(css, /--background:\s*#191919/);
  assert.match(css, /--navigation:\s*#232323/);
  assert.match(css, /width:\s*min\(720px,\s*calc\(100%\s*-\s*40px\)\)/);
  assert.match(css, /font-size:\s*40px/);
  assert.match(css, /@media \(max-width:\s*620px\)/);
  assert.match(page, /className="profile-photo"/);
  assert.match(page, /className="publication-timeline"/);
  assert.match(page, /className="timeline-year"/);
  assert.doesNotMatch(page, /publication-status/);
  assert.match(css, /\.publication-timeline::before/);
  assert.match(css, /\.publication::before/);
  assert.match(page, /<SiteHeader active="home" \/>/);
  assert.match(siteHeader, /<ThemeToggle \/>/);
  assert.match(layout, /joshua-strong-theme/);
  assert.match(layout, /prefers-color-scheme: dark/);
  assert.match(themeToggle, /localStorage\.setItem\(themeStorageKey, nextTheme\)/);
  assert.match(themeToggle, /addEventListener\("change"/);
  assert.match(layout, /\/og-dark\.png/);
});

test("renders a blog index and individual publication notes", async () => {
  const indexResponse = await render("/blog");
  assert.equal(indexResponse.status, 200);
  const indexHtml = await indexResponse.text();

  assert.match(indexHtml, /<title>Blogs \| Joshua Strong<\/title>/i);
  assert.match(indexHtml, /<h1>Blogs<\/h1>/i);
  assert.match(indexHtml, /An introduction to learning to defer/i);
  assert.match(indexHtml, /Behind the papers/i);
  assert.match(indexHtml, /\/blog\/coherent-hierarchical-learning-to-defer/);
  assert.match(indexHtml, /\/blog\/guided-deferral-with-language-models/);

  const postResponse = await render(
    "/blog/identity-free-deferral",
  );
  assert.equal(postResponse.status, 200);
  const postHtml = await postResponse.text();

  assert.match(postHtml, /<h1>Deferring to experts the model has never met<\/h1>/i);
  assert.match(postHtml, /Removing the identity shortcut/i);
  assert.match(postHtml, /Read the ICLR paper/i);
  assert.match(postHtml, /proceedings\.iclr\.cc/);
  assert.match(postHtml, /href="\/blog"[^>]*>Blogs<\/a>/);
});
