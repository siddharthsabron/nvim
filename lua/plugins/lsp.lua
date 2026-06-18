return {
  -- Mason UI polish (icons + keymap).
  -- NOTE: LSP servers themselves are installed/managed by LazyVim's language
  -- extras (see lazyvim.json). We don't hand-wire servers here anymore.
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- =========================================================================
  -- Java (JDTLS) — fully owned by LazyVim's `lang.java` extra.
  -- =========================================================================
  -- We ONLY *extend* the extra here to raise the JVM heap for large
  -- Spring Boot projects. We deliberately DO NOT define `cmd`, `root_dir`,
  -- `settings`, or call `jdtls.start_or_attach()` — the extra does all of that
  -- correctly (project import, capabilities, DAP, tests). Re-defining it here
  -- is what previously broke cross-file `gd`.
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      opts.cmd = opts.cmd or { vim.fn.exepath("jdtls") }
      vim.list_extend(opts.cmd, {
        "--jvm-arg=-Xmx4g",
        "--jvm-arg=-XX:+UseG1GC",
        "--jvm-arg=-XX:+UseStringDeduplication",
      })
    end,
  },
}
