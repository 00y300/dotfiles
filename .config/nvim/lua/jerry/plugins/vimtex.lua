return {
  "lervag/vimtex",
  lazy = false, -- vimtex ships its own ftdetect; lazy-loading by ft breaks detection
  init = function()
    -- Viewer -----------------------------------------------------------------
    vim.g.vimtex_view_method = "zathura"
    vim.g.vimtex_view_automatic = 1
    vim.g.vimtex_view_forward_search_on_start = 1

    -- Compiler ---------------------------------------------------------------
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_compiler_latexmk = {
      continuous = 1, -- rebuild automatically on every write
      options = {
        "-verbose",
        "-file-line-error",
        "-synctex=1", -- required for forward/backward search
        "-interaction=nonstopmode",
      },
    }
    -- Default engine is pdflatex. Override per file with:
    --   % !TeX program = xelatex
    vim.g.vimtex_compiler_latexmk_engines = {
      _ = "-pdf",
      pdflatex = "-pdf",
      lualatex = "-lualatex",
      xelatex = "-xelatex",
    }

    -- Misc -------------------------------------------------------------------
    vim.g.vimtex_mappings_enabled = 0 -- no default mappings; use the keys below
    vim.g.vimtex_complete_enabled = 1
    vim.g.vimtex_quickfix_mode = 0 -- don't steal focus with the quickfix window
  end,

  config = function()
    ---------------------------------------------------------------------------
    -- Follow the cursor: debounced forward search into zathura
    ---------------------------------------------------------------------------
    local uv = vim.uv or vim.loop
    local timer = uv.new_timer()
    local last_line = -1
    local enabled = true

    local group = vim.api.nvim_create_augroup("VimtexFollowCursor", { clear = true })

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "tex",
      callback = function(event)
        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
          group = group,
          buffer = event.buf,
          callback = function()
            if not enabled then
              return
            end
            local line = vim.fn.line(".")
            if line == last_line then
              return -- horizontal movement; synctex is line-granular anyway
            end
            last_line = line
            timer:stop()
            timer:start(
              250, -- ms of stillness before syncing
              0,
              vim.schedule_wrap(function()
                if vim.b.vimtex ~= nil then
                  pcall(vim.cmd, "VimtexView")
                end
              end)
            )
          end,
        })
      end,
    })

    vim.api.nvim_create_user_command("VimtexFollowToggle", function()
      enabled = not enabled
      vim.notify("Vimtex follow cursor: " .. (enabled and "on" or "off"))
    end, {})

    ---------------------------------------------------------------------------
    -- Let vimtex own LaTeX highlighting/indentation instead of treesitter.
    -- (Also requires the `tex` early-return in your treesitter FileType autocmd.)
    ---------------------------------------------------------------------------
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "tex",
      callback = function(event)
        pcall(vim.treesitter.stop, event.buf)
      end,
    })
  end,

  keys = {
    { "<leader>ll", "<cmd>VimtexCompile<CR>", ft = "tex", desc = "LaTeX compile (toggle continuous)" },
    { "<leader>lo", "<cmd>VimtexCompileSS<CR>", ft = "tex", desc = "LaTeX compile once" },
    { "<leader>lv", "<cmd>VimtexView<CR>", ft = "tex", desc = "LaTeX view (zathura)" },
    { "<leader>lk", "<cmd>VimtexStop<CR>", ft = "tex", desc = "LaTeX stop compilation" },
    { "<leader>lR", "<cmd>VimtexClean<CR>", ft = "tex", desc = "LaTeX clean aux files" },
    { "<leader>le", "<cmd>VimtexErrors<CR>", ft = "tex", desc = "LaTeX errors (quickfix)" },
    { "<leader>lf", "<cmd>VimtexCompileOutput<CR>", ft = "tex", desc = "LaTeX compiler output" },
    { "<leader>lt", "<cmd>VimtexTocToggle<CR>", ft = "tex", desc = "LaTeX table of contents" },
    { "<leader>li", "<cmd>VimtexInfo<CR>", ft = "tex", desc = "LaTeX info" },
    { "<leader>lF", "<cmd>VimtexFollowToggle<CR>", ft = "tex", desc = "LaTeX toggle follow cursor" },
  },
}
