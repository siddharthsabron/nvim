-- =============================================================================
-- LeetCode → GitHub Push
-- =============================================================================
-- Adds a :LeetcodeGithubPush command (and <leader>lg keymap in keymaps.lua).
-- On invoke, copies the current LeetCode solution file into the locally-cloned
-- GitHub repo and runs: git add → git commit → git push.
--
-- Repo clone lives at: ~/.local/share/nvim/leetcode-github/
-- Solutions are placed inside: <repo>/leetcode/<filename>
-- =============================================================================

-- Path where leetcode.nvim stores solution files
local LEET_DIR = vim.fn.expand("~/.local/share/nvim/leetcode")

-- Path where we cloned the GitHub repo
local REPO_DIR = vim.fn.expand("~/.local/share/nvim/leetcode-github")

-- Sub-folder inside the repo where solutions go
local REPO_LEET_DIR = REPO_DIR .. "/leetcode"

--- Show a Neovim notification
local function notify(msg, level)
  vim.notify("[LeetCode→GitHub] " .. msg, level or vim.log.levels.INFO)
end

--- Run a shell command, return { ok, output }
local function run(cmd)
  local handle = io.popen(cmd .. " 2>&1")
  if not handle then
    return false, "Failed to open process"
  end
  local result = handle:read("*a")
  local ok = handle:close()
  return ok, result or ""
end

--- The main push function
local function leetcode_github_push()
  -- 1. Guard: must be inside the leetcode storage dir
  local bufpath = vim.fn.expand("%:p")
  if not bufpath:find(LEET_DIR, 1, true) then
    notify(
      "Not a LeetCode solution file.\nExpected path inside: " .. LEET_DIR,
      vim.log.levels.WARN
    )
    return
  end

  -- 2. Guard: repo must exist
  if vim.fn.isdirectory(REPO_DIR) == 0 then
    notify(
      "GitHub repo not found at " .. REPO_DIR
        .. "\nRun: git clone git@github.com:siddharthsabron/thealgorithm.git "
        .. REPO_DIR,
      vim.log.levels.ERROR
    )
    return
  end

  -- 3. Make sure leetcode/ subfolder exists inside the repo
  vim.fn.mkdir(REPO_LEET_DIR, "p")

  -- 4. Copy current solution file into the repo
  local filename = vim.fn.expand("%:t")  -- e.g. "1.two-sum.java"
  local dest     = REPO_LEET_DIR .. "/" .. filename

  local ok, err = run(string.format("cp %q %q", bufpath, dest))
  if not ok then
    notify("Copy failed: " .. err, vim.log.levels.ERROR)
    return
  end

  -- 5. Build commit message from filename  e.g. "feat: two-sum [java]"
  local slug = filename:match("^%d+%.(.+)%.[^%.]+$") or filename
  local ext  = filename:match("%.([^%.]+)$") or "?"
  local msg  = string.format("feat: %s [%s]", slug, ext)

  -- 6. git pull (fast-forward) to avoid conflicts
  run(string.format("cd %q && git pull --ff-only 2>&1", REPO_DIR))

  -- 7. git add → commit → push
  local cmds = {
    string.format("cd %q && git add leetcode/%s", REPO_DIR, filename),
    string.format("cd %q && git commit -m %q", REPO_DIR, msg),
    string.format("cd %q && git push origin HEAD 2>&1", REPO_DIR),
  }

  for _, cmd in ipairs(cmds) do
    ok, err = run(cmd)
    if not ok then
      if err:find("nothing to commit") then
        notify("Nothing new to commit — file already up to date.", vim.log.levels.WARN)
        return
      end
      notify("Git error:\n" .. err, vim.log.levels.ERROR)
      return
    end
  end

  -- 8. Success notification
  notify('Pushed "' .. filename .. '" → github:siddharthsabron/thealgorithm')
end

-- Register as a user command (:LeetcodeGithubPush)
vim.api.nvim_create_user_command("LeetcodeGithubPush", leetcode_github_push, {
  desc = "Push current LeetCode solution to GitHub",
})

-- Empty table keeps lazy.nvim happy when it scans this plugins/ directory
return {}
