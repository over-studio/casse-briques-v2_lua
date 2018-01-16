-- init the game
function initUI(title, icon, wd, ht)
    -- set game title
    love.window.setTitle(title)

    -- set game icon
    local newIcon = loadImage(icon)
    love.window.setIcon(newIcon:getData())

    -- set game mode(width, height...)
    love.window.setMode(wd, ht)
end

-- load an image
function loadImage(src)
    local img = love.graphics.newImage(src)
    return img
end