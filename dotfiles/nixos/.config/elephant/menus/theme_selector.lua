--
-- Dynamic desktop theme menu for Elephant/Walker
--
Name = "themeSelector"
NamePretty = "Themes"
HideFromProviderlist = true

-- Check if file exists using Lua (no subprocess)
local function file_exists(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

-- Get first matching file from directory using ls (single call for fallback)
local function first_image_in_dir(dir)
  local handle = io.popen("ls -1 '" .. dir .. "' 2>/dev/null | head -n 1")
  if handle then
    local file = handle:read("*l")
    handle:close()
    if file and file ~= "" then
      return dir .. "/" .. file
    end
  end
  return nil
end

-- The main function elephant will call
function GetEntries()
  local entries = {}
  local user_theme_dir = os.getenv("HOME") .. "/.config/linux-desktop/themes"
  local session_root = os.getenv("LINUX_SESSION_ROOT") or os.getenv("HOME") .. "/.local/share/linux-desktop"
  local default_theme_dir = session_root .. "/themes"
  local current_theme_file = io.open(session_root .. "/current/theme.name", "r")
  local current_theme = current_theme_file and current_theme_file:read("*l") or nil
  if current_theme_file then
    current_theme_file:close()
  end

  local seen_themes = {}

  -- Helper function to process themes from a directory
  local function process_themes_from_dir(theme_dir)
    -- Single find call to get all theme directories
    local handle = io.popen("find -L '" .. theme_dir .. "' -mindepth 1 -maxdepth 1 -type d 2>/dev/null")
    if not handle then
      return
    end

    for theme_path in handle:lines() do
      local theme_name = theme_path:match(".*/(.+)$")

      if theme_name and not seen_themes[theme_name] then
        seen_themes[theme_name] = true

        -- Check for preview images directly (no subprocess)
        local preview_path = nil
        local preview_png = theme_path .. "/preview.png"
        local preview_jpg = theme_path .. "/preview.jpg"

        if file_exists(preview_png) then
          preview_path = preview_png
        elseif file_exists(preview_jpg) then
          preview_path = preview_jpg
        else
          -- Fallback: get first image from backgrounds (one ls call)
          preview_path = first_image_in_dir(theme_path .. "/backgrounds")
        end

        local display_name = theme_name:gsub("_", " "):gsub("%-", " ")
        display_name = display_name:gsub("(%a)([%w_']*)", function(first, rest)
          return first:upper() .. rest:lower()
        end)
        local is_current = theme_name == current_theme
        local entry = {
          Text = is_current and ("Active: " .. display_name) or display_name,
          Preview = preview_path,
          PreviewType = preview_path and "file" or nil,
          Actions = {
            activate = "theme-set " .. theme_name,
          },
        }
        table.insert(entries, is_current and 1 or (#entries + 1), entry)
      end
    end

    handle:close()
  end

  -- Process user themes first (they take precedence)
  process_themes_from_dir(user_theme_dir)
  -- Then process default themes (only if not already seen)
  process_themes_from_dir(default_theme_dir)

  return entries
end
