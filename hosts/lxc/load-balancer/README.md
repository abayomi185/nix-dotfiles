# Load Balancer (400)

LXC container for resolving traffic and load balancing to internal services and kubernetes cluster.

This manages traffic to:

- Kubernetes cluster
- LLM inference server
- Monitoring dashboard

```bash
   nix run nixpkgs#nixos-rebuild -- switch \
     --flake .#kloadbalancer \
     --build-host root@kloadbalancer.internal.yomitosh.media \
     --target-host root@kloadbalancer.internal.yomitosh.media
     # --use-remote-sudo
```
