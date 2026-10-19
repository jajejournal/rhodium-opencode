# ───────────────────────────────────────────────────────────────────────────
# opencode — Home Manager module
# ───────────────────────────────────────────────────────────────────────────
# Installs the (overlaid, x86_64 baseline) `opencode` package and drops its
# config at ~/.config/opencode/opencode.json.
#
# Default model: OpenCode's own FREE model (no API key required):
#   opencode/deepseek-v4.1-flash-free
#
# To add other providers (Anthropic, OpenAI, ...) run:  opencode auth login
# ───────────────────────────────────────────────────────────────────────────
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.opencode;
in
{
  options.programs.opencode = {
    enable = lib.mkEnableOption "opencode AI coding agent";
    model = lib.mkOption {
      type = lib.types.str;
      default = "opencode/deepseek-v4.1-flash-free";
      description = "Default model written to opencode.json.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.opencode ];

    xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      model = cfg.model;
      # Nix owns the binary, so disable self-updating (avoids clobbering the
      # read-only Nix store and version drift).
      autoupdate = false;
    };
  };
}
