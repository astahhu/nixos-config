{ pkgs, lib, config, ... }: {
  options.nix-tun.alloy = {
    enable = lib.mkEnableOption "Whether to enable alloy, metrics and log collector";
    loki-host = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
    };
    prometheus-host = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
    };
  };

  config = lib.mkIf config.nix-tun.alloy.enable {
    sops.secrets.loki-host-pw = { mode = "777"; };
    sops.secrets.prometheus-host-pw = { mode = "777"; };

    systemd.services.alloy.serviceConfig = {
      ReadPaths = [
        config.sops.secrets.loki-host-pw.path
        config.sops.secrets.prometheus-host-pw.path
      ];
    };


    services.alloy.enable = true;
    environment.etc = lib.mkMerge [
      (lib.attrsets.mapAttrs'
        (name: value: {
          name = "alloy/container-${name}-journal.alloy";
          value.text = ''
            loki.source.journal "logs_integrations_container_${lib.strings.replaceStrings ["-"] ["_"] name}_journal_scrape" {
              path = "${config.nix-tun.storage.persist.path}/containers/${name}/log"
              max_age       = "24h0m0s"
              relabel_rules = discovery.relabel.logs_integrations_integrations_node_exporter_journal_scrape.rules
              forward_to    = [loki.write.default.receiver]            }
          '';
        })
        config.nix-tun.utils.containers)
      {
        "alloy/loki-writer.alloy".text = lib.mkIf (config.nix-tun.alloy.loki-host != null) ''
          loki.write "default" {
            endpoint {
              url = "https://${config.nix-tun.alloy.loki-host}/loki/api/v1/push"

              tenant_id = 1
 
              basic_auth {
                password_file = "${config.sops.secrets.loki-host-pw.path}"
                username = "loki"
              }
            }
          }
        '';

        "alloy/loki-journal.alloy".text = lib.mkIf (config.nix-tun.alloy.loki-host != null) ''
          discovery.relabel "logs_integrations_integrations_node_exporter_journal_scrape" {
            targets = []

            rule {
              source_labels = ["__journal__systemd_unit"]
              target_label  = "unit"
            }

            rule {
              source_labels = ["__journal__boot_id"]
              target_label  = "boot_id"
            }

            rule {
              source_labels = ["__journal__transport"]
              target_label  = "transport"
            }

            rule {
              source_labels = ["__journal__hostname"]
              target_label = "host"
            }

            rule {
              source_labels = ["__journal_priority_keyword"]
              target_label  = "level"
            }
          }

          loki.source.journal "logs_integrations_integrations_node_exporter_journal_scrape" {
             max_age       = "24h0m0s"
             relabel_rules = discovery.relabel.logs_integrations_integrations_node_exporter_journal_scrape.rules
             forward_to    = [loki.write.default.receiver]
           }
        '';

        "alloy/prometheus-writer.alloy".text = lib.mkIf (config.nix-tun.alloy.prometheus-host != null) ''
          prometheus.remote_write "default" {
            endpoint {
              url = "https://${config.nix-tun.alloy.prometheus-host}/api/v1/write"

              basic_auth {
                password_file = "${config.sops.secrets.prometheus-host-pw.path}"
                username = "prometheus"
              }
            }
          }
        '';

        "alloy/prometheus-node-exporter.alloy".text = lib.mkIf (config.nix-tun.alloy.prometheus-host != null) ''
          discovery.relabel "integrations_node_exporter" {
            targets = prometheus.exporter.unix.integrations_node_exporter.targets

            rule {
              target_label = "instance"
              replacement  = constants.hostname
            }

            rule {
              target_label = "job"
              replacement = "node_exporter"
            }
          }

          prometheus.scrape "integrations_node_exporter" {
            scrape_interval = "15s"
            targets    = discovery.relabel.integrations_node_exporter.output
            forward_to = [prometheus.remote_write.default.receiver]
          }

          prometheus.exporter.unix "integrations_node_exporter" {
            disable_collectors = ["ipvs", "infiniband", "xfs", "zfs"]
            enable_collectors = ["meminfo", "systemd"]

            filesystem {
              fs_types_exclude     = "^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|tmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$"
              mount_points_exclude = "^/(dev|proc|run/.+|var/lib/.+|/var/log|run/credentials/.+|sys|var/lib/docker/.+)($|/)"
              mount_timeout        = "5s"
            }

            systemd {
              enable_restarts = true
            }

            netclass {
              ignored_devices = "^(veth.*|cali.*|[a-f0-9]{15})$"
            }

            netdev {
              device_exclude = "^(veth.*|cali.*|[a-f0-9]{15})$"
            }
          }
        '';
      }
    ];
  };

}
