package com.cnil.assistant.core.stt;

import android.content.Context;

import com.cnil.assistant.core.TaskCallback;
import com.harman.hybridnlpengine.models.FilesLocations;


public interface SpeechRecognizer {
    void init(Context context, FilesLocations filesLocations, final TaskCallback callback);
    void startVoiceRecognition(Context context, final SpeechRecognizerCallback callback);
    void stopVoiceRecognition();
    void unload();
}
