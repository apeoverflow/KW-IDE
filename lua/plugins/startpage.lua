return {
  {
    'mhinz/vim-startify',
    config = function()
      -- Startify settings
      vim.g.startify_lists = {
        { type = 'files',     header = { 'Recent Files' } },
        { type = 'dir',       header = { 'Current Directory ' } },
        { type = 'sessions',  header = { 'Sessions' } },
        { type = 'bookmarks', header = { 'Bookmarks' } }
      }

      vim.g.startify_bookmarks = {
        { c = '~/.config/nvim/' },
        { z = '~/.zshrc' }
      }

      vim.g.startify_session_autoload = 1
      vim.g.startify_change_to_vcs_root = 1
      vim.g.startify_fortune_use_unicode = 1
      vim.g.startify_session_persistence = 1
      vim.g.startify_enable_special = 0

      -- Custom header without lazy branding
      vim.g.startify_custom_header = {
        '/════════════════════════════════════════════════╗ ',
        '║                                                ║ ',
        '║   ██╗  ██╗██╗    ██╗      ██╗██████╗ ███████╗  ║ ',
        '║   ██║ ██╔╝██║    ██║      ██║██╔══██╗██╔════╝  ║ ',
        '║   █████╔╝ ██║ █╗ ██║█████╗██║██║  ██║█████╗    ║ ',
        '║   ██╔═██╗ ██║███╗██║╚════╝██║██║  ██║██╔══╝    ║ ',
        '║   ██║  ██╗╚███╔███╔╝      ██║██████╔╝███████╗  ║ ',
        '║   ╚═╝  ╚═╝ ╚══╝╚══╝       ╚═╝╚═════╝ ╚══════╝  ║ ',
        '╚════════════════════════════════════════════════╝ ',
        '',
        '    Find Files      <Leader>ff    Help           <Leader>sh',
        '    Recent Files    <Leader>?     Live Grep      <Leader>sg',
        '    File Browser    <Ctrl>b       Git Files      <Leader>ff',
        '    Terminal        <Ctrl>n       Objects Panel  <Space>o',
        ''
      }
    end,
  },
}