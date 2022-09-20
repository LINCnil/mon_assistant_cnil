package com.cnil.assistant.core.repositories;

import android.content.Context;

import androidx.annotation.NonNull;

import com.cnil.assistant.models.AnswerContent;
import com.cnil.assistant.models.AnswerJsonModel;
import com.cnil.assistant.models.QuestionJsonModel;
import com.cnil.assistant.models.VoiceAssistantError;
import com.cnil.assistant.utils.Constants;
import com.cnil.assistant.utils.FileManager;

import org.json.JSONException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executor;


public class AnswerRepositoryImplementation implements AnswerRepository{
    private final Executor executor;
    private Context context;

    public AnswerRepositoryImplementation(Executor ex) {
        executor = ex;
    }

    public void getAnswersList(Context ctx, List<String> answerIdsList, String questionsFilesLocations, final AnswerRepositoryGetAnswerCallback callback) {
        context = ctx;
        executor.execute(() -> {
            try {
                ArrayList<AnswerContent> answerContentArrayList = new ArrayList<>();
                for (int i = 0; i < answerIdsList.size(); i++) {
                    answerContentArrayList.add(getAnswerFromAnswerId(answerIdsList.get(i), questionsFilesLocations));
                }
                callback.onGetAnswerComplete(new VoiceAssistantError(VoiceAssistantError.ErrorType.NO_ERROR), answerContentArrayList);
            } catch (IOException ioEx) {
                ioEx.printStackTrace();
                callback.onGetAnswerComplete(
                        new VoiceAssistantError(VoiceAssistantError.ErrorType.AR_FINE_NOT_FOUND_ERROR,
                                String.format("AnswerRepositoryImplementation - getAnswer(): %1$s", ioEx.getMessage())), null);
            } catch (JSONException jsonEx) {
                jsonEx.printStackTrace();
                callback.onGetAnswerComplete(
                        new VoiceAssistantError(VoiceAssistantError.ErrorType.AR_INVALID_FORMAT_ERROR,
                                String.format("AnswerRepositoryImplementation - getAnswer(): %1$s", jsonEx.getMessage())), null);
            } catch (Exception ex) {
                callback.onGetAnswerComplete(
                        new VoiceAssistantError(VoiceAssistantError.ErrorType.ERROR,
                                String.format("AnswerRepositoryImplementation - getAnswer(): %1$s", ex.getMessage())), null);
            }
        });
    }

    private @NonNull AnswerContent getAnswerFromAnswerId(String answerId, String questionsFilesLocations)
            throws IOException, JSONException {
        String answerFileName = makeAnswerFileName(answerId);
        String questionFileName = makeQuestionFileName(answerId);
        String folderPath = context.getExternalFilesDir(null).toString().concat(Constants.ARCHIVE_FOLDER_NAME);

        String questionsFolderPath = folderPath.concat("/").concat(questionsFilesLocations).concat("/");
        String answerJsonString = FileManager.loadJSONFromFile(questionsFolderPath.concat(answerFileName));
        String questionJsonString = FileManager.loadJSONFromFile(questionsFolderPath.concat(questionFileName));

        QuestionJsonModel questionModel = new QuestionJsonModel(questionJsonString);
        AnswerJsonModel answerModel = new AnswerJsonModel(answerJsonString);

        return AnswerMapper.map(answerModel, questionModel);
    }

    private String makeAnswerFileName(String answerId) {
        return String.format("%1$s_content.json", answerId);
    }

    private String makeQuestionFileName(String answerId) {
        return String.format("%1$s.json", answerId);
    }
}
