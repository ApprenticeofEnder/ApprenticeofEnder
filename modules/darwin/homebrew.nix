{...}: {
  homebrew = {
    enable = true;
    brews = [
      "dart-sdk"
      "dependency-check"
      "fvm"
      "iproute2mac"
      "libiconv"
    ];
    casks = [
      {
        name = "1password-cli";
      }
      "font-hack-nerd-font"
    ];
  };
}
