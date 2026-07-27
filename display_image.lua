-- display_image.lua
-- Affiche une image au format .nfp sur un moniteur connecté (CC:Tweaked)
-- Usage : display_image <chemin_vers_image.nfp>

local args = {...}
local imagePath = args[1]

if not imagePath then
    print("Usage: display_image <chemin_image.nfp>")
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

local image = paintutils.loadImage(imagePath)
if not image then
    print("Impossible de charger l'image (format .nfp attendu).")
    return
end

-- Echelle de texte réduite = plus de "pixels" affichables
monitor.setTextScale(0.5)

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
