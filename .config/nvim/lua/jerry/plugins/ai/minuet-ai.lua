return {
  "milanglacier/minuet-ai.nvim",
  dependencies = { "rafamadriz/friendly-snippets" },
  config = function()
    require("minuet").setup({
      provider = "openai_fim_compatible", -- Default provider
      n_completions = 1,
      context_window = 512,
      provider_options = {
        -- Primary: Llama.cpp server with Qwen3-Coder-30B-A3B (FIM)
        openai_fim_compatible = {
          api_key = "TERM",
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

        -- Secondary: Regular Qwen3 (FIM)
        openai_fim_compatible_qwen3 = {
          api_key = "TERM",
          name = "Qwen-3 Coder",
          end_point = "http://localhost:8013/v1/completions",
          model = "qwen3-coder",
          optional = {
            max_tokens = 56,
            top_p = 0.9,
            temperature = 0.2,
          },
          template = {
            prompt = function(before, after, _)
              return "<|fim_prefix|>" .. before .. "<|fim_suffix|>" .. after .. "<|fim_middle|>"
            end,
            suffix = false,
          },
        },

        -- NVIDIA NeMo (Chat → inline completion)
        openai_compatible_nemo = {
          api_key = "TERM",
          name = "NVIDIA NeMo",
          end_point = "http://localhost:8000/v1/chat/completions",
          model = "nvidia/nemotron-4-340b-instruct",
          stream = false,
          optional = {
            max_tokens = 64,
            top_p = 0.9,
            temperature = 0.2,
          },
          template = {
            prompt = function(messages)
              local output = {}

              -- Always start with empty system block
              table.insert(output, "<|im_start|>system\n<|im_end|>")

              for i, msg in ipairs(messages) do
                local is_last = (i == #messages)

                if msg.role == "user" then
                  table.insert(output, "<|im_start|>user\n" .. msg.content .. "<|im_end|>")
                elseif msg.role == "assistant" then
                  table.insert(output, "<|im_start|>assistant\n" .. (msg.content or "") .. "<|im_end|>")
                end

                -- If last message is user, open assistant + think tag
                if is_last and msg.role == "user" then
                  table.insert(output, "<|im_start|>assistant\n<think>")
                end
              end

              return table.concat(output, "\n")
            end,
            suffix = false,
          },
        },
      },
    })

    -- Keymaps
    vim.keymap.set("n", "<leader>ami", function()
      require("minuet").change_provider("openai_fim_compatible")
    end, { desc = "Minuet → Llama.cpp FIM (A3B)" })

    vim.keymap.set("n", "<leader>amc", function()
      require("minuet").change_provider("openai_fim_compatible_qwen3")
    end, { desc = "Minuet → Qwen3 FIM" })

    vim.keymap.set("n", "<leader>amn", function()
      require("minuet").change_provider("openai_compatible_nemo")
    end, { desc = "Minuet → NVIDIA NeMo" })

    vim.keymap.set("n", "<leader>amo", ":Minuet cmp disable<cr>", { silent = true, desc = "Turn off Minuet" })
  end,
}
