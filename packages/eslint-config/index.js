// Shared flat ESLint config for every TypeScript package and service.
// Module boundaries are enforced separately by dependency-cruiser (.dependency-cruiser.cjs).
import js from "@eslint/js";
import tseslint from "typescript-eslint";

export default tseslint.config(
  { ignores: ["dist/**", "coverage/**", "**/generated/**"] },
  js.configs.recommended,
  ...tseslint.configs.strict,
  {
    rules: {
      "@typescript-eslint/no-explicit-any": "error",
      // Nest modules are decorator-only classes.
      "@typescript-eslint/no-extraneous-class": ["error", { allowWithDecorator: true }],
      "@typescript-eslint/consistent-type-imports": "error",
      // Money paths must never use floats. Use integer paise / integer Sparks.
      "no-restricted-syntax": [
        "error",
        {
          selector: "CallExpression[callee.object.name='Math'][callee.property.name='random']",
          message: "Use the server CSPRNG (node:crypto randomInt) - spin/slot/matchmaking outcomes are audited. Blueprint §40.",
        },
      ],
      "no-restricted-properties": [
        "error",
        { object: "Date", property: "now", message: "Inject Clock from @heymey/domain/shared - all timers use server time and tests use a fake clock." },
      ],
    },
  },
  {
    files: ["**/*.spec.ts", "**/*.test.ts", "**/test/**"],
    rules: { "no-restricted-properties": "off" },
  },
);
