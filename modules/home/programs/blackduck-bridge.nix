{
  # pkgs,
  # lib,
  ...
}: let
  # version = "4.4.0";
  # download_url_base = "https://repo.blackduck.com/bds-integrations-release/com/blackduck/integration/bridge/binaries/bridge-cli-bundle/${version}/";
  #
  # download_data = with pkgs;
  #   lib.mergeAttrsList [
  #     (lib.optionalAttrs (stdenv.isDarwin && stdenv.isaarch_64) {
  #       url = "${download_url_base}/bridge-cli-bundle-macos-arm.zip";
  #       md5 = "whGk8wVAppdw3PEBW4/UEQ==";
  #     })
  #     (lib.optionalAttrs (stdenv.isLinux && stdenv.isx86_64) {
  #       url = "${download_url_base}/bridge-cli-bundle-linux64.zip";
  #       md5 = "8zF7kGGDhf54yobGLWJQ1Q==";
  #     })
  #   ];
  #
  # zip_name = "bridge-cli-bundle.zip";
  #
  # blackduck-bridge =
  #   pkgs.runCommand "bridge-cli" {
  #     nativeBuildInputs = [pkgs.makeWrapper];
  #     meta = {
  #       mainProgram = "bridge-cli";
  #     };
  #   } ''
  #     mkdir -p $out/bin
  #     ${pkgs.curl} ${download_data.url} -o bridge-cli-bundle.zip
  #
  #   '';
in {
  home.packages = [
  ];
}
