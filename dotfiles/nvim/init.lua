--[[
-- Neovim 0.12 configuration using the native package manager and APIs.
=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is Kickstart?

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know what this means, type the following:
      - <escape key>
      - :
      - Tutor
      - <enter key>

    (If you already know how the Neovim basics, you can skip this step)

  Once you've completed that, you can continue working through **AND READING** the rest
  of the kickstart init.lua

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not sure exactly what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or neovim features used in kickstart.

   NOTE: Look for lines like this

    Throughout the file. These are for you, the reader, to help understand what is happening.
    Feel free to delete them once you know what you're doing, but they should serve as a guide
    for when you are first encountering a few different constructs in your nvim config.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, for help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Neovim 0.12 native completion. The `o` source uses the LSP omnifunc.
vim.opt.autocomplete = true
vim.opt.autocompletedelay = 100
vim.opt.complete = { 'o', '.', 'w', 'b', 'u', 't' }
vim.opt.completeopt = { 'menuone', 'noselect', 'popup', 'fuzzy' }

-- Neovim 0.12's experimental message and command-line presentation layer.
-- `g<` opens the message pager.
vim.opt.cmdheight = 0
require('vim._core.ui2').enable {
  msg = {
    targets = 'msg',
    msg = { height = 0.5, timeout = 4000 },
  },
}

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- The LSP log can become very large in monorepos. Enable it temporarily when debugging.
vim.lsp.log.set_level("OFF")

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- ============================================================
-- SECTION 3: NATIVE PACKAGE MANAGEMENT
-- See `:help vim.pack`, `:help vim.pack-examples`, and
-- https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
--
-- Inspect installed state without fetching:
--   :lua vim.pack.update(nil, { offline = true })
-- Review available updates:
--   :lua vim.pack.update()
-- In the review buffer, `:write` applies and `:quit` discards changes.
-- ============================================================

-- Build hooks must be registered before `vim.pack.add()` so they also run
-- while bootstrapping plugins from nvim-pack-lock.json.
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(event)
		if event.data.kind ~= "install" and event.data.kind ~= "update" then
			return
		end

		if event.data.spec.name == "nvim-treesitter" then
			if not event.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})

-- `vim.pack.add()` installs missing Git repositories, records revisions in
-- nvim-pack-lock.json, and loads each package so it can be configured below.
vim.pack.add({
	"https://github.com/tpope/vim-sleuth",
	"https://github.com/direnv/direnv.vim",
	"https://github.com/christoomey/vim-tmux-navigator",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-mini/mini.nvim",
	"https://github.com/folke/tokyonight.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/folke/todo-comments.nvim",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-telescope/telescope-ui-select.nvim",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
	"https://github.com/j-hui/fidget.nvim",
	"https://github.com/stevearc/conform.nvim",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	"https://github.com/folke/flash.nvim",
	"https://github.com/vim-test/vim-test",
	"https://github.com/linrongbin16/gitlinker.nvim",
	"https://github.com/monkoose/neocodeium",
	"https://github.com/olimorris/codecompanion.nvim",
}, { confirm = false })

-- ============================================================
-- SECTION 4: UI AND CORE EDITING
-- ============================================================

-- Collection of various small independent plugins/modules.
-- Better Around/Inside textobjects
--
-- Examples:
--  - va)  - [V]isually select [A]round [)]paren
--  - yinq - [Y]ank [I]nside [N]ext [']quote
--  - ci'  - [C]hange [I]nside [']quote
--
-- Add/delete/replace surroundings (brackets, quotes, etc.)
--
-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
-- - sd'   - [S]urround [D]elete [']quotes
-- - sr)'  - [S]urround [R]eplace [)] [']
--
-- mini.icons also provides a compatibility shim for plugins expecting the
-- nvim-web-devicons module.
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()
require("mini.pairs").setup()
require("mini.ai").setup({
	-- Avoid Neovim 0.12's built-in incremental-selection mappings.
	mappings = { around_next = "aa", inside_next = "ii" },
	n_lines = 500,
})
require("mini.surround").setup()
-- Simple and easy statusline.
-- You could remove this setup call if you don't like it and try another
-- statusline plugin.
local statusline = require("mini.statusline")
-- Set use_icons to true if you have a Nerd Font.
statusline.setup({ use_icons = vim.g.have_nerd_font })
statusline.section_location = function()
	return "%P %2l:%-2v"
