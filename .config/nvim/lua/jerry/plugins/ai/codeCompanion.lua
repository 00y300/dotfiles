-- CodeCompanion configuration for AI-powered coding assistance
-- Updated for adapters.http namespace (v18+) using extend("openai")
return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "folke/snacks.nvim",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "markdown", "codecompanion" },
    },
    {
      "echasnovski/mini.diff",
      config = function()
        local diff = require("mini.diff")
        diff.setup({
          source = diff.gen_source.none(),
        })
      end,
    },
  },
  config = function()
    local adapters = require("codecompanion.adapters")

    require("codecompanion").setup({
      strategies = {
        chat = { adapter = "llama_cpp" },
        inline = { adapter = "llama_cpp" },
        agent = { adapter = "llama_cpp" },
      },
      adapters = {
        http = {
          -- MLX adapter built using extend("openai")
          mlx = adapters.extend("openai", {
            name = "mlx",
            formatted_name = "MLX-LM",
            url = "http://localhost:8080/v1/chat/completions",
            api_key = "DUMMY",
            headers = { ["Content-Type"] = "application/json" },
            opts = {
              stream = true,
              vision = false,
            },
            features = { text = true, tokens = true },
            roles = { llm = "assistant", user = "user" },
            schema = {
              model = {
                order = 1,
                mapping = "parameters",
                type = "enum",
                desc = "MLX model to use for code completion and chat",
                default = "lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-MLX-6bit",
                choices = {
                  "lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-MLX-6bit",
                  "mlx-community/Qwen3-Coder-30B-A3B-Instruct-4bit",
                },
              },
              temperature = {
                order = 2,
                mapping = "parameters",
                type = "number",
                desc = "Sampling temperature",
                default = 0.7,
              },
              top_p = {
                order = 3,
                mapping = "parameters",
                type = "number",
                desc = "Nucleus sampling probability",
                default = 0.8,
              },
              max_tokens = {
                order = 4,
                mapping = "parameters",
                type = "number",
                desc = "Maximum tokens to generate",
                default = 4096,
              },
            },
          }),

          -- Llama.cpp adapter built using extend("openai")
          llama_cpp = adapters.extend("openai", {
            name = "qwen3_llamacpp",
            url = "http://localhost:8012/v1/chat/completions",
            api_key = "dummy",

            num_ctx = {
              default = 256000,
              max = 1000000,
              description = "Long-context Capabilities with native support for 256K tokens, extendable up to 1M tokens using Yarn, optimized for repository-scale understanding.",
            },
            chat = {
              model = "Qwen3-Coder-30B-A3B-Instruct-UD-Q5_K_XL",
              temperature = 0.7,
              top_p = 0.8,
              top_k = 20,
              frequency_penalty = 1.05,
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
          }),

          -- Global options moved under adapters.http.opts
          opts = {
            log_level = "ERROR", -- TRACE|DEBUG|ERROR|INFO
            send_code = true,
            use_default_actions = true,
            use_default_prompts = true,
          },
        },
      },
      display = {
        action_palette = { width = 95, height = 10 },
        chat = {
          window = {
            layout = "vertical",
            border = "single",
            height = 0.8,
            width = 0.45,
            relative = "editor",
          },
          show_settings = true,
        },
      },
      prompt_library = {
        ["Custom Code Review"] = {
          strategy = "chat",
          description = "Review code with Qwen3 Coder via MLX",
          opts = { index = 10, default_prompt = true },
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
          description = "Explain selected code with MLX",
          opts = { index = 11 },
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
        ["Optimize Code"] = {
          strategy = "inline",
          description = "Optimize selected code for performance",
          opts = { index = 12 },
          prompts = {
            {
              role = "system",
              content = "You are an expert at code optimization. Rewrite the provided code to be more efficient, readable, and performant while maintaining the same functionality.",
            },
            {
              role = "user",
              content = function()
                return "Optimize this code:\n\n```"
                  .. vim.bo.filetype
                  .. "\n"
                  .. require("codecompanion.helpers.actions").get_code()
                  .. "\n```\n\nReturn only the optimized code without explanations."
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
