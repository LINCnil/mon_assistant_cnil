package com.cnil.assistant.core.stt

import android.content.Context

import com.cnil.assistant.core.TaskCallback
import com.cnil.assistant.models.VoiceAssistantError
import com.cnil.assistant.utils.Constants
import com.cnil.assistant.utils.FileManager
import com.cnil.assistant.utils.LogManager

import com.harman.hybridnlpengine.models.FilesLocations


const val TFLITE_MODEL_FILENAME = "output_graph_0428_2.tflite"


class MozillaSpeechRecognizer : SpeechRecognizer {

    private var decodedText: String = ""

    private var filesLocations: FilesLocations? = null
    private val recognitionService: RecognitionServiceInterface =
        RecognitionService(REGULAR_SAMPLE_RATE_HZ)
    private var audioRecorder: AudioRecorderPauseDetection? = null
    private var speechRecognizerCallback: SpeechRecognizerCallback? = null


    override fun init(
        context: Context,
        filesLocationsValue: FilesLocations,
        callback: TaskCallback?
    ) {
        filesLocations = filesLocationsValue
        initRecognitionService(context, filesLocations ?: return, callback)

        recognitionService.setRecognitionListener(object : RecognitionServiceListener {
            override fun onWakeWordDetected() {
                LogManager.addLog("MozillaSpeechRecognizer - init() setRecognitionListener(): WakeWordDetected")
            }

            override fun onPauseDetected() {
                LogManager.addLog("MozillaSpeechRecognizer - init() setRecognitionListener(): PauseDetected")
            }

            override fun onTimeout() {
                LogManager.addLog("MozillaSpeechRecognizer - init() setRecognitionListener(): onTimeout")
            }

            override fun onTextRecognized(recognizedText: String) {
                LogManager.addLog("MozillaSpeechRecognizer - init() setRecognitionListener(): Decoded Text: $recognizedText")
                decodedText = recognizedText
            }
        })
    }

    private fun initRecognitionService(
        context: Context,
        filesLocations: FilesLocations,
        callback: TaskCallback?
    ) {
        val modelsPath = context.getExternalFilesDir(null).toString()
        val tfLiteModelPath = "$modelsPath/$TFLITE_MODEL_FILENAME"
        val scorerPath =
            "$modelsPath/${Constants.ARCHIVE_FOLDER_NAME}/${filesLocations.fileSttScorerLocation}"

        try {
            FileManager.copyAssetFileToInternalStorage(
                context.assets,
                TFLITE_MODEL_FILENAME,
                modelsPath
            )
            recognitionService.initialize(tfLiteModelPath, scorerPath, "")
        } catch (e: Exception) {
            LogManager.addLog("MozillaSpeechRecognizer - initRecognitionService(): Exception = $e")
            callback?.onTaskCompleted(VoiceAssistantError(VoiceAssistantError.ErrorType.ERROR))
        }
        LogManager.addLog("MozillaSpeechRecognizer - initRecognitionService(): Recognition Service is initialized")

        callback?.onTaskCompleted(VoiceAssistantError(VoiceAssistantError.ErrorType.NO_ERROR))
    }

    override fun startVoiceRecognition(
        context: Context,
        callback: SpeechRecognizerCallback?
    ) {
        if (recognitionService.getCurrentState() == RecognitionServiceState.UNINITIALIZED) {
            initRecognitionService(context, filesLocations ?: return, null)
        }

        speechRecognizerCallback = callback
        decodedText = ""

        if (audioRecorder == null) {
            audioRecorder = AudioRecorderPauseDetection(REGULAR_SAMPLE_RATE_HZ).also {
                it.audioRecorderPauseDetectionCallback =
                    object : AudioRecorderPauseDetectionCallback {
                        override fun onRecordingStopped() {
                            LogManager.addLog("MozillaSpeechRecognizer - AudioRecorderPauseDetection() onRecordingStopped(): stopped")
                            stopVoiceRecognition()
                        }

                        override fun onRecordingCompleted() {
                            LogManager.addLog("MozillaSpeechRecognizer - AudioRecorderPauseDetection() onRecordingCompleted(): completed")

                            speechRecognizerCallback?.onSpeechRecognitionComplete(
                                VoiceAssistantError(VoiceAssistantError.ErrorType.NO_ERROR),
                                decodedText
                            )
                        }
                    }
                it.audioRecorderCallback = object : AudioRecorderCallback {
                    override fun onAudioBufferAvailable(audioBuffer: ShortArray) {
                        try {
                            recognitionService.sendAudioBuffer(audioBuffer)
                        } catch (e: Exception) {
                            LogManager.addLog(e.toString())
                        }
                    }
                }
            }
        }

        audioRecorder?.let {
            try {
                recognitionService.start()
                it.startRecording()
            } catch (e: Exception) {
                LogManager.addLog("MozillaSpeechRecognizer - startVoiceRecognition(): Exception = $e")
            }
        }
    }

    override fun stopVoiceRecognition() {
        audioRecorder?.let {
            try {
                it.stopRecording()
                recognitionService.stop()
            } catch (e: Exception) {
                LogManager.addLog("MozillaSpeechRecognizer - stopVoiceRecognition(): Exception = $e")
            }
        }
    }

    override fun unload() {
        audioRecorder?.release()
        audioRecorder = null

        recognitionService.release()
    }
}