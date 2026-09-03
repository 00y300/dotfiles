local is_mac = vim.fn.has("mac") == 1

return {
  "lervag/vimtex",
  lazy = false, -- vimtex ships its own ftdetect; lazy-loading by ft breaks detection
  init = function()
    -- Viewer -----------------------------------------------------------------
    -- Skim on macOS, zathura on Linux. Zathura's forward search needs D-Bus,
    -- which macOS doesn't have -- every sync would spawn a new window.
    if is_mac then
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 0 -- don't steal focus on every sync
      vim.g.vimtex_view_skim_reading_bar = 1 -- highlight the synced line
    else
      vim.g.vimtex_view_method = "zathura"
    end

    vim.g.vimtex_view_automatic = 1 -- open the viewer after the first compile
    vim.g.vimtex_view_forward_search_on_start = 0 -- the follow-cursor autocmd handles this

    -- Compiler ---------------------------------------------------------------
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_compiler_latexmk = {
      continuous = 1, -- rebuild automatically on every write
      -- If a .latexmkrc sets $out_dir/$aux_dir, mirror it here as `out_dir` /
      -- `aux_dir`, or vimtex looks for the PDF in the wrong place.
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
    local function format_sentences(first_line, last_line)
      local lines = vim.api.nvim_buf_get_lines(0, first_line - 1, last_line, false)
      local formatted = {}

      for _, line in ipairs(lines) do
        local rest = line
        while true do
          local before, punctuation, after = rest:match("^(.-)([.!?])%s+([%u\\].*)")
          if not before then
            table.insert(formatted, rest)
            break
          end
          table.insert(formatted, before .. punctuation)
          rest = after
        end
      end

      vim.api.nvim_buf_set_lines(0, first_line - 1, last_line, false, formatted)
    end

    vim.api.nvim_create_user_command("TexSentenceFormat", function(args)
      format_sentences(args.line1, args.line2)
    end, {
      range = true,
      desc = "Put each LaTeX sentence on its own line",
    })

    ---------------------------------------------------------------------------
    -- Follow the cursor: debounced forward search into the viewer
    ---------------------------------------------------------------------------
    local uv = vim.uv or vim.loop
    local timer = uv.new_timer()
    local last_line = -1
    local enabled = true

    -- Buffers whose sync was skipped because the PDF wasn't readable yet.
    -- They get one catch-up sync when the next compile succeeds.
    local pending = {}

    local group = vim.api.nvim_create_augroup("VimtexFollowCursor", { clear = true })

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = group,
      pattern = "*.tex",
      callback = function(event)
        format_sentences(1, vim.api.nvim_buf_line_count(event.buf))
      end,
      desc = "Put each LaTeX sentence on its own line before saving",
    })

    -- These are Vimscript dict members, so they have to be reached via eval()
    -- from inside the owning buffer's context.
    local function eval_str(expr)
      local ok, v = pcall(vim.fn.eval, expr)
      if ok and type(v) == "string" and v ~= "" then
        return v
      end
      return nil
    end

    -- Where vimtex keeps the output path has moved between versions. Current
    -- builds expose compiler.get_file('pdf'); older ones had an out() method.
    -- Derive it by hand if neither exists.
    local function resolve_pdf()
      if vim.b.vimtex == nil then
        return nil
      end

      local p = eval_str("b:vimtex.compiler.get_file('pdf')")
        or eval_str("b:vimtex.compiler.out()")
        or eval_str("b:vimtex.out()")
      if p then
        return p
      end

      local root = eval_str("b:vimtex.root")
      local base = eval_str("b:vimtex.base")
      if not root or not base then
        return nil
      end

      local dir = eval_str("b:vimtex.compiler.out_dir") -- usually empty
      if dir and not vim.startswith(dir, "/") then
        dir = root .. "/" .. dir
      end

      local stem = (base:gsub("%.tex$", ""))
      return (dir or root) .. "/" .. stem .. ".pdf"
    end

    local function out_pdf(buf)
      if not vim.api.nvim_buf_is_valid(buf) then
        return nil
      end
      local ok, out = pcall(vim.api.nvim_buf_call, buf, resolve_pdf)
      return ok and out or nil
    end

    -- "Viewer cannot read PDF file!" is emitted by vimtex's own logging rather
    -- than thrown, so pcall can't suppress it. Checking first is the only fix.
    local function pdf_ready(buf)
      local pdf = out_pdf(buf)
      return pdf ~= nil and pdf ~= "" and vim.fn.filereadable(pdf) == 1
    end

    local function sync(buf)
      if not enabled or vim.api.nvim_get_current_buf() ~= buf then
        return
      end
      if not pdf_ready(buf) then
        pending[buf] = true -- retry after the next successful compile
        return
      end
      pending[buf] = nil
      vim.cmd("VimtexView")
    end

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
              400, -- ms of stillness; long enough to miss most mid-write races
              0,
              vim.schedule_wrap(function()
                sync(event.buf)
              end)
            )
          end,
        })

        vim.api.nvim_create_autocmd("BufWipeout", {
          group = group,
          buffer = event.buf,
          callback = function()
            pending[event.buf] = nil
          end,
        })
      end,
    })

    -- Catch-up sync: a compile just landed, so the skipped forward search
    -- from a moment ago can finally go through.
    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "VimtexEventCompileSuccess",
      callback = function()
        local buf = vim.api.nvim_get_current_buf()
        if not pending[buf] then
          return
        end
        pending[buf] = nil
        vim.defer_fn(function()
          sync(buf)
        end, 150) -- let the viewer finish picking up the new file
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
    { "<leader>lv", "<cmd>VimtexView<CR>", ft = "tex", desc = "LaTeX view (forward search)" },
    { "<leader>lk", "<cmd>VimtexStop<CR>", ft = "tex", desc = "LaTeX stop compilation" },
    { "<leader>lR", "<cmd>VimtexClean<CR>", ft = "tex", desc = "LaTeX clean aux files" },
    { "<leader>le", "<cmd>VimtexErrors<CR>", ft = "tex", desc = "LaTeX errors (quickfix)" },
    { "<leader>lf", "<cmd>VimtexCompileOutput<CR>", ft = "tex", desc = "LaTeX compiler output" },
    { "<leader>lt", "<cmd>VimtexTocToggle<CR>", ft = "tex", desc = "LaTeX table of contents" },
    { "<leader>li", "<cmd>VimtexInfo<CR>", ft = "tex", desc = "LaTeX info" },
    { "<leader>lF", "<cmd>VimtexFollowToggle<CR>", ft = "tex", desc = "LaTeX toggle follow cursor" },
    { "<leader>ls", "<cmd>%TexSentenceFormat<CR>", ft = "tex", desc = "LaTeX format sentences" },
    { "<leader>ls", ":TexSentenceFormat<CR>", ft = "tex", mode = "x", desc = "LaTeX format sentences" },
  },
}
