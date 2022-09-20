package com.cnil.assistant.models;

public class VoiceAssistantError {
    public enum ErrorType {
        NO_ERROR,
        NLP_FILE_NOT_FOUND_ERROR,
        NLP_INVALID_FILE_FORMAT_ERROR,
        NLP_INVALID_COUNT_OF_CLASSES_ERROR,
        NLP_UNEXPECTED_CLASSES_INDEX_ERROR,
        NLP_OOT_COEFFICIENT_BELOW_THRESHOLD,
        AR_INVALID_FORMAT_ERROR,
        AR_FINE_NOT_FOUND_ERROR,
        UPDATE_INVALID_RESPONSE_ERROR,
        UPDATE_NO_INTERNET_CONNECTION,
        INIT_FILES_DO_NOT_EXIST,
        ERROR
    }

    private final ErrorType errorType;
    private final String errorMessage;

    public VoiceAssistantError(ErrorType errType, String message) {
        errorType = errType;
        errorMessage = message;
    }

    public VoiceAssistantError(ErrorType errType) {
        errorType = errType;
        errorMessage = "";
    }

    public VoiceAssistantError(com.harman.hybridnlpengine.models.VoiceAssistantError vaError) {
        switch (vaError.getErrorType()) {
            case NLP_FILE_NOT_FOUND_ERROR:
                errorType = ErrorType.NLP_FILE_NOT_FOUND_ERROR;
                break;
            case NLP_INVALID_FILE_FORMAT_ERROR:
                errorType = ErrorType.NLP_INVALID_FILE_FORMAT_ERROR;
                break;
            case NLP_INVALID_COUNT_OF_CLASSES_ERROR:
                errorType = ErrorType.NLP_INVALID_COUNT_OF_CLASSES_ERROR;
                break;
            case NLP_UNEXPECTED_CLASSES_INDEX_ERROR:
                errorType = ErrorType.NLP_UNEXPECTED_CLASSES_INDEX_ERROR;
                break;
            case NLP_OOT_COEFFICIENT_BELOW_THRESHOLD:
                errorType = ErrorType.NLP_OOT_COEFFICIENT_BELOW_THRESHOLD;
                break;
            default:
                errorType = ErrorType.NO_ERROR;
                break;
        }

        errorMessage = vaError.getErrorMessage();
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public ErrorType getErrorType() {
        return errorType;
    }
}
