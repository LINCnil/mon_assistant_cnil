Mon assistant CNIL (iOS)
===

**Le LINC a développé un assistant vocal fonctionnant exclusivement en local, et sans connexion internet. Cette preuve de concept, «Mon Assistant CNIL », est disponible et testable sur les magasins d’applications [Android](https://play.google.com/store/apps/details?id=com.cnil.assistant) et [iOS](https://apps.apple.com/sk/app/mon-assistant-cnil/id1642545555).**

Le projet utilise le langage de programmation Swift 5

La cible de déploiement ios est iOS 13.

CocoaPods utilise comme gestionnaire de dépendances pour fournir un moyen simple d'intégrer des composants tiers courants.

L'identifiant du groupe d'applications est "com.cnil.assistant"

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

L'initialisation de la partie NLP vise à préparer le modèle pour une interaction future avec le modèle. 
* l'application charge les données du fichier clases_map.txt (pour obtenir la dépendance entre les classes de modèles NLP et les questions/réponses dans le champ d'application)
* le fichier vocab.txt (pour obtenir tous les mots possibles des questions)
* le fichier tflite (initialisation du modèle)

Au cours de la partie de prétraitement, les données d'entrée (texte) sont converties au format adapté au modèle Tensor Flow Lite. Cela se fait en utilisant la segmentation de la chaîne d'entrée afin que la chaîne initiale soit divisée en mots séparés. Chacun de ces mots (jetons) est mappé sur le chiffre de 4 octets. Ce vecteur a une longueur fixe de 120 octets (de sorte qu'il représente 30 mots ou des espaces réservés vides) et est utilisé comme entrée du modèle Tensor Flow Lite.

Dans l'étape d'inférence, le modèle Tensor Flow Lite traite l'entrée. En conséquence, il fournit un vecteur de poids de confiance pour chaque classe.

Lors de l'étape de post-traitement, le vecteur obtenu est converti en un tableau des 5 classes les mieux classées avec les niveaux de confiance respectifs. Ces 5 meilleures classes sont ensuite converties en identifiants de question mappés (remarque : si plusieurs identifiants de question correspondent à une classe, tous ces identifiants de réponse seront traités ensemble).

3. Module TTS

La fonctionnalité TTS est fournie en tant que solution hors ligne fournie par le système d'exploitation.

4. Signets

La fonctionnalité des signets dépend de l'ID de la paire question/réponse spécifiée dans les fichiers Json de l'ensemble de données. Cela signifie qu'une fois que l'utilisateur marque la paire question/réponse comme stockée dans les signets, l'application enregistre l'ID de cet élément de l'ensemble de données et utilise ensuite cet ID pour récupérer les informations correctes de question/réponse à partir des fichiers Json. Ainsi, il est nécessaire de conserver le même identifiant du couple question/réponse entre les mises à jour du jeu de données. Sinon, les modifications apportées à l'ID d'élément entraîneront un comportement incorrect de la fonctionnalité Signets.

## Procédure d'installation et de construction
Assurez-vous que les cocopods sont installés sous Mac OS

$ sudo gem installer les cocopods

Installez les dépendances dans votre projet :

$ cd <Localisation du Projet>/CNIL_Client_iOS

installation de pod $
1. Construire des schémas

    CNILAssistant -Dev : est une version réalisée à des fins de développement. L'application a une section Journaux dans les paramètres et un identifiant de bundle différent.
    CNILAssistant-Prod : est une version réalisée à des fins de production. L'application n'a pas d'options supplémentaires dans les paramètres tels que Logs et AudioLogs.

2. Exécuter via Xcode

Ouvrez CNILAssistant.xcworkspace dans Xcode.

Spécifiez l'équipe de développement

Sélectionnez l'appareil ou le simulateur, exécutez

3. Distribution sur AppStore via Xcode

Sélectionnez le schéma CNILAssistant-Prod.

Sélectionnez l'option Produit/Archive et suivez les instructions Xcode
