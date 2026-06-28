-- src/core/icons.lua
-- Built-in Lucide Roblox Icon Library for QwenUILib

local Icons = {
    -- Navigation & Core
    ["home"] = "rbxassetid://10747373864",
    ["search"] = "rbxassetid://10747373033",
    ["settings"] = "rbxassetid://10747373111",
    ["gear"] = "rbxassetid://10747373111",
    ["info"] = "rbxassetid://10747372792",
    ["help"] = "rbxassetid://10747372792",
    ["bell"] = "rbxassetid://10747371253",
    ["notification"] = "rbxassetid://10747371253",
    
    -- Combat & Action
    ["combat"] = "rbxassetid://10747383842",
    ["sword"] = "rbxassetid://10747383842",
    ["aimbot"] = "rbxassetid://10747365995",
    ["crosshair"] = "rbxassetid://10747365995",
    ["shield"] = "rbxassetid://10747383474",
    ["target"] = "rbxassetid://10747365995",
    
    -- Visuals & Theme
    ["visuals"] = "rbxassetid://10747372701",
    ["eye"] = "rbxassetid://10747372701",
    ["eye-off"] = "rbxassetid://10747372714",
    ["palette"] = "rbxassetid://10747373400",
    ["brush"] = "rbxassetid://10747373400",
    
    -- Players & Movement
    ["player"] = "rbxassetid://10747384394",
    ["user"] = "rbxassetid://10747384394",
    ["zap"] = "rbxassetid://10747383921",
    ["speed"] = "rbxassetid://10747383921",
    ["run"] = "rbxassetid://10747383921",
    
    -- Files, Coding & Configs
    ["terminal"] = "rbxassetid://10888290230",
    ["console"] = "rbxassetid://10888290230",
    ["code"] = "rbxassetid://10747363456",
    ["folder"] = "rbxassetid://10747372992",
    ["config"] = "rbxassetid://10747372992",
    ["file"] = "rbxassetid://10747363539",
    ["key"] = "rbxassetid://10747372910",
    ["keybind"] = "rbxassetid://10747372910",
    
    -- Actions & Status
    ["trash"] = "rbxassetid://10747373158",
    ["delete"] = "rbxassetid://10747373158",
    ["check"] = "rbxassetid://10747371510",
    ["success"] = "rbxassetid://10747371510",
    ["x"] = "rbxassetid://10747373217",
    ["close"] = "rbxassetid://10747373217",
    ["error"] = "rbxassetid://10747373217",
    ["plus"] = "rbxassetid://10747371661",
    ["add"] = "rbxassetid://10747371661",
    ["minus"] = "rbxassetid://10747371556",
    ["mouse"] = "rbxassetid://10747373280"
}

local IconLibrary = {}

function IconLibrary.Get(name)
    if not name then return nil end
    local lowerName = tostring(name):lower():gsub("lucide%-", "")
    return Icons[lowerName]
end

return IconLibrary
