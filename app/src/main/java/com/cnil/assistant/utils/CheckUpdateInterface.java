package com.cnil.assistant.utils;

import com.cnil.assistant.models.ServerMetadataJsonResponse;
import com.cnil.assistant.models.VoiceAssistantError;


public interface CheckUpdateInterface {
    void OnCheckResult(VoiceAssistantError checkUpdateError, ServerMetadataJsonResponse metadataJson);
}
