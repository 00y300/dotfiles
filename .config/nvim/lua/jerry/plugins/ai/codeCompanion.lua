return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "folke/snacks.nvim",
    { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
  },

  config = function()
    local adapters = require("codecompanion.adapters")

    require("codecompanion").setup({
      ------------------------------------------------------------------
      -- MCP SERVERS (CORRECTED - CMD/STDIO only)
      ------------------------------------------------------------------
      mcp = {
        servers = {
          ["searxng"] = {
            cmd = { "npx", "-y", "mcp-searxng" },
            env = {
              SEARXNG_URL = "http://127.0.0.1:8888",
            },
          },
          ["nixos"] = {
            cmd = { "uvx", "mcp-nixos" },
          },
        },
        --[[ opts = {
          default_servers = { "searxng" },
        }, ]]
      },

      ------------------------------------------------------------------
      -- STRATEGIES (default → llama.cpp)
      ------------------------------------------------------------------
      strategies = {
        chat = { adapter = "llama.cpp" },
        inline = { adapter = "llama.cpp" },
        agent = { adapter = "llama.cpp" },
      },

      ------------------------------------------------------------------
      -- ADAPTERS (FIXED FOR QWEN3.5 + MCP SUPPORT)
      ------------------------------------------------------------------
      adapters = {
        http = {
          ["llama.cpp"] = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              env = {
                url = "http://localhost:8080", -- Your llama-swap URL
                api_key = "TERM", -- Or os.getenv "LLAMA_API_KEY" if you have one
                chat_url = "/v1/chat/completions",
              },
              handlers = {
                form_messages = function(self, messages)
                  local system_content = {}
                  local other_messages = {}

                  -- 1. Separate system messages from everything else
                  for _, msg in ipairs(messages) do
                    if msg.role == "system" then
                      table.insert(system_content, msg.content)
                    else
                      table.insert(other_messages, msg)
                    end
                  end

                  local final_messages = {}

                  -- 2. If there are system messages, merge them into ONE message at the top
                  if #system_content > 0 then
                    table.insert(final_messages, {
                      role = "system",
                      content = table.concat(system_content, "\n\n"),
                    })
                  end

                  -- 3. Append all the user/assistant messages
                  for _, msg in ipairs(other_messages) do
                    table.insert(final_messages, msg)
                  end

                  -- 4. Pass the cleaned messages to the standard OpenAI handler
                  local openai = require("codecompanion.adapters.http.openai")
                  return openai.handlers.form_messages(self, final_messages)
                end,
                parse_message_meta = function(self, data)
                  local extra = data.extra
                  if extra and extra.reasoning_content then
                    data.output.reasoning = { content = extra.reasoning_content }
                    if data.output.content == "" then
                      data.output.content = nil
                    end
                  end
                  return data
                end,
              },
            })
          end,
        },

        opts = {
          log_level = "ERROR",
          show_model_choices = true,
          send_code = true,
          use_default_actions = true,
          use_default_prompts = true,
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
          show_reasoning = true,
          reasoning_icon = "🧠", -- Try brain icon instead of 💭
          fold_reasoning = true,
        },
      },

      ------------------------------------------------------------------
      -- HIGHLIGHTS (Custom Colors)
      ------------------------------------------------------------------
    })
  end,

  event = "VeryLazy",
  keys = {
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion Actions" },
    { "<leader>aq", "<cmd>CodeCompanionChat adapter=llama.cpp model=code<cr>", desc = "Quick Chat" },
    { "<leader>av", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "CodeCompanion Add" },
    { "<leader>ai", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "CodeCompanion Inline" },
    { "<leader>acv", "<cmd>CodeCompanionChat adapter=llama.cpp model=vision<cr>", desc = "Chat: Llama Vision" },
    { "<leader>acg", "<cmd>CodeCompanionChat adapter=llama.cpp model=flash<cr>", desc = "Chat: Llama Flash" },
    { "<leader>aci", "<cmd>CodeCompanionChat adapter=llama.cpp model=instruct<cr>", desc = "Chat: Llama Instruct" },
    { "<leader>act", "<cmd>CodeCompanionChat adapter=llama.cpp model=thinking<cr>", desc = "Chat: Llama Thinking" },
    { "<leader>acc", "<cmd>CodeCompanionChat adapter=llama.cpp model=code<cr>", desc = "Chat: Llama Code" },
    { "<leader>acq", "<cmd>CodeCompanionChat adapter=llama.cpp model=qwen3.5<cr>", desc = "Chat: Qwen3.5" },
    {
      "<leader>acn",
      "<cmd>CodeCompanionChat adapter=llama.cpp model=nemotron-nano-30b<cr>",
      desc = "Chat: Llama Nvidia Nemo",
    },
  },
}
