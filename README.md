# Dotfiles

After a fresh installation run:

## Arch Linux(Sway/i3 spin)

```console
bash <(curl -sL https://raw.githubusercontent.com/ben-garcia/dotfiles/refs/heads/master/arch_setup.sh) "your-email@example.com"
```

## Fedora Linux(i3 spin)

```console
curl -o- https://raw.githubusercontent.com/ben-garcia/dotfiles/refs/heads/master/fedora_setup.sh | bash -s -- "your-email@example.com"
```

## Linux Mint

Building `alacritty`, `i3`, `neovim`, and `btop` from source to get the latest versions.

```console
curl -o- https://raw.githubusercontent.com/ben-garcia/dotfiles/refs/heads/master/mint_setup.sh | bash -s -- "your-email@example.com"
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
