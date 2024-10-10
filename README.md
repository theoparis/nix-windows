# nix-windows

## Building Systems

```shell
git clone https://github.com/theoparis/nix-windows
cd nix-windows
cargo run -- --flake .#nixosConfigurations.qemu --root .
```
