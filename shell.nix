{
  system,
  nixpkgs,
  ghc ? "ghc984",
  libDeps ? [ ],
  edinix,
}:
let
  pkgs = import nixpkgs { inherit system; };
  hpkgs = pkgs.haskell.packages."${ghc}";

  # Wrap Stack to work with our custom Nix integration. We don't modify stack.yaml so it keeps working for non-Nix users.
  # --no-nix         # Don't use Stack's built-in Nix integrating.
  # --system-ghc     # Use the existing GHC on PATH (will be provided through this Nix file)
  # --no-install-ghc # Don't try to install GHC if no matching GHC version found on PATH
  stack-wrapped = pkgs.symlinkJoin {
    name = "stack"; # will be available as the usual `stack` in terminal
    paths = [ pkgs.stack ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/stack \
        --add-flags "\
          --no-nix \
          --system-ghc \
          --no-install-ghc \
        "
    '';
  };

  code = edinix.packages.${system}.code {
    profiles.nix.enable = true;
    profiles.haskell.enable = true;
  };
in
pkgs.mkShell {
  buildInputs = [
    pkgs.nixfmt
    pkgs.nil
    hpkgs.ghc
    stack-wrapped
    #hpkgs.ghcid  # Continous terminal Haskell compile checker
    #hpkgs.ormolu # Haskell formatter
    hpkgs.hlint # Haskell codestyle checker
    hpkgs.hoogle # Lookup Haskell documentation
    hpkgs.haskell-language-server # LSP server for editor
    hpkgs.implicit-hie # auto generate LSP hie.yaml file from cabal
    hpkgs.retrie # Haskell refactoring tool
    # hpkgs.cabal-install
    code.editor
    code.tooling
  ];

  # Make external Nix C libraries like zlib known to GHC, like pkgs.haskell.lib.buildStackProject does
  # https://github.com/NixOS/nixpkgs/blob/d64780ea0e22b5f61cd6012a456869c702a72f20/pkgs/development/haskell-modules/generic-stack-builder.nix#L38
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath libDeps;
}
