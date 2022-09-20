package com.cnil.assistant.ui;

import android.content.Context;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.cnil.assistant.core.repositories.AnswerRepositoryImplementation;
import com.cnil.assistant.models.AnswerContent;
import com.cnil.assistant.models.VoiceAssistantError;

import java.util.ArrayList;
import java.util.List;


public class BookmarksViewModel extends ViewModel {

    private final MutableLiveData<List<AnswerContent>> answerContentArrayListLiveData = new MutableLiveData<>();


    public LiveData<List<AnswerContent>> getAnswerContentArrayListLiveData() {
        return answerContentArrayListLiveData;
    }

    public void getAnswerForId(Context context, List<String> answerIdsList, String datasetFolderPath) {
        new AnswerRepositoryImplementation(MainActivity.getExecutorService())
                .getAnswersList(context, answerIdsList, datasetFolderPath,
                (answerRepositoryError, answerRepositoryResult) -> {
                    if ((answerRepositoryError != null) &&
                            answerRepositoryError.getErrorType().equals(VoiceAssistantError.ErrorType.NO_ERROR)) {
                        answerContentArrayListLiveData.postValue(answerRepositoryResult);
                    }
                });
    }

    public void clearList() {
        answerContentArrayListLiveData.postValue(new ArrayList<>());
    }
}

