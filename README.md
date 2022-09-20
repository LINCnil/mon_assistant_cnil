Mon assistant CNIL (Outil d'entrainement)
===

**Le LINC a développé un assistant vocal fonctionnant exclusivement en local, et sans connexion internet. Cette preuve de concept, «Mon Assistant CNIL », est disponible et testable sur les magasins d’applications [Android](https://play.google.com/store/apps/details?id=com.cnil.assistant) et [iOS](https://apps.apple.com/sk/app/mon-assistant-cnil/id1642545555).**

## Objectif

Ce document décrit comment configurer l'environnement docker, télécharger et lancer l'image docker [Skill Tool](https://github.com/LINCnil/mon_assistant_cnil/releases/download/1.00/skill_tool.tar) et utiliser Skill Tool pour générer un nouveau package de mise à jour pour l'application mon assistant CNIL.

# Pour les utilisateurs Windows 10

L'ordinateur doit exécuter Microsoft Windows 10 Professionnel ou Entreprise 64 bits, ou Windows 10 Famille 64 bits avec WSL 2.

Veuillez effectuer les actions suivantes pour préparer les prochaines étapes.

    Activez la fonctionnalité "Windows Subsystem for Linux" (WSL) sur votre Windows. Exécutez la commande suivante à l'aide de Windows cmd avec des privilèges d'administration :

dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

Redémarrez ensuite votre ordinateur.

    Installez le package de mise à jour du noyau Linux WSL2 - https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi.

# Préparer l'outil d'entrainement

Ouvrez la page Web https://docs.docker.com/docker-for-windows/install/et cliquez sur le bouton "Télécharger depuis Docker Hub", puis sur le bouton "Obtenir Docker".

Télécharger l'[image](https://github.com/LINCnil/mon_assistant_cnil/releases/download/1.00/skill_tool.tar) puis exécuter la commande suivante depuis un terminal :

docker load --input "PATH/TO/DOWNLOADED/TAR/skill_tool.tar"


# Executer l'outil d'entrainement

Exécutez la commande suivante depuis un termina :

docker run -v "CHEMIN/TO/THE/MOUNT/FOLDER:/mount/source/" -it skill_tool

Lorsque vous utilisez l'argument -v, vous spécifiez le chemin d'accès au point de montage de l'image docker. Tous les fichiers contenus dans ce dossier (PATH/TO/THE/MOUNT/FOLDER) sont disponibles dans l'image docker à partir de ce chemin (/mount/source/), donc à l'intérieur de ce dossier, vous devriez avoir un ensemble de données à partir duquel vous souhaitez vous entraîner nouveau package de mise à jour.

Pour voir tous les arguments attendus de l'outil Skill Tool avec la description, exécutez la commande suivante  :

./skill_tool -h

# Générer un nouveau modèle pour l'assistant

Pour générer un nouveau package de mise à jour et de le télécharger sur le serveur, vous devez utiliser la commande suivante :

./skill_tool --path_to_dataset PATH/TO/FOLDER/WITH/DATASET/FILES/RELATIVE/MOUNT/POINT --path_to_crt PATH/TO/FILE/.crt --path_to_key PATH/TO/FILE/.key --server_address SERVER/ IP/ADRESSE : PORT

Si vous ne spécifiez pas le chemin d'accès aux fichiers de certificat et l'adresse du serveur, Skill Tool ne tentera pas de télécharger un package de mise à jour sur le serveur.

Par défaut, un package de mise à jour sera supprimé après avoir été téléchargé avec succès sur le serveur. Si, pour une raison quelconque, le package de mise à jour n'est pas téléchargé sur le serveur, il sera stocké au même emplacement que celui où vous lancez Skill Tool.

# Enregistrer et mettre à jour le modèle

Pour enregistrer un package de mise à jour une fois le processus d'entrainement , vous devez ajouter l'argument « --path_to_save_folder » :

./skill_tool --path_to_dataset PATH/TO/FOLDER/WITH/DATASET/FILES/RELATIVE/MOUNT/POINT --path_to_crt PATH/TO/FILE/.crt --path_to_key PATH/TO/FILE/.key --server_address SERVER/ IP/ADDRES:SERVER/PORT --path_to_save_folder PATH/WHERE/YOU/WISH/SAVE/UPDATE/PACKAGE

# Spécifier une version de package de mise à jour

Si vous souhaitez appliquer une version spécifique au package de mise à jour, vous pouvez utiliser l'argument de ligne de commande "--package_version" :

./skill_tool --path_to_dataset PATH/TO/FOLDER/WITH/DATASET/FILES/RELATIVE/MOUNT/POINT --path_to_crt PATH/TO/FILE/.crt --path_to_key PATH/TO/FILE/.key --server_address SERVER/ IP/ADDRES:SERVER/PORT --package_version PREFERRED/VERSION/NAME/OF/THE/UPDATE/PACKAGE/

# Utiliser un fichier de configuration pour spécifier les paramètres d'entrainement

Vous pouvez spécifier tous les paramètres d'entrée de Skill Tool dans un fichier de configuration. 

Pour permettre à Skill Tool de lire ce fichier, vous pouvez le placer sur le point de montage. Pour demander à Skill Tool de prendre tous les paramètres d'entrée du fichier de configuration, vous pouvez utiliser l'argument de ligne de commande "--config" et remplir le fichier de configuration.

Exemple de ligne de commande :

./skill_tool –config /mount/source/config.json

Exemple de fichier de configuration :

{

"package_version": nul,

"path_to_crt": "/mount/source/cert_cnil/cnil_upload.crt",

"path_to_key": "/mount/source/cert_cnil/cnil_upload.key",

"path_to_save_folder": nul,

"adresse_serveur": "127.0.0.1:8448",

"path_to_dataset": "/mount/source/applicationCNIL-questions/"

}

# Télécharger le package de mise à jour existant et les fichiers audio TTS sur le serveur

Pour télécharger le package de mise à jour existant sans lancer d'entrainement, vous devez utiliser l'argument de ligne de commande "--path_to_update_package" :
./skill_tool --path_to_update_package /PATH/TO/EXISTING/UPDATE/PACKAGE/model.zip --path_to_tts_files /PATH/TO/EXISTING/AUDIO/FILES/.audio.zip --path_to_crt PATH/TO/FILE/.crt - -path_to_key PATH/TO/FILE/.key --server_address SERVER/IP/ADDRES:SERVER/PORT

