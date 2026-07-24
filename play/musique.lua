-- Remplace "top" par le côté où tu as posé le modem SANS FIL
rednet.open("top")

-- Cherche le serveur principal par radio
local id_serveur = rednet.lookup("jukebox", "serveur_musique")
if not id_serveur then
    error("Impossible de se connecter au Serveur Jukebox.")
end

-- 1. Demande la liste des musiques au serveur
rednet.send(id_serveur, {action = "list"})
local id, liste = rednet.receive(3) -- Attend la réponse 3 secondes max

if not liste or #liste == 0 then
    error("Aucune musique trouvée sur le serveur.")
end

-- 2. Affiche le menu
print("=== Musiques du Serveur ===")
for i, nom in ipairs(liste) do
    print(i .. " - " .. nom)
end

print("\nEntrez le numéro de la musique :")
local choix = tonumber(read())

if not choix or choix < 1 or choix > #liste then
    error("Choix invalide.")
end

-- 3. Demande à l'utilisateur quelle est son enceinte
-- (Le joueur doit taper le nom exact qui s'est affiché quand il a allumé le modem filaire du Speaker)
print("Entrez l'ID de l'enceinte de votre chambre (ex: speaker_0) :")
local nom_enceinte = read()

-- 4. Envoie l'ordre de lecture au serveur
local chanson_choisie = liste[choix]
rednet.send(id_serveur, { action = "play", chanson = chanson_choisie, enceinte = nom_enceinte })

-- Affiche la confirmation
local id, reponse = rednet.receive(3)
print("Serveur : " .. tostring(reponse))
