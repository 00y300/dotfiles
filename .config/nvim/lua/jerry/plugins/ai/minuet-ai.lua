return {
  "milanglacier/minuet-ai.nvim",
  dependencies = { "rafamadriz/friendly-snippets" },
  config = function()
    require("minuet").setup({
      provider = "openai_fim_compatible", -- default provider
      n_completions = 1,
      context_window = 512,
      provider_options = {
        -- Qwen3 Coder via llama-swap (FIM)
        openai_fim_compatible = {
          api_key = "TERM",
          name = "Qwen3 Coder (llama-swap)",
          end_point = "http://localhost:8080/v1/completions",
          model = "code", -- Using the alias
          optional = {
            max_tokens = 56,
            top_p = 0.8,
            temperature = 0.7,
          },
          template = {
            prompt = function(before, after)
              return "<|fim_prefix|>" .. before .. "<|fim_suffix|>" .. after .. "<|fim_middle|>"
            end,
            suffix = false,
          },
        },
        -- Qwen3 Instruct via llama-swap (Chat) - uses openai_compatible
        openai_compatible = {
          api_key = "TERM",
          name = "Qwen3 Instruct (llama-swap)",
          end_point = "http://localhost:8080/v1/chat/completions",
          model = "chat", -- Using the alias
          stream = false,
          optional = {
            max_tokens = 64,
            temperature = 0.7,
            top_p = 0.8,
          },
        },
        -- Qwen3 Coder full model name (backup FIM)
        openai_fim_compatible_qwen3 = {
          api_key = "TERM",
          name = "Qwen3 Coder Full (llama-swap)",
          end_point = "http://localhost:8080/v1/completions",
          model = "qwen3-coder-30b", -- Full model name
          optional = {
            max_tokens = 56,
            top_p = 0.8,
            temperature = 0.7,
          },
          template = {
            prompt = function(before, after)
              return "<|fim_prefix|>" .. before .. "<|fim_suffix|>" .. after .. "<|fim_middle|>"
            end,
            suffix = false,
          },
        },
      },
    })

    -- Keymaps
    vim.keymap.set("n", "<leader>amc", function()
      require("minuet").change_provider("openai_fim_compatible")
    end, { desc = "Minuet → Qwen3 Coder (FIM alias)" })

    vim.keymap.set("n", "<leader>amf", function()
      require("minuet").change_provider("openai_fim_compatible_qwen3")
    end, { desc = "Minuet → Qwen3 Coder (FIM full name)" })

    vim.keymap.set("n", "<leader>ami", function()
      require("minuet").change_provider("openai_compatible")
    end, { desc = "Minuet → Qwen3 Instruct (Chat)" })

    vim.keymap.set("n", "<leader>amo", ":Minuet cmp disable<cr>", {
      silent = true,
      desc = "Turn off Minuet",
    })
  end,
}
