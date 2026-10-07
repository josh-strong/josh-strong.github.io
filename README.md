# Joshua Strong — academic website

Source for [josh-strong.github.io](https://josh-strong.github.io), including
publication notes and an introduction to learning to defer.

## Local development

Requires Node.js 22.13 or newer.

```bash
npm ci
npm run dev
```

## Builds

- `npm test` verifies the ChatGPT Sites/Vinext build and rendered content.
- `npm run build:pages` creates the static GitHub Pages export in `out/`.

Pushing to `master` runs `.github/workflows/deploy-pages.yml` and publishes the
static export to GitHub Pages.
