package com.cnil.assistant.core.repositories;

import android.content.Context;

import java.util.List;


public interface AnswerRepository {
    void getAnswersList(Context ctx, List<String> answerId, String questionsLocations, final AnswerRepositoryGetAnswerCallback callback);
}
