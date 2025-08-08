return {

  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "folke/snacks.nvim",
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
          adapter = "llama_cpp", -- Changed to llama_cpp as default
        },
        inline = {
          adapter = "llama_cpp", -- Changed to llama_cpp as default
        },
        agent = {
          adapter = "llama_cpp", -- Changed to llama_cpp as default
        },
      },
      adapters = {
        -- Primary: Llama.cpp server adapter (now the default)
        llama_cpp = function()
          return require("codecompanion.adapters").extend("openai", {
            name = "qwen3_llamacpp",
            url = "http://localhost:8012/v1/chat/completions",
            api_key = "dummy",
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
          })
        end,

        -- Alternative: Custom MLX-LM adapter (kept for optional use)
        mlx = function()
          local openai = require("codecompanion.adapters.openai")

          ---@class MLX.Adapter: CodeCompanion.Adapter
          return {
            name = "mlx",
            formatted_name = "MLX-LM",
            roles = {
              llm = "assistant",
              user = "user",
            },
            opts = {
              stream = true,
              vision = false,
            },
            features = {
              text = true,
              tokens = true,
            },
            url = "http://localhost:8080/v1/chat/completions", -- Your working endpoint
            env = {
              api_key = "DUMMY", -- Not used but required by framework
            },
            headers = {
              ["Content-Type"] = "application/json",
            },
            handlers = {
              setup = function(self)
                if self.opts and self.opts.stream then
                  self.parameters.stream = true
                end
                return true
              end,
              --- Use the OpenAI adapter for the bulk of the work
              tokens = function(self, data)
                return openai.handlers.tokens(self, data)
              end,
              form_parameters = function(self, params, messages)
                return openai.handlers.form_parameters(self, params, messages)
              end,
              form_messages = function(self, messages)
                return openai.handlers.form_messages(self, messages)
              end,
              chat_output = function(self, data)
                return openai.handlers.chat_output(self, data)
              end,
              inline_output = function(self, data, context)
                return openai.handlers.inline_output(self, data, context)
              end,
              on_exit = function(self, data)
                return openai.handlers.on_exit(self, data)
              end,
            },
            schema = {
              ---@type CodeCompanion.Schema
              model = {
                order = 1,
                mapping = "parameters",
                type = "enum",
                desc = "MLX model to use for code completion and chat",
                -- default = "mlx-community/Qwen3-Coder-30B-A3B-Instruct-4bit",
                default = "lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-MLX-6bit",
                choices = {
                  -- "mlx-community/Qwen3-Coder-30B-A3B-Instruct-4bit",
                  "lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-MLX-6bit",
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
          }
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
          description = "Review code with Qwen3 Coder via llama.cpp",
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
          description = "Explain selected code with llama.cpp",
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
        ["Optimize Code"] = {
          strategy = "inline",
          description = "Optimize selected code for performance",
          opts = {
            index = 12,
          },
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
