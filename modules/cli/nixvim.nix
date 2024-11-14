{ pkgs
, config
, inputs
, lib
, ...
}: {
  options = {
    myprograms.cli.nixvim.enable = lib.mkEnableOption "Enable nixvim";
  };

  imports = [
    # For NixOS
    inputs.nixvim.nixosModules.nixvim
  ];

  config = lib.mkIf config.myprograms.cli.nixvim.enable {
    environment.systemPackages = with pkgs; [
      cargo-nextest
      ripgrep
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
          enable = true;
          servers = {
            lua_ls.enable = true;


            nixd = {
              enable = true;
              settings = {
                #nixpkgs = "${inputs.nixpkgs}";
                formatting.command = [ "nixpkgs-fmt" ];
              };
            };

            java_language_server.enable = true;

            texlab.enable = true;

            gopls.enable = true;

            ccls.enable = true;

            ansiblels.enable = true;

            marksman.enable = true;
          };
        };
        rustaceanvim.enable = true;

        web-devicons.enable = true;

        lsp-format.enable = true;
        lspsaga.enable = true;

        dap = {
          enable = true;
        };
        neotest = {
          enable = true;
        };

        telescope.enable = true;
        markdown-preview.enable = true;
        oil.enable = true;

        luasnip.enable = true;
        treesitter.enable = true;
        crates-nvim.enable = true;

        rainbow-delimiters.enable = true;
        cmp = {
          enable = true;
          autoEnableSources = true;

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

