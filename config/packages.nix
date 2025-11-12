{
  lib,
  pkgs,
  inputs,
  ...
}: {
  packages = with pkgs;
    [
      binsider # binary inspector TUI

      ccache

      pulumi-esc
      supabase-cli

      sqlite
    ]
    ++ lib.optionals (stdenv.isLinux) [
      # netscanner
    ]
    ++ lib.optionals (stdenv.isDarwin && stdenv.isAarch64) [
      macmon
    ];
}
