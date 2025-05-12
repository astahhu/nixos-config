# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ config
, lib
, pkgs
, inputs
, ...
}: {

  imports = [
    ./windmill.nix
  ];
  astahhu.common = {
    is_server = true;
    is_qemuvm = true;
    disko = {
      enable = true;
      device = "/dev/sda";
    };
  };

  environment.systemPackages = with pkgs; [
    bun
    rustc
    cargo
  ];

  systemd.network = {
    enable = true;
    networks."astahhu" = {
      name = "ens18";
      gateway = [
        "134.99.154.1"
      ];
      dns = [
        "134.99.154.200"
        "134.99.154.201"
      ];
      address = [
        "134.99.154.202/24"
      ];
      ntp = [
        "134.99.154.200"
        "134.99.154.201"
      ];
      domains = [
        "ad.astahhu.de"
        "asta2012.local"
      ];
    };
  };

  networking = {
    hostName = "nix-nextcloud"; # Define your hostname.
    domain = "ad.astahhu.de";
    useDHCP = false;
  };

  sops.defaultSopsFile = ../../secrets/nix-nextcloud.yaml;
  sops.secrets.proxyCert = {
    sopsFile = ../../secrets/nix-nextcloud_cert.pem;
    format = "binary";
  };

  sops.secrets.dockerproxy_env = { };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers = {
    "collabora" = {
      image = "collabora/code:latest";
      environment = {
        aliasgroup1 = "https://cloud.astahhu.de:443";
        server_name = "collabora.astahhu.de";
        extra_params = "--o:ssl.enable=true --o:remote_font_config.url=https://cloud.astahhu.de/apps/richdocuments/settings/fonts.json";
      };
      extraOptions = [ "--dns=134.99.154.200" "--dns=134.99.154.202" ];
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.collabora.entrypoints" = "websecure";
        "traefik.http.routers.collabora.rule" = "Host(`collabora.astahhu.de`)";
        "traefik.http.routers.collabora.tls" = "true";
        "traefik.http.routers.collabora.tls.certresolver" = "letsencrypt";
        "traefik.http.services.collabora.loadbalancer.server.port" = "9980";
        "traefik.http.services.collabora.loadbalancer.server.scheme" = "https";
        "traefik.http.services.collabora.loadbalancer.serversTransport" = "collabora@file";
      };
    };
  };

  services.traefik.dynamicConfigOptions.http.serversTransports.collabora.insecureSkipVerify = true;
  services.resolved = {
    enable = true;
    fallbackDns = [ ];
  };

  # List services that you want to enable:
  nix-tun.services = {
    traefik = {
      enable_docker = true;
    };
    containers.nextcloud = {
      enable = true;
      hostname = "cloud.astahhu.de";
      extraTrustedProxies = [ "134.99.154.202" ];
    };
  };

  services.traefik.staticConfigOptions.entryPoints.websecure.forwardedHeaders.trustedIPs = [ "192.168.0.0/16" "172.16.0.0/12" "10.0.0.0/8" "127.0.0.1" ];

  containers.nextcloud = {
    bindMounts.docker = {
      hostPath = "/run/docker.sock";
      mountPoint = "/run/docker.sock";
    };
  };

  nix-tun.utils.containers.nextcloud.config = { ... }: {
    environment.systemPackages = [
      pkgs.docker
    ];

    services.nextcloud.settings.default_phone_region = "DE";
    services.nextcloud.maxUploadSize = "3G";

    users.users.nextcloud.extraGroups = [ "docker" ];
  };


  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  networking.firewall.trustedInterfaces = [ "ve-nextcloud" ];


  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  security.pam.sshAgentAuth.enable = true;
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIIDFTCCAf2gAwIBAgIUOHwthMO3Dw04xRtE3/P9tzcGAc4wDQYJKoZIhvcNAQEL
      BQAwGTEXMBUGA1UEAwwOMTkyLjE2OC4xMDAuMTAwIBcNMjQxMDE3MTM1NTU3WhgP
      MzAyNDAyMTgxMzU1NTdaMBkxFzAVBgNVBAMMDjE5Mi4xNjguMTAwLjEwMIIBIjAN
      BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAobtxgNLyzT1KjhVNmAJil0b4AxhV
      xfRO5/QvF+ehykVKdB4C8yNv2PSjYA6JDflmYq0if0DoA0fW4znGem4/2wbRL+B/
      dGiGUTvWnVv6sdPy7kArS8Q+z6b4R56VnDYvqN6N6ADLnCChur0rYu3F0H+vezZx
      JRRg44Lzpw6KesyrE2YSd8vsdNjMJgu+35RZm91pZxrVzeQyHongTdQRtuabUq55
      FyXvflbeAwpRTKAXGMxBXsZ7NgsCVm5EX9O0M0tw2Vy3TVAvh4rFAN89t7kIbsOx
      EAMcMlmTqPr8rvoshh4w0mTP45ON489799/o5vLCLLYHoNkiwZDNbx48twIDAQAB
      o1MwUTAdBgNVHQ4EFgQU4tteG/vGAU1gbQ6s5O31sRKyQzkwHwYDVR0jBBgwFoAU
      4tteG/vGAU1gbQ6s5O31sRKyQzkwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0B
      AQsFAAOCAQEADz1sh6ipSNfbd3rE7hPRG1TN03Atmlq8yJ3uTsAGB7BDmPlad4fq
      Ak+MrHuqDu0+iYEaOk/qcr0kP6ozBoorahA5GXO+qV1I9YlZH5dccC9RnffyksKT
      T2epsJL91b9rh5bhUh4pBnQsRdpX8A7479DHNUP0SNYtrCW/vaeJuVbh9zU/VrLQ
      vZ6Nk04h4X00M10C1v0hCFRJqKPXpUW96SJAmrM7F5TAiMFeO6zeGCoXWpaq7M5X
      HwORa5h8YfdSozsB2XCDVd/0euDa5BOCBM5O431PhwL3peAwEeaGlXEk1XXnLDQ5
      ylufmUaJuk6YltROWkNq/821NljZR5j4Nw==
      -----END CERTIFICATE-----
    ''
    ''
            -----BEGIN CERTIFICATE-----
      MIIEOTCCAyGgAwIBAgIUOHFmcxpzp3l8pf+DtUFNALkgzEcwDQYJKoZIhvcNAQEL
      BQAwgaoxCzAJBgNVBAYTAkRFMRwwGgYDVQQIDBNOb3JkcmhlaW4tV2VzdGZhbGVu
      MRYwFAYDVQQHDA1Ew4PCvHNzZWxkb3JmMRUwEwYDVQQKDAxBU3RBIGRlciBISFUx
      DzANBgNVBAsMBklULVJlZjEfMB0GA1UEAwwWc2FtYmEtZGMuYWQuYXN0YWhodS5k
      ZTEcMBoGCSqGSIb3DQEJARYNYXN0YWl0QGhodS5kZTAgFw0yMzEyMzAwMzQzMTJa
      GA8zMDA0MDMwMjAzNDMxMlowgaoxCzAJBgNVBAYTAkRFMRwwGgYDVQQIDBNOb3Jk
      cmhlaW4tV2VzdGZhbGVuMRYwFAYDVQQHDA1Ew4PCvHNzZWxkb3JmMRUwEwYDVQQK
      DAxBU3RBIGRlciBISFUxDzANBgNVBAsMBklULVJlZjEfMB0GA1UEAwwWc2FtYmEt
      ZGMuYWQuYXN0YWhodS5kZTEcMBoGCSqGSIb3DQEJARYNYXN0YWl0QGhodS5kZTCC
      ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAPNLvpIkY1VkgjxubzSy8f75
      SqG/Ei58X77zhdaONxv2H2OudINXUMIqFGGNcKfkPo+cFZZJZY7Yog4JFaayCNdf
      4QZbPFV8X7af+e651Biuofsc95rR84UwROoJAXjpR0a+F57l+3JytF3mEDFSFmMy
      f+A5Mj2F4hCkXt3pGBsjY6SszYhQYkQTxa7oGobXTPDQcNm2QUHkkTHTj9jOKyAT
      k68sP+gY7fhA0TdTEQl2i3GkXQaNeoDRXOqY1boPUD/aS5Iq1kaCrXM3/pBOyLGh
      jgMS5lu9FvB7VehQ+a2CTT2lsH+tLQ7Tee9xRZKAzRw4jEQKEMQ52HYNyJpXbLkC
      AwEAAaNTMFEwHQYDVR0OBBYEFG6lrXrIeQDLpNtAbaTtQq38lerFMB8GA1UdIwQY
      MBaAFG6lrXrIeQDLpNtAbaTtQq38lerFMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZI
      hvcNAQELBQADggEBAL/IO+ME0v49YWOgbhE4XxmJk8l1kFI9yi7cjChLdAkU9Koa
      AWuBbwMtS1wHq9jIzr5Hbon13AOOglf5TV8wo06kmN2qorkuerGuh5m5sZoP1mWv
      cng/Kl0bRKL/RFZRhqqF3CwXm2k6+zbkeUTUbTHuqkKLgyDesVjaJC0XxyMlxR0N
      25U3rgEKFb2Rc4vYE3Emd6nSsrcCubUoDI/iyYsbTClct0kqsnsNeV3hOlXqCQ6f
      vlfyEtlpOpUU60aOnxUwT4yqchhe6cg53JFPLRAxjDUW7yYJR1WXP+SPB1+wnFg2
      LiJjkm+8DliLET2JyhFqWV0n4ljhkwUNBeCvTGA=
      -----END CERTIFICATE-----
    ''
    ''
      -----BEGIN CERTIFICATE-----
      MIIDFTCCAf2gAwIBAgIUOHwthMO3Dw04xRtE3/P9tzcGAc4wDQYJKoZIhvcNAQEL
      BQAwGTEXMBUGA1UEAwwOMTkyLjE2OC4xMDAuMTAwIBcNMjQxMDE3MTM1NTU3WhgP
      MzAyNDAyMTgxMzU1NTdaMBkxFzAVBgNVBAMMDjE5Mi4xNjguMTAwLjEwMIIBIjAN
      BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAobtxgNLyzT1KjhVNmAJil0b4AxhV
      xfRO5/QvF+ehykVKdB4C8yNv2PSjYA6JDflmYq0if0DoA0fW4znGem4/2wbRL+B/
      dGiGUTvWnVv6sdPy7kArS8Q+z6b4R56VnDYvqN6N6ADLnCChur0rYu3F0H+vezZx
      JRRg44Lzpw6KesyrE2YSd8vsdNjMJgu+35RZm91pZxrVzeQyHongTdQRtuabUq55
      FyXvflbeAwpRTKAXGMxBXsZ7NgsCVm5EX9O0M0tw2Vy3TVAvh4rFAN89t7kIbsOx
      EAMcMlmTqPr8rvoshh4w0mTP45ON489799/o5vLCLLYHoNkiwZDNbx48twIDAQAB
      o1MwUTAdBgNVHQ4EFgQU4tteG/vGAU1gbQ6s5O31sRKyQzkwHwYDVR0jBBgwFoAU
      4tteG/vGAU1gbQ6s5O31sRKyQzkwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0B
      AQsFAAOCAQEADz1sh6ipSNfbd3rE7hPRG1TN03Atmlq8yJ3uTsAGB7BDmPlad4fq
      Ak+MrHuqDu0+iYEaOk/qcr0kP6ozBoorahA5GXO+qV1I9YlZH5dccC9RnffyksKT
      T2epsJL91b9rh5bhUh4pBnQsRdpX8A7479DHNUP0SNYtrCW/vaeJuVbh9zU/VrLQ
      vZ6Nk04h4X00M10C1v0hCFRJqKPXpUW96SJAmrM7F5TAiMFeO6zeGCoXWpaq7M5X
      HwORa5h8YfdSozsB2XCDVd/0euDa5BOCBM5O431PhwL3peAwEeaGlXEk1XXnLDQ5
      ylufmUaJuk6YltROWkNq/821NljZR5j4Nw==
      -----END CERTIFICATE-----
    ''
  ];
}
