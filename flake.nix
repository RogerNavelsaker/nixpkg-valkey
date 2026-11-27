{
  description = "Valkey OCI image built with Nix dockerTools";
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://rogernavelsaker.cachix.org"
      "https://nacosolutions.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "rogernavelsaker.cachix.org-1:n1DtzMNhA9Rz4Kg3xlXOi/KceULu8VrMbs9WXyMFQNQ="
      "nacosolutions.cachix.org-1:JzCiW2CLcuLXtwOVAg3SlSK/kpqWbfSFEVenyKVUlug="
    ];
  };

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      image = pkgs.dockerTools.buildLayeredImage {
        name = "valkey";
        tag = pkgs.valkey.version;
        contents = [ pkgs.valkey pkgs.dockerTools.fakeNss ];

        config = {
          User = "10001:10001";
          WorkingDir = "/data";
          Entrypoint = [ "${pkgs.valkey}/bin/valkey-server" ];
          Cmd = [ "--dir" "/data" "--save" "" "--appendonly" "no" "--port" "6379" ];
          ExposedPorts = { "6379/tcp" = { }; };
          Volumes = { "/data" = { }; };
        };

        fakeRootCommands = ''
          mkdir -p ./data
          chown 10001:10001 ./data
          chmod 0700 ./data
        '';
      };
    in {
      packages.${system} = {
        inherit image;
        default = image;
      };
      checks.${system} = { inherit image; };
    };
}
