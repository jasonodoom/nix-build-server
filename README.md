### Installation Procedure


#### UEFI (GPT)
For UEFI, using `/dev/sda` as the device.

> :warning: You can safely ignore parted's informational message about needing to update /etc/fstab.
1. Create a GPT partition table.
```sh
# parted /dev/sda -- mklabel gpt
````
2. Add the root partition. This will fill the disk except for the end part, where the swap will live, and the space left in front (512MiB) which will be used by the boot partition.
```sh
# parted /dev/sda -- mkpart primary 512MiB -8GiB
```
3. Next, add a swap partition. The size required will vary according to needs, here a 8GiB one is created.
```sh
# parted /dev/sda -- mkpart primary linux-swap -8GiB 100%
```
> :warning:  The swap partition size rules are no different than for other Linux distributions.

4. Finally, the boot partition. NixOS by default uses the ESP (EFI system partition) as its `/boot` partition. It uses the initially reserved 512MiB at the start of the disk.
```sh
# parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
# parted /dev/sda -- set 3 esp on
```

#### Formatting
Use the following commands:
- For initialising Ext4 partitions: `mkfs.ext4`. It is recommended that you assign a unique symbolic label to the file system using the option `-L label`, since this makes the file system configuration independent from device changes. For example:
```sh
# mkfs.ext4 -L nixos /dev/sda1
```
- For creating swap partitions: `mkswap`. Again it’s recommended to assign a label to the swap partition: `-L label`. For example:
```sh
# mkswap -L swap /dev/sda2
```
- For creating boot partitions: `mkfs.fat`. Again it’s recommended to assign a label to the boot partition: `-n label`. For example:
```sh
# mkfs.fat -F 32 -n boot /dev/sda3
```
- For creating LVM volumes, the LVM commands, e.g., `pvcreate`, `vgcreate`, and `lvcreate`.
- For creating software RAID devices, use `mdadm`.

> :warning: (LVM Note): you can wipe out the old partition information with `wipefs`:
> ```sh
> # wipefs -a /dev/sdd
> /dev/sdd: 2 bytes were erased at offset 0x000001fe (dos): 55 aa
> /dev/sdd: calling ioclt to re-read partition table: Success 
> ```

> :warning: (LVM Note): you can create a singe logical volume using all spaces available in volume group:
> ```sh
> # lvcreate -n NAME -l 100%FREE vg0
> ```

### Installing
1. Mount the target file system on which NixOS should be installed on `/mnt`, e.g.
```sh
# mount /dev/disk/by-label/nixos /mnt
```
2. Mount the boot file system on /mnt/boot, e.g.
```sh
# mkdir -p /mnt/boot
# mount /dev/disk/by-label/boot /mnt/boot
```
3. If your machine has a limited amount of memory, you may want to activate swap devices now (`swapon device`). The installer (or rather, the build actions that it may spawn) may need quite a bit of RAM, depending on your configuration.
```sh
# swapon /dev/sda2
```
4. You now need to create a file `/mnt/etc/nixos/configuration.nix` that specifies the intended configuration of the system. This is because NixOS has a declarative configuration model: you create or edit a description of the desired configuration of your system, and then NixOS takes care of making it happen. The syntax of the NixOS configuration file is described [here](https://nixos.org/manual/nixos/stable/index.html#sec-configuration-syntax), while a list of available configuration options is [here](https://nixos.org/manual/nixos/stable/options.html). A minimal example is shown [here](https://nixos.org/manual/nixos/stable/index.html#ex-config).

The command `nixos-generate-config` can generate an initial configuration file for you:
```sh
# nixos-generate-config --root /mnt
```
Then remove it as we only want the generated `hardware-configuration.nix` which will be at /mnt/etc/nixos/hardware-configuration.nix

Next, copy our `configuration.nix` to  /mnt/etc/nixos/configuration.nix


Finally, `cd` into `/mnt/etc/nixos` to build our configuration:
```sh
# cd /mnt/etc/nixos
# nixos-install --root /mnt --flake .#moss-nix
```

If you need to make changes post installation configuration.nix and flake.nix are located in `/etc/nixos`:
```sh
ls /etc/nixos/
configuration.nix  flake.lock  flake.nix  hardware-configuration.nix
```

Any changes made will require a rebuild as is usual:
```sh
nixos-rebuild switch --flake .#moss-nix
```

#### References
README modified from: [Vincibean/my-nixos-installation.md](https://gist.githubusercontent.com/Vincibean/baf1b76ca5147449a1a479b5fcc9a222/raw/2822c8a6f912332ff267c06ca279c55f61172b2d/my-nixos-installation.md) 

Flake modified from: [jleightcap](https://git.sr.ht/~jleightcap/nixos-config/tree/main/item/cloud) 

