return {
  "milanglacier/minuet-ai.nvim",
  dependencies = { "rafamadriz/friendly-snippets" },
  config = function()
    require("minuet").setup({
      provider = "openai_compatible",
      n_completions = 1,
      context_window = 512,
      provider_options = {
        -- Qwen3.5 via llama-swap (Chat)
        openai_compatible = {
          api_key = function()
            return os.getenv("TERM") or "dummy"
          end,
          name = "Qwen3.5 (llama-swap)",
          end_point = "http://localhost:8080/v1/chat/completions",
          model = "qwen3.5",
          stream = false,
          optional = {
            max_tokens = 64,
            temperature = 0.7,
            top_p = 0.8,
          },
        },
      },
    })

    -- Keymaps
    vim.keymap.set("n", "<leader>amq", function()
      require("minuet").change_provider("openai_compatible")
    end, { desc = "Minuet → Qwen3.5 (Chat)" })
    vim.keymap.set("n", "<leader>amo", ":Minuet cmp disable<cr>", {
      silent = true,
      desc = "Turn off Minuet",
    })
  end,
}
