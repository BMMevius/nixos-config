{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  osConfig,
  ...
}:
let
  hostName = osConfig.networking.hostName or "";
  isWorkLaptop = hostName == "laptop-bastiaan";

  hyprlandHostSettings =
    {
      desktop = {
        monitor = [
          "DP-1, preferred, 0x0, 1"
          "HDMI-A-1, preferred, 1920x0, 1"
        ];

        workspace = [
          "1, monitor:DP-1, default:true"
          "2, monitor:HDMI-A-1"
        ];
      };

      "work-laptop" = {
        monitor = [ ", preferred, auto, 1" ];
        workspace = [ "1, default:true" ];
      };
    }
    .${hostName} or {
      monitor = [ ", preferred, auto, 1" ];
      workspace = [ "1, default:true" ];
    };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    xwayland.enable = true;
    systemd.enable = false;
    configType = "hyprlang";

    # Main hyprland configuration
    settings = {
      ecosystem.no_update_news = true;

      monitor = hyprlandHostSettings.monitor;

      workspace = hyprlandHostSettings.workspace;

      general = {
        border_size = 2;
        gaps_in = 0;
        gaps_out = 0;
        float_gaps = 0;
        gaps_workspaces = 0;
        "col.active_border" = "rgba(33ccffff)";
        "col.inactive_border" = "rgba(bebebeff)";
        "col.nogroup_border" = "rgba(ffffaaff)";
        "col.nogroup_border_active" = "rgba(ffff00ff)";
        layout = "dwindle";
        no_focus_fallback = false;
        resize_on_border = false;
        extend_border_grab_area = 15;
        hover_icon_on_border = true;
        allow_tearing = false;
        resize_corner = 0;
        modal_parent_blocking = true;
      };

      decoration = {
        rounding = 0;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        fullscreen_opacity = 1.0;

        blur = {
          enabled = false;
          size = 3;
          passes = 1;
          ignore_opacity = false;
          new_optimizations = true;
        };

        shadow = {
          enabled = false;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      animations = {
        enabled = true;
        animation = [
          "windows,1,7,default"
          "windowsIn,1,7,default,popin 80%"
          "windowsOut,1,7,default,popin 80%"
          "windowsMove,1,7,default"
          "fade,1,7,default"
          "layers,1,7,default"
          "layersIn,1,8,default,popin 80%"
          "layersOut,1,8,default,popin 80%"
          "fadeIn,1,7,default"
          "fadeOut,1,7,default"
          "workspaces,1,6,default"
        ];
      };

      input = {
        kb_layout = "us";
        kb_variant = "";
        follow_mouse = 1;
        mouse_refocus = true;
        sensitivity = 0.0;
        accel_profile = "flat";
      };

      dwindle = {
        force_split = 2;
        preserve_split = true;
        smart_split = false;
        smart_resizing = false;
        split_bias = 1;
      };

      master = {
        new_status = "slave";
        mfact = 0.55;
        orientation = "left";
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = false;
      };

      # Keybindings
      bind = [
        "SUPER, Left, movefocus, l"
        "SUPER, Right, movefocus, r"
        "SUPER, Up, movefocus, u"
        "SUPER, Down, movefocus, d"

        "SUPER SHIFT, Left, movewindow, l"
        "SUPER SHIFT, Right, movewindow, r"
        "SUPER SHIFT, Up, movewindow, u"
        "SUPER SHIFT, Down, movewindow, d"

        "SUPER CTRL, Left, resizeactive, -50 0"
        "SUPER CTRL, Right, resizeactive, 50 0"
        "SUPER CTRL, Up, resizeactive, 0 -50"
        "SUPER CTRL, Down, resizeactive, 0 50"

        "SUPER, Q, killactive,"
        "ALT, F4, killactive,"
        "SUPER SHIFT, F, fullscreen, 0"
        "SUPER, F, togglefloating,"
        "SUPER, T, layoutmsg, togglesplit"
        "SUPER, L, exec, hyprlock"

        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7"
        "SUPER, 8, workspace, 8"
        "SUPER, 9, workspace, 9"

        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER SHIFT, 6, movetoworkspace, 6"
        "SUPER SHIFT, 7, movetoworkspace, 7"
        "SUPER SHIFT, 8, movetoworkspace, 8"
        "SUPER SHIFT, 9, movetoworkspace, 9"

        "SUPER, S, togglespecialworkspace, magic"
        "SUPER SHIFT, S, movetoworkspace, special:magic"

        "CTRL ALT, T, exec, kitty"
        "SUPER, E, exec, dolphin"
        "SUPER, R, exec, fuzzel"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      windowrule = [
        "match:class ^(notification)$, match:title ^(Notification)$, no_focus true"
        "match:class ^(org.pulseaudio.pavucontrol)$, float true, center true, size 800 600"
        "match:class ^(nm-connection-editor)$, center true"
        "match:class ^(blueman-manager)$, float true, size 900 700"
        "match:class ^(nm-applet)$, float true"
        "match:class ^(file-roller)$, float true"
        "opacity 0.95 0.95, match:class ^(kitty)$"
        "opacity 0.95 0.95, match:class ^(code)$"
      ];

      exec-once = [
        "uwsm finalize WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE"
        "uwsm app -- ${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init"
        "uwsm app -- udiskie"
      ];
    };
  };

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      targets = [ "graphical-session.target" ];
    };
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "tray"
          "memory"
          "pulseaudio"
        ]
        ++ lib.optionals isWorkLaptop [ "network" ];

        "hyprland/workspaces" = {
          all-outputs = true;
        };

        clock = {
          format = "{:%Y-%m-%d %H:%M}";
        };

        "tray" = {
          icon-size = 16;
          spacing = 10;
        };

        memory = {
          interval = 1;
          format = "{used} / {total} ({percent}%)";
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "muted ";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pavucontrol";
        };

        network = {
          interval = 5;
          format-wifi = "{signalStrength}% {essid}";
          format-ethernet = "wired {ipaddr}";
          format-disconnected = "no wifi";
          tooltip-format = "{ifname} {ipaddr}/{cidr}";
        };
      };
    };

    style = ''
      * {
        font-family: JetBrains Mono;
        font-size: 14px;
      }

      window#waybar {
        background: #1e1e2e;
        color: #cdd6f4;
      }

      #workspaces button {
        padding: 0 8px;
        color: #cdd6f4;
      }

      #workspaces button.active {
        color: #cba6f7;
        border-bottom: 2px solid #cba6f7;
      }

      #clock {
        padding: 0 10px;
        color: #cdd6f4;
        font-weight: bold;
      }

      #memory, #pulseaudio, #tray {
        padding: 0 10px;
        margin: 0 4px;
        background-color: #383c4a;
        border-radius: 4px;
      }
    '';
  };

  # Install additional hyprland-related tools
  home.packages = with pkgs-unstable; [
    pavucontrol # GUI for audio inputs/outputs dropdown
    lxqt.lxqt-policykit # Required for mounting disks without root privileges
    hyprlock
    hypridle
    kitty
    fuzzel
    udiskie
  ];
}
