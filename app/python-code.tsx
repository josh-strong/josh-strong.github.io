import type { ReactNode } from "react";

const keywordTokens = new Set(["class", "def", "for", "in", "return"]);
const literalTokens = new Set(["False", "None", "True"]);
const pythonTokenPattern =
  /("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*')|\b(class|def|for|in|return)\b|\b(False|None|True)\b|\b(\d+(?:\.\d+)?)\b|\b([A-Za-z_]\w*)(?=\s*\()/g;

function highlightCode(code: string, lineNumber: number) {
  const nodes: ReactNode[] = [];
  let cursor = 0;
  let tokenNumber = 0;

  for (const match of code.matchAll(pythonTokenPattern)) {
    const start = match.index ?? 0;
    const token = match[0];

    if (start > cursor) {
      nodes.push(code.slice(cursor, start));
    }

    let tokenClass = "code-token-function";
    if (token.startsWith('"') || token.startsWith("'")) {
      tokenClass = "code-token-string";
    } else if (keywordTokens.has(token)) {
      tokenClass = "code-token-keyword";
    } else if (literalTokens.has(token)) {
      tokenClass = "code-token-literal";
    } else if (/^\d/.test(token)) {
      tokenClass = "code-token-number";
    }

    nodes.push(
      <span className={tokenClass} key={`${lineNumber}-${tokenNumber}`}>
        {token}
      </span>,
    );
    cursor = start + token.length;
    tokenNumber += 1;
  }

  if (cursor < code.length) {
    nodes.push(code.slice(cursor));
  }

  return nodes;
}

function highlightLine(line: string, lineNumber: number) {
  const commentStart = line.indexOf("#");
  const code = commentStart === -1 ? line : line.slice(0, commentStart);
  const comment = commentStart === -1 ? null : line.slice(commentStart);

  return (
    <>
      {highlightCode(code, lineNumber)}
      {comment ? <span className="code-token-comment">{comment}</span> : null}
    </>
  );
}

export function PythonCodeBlock({ code, label }: { code: string; label: string }) {
  const lines = code.split("\n");

  return (
    <pre className="code-block python-code" aria-label={label}>
      <code>
        {lines.map((line, index) => (
          <span className="code-line" key={index}>
            {highlightLine(line, index)}
            {index < lines.length - 1 ? "\n" : null}
          </span>
        ))}
      </code>
    </pre>
  );
}
