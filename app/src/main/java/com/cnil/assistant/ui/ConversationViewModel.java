package com.cnil.assistant.ui;

import android.content.Context;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.cnil.assistant.core.TaskCallback;
import com.cnil.assistant.core.repositories.AnswerRepositoryImplementation;
import com.cnil.assistant.core.services.ProcessingService;
import com.cnil.assistant.core.services.ProcessingServiceProcessCallback;
import com.cnil.assistant.core.stt.MozillaSpeechRecognizer;
import com.cnil.assistant.core.tts.TextToSpeech;
import com.cnil.assistant.core.tts.TextToSpeechOggEngine;
import com.cnil.assistant.models.AnswerContent;
import com.cnil.assistant.models.ConversationModel;
import com.cnil.assistant.models.DataSource;
import com.cnil.assistant.models.DebugInfoModel;
import com.cnil.assistant.models.VoiceAssistantError;
import com.cnil.assistant.utils.DebugLogInfoManager;
import com.cnil.assistant.utils.Utils;
import com.harman.hybridnlpengine.HybridNlpEngine;
import com.harman.hybridnlpengine.models.FilesLocations;
import com.harman.hybridnlpengine.nlp.HybridTFAndKWClassifier;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;


public class ConversationViewModel extends ViewModel {
    public enum ConversationStateEnum {
        INIT,
        INIT_FINISHED,
        LISTENING,
        PROCESSING,
        IDLE,
    }

    private final MutableLiveData<ArrayList<ConversationModel>> conversationModelArrayListLiveData = new MutableLiveData<>();
    private final ArrayList<ConversationModel> conversationModelArrayList = new ArrayList<>();

    private final MutableLiveData<ConversationStateEnum> conversationStateLiveData = new MutableLiveData<>();

    private int requestsCount = 0;

    private ProcessingService processingService;
    private TextToSpeech textToSpeechEngine;


    public LiveData<ArrayList<ConversationModel>> getConversationModelArrayListLiveData() {
        return conversationModelArrayListLiveData;
    }

    public LiveData<ConversationStateEnum> getConversationStateLiveData() {
        return conversationStateLiveData;
    }

    public void init(Context context) {
        if (processingService != null) {
            return;
        }

        conversationStateLiveData.postValue(ConversationStateEnum.INIT);

        DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.COMMON, "INIT started");
        DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.COMMON, Utils.logAppLaunchDetails(context));

        HybridNlpEngine.sharedInstance().addDebugLogCallback(
                (text) -> DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.NLP, text)
        );

        processingService = new ProcessingService(context,
                new MozillaSpeechRecognizer(),
                new HybridTFAndKWClassifier(MainActivity.getExecutorService()),
                new AnswerRepositoryImplementation(MainActivity.getExecutorService()));
        textToSpeechEngine = TextToSpeechOggEngine.getTtsInstance(MainActivity.getExecutorService());

        processingService.init((processServiceError) ->
                ((MainActivity) context).runOnUiThread(() -> {
                    if ((processServiceError != null) &&
                            processServiceError.getErrorType().equals(VoiceAssistantError.ErrorType.NO_ERROR)) {
                        DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.COMMON,
                                "INIT processing service finished successfully");
                        initTts(context);
                    } else {
                        conversationStateLiveData.postValue(ConversationStateEnum.IDLE);
                        DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.COMMON,
                                String.format("INIT finished with error: %1$s", Objects.requireNonNull(processServiceError).getErrorMessage()));
                    }
                })
        );
    }

    private void initTts(Context context) {
        textToSpeechEngine.init(context, (ttsInitError) -> {
                if ((ttsInitError != null) &&
                        ttsInitError.getErrorType().equals(VoiceAssistantError.ErrorType.NO_ERROR)) {
                    DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.COMMON, "TTS INIT finished successfully");
                } else {
                    DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.COMMON,
                            String.format("INIT finished with TTS error: %1$s", ttsInitError != null ? ttsInitError.getErrorMessage() : ""));
                }
                conversationStateLiveData.postValue(ConversationStateEnum.INIT_FINISHED);
            }
        );
    }

    public void handleText(String utterance) {
        switch (Objects.requireNonNull(conversationStateLiveData.getValue())) {
            case INIT_FINISHED:
            case IDLE:
                if (utterance != null && utterance.trim().length() > 0) {
                    conversationStateLiveData.postValue(ConversationStateEnum.PROCESSING);
                    process(new DataSource(utterance));
                }
                break;
            default:
                break;
        }
    }

    public void handleRecording() {
        switch (Objects.requireNonNull(conversationStateLiveData.getValue())) {
            case INIT_FINISHED:
            case IDLE:
                conversationStateLiveData.postValue(ConversationStateEnum.LISTENING);
                startVoiceRecording();
                break;
            case LISTENING:
                conversationStateLiveData.postValue(ConversationStateEnum.PROCESSING);
                stopVoiceRecording();
                break;
            default:
                break;
        }
    }

    private void startVoiceRecording() {
        process(new DataSource());
    }

    private void stopVoiceRecording() {
        processingService.stopVoiceRecording();
    }

    private void process(DataSource requestDataSource) {
        DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.COMMON, "Start processing");
        processingService.processData(requestDataSource, this::processingResultHandler);
    }

    public void getAnswerForId(String requestText, String answerId, ProcessingServiceProcessCallback processingCallback) {
        conversationStateLiveData.postValue(ConversationStateEnum.PROCESSING);
        processingService.getAnswerForId(requestText,
                Collections.singletonList(answerId),
                (processServiceError, requestString, answerContentList) -> {
                    processingCallback.onDataProcessingCompleted(processServiceError, requestString, answerContentList);
                    conversationStateLiveData.postValue(ConversationStateEnum.INIT_FINISHED);
                });
    }

    private void processingResultHandler(VoiceAssistantError processServiceError,
                                         String requestText,
                                         List<AnswerContent> response) {
        conversationModelArrayList.clear();

        if ((processServiceError != null) && processServiceError.getErrorType().equals(VoiceAssistantError.ErrorType.NO_ERROR) &&
                response != null) {
            DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.COMMON, "Success");

            conversationModelArrayList.add(
                    new ConversationModel(requestsCount++, requestText, response, ConversationModel.ConversationType.ANSWER));
        } else {
            DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.COMMON, String.format("Fail: Error has happened: %1$s",
                    (processServiceError != null ? processServiceError.getErrorMessage() : null)));

            conversationModelArrayList.add(new ConversationModel(requestsCount++, requestText == null ? "" : requestText, null,
                    ConversationModel.ConversationType.ANSWER_REQUEST_FAILED));
        }

        conversationModelArrayListLiveData.postValue(conversationModelArrayList);
        conversationStateLiveData.postValue(ConversationStateEnum.IDLE);
    }

    public void reloadModels(TaskCallback initCallback) {
        if (processingService != null) {
            processingService.onCleared();
            processingService.init(initCallback);
        }
    }

    public FilesLocations getFilesLocations() {
        return processingService.getFilesLocations();
    }

    @Override
    public void onCleared() {
        if (processingService != null) {
            processingService.onCleared();
        }
        if (textToSpeechEngine != null) {
            textToSpeechEngine.unload();
        }
    }
}

