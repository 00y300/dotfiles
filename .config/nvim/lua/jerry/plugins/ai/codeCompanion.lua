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
  },

  config = function()
    local adapters = require("codecompanion.adapters")

    require("codecompanion").setup({

      ------------------------------------------------------------------
      -- STRATEGIES (default → llama-swap)
      ------------------------------------------------------------------
      strategies = {
        chat = { adapter = "llama_swap" },
        inline = { adapter = "llama_swap" },
        agent = { adapter = "llama_swap" },
      },

      ------------------------------------------------------------------
      -- ADAPTERS
      ------------------------------------------------------------------
      adapters = {
        http = {

          --------------------------------------------------------------
          -- LLAMA-SWAP (ALIASES, LIKE MINUET)
          --------------------------------------------------------------
          llama_swap = adapters.extend("openai", {
            name = "llama_swap",
            formatted_name = "llama-swap",
            url = "http://localhost:8080/v1/chat/completions",
            api_key = "TERM",

            opts = {
              stream = true,
              vision = true,
            },

            features = {
              text = true,
              tokens = true,
              vision = true,
            },

            schema = {
              model = {
                order = 1,
                mapping = "parameters",
                type = "enum",
                desc = "llama-swap model alias",
                default = "chat",
                choices = {
                  "instruct", -- qwen3-30b-instruct
                  "code", -- qwen3-coder-30b
                  "thinking", -- qwen3-30b-thinking
                  "vision", -- qwen3-vl-32b
                  "nemotron-nano-30b",
                },
              },
              temperature = {
                order = 2,
                mapping = "parameters",
                type = "number",
                default = 0.7,
              },
              top_p = {
                order = 3,
                mapping = "parameters",
                type = "number",
                default = 0.8,
              },
              max_tokens = {
                order = 4,
                mapping = "parameters",
                type = "number",
                default = 4096,
              },
            },
          }),

          -- --------------------------------------------------------------
          -- -- NVIDIA NEMO (EXPLICIT, NOT DEFAULT)
          -- --------------------------------------------------------------
          -- nvidia_nemo = adapters.extend("openai", {
          --   name = "nvidia_nemo",
          --   formatted_name = "NVIDIA NeMo",
          --   url = "http://localhost:8012/v1/chat/completions",
          --   api_key = "DUMMY",
          --
          --   opts = { stream = true },
          --
          --   schema = {
          --     model = {
          --       order = 1,
          --       mapping = "parameters",
          --       type = "enum",
          --       default = "nvidia/nemotron-4-340b-instruct",
          --       choices = {
          --         "nvidia/nemotron-4-340b-instruct",
          --         "nvidia/nemotron-mini-4b-instruct",
          --       },
          --     },
          --     temperature = {
          --       order = 2,
          --       mapping = "parameters",
          --       type = "number",
          --       default = 0.6,
          --     },
          --     max_tokens = {
          --       order = 3,
          --       mapping = "parameters",
          --       type = "number",
          --       default = 4096,
          --     },
          --   },
          -- }),

          --------------------------------------------------------------
          -- GLOBAL HTTP OPTIONS
          --------------------------------------------------------------
          opts = {
            log_level = "ERROR",
            show_model_choices = true,
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
    })
  end,

  event = "VeryLazy",
  keys = {
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion Actions" },
    { "<leader>ac", "<qcmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "CodeCompanion Chat" },
    { "<leader>av", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "CodeCompanion Add" },
    { "<leader>ai", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "CodeCompanion Inline" },

    { "<leader>acv", "<cmd>CodeCompanionChat adapter=llama_swap model=vision<cr>", desc = "Chat: Llama Vision" },
    { "<leader>aci", "<cmd>CodeCompanionChat adapter=llama_swap model=instruct<cr>", desc = "Chat: Llama Vision" },
    { "<leader>act", "<cmd>CodeCompanionChat adapter=llama_swap model=thinking<cr>", desc = "Chat: Llama Thinking" },
    { "<leader>acc", "<cmd>CodeCompanionChat adapter=llama_swap model=code<cr>", desc = "Chat: Llama Code" },
    {
      "<leader>acn",
      "<cmd>CodeCompanionChat adapter=llama_swap model=nemotron-nano-30b<cr>",
      desc = "Chat: Llama Code",
    },
  },
}
