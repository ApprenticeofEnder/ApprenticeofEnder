{ pkgs, lib, config, ... }: {

  packages = with pkgs; [
    (writeShellScriptBin "yls" (builtins.readFile ./yls.sh))
    (writeShellScriptBin "fit" (builtins.readFile ./fit.sh))
  ];
}
