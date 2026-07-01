{lib, ...}: {
  mkVsCode = {
    settings ? {},
    extensions ? [],
    variants ? ["vscode" "vscodium"],
  }:
    lib.mkMerge (
      map (variant: {
        programs."${variant}" = {
          profiles = {
            default = {
              userSettings = settings;
              extensions = extensions;
            };
          };
        };
      })
      variants
    );

  setDefaultFormatters = formatter: languages: (
    builtins.listToAttrs (
      map (language: {
        name = "[${language}]";
        value = {
          "editor.defaultFormatter" = formatter;
        };
      })
      languages
    )
  );
}
