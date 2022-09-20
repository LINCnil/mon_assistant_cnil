package com.cnil.assistant.core.stt

interface AudioRecorderCallback {
    fun onAudioBufferAvailable(audioBuffer: ShortArray)
}