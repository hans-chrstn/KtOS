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
          buildInputs = libraries;
          nativeBuildInputs = libraries;
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath libraries;
          shellHook = ''
            if [ ! -d ./linux ]; then
              echo "Cloning linux kernel.."
              git clone https://github.com/torvalds/linux.git
            fi
          '';
        };
    });
  };
}
