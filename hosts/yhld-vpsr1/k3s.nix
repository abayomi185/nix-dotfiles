{config, ...}: {
  boot.supportedFilesystems = ["nfs"];
  services.rpcbind.enable = true;

  sops.secrets.k3s_token = {};

  systemd.services.k3s = {
    after = ["wg-quick-wg0.service"];
    wants = ["wg-quick-wg0.service"];
  };

  services.k3s = {
    enable = true;
    role = "agent";
    tokenFile = config.sops.secrets.k3s_token.path;
    serverAddr = "https://knode1.internal.yomitosh.media:6443";
    extraFlags = [
      "--node-ip=10.13.13.1"
      "--flannel-iface=wg0"
      # kube-proxy NodePort rules bypass the host firewall; keep them off the public IP
      "--kube-proxy-arg=nodeport-addresses=10.13.13.1/32"
      "--node-taint=dedicated=vps-public:NoSchedule"
      "--node-label=yomitosh.media/role=vps-public"
      "--node-label=yomitosh.media/ingress=true"
    ];
  };
}
