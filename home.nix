# ───────────────────────────────────────────────────────────────────────────
# opencode — Home Manager module
# ───────────────────────────────────────────────────────────────────────────
# Thin wrapper around Home Manager's built-in `programs.opencode`. It:
#   - enables opencode,
#   - points it at the x86_64 *baseline* build (via this flake's overlay) so it
#     also runs on old CPUs without AVX2,
#   - sets a sensible default: OpenCode's own FREE model (no API key needed).
#
# Run `opencode auth login` to add other providers (Anthropic, OpenAI, ...).
# ───────────────────────────────────────────────────────────────────────────
{
  pkgs,
  lib,
  ...
}:
let
  # Self-contained: apply our own overlay so the module works whether or not the
  # caller added `overlays.default` to nixpkgs.
  baseline =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      (pkgs.extend (import ./overlay.nix)).opencode
    else
      pkgs.opencode;
in
{
  programs.opencode = {
    enable = true;
    package = lib.mkDefault baseline;
    settings = {
      model = "opencode/deepseek-v4.1-flash-free";
      autoupdate = false;
    };
  };
}
