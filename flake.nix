{
  description = "Haskell flake template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    edinix = {
      url = "github:fmarl/edinix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        extensions.follows = "nix-vscode-extensions";
      };
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  nixConfig.sandbox = "relaxed";

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      edinix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Nix GHC version needs to be the one that the stack.yaml resolver expects.
        #
        # Find out available Nix GHCs:
        # ```
        # $ nix repl
        # nix-repl> :lf nixpkgs
        # nix-repl> legacyPackages.x86_64-linux.haskell.packages.<TAB>
        # ```
        # `:lf` stands for "load flake"
        #
        # Find out expected Stack GHCs:
        # Visit https://www.stackage.org/ and look for LTS or Nightlies, e.g.
        # resolver: lts-20.11          expects ghc-9.2.5
        # resolver: nightly-2023-02-14 expects ghc-9.4.4
        #
        # So if you use "ghc944", set "resolver: nightly-2023-02-14" in your stack.yaml file
        ghc = "ghc984";

        libDeps = [ pkgs.zlib ];

        app = pkgs.haskell.lib.buildStackProject {
          name = "myStack";
          src = ./.;
          ghc = pkgs.haskell.packages."${ghc}".ghc;
          buildInputs = libDeps;
        };

      in
      {
        devShells.default = import ./shell.nix {
          inherit
            system
            nixpkgs
            ghc
            libDeps
            edinix
            ;
        };
        packages.default = app;
      }
    );
}
