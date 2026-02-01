{pkgs, ...}: let
  sdk = pkgs.dotnet-sdk_9;
  runtime = pkgs.dotnet-runtime_9;
in {
  home = {
    packages = [
      sdk
      runtime
    ];

    sessionVariables = {
      DOTNET_ROOT = "${sdk}";
    };
  };
}
