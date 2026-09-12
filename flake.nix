{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nci.url = "github:yusdacra/nix-cargo-integration";
  inputs.nci.inputs.nixpkgs.follows = "nixpkgs";
  inputs.parts.url = "github:hercules-ci/flake-parts";
  inputs.parts.inputs.nixpkgs-lib.follows = "nixpkgs";

  outputs =
    inputs@{
      parts,
      nci,
      ...
    }:
    parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
        "aarch64-linux"
        "i686-linux"
      ];
      imports = [
        nci.flakeModule
        ./crates.nix
      ];
      perSystem =
        {
          pkgs,
          config,
          ...
        }:
        let
          crateOutputs = config.nci.outputs."nix-inspect";
        in
        {
          devShells.default = crateOutputs.devShell.overrideAttrs (old: {
            WORKER_BINARY_PATH = "./worker/build/nix-inspect";

            # https://discourse.nixos.org/t/rust-src-not-found-and-other-misadventures-of-developing-rust-on-nixos/11570/5
            RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

            packages =
              (old.packages or [ ])
              ++ (with pkgs; [
                rust-analyzer
                clang-tools
                pkg-config
                ninja
                boost
                meson
                nlohmann_json
                nixVersions.nix_2_30.dev
                treefmt
              ]);
          });
          packages.default = crateOutputs.packages.release;
          packages.nix-inspect = crateOutputs.packages.release;
        };
    };
}
