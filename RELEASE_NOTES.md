Generic privacy-audited Linux release for amd64 and arm64.

- One-line server and node installers
- In-place, rollback-capable upgrades using the same one-line commands
- Agent upgrades preserve the service user's required data-directory traversal permissions
- Runtime, proxy-config, and certificate directories are normalized to mode `0750` despite a restrictive process umask
- Certificate permission recovery when the first service reload occurs before its unit exists
- Secure mode-`0600` subscription-secret output; first install no longer creates or prints a token
- CLI-only management over a protected Unix socket
- Signed desired state and outbound Agent registration
- HTTPS subscriptions and local quota enforcement

No operator inventory, addresses, credentials, tokens, certificates, private keys, or databases are included.
