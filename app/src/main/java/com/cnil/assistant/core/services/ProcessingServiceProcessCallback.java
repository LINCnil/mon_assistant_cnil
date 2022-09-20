package com.cnil.assistant.core.services;

import com.cnil.assistant.models.AnswerContent;
import com.cnil.assistant.models.VoiceAssistantError;

import java.util.List;

public interface ProcessingServiceProcessCallback {
    void onDataProcessingCompleted(VoiceAssistantError processServiceError,
                                   String request,
                                   List<AnswerContent> response);
}
