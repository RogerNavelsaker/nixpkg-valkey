# Valkey OCI image

Reproducible, Nix-built Valkey image for x86_64 Linux. It uses the Nixpkgs Valkey package and `dockerTools`; it does not wrap an upstream OCI image.

## Build and load

```sh
nix flake check
nix build .#image
podman load -i result
```

The flake lock pins the Nixpkgs revision; the package version is Valkey 9.1.2.

## Runtime contract

- Numeric user: `10001:10001` (non-root).
- Entrypoint: Nixpkgs `valkey-server`.
- Port metadata: TCP 6379; default server binding/security configuration is retained.
- Writable path: `/data`, owned by UID/GID 10001. The default command disables RDB snapshots and AOF; `/data` remains available for caller-provided persistence options.
- No shell or package manager is added to the image.
- The image does not configure a password or publish a host port. Keep it on a private container network and supply deployment-specific bind/auth options when needed.

## Smoke-test constraints

Use a disposable rootless Podman container and storage. The package has been smoke-tested with a read-only root filesystem, all capabilities dropped, no-new-privileges, and no network; `valkey-cli ping` returned PONG. Do not attach production networks or data.
