package com.cnil.assistant.models;

import java.util.List;
import java.util.Objects;


public class ConversationModel {
    private final int requestId;
    private final String requestText;
    private final List<AnswerContent> answersList;
    private final ConversationType conversationType;

    public enum ConversationType
    {
        ANSWER(0),
        ANSWER_REQUEST_FAILED(1);

        private final int value;
        ConversationType(int value) {
            this.value = value;
        }

        public int getValue() {
            return value;
        }
    }

    public ConversationModel(int requestNumber, String requestTextValue, List<AnswerContent> answersListValue, ConversationType conversationTypeValue) {
        requestId = requestNumber;
        requestText = requestTextValue;
        answersList = answersListValue;
        conversationType = conversationTypeValue;
    }

    public int getRequestId() {
        return requestId;
    }

    public String getRequestText() {
        return requestText;
    }

    public List<AnswerContent> getAnswersList() {
        return answersList;
    }

    public ConversationType getConversationType() { return conversationType; }

    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) return false;
        ConversationModel conversationModel = (ConversationModel) o;
        return Objects.equals(requestText, conversationModel.requestText) &&
                Objects.equals(answersList, conversationModel.answersList);
    }
}


