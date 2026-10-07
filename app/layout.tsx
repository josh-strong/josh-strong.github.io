import type { Metadata } from "next";
import "katex/dist/katex.min.css";
import "./globals.css";

const baseUrl = new URL("https://josh-strong.github.io");

export const metadata: Metadata = {
  metadataBase: baseUrl,
  title: "Joshua Strong | Trustworthy AI for Healthcare",
  description:
    "Joshua Strong is an Oxford DPhil student researching learning to defer and human-AI collaboration for safe clinical decision-making.",
  openGraph: {
    title: "Joshua Strong",
    description: "Human-AI collaboration for safer clinical AI",
    type: "website",
    images: [{ url: "/og-dark.png", width: 1200, height: 630 }],
  },
  twitter: {
    card: "summary_large_image",
    title: "Joshua Strong",
    description: "Human-AI collaboration for safer clinical AI",
    images: ["/og-dark.png"],
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html: `(function(){try{var key="joshua-strong-theme";var saved=localStorage.getItem(key);var theme=saved==="light"||saved==="dark"?saved:(window.matchMedia("(prefers-color-scheme: dark)").matches?"dark":"light");document.documentElement.dataset.theme=theme;}catch(e){}})();`,
          }}
        />
      </head>
      <body>{children}</body>
    </html>
  );
}
