{ pkgs
, config
, inputs
, lib
, ...
}: {
  options = {
    astahhu.cli.nixvim.enable = lib.mkEnableOption "Enable nixvim";
  };

  imports = [
    # For NixOS
    inputs.nixvim.nixosModules.nixvim
  ];

  config = lib.mkIf config.astahhu.cli.nixvim.enable {
    environment.systemPackages = [
      (lib.mkIf (!config.astahhu.common.is_server) pkgs.cargo-nextest)
      (lib.mkIf (!config.astahhu.common.is_server) pkgs.rust-analyzer)
      (lib.mkIf (!config.astahhu.common.is_server) pkgs.rustfmt)
      (lib.mkIf (!config.astahhu.common.is_server) pkgs.lldb)
      pkgs.ripgrep
    ];

    environment.variables = {
      EDITOR = "nvim";
    };

    home-manager.sharedModules = [
      {
        home.sessionVariables = {
          EDITOR = "nvim";
        };
      }
    ];

    programs.nixvim = {
      enable = true;
      plugins = {
        lualine.enable = true;
        fidget.enable = true;
        lsp = {
          enable = !config.astahhu.common.is_server;
          servers = {
            lua_ls.enable = !config.astahhu.common.is_server;

            nixd = {
              enable = !config.astahhu.common.is_server;
              settings = {
                formatting.command = [ "nixpkgs-fmt" ];

                options = {
                  nixos.expr = "(builtins.getFlake \"${inputs.self}\").nixosConfigurations.${config.networking.hostName}";
                };
              };
            };

            java_language_server.enable = !config.astahhu.common.is_server;

            texlab.enable = !config.astahhu.common.is_server;

            gopls.enable = !config.astahhu.common.is_server;

            ccls.enable = !config.astahhu.common.is_server;

            marksman.enable = !config.astahhu.common.is_server;
          };
        };
        rustaceanvim = {
          enable = !config.astahhu.common.is_server;
        };


        web-devicons.enable = !config.astahhu.common.is_server;

        lsp-format.enable = !config.astahhu.common.is_server;

        lspsaga.enable = !config.astahhu.common.is_server;


        dap = {
          enable = !config.astahhu.common.is_server;

        };
        neotest = {
          enable = !config.astahhu.common.is_server;

        };

        telescope.enable = true;

        markdown-preview.enable = !config.astahhu.common.is_server;

        oil.enable = !config.astahhu.common.is_server;

        luasnip.enable = !config.astahhu.common.is_server;

        treesitter.enable = !config.astahhu.common.is_server;

        crates.enable = !config.astahhu.common.is_server;


        rainbow-delimiters.enable = !config.astahhu.common.is_server;

        cmp = {
          enable = !config.astahhu.common.is_server;
          autoEnableSources = !config.astahhu.common.is_server;


          settings = {
            mapping = {
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-d>" = "cmp.mapping.scroll_docs(-4)";
              "<C-e>" = "cmp.mapping.close()";
              "<C-f>" = "cmp.mapping.scroll_docs(4)";
              "<CR>" = "cmp.mapping.confirm({ select = true })";
              "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
              "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            };

            snippet.expand = ''
              function(args)
                require('luasnip').lsp_expand(args.body)
              end
            '';

            sources = [
              { name = "nvim_lsp"; }
              { name = "clippy"; }
              { name = "path"; }
              { name = "buffer"; }
              { name = "luasnip"; }
            ];
          };
        };
        bufferline.enable = true;
      };

      keymaps = [
        {
          action = "<cmd>Telescope live_grep<CR>";
          key = "<leader>g";
        }
        {
          action = "<cmd>Lspsaga code_action<CR>";
          key = "<leader>a";
        }
        {
          action = "<cmd>Lspsaga rename<CR>";
          key = "<leader>r";
        }
        {
          action = "<cmd>edit .<CR>";
          key = "<leader>o";
        }
        {
          action = "<cmd>Neotest run<CR>";
          key = "<leader>tf";
        }
        {
          action = "<cmd>lua require('neotest').run.run(vim.fn.getcwd())<CR>";
          key = "<leader>tp";
        }
        {
          action = "<cmd>lua require('neotest').watch.watch()<CR>";
          key = "<leader>twf";
        }
        {
          action = "<cmd>lua require('neotest').watch.toggle(vim.fn.getcwd())<CR>";
          key = "<leader>twp";
        }
        {
          action = "<cmd>lua require('neotest').summary.toggle()<CR>";
          key = "<leader>ts";
        }
      ];

      globals.mapleader = " ";
      opts = {
        signcolumn = "yes";
        number = true;
        shiftwidth = 2;
      };
    };
  };
}

