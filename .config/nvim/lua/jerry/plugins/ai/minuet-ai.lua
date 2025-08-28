return {
  "milanglacier/minuet-ai.nvim",
  dependencies = { "rafamadriz/friendly-snippets" },
  config = function()
    require("minuet").setup({
      provider = "openai_fim_compatible",
      n_completions = 1,
      context_window = 512,
      provider_options = {
        openai_fim_compatible = {
          api_key = "TERM",
          name = "MLX (FIM)",
          end_point = "http://localhost:8080/v1/completions",
          model = "lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-MLX-6bit",
          stream = true,
          -- IMPORTANT: tell the model to *only* continue code
          system = "Continue the code from the cursor. Output ONLY the code continuation with no backticks, no language fences, no preamble, no comments, no explanations.",
          few_shots = nil,
          chat_input = nil,
          optional = {
            stop = { "<|endoftext|>", "\n\n", "\nimport ", "\nfrom " },
            max_tokens = 64,
            top_p = 0.9,
            temperature = 0.0,
          },
          system = "Continue this code exactly where the cursor is. Do not repeat imports or existing lines. Only write the next logical lines of code.",
          template = {
            prompt = function(before, after, _)
              return "<|fim_prefix|>" .. before .. "<|fim_suffix|>" .. after .. "<|fim_middle|>"
            end,
            suffix = false,
          },
          template = {
            -- classic FIM: prefix/suffix/middle
            prompt = function(before, after, _)
              return "<|fim_prefix|>" .. before .. "<|fim_suffix|>" .. after .. "<|fim_middle|>"
            end,
            suffix = false,
          },
        },

        -- If your MLX build has /v1/chat/completions working, you can switch to it for
        -- chat-style editing (usually reduces weird token leaks). Keep FIM as default.
        openai_compatible = {
          api_key = "TERM",
          name = "MLX (Chat)",
          end_point = "http://localhost:8080/v1/chat/completions",
          model = "lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-MLX-6bit",
          stream = true,
          system = "You are a code completion engine. Return ONLY the code continuation. Do not include backticks or fences.",
          few_shots = nil,
          chat_input = nil,
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

    vim.keymap.set("n", "<leader>amf", function()
      require("minuet").change_provider("openai_fim_compatible")
    end, { desc = "Minuet → MLX FIM (/v1/completions)" })

    vim.keymap.set("n", "<leader>amo", ":Minuet cmp disable<cr>", { silent = true, desc = "Turn off Minuet" })

    vim.keymap.set("n", "<leader>amc", function()
      require("minuet").change_provider("openai_compatible")
    end, { desc = "Minuet → MLX Chat (/v1/chat/completions)" })
  end,
}
