return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- Function to get provider icon based on provider name
    local function get_provider_icon(provider_name)
      local kind_icons = {
        -- LLM Provider icons
        claude = "󰋦",
        openai = "󱢆",
        codestral = "󱎥",
        gemini = "",
        Groq = "",
        Openrouter = "󱂇",
        Ollama = "󰳆",
        ["Llama.cpp"] = "󰳆",
        Deepseek = "",
      }
      -- Return the corresponding icon or a default icon if not found
      return kind_icons[provider_name] or "󰍩" -- Default icon if provider not found
    end

    local is_mac = vim.fn.has("macunix") == 1
    -- Spinner component for CodeCompanion
    local M = require("lualine.component"):extend()
    M.processing = false
    M.spinner_index = 1
    local spinner_symbols = {
      "⠋",
      "⠙",
      "⠹",
      "⠸",
      "⠼",
      "⠴",
      "⠦",
      "⠧",
      "⠇",
      "⠏",
    }
    local spinner_symbols_len = 10
    -- Initializer
    function M:init(options)
      M.super.init(self, options)
      local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})
      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "CodeCompanionRequest*",
        group = group,
        callback = function(request)
          if request.match == "CodeCompanionRequestStarted" then
            self.processing = true
          elseif request.match == "CodeCompanionRequestFinished" then
            self.processing = false
          end
        end,
      })
    end
    -- Function that runs every time statusline is updated
    function M:update_status()
      if self.processing then
        self.spinner_index = (self.spinner_index % spinner_symbols_len) + 1
        return spinner_symbols[self.spinner_index]
      else
        return nil
      end
    end
    local virtual_env = function()
      -- show virtual env for Python and Quarto
      if vim.bo.filetype ~= "python" and vim.bo.filetype ~= "quarto" then
        return ""
      end
      local conda_env = os.getenv("CONDA_DEFAULT_ENV")
      local venv_path = os.getenv("VIRTUAL_ENV")
      if venv_path == nil then
        if conda_env == nil then
          return ""
        else
          return string.format("🐍 %s", conda_env)
        end
      else
        local venv_name = vim.fn.fnamemodify(venv_path, ":t")
        return string.format("🐍 %s", venv_name)
      end
    end
    require("lualine").setup({
      options = {
        theme = "ayu_mirage",
        globalstatus = true,
      },
      sections = {
        lualine_c = { "filename" },
        lualine_x = {
          {
            require("minuet.lualine"),
            display_name = "provider",
            provider_model_separator = "/",
            display_on_idle = true,
            fmt = function(str)
              -- Extract provider name from the string (assuming format like "provider/model" or just "provider")
              local provider = str:match("^([^/]+)")
              if provider then
                local icon = get_provider_icon(provider)
                return icon .. " " .. str
              end
              return str
            end,
          },
          { "encoding" },
          {
            "fileformat",
            symbols = is_mac and { unix = "" } or nil,
          },
          -- {
          --   virtual_env,
          --   color = { fg = "#a6e3a1" }, -- Setting the color to green
          -- },
          {
            M,
            color = { fg = "#f9ae58" }, -- Orange color for spinner
          },
          { "filetype" },
        },
      },
    })
  end,
}
