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
          name = "Llama.cpp (Qwen3-A3B)",
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
        -- Alternative: MLX-LM server (Chat, uses new template)
        openai_compatible = {
          api_key = "TERM",
          name = "MLX (Chat)",
          end_point = "http://localhost:8080/v1/chat/completions",
          model = "lmstudio-community/Qwen3-Coder-30B-A3B-Instruct-MLX-6bit",
          stream = true,
          optional = {
            stop = { "<|endoftext|>", "```", "\n```", "\r\n```" },
            max_tokens = 96,
            top_p = 0.9,
            temperature = 0.2,
          },
          template = {
            prompt = function(messages)
              -- Implements your custom chat template
              local output = {}
              local last_user_idx = -1
              for i, msg in ipairs(messages) do
                if msg.role == "user" then
                  last_user_idx = i
                end
              end

              -- System & Tools
              if messages.system or messages.tools then
                table.insert(output, "<|im_start|>system")
                if messages.system then
                  table.insert(output, messages.system)
                end
                if messages.tools then
                  table.insert(
                    output,
                    "\n# Tools\n\nYou may call one or more functions to assist with the user query.\n\nYou are provided with function signatures within <tools></tools> XML tags:\n<tools>"
                  )
                  for _, tool in ipairs(messages.tools) do
                    table.insert(output, string.format('{"type": "function", "function": %s}', tool.function_def))
                  end
                  table.insert(
                    output,
                    '</tools>\n\nFor each function call, return a json object with function name and arguments within <tool_call></tool_call> XML tags:\n<tool_call>\n{"name": <function-name>, "arguments": <args-json-object>}\n</tool_call>'
                  )
                end
                table.insert(output, "<|im_end|>")
              end

              -- Conversation messages
              for i, msg in ipairs(messages) do
                local is_last = (i == #messages)
                if msg.role == "user" then
                  table.insert(output, "<|im_start|>user\n" .. msg.content .. "<|im_end|>")
                elseif msg.role == "assistant" then
                  table.insert(output, "<|im_start|>assistant\n" .. (msg.content or ""))
                  if not is_last then
                    table.insert(output, "<|im_end|>")
                  end
                elseif msg.role == "tool" then
                  table.insert(
                    output,
                    "<|im_start|>user\n<tool_response>\n" .. msg.content .. "\n</tool_response><|im_end|>"
                  )
                end
                if msg.role ~= "assistant" and is_last then
                  table.insert(output, "<|im_start|>assistant")
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

    --[[ vim.keymap.set("n", "<leader>amx", function()
      require("minuet").change_provider("openai_compatible")
    end, { desc = "Minuet → MLX Chat" }) ]]

    vim.keymap.set("n", "<leader>amo", ":Minuet cmp disable<cr>", { silent = true, desc = "Turn off Minuet" })
  end,
}
