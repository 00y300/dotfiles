return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "folke/snacks.nvim",
    { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
  },

  config = function()
    require("codecompanion").setup({
      ------------------------------------------------------------------
      -- TOP-LEVEL OPTIONS
      ------------------------------------------------------------------
      log_level = "ERROR",
      send_code = true,
      use_default_actions = true,
      use_default_prompts = true,

      ------------------------------------------------------------------
      -- MCP SERVERS
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
          ["esp-idf"] = {
            cmd = { "idf.py", "mcp-server" },
            env = {
              IDF_MCP_WORKSPACE_FOLDER = vim.fn.getcwd(),
            },
          },
        },
      },

      ------------------------------------------------------------------
      -- INTERACTIONS
      -- Change the model value here to switch what inline/chat/cmd use.
      ------------------------------------------------------------------
      interactions = {
        chat = {
          adapter = { name = "llamacpp", model = "qwen3.5" },
        },
        inline = {
          -- Change this model value to switch the inline assistant model
          adapter = { name = "llamacpp", model = "qwen3.5" },
        },
        cmd = {
          adapter = { name = "llamacpp", model = "qwen3.5" },
        },
      },

      ------------------------------------------------------------------
      -- ADAPTERS
      -- NOTE: No `default` in schema.model so the interaction-level
      -- model setting is what actually controls model selection.
      ------------------------------------------------------------------
      adapters = {
        http = {
          ["llamacpp"] = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              env = {
                url = "http://localhost:8080",
                api_key = "TERM",
                chat_url = "/v1/chat/completions",
              },
              schema = {
                model = {
                  choices = {
                    "qwen3.5",
                    "qwen3-vl-32b",
                    "qwen3-coder-30b",
                    "qwen3-30b-instruct",
                    "qwen3-30b-thinking",
                    "nemotron-nano-30b",
                    "glm-4-7-flash",
                    -- aliases
                    "code",
                    "coder",
                    "vision",
                    "flash",
                    "thinking",
                    "instruct",
                    "chat",
                    "nano",
                    "nemotron",
                  },
                },
              },
              handlers = {
                form_messages = function(self, messages)
                  local system_content = {}
                  local other_messages = {}

                  for _, msg in ipairs(messages) do
                    if msg.role == "system" then
                      table.insert(system_content, msg.content)
                    else
                      table.insert(other_messages, msg)
                    end
                  end

                  local final_messages = {}

                  if #system_content > 0 then
                    table.insert(final_messages, {
                      role = "system",
                      content = table.concat(system_content, "\n\n"),
                    })
                  end

                  for _, msg in ipairs(other_messages) do
                    table.insert(final_messages, msg)
                  end

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

          opts = {
            show_model_choices = true,
          },
        },
      },

      ------------------------------------------------------------------
      -- DISPLAY
      ------------------------------------------------------------------
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
          reasoning_icon = "🧠",
          fold_reasoning = true,
        },
      },
    })

    --------------------------------------------------------------------------
    -- FIX: Patch show_diff for C++ (and similar) filetype bug
    -- Treesitter reports "C++" but nvim_set_option_value expects "cpp".
    -- show_diff(args) passes args.ft directly to nvim_set_option_value.
    -- We intercept and resolve the real vim filetype from args.bufnr.
    -- See: https://github.com/olimorris/codecompanion.nvim/issues/531
    --------------------------------------------------------------------------
    local ok, helpers = pcall(require, "codecompanion.helpers")
    if ok and helpers and helpers.show_diff then
      local original_show_diff = helpers.show_diff
      helpers.show_diff = function(args)
        if args and args.ft and args.bufnr then
          local fok, real_ft = pcall(vim.api.nvim_get_option_value, "filetype", { buf = args.bufnr })
          if fok and real_ft and real_ft ~= "" then
            args.ft = real_ft
          end
        end
        return original_show_diff(args)
      end
    end
  end,

  event = "VeryLazy",
  keys = {
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion Actions" },
    { "<leader>aq", "<cmd>CodeCompanionChat adapter=llamacpp model=code<cr>", desc = "Quick Chat" },
    { "<leader>av", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "CodeCompanion Add" },
    { "<leader>ai", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "CodeCompanion Inline" },
    { "<leader>acv", "<cmd>CodeCompanionChat adapter=llamacpp model=vision<cr>", desc = "Chat: Llama Vision" },
    { "<leader>acg", "<cmd>CodeCompanionChat adapter=llamacpp model=flash<cr>", desc = "Chat: Llama Flash" },
    { "<leader>aci", "<cmd>CodeCompanionChat adapter=llamacpp model=instruct<cr>", desc = "Chat: Llama Instruct" },
    { "<leader>act", "<cmd>CodeCompanionChat adapter=llamacpp model=thinking<cr>", desc = "Chat: Llama Thinking" },
    { "<leader>acc", "<cmd>CodeCompanionChat adapter=llamacpp model=code<cr>", desc = "Chat: Llama Code" },
    { "<leader>acq", "<cmd>CodeCompanionChat adapter=llamacpp model=qwen3.5<cr>", desc = "Chat: Qwen3.5" },
    {
      "<leader>acn",
      "<cmd>CodeCompanionChat adapter=llamacpp model=nemotron-nano-30b<cr>",
      desc = "Chat: Llama Nvidia Nemo",
    },
  },
}
