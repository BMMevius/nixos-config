{ pkgs, ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "none";
    extraUpFlags = [
      "--accept-routes=false"
    ];
  };

  # Ensure the node reconnects to tailnet on startup.
  systemd.services.tailscale-autoup = {
    description = "Bring Tailscale up at boot";
    after = [
      "tailscaled.service"
      "network-online.target"
    ];
    wants = [
      "tailscaled.service"
      "network-online.target"
    ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      tailscale
      gnugrep
      bash
    ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -euo pipefail
      if tailscale status --json | grep -q '"BackendState": "Running"'; then
        exit 0
      fi
      tailscale up --accept-routes=false
    '';
  };

  # Keep tailnet exposure limited to Nextcloud via nginx (80/443).
  networking.firewall.extraInputRules = ''
    iifname "tailscale0" tcp dport != { 80, 443 } drop
    iifname "tailscale0" udp dport != { 80, 443 } drop
  '';

  services.networkd-dispatcher = {
    enable = true;
    rules."50-tailscale-optimizations" = {
      onState = [ "routable" ];
      script = ''
        ${pkgs.ethtool}/bin/ethtool -K eth0 rx-udp-gro-forwarding on rx-gro-list off
      '';
    };
  };
}
