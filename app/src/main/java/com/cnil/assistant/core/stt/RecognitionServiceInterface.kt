package com.cnil.assistant.core.stt

import java.lang.IllegalArgumentException

/**
 * Describes states of the recognition service
 *
 * @property UNINITIALIZED indicates recognition service state is not successfully initialized.
 * @property INITIALIZED indicates recognition service state is ready to be used.
 * @property WAKE_WORD_DETECTION indicates recognition service state is detecting the wake word.
 * @property STT_RECOGNITION indicates recognition service state is recognizing speech to text.
 */
enum class RecognitionServiceState {
    UNINITIALIZED,
    INITIALIZED,
    WAKE_WORD_DETECTION,
    STT_RECOGNITION
}

/**
 * Interface definition for the recognition service
 */
interface RecognitionServiceInterface {

    /**
     * Initializes the recognition service
     * @throws IllegalStateException
     * @throws IllegalArgumentException
     */
    fun initialize(
        sttModelPath: String,
        scorerPath: String,
        wakeWordModelPath: String
    )

    /**
     * Starts the recognition service
     * @throws IllegalStateException
     */
    fun start()

    /**
     * Stops the recognition service
     * @throws IllegalStateException
     */
    fun stop()

    /**
     * Releases the recognition service resources
     */
    fun release()

    /**
     * Sets voice volume threshold for pause detection
     *
     * @param threshold the voice volume threshold
     */
    fun setVoiceVolumeThreshold(threshold: Float)

    /**
     * Sends audio buffer to the recognition service
     *
     * @param buffer the audio buffer short array
     */
    fun sendAudioBuffer(buffer: ShortArray)

    /**
     * Sets RecognitionServiceListener
     *
     * @param listener the RecognitionServiceListener
     */
    fun setRecognitionListener(listener: RecognitionServiceListener)

    /**
     * Gets current state of the recognition service
     *
     * @return the current state of the recognition service
     */
    fun getCurrentState(): RecognitionServiceState
}