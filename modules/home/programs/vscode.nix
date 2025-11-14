{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    # mutableExtensionsDir = true;
    profiles = {
      default = {
        enableUpdateCheck = true;
        enableExtensionUpdateCheck = true;
      };

      # TODO: Add home vs work profiles

      ender = {
        userTasks = {};

        keybindings = [
          {
            key = "ctrl+c";
            command = "editor.action.clipboardCopyAction";
            when = "textInputFocus";
          }
        ];

        extensions = with pkgs.vscode-extensions; [
          vue.volar
          antfu.slidev
          bbenoist.nix
          ms-vscode.cpptools
          jnoortheen.nix-ide
          vspacecode.whichkey
          unifiedjs.vscode-mdx
          timonwong.shellcheck
          esbenp.prettier-vscode
          graphql.vscode-graphql
          gruntfuggly.todo-tree
          ms-dotnettools.csdevkit
          ms-dotnettools.csharp
          ms-dotnettools.vscode-dotnet-runtime
          # tobias-z.vscode-harpoon
          tamasfe.even-better-toml
          bierner.markdown-mermaid
          asvetliakov.vscode-neovim
          bradlc.vscode-tailwindcss
          pkief.material-icon-theme
          aaron-bond.better-comments
          ms-vsliveshare.vsliveshare
          tailscale.vscode-tailscale
          alefragnani.project-manager
          github.vscode-github-actions
          graphql.vscode-graphql-syntax
          platformio.platformio-vscode-ide
          christian-kohler.npm-intellisense
          christian-kohler.path-intellisense
          arcticicestudio.nord-visual-studio-code
          ms-kubernetes-tools.vscode-kubernetes-tools
          ms-vscode-remote.vscode-remote-extensionpack

          # solidity
          # supabase
          # unocss
          # vitest
          # docker
          # drizzle orm
          # github repositories
          # iconify intellisense
          # ksl
          # markdownlint
          # org mode
          # playwright test for vscode
          # postgresql lsp
          # pulumi
          # pulumi copilot
          # pulumi yaml
          # sway
          # vite
          # ms-vscode-remote.remote-wsl
          # xstate vscode
        ];

        userSettings = {
          editor = {
            wordWrap = "on";
            formatOnSave = true;
            formatOnPaste = true;
            minimap.enabled = false;
            files.autoSave = "afterDelay";
            fontFamily = "JetBrainsMono Nerd Font";
          };
          workbench = {
            colorTheme = "Nord";
            iconTheme = "material-icon-theme";
            panel = {
              showLabels = false;
            };
            sideBar = {
              location = "right";
            };
            navigationControl = {
              enabled = false;
            };
            layoutControl = {
              enabled = false;
            };
            statusBar.visible = false;
            tips.enabled = false;
          };
          window = {
            titleBarStyle = "native";
            customTitleBarVisibility = "windowed";
          };
          # zenMode = {
          #   showTabs = "single";
          # };
          terminal = {
            integrated = {
              enableImages = true;
            };
          };
          github.copilot.enable = {
            "*" = false;
            plaintext = false;
            markdown = false;
            scminput = false;
          };
          extensions.experimental.affinity = {
            "asvetliakov.vscode-neovim" = 1;
          };
        };
      };
    };
  };
}