end

-- You can easily change to a different colorscheme. To see installed schemes,
-- use `:Telescope colorscheme`.
require("tokyonight").setup({ styles = { comments = { italic = false } } })
-- Other variants include tokyonight-storm, tokyonight-moon, and tokyonight-day.
vim.cmd.colorscheme("tokyonight-night")

-- Highlight todo, notes, etc in comments.
require("todo-comments").setup({ signs = false })

-- Adds git related signs to the gutter, as well as utilities for managing changes.
-- See `:help gitsigns` to understand what the configuration keys do.
require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
})
vim.keymap.set("n", "<leader>gb", require("gitsigns").blame_line, { desc = "[G]it [B]lame" })

require("which-key").setup({ delay = 0, icons = { mappings = vim.g.have_nerd_font } })
require("which-key").add({
	{ "<leader>c", group = "[C]ode" },
	{ "<leader>d", group = "[D]ocument" },
	{ "<leader>r", group = "[R]ename" },
	{ "<leader>s", group = "[S]earch" },
	{ "<leader>t", group = "[T]est" },
	{ "<leader>w", group = "[W]orkspace" },
})

-- ============================================================
-- SECTION 5: SEARCH AND NAVIGATION
-- ============================================================

      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of help_tags options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
require("telescope").setup({
	-- You can put default mappings and picker-specific options in this table.
	-- See `:help telescope.setup()` for all available settings.
	extensions = { ["ui-select"] = { require("telescope.themes").get_dropdown() } },
	pickers = { find_files = { hidden = true } },
})
require("telescope").load_extension("ui-select")

-- See `:help telescope.builtin`.
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", builtin.git_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sF", function()
	builtin.find_files({ previewer = false })
end, { desc = "[S]earch [F]iles (non-git)" })
vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "[S]earch Recent Files" })
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "Find existing buffers" })
-- nvim.undotree is an optional plugin shipped with Neovim 0.12. Moving the
-- cursor in its window previews the selected state in the undo tree.
vim.cmd.packadd("nvim.undotree")
vim.keymap.set("n", "<leader>u", "<cmd>Undotree<cr>", { desc = "[U]ndo Tree" })
vim.keymap.set("n", "<leader>/", function()
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({ winblend = 10, previewer = false }))
end, { desc = "Fuzzily search current buffer" })
vim.keymap.set("n", "<leader>s/", function()
	builtin.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
end, { desc = "[S]earch in open files" })
vim.keymap.set("n", "<leader>sn", function()
	builtin.find_files({ cwd = vim.fn.stdpath("config"), follow = true })
end, { desc = "[S]earch [N]eovim files" })

require("oil").setup({ default_file_explorer = true, view_options = { show_hidden = true } })
vim.keymap.set("n", "<leader>b", "<cmd>Oil<cr>", { desc = "[B]rowse files" })

-- ============================================================
-- SECTION 6: NATIVE LSP AND COMPLETION
-- ============================================================

      -- Brief Aside: **What is LSP?**
      --
      -- LSP is an acronym you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

-- Neovim 0.12 manages server lifecycle with `vim.lsp.config()` and
-- `vim.lsp.enable()`. nvim-lspconfig supplies standard server definitions.

-- Useful status updates for LSP.
require("fidget").setup({})

