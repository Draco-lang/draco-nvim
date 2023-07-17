local function root_pattern(...)
  local function exists(filename)
    local stat = vim.loop.fs_stat(filename)
    return stat and stat.type or false
  end
  local function path_join(...)
    return table.concat(vim.tbl_flatten { ... }, '/')
  end
  local function escape_wildcards(path)
    return path:gsub('([%[%]%?%*])', '\\%1')
  end
  local patterns = vim.tbl_flatten { ... }
  local function matcher(path)
    for _, pattern in ipairs(patterns) do
      for _, p in ipairs(vim.fn.glob(path_join(escape_wildcards(path), pattern), true, true)) do
        if exists(p) then
          return path
        end
      end
    end
  end
  local function strip_archive_subpath(path)
    -- Matches regex from zip.vim / tar.vim
    path = vim.fn.substitute(path, 'zipfile://\\(.\\{-}\\)::[^\\\\].*$', '\\1', '')
    path = vim.fn.substitute(path, 'tarfile:\\(.\\{-}\\)::.*$', '\\1', '')
    return path
  end
  local is_windows = vim.loop.os_uname().version:match 'Windows'
  local function is_fs_root(path)
    if is_windows then
      return path:match '^%a:$'
    else
      return path == '/'
    end
  end
  local function dirname(path)
    local strip_dir_pat = '/([^/]+)$'
    local strip_sep_pat = '/$'
    if not path or #path == 0 then
      return
    end
    local result = path:gsub(strip_sep_pat, ''):gsub(strip_dir_pat, '')
    if #result == 0 then
      if is_windows then
        return path:sub(1, 2):upper()
      else
        return '/'
      end
    end
    return result
  end
  local function search_ancestors(startpath, func)
    vim.validate { func = { func, 'f' } }
    if func(startpath) then
      return startpath
    end
    local guard = 100
    local function iterate_parents(path)
      local function it(_, v)
        if v and not is_fs_root(v) then
          v = dirname(v)
        else
          return
        end
        if v and vim.loop.fs_realpath(v) then
          return v, path
        else
          return
        end
      end
      return it, path, path
    end
    for path in iterate_parents(startpath) do
      -- Prevent infinite recursion if our algorithm breaks
      guard = guard - 1
      if guard == 0 then
        return
      end
      if func(path) then
        return path
      end
    end
  end
  return function(startpath)
    startpath = strip_archive_subpath(startpath)
    return search_ancestors(startpath, matcher)
  end
end

DracoRunServer = function()
   vim.lsp.start({
       name = 'draco',
       cmd={ "draco-langserver", "run", "--stdio" },
       root_dir=root_pattern('*.sln', '*.dracoproj', '.git'),
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
