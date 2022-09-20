Mon assistant CNIL (Android)
===

**Le LINC a développé un assistant vocal fonctionnant exclusivement en local, et sans connexion internet. Cette preuve de concept, «Mon Assistant CNIL », est disponible et testable sur les magasins d’applications [Android](https://play.google.com/store/apps/details?id=com.cnil.assistant) et [iOS](https://apps.apple.com/sk/app/mon-assistant-cnil/id1642545555).**

## Architecture
L'architecture MVVM est utilisée pour séparer les objets en trois groupes d'abstraction distincts:
•	View est responsable de la couche d'interface utilisateur et de l'interaction avec l'utilisateur (afficher les données, capturer les entrées de l'utilisateur). Les données d'entrée peuvent être capturées sous forme de fichier audio ou de texte.
•	Les modèles de vue transforment les informations du modèle en valeurs pouvant être affichées sur une vue. Et rassembler les données d'entrée et les transmettre pour traitement au modèle
•	Les modèles contiennent la logique métier de l'application. Ce sont généralement des structures ou des classes simples.


La couche Modèle est conçue comme une architecture de microservices. La partie principale est ProcessingService qui est responsable du traitement du pipeline de l'assistant vocal : les données d'entrée sont traitées via les modules suivants :
1.	Le fichier audio d'entrée est traité par le moteur STT 
2.	sortie de texte STT  ou le texte d'entrée est traité par le module NLP 
3.	La sortie NLP est utilisée pour obtenir une réponse textuelle à la question de l'utilisateur. L'extraction du texte sera effectuée par AnswersRepository . Le modèle de référentiel est ciblé pour encapsuler la logique d'interaction avec les données, comme JSON, CSV, SQLITE
4.	La réponse finale est utilisée pour obtenir la représentation audio respective 
Une fois que les formats texte et audio de la réponse sont prêts, la partie Service de l'application transmet ces données à la couche supérieure ( ViewModel ).

L'application offre également la possibilité de télécharger de nouveaux modèles STT, NLP et des fichiers audio à partir d'un serveur distant. 

## Détails internes des modules

1. Module STT

La fonctionnalité STT est présentée dans l'application sous la forme d'une bibliothèque C avec des liaisons JNI. Le modèle Mozilla DeepSpeech est alimenté par TensorflowLite et est utilisé pour la reconnaissance vocale.

La bibliothèque STT comprend des méthodes d'initialisation et d'inférence de modèle.

L'initialisation de la partie STT vise à préparer le modèle pour une interaction future. À ce stade:

* l'application charge les données du fichier kenlm.scorer (initialisation du modèle linguistique)

* deepspeech-models.tflite (initialisation du modèle acoustique)

Dans l'étape d'inférence, le modèle Tensor Flow Lite traite l'entrée au format d'un fichier audio ou d'un flux audio. La sortie du résultat est un texte reconnu. La sortie de la partie STT est considérée comme une entrée pour le module NLP dans le pipeline de traitement.
2. Module PNL

La fonctionnalité NLP est présentée dans l'application sous la forme d'un modèle de classificateur d'intention TensorFlow Lite (initialisation, inférence) et d'un ensemble de méthodes de prétraitement et de post-traitement.

L'initialisation de la partie NLP vise à préparer le modèle pour une interaction future avec le modèle. À ce stade:

    l'application charge les données du fichier clases_map.txt (pour obtenir la dépendance entre les classes de modèles NLP et les questions/réponses dans le champ d'application)
    fichier vocab.txt (pour obtenir tous les mots possibles des questions en question)
    tflite (initialisation du modèle lui-même)

