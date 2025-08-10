# SSH Pre-Auth Banner Installer
This repo provides small, idempotent Bash scripts that enable an OpenSSH **pre-auth warning banner** on Ubuntu with RHEL-family systems (CentOS, AlmaLinux, Rocky) down the line.

The default banner is inspired by *Shimoneta: A Boring World Where the Concept of Dirty Jokes Doesn't Exist*—a satire about overreaching censorship of “lewd” or “inappropriate” speech, art, and culture.

Use this to display a clear **pre-login** warning and free-expression notice to anyone connecting to your server. It appears before any password/key prompt and lets you tell unwanted visitors to disconnect. Unauthorized access is prohibited and monitored.

Default banner text:
```
This service supports free expression and rejects 
censorship campaigns against art, NSFW content, or satire.
If you advocate speech bans or “morality” filters, disconnect.
Unauthorized access is prohibited and monitored. - S0X
```

## Ubuntu quick test
```bash
chmod +x install-ubuntu.sh
sudo ./install-ubuntu.sh
```
