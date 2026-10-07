declare module "katex" {
  type KatexOptions = {
    displayMode?: boolean;
    output?: "html" | "mathml" | "htmlAndMathml";
    strict?: boolean | "ignore" | "warn" | "error";
    throwOnError?: boolean;
  };

  const katex: {
    renderToString(expression: string, options?: KatexOptions): string;
  };

  export default katex;
}
