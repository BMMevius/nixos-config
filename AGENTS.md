# NixOS Config Agent Guide

This repository uses flake-based NixOS and Home Manager configuration.

## Primary Focus
- Edit configuration in `hosts/`, `modules/`, `home/`, and top-level flake files.
- Keep changes modular and reusable.
- Avoid unrelated refactors.

## Validation Workflow (No sudo)
Run validation in this order when possible:
1. `nix flake show`
2. `nix flake check`
3. Host builds (no switch):
   - `nix build .#nixosConfigurations.desktop.config.system.build.toplevel --no-link`
   - `nix build .#nixosConfigurations.work-laptop.config.system.build.toplevel --no-link`

If new files were added and flake commands do not pick them up, stage them first with `git add`.

## Constraints
- Do not use `sudo` for validation.
- Prefer flake-native workflows over channel-based workflows.
- Do not use legacy non-flake rebuild flows when validating configuration changes.

## File Instructions
- General NixOS/Home Manager editing workflow: [nixos-config-editor instructions](.github/instructions/nixos-config-editor.instructions.md)
- Nix style and flake-first rules: [nix-language-flakes instructions](.github/instructions/nix-language-flakes.instructions.md)
