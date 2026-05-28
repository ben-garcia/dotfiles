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
  1. Download the script
```console
curl -LO https://raw.githubusercontent.com/ben-garcia/dotfiles/refs/heads/master/arch_setup.sh
curl -LO https://raw.githubusercontent.com/ben-garcia/dotfiles/refs/heads/master/fedora_setup.sh
curl -LO https://raw.githubusercontent.com/ben-garcia/dotfiles/refs/heads/master/mint_setup.sh
```

  2. Make changes

  3. Make it executable
```console
chmod +x arch_setup.sh
chmod +x fedora_setup.sh
chmod +x mint_setup.sh
```

  4. Run it
```console
./arch_setup.sh "your-email@example.com"
./fedora_setup.sh "your-email@example.com"
./mint_setup.sh "your-email@example.com"
```
