import katex from "katex";

type LatexProps = {
  children: string;
  display?: boolean;
};

export function Latex({ children, display = false }: LatexProps) {
  const html = katex.renderToString(children, {
    displayMode: display,
    output: "htmlAndMathml",
    strict: false,
    throwOnError: true,
  });

  if (display) {
    return (
      <div
        className="latex-display"
        dangerouslySetInnerHTML={{ __html: html }}
      />
    );
  }

  return (
    <span
      className="latex-inline"
      dangerouslySetInnerHTML={{ __html: html }}
    />
  );
}
