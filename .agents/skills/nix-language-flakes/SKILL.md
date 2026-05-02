---
name: nix-language-flakes
description: "Write and review Nix code with flake-first patterns. Use for NixOS/Home Manager modules, option definitions, package lists, imports, and safe validation without sudo. Prefer flakes over legacy channels or nixos-rebuild flows."
argument-hint: "Task to perform in Nix files, target host/module, and desired behavior"
user-invocable: true
---
# Nix Language (Flake-First)

## When to Use
- Editing `.nix` files in flake-based repositories
- Adding or changing NixOS modules and Home Manager config
- Refactoring Nix expressions for readability and composability
- Validating configuration changes without privileged commands

## Rules
- Prefer flake outputs and inputs wiring instead of legacy channels.
- Prefer module composition (`imports`, options, small modules) over large monolithic files.
- Keep attribute sets explicit and stable; avoid unnecessary abstraction.
- Preserve existing formatting/style in the repository.
- Never require `sudo` for validation steps.

## Flake-First Workflow
1. Locate where the option should live (host file vs shared module vs home module).
2. Implement the smallest change in the most specific module that still keeps reuse practical.
3. Wire imports through the existing module graph if needed.
4. Validate with flake-native commands:
   - `nix flake show`
   - `nix flake check`
   - Optional host build checks:
     - `nix build .#nixosConfigurations.<host>.config.system.build.toplevel --no-link`

## Nix Writing Guidelines
- Prefer `lib.mkIf`, `lib.mkDefault`, and `lib.mkEnableOption` where appropriate.
- Keep package declarations deterministic and grouped logically.
- Use comments sparingly and only where intent is non-obvious.
- Avoid side effects and imperative assumptions; keep code declarative.

## Legacy Commands to Avoid
- `sudo nixos-rebuild switch` for validation
- channel-centric workflows (`nix-channel --update`) in flake repos
- changes that bypass flake outputs for system configuration

## Completion Checklist
- All modified Nix files parse correctly.
- Flake evaluation commands run successfully (or failures are clearly explained).
- Changes are minimal, scoped, and consistent with repository conventions.
