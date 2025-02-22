# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ghaf.services.audio;
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
in
{
  options.ghaf.services.audio = {
    enable = mkEnableOption "Enable audio service for audio VM";
    pulseaudioTcpPort = mkOption {
      type = types.int;
      default = 4713;
      description = "TCP port used by Pipewire-pulseaudio service";
    };
    pulseaudioTcpControlPort = mkOption {
      type = types.int;
      default = 4714;
      description = "TCP port used by Pipewire-pulseaudio control";
    };
  };

  config = mkIf cfg.enable {
    # Enable pipewire service for audioVM with pulseaudio support
    security.rtkit.enable = true;
    hardware.firmware = [ pkgs.sof-firmware ];
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = config.ghaf.development.debug.tools.enable;
      systemWide = true;
      extraConfig = {
        pipewire."10-remote-pulseaudio" = {
          "context.modules" = [
            {
              name = "libpipewire-module-protocol-pulse";
              args = {
                # Enable TCP socket for VMs pulseaudio clients
                "server.address" = [
                  {
                    address = "tcp:0.0.0.0:${toString cfg.pulseaudioTcpPort}";
                    "client.access" = "restricted";
                  }
                ];
                "pulse.min.req" = "1024/48000";
                "pulse.min.quantum" = "1024/48000";
                "pulse.idle.timeout" = "3";
              };
            }
            {
              name = "libpipewire-module-protocol-pulse";
              args = {
                # Enable TCP socket for VMs pulseaudio clients
                "server.address" = [
                  {
                    address = "tcp:0.0.0.0:${toString cfg.pulseaudioTcpControlPort}";
                    "client.access" = "unrestricted";
                  }
                ];
              };
            }
          ];
        };
      };
      # Disable the auto-switching to the low-quality HSP profile
      wireplumber.extraConfig.disable-autoswitch = {
        "wireplumber.settings" = {
          "bluetooth.autoswitch-to-headset-profile" = "false";
        };
      };
    };

    # Allow ghaf user to access pulseaudio and pipewire
    users.extraUsers.ghaf.extraGroups = [
      "audio"
      "video"
      "pipewire"
    ];

    # Start pipewire on system boot
    systemd.services.pipewire.wantedBy = [ "multi-user.target" ];

    systemd.services."pulseaudio-set-profile" =
      let
        pulse-set-profile = pkgs.writeShellScriptBin "pulseaudio-set-profile" ''
          ${pkgs.pulseaudio}/bin/pactl set-card-profile "alsa_card.pci-0000_00_07.0-platform-skl_hda_dsp_generic" "HiFi (Headphones, Mic1, Mic2)"
          ${pkgs.pulseaudio}/bin/pactl set-card-profile "alsa_card.pci-0000_00_07.0-platform-skl_hda_dsp_generic" "HiFi (Mic1, Mic2, Speaker)"
        '';
      in
      {
        enable = true;
        description = "Force selection of Pulseaudio integrated mic profile";
        path = [ pulse-set-profile ];
        wantedBy = [ "multi-user.target" ];
        after = [ "pipewire.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          StandardOutput = "journal";
          StandardError = "journal";
          Environment = "PULSE_SERVER=tcp:localhost:${toString cfg.pulseaudioTcpControlPort}";
          ExecStart = "${pulse-set-profile}/bin/pulseaudio-set-profile";
          Restart = "on-failure";
          RestartSec = "1";
        };
      };

    # Open TCP port for the pipewire pulseaudio socket
    networking.firewall.allowedTCPPorts = [
      cfg.pulseaudioTcpPort
      cfg.pulseaudioTcpControlPort
    ];
  };
}
