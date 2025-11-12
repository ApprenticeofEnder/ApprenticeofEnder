{
  cachix = {
    enable = true;
    push = "rbabaev";
    pull = [
      "cachix"
      "devenv"
      "oxalica"
      "rbabaev"
      "nixpkgs"
      "mfarabi"
      "emacs-ci"
      "nix-darwin"
      "nix-community"
      "pre-commit-hooks"
    ];
  };
}
