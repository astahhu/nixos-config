{
  pkgs,
  config,
  nixvim,
  system,
  lib,
  ...
}: {
  options = {
    myprograms.cli.nixvim.enable = lib.mkEnableOption "Enable nixvim";
  };

  config = lib.mkIf config.myprograms.cli.nixvim.enable {
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

	treesitter.enable = true;
	crates-nvim.enable = true;
        cmp = {
          enable = true;
	  autoEnableSources = true;
        };
	bufferline.enable = true;
	cmp-nvim-lsp.enable = true;
	cmp-path.enable = true;
	cmp-buffer.enable = true;
      };

      options = {
        number = true;
	shiftwidth = 2;
      };
    };
  };
}
