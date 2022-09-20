package com.cnil.assistant.core.stt

import android.os.CountDownTimer
import com.cnil.assistant.utils.LogManager

const val DEFAULT_AUDIO_LENGTH_MILLIS = 15000L
const val SILENCE_MILLIS = 5000L
const val PAUSE_MILLIS = 2000L


class AudioRecorderPauseDetection(sampleRate: Int) : AudioRecorder(sampleRate) {

    var audioRecorderPauseDetectionCallback: AudioRecorderPauseDetectionCallback? = null

    private var isVoiceRecordingTimerStarted = false
    private var voiceRecordingTimer = createStopTimer(DEFAULT_AUDIO_LENGTH_MILLIS, "recordingTimer")
    private val silenceTimer = createStopTimer(SILENCE_MILLIS, "silenceTimer")
    private val pauseTimer = createStopTimer(PAUSE_MILLIS, "pauseTimer")

    init {
        audioDetectionCallback = object : AudioDetectionCallback {
            override fun onPauseFound() {
                LogManager.addLog("AudioRecorderPauseDetection - AudioDetectionCallback() onPauseFound()")
                silenceTimer.cancel()
                pauseTimer.cancel()
                pauseTimer.start()
            }

            override fun onVoiceFound() {
                LogManager.addLog("AudioRecorderPauseDetection - AudioDetectionCallback() onVoiceFound()")
                silenceTimer.cancel()
                pauseTimer.cancel()
                if (!isVoiceRecordingTimerStarted) {
                    isVoiceRecordingTimerStarted = true
                    voiceRecordingTimer.start()
                }
            }

            override fun onRecordingCompleted() {
                LogManager.addLog("AudioRecorderPauseDetection - AudioDetectionCallback() onRecordingCompleted()")
                audioRecorderPauseDetectionCallback?.onRecordingCompleted()
            }
        }
    }

    override fun startRecording() {
        if (!isRecording.get()) {
            cancelAllTimers()
            super.startRecording()
            silenceTimer.start()
        }
    }

    override fun stopRecording() {
        if (isRecording.get()) {
            cancelAllTimers()
            super.stopRecording()
            audioRecorderPauseDetectionCallback?.onRecordingStopped()
        }
    }

    override fun release() {
        cancelAllTimers()
        audioRecorderPauseDetectionCallback = null
        super.release()
    }

    private fun createStopTimer(millisInFuture: Long, event: String) =
        object : CountDownTimer(millisInFuture, 1000) {
            override fun onTick(millisUntilFinished: Long) {
                LogManager.addLog("AudioRecorderPauseDetection - createStopTimer(): $event, until finish=$millisUntilFinished")
            }

            override fun onFinish() {
                LogManager.addLog("AudioRecorderPauseDetection - onFinishTimer(): $event")
                stopRecording()
            }
        }

    private fun cancelAllTimers() {
        silenceTimer.cancel()
        pauseTimer.cancel()
        voiceRecordingTimer.cancel()
        isVoiceRecordingTimerStarted = false
    }
}