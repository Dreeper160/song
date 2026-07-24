-- Remplace "top" par le côté où tu as posé ton modem SANS FIL
rednet.open("top")
rednet.host("jukebox", "serveur_musique")

local dfpwm = require("cc.audio.dfpwm")
local decoder = dfpwm.make_decoder()

print("Serveur Jukebox en ligne ! En attente de requêtes...")

while true do
    local id_joueur, message = rednet.receive()
    
    -- 1. Le joueur demande la liste
    if type(message) == "table" and message.action == "list" then
        local fichiers = fs.list("disk")
        local musiques = {}
        for _, f in ipairs(fichiers) do
            if f:match("%.dfpwm$") then table.insert(musiques, f) end
        end
        rednet.send(id_joueur, musiques)
        
    -- 2. Le joueur lance une musique
    elseif type(message) == "table" and message.action == "play" then
        print("Demande de lecture : " .. message.chanson)
        local file = fs.open("disk/" .. message.chanson, "rb")
        if file then
            rednet.send(id_joueur, "Lecture en cours...")
            while true do
                local chunk = file.read(16 * 1024)
                if not chunk then break end
                local buffer = decoder(chunk)
                while not peripheral.call(message.enceinte, "playAudio", buffer) do
                    os.pullEvent("speaker_audio_empty")
                end
            end
            file.close()
            print("Lecture terminée.")
        else
            rednet.send(id_joueur, "Erreur : Fichier introuvable.")
        end

    -- 3. NOUVEAU : Le PC Uploader demande d'ajouter une musique
    elseif type(message) == "table" and message.action == "upload" then
        print("Téléchargement demandé : " .. message.filename)
        rednet.send(id_joueur, "Le serveur commence le téléchargement...")
        
        -- On télécharge le fichier en mode binaire (true)
        local request = http.get(message.url, nil, true)
        
        if request then
            local content = request.readAll()
            request.close()
            
            -- On sauvegarde directement sur la disquette
            local file = fs.open("disk/" .. message.filename, "wb")
            file.write(content)
            file.close()
            
            print("Sauvegarde réussie : " .. message.filename)
            rednet.send(id_joueur, "Succès : La musique a été ajoutée à la disquette !")
        else
            print("Échec du téléchargement.")
            rednet.send(id_joueur, "Erreur : Le serveur n'a pas pu télécharger ce lien.")
        end
    end
end
