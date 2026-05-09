---
description: "Use for Nix syntax/style and flake-first workflows when editing .nix files in this repo."
applyTo: "**/*.nix"
---

# Nix Language (Flake-First)

## Rules
- Prefer flake outputs and inputs wiring over channel-based workflows.
- Prefer module composition (`imports`, options, small modules) over monolithic files.
- Keep attribute sets explicit and stable.
- Preserve existing repository formatting and style.

## Writing Guidelines
- Prefer `lib.mkIf`, `lib.mkDefault`, and `lib.mkEnableOption` where appropriate.
- Keep package declarations deterministic and grouped logically.
- Use comments sparingly and only when intent is non-obvious.
- Keep code declarative and avoid imperative assumptions.

## Validation Checklist
- Modified Nix files parse correctly.
- Flake evaluation commands succeed or failures are clearly explained.
- Changes are minimal and scoped to the task.

## Avoid
- `sudo`-based validation workflows.
- Channel update workflows.
- Legacy non-flake rebuild flows for validation.