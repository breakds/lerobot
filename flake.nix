{
  description = "End-to-end Learning for Real-World Robotics in Pytorch";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    utils.url = "github:numtide/flake-utils";

    ml-pkgs.url = "github:nixvital/ml-pkgs";
    ml-pkgs.inputs.nixpkgs.follows = "nixpkgs";
    ml-pkgs.inputs.utils.follows = "utils";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    overlays.dev = nixpkgs.lib.composeManyExtensions [
      inputs.ml-pkgs.overlays.torch-family

      (final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (py-final: py-prev: {
            gym-aloha = py-final.callPackage ./nix/pkgs/gym-aloha {};
          })
        ];
      })
    ];
  } // inputs.utils.lib.eachSystem [
    "x86_64-linux"
  ] (system:
    let pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
            cudaCapabilities = [ "7.5" "8.6" ];
            cudaForwardCompat = true;
          };
          overlays = [ self.overlays.dev ];
        };
    in {
      packages = {
        gym-aloha = pkgs.python3Packages.gym-aloha;
        aio-pika = pkgs.python3Packages.aio-pika;
      };
      
      devShells.default = let
        python-env = pkgs.python3.withPackages (pyPkgs: with pyPkgs; [
          numpy
          numba
          torchWithCuda
          torchvision
          einops
          opencv4
          pymunk
          zarr
          gymnasium

          # Utils
          termcolor
          omegaconf
          wandb
          gdown
          hydra-core
          h5py
          av
          moviepy
          rerun-sdk
          debugpy

          # Huggingface
          huggingface-hub
          datasets
          safetensors
        ]);

        name = "lerobot";
      in pkgs.mkShell {
        inherit name;

        packages = [
          python-env
          pkgs.cmake
        ];

        shellHooks = let pythonIcon = "f3e2"; in ''
          export PS1="$(echo -e '\u${pythonIcon}') {\[$(tput sgr0)\]\[\033[38;5;228m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]} (${name}) \\$ \[$(tput sgr0)\]"
        '';
      };
    });
}