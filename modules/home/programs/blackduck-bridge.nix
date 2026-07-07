{
  pkgs,
  lib,
  ...
}: let
  version = "4.4.0";
  download_url_base = "https://repo.blackduck.com/bds-integrations-release/com/blackduck/integration/bridge/binaries/bridge-cli-bundle/${version}";

  md5_hashes = {
    linux_arm = "jBRIuNj13Ytcp5aJp7lPoA==";
    linux64 = "8zF7kGGDhf54yobGLWJQ1Q==";
    macos_arm = "whGk8wVAppdw3PEBW4/UEQ==";
    macosx = "fc788iCDMq5qD2Qgf1dKTQ==";
  };

  darwinName =
    if pkgs.stdenv.isAarch64
    then "macos_arm"
    else "macosx";

  linuxName =
    if pkgs.stdenv.isAarch64
    then "linux_arm"
    else "linux64";

  download_data = with pkgs; let
    os_name =
      if stdenv.isDarwin
      then darwinName
      else linuxName;
  in {
    url = "${download_url_base}/bridge-cli-bundle-${version}-${os_name}.zip";
    md5 = md5_hashes."${os_name}";
    extracted = "bridge-cli-bundle-${version}-${os_name}";
  };

  zip_name = "bridge-cli-bundle.zip";

  blackduck-bridge =
    pkgs.runCommand "bridge-cli" {
      nativeBuildInputs = with pkgs; [
        # keep-sorted start
        cacert
        curl
        makeWrapper
        openssl
        unzip
        # keep-sorted end
      ];
      meta = {
        mainProgram = "bridge-cli";
      };
    } ''
      mkdir -p $out/bin
      curl -L ${download_data.url} -o ${zip_name}
      MD5SUM=$(cat ${zip_name} | openssl dgst -md5 -binary | openssl enc -base64)

      if [ "$MD5SUM" != "${download_data.md5}" ]; then
        echo "Invalid MD5 checksum: $MD5SUM"
        exit 1
      fi

      TMP=$(mktemp --directory /tmp/blackduck-bridge.XXXXXXXX)

      unzip ${zip_name} -d "$TMP"
      cp -r $TMP/${download_data.extracted}/* $out/bin
      rm -rf "$TMP"

      ls -la $out/bin/bridge-cli

      wrapProgram $out/bin/bridge-cli
    '';
in {
  home.packages = lib.optionals pkgs.stdenv.isDarwin [
    blackduck-bridge
  ];
}
