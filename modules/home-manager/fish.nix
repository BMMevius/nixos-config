{ ... }:
{
  programs.fish = {
    enable = true;
  };

  programs.fish.loginShellInit = ''
    set -gx SSH_AUTH_SOCK "/run/user/"(id -u)"/ssh-agent"

    if test -n "$SSH_AUTH_SOCK"
      systemctl --user import-environment SSH_AUTH_SOCK
      dbus-update-activation-environment --systemd SSH_AUTH_SOCK
    end

    if test -f ~/.ssh/id_ed25519
      if not ssh-add -l | grep -q (ssh-keygen -lf ~/.ssh/id_ed25519 | awk '{print $2}')
        ssh-add ~/.ssh/id_ed25519
      end
    end
  '';
}
