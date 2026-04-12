let
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

  normalMaps = mapModes ["n"] [
    (makeMapping ";" ":" "CMD enter command mode")
    (makeMapping "<SPACE>" "" "Preparing leader key")

    # Window switching
    (makeMapping "<C-h>" "<C-w>h" "Switch window left")
    (makeMapping "<C-l>" "<C-w>l" "Switch window right")
    (makeMapping "<C-j>" "<C-w>j" "Switch window up")
    (makeMapping "<C-k>" "<C-w>k" "Switch window down")

    (makeMapping "<ESC>" "<cmd>noh<CR>" "General clear highlights")
    (makeMapping "<C-s>" "<cmd>w<CR>" "General save file")
    (makeMapping "<C-c>" "<cmd>%y+<CR>" "General copy whole file")

    (makeMapping "<leader>n" "<cmd>set nu!<CR>" "Toggle line number")
    (makeMapping "<leader>rn" "<cmd>set rnu!<CR>" "Toggle relative line number")
    (makeMapping "<leader>ch" "<cmd>NvCheatsheet<CR>" "Toggle NvCheatsheet")

    # Global LSP Mappings
    (makeMapping "<leader>ds" {
      __raw = "vim.diagnostic.setloclist";
    } "LSP diagnostic loclist")

    # NvimTree
    (makeMapping "<C-n>" "<cmd>NvimTreeToggle<CR>" "nvimtree toggle window")
    (makeMapping "<leader>e" "<cmd>NvimTreeFocus<CR>" "nvimtree focus window")

    # Barbar
    (makeMapping "<tab>" "<cmd>BufferNext<CR>" "buffer goto next")
    (makeMapping "<S-tab>" "<cmd>BufferPrevious<CR>" "buffer goto prev")
    (makeMapping "<leader>x" "<cmd>BufferClose<CR>" "buffer close")
    (makeMapping "<A->>" "<cmd>BufferMoveNext<CR>" "buffer reorder right")
    (makeMapping "<A-<>" "<cmd>BufferMovePrevious<CR>" "buffer reorder left")

    # Telescope
    (makeMapping "<leader>fw" "<cmd>Telescope live_grep<CR>" "telescope live grep")
    (makeMapping "<leader>fb" "<cmd>Telescope buffers<CR>" "telescope find buffers")
    (makeMapping "<leader>fh" "<cmd>Telescope help_tags<CR>" "telescope help page")
    (makeMapping "<leader>ma" "<cmd>Telescope marks<CR>" "telescope find marks")
    (makeMapping "<leader>fo" "<cmd>Telescope oldfiles<CR>" "telescope find oldfiles")
    (makeMapping "<leader>fz" "<cmd>Telescope current_buffer_fuzzy_find<CR>" "telescope find in current buffer")
    (makeMapping "<leader>cm" "<cmd>Telescope git_commits<CR>" "telescope git commits")
    (makeMapping "<leader>gt" "<cmd>Telescope git_status<CR>" "telescope git status")
    (makeMapping "<leader>pt" "<cmd>Telescope terms<CR>" "telescope pick hidden term")
    (makeMapping "<leader>ff" "<cmd>Telescope find_files<cr>" "telescope find files")
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
  ];
in {
  keymaps =
    normalMaps
    ++ insertMaps
    ++ visualMaps;
}
#
# map({ "n", "x" }, "<leader>fm", function()
#   require("conform").format { lsp_fallback = true }
# end, { desc = "general format file" })
#
# -- terminal
# map("t", "<C-x>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })
#
# -- new terminals
# map("n", "<leader>h", function()
#   require("nvchad.term").new { pos = "sp" }
# end, { desc = "terminal new horizontal term" })
#
# map("n", "<leader>v", function()
#   require("nvchad.term").new { pos = "vsp" }
# end, { desc = "terminal new vertical term" })
#
# -- toggleable
# map({ "n", "t" }, "<A-v>", function()
#   require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" }
# end, { desc = "terminal toggleable vertical term" })
#
# map({ "n", "t" }, "<A-h>", function()
#   require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
# end, { desc = "terminal toggleable horizontal term" })
#
# map({ "n", "t" }, "<A-i>", function()
#   require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
# end, { desc = "terminal toggle floating term" })
#

