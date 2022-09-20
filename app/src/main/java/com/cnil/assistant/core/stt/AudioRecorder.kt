package com.cnil.assistant.core.stt

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import com.cnil.assistant.utils.LogManager
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.concurrent.thread
import kotlin.math.abs
import kotlin.math.log10


const val REGULAR_SAMPLE_RATE_HZ = 16000

const val CHANNEL_CONFIG = AudioFormat.CHANNEL_IN_MONO
const val AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT
const val BUFFER_SIZE_FACTOR = 4

const val DEFAULT_VOICE_THRESHOLD = -40f

const val MAX_SAMPLE_VALUE = 32767


open class AudioRecorder(sampleRate: Int) {

    private val bufferSize = AudioRecord.getMinBufferSize(
        sampleRate, CHANNEL_CONFIG,
        AUDIO_FORMAT
    ) * BUFFER_SIZE_FACTOR

    private val audioRecord = AudioRecord(
        MediaRecorder.AudioSource.MIC,
        sampleRate,
        CHANNEL_CONFIG,
        AUDIO_FORMAT,
        bufferSize
    )

    var isRecording = AtomicBoolean(false)

    private var volumeDb: Float = Float.NEGATIVE_INFINITY

    var audioDetectionCallback: AudioDetectionCallback? = null
    var audioRecorderCallback: AudioRecorderCallback? = null


    open fun startRecording() {
        LogManager.addLog("AudioRecorder - startRecording(): method call")
        if (audioRecord.state == AudioRecord.STATE_INITIALIZED) {
            if (isRecording.compareAndSet(false, true)) {
                LogManager.addLog("AudioRecorder - startRecording(): start recording")
                volumeDb = Float.NEGATIVE_INFINITY
                audioRecord.startRecording()

                thread { captureAudioData() }
            }
        }
    }

    open fun stopRecording() {
        LogManager.addLog("AudioRecorder - stopRecording(): method call")
        if (audioRecord.state == AudioRecord.STATE_INITIALIZED) {
            LogManager.addLog("AudioRecorder - stopRecording(): stop recording")
            audioRecord.stop()
        }
        isRecording.set(false)
    }

    open fun release() {
        audioRecorderCallback = null
        stopRecording()
        audioRecord.release()
    }

    private fun captureAudioData() {
        LogManager.addLog("AudioRecorder - captureAudioData(): method call")

        var writeSound = false
        var lastVoiceSearchResult = false
        val bufferShort = ShortArray(bufferSize)

        while (isRecording.get()) {
            val bufferReadResult = audioRecord.read(bufferShort, 0, bufferShort.size)

            if (bufferReadResult < 0) {
                throw RuntimeException(
                    "AudioRecorder - captureAudioData(): Reading of audio buffer failed: " +
                            getBufferReadFailureReason(bufferReadResult)
                )
            } else {
                volumeDb = calculatePcmVolume(bufferShort)
                val voiceSearchResult = volumeDb >= DEFAULT_VOICE_THRESHOLD
                LogManager.addLog("AudioRecorder - captureAudioData(): voiceSearchResult = $volumeDb")
                if (lastVoiceSearchResult != voiceSearchResult) {
                    if (voiceSearchResult) {
                        LogManager.addLog("AudioRecorder - captureAudioData(): Voice found")
                        writeSound = true
                        audioDetectionCallback?.onVoiceFound()
                    } else if (writeSound) {
                        LogManager.addLog("AudioRecorder - captureAudioData(): Pause found")
                        audioDetectionCallback?.onPauseFound()
                    }
                    lastVoiceSearchResult = voiceSearchResult
                }
                audioRecorderCallback?.onAudioBufferAvailable(bufferShort)
            }
        }

        audioDetectionCallback?.onRecordingCompleted()
    }

    private fun calculatePcmVolume(buffer: ShortArray): Float {
        var sampleSum = 0
        var sampleCount = 0
        for (index in buffer.indices step 1) {
            val sample = abs(buffer[index].toInt())
            sampleSum += sample
            ++sampleCount
        }
        val averageAmplitude = sampleSum.toFloat() / sampleCount
        return 20 * log10(averageAmplitude / MAX_SAMPLE_VALUE)
    }

    private fun getBufferReadFailureReason(errorCode: Int): String {
        return when (errorCode) {
            AudioRecord.ERROR_INVALID_OPERATION -> "ERROR_INVALID_OPERATION"
            AudioRecord.ERROR_BAD_VALUE -> "ERROR_BAD_VALUE"
            AudioRecord.ERROR_DEAD_OBJECT -> "ERROR_DEAD_OBJECT"
            AudioRecord.ERROR -> "ERROR"
            else -> "Unknown ($errorCode)"
        }
    }
}