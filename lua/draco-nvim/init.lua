DracoRunServer = function()
   vim.lsp.start({
       name = 'draco',
       cmd={ "draco-langserver", "run", "--stdio" },
       root_dir=vim.fs.dirname('src'),
       detached=false,
       on_attach = function(_, bufnr)
          print('Draco server is running on buffer ' .. bufnr)
       end,
       autostart=true
       })
end
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.draco",
    callback = function (_)
        vim.b.filetype = "draco"
        DracoRunServer()
    end
})
