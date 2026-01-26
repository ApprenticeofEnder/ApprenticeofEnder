{
  flake,
  lib,
  ...
}: {
  imports = lib.attrValues flake.inputs.nur.repos.moredhel.hmModules.rawModules;
}
