return {
  "milanglacier/minuet-ai.nvim",
  dependencies = { "rafamadriz/friendly-snippets" },
  config = function()
    require("minuet").setup({
      provider = "openai_fim_compatible", -- Default provider
      -- provider = "openai_compatible",
      n_completions = 1,
      context_window = 512,
      provider_options = {
        -- Primary: Llama.cpp server (default)
        openai_fim_compatible = {
          api_key = "TERM", -- Or APPDATA for Windows
          name = "Llama.cpp",
          end_point = "http://localhost:8012/v1/completions",
          model = "Qwen3-Coder-30B-A3B-Instruct-UD-Q5_K_XL.gguf",
          optional = {
            max_tokens = 56,
            top_p = 0.9,
          },
          template = {
            prompt = function(before, after, _)
              return "<|fim_prefix|>" .. before .. "<|fim_suffix|>" .. after .. "<|fim_middle|>"
            end,
            suffix = false,
          },
        },
        -- Alternative: MLX-LM server
        openai_compatible = {
          api_key = "TERM",
          name = "MLX (Chat)",
          end_point = "http://localhost:8080/v1/chat/completions",
          model = "lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-MLX-6bit",
          stream = true,
          system = "You are a code completion engine. Return ONLY the code continuation. Do not include backticks or fences.",
          optional = {
            stop = { "<|endoftext|>", "```", "\n```", "\r\n```" },
            max_tokens = 96,
            top_p = 0.9,
            temperature = 0.2,
          },
          template = {
            prompt = function(before, after, _)
              return {
                {
                  role = "system",
                  content = "You are a code completion engine. Return ONLY the code continuation. Do not include backticks or fences.",
                },
                { role = "user", content = before .. after },
              }
            end,
            suffix = false,
          },
        },
      },
    })

    -- Keymaps
    vim.keymap.set("n", "<leader>amf", function()
      require("minuet").change_provider("openai_fim_compatible")
    end, { desc = "Minuet → MLX FIM (/v1/completions)" })

    vim.keymap.set("n", "<leader>amo", ":Minuet cmp disable<cr>", { silent = true, desc = "Turn off Minuet" })

    vim.keymap.set("n", "<leader>amc", function()
      require("minuet").change_provider("openai_compatible")
    end, { desc = "Minuet → MLX Chat (/v1/chat/completions)" })
  end,
}
