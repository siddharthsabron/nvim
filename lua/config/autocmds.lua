-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- =============================================================================
-- Neo-tree: VS Code-style git colors (changed / new / deleted files)
-- =============================================================================
-- Defined here (not in the neo-tree plugin spec) so it does NOT override
-- LazyVim's own neo-tree `init` that handles `nvim .` directory hijacking.
local function apply_neotree_git_colors()
  local set = vim.api.nvim_set_hl
  set(0, "NeoTreeGitModified", { fg = "#e2c08d" }) -- changed = yellow
  set(0, "NeoTreeGitAdded", { fg = "#73c991" }) -- added = green
  set(0, "NeoTreeGitUntracked", { fg = "#73c991" }) -- new = green
  set(0, "NeoTreeGitStaged", { fg = "#73c991" })
  set(0, "NeoTreeGitUnstaged", { fg = "#e2c08d" })
  set(0, "NeoTreeGitConflict", { fg = "#e4676b" }) -- conflict = red
  set(0, "NeoTreeGitDeleted", { fg = "#f14c4c" }) -- deleted = red
  set(0, "NeoTreeGitIgnored", { fg = "#8c8c8c" }) -- ignored = grey
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("UserNeoTreeColors", { clear = true }),
  callback = apply_neotree_git_colors,
})
-- Apply once now in case the colorscheme is already loaded at startup.
vim.defer_fn(apply_neotree_git_colors, 200)
