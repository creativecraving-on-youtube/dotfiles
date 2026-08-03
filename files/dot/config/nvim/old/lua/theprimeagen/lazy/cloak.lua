return {
  "laytan/cloak.nvim",
  config = function()
    require("cloak").setup({
      enabled = true,
      cloak_character = "*",

      -- See :help highlight
      highlight_group = "Comment",
      patterns = {
        {
          file_pattern = {
            ".env*",
            "*.secret",
          },
          cloak_pattern = { "=.+", ":.+", "-.+" },
        },
      },
    })
  end
}
