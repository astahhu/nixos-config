{
  pkgs,
  lib,
  config,
  ...
}:

{

  ########################################
  # Secrets
  ########################################

  sops.secrets.windmill_env = {
    sopsFile = ../../secrets/nix-nextcloud_windmill_pg_env;
    format = "binary";
  };

  ########################################
  # ZFS Persistence (REPLACES subvolumes)
  ########################################

  nix-tun.storage.persist.datasets = {
    windmill = {
      backup = true;
      path = "${config.nix-tun.storage.persist.path}/windmill";

      directories = {
        db_data = { };
        lsp_cache = { };
        worker_logs = { };
        worker_dependency_cache = { };
      };
    };
  };

  ########################################
  # Docker Runtime
  ########################################

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  virtualisation.oci-containers.backend = "docker";

  ########################################
  # Containers
  ########################################

  virtualisation.oci-containers.containers."windmill-db" = {
    image = "postgres:16";

    environment = {
      POSTGRES_DB = "windmill";
    };

    environmentFiles = [
      config.sops.secrets.windmill_env.path
    ];

    volumes = [
      "${config.nix-tun.storage.persist.path}/windmill/db_data:/var/lib/postgresql/data:rw"
    ];

    log-driver = "journald";

    extraOptions = [
      "--health-cmd=pg_isready -U postgres"
      "--health-interval=10s"
      "--health-retries=5"
      "--health-timeout=5s"
      "--network-alias=db"
      "--network=windmill_default"
      "--shm-size=1073741824"
    ];
  };

  virtualisation.oci-containers.containers."windmill-lsp" = {
    image = "ghcr.io/windmill-labs/windmill-lsp:latest";

    volumes = [
      "${config.nix-tun.storage.persist.path}/windmill/lsp_cache:/root/.cache:rw"
    ];

    log-driver = "journald";

    extraOptions = [
      "--network-alias=lsp"
      "--network=windmill_default"
    ];
  };

  virtualisation.oci-containers.containers."windmill-windmill_server" = {
    image = "ghcr.io/windmill-labs/windmill:main";

    environment = {
      MODE = "server";
    };

    environmentFiles = [
      config.sops.secrets.windmill_env.path
    ];

    volumes = [
      "windmill_worker_logs:/tmp/windmill/logs:rw"
    ];

    dependsOn = [ "windmill-db" ];

    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.windmill.entrypoints" = "websecure";
      "traefik.http.routers.windmill.rule" = "Host(`windmill.astahhu.de`)";
      "traefik.http.services.windmill.loadbalancer.server.port" = "8000";
      "traefik.http.routers.windmill.tls" = "true";
      "traefik.http.routers.windmill.tls.certresolver" = "letsencrypt";
    };

    log-driver = "journald";

    extraOptions = [
      "--network-alias=windmill_server"
      "--network=windmill_default"
    ];
  };

  ########################################
  # Workers (unchanged logic)
  ########################################

  virtualisation.oci-containers.containers."windmill-windmill_worker" = {
    image = "ghcr.io/windmill-labs/windmill:main";

    environment = {
      MODE = "worker";
      WORKER_GROUP = "default";
    };

    environmentFiles = [
      config.sops.secrets.windmill_env.path
    ];

    volumes = [
      "/run/docker.sock:/var/run/docker.sock:rw"
      "${config.nix-tun.storage.persist.path}/windmill/worker_dependency_cache:/tmp/windmill/cache:rw"
      "${config.nix-tun.storage.persist.path}/windmill/worker_logs:/tmp/windmill/logs:rw"
    ];

    dependsOn = [ "windmill-db" ];

    log-driver = "journald";

    extraOptions = [
      "--cpus=1"
      "--memory=2147483648b"
      "--network-alias=windmill_worker"
      "--network=windmill_default"
    ];
  };

  ########################################
  # Docker Network
  ########################################

  systemd.services."docker-network-windmill_default" = {
    path = [ pkgs.docker ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f windmill_default";
    };

    script = ''
      docker network inspect windmill_default || \
      docker network create windmill_default
    '';

    wantedBy = [ "multi-user.target" ];
  };

}
