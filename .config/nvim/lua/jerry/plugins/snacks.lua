return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  config = function()
    local snacks = require("snacks")

    snacks.setup({
      bigfile = { enabled = true },
      dashboard = { enabled = false },
      explorer = { enabled = true },
      indent = { enabled = true },
      image = {
        enabled = true,
        formats = {
          "png",
          "jpg",
          "jpeg",
          "gif",
          "bmp",
          "webp",
          "tiff",
          "heic",
          "avif",
          "mp4",
          "mov",
          "avi",
          "mkv",
          "webm",
          -- "pdf",
        },
        doc = {
          -- enable image viewer for documents
          -- a treesitter parser must be available for the enabled languages.
          enabled = true,
          -- render the image inline in the buffer
          -- if your env doesn't support unicode placeholders, this will be disabled
          -- takes precedence over `opts.float` on supported terminals
          inline = true,
          -- render the image in a floating window
          -- only used if `opts.inline` is disabled
          float = false,
          max_width = 80,
          max_height = 40,
          -- Set to `true`, to conceal the image text when rendering inline.
          -- (experimental)
          ---@param lang string tree-sitter language
          ---@param type snacks.image.Type image type
          conceal = function(lang, type)
            -- only conceal math expressions
            return type == "math"
          end,
        },
        img_dirs = { "img", "images", "assets", "static", "public", "media", "attachments" },
      },
      input = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      picker = {
        enabled = true,
        sources = {
          files = {
            hidden = true,
          },
          explorer = {
            hidden = true,
            ignored = true,
            win = {
              list = {
                wo = {
                  number = true,
                  relativenumber = true,
                },
              },
            },
          },
          buffers = {
            hidden = true,
            win = {
              input = {
                keys = {
                  ["<c-d>"] = { "bufdelete", mode = { "n", "i" } },
                },
              },
            },
          },
        },
      },
      quickfile = { enabled = true },
      scope = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      styles = {
        notification = {
          -- wo = { wrap = true } -- Wrap notifications
        },
      },
    })
  end,
  keys = {
    -- Top Pickers & Explorer
    {
      "<leader>:",
      function()
        Snacks.picker.command_history()
      end,
      desc = "Command History",
    },
    {
      "<leader>n",
      function()
        Snacks.picker.notifications()
      end,
      desc = "Notification History",
    },
    {
      "<leader>e",
      function()
        Snacks.explorer()
      end,
      desc = "File Explorer",
    },
    -- find
    {
      "<leader>fb",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Buffers",
    },
    {
      "<leader>fc",
      function()
        Snacks.picker.files({
          cwd = vim.fn.stdpath("config"),
          exclude = { "node_modules", ".next/*", ".git/*", "lib/python3%..*/.*", ".cargo", "target/" },
          hidden = true,
          ignored = false,
        })
      end,
      desc = "Find Config File",
    },
    {
      "<leader>ff",
      function()
        Snacks.picker.files({

          exclude = { "node_modules", ".next/*", ".git/*", "lib/python3%..*/.*", ".cargo", "target/" },
          hidden = true,
          ignored = true,
        })
      end,
      desc = "Find Files",
    },
    {
      "<leader>fb",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Find Buffers",
    },

    {
      "<leader>fg",
      function()
        Snacks.picker.git_files()
      end,
      desc = "Find Git Files",
    },
    {
      "<leader>fp",
      function()
        Snacks.picker.projects()
      end,
      desc = "Projects",
    },
    {
      "<leader>fr",
      function()
        Snacks.picker.recent()
      end,
      desc = "Recent",
    },
    {
      "<leader>fs",
      function()
        Snacks.picker.grep()
      end,
      desc = "Find String",
    },

    -- git
    {
      "<leader>gb",
      function()
        Snacks.picker.git_branches()
      end,
      desc = "Git Branches",
    },
    {
      "<leader>gl",
      function()
        Snacks.picker.git_log()
      end,
      desc = "Git Log",
    },
    {
      "<leader>gL",
      function()
        Snacks.picker.git_log_line()
      end,
      desc = "Git Log Line",
    },
    {
      "<leader>gs",
      function()
        Snacks.picker.git_status()
      end,
      desc = "Git Status",
    },
    {
      "<leader>gS",
      function()
        Snacks.picker.git_stash()
      end,
      desc = "Git Stash",
    },
    {
      "<leader>gd",
      function()
        Snacks.picker.git_diff()
      end,
      desc = "Git Diff (Hunks)",
    },
    {
      "<leader>gf",
      function()
        Snacks.picker.git_log_file()
      end,
      desc = "Git Log File",
    },
    -- Add the git files using custom function
    {
      "<leader>gF",
      function()
        local snacks = require("snacks")
        snacks.picker.git_files({
          cwd = vim.env.GIT_WORK_TREE or snacks.git.get_root(),
        })
      end,
      desc = "Git Files",
    },
    -- Pick and switch to a git worktree
    {
      "<leader>gw",
      function()
        -- Get list of worktrees using git command
        local output = vim.fn.system("git worktree list")
        if vim.v.shell_error ~= 0 then
          print("Error: Not in a git repository or no worktrees found")
          return
        end

        local worktrees = {}
        for line in output:gmatch("[^\r\n]+") do
          if line and line ~= "" then
            -- Parse each line: /path/to/worktree  branch_name  [commit_hash]
            local path = line:match("^([^%s]+)")
            if path then
              table.insert(worktrees, {
                path = path,
                display = line,
              })
            end
          end
        end

        if #worktrees == 0 then
          print("No git worktrees found")
          return
        end

        -- Get current directory for comparison
        local prev_path = vim.fn.getcwd()

        -- Use vim.ui.select as a fallback
        local items = {}
        for _, wt in ipairs(worktrees) do
          table.insert(items, wt.display)
        end

        vim.ui.select(items, {
          prompt = "Select Git Worktree:",
        }, function(choice, idx)
          if choice and idx then
            local selected = worktrees[idx]
            local new_path = selected.path

            -- Don't switch if already in the selected worktree
            if new_path == prev_path then
              print("Already in worktree: " .. new_path)
              return
            end

            -- Change directory
            vim.cmd("cd " .. vim.fn.fnameescape(new_path))

            -- Hook: Notify about the switch
            vim.notify("Moved from " .. prev_path .. " to " .. new_path)

            -- Hook: Update current buffer (similar to git-worktree's update_current_buffer_on_switch)
            local current_buf = vim.api.nvim_get_current_buf()
            local current_file = vim.api.nvim_buf_get_name(current_buf)

            if current_file and current_file ~= "" then
              -- Try to find equivalent file in new worktree
              local relative_path = current_file:gsub("^" .. vim.pesc(prev_path), "")
              local new_file_path = new_path .. relative_path

              -- Check if the file exists in the new worktree
              if vim.fn.filereadable(new_file_path) == 1 then
                vim.cmd("edit " .. vim.fn.fnameescape(new_file_path))
              else
                -- File doesn't exist in new worktree, just close current buffer
                -- and let user navigate to files in new worktree
                vim.cmd("enew")
              end
            end

            -- Hook: Refresh file explorer if available
            --[[ if vim.fn.exists(":NvimTreeRefresh") == 2 then
              vim.cmd("NvimTreeRefresh")
            end ]]

            -- Hook: Update any other buffers/windows as needed
            -- You can add more custom logic here

            print("Switched to worktree: " .. new_path)
          end
        end)
      end,
      desc = "Switch Git Worktree",
    },
    -- Add Git Worktree
    {
      "<leader>gwa",
      function()
        -- Get list of worktrees using git command
        local output = vim.fn.system("git worktree list")
        if vim.v.shell_error ~= 0 then
          vim.notify("Error: Not in a git repository or no worktrees found", vim.log.levels.ERROR)
          return
        end

        -- Check if we're in a git repository
        local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "")
        if vim.v.shell_error ~= 0 then
          vim.notify("Error: Not in a git repository", vim.log.levels.ERROR)
          return
        end

        -- Get available branches (local and remote)
        local branches_output = vim.fn.system("git branch -a --format='%(refname:short)'")
        if vim.v.shell_error ~= 0 then
          vim.notify("Error: Failed to get git branches", vim.log.levels.ERROR)
          return
        end

        local branches = {}
        for line in branches_output:gmatch("[^\r\n]+") do
          if line and line ~= "" and not line:match("HEAD") then
            -- Clean up remote branch names
            local branch = line:gsub("^origin/", "")
            if not vim.tbl_contains(branches, branch) then
              table.insert(branches, branch)
            end
          end
        end

        -- Add option to create new branch
        table.insert(branches, 1, "[Create new branch]")

        vim.ui.select(branches, {
          prompt = "Select branch for new worktree:",
        }, function(choice)
          if not choice then
            return
          end

          local branch_name = choice
          local is_new_branch = choice == "[Create new branch]"

          if is_new_branch then
            vim.ui.input({
              prompt = "New branch name: ",
            }, function(input)
              if not input or input == "" then
                return
              end
              branch_name = input
              -- Default path suggestion
              local default_path = vim.fn.expand("~") .. "/worktrees/" .. branch_name

              vim.ui.input({
                prompt = "Worktree path: ",
                default = default_path,
              }, function(path)
                if not path or path == "" then
                  return
                end

                -- Expand path
                path = vim.fn.expand(path)

                -- Create the worktree
                local cmd =
                  string.format("git worktree add -b %s %s", vim.fn.shellescape(branch_name), vim.fn.shellescape(path))
                local create_output = vim.fn.system(cmd)
                if vim.v.shell_error == 0 then
                  vim.notify("Created worktree: " .. path .. " (" .. branch_name .. ")")

                  -- Ask if user wants to switch to the new worktree
                  vim.ui.select({ "Yes", "No" }, {
                    prompt = "Switch to new worktree?",
                  }, function(switch_choice)
                    if switch_choice == "Yes" then
                      vim.cmd("cd " .. vim.fn.fnameescape(path))
                      vim.notify("Switched to worktree: " .. path)
                      vim.cmd("enew") -- Open a new buffer
                    end
                  end)
                else
                  vim.notify("Error creating worktree: " .. create_output, vim.log.levels.ERROR)
                end
              end)
            end)
          else
            -- Default path suggestion
            local default_path = vim.fn.expand("~") .. "/worktrees/" .. branch_name

            vim.ui.input({
              prompt = "Worktree path: ",
              default = default_path,
            }, function(path)
              if not path or path == "" then
                return
              end

              -- Expand path
              path = vim.fn.expand(path)

              -- Create the worktree
              local cmd =
                string.format("git worktree add %s %s", vim.fn.shellescape(path), vim.fn.shellescape(branch_name))
              local create_output = vim.fn.system(cmd)
              if vim.v.shell_error == 0 then
                vim.notify("Created worktree: " .. path .. " (" .. branch_name .. ")")

                -- Ask if user wants to switch to the new worktree
                vim.ui.select({ "Yes", "No" }, {
                  prompt = "Switch to new worktree?",
                }, function(switch_choice)
                  if switch_choice == "Yes" then
                    vim.cmd("cd " .. vim.fn.fnameescape(path))
                    vim.notify("Switched to worktree: " .. path)
                    vim.cmd("enew") -- Open a new buffer
                  end
                end)
              else
                vim.notify("Error creating worktree: " .. create_output, vim.log.levels.ERROR)
              end
            end)
          end
        end)
      end,
      desc = "Add Git Worktree",
    },
    -- Delete Git Worktree
    {
      "<leader>gwd",
      function()
        -- Get list of worktrees
        local output = vim.fn.system("git worktree list")
        if vim.v.shell_error ~= 0 then
          vim.notify("Error: Not in a git repository or no worktrees found", vim.log.levels.ERROR)
          return
        end

        local worktrees = {}
        local current_path = vim.fn.getcwd()

        for line in output:gmatch("[^\r\n]+") do
          if line and line ~= "" then
            local path = line:match("^([^%s]+)")
            if path and path ~= current_path then -- Don't allow deleting current worktree
              table.insert(worktrees, {
                path = path,
                display = line,
              })
            end
          end
        end

        if #worktrees == 0 then
          vim.notify("No worktrees available for deletion (cannot delete current worktree)")
          return
        end

        local items = {}
        for _, wt in ipairs(worktrees) do
          table.insert(items, wt.display)
        end

        vim.ui.select(items, {
          prompt = "Select worktree to delete:",
        }, function(choice, idx)
          if not choice or not idx then
            return
          end

          local selected = worktrees[idx]

          -- Confirm deletion
          vim.ui.select({ "Yes", "No" }, {
            prompt = "Delete worktree '" .. selected.path .. "'? (This will remove the directory)",
          }, function(confirm)
            if confirm == "Yes" then
              local cmd = "git worktree remove " .. vim.fn.shellescape(selected.path)
              local delete_output = vim.fn.system(cmd)

              if vim.v.shell_error == 0 then
                vim.notify("Deleted worktree: " .. selected.path)
              else
                -- If worktree has changes, git might refuse to delete it
                if delete_output:match("contains modified or untracked files") then
                  vim.ui.select({ "Yes", "No" }, {
                    prompt = "Worktree contains changes. Force delete?",
                  }, function(force_confirm)
                    if force_confirm == "Yes" then
                      local force_cmd = "git worktree remove --force " .. vim.fn.shellescape(selected.path)
                      local force_output = vim.fn.system(force_cmd)
                      if vim.v.shell_error == 0 then
                        vim.notify("Force deleted worktree: " .. selected.path)
                      else
                        vim.notify("Error force deleting worktree: " .. force_output, vim.log.levels.ERROR)
                      end
                    end
                  end)
                else
                  vim.notify("Error deleting worktree: " .. delete_output, vim.log.levels.ERROR)
                end
              end
            end
          end)
        end)
      end,
      desc = "Delete Git Worktree",
    },
    -- Grep
    {
      "<leader>sg",
      function()
        Snacks.picker.grep()
      end,
      desc = "Grep",
    },
    -- search
    {
      "<leader>sc",
      function()
        Snacks.picker.command_history()
      end,
      desc = "Command History",
    },
    {
      "<leader>sC",
      function()
        Snacks.picker.commands()
      end,
      desc = "Commands",
    },
    {
      "<leader>sd",
      function()
        Snacks.picker.diagnostics()
      end,
      desc = "Diagnostics",
    },
    {
      "<leader>sH",
      function()
        Snacks.picker.highlights()
      end,
      desc = "Highlights",
    },
    {
      "<leader>si",
      function()
        Snacks.picker.icons()
      end,
      desc = "Icons",
    },

    {
      "<leader>sk",
      function()
        Snacks.picker.keymaps()
      end,
      desc = "Keymaps",
    },
    {
      "<leader>sq",
      function()
        Snacks.picker.qflist()
      end,
      desc = "Quickfix List",
    },
    {
      "<leader>sR",
      function()
        Snacks.picker.resume()
      end,
      desc = "Resume",
    },
    {
      "<leader>su",
      function()
        Snacks.picker.undo()
      end,
      desc = "Undo History",
    },
    {
      "<leader>uC",
      function()
        Snacks.picker.colorschemes()
      end,
      desc = "Colorschemes",
    },
    -- LSP

    {
      "<leader>D",
      function()
        Snacks.picker.diagnostics_buffer()
      end,
      desc = "Buffer Diagnostics",
    },
    {
      "gd",
      function()
        Snacks.picker.lsp_definitions()
      end,
    },
    {
      "gD",
      function()
        Snacks.picker.lsp_declarations()
      end,
      desc = "Goto Declaration",
    },
    {
      "gR",
      function()
        Snacks.picker.lsp_references()
      end,
      nowait = true,
      desc = "References",
    },
    {
      "gi",
      function()
        Snacks.picker.lsp_implementations()
      end,
      desc = "Goto Implementation",
    },
    {
      "gt",
      function()
        Snacks.picker.lsp_type_definitions()
      end,
      desc = "Goto T[y]pe Definition",
    },
    {
      "<leader>ss",
      function()
        Snacks.picker.lsp_symbols()
      end,
      desc = "LSP Symbols",
    },
    {
      "<leader>sS",
      function()
        Snacks.picker.lsp_workspace_symbols()
      end,
      desc = "LSP Workspace Symbols",
    },
    -- Other
    {
      "<leader>bd",
      function()
        Snacks.bufdelete()
      end,
      desc = "Delete Buffer",
    },
    {
      "<leader>cR",
      function()
        Snacks.rename.rename_file()
      end,
      desc = "Rename File",
    },
    {
      "<leader>gB",
      function()
        Snacks.gitbrowse()
      end,
      desc = "Git Browse",
      mode = { "n", "v" },
    },
    {
      "<leader>gg",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },
    {
      "<leader>un",
      function()
        Snacks.notifier.hide()
      end,
      desc = "Dismiss All Notifications",
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle
          .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
          :map("<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.dim():map("<leader>uD")
      end,
    })
  end,
}
