"use client";

import { useEffect } from "react";
import { FiMoon, FiSun } from "react-icons/fi";

const themeStorageKey = "joshua-strong-theme";

function systemTheme() {
  return window.matchMedia("(prefers-color-scheme: dark)").matches
    ? "dark"
    : "light";
}

export function ThemeToggle() {
  useEffect(() => {
    const preference = window.matchMedia("(prefers-color-scheme: dark)");
    const followSystemPreference = () => {
      if (!localStorage.getItem(themeStorageKey)) {
        document.documentElement.dataset.theme = systemTheme();
      }
    };

    preference.addEventListener("change", followSystemPreference);
    return () =>
      preference.removeEventListener("change", followSystemPreference);
  }, []);

  function toggleTheme() {
    const currentTheme =
      document.documentElement.dataset.theme ?? systemTheme();
    const nextTheme = currentTheme === "dark" ? "light" : "dark";

    document.documentElement.dataset.theme = nextTheme;
    localStorage.setItem(themeStorageKey, nextTheme);
  }

  return (
    <button
      type="button"
      className="theme-toggle"
      data-theme-toggle
      aria-label="Toggle light and dark mode"
      title="Toggle light and dark mode"
      onClick={toggleTheme}
    >
      <FiMoon className="theme-icon theme-icon-moon" aria-hidden="true" />
      <FiSun className="theme-icon theme-icon-sun" aria-hidden="true" />
    </button>
  );
}
