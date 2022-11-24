DracoRunServer = function()
   vim.lsp.start({
       name = 'draco',
       cmd={LS_hotfix_path},
       root_dir=vim.fs.dirname('src'),
       detached=false,
       on_attach = function(_, bufnr)
          print('Draco server is running')
       end,
       autostart=true
       })
end
vim.cmd[[
:command DracoRunServer lua DracoRunServer()
]]
vim.cmd[[
:autocmd FileType draco DracoRunServer
]]
vim.cmd[[
:au BufRead,BufNewFile *.draco set filetype=draco
]]
