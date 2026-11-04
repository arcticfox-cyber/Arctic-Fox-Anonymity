# Contributing to Arctic Fox Anonymity

Thank you for helping improve Arctic Fox Anonymity. Documentation improvements, reproducible bug reports, tests, and focused code changes are welcome.

## Before opening a change

1. Check existing issues and pull requests for duplicate reports.
2. Include your Linux distribution/version, relevant tool versions, steps to reproduce, and sanitized logs.
3. Never publish private IP details, credentials, tokens, or personal data.

## Development environment

Use a disposable Kali Linux or Debian-based virtual machine. This project changes Tor, firewall, DNS, and network-routing configuration; do not experiment on a production machine or a network you do not own or administer.

Clone the repository:

```bash
git clone https://github.com/arcticfox-cyber/Arctic-Fox-Anonymity.git
cd Arctic-Fox-Anonymity
```

Review the install, start, stop, and uninstall scripts before running them. Keep a working recovery path to restore network settings.

## Safety and testing

When testing changes to routing or firewall behavior:

- Use an isolated VM with a snapshot you can restore.
- Record the original network and firewall state before testing.
- Verify that the stop/recovery path restores the expected state.
- Check that DNS, IPv6, and unsupported UDP behavior is documented accurately.
- Do not claim that Tor guarantees anonymity or protects traffic the tool does not route.
- Never test against third-party systems or networks without authorization.

For documentation-only changes, verify command names, paths, and links against the current project files.

## Pull request process

1. Create a focused branch from `main`.
2. Keep each pull request limited to one logical change.
3. Review the diff and run the relevant checks in the isolated environment.
4. Describe the behavior changed, potential network impact, and exact tests performed.
5. Link any related issue.

Please include enough detail for another maintainer to reproduce your result without exposing sensitive information.

## Reporting security issues

Do not post credentials, private network data, or an unpatched exploit in a public issue. Use GitHub's private vulnerability reporting feature if enabled; otherwise contact the maintainer privately.

Thank you for contributing safely and responsibly.
