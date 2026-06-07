# Dotfiles

After a fresh installation run:

## Arch or Fedora

Both Wayland(Sway) and X11(i3) are supported

```console
bash <(curl -sL https://raw.githubusercontent.com/ben-garcia/dotfiles/refs/heads/master/bootstrap.sh) "your-github-email@example.com"
```

## Mint

Only X11(i3)

Building `alacritty`, `i3`, `neovim`, and `btop` from source to get the latest versions.

```console
curl -o- https://raw.githubusercontent.com/ben-garcia/dotfiles/refs/heads/master/bootstrap_mint.sh | bash -s -- "your-email@example.com"
```

## Modify the script
*NOTE: replace `<script_name>` with the either `arch_setup`, `fedora_setup`, or `mint_setup`*

  1. Download the script
```console
curl -LO https://raw.githubusercontent.com/ben-garcia/dotfiles/refs/heads/master/<script_name>.sh
```

  2. Make changes

  3. Make it executable
```console
chmod +x <script_name>.sh
```

  4. Run it
```console
./<script_name>.sh "your-email@example.com"
```
