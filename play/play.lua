-- Trouve le haut-parleur connecté
local speaker = peripheral.find("speaker")
if not speaker then
    error("Erreur : Aucun speaker trouvé !")
end

-- Vérifie que le disque est bien présent
local diskPath = "disk"
if not fs.exists(diskPath) or not fs.isDir(diskPath) then
    error("Erreur : Aucune disquette trouvée (le dossier 'disk' n'existe pas).")
end

-- 1. Récupère et filtre les musiques
local files = fs.list(diskPath)
local musiques = {}

for _, file in ipairs(files) do
    if file:match("%.dfpwm$") then
        table.insert(musiques, file)
    end
end

if #musiques == 0 then
    print("Aucun fichier .dfpwm trouvé sur le disque.")
    return
end

-- 2. Affiche le menu
print("=== Musiques disponibles ===")
for i, file in ipairs(musiques) do
    print(i .. " - " .. file)
end

print("\nEntrez le numéro de la musique :")
local input = read()
local choix = tonumber(input)

-- Vérifie si l'entrée est valide
if not choix or choix < 1 or choix > #musiques then
    error("Choix invalide, annulation.")
end

local fichierChoisi = musiques[choix]
local cheminComplet = fs.combine(diskPath, fichierChoisi)

-- 3. Lecture de l'audio
local dfpwm = require("cc.audio.dfpwm")
local decoder = dfpwm.make_decoder()

local file = fs.open(cheminComplet, "rb")
if not file then
    error("Erreur lors de l'ouverture du fichier.")
end

print("Lecture en cours : " .. fichierChoisi)

-- Boucle de lecture par blocs
while true do
    local chunk = file.read(16 * 1024)
    if not chunk then break end

    local buffer = decoder(chunk)

    while not speaker.playAudio(buffer) do
        os.pullEvent("speaker_audio_empty")
    end
end

file.close()
print("Lecture terminée !")
