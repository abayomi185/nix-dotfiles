# Run a binary from a fixed path outside /nix/store.
#
# macOS grants Accessibility/Input permissions per file path. `nix store optimise`
# hard-links identical store files, so one binary ends up with several paths
# (e.g. /nix/store/.links/...). macOS then sometimes checks a path that was never
# granted, and skhd/yabai silently lose their event taps (keys/clicks dropped).
# A copy in /usr/local/libexec has exactly one path, so the grant always matches.
{ pkgs, name, src }:
let
  dest = "/usr/local/libexec/${name}";
in
{
  # Stand-in package whose bin/<name> points at the stable copy.
  package = pkgs.runCommand "${name}-stable" { } ''
    mkdir -p $out/bin
    ln -s ${dest} $out/bin/${name}
  '';

  # Runs before launchd agents are (re)loaded. Replaces the copy atomically,
  # and only when the binary changed, so the grant survives rebuilds.
  activation = ''
    if ! cmp -s ${src}/bin/${name} ${dest}; then
      echo "installing ${name} to ${dest}..." >&2
      mkdir -p /usr/local/libexec
      cp ${src}/bin/${name} ${dest}.tmp
      chmod 755 ${dest}.tmp
      mv -f ${dest}.tmp ${dest}
    fi
  '';
}
