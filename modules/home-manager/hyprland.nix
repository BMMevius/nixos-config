{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:
{
  home.sessionVariables.NIXOS_OZONE_WL = "1";
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    xwayland.enable = true;

    # Main hyprland configuration
    settings = {
      monitor = [
        "DP-1, preferred, 0x0, 1"
        "HDMI-A-1, preferred, 1920x0, 1"
      ];

      general = {
        border_size = 2;
        gaps_in = 2;
        gaps_out = 0;
        float_gaps = 0;
        gaps_workspaces = 0;
        "col.active_border" = "rgba(33ccffff)";
        "col.inactive_border" = "rgba(595959ff)";
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
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 0.9;
        fullscreen_opacity = 1.0;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          ignore_opacity = false;
          new_optimizations = true;
        };

        shadow = {
          enabled = true;
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
        pseudotile = false;
        preserve_split = true;
        smart_split = false;
        smart_resizing = true;
      };

      master = {
        new_status = "slave";
        mfact = 0.55;
        orientation = "left";
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = false;
        vfr = true;
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

        "SUPER SHIFT, Q, killactive,"
        "SUPER SHIFT, F, fullscreen, 0"
        "SUPER, F, togglefloating,"
        "SUPER CTRL, F, fullscreenstate, 0"

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

        "SUPER CTRL, S, layoutmsg, cyclenext"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      windowrulev2 = [
        "nofocus, class:^(notification)$,title:^(Notification)$"
        "float, class:^(pavucontrol)$"
        "center, class:^(pavucontrol)$"
        "center, class:^(nm-connection-editor)$"
        "float, class:^(blueman-manager)$"
        "float, class:^(nm-applet)$"
        "float, class:^(file-roller)$"
        "size 800 600, class:^(pavucontrol)$"
        "size 900 700, class:^(blueman-manager)$"
        "idleinhibit fullscreen, class:^(mpv)$"
        "idleinhibit fullscreen, class:^(firefox)$"
        "opacity 0.95 0.95, class:^(kitty)$"
        "opacity 0.95 0.95, class:^(code)$"
      ];

      exec-once = [
        "waybar"
      ];
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = ["hyprland/workspaces" "hyprland/window"];
        modules-center = ["clock"];
        modules-right = ["pulseaudio" "network" "battery" "tray"];

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
        };

        clock = {
          format = "{:%H:%M}";
          tooltip-format = "{:%Y-%m-%d}";
        };

        battery = {
          format = "{capacity}% {icon}";
          format-icons = ["" "" "" "" ""];
        };

        network = {
          format-wifi = "{essid} ";
          format-ethernet = "{ifname} ";
          format-disconnected = "⚠";
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "muted ";
        };
      };
    };

    style = ''
      * {
        font-family: JetBrains Mono;
        font-size: 13px;
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
      }
    '';
  };

  # Install additional hyprland-related tools
  home.packages = with pkgs-unstable; [
    hyprpicker
    hyprcursor
    hyprlock
    hypridle
    kitty
    fuzzel
  ];
}
