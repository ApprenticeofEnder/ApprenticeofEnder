{lib, ...}: {
  plugins = {
    lualine = {
      enable = true;
      luaConfig.pre = ''
        local function get_colors(highlight_name)
          if vim.g.vscode then
            return {
              fg = "x000000",
              bg ="x000000"
            }
          end
          local highlight_data = vim.api.nvim_get_hl(0, {name=highlight_name})
          local result = {
            fg = string.format("%x", highlight_data.fg),
          }

          if highlight_data.bg then
            result.bg = string.format("%x", highlight_data.bg)
          end
          return result
        end

        local colors = {
          red = "#ca1243",
          danger = get_colors("DiffDelete"),
          warning = get_colors("DiffChange"),
          success = get_colors("DiffAdd"),
          replace = get_colors("DiffText"),
          level1 = get_colors("Search"),
          level2 = get_colors("TabLine"),
          normal = get_colors("Normal"),

          grey = "#a0a1a7",
          black = "#383a42",
          white = "#f3f3f3",
          light_green = "#83a598",
          orange = "#fe8019",
          green = "#8ec07c",
        }

        local theme = {
          normal = {
            a = colors.level1,
            b = colors.level2,
            c = colors.level2,
            z = colors.level1,
          },
          insert = { a = { fg = colors.black, bg = colors.success.fg } },
          visual = { a = { fg = colors.black, bg = colors.warning.fg } },
          replace = { a = { fg = colors.black, bg = colors.replace.fg } },
        }

        local empty = require("lualine.component"):extend()
        function empty:draw(default_highlight)
          self.status = ""
          self.applied_separator = ""
          self:apply_highlights(default_highlight)
          self:apply_section_separators()
          return self.status
        end

        -- Put proper separators and gaps between components in sections
        local function process_sections(sections)
          for name, section in pairs(sections) do
            local left = name:sub(9, 10) < "x"
            for pos = 1, name ~= "lualine_z" and #section or #section - 1 do
              table.insert(section, pos * 2, { empty, color = { fg = colors.normal.bg, bg = colors.normal.bg } })
            end
            for id, comp in ipairs(section) do
              if type(comp) ~= "table" then
                comp = { comp }
                section[id] = comp
              end
              comp.separator = left and { right = "" } or { left = "" }
            end
          end
          return sections
        end

        local function search_result()
          if vim.v.hlsearch == 0 then
            return ""
          end
          local last_search = vim.fn.getreg("/")
          if not last_search or last_search == "" then
            return ""
          end
          local searchcount = vim.fn.searchcount { maxcount = 9999 }
          return last_search .. "(" .. searchcount.current .. "/" .. searchcount.total .. ")"
        end

        local function modified()
          if vim.bo.modified then
            return "+"
          elseif vim.bo.modifiable == false or vim.bo.readonly == true then
            return "-"
          end
          return ""
        end
      '';
      settings = lib.nixvim.mkRaw ''
        {
          options = {
            theme = theme,
            component_separators = "",
            section_separators = { left = "", right = "" },
          },
          sections = process_sections {
            lualine_a = { "mode" },
            lualine_b = {
              "branch",
              "diff",
              {
                "diagnostics",
                source = { "nvim" },
                sections = { "error" },
                diagnostics_color = { error = colors.danger },
              },
              {
                "diagnostics",
                source = { "nvim" },
                sections = { "warn" },
                diagnostics_color = { warn = colors.danger },
              },
              { "filename", file_status = false, path = 4 },
              { modified, color = { bg = colors.danger.bg } },
              {
                "%w",
                cond = function()
                  return vim.wo.previewwindow
                end,
              },
              {
                "%r",
                cond = function()
                  return vim.bo.readonly
                end,
              },
              {
                "%q",
                cond = function()
                  return vim.bo.buftype == "quickfix"
                end,
              },
            },
            lualine_c = {},
            lualine_x = {},
            lualine_y = { search_result, "lsp_status", "filetype" },
            lualine_z = { "%l:%c", "%p%%/%L" },
          },
          inactive_sections = {
            lualine_c = { "%f %y %m" },
            lualine_x = {},
          },
        }
      '';
    };
  };
}
