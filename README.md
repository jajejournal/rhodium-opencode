# rhodium-opencode

[opencode](https://opencode.ai) packaged as a reusable Nix flake: an overlay, a
standalone package and a Home Manager module.

It installs upstream's **x86_64 "baseline"** build instead of compiling from
source. nixpkgs builds opencode with a Bun binary that targets AVX2, which dies
with `Illegal instruction (core dumped)` on CPUs that have AVX but not AVX2
(Sandy/Ivy Bridge — e.g. ThinkPad T420). Upstream ships a baseline flavour for
exactly those machines, and it runs fine on modern CPUs too.

## Usage

### Overlay

```nix
{
  inputs.rhodium-opencode.url = "github:jajejournal/rhodium-opencode";
  # then, in nixpkgs config:
  nixpkgs.overlays = [ inputs.rhodium-opencode.overlays.default ];
}
```

### Package

```bash
nix build github:jajejournal/rhodium-opencode
```

### Home Manager

```nix
{
  imports = [ inputs.rhodium-opencode.homeManagerModules.default ];
  programs.opencode = {
    enable = true;
    model = "opencode/deepseek-v4.1-flash-free"; # default
  };
}
```

## Updating

Bump `version` in `overlay.nix` and refresh the hash:

```bash
nix-prefetch-url https://github.com/anomalyco/opencode/releases/download/vX.Y.Z/opencode-linux-x64-baseline.tar.gz
```

Keep it reasonably fresh: each release bakes in the catalogue of models it
knows about, so an old binary won't offer newer models (e.g. `1.18.x` lacks
`deepseek-v4.1-flash-free`, which `1.19.x` has).

## License

MIT
