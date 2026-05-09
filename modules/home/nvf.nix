{ pkgs, ... }:
{
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;

        options = {
          shiftwidth = 2;
        };

        clipboard = {
          enable = true;
          providers = {
            wl-copy.enable = true;
            xclip.enable = true;
          };
        };

        theme = {
          enable = true;
          name = "tokyonight";
          style = "moon"; # day, night, moon, storm
          transparent = true;
        };

        statusline.lualine = {
          enable = true;
          theme = "tokyonight";
        };

        spellcheck.enable = true;
        telescope.enable = true;
        enableLuaLoader = true;
        undoFile.enable = true;
        snippets.luasnip = {
          enable = true;
          setupOpts.enable_autosnippets = true;
          customSnippets.snipmate = {
            all = [
              {
                trigger = "test";
                body = "this is just a test";
              }
            ];
            beancount = [
              {
                trigger = "test2";
                body = "this is just another test";
              }
            ];
          };
        };
        autopairs.nvim-autopairs.enable = true;
        autocomplete = {
          nvim-cmp = {
            enable = true;
            mappings = {
              complete = "<C-Space>";
              confirm = "<CR>";
            };
            sources = {
              buffer = "[Buffer]";
              nvim-cmp = null;
              path = "[Path]";
            };
          };
        };

        lsp = {
          enable = true;
          formatOnSave = true;
          lspkind.enable = true;
          lightbulb.enable = true;
          lspsaga.enable = false;
          trouble.enable = true;
          null-ls.enable = true;
          inlayHints.enable = true;
          lspSignature.enable = true;
          servers = {
            "*" = {
              root_markers = [ ".git" ];
              capabilities = {
                textDocument = {
                  semanticTokens = {
                    multilineTokenSupport = true;
                  };
                };
              };
            };
          };
        };
        debugger = {
          nvim-dap = {
            enable = true;
            ui.enable = true;
          };
        };
        diagnostics.nvim-lint = {
          enable = true;
          linters_by_ft = {
            beancount = [
              "bean_check"
            ];
            markdown = [
              "vale"
            ];
            text = [
              "vale"
            ];
          };
        };
        languages = {
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;
          nix = {
            enable = true;
            extraDiagnostics = {
              enable = true;
              types = [
                "statix"
                "deadnix"
              ];
            };
            format = {
              enable = true;
              type = [ "nixfmt" ]; # alejandra, nixfmt
            };
            lsp = {
              enable = true;
              # server = "nil"; # nil, nixd
              servers = [ "nixd" ]; # nil, nixd
            };
            treesitter = {
              enable = true;
            };
          };
          markdown = {
            enable = true;
            lsp.enable = true;
            treesitter.enable = true;
          };
          python = {
            enable = true;
            dap = {
              enable = true;
              debugger = "debugpy";
            };
            format = {
              enable = true;
              type = [ "ruff" ];
            };
            lsp = {
              enable = true;
              servers = [ "basedpyright" ];
            };
            treesitter.enable = true;
          };
          # ts.enable = true;
          rust.enable = true;
          html.enable = true;
          bash.enable = true;
          lua = {
            enable = true;
            extraDiagnostics.types = [ "luacheck" ];
          };
        };

        withPython3 = true;
        python3Packages = [
          "pynvim"
          "tasklib"
          "packaging"
        ];

        visuals = {
          nvim-web-devicons.enable = true;
          nvim-cursorline.enable = true;
          cinnamon-nvim.enable = false;
          fidget-nvim.enable = true;

          highlight-undo.enable = true;
          indent-blankline.enable = true;
        };

        tabline = {
          nvimBufferline.enable = true;
        };

        treesitter.context.enable = true;

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
        };

        # filetree.nvimTree = {
        #   enable = true;
        #   mappings.toggle = "<F2>";
        #   setupOpts = {
        #     git.enable = true;
        #     view = {
        #       side = "left";
        #       width = 30;
        #     };
        #   };
        # };

        git = {
          enable = true;
          gitsigns.enable = true;
          gitsigns.codeActions.enable = false; # throws an annoying debug message
        };

        projects.project-nvim.enable = true;

        dashboard = {
          alpha.enable = true;
        };

        notify = {
          nvim-notify.enable = true;
        };

        utility = {
          ccc.enable = false;
          vim-wakatime.enable = false;
          diffview-nvim.enable = true;
          yanky-nvim.enable = false;
          icon-picker.enable = true;
          surround.enable = true;

          motion = {
            hop.enable = true;
            leap.enable = true;
          };
          images = {
            image-nvim = {
              enable = true;
              setupOpts = {
                backend = "kitty";
                integrations.markdown = {
                  enable = true;
                  downloadRemoteImages = true;
                };
              };
            };
          };

          yazi-nvim = {
            enable = true;
            mappings.yaziToggle = "<F2>";
          };
        };

        terminal = {
          toggleterm = {
            enable = true;
            mappings.open = "<F4>";
            lazygit = {
              enable = true;
              mappings.open = "<F3>";
            };
          };
        };

        ui = {
          borders.enable = true;
          noice.enable = true;
          colorizer.enable = true;
          illuminate.enable = true;
          smartcolumn = {
            enable = true;
            setupOpts.custom_colorcolumn = {
              # this is a freeform module, it's `buftype = int;` for configuring column position
              nix = "110";
              ruby = "120";
              java = "130";
              go = [
                "90"
                "130"
              ];
            };
          };
          fastaction.enable = true;
        };

        assistant = {
          chatgpt.enable = false;
          copilot = {
            enable = false;
            # cmp.enable = isMaximal;
          };
          codecompanion-nvim.enable = false;
          avante-nvim = {
            enable = true;
            setupOpts = {
              providers = {
                opencode = {
                  command = "opencode";
                  args = "acp";
                };
                ollama = {
                  endpoint = "http://127.0.0.1:11434";
                  timeout = 30000; # Timeout in milliseconds
                  extra_request_body = {
                    options = {
                      temperature = 0.75;
                      num_ctx = 20480;
                      keep_alive = "5m";
                    };
                  };
                };
              };
            };
          };
        };

        comments = {
          comment-nvim.enable = true;
        };

        notes = {
          obsidian = {
            enable = false;
            setupOpts = {
              dir = "~/notes";
            };
          };
          orgmode.enable = false;
          mind-nvim.enable = false;
          todo-comments.enable = true;
        };

        # startPlugins = builtins.attrValues {
        #   inherit
        #     (pkgs.vimPlugins)
        #     vimwiki
        #     vim-zettel
        #     zk-nvim
        #     calendar-vim
        #     # telekasten
        #     # telescope-media-files
        #     ;
        # };

        startPlugins = with pkgs.vimPlugins; [
          vimwiki
          taskwiki
          # telekasten-nvim
          vim-markdown-toc
          telescope-media-files-nvim
          vim-beancount
        ];

        lazy.plugins = {
          "telekasten-calendar" = {
            package = pkgs.vimUtils.buildVimPlugin {
              pname = "telekasten-calendar";
              version = "unstable-2021-11-27";
              src = pkgs.fetchFromGitHub {
                owner = "nvim-telekasten";
                repo = "calendar-vim";
                rev = "a7e73e02c92566bf427b2a1d6a61a8f23542cc21";
                sha256 = "sha256-4XeDd+myM+wtHUsr3s1H9+GAwIjK8fAqBbFnBCeatPo=";
              };
            };
          };

          "telekasten.nvim" = {
            package = pkgs.vimPlugins.telekasten-nvim;
            setupModule = "telekasten";
            after = ''
              require('telekasten').setup({
                -- Main paths
                home = vim.fn.expand("~/notes/pages"), -- path to main notes folder
                dailies = vim.fn.expand("~/notes/journals"), -- path to daily notes
                -- templates = vim.fn.expand("~/notes/templates"), -- path to templates
                take_over_my_home = false,
                journal_auto_open = true,

                -- Specific note templates
                  -- set to `nil` or do not specify if you do not want a template
                --template_new_note = vim.fn.expand("~/notes/templates/new.md"),    -- template for new notes
                template_new_daily = vim.fn.expand("~/notes/pages/templates.md"),   -- template for new daily notes

                -- Image subdir for pasting
                  -- subdir name
                  -- or nil if pasted images shouldn't go into a special subdir
                image_subdir = vim.fn.expand("~/notes/assets"),

                -- Image link style",
                  -- wiki:     ![[image name]]
                  -- markdown: ![](image_subdir/xxxxx.png)
                image_link_style = "markdown",

                -- Make syntax available to markdown buffers and telescope previewers
                install_syntax = true,

                -- Previewer for media files (images mostly)
                  -- "telescope-media-files" if you have telescope-media-files.nvim installed
                  -- "catimg-previewer" if you have catimg installed
                  -- "viu-previewer" if you have viu installed
                media_previewer = "catimg-previewer",

                -- Calendar integration
                plug_into_calendar = true,         -- use calendar integration
                calendar_opts = {
                  weeknm = 1,                      -- calendar week display mode:
                                                   --   1 .. 'WK01'
                                                   --   2 .. 'WK 1'
                                                   --   3 .. 'KW01'
                                                   --   4 .. 'KW 1'
                                                   --   5 .. '1'

                  calendar_monday = 1,             -- use monday as first day of week:
                                                   --   1 .. true
                                                   --   0 .. false

                  calendar_mark = 'left-fit',      -- calendar mark placement
                                                   -- where to put mark for marked days:
                                                   --   'left'
                                                   --   'right'
                                                   --   'left-fit'
                },
              })
            '';
            keys = [
              # Launch panel if nothing is typed after <leader>z
              {
                mode = "n";
                key = "<leader>z";
                action = ":Telekasten panel<CR>";
              }

              # Most used functions
              {
                mode = "n";
                key = "<leader>zf";
                action = ":Telekasten find_notes<CR>";
              }
              {
                mode = "n";
                key = "<leader>zg";
                action = ":Telekasten search_notes<CR>";
              }
              {
                mode = "n";
                key = "<leader>zn";
                action = ":Telekasten new_note<CR>";
              }
              {
                mode = "n";
                key = "<leader>zr";
                action = ":Telekasten rename_note<CR>";
              }
              {
                mode = "n";
                key = "<leader>zd";
                action = ":Telekasten goto_today<CR>";
              }
              {
                mode = "n";
                key = "<leader>zc";
                action = ":Telekasten show_calendar<CR>";
              }
              {
                mode = "n";
                key = "<leader>zx";
                action = ":Telekasten toggle_todo<CR>";
              }
              {
                mode = "n";
                key = "<leader>zt";
                action = ":Telekasten show_tags<CR>";
              }
              {
                mode = "n";
                key = "<leader>zz";
                action = ":Telekasten follow_link<CR>";
              }
              {
                mode = "n";
                key = "<leader>zb";
                action = ":Telekasten show_backlinks<CR>";
              }
              {
                mode = "n";
                key = "<leader>zI";
                action = ":Telekasten insert_img_link<CR>";
              }

              # Call insert link automatically when we start typing a link
              {
                mode = "i";
                key = "[[";
                action = "<cmd>Telekasten insert_link<CR>";
              }
            ];
          };
        };

        luaConfigRC.notes = ''
          -- -- See :h vimwiki_list for info on registering wiki paths
          -- vim.o.wiki_0 = {}
          -- vim.o.wiki_0.path = '~/notes/'
          -- vim.o.wiki_0.index = 'home'
          -- vim.o.wiki_0.syntax = 'markdown'
          -- vim.o.wiki_0.ext = '.md'
          -- vim.o.wiki_0.auto_toc = 1
          -- vim.o.wiki_0.list_margin = -1
          -- -- fill spaces in page names with _ in pathing
          -- vim.o.wiki_0.links_space_char = '_'

          -- -- TODO: nixvim: CONFIRM THESE PATHS FOR NIXOS
          -- vim.o.wiki_1 = {}
          -- vim.o.wiki_1.path = '~/doc/foundry/thefoundry.wiki/'
          -- vim.o.wiki_1.index = 'home'
          -- vim.o.wiki_1.syntax = 'markdown'
          -- vim.o.wiki_1.ext = '.md'
          -- -- fill spaces in page names with _ in pathing
          -- vim.o.wiki_1.links_space_char = '_'

          -- vim.g.vimwiki_list = {{
          --   wiki_0,
          --   wiki_1,
          -- }}

          -- Make markdown the default vimwiki setup
          vim.g.vimwiki_list = {{
            path = '~/notes/',
            syntax = 'markdown',
            ext = '.md',
          },}
          vim.g.vimwiki_ext2syntax = {
            ['.md'] = 'markdown',
            ['.markdown'] = 'markdown',
            ['.mdown'] = 'markdown',
          }

          vim.g.vimwiki_listsyms = '✗○◐●✓'
          vim.g.vimwiki_global_ext = 0 -- 0 disables Temporary Wikis

          -- vim.g.vimwiki_folding='custom'
          -- vim.g.vimwiki_folding = 'expr'

          vim.g.vimwiki_use_mouse = 1
          vim.g.vimwiki_auto_chdir = 1

          -- -- Makes vimwiki markdown links as [text](text.md) instead of [text](text)
          vim.g.vimwiki_markdown_link_ext = 1

          -- -- When opening a directory containing a file with this name and default wiki
          -- -- extention, assume it is a vimwiki
          -- vim.g.vimwiki_dir_link = ' '
          -- autocmd FileType vimwiki setlocal foldenable

          -- TaskWarrior
          vim.g.taskwiki_markup_syntax = 'markdown'
          vim.g.markdown_folding = 1
          vim.g.taskwiki_project_root = '~/notes/'
          -- taskwarrior data location
          -- vim.g.taskwiki_extra_warrirors={'H': {'data_location': '~/notes/tasks/task/', 'taskrc_location': '~/.config/task/taskrc'}}

          -- -- vim-zettel config
          -- vim.g.nv_search_paths = {{'~/notes'}}
          -- vim.g.zettel_options = {{
          --   front_matter = {tags = ""},
          --   template =  '~/notes/_templates/zettel.tpl',
          -- }}
          -- vim.g.zettel_format = '%Y%m%d%H%M%S'
        '';

        ### FROM AI ###
        # # Extra plugins for Zettelkasten
        # extraPlugins = with pkgs.vimPlugins; {
        #   telekasten-nvim = {
        #     package = telekasten-nvim;
        #     setup = ''
        #       require('telekasten').setup({
        #         home = vim.fn.expand("~/notes"),
        #         dailies = vim.fn.expand("~/notes/daily"),
        #         weeklies = vim.fn.expand("~/notes/weekly"),
        #         templates = vim.fn.expand("~/notes/templates"),
        #         extension = ".md",
        #         template_new_note = vim.fn.expand("~/notes/templates/new_note.md"),
        #         template_new_daily = vim.fn.expand("~/notes/templates/daily.md"),
        #         follow_creates_nonexisting = true,
        #         dailies_create_nonexisting = true,
        #         weeklies_create_nonexisting = true,
        #         image_subdir = "img",
        #         plug_into_calendar = true,
        #         calendar_opts = {
        #           weekdayheader = {'M', 'T', 'W', 'T', 'F', 'S', 'S'},
        #           calendar_monday = 1,
        #         },
        #         new_note_filename = "uuid-title",
        #         uuid_type = "%Y%m%d%H%M",
        #         uuid_sep = "-",
        #       })
        #     '';
        #   };
        #
        #   vim-zettel = {
        #     package = vim-zettel;
        #     setup = ''
        #       vim.g.zettel_format = "%Y%m%d%H%M"
        #       vim.g.zettel_default_mappings = 1
        #     '';
        #   };
        # };
        #
        # # Key mappings for Zettelkasten
        # maps = {
        #   normal = {
        #     # Telescope mappings
        #     "<leader>ff" = ":Telescope find_files<CR>";
        #     "<leader>fg" = ":Telescope live_grep<CR>";
        #     "<leader>fb" = ":Telescope buffers<CR>";
        #     "<leader>fh" = ":Telescope help_tags<CR>";
        #
        #     # Telekasten mappings
        #     "<leader>z" = ":Telekasten panel<CR>";
        #     "<leader>zf" = ":Telekasten find_notes<CR>";
        #     "<leader>zg" = ":Telekasten search_notes<CR>";
        #     "<leader>zd" = ":Telekasten goto_today<CR>";
        #     "<leader>zz" = ":Telekasten follow_link<CR>";
        #     "<leader>zn" = ":Telekasten new_note<CR>";
        #     "<leader>zc" = ":Telekasten show_calendar<CR>";
        #     "<leader>zb" = ":Telekasten show_backlinks<CR>";
        #     "<leader>zI" = ":Telekasten insert_img_link<CR>";
        #   };
        # };
        #
        # # Custom Lua config for additional Zettelkasten functions
        # luaConfig = ''
        #   -- Custom function for today's daily note
        #   vim.api.nvim_create_user_command('Today', function()
        #     local date = os.date('%Y-%m-%d')
        #     vim.cmd('edit ~/notes/daily/' .. date .. '.md')
        #   end, {})
        #
        #   -- Custom function to create timestamped block reference
        #   vim.api.nvim_create_user_command('BlockRef', function()
        #     local timestamp = os.date('%Y%m%d%H%M%S')
        #     local block_id = '^' .. timestamp
        #     vim.api.nvim_put({block_id}, 'c', true, true)
        #   end, {})
        #
        #   -- Auto-create notes directory structure
        #   local notes_dirs = {
        #     vim.fn.expand("~/notes"),
        #     vim.fn.expand("~/notes/daily"),
        #     vim.fn.expand("~/notes/weekly"),
        #     vim.fn.expand("~/notes/templates"),
        #     vim.fn.expand("~/notes/img"),
        #   }
        #
        #   for _, dir in ipairs(notes_dirs) do
        #     if vim.fn.isdirectory(dir) == 0 then
        #       vim.fn.mkdir(dir, 'p')
        #     end
        #   end
        # '';
        #
        # # Vimscript config for markdown
        # vimConfig = ''
        #   " Markdown-specific settings
        #   autocmd FileType markdown setlocal wrap linebreak
        #   autocmd FileType markdown setlocal conceallevel=2
        #   autocmd BufNewFile,BufRead *.md set filetype=markdown
        # '';

        # keymaps = [
        #   {
        #     # ========== LazyGit Plugin =========
        #     key = "<F3>";
        #     mode = "n";
        #     action = ":LazyGit<CR>";
        #     noremap = true;
        #     silent = true;
        #   }
        #   # ========== ToggleTerm Plugin =========
        #   {
        #     key = "<Esc>";
        #     mode = "t";
        #     action = "<C-\\><C-n>";
        #     noremap = true;
        #   }
        # ];
      };
    };
  };
}
