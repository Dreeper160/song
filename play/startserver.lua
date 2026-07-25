-- Remplace "top" par le côté où tu as posé ton modem SANS FIL
rednet.open("top")
rednet.host("jukebox", "serveur_musique")

local dfpwm = require("cc.audio.dfpwm")
local decoder = dfpwm.make_decoder()

-- Ce tableau va mémoriser quelles enceintes jouent quelle musique
-- Exemple : lectures["speaker_0"] = fichier_ouvert
local lectures = {}

print("Serveur Multitâche en ligne ! Prêt à gérer plusieurs chambres.")

while true do
    -- Le serveur se met en pause et attend n'importe quel événement
    local event, param1, param2, param3 = os.pullEvent()

    ----------------------------------------------------
    -- 1. SI ON REÇOIT UN MESSAGE RÉSEAU (Télécommande)
    ----------------------------------------------------
    if event == "rednet_message" then
        local id_joueur = param1
        local message = param2

        if type(message) == "table" then
            
            -- Action : LIGNE DES MUSIQUES
            if message.action == "list" then
                local fichiers = fs.list("disk")
                local musiques = {}
                for _, f in ipairs(fichiers) do
                    if f:match("%.dfpwm$") then table.insert(musiques, f) end
                end
                rednet.send(id_joueur, musiques)
                
            -- Action : JOUER UNE MUSIQUE
            elseif message.action == "play" then
                -- Si une musique joue déjà dans cette chambre, on la coupe
                if lectures[message.enceinte] then
                    lectures[message.enceinte].close()
                    peripheral.call(message.enceinte, "stop")
                end

                local file = fs.open("disk/" .. message.chanson, "rb")
                if file then
                    lectures[message.enceinte] = file
                    -- On envoie juste le premier bout de son pour amorcer la pompe
                    local chunk = file.read(16 * 1024)
                    if chunk then
                        peripheral.call(message.enceinte, "playAudio", decoder(chunk), 3.0)
                        rednet.send(id_joueur, "Lecture en cours...")
                    end
                else
                    rednet.send(id_joueur, "Erreur : Fichier introuvable.")
                end
                
            -- Action : AJOUTER UNE MUSIQUE (Upload)
            elseif message.action == "upload" then
                rednet.send(id_joueur, "Le serveur commence le téléchargement...")
                local request = http.get(message.url, nil, true)
                if request then
                    local content = request.readAll()
                    request.close()
                    local file = fs.open("disk/" .. message.filename, "wb")
                    file.write(content)
                    file.close()
                    rednet.send(id_joueur, "Succès : La musique a été ajoutée !")
                else
                    rednet.send(id_joueur, "Erreur lors du téléchargement.")
                end
            end
        end

    ----------------------------------------------------
    -- 2. SI UNE ENCEINTE A FINI SON EXTRAIT AUDIO
    ----------------------------------------------------
    elseif event == "speaker_audio_empty" then
        local nom_enceinte = param1
        local file = lectures[nom_enceinte]

        -- Si on a bien une musique en cours pour cette enceinte précise
        if file then
            local chunk = file.read(16 * 1024)
            
            if chunk then
                -- On lui envoie la suite du morceau
                peripheral.call(nom_enceinte, "playAudio", decoder(chunk), 3.0)
            else
                -- Le morceau est terminé, on ferme le fichier
                file.close()
                lectures[nom_enceinte] = nil
            end
        end
    end
end
