return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "hrsh7th/nvim-cmp", -- Optional: for completion
    "nvim-telescope/telescope.nvim", -- Optional: for actions
    {
      "MeanderingProgrammer/render-markdown.nvim", -- Optional: for markdown rendering
      ft = { "markdown", "codecompanion" },
    },
    {
      "echasnovski/mini.diff",
      config = function()
        local diff = require("mini.diff")
        diff.setup({
          -- Disabled by default
          source = diff.gen_source.none(),
        })
      end,
    },
  },
  config = function()
    require("codecompanion").setup({
      strategies = {
        chat = {
          adapter = "openai",
        },
        inline = {
          adapter = "openai",
        },
        agent = {
          adapter = "openai",
        },
      },
      adapters = {
        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            name = "qwen3_coder",
            url = "http://localhost:8012/v1/chat/completions",
            api_key = "dummy", -- Required but not used for local server
            chat = {
              model = "Qwen3-Coder-30B-A3B-Instruct-UD-Q5_K_XL",
              temperature = 0.7,
              top_p = 0.8,
              top_k = 20,
              frequency_penalty = 1.05, -- OpenAI API equivalent to repeat_penalty
              max_tokens = 4096,
            },
            inline = {
              model = "Qwen3-Coder-30B-A3B-Instruct-UD-Q5_K_XL",
              temperature = 0.7,
              top_p = 0.8,
              top_k = 20,
              frequency_penalty = 1.05,
              max_tokens = 2048,
            },
          })
        end,
        -- Alternative: Direct llama-server adapter (if available)
        llama = function()
          return require("codecompanion.adapters").extend("openai", {
            name = "qwen3_llama",
            url = "http://localhost:8012/completion",
            api_key = "", -- No API key for local server
            headers = {
              ["Content-Type"] = "application/json",
            },
            parameters = {
              temperature = 0.7,
              top_p = 0.8,
              top_k = 20,
              repeat_penalty = 1.05,
              n_predict = 4096,
            },
          })
        end,
      },
      display = {
        action_palette = {
          width = 95,
          height = 10,
        },
        chat = {
          window = {
            layout = "vertical", -- vertical|horizontal|buffer
            border = "single",
            height = 0.8,
            width = 0.45,
            relative = "editor",
          },
          show_settings = true,
        },
      },
      opts = {
        log_level = "ERROR", -- TRACE|DEBUG|ERROR|INFO
        send_code = true, -- Send code to the model
        use_default_actions = true, -- Use default actions
        use_default_prompts = true, -- Use default prompts
      },
      prompt_library = {
        ["Custom Code Review"] = {
          strategy = "chat",
          description = "Review code with Qwen3 Coder",
          opts = {
            index = 10,
            default_prompt = true,
          },
          prompts = {
            {
              role = "system",
              content = "You are an expert code reviewer. Analyze the provided code for potential issues, improvements, and best practices. Focus on correctness, performance, security, and maintainability.",
            },
            {
              role = "user",
              content = function()
                return "Please review this code:\n\n```"
                  .. vim.bo.filetype
                  .. "\n"
                  .. require("codecompanion.helpers.actions").get_code()
                  .. "\n```"
              end,
            },
          },
        },
        ["Explain Code"] = {
          strategy = "chat",
          description = "Explain selected code",
          opts = {
            index = 11,
          },
          prompts = {
            {
              role = "system",
              content = "You are a helpful coding assistant. Explain code clearly and concisely, breaking down complex concepts into understandable parts.",
            },
            {
              role = "user",
              content = function()
                return "Please explain this code:\n\n```"
                  .. vim.bo.filetype
                  .. "\n"
                  .. require("codecompanion.helpers.actions").get_code()
                  .. "\n```"
              end,
            },
          },
        },
      },
    })
  end,
  event = "VeryLazy",
  keys = {
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion Actions" },
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "CodeCompanion Chat" },
    { "<leader>av", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "CodeCompanion Add" },
    { "<leader>ai", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "CodeCompanion Inline" },
    { "<leader>aq", "<cmd>CodeCompanionChat<cr>", mode = { "n", "v" }, desc = "CodeCompanion Quick Chat" },
  },
}
