{
  description = "Personal coding-agent skills";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        preCommitCheck = inputs.git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            alejandra.enable = true;
            check-added-large-files.enable = true;
            check-merge-conflicts.enable = true;
            deadnix.enable = true;
            end-of-file-fixer.enable = true;
            statix.enable = true;
            trim-trailing-whitespace.enable = true;
          };
        };
      in {
        checks.pre-commit = preCommitCheck;
        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          packages = preCommitCheck.enabledPackages;
          inherit (preCommitCheck) shellHook;
        };
      };
    };
}
