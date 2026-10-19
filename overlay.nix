final: prev:
# ───────────────────────────────────────────────────────────────────────────
# opencode — x86_64 "baseline" build
# ───────────────────────────────────────────────────────────────────────────
# opencode is a Bun-compiled binary, and nixpkgs compiles it with the regular
# Bun build, which targets CPUs that have AVX2. On older machines (ThinkPad
# T420 / Sandy Bridge and Ivy Bridge: AVX but no AVX2) the result dies right
# away with:
#
#     Illegal instruction (core dumped)
#
# Upstream publishes an extra "baseline" flavour of every release for exactly
# those CPUs (see anomalyco/opencode#13379), so here we install that prebuilt
# binary instead of building opencode from source. It runs on modern CPUs too,
# so this is the default for every x86_64 machine.
#
# To bump it: bump `version` and refresh the hash with
#   nix-prefetch-url https://github.com/anomalyco/opencode/releases/download/vX.Y.Z/opencode-linux-x64-baseline.tar.gz
#
# Worth keeping reasonably fresh: every release bakes in the catalogue of models
# it knows about, so an older binary does not offer models that came out later.
# A 1.18.x build, for instance, has no `deepseek-v4.1-flash-free` (1.19.x does),
# even though the model is free on OpenCode's side. The free models need no API
# key, so the pin is what decides which ones you can pick.
let
  version = "1.19.3";
  src = prev.fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-x64-baseline.tar.gz";
    hash = "sha256-Uxz/JEESnDDw7dWHivSUEIrQf1/rRtfuKaKluDCldl0=";
  };
in
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isx86_64 {
  opencode = prev.stdenvNoCC.mkDerivation {
    pname = "opencode";
    inherit version src;

    strictDeps = true;

    # autoPatchelfHook gives the binary the RPATH it needs for glibc /
    # libstdc++ and for the libraries it loads at runtime (desktop
    # notifications via libsecret, sound via alsa/pulse).
    nativeBuildInputs = [
      prev.autoPatchelfHook
      prev.makeWrapper
    ];
    buildInputs = [
      prev.alsa-lib
      prev.libsecret
      prev.libpulseaudio
      prev.openssl
      prev.stdenv.cc.cc.lib
    ];

    dontConfigure = true;
    dontBuild = true;
    # Never strip it: the Bun runtime lives inside this same file.
    dontStrip = true;
    # The release tarball contains the bare `opencode` binary, with no
    # top-level directory, which the default unpacker rejects
    # ("unpacker appears to have produced no directories"). Extract it
    # ourselves instead.
    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      tar -xzf ${src}
      install -Dm755 opencode $out/bin/opencode

      wrapProgram $out/bin/opencode \
        --prefix PATH : ${prev.lib.makeBinPath [ prev.ripgrep ]} \
        --set OPENCODE_DISABLE_AUTOUPDATE true

      runHook postInstall
    '';

    meta = {
      description = "AI coding agent built for the terminal (x86_64 baseline build)";
      homepage = "https://github.com/anomalyco/opencode";
      changelog = "https://github.com/anomalyco/opencode/releases/tag/v${version}";
      license = prev.lib.licenses.mit;
      sourceProvenance = with prev.lib.sourceTypes; [ binaryNativeCode ];
      mainProgram = "opencode";
      platforms = [ "x86_64-linux" ];
    };
  };
}
