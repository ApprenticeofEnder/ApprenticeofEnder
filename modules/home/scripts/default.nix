{pkgs, ...}: {
  home.packages = with pkgs; [
    (writeShellScriptBin "yls" (builtins.readFile ./yls.sh))
    (writeShellScriptBin "fit" (builtins.readFile ./fit.sh))
    (writeShellScriptBin "prod-zapper" (builtins.readFile ./prod-zapper.sh))
  ];
}
