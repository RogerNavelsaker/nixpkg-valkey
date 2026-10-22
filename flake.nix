{
  description = "Valkey OCI image built with Nix dockerTools";

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
