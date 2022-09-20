package com.cnil.assistant.core.stt

import android.media.AudioRecord
import androidx.collection.CircularArray

import com.cnil.assistant.CnilApplication
import com.cnil.assistant.utils.Constants
import com.cnil.assistant.utils.FileManager
import com.cnil.assistant.utils.LogManager

import org.deepspeech.libdeepspeech.DeepSpeechModel
import org.deepspeech.libdeepspeech.DeepSpeechStreamingState

import java.io.File
import java.lang.IllegalArgumentException
import java.lang.IllegalStateException
import java.util.concurrent.atomic.AtomicBoolean

import kotlin.concurrent.thread


const val AUDIO_FILES_PATH = "AudioFiles"


internal class RecognitionService(sampleRate: Int) : RecognitionServiceInterface {
    private var deepSpeechModel: DeepSpeechModel? = null
    private var deepSpeechStreamingState: DeepSpeechStreamingState? = null

    private var currentState: RecognitionServiceState = RecognitionServiceState.UNINITIALIZED
    private var listener: RecognitionServiceListener? = null

    private val circularBuffer = CircularArray<Short>(4096)
    private var isRunning = AtomicBoolean(false)


    override fun initialize(
        sttModelPath: String,
        scorerPath: String,
        wakeWordModelPath: String
    ) {
        if (currentState != RecognitionServiceState.UNINITIALIZED) {
            throw IllegalStateException("RecognitionService - initialize(): RecognitionService is in $currentState state")
        }
        createDeepSpeechModel(sttModelPath, scorerPath)

        currentState = RecognitionServiceState.INITIALIZED
    }

    override fun start() {
        LogManager.addLog("RecognitionService - start(): ")

        if (currentState != RecognitionServiceState.INITIALIZED) {
            LogManager.addLog("RecognitionService - start(): Failed to start(). RecognitionService is in $currentState state")
            throw IllegalStateException("Failed to start(). RecognitionService is in $currentState state")
        }

        currentState = RecognitionServiceState.STT_RECOGNITION
        if (isRunning.compareAndSet(false, true)) {
            thread { processAudioBuffer() }
        }
    }

    override fun stop() {
        LogManager.addLog("RecognitionService - stop(): ")
        if (currentState != RecognitionServiceState.WAKE_WORD_DETECTION &&
            currentState != RecognitionServiceState.STT_RECOGNITION
        ) {
            LogManager.addLog("RecognitionService - stop(): Failed to stop(). RecognitionService is in $currentState state")
            throw IllegalStateException("Failed to stop(). RecognitionService is in $currentState state")
        }
        currentState = RecognitionServiceState.INITIALIZED

        isRunning.set(false)
    }

    override fun release() {
        deepSpeechModel?.freeModel()

        currentState = RecognitionServiceState.UNINITIALIZED
    }

    override fun setVoiceVolumeThreshold(threshold: Float) {}

    override fun sendAudioBuffer(buffer: ShortArray) {
        LogManager.addLog("RecognitionService - sendAudioBuffer()")
        if (currentState != RecognitionServiceState.WAKE_WORD_DETECTION &&
            currentState != RecognitionServiceState.STT_RECOGNITION
        ) {
            LogManager.addLog("RecognitionService - sendAudioBuffer(): Failed to sendAudioBuffer(). RecognitionService is in $currentState state")
            throw IllegalStateException("Failed to sendAudioBuffer(). RecognitionService is in $currentState state")
        }

        for (item in buffer) {
            circularBuffer.addLast(item)
        }
    }

    override fun setRecognitionListener(listener: RecognitionServiceListener) {
        this.listener = listener
    }

    override fun getCurrentState() = currentState

    private fun createDeepSpeechModel(sttModelPath: String, scorerPath: String) {
        for (path in listOf(sttModelPath, scorerPath)) {
            if (!File(path).exists()) {
                throw IllegalArgumentException("File $path is not exists")
            }
        }

        deepSpeechModel = DeepSpeechModel(sttModelPath)
        deepSpeechModel?.enableExternalScorer(scorerPath)
    }

    private val bufferSize = AudioRecord.getMinBufferSize(
        sampleRate, CHANNEL_CONFIG,
        AUDIO_FORMAT
    ) * BUFFER_SIZE_FACTOR

    private fun processAudioBuffer() {
        deepSpeechStreamingState = deepSpeechModel?.createStream()

        while (isRunning.get()) {
            if (circularBuffer.size() >= bufferSize) {
                val buffer = ShortArray(bufferSize)
                for (i in buffer.indices) {
                    buffer[i] = circularBuffer.popFirst()
                }

                deepSpeechModel?.feedAudioContent(deepSpeechStreamingState, buffer, buffer.size)
                val decoded = deepSpeechModel?.intermediateDecode(deepSpeechStreamingState)
                if (!decoded.isNullOrEmpty()) {
                    listener?.onTextRecognized(decoded)
                }
            }
        }

        val decoded = deepSpeechModel?.finishStream(
            deepSpeechStreamingState,
            getAudioPath()
        )

        if (!decoded.isNullOrEmpty()) {
            listener?.onTextRecognized(decoded)
        }
    }

    private fun getAudioPath(): String {
        val modelsPath = CnilApplication.getAppContext().getExternalFilesDir(null).toString()
        val audioFilesPath = "$modelsPath/$AUDIO_FILES_PATH"

        val storeAudioFilesOption = CnilApplication.readStringPreference(
            CnilApplication.getAppContext(),
            Constants.SHARED_PREFERENCES_KEY_SETTINGS_RECORDING,
            Constants.SETTINGS_RECORDING_OFF
        )
        if (storeAudioFilesOption == Constants.SETTINGS_RECORDING_ON) {
            FileManager.createFolder(audioFilesPath)
        }

        return if (storeAudioFilesOption == Constants.SETTINGS_RECORDING_ON) audioFilesPath else ""
    }
}