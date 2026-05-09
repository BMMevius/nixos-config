---
description: "Use when editing NixOS or Home Manager config in this repository (nix, nixos, home-manager, flake, modules, hosts, configuration.nix, home.nix)."
applyTo: "**/*.nix"
---

# NixOS Config Editor Workflow

## Scope
- Prefer edits in `hosts/`, `modules/`, `home/`, and top-level flake files.
- Keep changes aligned with the existing module structure.

## Constraints
- Do not use `sudo` for validation commands.
- Do not introduce unrelated refactors.
- Prefer flake-native validation commands.

## Validation Order
1. `nix flake show`
2. `nix flake check`
3. Host build checks (without switch):
   - `nix build .#nixosConfigurations.desktop.config.system.build.toplevel --no-link`
   - `nix build .#nixosConfigurations.work-laptop.config.system.build.toplevel --no-link`

## Notes
- If newly created files are not included during evaluation, stage them first with `git add`.