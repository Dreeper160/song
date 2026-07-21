-- Trouve le haut-parleur connecté
local speaker = peripheral.find("speaker")
if not speaker then
    error("Erreur : Aucun speaker trouvé !")
end

-- Charge l'API de décodage
local dfpwm = require("cc.audio.dfpwm")
local decoder = dfpwm.make_decoder()

-- Ouvre le fichier depuis la disquette en mode binaire ("rb")
-- /!\ Remplace "morceau.dfpwm" par le nom exact de ton fichier
local file = fs.open("disk/morceau.dfpwm", "rb")
if not file then
    error("Erreur : Fichier introuvable sur le disque.")
end

print("Lecture en cours...")

-- Boucle de lecture par blocs
while true do
    local chunk = file.read(16 * 1024) -- Lit 16 ko à la fois
    if not chunk then break end

    local buffer = decoder(chunk)

    -- Tente d'envoyer l'audio. Si le buffer du speaker est plein, on attend qu'il se vide.
    while not speaker.playAudio(buffer) do
        os.pullEvent("speaker_audio_empty")
    end
end

file.close()
print("Lecture terminée !")
