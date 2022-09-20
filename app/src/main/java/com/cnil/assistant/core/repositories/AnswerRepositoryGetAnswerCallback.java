package com.cnil.assistant.core.repositories;

import com.cnil.assistant.models.AnswerContent;
import com.cnil.assistant.models.VoiceAssistantError;

import java.util.List;


public interface AnswerRepositoryGetAnswerCallback {
    void onGetAnswerComplete(VoiceAssistantError answerRepositoryError, List<AnswerContent> answerRepositoryResult);
}