-- Manually request native LSP completion. <C-y> accepts a candidate and
-- Neovim's built-in vim.snippet expands and navigates snippet placeholders.
vim.keymap.set("i", "<C-Space>", function()
	vim.lsp.completion.get()
end, { desc = "Trigger LSP completion" })
-- Configure buffer-local behavior each time a language server attaches.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(event)
          -- NOTE: Remember that lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself
          -- many times.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what language a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace
          --  Similar to document symbols, except searches over your whole project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('<leader>cl', vim.lsp.codelens.run, '[C]ode [L]ens')

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client:supports_method("textDocument/completion", event.buf) then
			vim.lsp.completion.enable(true, client.id, event.buf)
		end
		if client and client:supports_method("textDocument/inlayHint", event.buf) then
			vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
		end
		if client and client:supports_method("textDocument/documentHighlight", event.buf) then
			local group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
			vim.api.nvim_create_autocmd(
				{ "CursorHold", "CursorHoldI" },
				{ buffer = event.buf, group = group, callback = vim.lsp.buf.document_highlight }
			)
			vim.api.nvim_create_autocmd(
				{ "CursorMoved", "CursorMovedI" },
				{ buffer = event.buf, group = group, callback = vim.lsp.buf.clear_references }
			)
		end
		if client and client:supports_method("textDocument/codeLens", event.buf) then
			vim.lsp.codelens.enable(true, { bufnr = event.buf })
		end
	end,
})

-- Enable the following language servers. Add override configuration in these
-- tables. Common keys are `cmd`, `filetypes`, `capabilities`, and `settings`.
-- See `:help lspconfig-all` for the available server definitions.
-- Servers are enabled globally, but only start in matching buffers.
local servers = {
	pyright = {},
	hls = {},
	zls = { settings = { enable_build_on_save = true, build_on_save_step = "check" } },
	gopls = {
		settings = {
			gopls = {
				hints = { compositeLiteralFields = true, constantValues = true },
				codelenses = { test = true, generate = true },
				staticcheck = true,
			},
		},
	},
	lua_ls = {
		on_init = function(client)
			if client.workspace_folders then
				local path = client.workspace_folders[1].name
				if
					path ~= vim.fn.stdpath("config")
					and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
				then
					return
				end
			end
			client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
				runtime = { version = "LuaJIT", path = { "lua/?.lua", "lua/?/init.lua" } },
				workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
			})
		end,
		settings = { Lua = { completion = { callSnippet = "Replace" } } },
	},
}
-- Mason installs only the tools we want it to own. gopls, hls, and zls are
-- intentionally expected from the system PATH.
require("mason").setup({ PATH = "append" })
require("mason-tool-installer").setup({ ensure_installed = { "lua-language-server", "stylua" } })
for name, config in pairs(servers) do
	vim.lsp.config(name, config)
	vim.lsp.enable(name)
end

-- ============================================================
-- SECTION 7: FORMATTING AND TESTING
-- ============================================================

-- Autoformat with conform.nvim. External formatters are selected by filetype;
-- LSP formatting is used as a fallback for languages without one. C and C++
-- deliberately avoid LSP fallback because they do not have one standardized
-- formatting style. Additional formatters can be added to `formatters_by_ft`.
require("conform").setup({
	notify_on_error = false,
	-- Conform can run multiple formatters sequentially. It can also use a
	-- sub-list to stop after the first available formatter.
	format_after_save = function(bufnr)
		return { lsp_format = ({ c = true, cpp = true })[vim.bo[bufnr].filetype] and "never" or "fallback" }
	end,
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "goimports", "gofmt" },
		haskell = { "ormolu" },
	},
})

-- nvim-test is tied to the retired nvim-treesitter master API. vim-test keeps
-- the same commands/keybindings while working with the 0.12 Treesitter stack.
vim.g["test#go#gotest#options"] = "-tags=dynamic"
vim.keymap.set("n", "<leader>tf", "<cmd>TestFile<cr>", { desc = "[T]est [F]ile" })
vim.keymap.set("n", "<leader>tn", "<cmd>TestNearest<cr>", { desc = "[T]est [N]earest" })
vim.keymap.set("n", "<leader>ts", "<cmd>TestSuite<cr>", { desc = "[T]est [S]uite" })
vim.keymap.set("n", "<leader>tl", "<cmd>TestLast<cr>", { desc = "[T]est [L]ast" })
vim.keymap.set("n", "<leader>tv", "<cmd>TestVisit<cr>", { desc = "[T]est [V]isit" })

