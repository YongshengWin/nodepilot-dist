# NodePilot Generic Distribution

This archive contains the generic NodePilot runtime for Linux amd64/arm64. It
contains no operator inventory, managed domain, DNS claim, public address,
credential, enrollment token, certificate, private key, database, or
operator-specific documentation.

The same published installer handles both roles:

```sh
# Control VPS
bash <(curl -fsSL https://raw.githubusercontent.com/YongshengWin/nodepilot-dist/main/install.sh) server

# Node VPS; paste the one-time pairing code into the hidden prompt
bash <(curl -fsSL https://raw.githubusercontent.com/YongshengWin/nodepilot-dist/main/install.sh) node
```

The same commands are also the upgrade commands. Existing control installs keep
their database, account, signing key, and certificates. Existing registered
Agents keep their identity, policy, certificates, usage, and cached signed
state. Set `NODEPILOT_VERSION=v1.0.1` to pin a release; otherwise the installer
uses the latest published release.

Before control installation, DNS-only A/AAAA records for the Agent API and
subscription hostname must point to the control VPS. Public TCP port 80 must be
available for HTTP-01 certificate issuance.

After control installation:

```sh
# Create the node DNS-only record manually first.
sudo nodepilot add NAME node.example.com
sudo nodepilot subscribe DEVICE -output /root/nodepilot-subscription.json
sudo nodepilot remove NAME
```

Control setup creates protected configuration, a root-only operator key, a
private Agent TLS CA, and a public HTTPS subscription certificate. Node setup
consumes a hidden, server-scoped, single-use pairing code and deletes it after
registration. It installs sing-box, Snell, acme.sh, typed systemd services, and
local nftables quota enforcement.

Control installation does not create or print a subscription token. The
explicit subscription command above creates a new mode-`0600` file and writes
the one-time token only there.

Online nodes join existing subscriptions only after acknowledging the exact
signed revision they applied. Retired nodes leave subscriptions immediately;
cleanup reaches the VPS only when its outbound Agent pulls and verifies the
signed empty state.

Each token exposes full Surge and FlClash/Mihomo configurations plus explicit
`surge-nodes` and `flclash-nodes` provider outputs. Full configurations contain
stable protocol and region policy groups.

Cloudflare records remain manual and DNS-only. No Cloudflare token is required,
and NodePilot never creates, updates, proxies, renames, or deletes those
records. AnyTLS certificates use HTTP-01 by default.

Public artifacts use the `nodepilot_public` build profile. Every release archive
is checked against `SHA256SUMS` by the installer and scanned before publication
for secret paths, private-key markers, home paths, non-reserved IP literals, and
operator-identifying metadata.
