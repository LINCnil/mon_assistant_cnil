package com.cnil.assistant.core;


import com.cnil.assistant.models.VoiceAssistantError;

public interface TaskCallback {
    void onTaskCompleted(VoiceAssistantError error);
}
