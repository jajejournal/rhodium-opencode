{
  description = "opencode (x86_64 baseline) — overlay, package and Home Manager module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in
    {
      # Apply to any nixpkgs to override `opencode` with the baseline build.
      overlays.default = import ./overlay.nix;

      # Standalone package: `nix build github:jajejournal/rhodium-opencode`
      packages = forAllSystems (pkgs: rec {
        opencode = (pkgs.extend self.overlays.default).opencode;
        default = opencode;
      });

      # Home Manager module: installs the package + writes opencode.json.
      homeManagerModules.default = import ./home.nix;
    };
}