Au cours de la partie de prétraitement, les données d'entrée (texte) sont converties au format adapté au modèle Tensor Flow Lite. Cela se fait en utilisant la segmentation de la chaîne d'entrée afin que la chaîne initiale soit divisée en mots séparés. Chacun de ces mots (jetons) est mappé sur le chiffre de 4 octets. Ce vecteur a une longueur fixe de 120 octets (de sorte qu'il représente 30 mots ou des espaces réservés vides) et est utilisé comme entrée du modèle Tensor Flow Lite.

Dans l'étape d'inférence, le modèle Tensor Flow Lite traite l'entrée. En conséquence, il fournit un vecteur de poids de confiance pour chaque classe.

Lors de l'étape de post-traitement, le vecteur obtenu est converti en un tableau des 5 classes les mieux classées avec les niveaux de confiance respectifs. Ces 5 meilleures classes sont ensuite converties en identifiants de question mappés (remarque : si plusieurs identifiants de question correspondent à une classe, tous ces identifiants de réponse seront traités ensemble).

3. Module TTS

La fonctionnalité TTS est fournie sous la forme d'un ensemble intégré de fichiers audio placés dans le dossier "Assets" de l'application (dossiers "FEMALE_TTS_AUDIO_FILES", "MALE_TTS_AUDIO_FILES"). Les fichiers audio peuvent être mis à jour à partir du serveur lorsque la nouvelle version des modèles et des fichiers audio est disponible.

4. Signets

La fonctionnalité des signets dépend de l'ID de la paire question/réponse spécifiée dans les fichiers Json de l'ensemble de données. Cela signifie qu'une fois que l'utilisateur marque la paire question/réponse comme stockée dans les signets, l'application enregistre l'ID de cet élément de l'ensemble de données et utilise ensuite cet ID pour récupérer les informations correctes de question/réponse à partir des fichiers Json. Ainsi, il est nécessaire de conserver le même identifiant du couple question/réponse entre les mises à jour du jeu de données. Sinon, les modifications apportées à l'ID d'élément entraîneront un comportement incorrect de la fonctionnalité Signets.

## Procédure d'installation et de construction

Installez Android Studio et ouvrez le projet  via le menu "Fichier" -> "Ouvrir" ou "Ouvrir un projet Android Studio existant" . Sélectionnez le dossier racine du projet « CNIL_Client_Android ».

Installez le SDK Android et les plugins requis. Configuration cible :

    Plate-forme SDK Android 11.0 (API niveau 30)
    Outils de construction du SDK Android 31-rc1
    Plate-forme Android SDK-Outils v30.0.5
    Plugin Kotlin (version 1.4.31-release-Studio4.1-1)

D'autres configurations sont possibles mais peuvent nécessiter des étapes supplémentaires ou des changements de procédure par rapport à l'instruction actuelle.

Effectuez l'opération "Synchroniser le projet avec les fichiers Gradle" en sélectionnant le menu "Fichier" dans le coin supérieur gauche -> option "Synchroniser le projet avec les fichiers Gradle". Attendez que l'opération de synchronisation soit terminée.

 1. Pour intégrer de nouveaux fichiers de modèle à l'application :

Si de nouveaux fichiers de modèle de Skill Tool doivent être intégrés dans une nouvelle version d'Android, les étapes suivantes sont nécessaires :

    Obtenez une archive zip de modèle avec des modèles de Skill Tool

    Décompressez l'archive de l'étape 1.

    Ouvrez le dossier décompressé à l'étape 2.

    Vérifiez que la version de l'architecture spécifiée dans le fichier "version.txt" (par exemple, v1.1_update_21-04-08_11-58-24, où "1.1" est la version de l'architecture) correspond à la version spécifiée dans l'application dans le fichier CNIL_Client_Android\app\src\main\java\com\cnil\assistant\utils\Constants.java, champ constant SUPPORTED_ARCHITECTURE_VERSION (par exemple public static final double SUPPORTED_ARCHITECTURE_VERSION = 1.1 ;)

Si la version est la même - passez à l'étape suivante.

Si la version ne correspond pas, ces fichiers ne sont pas compatibles avec cette version de l'application. Ne poursuivez pas l'intégration de ces fichiers. Obtenez des fichiers avec une version spécifiée dans l'application.

    Ouvrez le dossier "CNIL_Client_Android\app\src\main\assets" dans l'emplacement du code source de l'application

    Supprimez dans "CNIL_Client_Android\app\src\main\assets" les dossiers nommés "NLP", "QUESTIONS", "STT" et le fichier nommé "config.json"

    Ouvrez le dossier décompressé de l'étape 3 et sélectionnez les dossiers "NLP", "QUESTIONS", "STT" et le fichier "config.json".

    Copiez les fichiers sélectionnés à l'étape 7 dans le dossier du code source de l'application : CNIL_Client_Android\app\src\main\assets

    Générez l'application en suivant la procédure de génération habituelle décrite précédemment.

