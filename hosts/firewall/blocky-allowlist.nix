# Blocky custom allowlist — domains exempt from ad blocking.
#
# Add entries here to unblock sites caught by the denylist.
# Supports exact matches ("opencode.ai") and wildcards ("*.opencode.ai").
# Deploy with: nixos-rebuild switch --flake .#firewall ...
[
  "opencode.ai"
  "*.opencode.ai"
]
