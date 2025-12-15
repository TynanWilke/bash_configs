-- Tynan's Neovim Configuration

-- Basic Settings
vim.opt.number = true                    -- Show line numbers
vim.opt.relativenumber = true            -- Relative line numbers
vim.opt.mouse = 'a'                      -- Enable mouse support
vim.opt.ignorecase = true                -- Ignore case in search
vim.opt.smartcase = true                 -- Override ignorecase if search contains uppercase
vim.opt.hlsearch = true                  -- Highlight search results
vim.opt.incsearch = true                 -- Incremental search
vim.opt.wrap = false                     -- Don't wrap lines
vim.opt.breakindent = true               -- Preserve indentation in wrapped text
vim.opt.tabstop = 4                      -- Number of spaces per tab
vim.opt.shiftwidth = 4                   -- Number of spaces for indentation
vim.opt.expandtab = true                 -- Convert tabs to spaces
vim.opt.autoindent = true                -- Copy indent from current line when starting new line
vim.opt.smartindent = true               -- Smart autoindenting
vim.opt.termguicolors = true             -- Enable 24-bit RGB colors
vim.opt.cursorline = true                -- Highlight current line
vim.opt.updatetime = 250                 -- Faster completion
vim.opt.timeoutlen = 300                 -- Time to wait for mapped sequence
vim.opt.backup = false                   -- Disable backup files
vim.opt.writebackup = false              -- Disable backup before overwriting file
vim.opt.swapfile = false                 -- Disable swap files
vim.opt.undofile = true                  -- Enable persistent undo
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undo')  -- Undo directory
vim.opt.scrolloff = 8                    -- Keep 8 lines above/below cursor
vim.opt.signcolumn = 'yes'               -- Always show sign column
vim.opt.clipboard = 'unnamedplus'        -- Use system clipboard
vim.opt.splitright = true                -- Vertical split to the right
vim.opt.splitbelow = true                -- Horizontal split below

-- Create undo directory if it doesn't exist
vim.fn.mkdir(vim.fn.expand('~/.config/nvim/undo'), 'p')

-- Leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Key Mappings
local keymap = vim.keymap.set

-- Better window navigation
keymap('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
keymap('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
keymap('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
keymap('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Resize windows
keymap('n', '<C-Up>', ':resize -2<CR>', { desc = 'Decrease window height' })
keymap('n', '<C-Down>', ':resize +2<CR>', { desc = 'Increase window height' })
keymap('n', '<C-Left>', ':vertical resize -2<CR>', { desc = 'Decrease window width' })
keymap('n', '<C-Right>', ':vertical resize +2<CR>', { desc = 'Increase window width' })

-- Buffer navigation
keymap('n', '<S-l>', ':bnext<CR>', { desc = 'Next buffer' })
keymap('n', '<S-h>', ':bprevious<CR>', { desc = 'Previous buffer' })

-- Clear search highlighting
keymap('n', '<leader>h', ':nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Better indenting in visual mode
keymap('v', '<', '<gv', { desc = 'Indent left' })
keymap('v', '>', '>gv', { desc = 'Indent right' })

-- Move text up and down in visual mode
keymap('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move line down' })
keymap('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move line up' })

-- Keep cursor centered when scrolling
keymap('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
keymap('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
keymap('n', 'n', 'nzzzv', { desc = 'Next search result and center' })
keymap('n', 'N', 'Nzzzv', { desc = 'Previous search result and center' })

-- Better paste (doesn't replace clipboard with deleted text)
keymap('x', '<leader>p', '"_dP', { desc = 'Paste without replacing clipboard' })

-- Save and quit shortcuts
keymap('n', '<leader>w', ':w<CR>', { desc = 'Save file' })
keymap('n', '<leader>q', ':q<CR>', { desc = 'Quit' })

-- File explorer (using built-in netrw)
keymap('n', '<leader>e', ':Explore<CR>', { desc = 'Open file explorer' })

-- Split windows
keymap('n', '<leader>v', ':vsplit<CR>', { desc = 'Vertical split' })
keymap('n', '<leader>s', ':split<CR>', { desc = 'Horizontal split' })

-- Auto commands
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd('BufWritePre', {
    desc = 'Remove trailing whitespace',
    group = vim.api.nvim_create_augroup('trailing-whitespace', { clear = true }),
    pattern = '*',
    command = [[%s/\s\+$//e]],
})

-- Color scheme (using built-in)
vim.cmd.colorscheme('desert')

-- Status line
vim.opt.laststatus = 2
vim.opt.statusline = '%f %m %r%=%l,%c %p%%'

print("Neovim config loaded!")
