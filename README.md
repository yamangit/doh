# DoH Anywhere

DoH Anywhere is a local DNS gateway for apps that do not natively support DNS-over-HTTPS. Point any application, container, VM, or OS resolver at this service as a normal DNS server, and it forwards DNS queries to trusted DoH upstreams over HTTPS.

## What It Provides

- UDP and TCP DNS listeners for broad app compatibility.
- RFC 8484 DoH forwarding using `application/dns-message`.
- Multiple upstreams with timeout and failover.
- TTL-aware in-memory response cache with stale-if-error behavior.
- Optional domain allow and deny policy.
- Health and Prometheus-style metrics endpoint.
- Graceful shutdown and structured JSON logs.
- No runtime npm dependencies.

## Quick Start

```powershell
npm test
npm start -- --config .\config\example.json
```

By default the service listens on:

- DNS UDP/TCP: `127.0.0.1:1053`
- Health/metrics: `127.0.0.1:8080`

Use it from an app:

```powershell
nslookup example.com 127.0.0.1 -port=1053
```

For OS-wide usage, run the service with permission to bind port `53`, then set your network DNS server to `127.0.0.1`.

## Configuration

See [config/example.json](config/example.json).

Important fields:

- `listen.host`: Bind address. Use `127.0.0.1` for local-only or `0.0.0.0` for LAN/container exposure.
- `listen.port`: DNS port. Use `1053` for development, `53` for production.
- `upstreams`: DoH endpoints. The service tries them in order.
- `cache.maxEntries`: Maximum cached DNS responses.
- `cache.staleIfErrorSeconds`: How long expired cache entries may be used when upstreams fail.
- `policy.denyDomains`: Block exact domains or suffixes like `.ads.example`.
- `policy.allowDomains`: Optional exact/suffix allow list. Empty means allow all non-denied domains.

## Production Deployment Notes

1. Run as an unprivileged user where possible.
2. Bind only to interfaces that should receive DNS traffic.
3. Put the service behind firewall rules if exposed beyond localhost.
4. Use upstream resolvers you trust and monitor `/healthz` and `/metrics`.
5. Pin Node.js to an LTS version in production.

### Docker

```powershell
docker build -t doh-anywhere .
docker run --rm -p 53:53/udp -p 53:53/tcp -p 8080:8080 -v ${PWD}\config\example.json:/app/config.json:ro doh-anywhere --config /app/config.json
```

### systemd

See [deploy/doh-anywhere.service](deploy/doh-anywhere.service).

## App Integration Patterns

- Desktop app: configure the app's DNS server to `127.0.0.1:1053` if it supports custom DNS.
- Whole machine: run on port `53` and set OS DNS to `127.0.0.1`.
- Docker container: run this gateway on a shared Docker network and set app containers to use it as DNS.
- Kubernetes: run as a DaemonSet or sidecar and point workloads at the service IP.

## Security Model

This tool encrypts DNS traffic between the gateway and the DoH upstream. Apps still send plain DNS to the local gateway, so keep the listener local unless you intentionally operate a network resolver.

## License

MIT
