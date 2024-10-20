{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    terranix.url = "github:terranix/terranix";
  };

  outputs = { self, nixpkgs, terranix }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = terranix.lib.terranixConfiguration {
            inherit system;
            modules = [ ./config.nix ];
          };
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              opentofu
              terranix.packages.${system}.default
              graphviz  
            ];

            shellHook = ''
              echo "Terranix + Terraform development environment"
              echo "Use 'terranix' to generate Terraform configuration"
              echo "Use 'terraform' to apply the generated configuration"
            '';
          };
        }
      );
    };
}