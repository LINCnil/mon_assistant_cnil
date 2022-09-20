package com.cnil.assistant.core.services;

import android.content.Context;

import androidx.annotation.NonNull;

import com.cnil.assistant.CnilApplication;
import com.cnil.assistant.core.TaskCallback;
import com.cnil.assistant.core.repositories.AnswerRepository;
import com.cnil.assistant.core.stt.SpeechRecognizer;
import com.cnil.assistant.models.AnswerContent;
import com.cnil.assistant.models.DataSource;
import com.cnil.assistant.models.DebugInfoModel;
import com.cnil.assistant.models.VoiceAssistantError;
import com.cnil.assistant.utils.Constants;
import com.cnil.assistant.utils.DebugLogInfoManager;
import com.cnil.assistant.utils.FileManager;
import com.cnil.assistant.utils.LogManager;

import com.harman.hybridnlpengine.IntentClassifier;
import com.harman.hybridnlpengine.models.FilesLocations;
import com.harman.hybridnlpengine.models.TopRankedNlpAnswer;

import org.json.JSONException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;


public class ProcessingService {
    private static final String FILES_LOCATIONS_PATH = "config.json";

    private final Context context;

    private final SpeechRecognizer speechRecognizer;
    private final IntentClassifier textClassifier;
    private final AnswerRepository answerRepository;

    private ProcessingServiceProcessCallback psCallback;

    private FilesLocations filesLocations;

    private String request;


    public ProcessingService(Context ctx, SpeechRecognizer sr, IntentClassifier tc, AnswerRepository ar) {
        context = ctx;

        speechRecognizer = sr;
        textClassifier = tc;
        answerRepository = ar;
    }

    public void init(TaskCallback initCallback) {
        try {
            String modelsFolderPath = context.getExternalFilesDir(null).toString().concat(Constants.ARCHIVE_FOLDER_NAME);
            String audioFolderPath = context.getExternalFilesDir(null).toString().concat(Constants.AUDIO_ARCHIVE_FOLDER_NAME);

            String storedAssetsModelsVersion = CnilApplication.readStringPreference(context,
                    Constants.SHARED_PREFERENCES_KEY_ASSETS_MODELS_VERSION, "");
            String realAssetsModelVersion = FileManager.loadJSONFromAsset(context, Constants.ASSETS_VERSION_FILE_NAME);
            if (!storedAssetsModelsVersion.equals(realAssetsModelVersion)) {
                boolean isModelFolderDeleted = true;
                boolean isAudioFolderDeleted = true;
                if (FileManager.doesFolderExist(modelsFolderPath)) {
                    isModelFolderDeleted = FileManager.deleteFolder(modelsFolderPath);
                }
                if (FileManager.doesFolderExist(audioFolderPath)) {
                    isAudioFolderDeleted = FileManager.deleteFolder(audioFolderPath);
                }

                if (isModelFolderDeleted && isAudioFolderDeleted) {
                    CnilApplication.writeStringPreference(context,
                            Constants.SHARED_PREFERENCES_KEY_ASSETS_MODELS_VERSION, realAssetsModelVersion);
                } else {
                    initCallback.onTaskCompleted(new VoiceAssistantError(VoiceAssistantError.ErrorType.INIT_FILES_DO_NOT_EXIST,
                            "ProcessingService - init(): Folder mismatch. Folder cannot be deleted"));
                    return;
                }
            }

            if (FileManager.doesFolderExist(modelsFolderPath)) {
                String configFilePath = modelsFolderPath.concat("/").concat(FILES_LOCATIONS_PATH);
                if (FileManager.doesFolderExist(configFilePath)) {
                    filesLocations = new FilesLocations(FileManager.loadJSONFromFile(modelsFolderPath.concat("/").concat(FILES_LOCATIONS_PATH)));
                } else {
                    filesLocations = new FilesLocations(FileManager.loadJSONFromAsset(context, FILES_LOCATIONS_PATH));
                    FileManager.copyAssetFileToInternalStorage(context.getAssets(), FILES_LOCATIONS_PATH, modelsFolderPath);
                    CnilApplication.writeStringPreference(
                            context, Constants.SHARED_PREFERENCES_KEY_CURRENT_INSTALLED_VERSION, filesLocations.getVersion());
                }
            } else {
                filesLocations = new FilesLocations(FileManager.loadJSONFromAsset(context, FILES_LOCATIONS_PATH));
                FileManager.copyAssetFileToInternalStorage(context.getAssets(), FILES_LOCATIONS_PATH, modelsFolderPath);
                CnilApplication.writeStringPreference(
                        context, Constants.SHARED_PREFERENCES_KEY_CURRENT_INSTALLED_VERSION, filesLocations.getVersion());
            }

            if (!verifyFilesAvailability(filesLocations)) {
                initCallback.onTaskCompleted(new VoiceAssistantError(VoiceAssistantError.ErrorType.INIT_FILES_DO_NOT_EXIST,
                        "ProcessingService - init(): Some init file(s) are missing"));
                return;
            }

            textClassifier.init(context, filesLocations, (nlpInitErrorLib) -> {
                VoiceAssistantError nlpInitError = new VoiceAssistantError(nlpInitErrorLib);
                if (nlpInitError.getErrorType().equals(VoiceAssistantError.ErrorType.NO_ERROR)) {
                    speechRecognizer.init(context, filesLocations, initCallback);
                } else {
                    initCallback.onTaskCompleted(nlpInitError);
                }
            });
        } catch (JSONException | IOException e) {
            e.printStackTrace();
            LogManager.addLog("ProcessingService - init(): Exception: " + e.getMessage());
        }
    }

