# How Nix got onto this machine

Reconstructed on 2026-07-14 from on-disk evidence and `~/.zsh_history`, for an
aarch64-darwin host.

**Summary:** the official upstream Nix installer in multi-user mode on **9 May 2026**,
with **nix-darwin** layered on about an hour later. Not Determinate Systems, not Homebrew.

Throughout, `<hostname>` stands for the machine's `scutil --get LocalHostName`, and
`<you>` for the local username.

---

## 1. The install command

Verbatim from `~/.zsh_history` line 654:

```sh
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

This is exactly the command published on nixos.org, which is what rules out the
Determinate Systems installer.

Note there is **no `--daemon` flag**. It was still a multi-user install because the
upstream installer *defaults* to multi-user on macOS — `--daemon` only changes the
default on Linux. Evidence of the install being multi-user regardless:

- 32 `_nixbld1`..`_nixbld32` build users
- `org.nixos.nix-daemon.plist` in `/Library/LaunchDaemons/`
- `build-users-group = nixbld` in `/etc/nix/nix.conf`

## 2. Why it's upstream and not Determinate

The strongest signal is what's absent:

| Determinate artifact | Present? |
|---|---|
| `/nix/receipt.json` | No |
| `/usr/local/bin/determinate-nixd` | No |
| Determinate.app | No |

The receipt is how Determinate's uninstaller works, so it is always written. Its
absence is conclusive.

Corroborating upstream artifacts:

- `/etc/bashrc.backup-before-nix`, `/etc/zshrc.backup-before-nix` — the `.backup-before-nix`
  suffix is upstream's naming convention. Both stamped `9 May 17:31`.
- `/etc/synthetic.conf` contains a `nix` entry, creating the empty `/nix` mount point
  (needed since macOS made the root filesystem read-only in Catalina).
- `org.nixos.darwin-store.plist` mounts a dedicated APFS volume at `/nix` on every boot.
  This is upstream's `create-darwin-volume.sh` behaviour.

## 3. Timeline

| When | What | Source |
|---|---|---|
| 9 May 17:31 | Nix installer ran | `*.backup-before-nix` mtimes |
| 9 May 18:39 | `/etc/nix-darwin/flake.nix` written | mtime of `flake.nix.bak` |
| 9 May 18:47 | First `darwin-rebuild switch` | `system-1-link` |
| 12 Jul 12:57 | Current generation | `system-36-link` |

## 4. The full command sequence

From `~/.zsh_history`, lines 653–715:

```sh
653  go version
654  sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)   # install
656  nix-shell -p neofetch --run neofetch                                     # first use
657  nix-shell -p fastfetch --run fastfetch
667  more nix.conf
670  sudo mkdir -p /etc/nix-darwin
673  sudo chown $(id -nu):$(id -ng) /etc/nix-darwin
675  nix flake init -t nix-darwin/master                                      # failed: flakes off
676  nix flake init -t nix-darwin/master --extra-experimental-features "nix-command flakes"
680  sed -i '' "s/simple/$(scutil --get LocalHostName)/" flake.nix            # -> <hostname>
689  sudo nix run nix-darwin/master#darwin-rebuild \
       --extra-experimental-features "nix-command flakes" \
       -- switch --flake /etc/nix-darwin#<hostname>                           # failed
691  sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin \
       && sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin                     # the fix
692  sudo nix run nix-darwin/master#darwin-rebuild ... switch --flake /etc/nix-darwin#<hostname>
694  sudo darwin-rebuild switch
701  brew uninstall neovim                                                    # Nix takes over nvim
707  mkdir neovim
708  cd neovim
709  nix flake init --experimental-features "nix-command flakes" \
       --template github:nix-community/nixvim                                 # this repo is born
712  nix run
```

Things worth noting:

- **The hostname wasn't hand-typed** — line 680 `sed`s the template's placeholder `simple`
  for `$(scutil --get LocalHostName)`, straight from the nix-darwin docs.
- **Line 689 hit the classic bootstrap failure.** nix-darwin refuses to clobber an existing
  `/etc/bashrc` / `/etc/zshrc`. Line 691 is the documented fix; 692 is the retry that
  produced `system-1-link`. This is why two backup layers exist: `.backup-before-nix`
  (from the Nix installer) and `.before-nix-darwin` (from the `mv`).

## 5. Current state

Config lives at **`/etc/nix-darwin/flake.nix`**, tracking `nixpkgs-unstable` and nix-darwin
`master`. `flake.nix.bak` (9 May 18:39) is the pristine starter template and shows how far
the config has since evolved:

- weekly GC at Sunday 03:00 keeping 14 days of generations
- `nix.optimise.automatic = true`
- this repo pulled in as a flake input

```nix
# must be an absolute path — Nix does not expand $HOME here
nixvim-config.url = "path:/Users/<you>/Projects/neovim";
```

nix-darwin now owns the daemon: `/etc/nix/nix.conf` carries a "generated, do not edit"
header, `org.nixos.nix-daemon.plist` points at a store path, and `/etc/zshrc` and
`/etc/bashrc` are symlinks into `/etc/static/`. That's why `nix --version` resolves through
`/run/current-system/sw/bin/nix` — **Nix 2.34.7 is what nix-darwin currently builds, not
what was installed in May**.

Homebrew is installed at `/opt/homebrew` but is independent — the flake has no `homebrew`
block, so nix-darwin does not manage it.

### Rebuilding

```sh
# after editing /etc/nix-darwin/flake.nix
sudo darwin-rebuild switch --flake /etc/nix-darwin#<hostname>

# after editing THIS repo — re-lock first, or the change won't reach nvim
cd /etc/nix-darwin && sudo nix flake update nixvim-config \
  && sudo darwin-rebuild switch --flake /etc/nix-darwin#<hostname>
```

The `nvim` on PATH comes from the system profile, so it stays pinned to the *locked*
revision of this repo until you re-lock. `nix run .` in this repo only tests the local
build.

---

## Appendix A: grepping `~/.zsh_history`

`~/.zsh_history` is `Non-ISO extended-ASCII text` — a stray high byte makes grep treat the
whole file as binary and silently suppress matches. A plain `grep -i nix ~/.zsh_history`
returns **nothing** even though the matches are right there.

```sh
LC_ALL=C grep -a -i nix ~/.zsh_history     # works
```

Also note the May entries predate `EXTENDED_HISTORY` (enabled ~4 Jul 2026, at line 2319),
so they carry **no timestamps**. History supplies the commands; file mtimes supply the
dates. The two agree.

## Appendix B: open thread

The current `/etc/*.before-nix-darwin` files are pristine Apple copies whose mtimes predate
the Nix install entirely — they are not the Nix-modified ones the 9 May `mv` would have
produced. And that `mv` appears only once in history.

Likely explanation: a macOS update around **27 Jun** restored real `/etc/zshrc` and
`/etc/bashrc`, and nix-darwin's activation automatically moved them aside again and rebuilt
the symlinks, which now carry a `27 Jun 21:00` timestamp. The `.before-nix-darwin` files
would then have been overwritten with Apple's originals, preserving Apple's original mtime.

This is **inference from timestamps, not something history proves.**
