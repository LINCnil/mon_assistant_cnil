package com.cnil.assistant.core.stt

/**
 * Interface definition for a RecognitionService callbacks
 */
interface RecognitionServiceListener {

    /**
     * Called on the listener to notify it that the wake word has been detected.
     */
    fun onWakeWordDetected()

    /**
     * Called on the listener to notify it that the pause has been detected
     * in the received audio buffer.
     */
    fun onPauseDetected()

    /**
     * Called on the listener to notify it that the RecognitionService has been stopped
     * by the timeout.
     */
    fun onTimeout()

    /**
     * Called on the listener to notify it that the text has been recognized
     * by the RecognitionService.
     *
     * @param recognizedText the recognized text
     */
    fun onTextRecognized(recognizedText: String)
}