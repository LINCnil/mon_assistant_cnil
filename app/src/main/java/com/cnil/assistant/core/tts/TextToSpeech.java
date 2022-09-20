package com.cnil.assistant.core.tts;

import android.content.Context;

import com.cnil.assistant.core.TaskCallback;


public interface TextToSpeech {
    void init(Context context, final TaskCallback callback);
    void startSpeech(String requestId, Context context, final TaskCallback callback);
    void stopSpeech();
    void playPauseSpeech();
    boolean getIsAudioPlaying();
    boolean getIsAudioConfigured();
    void unload();
}
