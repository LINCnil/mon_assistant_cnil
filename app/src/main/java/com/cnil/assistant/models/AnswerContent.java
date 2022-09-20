package com.cnil.assistant.models;

import java.util.ArrayList;
import java.util.Objects;


public class AnswerContent {
    private final String id;
    private final String response;
    private final String request;
    private final ArrayList<String> keywordsArrayList = new ArrayList<>();

    public AnswerContent(String id, String answerString, String question, ArrayList<String> keywordsArrayList) {
        this.id = id;
        this.response = answerString;
        this.request = question;
        if (keywordsArrayList != null) {
            this.keywordsArrayList.addAll(keywordsArrayList);
        }
    }

    public String getId() {
        return id;
    }

    public String getResponse() {
        return response;
    }

    public String getRequest() {
        return request;
    }

    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) return false;
        AnswerContent answerContent = (AnswerContent) o;
        return Objects.equals(id, answerContent.id) &&
                Objects.equals(response, answerContent.response) &&
                Objects.equals(request, answerContent.request) &&
                Objects.equals(keywordsArrayList, answerContent.keywordsArrayList);
    }
}
