---
name: nix-project
description: |
  Add or complete a Nix flake for a software project. Use this skill when a
  project lacks flake.nix, reproducible development tools, flake checks,
  formatting, or pre-commit hooks. Also use it when changing build, test,
  lint, container, or development-shell configuration in a flake.
license: MIT
compatibility: claude-code codex gemini-cli opencode
---

# Nix Project

Create the smallest complete Nix setup that matches the project.

## Workflow

1. Inspect the languages, package managers, build commands, tests, linters, and deployment outputs.
2. Inspect the backlog before implementation.
3. If the flake is absent or incomplete, add a backlog task and move it to `doing`.
4. Add one default development shell with all required development tools.
5. Expose applicable builds, tests, linters, formatters, and container images through `checks`.
6. Configure `cachix/git-hooks.nix` with hooks that match the repository contents.
7. Expose the pre-commit derivation through `checks.pre-commit`.
8. Install the hooks through the default development shell.
9. Run formatters, linters, pre-commit checks, and `nix flake check "path:$PWD" --no-write-lock-file`.
10. Move the backlog task to `done` only after all checks pass.

Do not add tools for languages or file formats that the project does not use.

## Minimal Pattern

Add the input:

```nix
git-hooks = {
  url = "github:cachix/git-hooks.nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Add the per-system configuration:

```nix
let
  preCommitCheck = inputs.git-hooks.lib.${system}.run {
    src = ./.;
    hooks = {
      alejandra.enable = true;
      deadnix.enable = true;
      statix.enable = true;
    };
  };
in {
  checks.pre-commit = preCommitCheck;
  formatter = pkgs.alejandra;

  devShells.default = pkgs.mkShell {
    packages = preCommitCheck.enabledPackages;
    inherit (preCommitCheck) shellHook;
  };
}
```

Replace the Nix hooks when the project uses another language. Keep generic file checks when they apply.

## Completion Criteria

- `nix develop` installs the hooks and provides the required tools.
- `nix flake check` runs every applicable project check.
- The formatter is available through `nix fmt`.
- The lock file records all flake inputs.
- The working tree contains no generated hook changes.
