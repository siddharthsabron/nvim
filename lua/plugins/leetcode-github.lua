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

--- Show a Neovim notification — always via vim.schedule so snacks/notify renders it
local function notify(msg, level)
  vim.schedule(function()
    vim.notify("[LeetCode→GitHub] " .. msg, level or vim.log.levels.INFO, {
      title = "LeetCode → GitHub",
    })
  end)
end

--- Run a shell command synchronously, return ok (bool) and full output string
local function run(cmd)
  local handle = io.popen(cmd .. " 2>&1")
  if not handle then
    return false, "Failed to open process"
  end
  local result = handle:read("*a")
  handle:close()
  -- check exit code via a separate call
  local rc = os.execute(cmd .. " 2>/dev/null")
  return (rc == 0 or rc == true), result or ""
end

--- The main push function
local function leetcode_github_push()
  -- 1. Guard: must be inside the leetcode storage dir
  local bufpath = vim.fn.expand("%:p")
  if not bufpath:find(LEET_DIR, 1, true) then
    notify(
      "Not a LeetCode solution file.\nOpen a problem via <leader>lc first.",
      vim.log.levels.WARN
    )
    return
  end

  -- 2. Guard: repo must exist
  if vim.fn.isdirectory(REPO_DIR) == 0 then
    notify(
      "GitHub repo not found at " .. REPO_DIR,
      vim.log.levels.ERROR
    )
    return
  end

  -- 3. Make sure leetcode/ subfolder exists inside the repo
  vim.fn.mkdir(REPO_LEET_DIR, "p")

  -- 4. Copy current solution file into the repo
  local filename = vim.fn.expand("%:t")  -- e.g. "1.two-sum.java"
  local dest     = REPO_LEET_DIR .. "/" .. filename

  -- use vim.fn.system for copy (more reliable inside nvim)
  vim.fn.system({"cp", bufpath, dest})
  if vim.v.shell_error ~= 0 then
    notify("Copy failed for: " .. filename, vim.log.levels.ERROR)
    return
  end

  -- 5. Build commit message  e.g. "feat: two-sum [java]"
  local slug = filename:match("^%d+%.(.+)%.[^%.]+$") or filename
  local ext  = filename:match("%.([^%.]+)$") or "?"
  local msg  = string.format("feat: %s [%s]", slug, ext)

  -- 6. git pull (fast-forward) — ignore errors silently
  vim.fn.system("cd " .. vim.fn.shellescape(REPO_DIR) .. " && git pull --ff-only 2>&1")

  -- 7. git add
  vim.fn.system({
    "git", "-C", REPO_DIR, "add", "leetcode/" .. filename,
  })

  -- 8. git commit
  local commit_out = vim.fn.system({
    "git", "-C", REPO_DIR, "commit", "-m", msg,
  })
  local commit_rc = vim.v.shell_error

  if commit_rc ~= 0 then
    if commit_out:find("nothing to commit") then
      notify("Already up to date — no changes to push.", vim.log.levels.WARN)
    else
      notify("Commit failed:\n" .. commit_out, vim.log.levels.ERROR)
    end
    return
  end

  -- 9. git push
  local push_out = vim.fn.system({
    "git", "-C", REPO_DIR, "push", "origin", "HEAD",
  })
  local push_rc = vim.v.shell_error

  if push_rc ~= 0 then
    notify("Push failed:\n" .. push_out, vim.log.levels.ERROR)
    return
  end

  -- 10. Success
  notify("✓ Pushed  [" .. filename .. "]  to github:siddharthsabron/thealgorithm", vim.log.levels.INFO)
end

-- Register as a user command (:LeetcodeGithubPush)
vim.api.nvim_create_user_command("LeetcodeGithubPush", leetcode_github_push, {
  desc = "Push current LeetCode solution to GitHub",
})

-- Empty table keeps lazy.nvim happy when it scans this plugins/ directory
return {}
