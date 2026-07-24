-- Remplace "top" par le côté où tu as posé ton modem SANS FIL
rednet.open("top")
rednet.host("jukebox", "serveur_musique")

local dfpwm = require("cc.audio.dfpwm")
local decoder = dfpwm.make_decoder()

print("Serveur Jukebox en ligne ! En attente de requêtes...")

while true do
    -- Attente d'un message réseau par ondes radio
    local id_joueur, message = rednet.receive()
    
    -- Si le joueur demande la liste des musiques
    if type(message) == "table" and message.action == "list" then
        local fichiers = fs.list("disk")
        local musiques = {}
        for _, f in ipairs(fichiers) do
            if f:match("%.dfpwm$") then table.insert(musiques, f) end
        end
        rednet.send(id_joueur, musiques)
        
    -- Si le joueur demande de jouer une musique
    elseif type(message) == "table" and message.action == "play" then
        print("Demande reçue : " .. message.chanson .. " pour " .. message.enceinte)
        
        local file = fs.open("disk/" .. message.chanson, "rb")
        if file then
            rednet.send(id_joueur, "Lecture en cours dans la chambre...")
            
            while true do
                local chunk = file.read(16 * 1024)
                if not chunk then break end
                local buffer = decoder(chunk)
                
                -- Envoie l'audio dans les câbles (Wired Modem) jusqu'à l'enceinte
                while not peripheral.call(message.enceinte, "playAudio", buffer) do
                    os.pullEvent("speaker_audio_empty")
                end
            end
            file.close()
            print("Lecture terminée.")
        else
            rednet.send(id_joueur, "Erreur : Fichier introuvable sur le disque du serveur.")
        end
    end
end
