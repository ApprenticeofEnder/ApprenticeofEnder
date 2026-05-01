{pkgs, ...}: let
  obsidianRoot = "Obsidian";
  systemFolder = name: "_system/${name}";
  cssSnippet = name: ./snippets/${builtins.toString (builtins.replaceStrings [" "] ["-"] name)}.css;
  enabledCssSnippets = [
    # keep-sorted start
    "MCL Gallery Cards"
    "MCL Multi Column"
    "MCL Wide Views"
    "callouts"
    "graph"
    # keep-sorted end
  ];
in {
  imports = [
    ./plugins.nix
  ];
  home.packages = with pkgs; [
    obsidian
  ];
  programs.obsidian = {
    enable = true;
    defaultSettings = {
      # keep-sorted start block=yes

      app = {
        # keep-sorted start block=yes
        alwaysUpdateLinks = true;
        attachmentFolderPath = systemFolder "Attachments";
        newFileFolderPath = "Notes";
        newFileLocation = "folder";
        newLinkFormat = "shortest";
        pdfExportSettings = {
          includeName = true;
          pageSize = "Letter";
          landscape = false;
          margin = "0";
          downscalePercent = 100;
        };
        promptDelete = false;
        readableLineLength = false;
        showInlineTitle = true;
        vimMode = true;
        # keep-sorted end
      };
      appearance = {
        # keep-sorted start block=yes
        accentColor = "#00ff33";
        baseFontSizeAction = false;
        cssTheme = "Encore";
        enabledCssSnippets = enabledCssSnippets;
        interfaceFontFamily = "Inter";
        monospaceFontFamily = "Ubuntu Mono";
        textFontFamily = "Inter";
        theme = "obsidian";
        # keep-sorted end
      };
      cssSnippets =
        map (name: {
          inherit name;
          text = builtins.readFile (cssSnippet name);
          enable = true;
        })
        enabledCssSnippets;
      extraFiles = {
      };
      hotkeys = {
      };
      themes = [
      ];
      # keep-sorted end
    };
    vaults = {
      hub = {
        enable = false;
        target = "${obsidianRoot}/Hub";
        # settings = {};
      };
      # TODO: Add work, RPG, gaming, homelab, personal
    };
  };
}
