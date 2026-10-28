// Fallback ESLint flat config for the code-audit skill.
// Used only when the target project has no ESLint config of its own.
import js from "@eslint/js";
import tseslint from "typescript-eslint";
import reactHooks from "eslint-plugin-react-hooks";
import security from "eslint-plugin-security";
import globals from "globals";

export default tseslint.config(
  { ignores: ["**/node_modules/**", "**/dist/**", "**/build/**", "**/*.min.js"] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  security.configs.recommended,
  {
    files: ["**/*.{js,jsx,mjs,cjs,ts,tsx}"],
    languageOptions: { globals: { ...globals.browser, ...globals.node } },
    plugins: { "react-hooks": reactHooks },
    rules: {
      ...reactHooks.configs.recommended.rules,
      eqeqeq: "error",
      "no-console": "warn",
      complexity: ["warn", 12],
      "max-depth": ["warn", 4],
      "max-lines-per-function": ["warn", 80],
      "no-implied-eval": "error",
    },
  },
);
