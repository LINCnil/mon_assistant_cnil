package com.cnil.assistant.core.stt;

import com.cnil.assistant.models.VoiceAssistantError;

public interface SpeechRecognizerCallback {
    void onSpeechRecognitionComplete(VoiceAssistantError sttError, String sttResult);
}
