return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function ()
    local config = {
      ensure_installed = {
        "bash", "c", "javascript", "jsdoc",
        "lua", "rust", "typescript", "vimdoc",
      },

      sync_install = false,
      -- automatically install missing parser when entering buffer
      auto_install = true,
      indent = {
        enable = true,
      },

      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "markdown" },
      },
    }

    local parser_templates = {
      install_info = {
        -- HTML syntax in Go
        -- https://templ.guide/
        url = "https://github.com/vrischmann/tree-sitter-templ.git",
        files = { "src/parser.c", "src/scanner.c"},
        branch = "master",
      },
    }

    require("nvim-treesitter.configs").setup(config)

    local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    parser_config.templ = parser_templates
    vim.treesitter.language.register("templ", "templ")
  end,
}
