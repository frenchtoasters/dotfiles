# AGENTS

## Purpose
- This repository is a personal Neovim configuration rooted at `init.vim`.
- Lua modules live under `lua/` and are loaded during `VimEnter`.
- Plugin setup is centralized in `lua/toast.lua`.
- LSP and completion live in `lua/lsp.lua`.
- Editor options and keymaps live in `lua/settings.lua`.
- Statusline logic lives in `lua/statusline.lua`.
- Local extensions live in `lua/extensions/`.

## Repo Map
- `init.vim`: vim-plug plugin list and bootstrapping.
- `lua/settings.lua`: options, globals, keymaps, misc autocmds.
- `lua/toast.lua`: plugin configuration and plugin-local autocmds.
- `lua/lsp.lua`: LSP servers, completion, LSP keymaps.
- `lua/statusline.lua`: statusline render + highlights.
- `lua/extensions/*.lua`: small helper modules (custom integrations).
- `rules/` and `prompts/`: CodeCompanion rules/prompts (see below).
- `plugged/`: vendor plugin repos (do not edit unless needed).

## Build / Lint / Test
- There are no repo-level build, lint, or test commands.
- No single-test runner exists in this config repo.
- For plugin-specific tests, run them inside the plugin repo in `plugged/<plugin>`.
- Manual verification for config changes:
- `nvim -u init.vim` to load this config in isolation.
- `nvim --clean` to compare behavior against a clean baseline.

## Commands Worth Knowing
- `:checkhealth` to inspect runtime health (built-in Neovim command).
- `:Lazy` does not exist; plugins are managed by vim-plug in `init.vim`.
- `:PlugInstall` and `:PlugUpdate` are used when plugin lists change.
- `:source %` can reload a Lua module file during development.

## Code Style: Lua
- Use tabs for indentation (match existing Lua files).
- Prefer double quotes for strings (matches most Lua modules).
- Use `local` for variables; avoid implicit globals.
- Module files return a table or call `M.<func>` methods.
- Prefer `vim.keymap.set` over `vim.api.nvim_set_keymap`.
- Prefer `vim.opt` for options and `vim.g` for globals.
- Guard optional plugins with `pcall(require, "plugin")`.
- Use `vim.api.nvim_create_autocmd` with `vim.api.nvim_create_augroup`.
- When defining augroups, pass `{ clear = true }` for idempotency.
- Keep setup calls in `lua/toast.lua` rather than scattered in modules.

## Code Style: LSP/Completion
- LSP configuration lives in `lua/lsp.lua`.
- Use `vim.lsp.config("server", { ... })` and `vim.lsp.enable`.
- Prefer `capabilities = require("cmp_nvim_lsp").default_capabilities()`.
- For non-essential LSP helpers, wrap with `pcall` to avoid hard failures.
- Configure LspAttach keymaps in the LspAttach autocmd.

## Code Style: Statusline
- Statusline rendering is in `lua/statusline.lua`.
- Prefer small local helpers for diagnostics or LSP client lists.
- Trigger redraws via a dedicated augroup on buffer/LSP events.
- Keep highlight definitions in the same file as the statusline.

## Error Handling
- Use `pcall` for optional dependencies and experimental modules.
- Return early on missing plugin/modules instead of hard-failing.
- Use `vim.notify` for user-facing errors; avoid silent failure.

## Naming Conventions
- Lua module filenames: `snake_case.lua`.
- Lua tables: `M` for modules, `opts` for configuration tables.
- Functions and locals: `snake_case`.
- Autocmd groups: descriptive UpperCamel or `snake_case` names.

## Configuration Patterns
- Centralize plugin setup in `lua/toast.lua`.
- Keep editor options and globals in `lua/settings.lua`.
- Use `vim.api.nvim_create_autocmd` for buffer-specific behavior.
- Favor buffer-local keymaps in LSP attach callbacks.

## Prompt/Rule Files (CodeCompanion)
- `rules/speedy.md` defines architecture expectations for the "speedy" CLI.
- `prompts/speedy_wizard.md` describes scaffold flows and flags.
- `prompts/speedy_up.md` outlines `cmd/<project>-up.go` template.
- `prompts/new_speedy_func.md` documents new command wiring.
- `prompts/git_diff.md` defines how to explain diffs and risks.
- If editing these areas, follow the instructions verbatim.

## Security
- Do not hardcode API keys or tokens in config.
- Use environment variables for credentials.
- Scrub any sample secrets before committing.

## Editing Guidance
- Avoid editing files inside `plugged/` unless a plugin fix is required.
- When adding plugins, update `init.vim` and include setup in `lua/toast.lua`.
- When adding LSP servers, add to `lua/lsp.lua` and Mason ensure list.
- When adding keymaps, keep them grouped in `lua/settings.lua`.
- Keep new modules small and focused; prefer `lua/extensions/` for helpers.

## Runtime Verification
- Start Neovim and open a file to verify plugins load correctly.
- Confirm LSP attaches in a known project file.
- Verify diagnostics and statusline updates on file changes.

## Notes for Agents
- This repo is a Neovim config, not an application with tests.
- Manual runtime verification is the primary validation path.
- Follow existing patterns and keep configs idempotent.
