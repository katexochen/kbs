{
  description = "A very basic flake";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    naersk.url = "github:nix-community/naersk";
  };

  outputs =
    { self
    , nixpkgs
    , naersk
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      naersk' = pkgs.callPackage naersk { };

      kbs = naersk'.buildPackage rec {
        OPENSSL_NO_VENDOR = 1;
        LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
        nativeBuildInputs = with pkgs; [
          openssl_1_1.dev
          tpm2-tss.dev
          pkg-config
          llvmPackages.libclang.lib
          rustPlatform.bindgenHook
          sgx-sdk
        ];
        src = ./.;
      };
    in
    {

      packages.x86_64-linux = {
        default = kbs;
      };
    };
}