-- ============================================================
-- SECTION 8: TREESITTER
-- ============================================================

-- [[ Configure Treesitter ]] See `:help nvim-treesitter-intro`.
-- Treesitter highlights, edits, and navigates code using a syntax tree.
-- nvim-treesitter installs parsers and compatible queries; Neovim 0.12 itself
-- provides highlighting and selection, while nvim-treesitter supplies
-- installation and indentation.
--
-- Other useful modules to explore include Treesitter context and textobjects.
local parsers = {
	"bash",
	"c",
	"diff",
	"go",
	"haskell",
	"html",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"query",
	"vim",
	"vimdoc",
	"yaml",
	"zig",
}
require("nvim-treesitter").install(parsers)
local available_parsers = require("nvim-treesitter").get_available()
-- Attach native highlighting and Treesitter indentation when a parser exists.
local function treesitter_attach(buf, language)
	if not vim.treesitter.language.add(language) then
		return
	end
	vim.treesitter.start(buf, language)
	if vim.treesitter.query.get(language, "indents") then
		vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
end
-- Autoinstall languages that are available but do not have an installed parser.
vim.api.nvim_create_autocmd("FileType", {
	callback = function(event)
		local language = vim.treesitter.language.get_lang(event.match)
		if not language then
			return
		end
		local installed_parsers = require("nvim-treesitter").get_installed("parsers")
		if vim.tbl_contains(installed_parsers, language) then
			treesitter_attach(event.buf, language)
		elseif vim.tbl_contains(available_parsers, language) then
			require("nvim-treesitter").install(language):await(function()
				treesitter_attach(event.buf, language)
			end)
		else
			treesitter_attach(event.buf, language)
		end
	end,
})

-- Other Treesitter modules worth exploring include:
--  - Incremental selection: `:help treesitter-incremental-selection`
--  - Current context: https://github.com/nvim-treesitter/nvim-treesitter-context
--  - Textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects

-- ============================================================
-- SECTION 9: MOTION, GIT, AI, AND TEST UTILITIES
-- These are personal additions beyond the core Kickstart example.
-- ============================================================
require("flash").setup({})
vim.keymap.set({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash" })

require("gitlinker").setup({})
vim.keymap.set("n", "<leader>gl", require("gitlinker").link, { desc = "[G]it [L]ink" })

require("neocodeium").setup({})
-- Keep Tab available for native snippet navigation.
vim.keymap.set("i", "<M-f>", require("neocodeium").accept, { desc = "Accept NeoCodeium suggestion" })

require("codecompanion").setup({
	strategies = { chat = { adapter = "openai_responses" } },
	adapters = {
		openai_responses = function()
			return require("codecompanion.adapters").extend("openai_responses", { schema = { model = { default = "gpt-5.6-luna" } } })
		end,
	},
})
vim.keymap.set("n", "<leader>a", "<cmd>CodeCompanionActions<cr>", { desc = "[A]I" })

-- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
-- init.lua. If you want these files, they are in the repository, so you can just download them and
-- put them in the right spots if you want.

-- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for kickstart
--
-- Here are some example plugins included in the Kickstart repository. Require
-- them here after copying the files into `lua/kickstart/plugins/`.
--
-- require 'kickstart.plugins.debug'
-- require 'kickstart.plugins.indent_line'

-- NOTE: You can also add your own plugins and configuration from Lua modules.
-- Native `vim.pack.add()` can be called from those modules directly.

-- Inspect plugins: :lua vim.pack.update(nil, { offline = true })
-- Update plugins:  :lua vim.pack.update()
-- Review changes, then `:write` to apply or `:quit` to cancel.

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
