return {
  "yetone/avante.nvim",
  -- if you want to build from source then do make BUILD_FROM_SOURCE=true
  -- ⚠️ must add this setting! ! !
  build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
    or "make",
  event = "VeryLazy",
  enabled = false,
  version = false, -- Never set this value to "*"! Never!
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    provider = "openai", -- Use openai provider for llama-server compatibility
    providers = {
      openai = {
        endpoint = "http://localhost:8012/v1", -- llama-server uses /v1 endpoint
        model = "Qwen3-Coder-30B-A3B-Instruct-UD-Q5_K_XL", -- Your model name
        api_key_name = "", -- No API key needed for local server
        timeout = 30000, -- Increase timeout for large models
        extra_request_body = {
          temperature = 0.7,
          top_p = 0.8,
          top_k = 20,
          frequency_penalty = 1.05, -- Using frequency_penalty as equivalent to repeat_penalty
          -- max_tokens = 20480,
        },
        disable_tools = true, -- Disable tools to avoid malformed JSON responses
      },
      -- Alternative: Keep ollama config as backup
      ollama = {
        endpoint = "http://localhost:8012",
        model = "Qwen3-Coder-30B-A3B-Instruct-UD-Q5_K_XL",
        options = {
          temperature = 0.7,
          top_p = 0.8,
          top_k = 20,
          repeat_penalty = 1.05,
        },
      },
    },
    -- Optional: Configure behavior for local setup
    behaviour = {
      auto_suggestions = false, -- May want to disable for performance
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = true,
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "folke/snacks.nvim", -- for input provider snacks
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    -- "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
