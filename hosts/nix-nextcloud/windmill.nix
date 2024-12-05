# Auto-generated using compose2nix v0.3.2-pre.
{ pkgs, lib, config, ... }:

{

  # volumes
  nix-tun.storage.persist.subvolumes.windmill = {
    directories = {
      db_data = { };
      lsp_cache = { };
      worker_logs = { };
      worker_dependency_cache = { };

    };
  };

  sops.secrets.windmill_env = {
    sopsFile = ../../secrets/nix-nextcloud_windmill_pg_env;
    format = "binary";
  };

  # Containers
  virtualisation.oci-containers.containers."windmill-db" = {
    image = "postgres:16";
    environment = {
      "POSTGRES_DB" = "windmill";
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

  systemd.services."docker-windmill-db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "docker-network-windmill_default.service"
    ];
    requires = [
      "docker-network-windmill_default.service"
    ];
    partOf = [
      "docker-compose-windmill-root.target"
    ];
    wantedBy = [
      "docker-compose-windmill-root.target"
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
  systemd.services."docker-windmill-lsp" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "docker-network-windmill_default.service"
    ];
    requires = [
      "docker-network-windmill_default.service"
    ];
    partOf = [
      "docker-compose-windmill-root.target"
    ];
    wantedBy = [
      "docker-compose-windmill-root.target"
    ];
  };
  virtualisation.oci-containers.containers."windmill-windmill_server" = {
    image = "ghcr.io/windmill-labs/windmill:main";
    environment = {
      "MODE" = "server";
    };
    environmentFiles = [
      config.sops.secrets.windmill_env.path
    ];
    volumes = [
      "windmill_worker_logs:/tmp/windmill/logs:rw"
    ];
    dependsOn = [
      "windmill-db"
    ];
    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.windmill.entrypoints" = "websecure";
      "traefik.http.routers.windmill.rule" = "Host(`windmill.astahhu.de`)";
      "traefik.http.routers.windmill.tls" = "true";
      "traefik.http.services.windmill.loadbalancer.server.port" = "8000";
      "traefik.http.routers.windmill.tls.certresolver" = "letsencrypt";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=windmill_server"
      "--network=windmill_default"
    ];

  };
  systemd.services."docker-windmill-windmill_server" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "docker-network-windmill_default.service"
    ];
    requires = [
      "docker-network-windmill_default.service"
    ];
    partOf = [
      "docker-compose-windmill-root.target"
    ];
    wantedBy = [
      "docker-compose-windmill-root.target"
    ];
  };
  virtualisation.oci-containers.containers."windmill-windmill_worker" = {
    image = "ghcr.io/windmill-labs/windmill:main";
    environment = {
      "MODE" = "worker";
      "WORKER_GROUP" = "default";
    };
    environmentFiles = [
      config.sops.secrets.windmill_env.path
    ];
    volumes = [
      "/run/docker.sock:/var/run/docker.sock:rw"
      "${config.nix-tun.storage.persist.path}/windmill/worker_dependency_cache:/tmp/windmill/cache:rw"
      "${config.nix-tun.storage.persist.path}/windmill/worker_logs:/tmp/windmill/logs:rw"
    ];
    dependsOn = [
      "windmill-db"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cpus=1"
      "--memory=2147483648b"
      "--network-alias=windmill_worker"
      "--network=windmill_default"
    ];
  };
  systemd.services."docker-windmill-windmill_worker" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "docker-network-windmill_default.service"
    ];
    requires = [
      "docker-network-windmill_default.service"
    ];
    partOf = [
      "docker-compose-windmill-root.target"
    ];
    wantedBy = [
      "docker-compose-windmill-root.target"
    ];
  };
  virtualisation.oci-containers.containers."windmill-windmill_worker_native" = {
    image = "ghcr.io/windmill-labs/windmill:main";
    environment = {
      "MODE" = "worker";
      "NUM_WORKERS" = "8";
      "SLEEP_QUEUE" = "200";
      "WORKER_GROUP" = "native";
    };
    environmentFiles = [
      config.sops.secrets.windmill_env.path
    ];
    volumes = [
      "/run/docker.sock:/var/run/docker.sock:rw"
      "${config.nix-tun.storage.persist.path}/windmill/worker_dependency_cache:/tmp/windmill/cache:rw"
      "${config.nix-tun.storage.persist.path}/windmill/worker_logs:/tmp/windmill/logs:rw"
    ];
    dependsOn = [
      "windmill-db"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cpus=1"
      "--memory=2147483648b"
      "--network-alias=windmill_worker_native"
      "--network=windmill_default"
    ];
  };
  systemd.services."docker-windmill-windmill_worker_native" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "docker-network-windmill_default.service"
    ];
    requires = [
      "docker-network-windmill_default.service"
    ];
    partOf = [
      "docker-compose-windmill-root.target"
    ];
    wantedBy = [
      "docker-compose-windmill-root.target"
    ];
  };
  virtualisation.oci-containers.containers."windmill-windmill_worker_reports" = {
    image = "ghcr.io/windmill-labs/windmill:main";
    environment = {
      "MODE" = "worker";
      "WORKER_GROUP" = "reports";
    };
    environmentFiles = [
      config.sops.secrets.windmill_env.path
    ];
    volumes = [
      "/run/docker.sock:/var/run/docker.sock:rw"
      "${config.nix-tun.storage.persist.path}/windmill/worker_dependency_cache:/tmp/windmill/cache:rw"
      "${config.nix-tun.storage.persist.path}/windmill/worker_logs:/tmp/windmill/logs:rw"
    ];
    dependsOn = [
      "windmill-db"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cpus=1"
      "--memory=2147483648b"
      "--network-alias=windmill_worker_reports"
      "--network=windmill_default"
    ];
  };
  systemd.services."docker-windmill-windmill_worker_reports" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "docker-network-windmill_default.service"
    ];
    requires = [
      "docker-network-windmill_default.service"
    ];
    partOf = [
      "docker-compose-windmill-root.target"
    ];
    wantedBy = [
      "docker-compose-windmill-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-windmill_default" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f windmill_default";
    };
    script = ''
      docker network inspect windmill_default || docker network create windmill_default
    '';
    partOf = [ "docker-compose-windmill-root.target" ];
    wantedBy = [ "docker-compose-windmill-root.target" ];
  };


  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-windmill-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
