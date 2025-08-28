{
  description = "Making a distro";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    nixpkgs,
    self,
  }: let
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f {
      pkgs = import nixpkgs { inherit system; config = { allowUnfree = true; }; };
    });
  in {

    devShells = forAllSystems ({ pkgs }: let 
      libraries = with pkgs; [
          ncurses
          grub2
          xorriso
          bzip2
          git
          gnumake
          flex
          bison
          bc
          cpio
          elfutils.dev
          openssl.dev
          syslinux
          dosfstools
          bash
          binutils
          gdb
          lld
          libllvm
          pkg-config
          coreutils
          diffutils
          busybox
          file
          findutils
          gawk
          gnugrep
          gzip
          m4
          man-db
          procps
          psmisc
          sedutil
          shadow
          gnutar
          util-linux
          zlib
          perl
          python312Full
          kotlin
          gcc
          linuxHeaders
        ];
    in {
      default = pkgs.mkShell {
          buildInputs = libraries ++ [
            (pkgs.writeShellScriptBin "linux-fetch" ''
              if [ ! -d ./linux ]; then
                echo "Cloning Linux kernel..."
                git clone https://github.com/torvalds/linux.git
              fi
            '')
            (pkgs.writeShellScriptBin "build-iso" ''
              set -euo pipefail
              ROOTFS="./rootfs"
              ISO_DIR="./iso"
              ISO_OUTPUT="./output/myos.iso"
              INITRAMFS="$ISO_DIR/boot/initramfs.cpio.gz"
              KERNEL="$ISO_DIR/boot/bzImage"

              echo "Building initramfs: $ROOTFS -> $INITRAMFS..."
              cd "$ROOTFS"
              find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../iso/boot/initramfs.cpio.gz
              cd ../
              if [ ! -f "$KERNEL" ]; then
                echo "bzImage (Kernel) not found.."
                echo "Please run a linux-fetch and build the kernel!"
                exit 1
              fi

              echo "Building ISO: $ISO_OUTPUT"
              grub-mkrescue -o $ISO_OUTPUT $ISO_DIR

              echo "Done!"

            '')
          ];
          nativeBuildInputs = libraries;
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath libraries;
          shellHook = ''
            echo "Run 'linux-fetch' to fetch latest linux kernel"
            echo "Run 'build-iso' to build the initramfs and iso"

          '';
        };
    });
  };
}
