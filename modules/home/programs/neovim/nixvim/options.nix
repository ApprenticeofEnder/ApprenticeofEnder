{
  # -------------------------------------- options ------------------------------------------
  # o.laststatus = 3
  # o.showmode = false
  # o.splitkeep = "screen"
  #
  # o.clipboard = "unnamedplus"
  # o.cursorline = true
  # o.cursorlineopt = "number"
  #
  # -- Indenting
  # o.expandtab = true
  # o.shiftwidth = 2
  # o.smartindent = true
  # o.tabstop = 2
  # o.softtabstop = 2
  #
  # opt.fillchars = { eob = " " }
  # o.ignorecase = true
  # o.smartcase = true
  # o.mouse = "a"
  #
  # -- Numbers
  # o.number = true
  # o.numberwidth = 2
  # o.ruler = false
  #
  # -- disable nvim intro
  # opt.shortmess:append "sI"
  #
  # o.signcolumn = "yes"
  # o.splitbelow = true
  # o.splitright = true
  # o.timeoutlen = 400
  # o.undofile = true
  #
  # -- interval for writing swap file to disk, also used by gitsigns
  # o.updatetime = 250
  #
  # -- go to previous/next line with h,l,left arrow and right arrow
  # -- when cursor reaches end/beginning of line
  # opt.whichwrap:append "<>[]hl"
  #

  globals = {
    # Disable useless providers
    loaded_ruby_provider = 0; # Ruby
    loaded_perl_provider = 0; # Perl
    loaded_python_provider = 0; # Python 2

    # Custom toggles for UI features
    disable_autoformat = false;
    spell_enabled = true;
    colorizing_enabled = false;
    first_buffer_opened = false;
    whitespace_character_enabled = false;
  };

  opts = {
    # Performance & Timing
    updatetime = 100; # CursorHold delay; faster completion and git signs
    lazyredraw = false; # Breaks noice plugin
    synmaxcol = 240; # Disable syntax highlighting for long lines
    timeoutlen = 500; # Key sequence timeout (ms)
    smoothscroll = true; # Smooth scrolling with Ctrl-D/U

    # UI & Appearance
    colorcolumn = "100";
    cursorcolumn = false;
    cursorline = true;
    cursorlineopt = "number";
    laststatus = 3; # Global statusline
    matchtime = 1; # Flash duration in deciseconds
    number = true;
    numberwidth = 2;
    relativenumber = true;
    showmatch = true;
    showmode = false;
    showtabline = 2;
    signcolumn = "yes";
    termguicolors = true;
    winborder = "rounded";

    # Windows & Splits
    splitbelow = true;
    splitright = true;
    splitkeep = "screen";

    # Mouse
    mouse = "a";
    mousemodel = "extend"; # Right-click extends selection

    # Search
    incsearch = true;
    ignorecase = true; # Case-insensitive search
    smartcase = true; # Unless pattern contains uppercase
    iskeyword = "@,48-57,_,192-255,-"; # Treat dash-separated text as a single word

    # Files & Buffers
    swapfile = false;
    undofile = true;
    autoread = true;
    writebackup = false;
    fileencoding = "utf-8";
    modeline = true; # Scan for editor directives like 'vim: set ft=nix:'
    modelines = 100; # Scan first/last 100 lines for modelines

    # Indentation & Formatting
    tabstop = 2;
    shiftwidth = 2;
    expandtab = true;
    autoindent = true;
    breakindent = true;
    copyindent = true;
    preserveindent = true;
    formatoptions = "rqnl1j";
    formatlistpat = "^\\s*[0-9\\-\\+\\*]\\+[\\.)]*\\s\\+";
    linebreak = true;
    wrap = false;
  };
  clipboard = {
    register = "unnamedplus";
  };
}
