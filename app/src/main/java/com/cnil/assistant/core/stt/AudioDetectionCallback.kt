package com.cnil.assistant.core.stt

interface AudioDetectionCallback {
    fun onPauseFound()
    fun onVoiceFound()
    fun onRecordingCompleted()
}