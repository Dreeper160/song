-- display_image.lua
-- Affiche une image au format .nfp sur un moniteur connecté (CC:Tweaked)
-- Usage : display_image <chemin_vers_image.nfp> [chemin_vers_palette.lua]
-- Le 2e argument est optionnel : fichier genere par png_to_nfp.py --custom-palette,
-- applique uniquement sur un advanced monitor (ignore silencieusement sinon).

local args = {...}
local imagePath = args[1]
local palettePath = args[2]

if not imagePath then
    print("Usage: display_image <chemin_image.nfp> [chemin_palette.lua]")
    return
end

if not fs.exists(imagePath) then
    print("Fichier introuvable : " .. imagePath)
    return
end

local monitor = peripheral.find("monitor")
if not monitor then
    print("Aucun moniteur connecté trouvé.")
    return
end

-- Correspondance chiffre .nfp -> constante colors.xxx
-- (equivalent manuel de colors.fromBlit, absent des versions plus anciennes de CC:Tweaked)
local BLIT_TO_COLOUR = {
    ["0"] = colors.white,
    ["1"] = colors.orange,
    ["2"] = colors.magenta,
    ["3"] = colors.lightBlue,
    ["4"] = colors.yellow,
    ["5"] = colors.lime,
    ["6"] = colors.pink,
    ["7"] = colors.gray,
    ["8"] = colors.lightGray,
    ["9"] = colors.cyan,
    ["a"] = colors.purple,
    ["b"] = colors.blue,
    ["c"] = colors.brown,
    ["d"] = colors.green,
    ["e"] = colors.red,
    ["f"] = colors.black,
}

local image = paintutils.loadImage(imagePath)
if not image then
    print("Impossible de charger l'image (format .nfp attendu).")
    return
end

-- Echelle de texte réduite = plus de "pixels" affichables
monitor.setTextScale(0.5)

-- Palette personnalisee (advanced monitor uniquement) : remplace les 16
-- couleurs Minecraft par les couleurs calculees pour CETTE image
if palettePath then
    if not fs.exists(palettePath) then
        print("Palette introuvable : " .. palettePath .. " (affichage avec la palette par defaut)")
    else
        local ok, palette = pcall(dofile, palettePath)
        if ok and type(palette) == "table" then
            local count = 0
            for hexChar, rgb in pairs(palette) do
                local colourConst = BLIT_TO_COLOUR[hexChar]
                if colourConst then
                    monitor.setPaletteColor(colourConst, rgb)
                    count = count + 1
                end
            end
            print("Palette personnalisee appliquee (" .. count .. " couleurs).")
        else
            print("Palette invalide, affichage avec la palette par defaut.")
        end
    end
end

local mw, mh = monitor.getSize()
local iw, ih = #image[1], #image

-- Centrage automatique de l'image sur le moniteur
local x = math.max(1, math.floor((mw - iw) / 2) + 1)
local y = math.max(1, math.floor((mh - ih) / 2) + 1)

local oldTerm = term.redirect(monitor)
monitor.setBackgroundColor(colors.black)
term.clear()
paintutils.drawImage(image, x, y)
term.redirect(oldTerm)

print("Image affichee sur le moniteur.")
