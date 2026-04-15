{lib, ...}: let
  mapModes = modes: keymaps:
    map (
      keymap:
        keymap
        // {
          mode = modes;
        }
    )
    keymaps;

  makeMapping = key: action: desc: {
    action = action;
    key = key;
    options = {
      desc = desc;
    };
  };

  actions = ''
    vim.opt.whichwrap:append "<>[]hl"

    _M.make_vscode_mapping = function(
      vscode_action,
      nvim_action
    )
      if not vim.g.vscode then
        return nvim_action
      end

      return function()
        require("vscode").action(vscode_action)
      end
    end

    _M.make_vscode_mapping_advanced = function(
      vscode_cb,
      nvim_cb
    )
      return function()
        if not vim.g.vscode then
          return nvim_cb()
        end

        return vscode_cb()
      end
    end
  '';

  makeVsCodeMapping = key: vscodeAction: nvimAction: desc:
    (
      makeMapping
      key
      (
        lib.nixvim.mkRaw ''
          _M.make_vscode_mapping("${vscodeAction}", "${nvimAction}")
        ''
      )
      desc
    )
    // {
      options.noremap = true;
    };

  makeVsCodeMappingAdvanced = key: vscodeCallbackLua: nvimCallbackLua: desc:
    (
      makeMapping
      key
      (
        lib.nixvim.mkRaw ''
          _M.make_vscode_mapping_advanced(${vscodeCallbackLua}, ${nvimCallbackLua})
        ''
      )
      desc
    )
    // {
      options.noremap = true;
    };

  normalMaps = mapModes ["n"] [
    (makeMapping ";" ":" "CMD enter command mode")
    (makeMapping "<SPACE>" "" "Preparing leader key")

    # Window switching
    (makeVsCodeMapping "<C-h>" "workbench.action.navigateLeft" "<C-w>h" "Switch window left")
    (makeVsCodeMapping "<C-l>" "workbench.action.navigateRight" "<C-w>l" "Switch window right")
    (makeVsCodeMapping "<C-j>" "workbench.action.navigateUp" "<C-w>j" "Switch window up")
    (makeVsCodeMapping "<C-k>" "workbench.action.navigateDown" "<C-w>k" "Switch window down")

    (makeMapping "<ESC>" "<cmd>noh<CR>" "General clear highlights")
    (makeMapping "<C-s>" "<cmd>w<CR>" "General save file")
    (makeMapping "<C-c>" "<cmd>%y+<CR>" "General copy whole file")

    (makeMapping "<leader>n" "<cmd>set nu!<CR>" "Toggle line number")
    (makeMapping "<leader>rn" "<cmd>set rnu!<CR>" "Toggle relative line number")
    (makeMapping "<leader>ch" "<cmd>NvCheatsheet<CR>" "Toggle NvCheatsheet")

    # Global LSP Mappings
    (
      makeVsCodeMappingAdvanced
      "<leader>ds"
      ''
        function()
          require("vscode").action("workbench.actions.view.problems")
        end
      ''
      "vim.diagnostic.setloclist"
      "LSP diagnostic loclist"
    )

    # File Explorer
    (makeVsCodeMapping "<C-n>" "workbench.view.explorer" "<cmd>NvimTreeToggle<CR>" "nvimtree toggle window")
    (makeVsCodeMapping "<leader>e" "workbench.files.action.focusFilesExplorer" "<cmd>NvimTreeFocus<CR>" "nvimtree focus window")

    # Tabs
    (makeVsCodeMapping "<tab>" "workbench.action.nextEditor" "<cmd>BufferNext<CR>" "buffer goto next")
    (makeVsCodeMapping "<S-tab>" "workbench.action.previousEditor" "<cmd>BufferPrevious<CR>" "buffer goto prev")
    (makeVsCodeMapping "<leader>x" "workbench.action.closeActiveEditor" "<cmd>BufferClose<CR>" "buffer close")
    (makeVsCodeMapping "<A->>" "workbench.action.moveEditorRightInGroup" "<cmd>BufferMoveNext<CR>" "buffer reorder right")
    (makeVsCodeMapping "<A-<>" "workbench.action.moveEditorLeftInGroup" "<cmd>BufferMovePrevious<CR>" "buffer reorder left")

    # Telescope
    (makeVsCodeMapping "<leader>fw" "periscope.search" "<cmd>Telescope live_grep<CR>" "telescope live grep")
    (makeVsCodeMapping "<leader>fb" "periscope.searchBuffers" "<cmd>Telescope buffers<CR>" "telescope find buffers")
    (makeVsCodeMapping "<leader>ff" "periscope.searchFiles" "<cmd>Telescope find_files<cr>" "telescope find files")
    # TODO: How do I even go about these . . .
    (makeMapping "<leader>fh" "<cmd>Telescope help_tags<CR>" "telescope help page")
    (makeMapping "<leader>ma" "<cmd>Telescope marks<CR>" "telescope find marks")
    (makeMapping "<leader>fo" "<cmd>Telescope oldfiles<CR>" "telescope find oldfiles")
    (makeMapping "<leader>fz" "<cmd>Telescope current_buffer_fuzzy_find<CR>" "telescope find in current buffer")
    (makeMapping "<leader>cm" "<cmd>Telescope git_commits<CR>" "telescope git commits")
    (makeMapping "<leader>gt" "<cmd>Telescope git_status<CR>" "telescope git status")
    (makeMapping "<leader>pt" "<cmd>Telescope terms<CR>" "telescope pick hidden term")
    (
      makeMapping
      "<leader>fa"
      "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>"
      "telescope find all files"
    )

    # Comments
    {
      action = "gcc";
      key = "<leader>/";
      options = {
        desc = "toggle comment";
        remap = true;
      };
    }

    # whichkey
    (makeMapping "<leader>wK" "<cmd>WhichKey <CR>" "whichkey all keymaps")
    (makeMapping "<leader>wk" {
      __raw = ''
        function()
          vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
        end
      '';
    } "whichkey query lookup")
  ];

  insertMaps = mapModes ["i"] [
    (makeMapping "jk" "<ESC>" "Escape insert mode")

    (makeMapping "<C-b>" "<ESC>^i" "Move to beginning of line")
    (makeMapping "<C-e>" "<End>" "Move to end of line")
    (makeMapping "<C-h>" "<Left>" "Move left")
    (makeMapping "<C-l>" "<Right>" "Move right")
    (makeMapping "<C-j>" "<Down>" "Move down")
    (makeMapping "<C-k>" "<Up>" "Move up")
  ];

  visualMaps = mapModes ["v"] [
    {
      action = "gc";
      key = "<leader>/";
      options = {
        desc = "toggle comment";
        remap = true;
      };
    }

    (makeMapping "p" ''"_dP'' "Paste preserves primal yanked piece")

    # Better indent handling
    (makeMapping "<" "<gv" "Indent left")
    (makeMapping ">" ">gv" "Indent right")
  ];
in {
  extraConfigLuaPre = actions;
  keymaps =
    normalMaps
    ++ insertMaps
    ++ visualMaps;
}
