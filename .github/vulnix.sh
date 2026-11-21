#!/usr/bin/env bash
# Scan every host's (unbuilt) system closure for CVEs with vulnix.
# Usage: vulnix.sh [base-rev]  -- with base-rev, also report new/fixed CVEs.
# Writes markdown to $GITHUB_STEP_SUMMARY (stdout when unset).
set -euo pipefail

exclude='^nixosConfigurations\.(livecd|nixos-anywhere-generic.*|vm-game)$'
whitelist=$(dirname "$0")/vulnix.toml
out=${GITHUB_STEP_SUMMARY:-/dev/stdout}

# $1: flake ref -> vulnix JSON for all hosts
vulnix_json() {
  local drvs=() h
  for h in $(nix eval --json "$1#nixosConfigurations" --apply builtins.attrNames | jq -r '.[] | "nixosConfigurations.\(.)"') \
    $(nix eval --json "$1#darwinConfigurations" --apply builtins.attrNames | jq -r '.[] | "darwinConfigurations.\(.)"'); do
    [[ $h =~ $exclude ]] && continue
    echo "evaluating $1#$h" >&2
    drvs+=("$(nix eval --raw "$1#$h.config.system.build.toplevel.drvPath")")
  done
  # exit 2 = vulnerabilities found
  nix run nixpkgs#vulnix -- -w "$whitelist" --json "${drvs[@]}" || (($? == 2))
}

# $1: flake ref -> "pname\tversion\tCVE\tCVSS" lines
scan() {
  vulnix_json "$1" | jq -r '.[] | .pname as $p | .version as $v | .cvssv3_basescore as $s
    | .affected_by[] | [$p, $v, ., ($s[.] // "-" | tostring)] | @tsv' | sort -u
}

# lines of $2 whose package+CVE is absent from $1
minus() { awk -F'\t' 'NR==FNR {k[$1 FS $3]; next} !($1 FS $3 in k)' "$1" "$2"; }
count() { cut -f1,3 "$1" | sort -u | wc -l | tr -d ' '; }

# stdin: scan lines -> markdown table, worst first, one row per package+CVE
table() {
  echo
  echo "| package | version | CVE | CVSS |"
  echo "|---|---|---|---|"
  sort -t$'\t' -k4,4rn | awk -F'\t' '!seen[$1 FS $3]++ {
    printf "| %s | %s | [%s](https://nvd.nist.gov/vuln/detail/%s) | %s |\n", $1, $2, $3, $3, $4 }'
  echo
}

tmp=$(mktemp -d)
scan "git+file://$PWD" >"$tmp/head"

{
  echo "## vulnix"
  if [[ -n ${1:-} ]]; then
    scan "git+file://$PWD?rev=$(git rev-parse "$1")" >"$tmp/base"
    minus "$tmp/base" "$tmp/head" >"$tmp/new"
    minus "$tmp/head" "$tmp/base" >"$tmp/fixed"
    echo "### New ($(count "$tmp/new"))"
    table <"$tmp/new"
    echo "### Fixed ($(count "$tmp/fixed"))"
    table <"$tmp/fixed"
  fi
  echo "<details><summary>All ($(count "$tmp/head"))</summary>"
  table <"$tmp/head"
  echo "</details>"
} >>"$out"
