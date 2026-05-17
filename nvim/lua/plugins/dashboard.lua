return {
  {
    "m00qek/baleia.nvim",
    lazy = true,
    opts = {
      augroup = "BaleiaDashboard",
      debug = false,
    },
  },
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      { "m00qek/baleia.nvim", optional = true },
    },
    config = function()
      local navy = "#000080"
      local image_stem = "dashboard"
      local extensions = { "png", "jpg", "jpeg", "webp", "gif" }

      local function apply_highlights(colored_header)
        for _, group in ipairs({
          "DashboardFooter",
          "DashboardIcon",
          "DashboardDesc",
          "DashboardKey",
          "DashboardShortcut",
        }) do
          vim.api.nvim_set_hl(0, group, { fg = navy })
        end

        if colored_header then
          vim.api.nvim_set_hl(0, "DashboardHeader", { link = "Normal" })
        else
          vim.api.nvim_set_hl(0, "DashboardHeader", { fg = navy, bold = true })
        end
      end

      local function strip_ansi_header(lines)
        local stripped = {}
        for _, line in ipairs(lines) do
          table.insert(stripped, line:gsub("\27%[[0-9;]*m", ""))
        end
        return stripped
      end

      local function setup_baleia()
        local ok, baleia = pcall(require, "baleia")
        if not ok then
          pcall(function()
            require("lazy").load({ plugins = { "baleia.nvim" } })
          end)
          ok, baleia = pcall(require, "baleia")
        end
        if not ok then
          return false
        end

        vim.api.nvim_create_autocmd("FileType", {
          group = vim.api.nvim_create_augroup("BaleiaDashboardColor", { clear = true }),
          pattern = "dashboard",
          callback = function(event)
            baleia.once(event.buf)
          end,
        })

        return true
      end

      local function nvim_config_root()
        return vim.fn.fnamemodify(
          (debug.getinfo(1, "S").source:gsub("^@", ""):gsub("\\", "/")),
          ":h:h:h"
        )
      end

      local function asset_dirs()
        return {
          vim.fn.stdpath("config") .. "/assets",
          nvim_config_root() .. "/assets",
        }
      end

      local function find_dashboard_image()
        for _, dir in ipairs(asset_dirs()) do
          for _, ext in ipairs(extensions) do
            local path = dir .. "/" .. image_stem .. "." .. ext
            if vim.fn.filereadable(path) == 1 then
              return path
            end
          end
        end
      end

      local function header_width()
        local cols = vim.o.columns
        if cols <= 0 then
          cols = 80
        end
        return math.max(40, math.min(cols - 2, 100))
      end

      local function cache_path(image_path)
        local safe = image_path:gsub("[^%w]", "_")
        return vim.fn.stdpath("cache") .. "/dashboard-color-" .. safe .. ".txt"
      end

      local function read_cache(image_path)
        local cache = cache_path(image_path)
        if vim.fn.filereadable(cache) ~= 1 then
          return nil
        end

        local img_stat = vim.uv.fs_stat(image_path)
        local cache_stat = vim.uv.fs_stat(cache)
        if not img_stat or not cache_stat then
          return nil
        end

        if cache_stat.mtime.sec < img_stat.mtime.sec then
          return nil
        end

        local lines = vim.fn.readfile(cache)
        return #lines > 0 and lines or nil
      end

      local function write_cache(image_path, lines)
        vim.fn.writefile(lines, cache_path(image_path))
      end

      local function stdout_to_lines(stdout)
        return vim.split(vim.trim(stdout), "\n", { plain = true })
      end

      local function convert_with_chafa(image_path, width)
        if vim.fn.executable("chafa") ~= 1 then
          return nil
        end

        local result = vim.system({
          "chafa",
          "--format=symbols",
          "--symbols=narrow",
          "--colors=full",
          "--size=" .. width .. "x0",
          image_path,
        }, { text = true })

        if result.code ~= 0 or result.stdout == "" then
          return nil
        end

        return stdout_to_lines(result.stdout)
      end

      local function convert_with_ascii_image_converter(image_path, width)
        if vim.fn.executable("ascii-image-converter") ~= 1 then
          return nil
        end

        local result = vim.system({
          "ascii-image-converter",
          image_path,
          "-W",
          tostring(width),
          "-c",
          "-C",
        }, { text = true })

        if result.code ~= 0 or result.stdout == "" then
          return nil
        end

        return stdout_to_lines(result.stdout)
      end

      local function image_to_header(image_path)
        local width = header_width()
        local cached = read_cache(image_path)
        if cached then
          return cached
        end

        local header = convert_with_chafa(image_path, width)
          or convert_with_ascii_image_converter(image_path, width)

        if header then
          write_cache(image_path, header)
        end

        return header
      end

      local function default_header()
        local function scale_header(lines, height_factor, width_factor)
          local scaled = {}
          for _, line in ipairs(lines) do
            if width_factor > 1 then
              line = line:gsub(".", function(ch)
                return string.rep(ch, width_factor)
              end)
            end
            for _ = 1, height_factor do
              table.insert(scaled, line)
            end
          end
          return scaled
        end

        return scale_header(
          vim.split(
            [[
 _   _     ___ __  _
| \ | |   |_ _|  \/  |
|  \| |    | || |\/| |
| |\  |    | || |  | |
|_| \_|   |___|_|  |_|
]],
            "\n",
            { plain = true, trimempty = true }
          ),
          4,
          2
        )
      end

      local function resolve_header()
        local image_path = find_dashboard_image()
        if image_path then
          local header = image_to_header(image_path)
          if header then
            return header, true
          end
          vim.notify(
            "dashboard: found "
              .. image_path
              .. " but conversion failed. Install chafa or ascii-image-converter.",
            vim.log.levels.WARN
          )
        end
        return default_header(), false
      end

      local header, colored_header = resolve_header()

      if colored_header then
        if setup_baleia() then
          apply_highlights(true)
        else
          header = strip_ansi_header(header)
          apply_highlights(false)
          vim.notify(
            "dashboard: run :Lazy install baleia.nvim for image colors",
            vim.log.levels.WARN
          )
        end
      else
        apply_highlights(false)
      end

      require("dashboard").setup({
        theme = "hyper",
        config = {
          header = header,
          center = {
            { desc = "New File", action = "ene | startinsert" },
            { desc = "File Explorer", action = "NvimTreeToggle" },
            { desc = "Find File", action = "Telescope find_files" },
            { desc = "Git Status", action = "Telescope git_status" },
            { desc = "Quit", action = "qa" },
          },
          footer = {},
        },
      })
    end,
  },
}
