-- Remplace "top" par la face de ton modem SANS FIL
rednet.open("top")

local id_serveur = rednet.lookup("jukebox", "serveur_musique")
if not id_serveur then
    error("Erreur : Serveur Jukebox introuvable sur le réseau.")
end

print("=== Ajout d'une nouvelle musique ===")
print("Collez le lien direct (ex: catbox.moe) avec le clic molette :")
local lien = read()

print("\nQuel nom donner au fichier ? (ex: musique1.dfpwm) :")
local nom = read()

-- Petite sécurité au cas où tu oublies l'extension à la fin
if not nom:match("%.dfpwm$") then
    nom = nom .. ".dfpwm"
end

-- On envoie le lien et le nom au serveur
rednet.send(id_serveur, { action = "upload", url = lien, filename = nom })

-- On attend la confirmation du début du téléchargement
local id1, rep1 = rednet.receive(5)
if rep1 then
    print("\nServeur : " .. tostring(rep1))
end

-- On attend la confirmation de la fin du téléchargement (20 secondes max)
print("Veuillez patienter...")
local id2, rep2 = rednet.receive(20)
if rep2 then
    print("Serveur : " .. tostring(rep2))
else
    print("Temps d'attente dépassé, mais le téléchargement continue peut-être en arrière-plan.")
end
