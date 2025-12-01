{
  programs.lazygit = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    settings = {
      notARepository = "skip";
      disableStartupPopups = true;
      promptToReturnFromSubprocess = true;

      gui = {
        sidePanelWidth = 0.33;
        nerdFontsVersion = "3";
        scrollPastBottom = true;
        scrollOffBehaviour = "jump";
        switchTabsWithPanelJumpKeys = true;
      };

      os = {
        editInTerminal = true;
        # edit = "emacsclient -nw {{filename}}";
        # openDirInEditor = "emacsclient -nw {{dir}}";
        # editAtLine = "emacsclient -nw +{{line}} {{filename}}";
      };

      git = {
        parseEmoji = true;
        commit.signOff = true;
        branchPrefix = "rbabaev/";
        # branchPrefix = "${config.me.username}/";
      };
    };
  };
}
