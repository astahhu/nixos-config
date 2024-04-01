{
  pkgs,
  config,
  inputs,
  system,
  lib,
  ...
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
      ripgrep
    ];

    programs.nixvim = {
      enable = true;
      plugins = {
        lualine.enable = true;
        lsp = {
          enable = true;
          servers = {
            lua-ls.enable = true;

            rust-analyzer = {
              enable = true;
              installRustc = true;
              installCargo = true;
            };

            nixd.enable = true;

            java-language-server.enable = true;

            texlab.enable = true;

            gopls.enable = true;

            ccls.enable = true;

            ansiblels.enable = true;

            marksman.enable = true;
          };
        };

        telescope.enable = true;

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

            sources = [
              {name = "nvim_lsp";}
              {name = "path";}
              {name = "buffer";}
              {name = "luasnip";}
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
      ];

      globals.mapleader = " ";
      options = {
        number = true;
        shiftwidth = 2;
      };
    };
  };
}
