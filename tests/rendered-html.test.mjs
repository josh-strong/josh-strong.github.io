import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

async function render() {
  const workerUrl = new URL("../dist/server/index.js", import.meta.url);
  workerUrl.searchParams.set("test", `${process.pid}-${Date.now()}`);
  const { default: worker } = await import(workerUrl.href);

  return worker.fetch(
    new Request("http://localhost/", {
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
  assert.match(html, /<h1>About me<\/h1>/i);
  assert.match(html, /Human-AI Collaboration in Healthcare: A Scoping Review/);
  assert.match(html, /https:\/\/www\.nature\.com\/articles\/s41746-026-02918-6/);
  assert.doesNotMatch(html, /joshua-strong-cv\.pdf/);
  assert.match(html, /src="\/joshua-strong\.png"/);
  assert.match(html, /data-icon="mail"/);
  assert.match(html, /data-icon="google-scholar"/);
  assert.match(html, /data-icon="github"/);
  assert.match(html, /data-icon="linkedin"/);
  assert.match(
    html,
    /scholar\.google\.co\.uk\/citations\?user=vFoP8mIAAAAJ&amp;hl=en/,
  );
  assert.match(html, /https:\/\/github\.com\/josh-strong/);
  assert.match(html, /https:\/\/www\.linkedin\.com\/in\/josh-strong\//);
  assert.match(html, /content="http:\/\/localhost(?::3000)?\/og-dark\.png"/);
  assert.doesNotMatch(html, /codex-preview|Building your site/);
});

test("keeps the reference-inspired dark layout and responsive guardrails", async () => {
  const [css, page, layout] = await Promise.all([
    readFile(new URL("../app/globals.css", import.meta.url), "utf8"),
    readFile(new URL("../app/page.tsx", import.meta.url), "utf8"),
    readFile(new URL("../app/layout.tsx", import.meta.url), "utf8"),
  ]);

  assert.match(css, /--background:\s*#191919/);
  assert.match(css, /--navigation:\s*#232323/);
  assert.match(css, /width:\s*min\(720px,\s*calc\(100%\s*-\s*40px\)\)/);
  assert.match(css, /font-size:\s*40px/);
  assert.match(css, /@media \(max-width:\s*620px\)/);
  assert.match(page, /className="profile-photo"/);
  assert.match(page, /className="publication-list"/);
  assert.match(layout, /\/og-dark\.png/);
});
