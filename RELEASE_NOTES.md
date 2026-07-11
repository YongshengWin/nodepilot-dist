Generic privacy-audited Linux release for amd64 and arm64.

- Numbered menu pages now render readable summaries and tables instead of raw JSON
- Overview, servers, nodes, Agents, usage, tasks, audit, and account views are
  formatted for terminal operation
- `sudo nodepilot` now opens a numbered x-ui-style terminal management menu
- Subscription management can be driven from the menu or with numbered shortcuts:
  `sudo nodepilot sub`, `sub new DEVICE`, `sub link 1`, `sub show 1`, `sub rm 1`
- Saved subscription URL files are kept under `/root/.nodepilot/subscriptions/`
  with mode `0600`
- One-line server and node installers
- In-place, rollback-capable upgrades using the same one-line commands
- Agent upgrades preserve the service user's required data-directory traversal permissions
- Runtime, proxy-config, and certificate directories are normalized to mode `0750` despite a restrictive process umask
- The sing-box sandbox permits route-update subscriptions through `AF_NETLINK` without granting `CAP_NET_ADMIN`
- The official Snell v5 binary receives its required executable-memory compatibility exception while retaining the remaining non-root systemd sandbox
- Certificate permission recovery when the first service reload occurs before its unit exists
- Secure mode-`0600` subscription-secret output; first install no longer creates or prints a token
- CLI-only management over a protected Unix socket
- Signed desired state and outbound Agent registration
- HTTPS subscriptions and local quota enforcement

No operator inventory, addresses, credentials, tokens, certificates, private keys, or databases are included.
