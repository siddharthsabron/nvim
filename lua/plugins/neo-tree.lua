return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true, -- when true, they will just be displayed differently than normal items
        hide_dotfiles = false, -- hide files starting with a dot
        hide_gitignored = false, -- hide files that are ignored by git
        hide_hidden = false, -- hide files and folders that are hidden
        hide_by_name = {
          -- "node_modules"
        },
        hide_by_pattern = { -- uses glob style patterns
          -- "*.meta",
          -- "*/src/*/tsconfig.json",
        },
        always_show = { -- remains visible even if other settings would normally hide it
          -- ".gitignored",
        },
        never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
          -- ".DS_Store",
          -- "thumbs.db"
        },
        never_show_by_pattern = { -- uses glob style patterns
          -- ".null-ls_ignore",
        },
      },
    },
  },
}
