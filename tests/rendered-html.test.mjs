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
  assert.match(html, /class="bio-copy"/);
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
  assert.match(
    html,
    /content="https:\/\/josh-strong\.github\.io\/og-dark\.png"/,
  );
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
  assert.match(css, /\.bio\s*\{[\s\S]*grid-template-columns:\s*212px minmax\(0, 1fr\)/);
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
  assert.match(
    indexHtml,
    /Learning to defer in practice: A retrospective example with real chest X-rays and human annotations/i,
  );
  assert.match(indexHtml, /Behind the papers/i);
  assert.match(indexHtml, /\/blog\/coherent-hierarchical-learning-to-defer/);
  assert.match(indexHtml, /\/blog\/guided-deferral-with-language-models/);

  const introResponse = await render(
    "/blog/introduction-to-learning-to-defer",
  );
  assert.equal(introResponse.status, 200);
  const introHtml = await introResponse.text();

  assert.match(
    introHtml,
    /Learning to defer in practice: A retrospective example with real chest X-rays and human annotations/i,
  );
  assert.match(introHtml, /What this example demonstrates/i);
  assert.match(introHtml, /How deferral helps/i);
  assert.match(introHtml, /The one-vs-all deferral loss/i);
  assert.match(introHtml, /Equation[\s\S]{0,40}\(8\)/i);
  assert.match(introHtml, /class="katex"/);
  assert.match(introHtml, /ψ/);
  assert.match(introHtml, /BCELogit/);
  assert.match(introHtml, /hard rejector/i);
  assert.match(introHtml, /class="code-block/);
  assert.match(introHtml, /class="code-block python-code"/);
  assert.match(introHtml, /class="code-token-comment"/);
  assert.match(introHtml, /class="code-token-keyword"/);
  assert.match(introHtml, /class="code-token-function"/);
  assert.match(introHtml, /class="code-token-number"/);
  assert.match(introHtml, /Keep the image features; discard ResNet&#x27;s original classifier/);
  assert.match(introHtml, /The defer logit learns when this expert is correct/);
  assert.match(introHtml, /Output shape: \[batch, findings, 3\]/);
  assert.match(introHtml, /multilabel-l2d-architecture\.png/);
  assert.match(introHtml, /Multi-label OvA-L2D architecture/i);
  assert.match(introHtml, /class="architecture-figure"/);
  assert.match(introHtml, /<h2>Three ways to decide when to ask a human<\/h2>/i);
  assert.match(introHtml, /l2d-ova-vs-confidence-random\.png/);
  assert.match(introHtml, /200 independent random orderings/i);
  assert.match(introHtml, /same classifier/i);
  assert.match(introHtml, /Where OvA fits historically/);
  assert.match(introHtml, /Consistent Estimators for Learning to Defer to an Expert/);
  assert.match(introHtml, /proceedings\.mlr\.press\/v119\/mozannar20b\.html/);
  assert.match(introHtml, /not calibrated with respect to expert correctness/i);
  assert.match(introHtml, /preserve it while making/i);
  assert.match(introHtml, /personal favourite of mine/i);
  assert.match(introHtml, /proceedings\.mlr\.press\/v162\/verma22c\.html/);
  assert.match(introHtml, /Deep Residual Learning for Image Recognition/);
  assert.match(
    introHtml,
    /openaccess\.thecvf\.com\/content_cvpr_2016\/html\/He_Deep_Residual_Learning_CVPR_2016_paper\.html/,
  );
  assert.match(introHtml, /doi\.org\/10\.1038\/s41597-022-01498-w/);
  assert.doesNotMatch(introHtml, /class="post-facts"|Experiment summary/);
  assert.doesNotMatch(introHtml, /R9-annotated images|held-out test images/);
  assert.match(introHtml, /0\.8707/);
  assert.match(introHtml, /0\.8543/);
  assert.match(introHtml, /0\.8402/);
  assert.match(introHtml, /<h2>Limitations<\/h2>/i);
  assert.match(introHtml, /agreement between only two/i);
  assert.match(introHtml, /coherent-hierarchical-learning-to-defer/);
  assert.match(introHtml, /single, fixed expert/i);
  assert.match(introHtml, /prospective clinical evaluation/i);
  assert.match(introHtml, /<h2>Conclusion<\/h2>/i);
  assert.match(introHtml, /allocating responsibility, not/i);
  assert.doesNotMatch(introHtml, /CE-L2D/);

  const postResponse = await render(
    "/blog/identity-free-deferral",
  );
  assert.equal(postResponse.status, 200);
  const postHtml = await postResponse.text();

  assert.match(postHtml, /<h1>Deferring to experts the model has never met<\/h1>/i);
  assert.match(postHtml, /A competence profile, not an identity/i);
  assert.match(postHtml, /ifd-expert-shift\.png/i);
  assert.match(postHtml, /ifd-context-scaling\.png/i);
  assert.match(postHtml, /class="katex"/i);
  assert.match(postHtml, /Annotation efficiency matters/i);
  assert.match(postHtml, /Read the ICLR paper/i);
  assert.match(postHtml, /proceedings\.iclr\.cc/);
  assert.match(postHtml, /href="\/blog"[^>]*>Blogs<\/a>/);

  const chl2dResponse = await render(
    "/blog/coherent-hierarchical-learning-to-defer",
  );
  assert.equal(chl2dResponse.status, 200);
  const chl2dHtml = await chl2dResponse.text();

  assert.match(chl2dHtml, /The handover is part of the prediction/i);
  assert.match(chl2dHtml, /Three ways independent deferral can break/i);
  assert.match(chl2dHtml, /Taxonomic contradiction/i);
  assert.match(chl2dHtml, /Delegation violation/i);
  assert.match(chl2dHtml, /Deductive defect/i);
  assert.match(chl2dHtml, /Defining a coherent action/i);
  assert.match(chl2dHtml, /Exact coherent projection/i);
  assert.match(chl2dHtml, /Taxonomic Belief Propagation/i);
  assert.match(chl2dHtml, /chl2d-system-f1\.png/i);
  assert.match(chl2dHtml, /chl2d-incoherence-rate\.png/i);
  assert.match(chl2dHtml, /Read the paper on arXiv/i);

  const surveyResponse = await render("/blog/learning-to-defer-a-survey");
  assert.equal(surveyResponse.status, 200);
  const surveyHtml = await surveyResponse.text();
  assert.match(surveyHtml, /Four branches, one decision problem/i);
  assert.match(surveyHtml, /l2d-survey-taxonomy\.png/i);
  assert.match(surveyHtml, /One-stage learning/i);
  assert.match(surveyHtml, /Two-stage learning/i);
  assert.match(surveyHtml, /Post-hoc fine-tuning/i);
  assert.match(surveyHtml, /Before choosing a loss/i);

  const reviewResponse = await render(
    "/blog/human-ai-collaboration-in-healthcare",
  );
  assert.equal(reviewResponse.status, 200);
  const reviewHtml = await reviewResponse.text();
  assert.match(reviewHtml, /The evidence is about teams, not tools/i);
  assert.match(reviewHtml, /17,463/);
  assert.match(reviewHtml, /haic-study-map\.png/i);
  assert.match(reviewHtml, /haic-trust-evidence\.png/i);
  assert.match(reviewHtml, /Trust is not the same as reliance/i);
  assert.match(reviewHtml, /Human oversight is not a safety property/i);

  const guidedResponse = await render(
    "/blog/guided-deferral-with-language-models",
  );
  assert.equal(guidedResponse.status, 200);
  const guidedHtml = await guidedResponse.text();
  assert.match(guidedHtml, /A handover should carry something useful/i);
  assert.match(guidedHtml, /guided-deferral-system\.png/i);
  assert.match(guidedHtml, /guided-pilot-result\.png/i);
  assert.match(guidedHtml, /Calibration under imbalance/i);
  assert.match(guidedHtml, /20 \/ 20/);
  assert.match(guidedHtml, /What this does—and does not—show/i);
});

test("styles the notebook-based learning-to-defer article", async () => {
  const css = await readFile(new URL("../app/globals.css", import.meta.url), "utf8");

  assert.doesNotMatch(css, /\.post-facts\s*\{/);
  assert.match(css, /\.code-block\s*\{/);
  assert.match(css, /\.code-token-comment\s*\{/);
  assert.match(css, /\.code-token-keyword\s*\{/);
  assert.match(css, /\.code-token-function\s*\{/);
  assert.match(css, /\.code-token-string\s*\{/);
  assert.match(css, /\.loss-table\s*\{/);
  assert.match(css, /\.latex-display\s*\{/);
  assert.match(css, /\.latex-display \.katex-display\s*\{/);
  assert.match(css, /\.architecture-figure-scroll\s*\{/);
  assert.match(css, /\.architecture-figure img\s*\{/);
  assert.match(css, /\.experiment-figure img\s*\{/);
  assert.match(css, /\.method-note\s*\{/);
  assert.match(css, /\.post-limitations\s*\{/);
  assert.match(css, /\.coherence-cards\s*\{/);
  assert.match(css, /\.method-comparison\s*\{/);
  assert.match(css, /\.paper-figure\s*\{/);
  assert.match(css, /\.branch-grid/);
  assert.match(css, /\.evidence-stats/);
  assert.match(css, /\.identity-contrast/);
  assert.match(css, /\.prediction-sources/);
});
