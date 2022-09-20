package com.cnil.assistant.core.stt

interface AudioRecorderPauseDetectionCallback {
    fun onRecordingCompleted()
    fun onRecordingStopped()
}