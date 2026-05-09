{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    initLua = ./init.lua;
    plugins = {
      compress = ./plugins/compress.yazi;
      glow = ./plugins/glow.yazi;
      full-border = ./plugins/full-border.yazi/init.lua;
      hide-preview = ./plugins/hide-preview.yazi;
      max-preview = ./plugins/max-preview.yazi;
      ouch = ./plugins/ouch.yazi;
      rsync = ./plugins/rsync.yazi;
      yatline = ./plugins/yatline.yazi;
    };
    settings = {
      yazi = {
        manager = {
          ratio = [
            2
            2
            4
          ];
          sort_by = "alphabetical";
          sort_sensitive = false;
          sort_reverse = false;
          sort_dir_first = true;
          # linemode       = "mtime";
          linemode = "size";
          show_hidden = true;
          show_symlink = true;
        };

        preview = {
          # tab_size = 2;
          cache_dir = "";
          image_filter = "lanczos3";
          # image_filter = "triangle";
          image_quality = 80;
          sixel_fraction = 15;
          max_width = 600;
          max_height = 900;
          ueberzug_scale = 1;
          ueberzug_offset = [
            0
            0
            0
            0
          ];
        };

        tasks = {
          micro_workers = 5;
          macro_workers = 10;
          bizarre_retry = 5;
        };

        open = {
          rules = [
            {
              name = "*/";
              use = [
                "edit"
                "open"
                "reveal"
              ];
            }
            {
              mime = "text/*";
              use = [
                "edit"
                "reveal"
              ];
            }
            {
              mime = "image/*";
              use = [
                "open"
                "reveal"
              ];
            }
            {
              mime = "video/*";
              use = [
                "play"
                "reveal"
              ];
            }
            {
              mime = "audio/*";
              use = [
                "play"
                "reveal"
              ];
            }
            {
              mime = "inode/x-empty";
              use = [
                "edit"
                "reveal"
              ];
            }
            {
              mime = "application/json";
              use = [
                "edit"
                "reveal"
              ];
            }
            {
              mime = "*/javascript";
              use = [
                "edit"
                "reveal"
              ];
            }
            {
              mime = "application/zip";
              use = [
                "extract"
                "reveal"
              ];
            }
            {
              mime = "application/gzip";
              use = [
                "extract"
                "reveal"
              ];
            }
            {
              mime = "application/x-tar";
              use = [
                "extract"
                "reveal"
              ];
            }
            {
              mime = "application/x-bzip";
              use = [
                "extract"
                "reveal"
              ];
            }
            {
              mime = "application/x-bzip2";
              use = [
                "extract"
                "reveal"
              ];
            }
            {
              mime = "application/x-7z-compressed";
              use = [
                "extract"
                "reveal"
              ];
            }
            {
              mime = "application/x-rar";
              use = [
                "extract"
                "reveal"
              ];
            }
            {
              mime = "application/xz";
              use = [
                "extract"
                "reveal"
              ];
            }
            {
              mime = "*";
              use = [
                "open"
                "reveal"
              ];
            }
          ];
        };

        opener = {
          edit = [
            {
              run = "nvim \"$@\"";
              block = true;
              for = "unix";
            }
          ];
          open = [
            # { run = "qimgv \"$@\""; desc = "Open"; }
            {
              run = "xdg-open \"$@\"";
              desc = "Open";
              for = "linux";
            }
          ];
          reveal = [
            # {
            #   run = "''${pkgs.exiftool}/bin/exiftool \"$1\"; echo \"Press enter to exit\"; read _''";
            #   block = true;
            #   desc = "Show EXIF";
            # }
            {
              run = "''exiftool \"$1\"; echo \"Press enter to exit\"; read''";
              block = true;
              desc = "Show EXIF";
              for = "unix";
            }
          ];
          extract = [
            {
              run = "unar \"$1\"";
              desc = "Extract here";
              for = "unix";
            }
          ];
          play = [
            {
              run = "mpv \"$@\"";
              orphan = true;
              for = "unix";
            }
            # {
            #   run = "''${pkgs.mediainfo}/bin/mediainfo \"$1\"; echo \"Press enter to exit\"; read _''";
            #   block = true;
            #   desc = "Show media info";
            # }
            {
              run = "''mediainfo \"$1\"; echo \"Press enter to exit\"; read''";
              block = true;
              desc = "Show media info";
              for = "unix";
            }
          ];
          archive = [
            {
              run = "unar \"$1\"";
              desc = "Extract here";
              for = "unix";
            }
          ];
        };

        # plugin = {
        #   prepend_previewers = [
        #     { name = "*.md"; run = "glow"; }
        #     { mime = "application/*zip"; run = "ouch"; }
        #     { mime = "application/x-tar"; run = "ouch"; }
        #     { mime = "application/x-bzip2"; run = "ouch"; }
        #     { mime = "application/x-7z-compressed"; run = "ouch"; }
        #     { mime = "application/x-rar"; run = "ouch"; }
        #     { mime = "application/x-xz"; run = "ouch"; }
        #   ];
        # };
      };

      keymap = {
        manager.prepend_keymap = [
          {
            on = [ "<F1>" ];
            run = "plugin --sync max-preview";
            desc = "Maximize or restore preview";
          }
          {
            on = [ "<F2>" ];
            run = "plugin --sync hide-preview";
            desc = "Hide or show preview";
          }
          {
            on = [ "<F3>" ];
            run = "shell \"lazygit\" --block --confirm";
            desc = "Run lazygit";
          }
          {
            on = [ "<F4>" ];
            run = "shell \"$SHELL\" --block --confirm";
            desc = "Open shell here";
          }
          {
            on = [
              "c"
              "a"
            ];
            run = "plugin compress";
            desc = "Archive selected files";
          }
          {
            on = [ "R" ];
            run = "plugin rsync";
            desc = "Copy files using rsync";
          }
          {
            on = [ "<C-n>" ];
            run = "shell 'dragon -x -i -T \"$1\"' --confirm";
            desc = "Drag and drop via dragon";
          }
        ];
        # manager.keymap = [
        #   {
        #     on = ["<Up>"];
        #     run = "arrow -1";
        #     desc = "Move cursor up";
        #   }
        # ];
        # completion.keymap = [
        #   {
        #     on = ["<Esc>"];
        #     run = "close";
        #     desc = "Cancel completion";
        #   }
        #   {
        #     on = ["<Tab>"];
        #     run = "close --submit";
        #     desc = "Submit the completion";
        #   }
        # ];
        # tasks.keymap = [
        #   {
        #     run = "close";
        #     exec = "close";
        #     on = ["<Esc>"];
        #   }
        #   {
        #     run = "arrow -1";
        #     exec = "arrow -1";
        #     on = ["<Up>"];
        #   }
        # ];
        # select.keymap = [
        #   {
        #     run = "close";
        #     exec = "close";
        #     on = ["<Esc>"];
        #   }
        #   {
        #     run = "close --submit";
        #     exec = "close --submit";
        #     on = ["<Enter>"];
        #   }
        # ];
        # input.keymap = [
        #   {
        #     run = "close";
        #     exec = "close";
        #     on = ["<Esc>"];
        #   }
        #   {
        #     run = "close --submit";
        #     exec = "close --submit";
        #     on = ["<Enter>"];
        #   }
        # ];
        # help.keymap = [
        #   {
        #     run = "escape";
        #     exec = "escape";
        #     on = ["<Esc>"];
        #   }
        #   {
        #     run = "filter";
        #     exec = "filter";
        #     on = ["/"];
        #   }
        # ];
      };

      # theme = {
      #   # manager = {
      #   #   border_symbol = "|";
      #   # };
      #   icon = {
      #     rules = [
      #       {
      #         name = "*.jsx";
      #         text = "";
      #         fg = "#20c2e3";
      #       }
      #       {
      #         name = "*.lua";
      #         text = "";
      #         fg = "#51a0cf";
      #       }
      #       {
      #         name = "*.nix";
      #         text = "";
      #         fg = "#7ebae4";
      #       }
      #     ];
      #   };
      #   filetype = {
      #     rules = [
      #       # Images
      #       {
      #         mime = "image/*";
      #         fg = "#7ebae4";
      #       }
      #     ];
      #   };
      # };
    };
  };
}
