-- https://stackoverflow.com/questions/1340230/check-if-directory-exists-in-lua
function exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok
end

local LS_url         = 'https://github.com/Draco-lang/Compiler'
local LS_csproj_path = 'draco-server/src/Draco.LanguageServer/Draco.LanguageServer.csproj'
local LS_exec_path   = 'draco-server/src/Draco.LanguageServer/bin/Debug/net7.0/Draco.LanguageServer'

function DracoPullServer()
    os.execute('rm draco-server')
    os.execute('git clone ' .. LS_url .. ' draco-server')
end

function DracoBuildServer()
    os.execute('dotnet build --project ' .. LS_csproj_path)
end

DracoRunServer = function()
   vim.lsp.start({
       name = 'draco',
       cmd={LS_exec_path},
       root_dir=vim.fs.dirname('src'),
       detached=false,
       on_attach = function(_, bufnr)
          print('Draco server is running')
       end,
       autostart=true
       })
end
vim.cmd[[
:command DracoPullServer lua DracoPullServer()
:command DracoBuildServer lua DracoBuildServer()
:command DracoRunServer lua DracoRunServer()
:autocmd FileType draco DracoRunServer
:au BufRead,BufNewFile *.draco set filetype=draco
]]
