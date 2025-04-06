# Prometheus Node Exporter
[Node Exporter](https://github.com/prometheus/node_exporter) is a hardware and OS metrics exporter for Prometheus. We use it to be alerted, when for example the storage or ram for a vm is full. Or to know if systemd-units failed.

## Why a Container?
The Node Exporter runs in a nixos-container with the host filesystem mounted at "/host". Because Node Exporter itslef has no authentication mechanism for its endpoint. Which is why we put it behind a reverse proxy with authentication for additional security. Hence the container.