    public void processData(DataSource dataSource, ProcessingServiceProcessCallback callback) {
        psCallback = callback;
        performSpeechRecognition(dataSource);
    }

    private void performSpeechRecognition(@NonNull DataSource dataSource) {
        switch (dataSource.getDataSourceType()) {
            case AUDIO_STREAM:
                speechRecognizer.startVoiceRecognition(context, this::speechRecognizerCallback);
                break;
            case TEXT:
                request = dataSource.getStringDataSource();
                performTextClassification(request);
                break;
        }
    }

    public void stopVoiceRecording() {
        speechRecognizer.stopVoiceRecognition();
    }

    private void speechRecognizerCallback(VoiceAssistantError sttError, String sttResult) {
        DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.STT, String.format("STT result: \"%1$s\"", sttResult));

        if ((sttError != null) && sttError.getErrorType().equals(VoiceAssistantError.ErrorType.NO_ERROR)) {
            request = sttResult;
            performTextClassification(sttResult);
        } else {
            psCallback.onDataProcessingCompleted(sttError, "", null);
        }
    }

    private void performTextClassification(String request) {
        textClassifier.classify(request, (nlpErrorLib, nlpResult) -> {
            VoiceAssistantError nlpError = new VoiceAssistantError(nlpErrorLib);
            if (nlpError.getErrorType().equals(VoiceAssistantError.ErrorType.NO_ERROR)) {
                performGettingAnswer(new VoiceAssistantError(VoiceAssistantError.ErrorType.NO_ERROR), nlpResult);
            } else {
                performGettingAnswer(nlpError, null);
            }
        });
    }

    private void performGettingAnswer(VoiceAssistantError nlpError, ArrayList<TopRankedNlpAnswer> nlpResult) {
        if ((nlpError != null) && nlpError.getErrorType().equals(VoiceAssistantError.ErrorType.NO_ERROR)) {
            if (nlpResult != null && nlpResult.size() > 0) {
                List<String> answerIdsList = new ArrayList<>();
                for (TopRankedNlpAnswer nlpAnswer : nlpResult) {
                    if (nlpAnswer.getQuestionIds() != null) {
                        for (Integer questionId : nlpAnswer.getQuestionIds()) {
                            answerIdsList.add(String.valueOf(questionId));
                        }
                    }
                }
                if (answerIdsList.size() > Constants.QUANTITY_OF_ANSWER) {
                    answerIdsList = answerIdsList.subList(0, Constants.QUANTITY_OF_ANSWER);
                }

                getAnswerForId(request, answerIdsList, psCallback);
            } else {
                psCallback.onDataProcessingCompleted(new VoiceAssistantError(VoiceAssistantError.ErrorType.ERROR,
                                "ProcessingService - performGettingAnswer(): Invalid NLP result"),
                        request, null);
            }
        } else {
            psCallback.onDataProcessingCompleted(nlpError, request, null);
        }
    }

    public void getAnswerForId(String requestText, List<String> answerIdsList, ProcessingServiceProcessCallback callback) {
        answerRepository.getAnswersList(context, answerIdsList, filesLocations.getFileDatasetFolderLocation(),
                (answerRepositoryError, answerRepositoryResult) -> {
                    if ((answerRepositoryError != null) &&
                            answerRepositoryError.getErrorType().equals(VoiceAssistantError.ErrorType.NO_ERROR)) {
                        logAnswersResults(answerRepositoryResult);

                        callback.onDataProcessingCompleted(new VoiceAssistantError(VoiceAssistantError.ErrorType.NO_ERROR),
                                requestText, answerRepositoryResult);
                    } else {
                        callback.onDataProcessingCompleted(answerRepositoryError, requestText, null);
                    }
                });
    }

    private void logAnswersResults(@NonNull List<AnswerContent> list) {
        StringBuilder strBuilder = new StringBuilder("Answers for ids: [");
        for (int i = 0; i < list.size(); i++) {
            AnswerContent result = list.get(i);
            strBuilder.append(String.format("%1$s, ", result.getId()));
        }
        strBuilder.delete(strBuilder.length() - 2, strBuilder.length());
        strBuilder.append("]");
        DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.DB, strBuilder.toString());
    }

    private boolean verifyFilesAvailability(@NonNull FilesLocations filesLocations) {
        String modelsFolderPath = context.getExternalFilesDir(null).toString().concat(Constants.ARCHIVE_FOLDER_NAME);
        try {
            boolean[] areAllFilesLoadedArray = new boolean[8];
            areAllFilesLoadedArray[0] = FileManager.checkIfFileIsLoaded(
                    context.getAssets(), filesLocations.getFileKeywordsLocation(), modelsFolderPath);
            areAllFilesLoadedArray[1] = FileManager.checkIfFileIsLoaded(
                    context.getAssets(), filesLocations.getFileClassesMapLocation(), modelsFolderPath);
            areAllFilesLoadedArray[2] = FileManager.checkIfFileIsLoaded(
                    context.getAssets(), filesLocations.getFileStopWordsLocation(), modelsFolderPath);
            areAllFilesLoadedArray[3] = FileManager.checkIfFileIsLoaded(
                    context.getAssets(), filesLocations.getFileVocabLocation(), modelsFolderPath);
            areAllFilesLoadedArray[4] = FileManager.checkIfFileIsLoaded(
                    context.getAssets(), filesLocations.getFileNlpModelLocation(), modelsFolderPath);
            areAllFilesLoadedArray[5] = FileManager.checkIfFileIsLoaded(
                    context.getAssets(), filesLocations.getFileSttScorerLocation(), modelsFolderPath);
            areAllFilesLoadedArray[6] = FileManager.checkIfFileIsLoaded(
                    context.getAssets(), filesLocations.getFileCrunchLocation(), modelsFolderPath);

            String questionsFolderPath = filesLocations.getFileDatasetFolderLocation().substring(
                    0, filesLocations.getFileDatasetFolderLocation().length() - 1
            );

            areAllFilesLoadedArray[7] = FileManager.loadAllFilesFromFolder(
                    context.getAssets(),
                    questionsFolderPath,
                    modelsFolderPath.concat("/").concat(questionsFolderPath));

            boolean areAllFilesLoaded = true;
            for (boolean b : areAllFilesLoadedArray) {
                if (!b) {
                    areAllFilesLoaded = false;
                    break;
                }
            }

            return areAllFilesLoaded;
        } catch (IOException e) {
            e.printStackTrace();
            LogManager.addLog("ProcessingService - verifyFilesAvailability(): Exception: " + e.getMessage());

            return false;
        }
    }

    public FilesLocations getFilesLocations() {
        return filesLocations;
    }

    public void onCleared() {
        speechRecognizer.unload();
        textClassifier.unload();
    }
}