Pour intégrer de nouveaux fichiers audio de Skill Tool à la nouvelle version d'Android, les étapes suivantes sont nécessaires : 

    Obtenir une archive audio zip avec des modèles de Skill Tool

    Décompressez l'archive des fichiers audio de l'étape 10.

    Ouvrez le dossier décompressé à l'étape 11.

    Ouvrez le dossier "CNIL_Client_Android\app\src\main\assets" dans l'emplacement du code source de l'application

    Supprimez dans "CNIL_Client_Android\app\src\main\assets" les dossiers nommés "FEMALE_TTS_AUDIO_FILES", "MALE_TTS_AUDIO_FILES" et le fichier nommé "audio_config.json"

    Ouvrez le dossier décompressé de l'étape 12 et sélectionnez les dossiers nommés "FEMALE_TTS_AUDIO_FILES", "MALE_TTS_AUDIO_FILES" et le fichier nommé "audio_config.json"

l' application : CNIL_Client_Android\app\src\main\assets construire.

2. Pour exécuter l'application sur un appareil :

Dans l'onglet "variante de construction" à gauche, choisissez la variante souhaitée pour le module d'application :

    devDebug : est une version conçue à des fins de débogage. L'application a une section Journaux dans les paramètres.
    dev Release : est une version conçue à des fins de production. L'application a une section Journaux dans les paramètres.
    prodDebug : est une version conçue à des fins de débogage. L'application n'a pas de section Journaux dans les paramètres.
    dev Release : est une version conçue à des fins de production. L'application n'a pas de section Journaux dans les paramètres.

Sélectionnez l'option "application" dans le menu en haut de l'écran et l'appareil cible sur lequel l'application doit être lancée.

Si la variante de construction "Debug" est sélectionnée, cliquez sur le bouton "Bug" pour exécuter l'application sur un appareil.

Avant de procéder avec l'option "release", votre configuration de signature doit être fournie. Pour ce faire, allez dans le menu "Fichier" -> "Structure du projet" -> "Modules" -> "Configurations de signature". Cliquez sur le bouton + pour créer une nouvelle configuration de signature, donnez le nom à cette configuration et remplissez les champs avec la date de signature des détails du certificat et spécifiez le chemin vers le certificat lui-même dans le champ "Fichier de stockage".

Passez ensuite au menu "Fichier" -> "Structure du projet" -> "Modules" -> vignette "Configuration par défaut" -> champ "Configuration de signature" et sélectionnez la configuration de signature créée dans la liste déroulante.


Ensuite, allez dans le menu "Fichier" -> "Structure du projet" -> "Variantes de construction" -> "Types de construction", sélectionnez la configuration de la version et assurez-vous que la configuration nouvellement créée est définie sur "Configuration de signature". Si ce n'est pas le cas, sélectionnez-le dans la liste déroulante.

Appuyez sur le bouton "Jouer".

Après le processus de construction, l'application doit être lancée sur l'appareil respectif.

3. Pour créer un fichier d'application de version :

Pour préparer le document pour la sortie de GooglePlay, la version de sortie doit être créée et signée.

Ouvrez "Build" -> "Générer un bundle signé ou APK" -> APK. Remplissez la liste en fonction de la capture d'écran ci-dessous (pour le chemin Keystore, veuillez sélectionner l'emplacement du fichier de certificat sur votre ordinateur). Le mot de passe du magasin de clés et le mot de passe de la clé seront fournis séparément.

Cliquez sur le bouton "Suivant" et sélectionnez la variante de construction "libérer". La version de la signature doit être "V2 (Full APK Signature)". Cliquez sur le bouton "Terminer". Le processus de construction Gradle s'exécutera (jusqu'à plusieurs minutes). L'état sera affiché en bas de la fenêtre d'Android Studio. Une fois le processus terminé, cliquez sur la vignette "Générer un APK signé" dans le coin inférieur droit et cliquez sur le lien "Localiser".

Dans la fenêtre ouverte de l'explorateur de fichiers, sélectionnez le dossier "release". Le fichier nommé "CNIL_VA_XX.XX.XXX.apk" est un fichier signé de version souhaité (XX.XX.XXX est une version spécifiée dans le fichier Gradle).

