return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  dependencies = {
    "folke/snacks.nvim",
  },
  opts = {
    legacy_commands = false,

    picker = {
      name = "snacks.pick",
    },

    -- Use the title you type as the filename (e.g. "test" -> test.md)
    note_id_func = function(title)
      if title ~= nil and title ~= "" then
        return title:gsub(" ", "-"):gsub("[^A-Za-z0-9%-_]", "")
      else
        local suffix = ""
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
        return tostring(os.time()) .. "-" .. suffix
      end
    end,

    -- Customize frontmatter: date, time, tags (in that order)
    frontmatter = {
      enabled = true,
      sort = function(a, b)
        local order = { date = 1, time = 2, tags = 3 }
        local function key_of(x)
          if type(x) == "table" then
            return x[1]
          end
          return x
        end
        local ai = order[key_of(a)] or 99
        local bi = order[key_of(b)] or 99
        return ai < bi
      end,
      func = function(note)
        local tags = (note.tags and #note.tags > 0) and note.tags or vim.NIL
        local out = {
          date = os.date("%m-%d-%Y"),
          time = os.date("%I:%M %p"),
          tags = tags,
        }
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end
        return out
      end,
    },

    callbacks = {
      -- Auto-insert "# <title>" as the first body line on newly created notes
      enter_note = function(note)
        local bufnr = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

        local fm_boundaries = 0
        local has_body = false
        for _, line in ipairs(lines) do
          if line == "---" then
            fm_boundaries = fm_boundaries + 1
          elseif fm_boundaries >= 2 and line:match("%S") then
            has_body = true
            break
          end
        end

        if not has_body and note and note.title then
          vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "# " .. note.title, "" })
          vim.cmd("silent! write")
        end
      end,

      -- Fallback ordering enforcer: rewrites frontmatter block in date/time/tags order
      -- after the note is saved. Harmless if `sort` already handled it correctly.
      post_write_note = function(note)
        local bufnr = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        if lines[1] ~= "---" then
          return
        end

        local fm_end = nil
        for i = 2, #lines do
          if lines[i] == "---" then
            fm_end = i
            break
          end
        end
        if not fm_end then
          return
        end

        local fields = {}
        for i = 2, fm_end - 1 do
          local key, val = lines[i]:match("^([%w_]+):%s*(.*)$")
          if key then
            fields[key] = val
          end
        end

        if not (fields.date and fields.time) then
          return
        end

        local tag_line = "tags:"
        if fields.tags and fields.tags ~= "" then
          tag_line = "tags: " .. fields.tags
        end

        local new_fm = {
          "---",
          "date: " .. (fields.date or ""),
          "time: " .. (fields.time or ""),
          tag_line,
          "---",
        }

        local needs_rewrite = false
        for i, line in ipairs(new_fm) do
          if lines[i] ~= line then
            needs_rewrite = true
            break
          end
        end
        if not needs_rewrite then
          return
        end

        vim.api.nvim_buf_set_lines(bufnr, 0, fm_end, false, new_fm)
        vim.cmd("silent! write")
      end,
    },

    workspaces = {
      {
        name = "ZK",
        path = "~/Documents/ZK/",
        overrides = {
          notes_subdir = "/Inbox/",
          templates = {
            folder = "/Templates/",
            date_format = "%m-%d-%Y",
            time_format = "%I:%M %p",
          },
          daily_notes = {
            folder = "/Journal",
            date_format = "%m-%d-%Y",
            alias_format = "%B %-d, %Y",
          },
        },
      },
    },
  },

  keys = {
    { "<leader>o", "", desc = "+Obsidian" },
    { "<leader>ol", "<cmd>Obsidian link<CR>", desc = "Create Link (Obsidian)" },
    { "<leader>oO", "<cmd>Obsidian open<CR>", desc = "Open Obsidian" },
    { "<leader>of", "<cmd>Obsidian follow_link<CR>", desc = "Follow Link (Obsidian)" },
    { "<leader>on", "<cmd>Obsidian new_from_template<CR>", desc = "Create New Note (Obsidian)" },
    { "<leader>ot", "<cmd>Obsidian tags<CR>", desc = "See Tags" },
    { "<leader>ott", "<cmd>Obsidian template<CR>", desc = "Applies Template to Note" },
    { "<leader>oy", "<cmd>Obsidian yesterday<CR>", desc = "Open Yesterday's Note (Obsidian)" },
    { "<leader>os", "<cmd>Obsidian search<CR>", desc = "Search Notes (Obsidian)" },
    { "<leader>ob", "<cmd>Obsidian backlinks<CR>", desc = "Show Backlinks (Obsidian)" },
    { "<leader>ow", "<cmd>Obsidian workspace<CR>", desc = "Switch Workspace (Obsidian)" },
    {
      "<leader>oz",
      function()
        local filepath = vim.fn.expand("%:p")
        local filename = vim.fn.expand("%:t")
        local target_dir = vim.fn.expand("~/Documents/ZK/Zettelkasten/")
        local target_path = target_dir .. filename

        if vim.fn.isdirectory(target_dir) == 0 then
          vim.fn.mkdir(target_dir, "p")
        end

        if vim.fn.filereadable(filepath) == 1 then
          local success, err = os.rename(filepath, target_path)
          if success then
            print("Moved " .. filename .. " to " .. target_dir)
            vim.cmd("edit " .. target_path)
          else
            print("Error moving file: " .. (err or "unknown error"))
          end
        else
          print("Error: File does not exist or is not readable.")
        end
      end,
      desc = "Move current file to ZK folder",
    },
  },
}
