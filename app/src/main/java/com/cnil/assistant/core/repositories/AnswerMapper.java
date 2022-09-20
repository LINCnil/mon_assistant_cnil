package com.cnil.assistant.core.repositories;

import com.cnil.assistant.models.AnswerContent;
import com.cnil.assistant.models.AnswerJsonModel;
import com.cnil.assistant.models.QuestionJsonModel;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;


public class AnswerMapper {
    public static AnswerContent map(AnswerJsonModel answerModel, QuestionJsonModel questionModel) throws IOException{
        ArrayList<QuestionJsonModel.QuestionMetadata> metadataArr = questionModel.getQuestionMetadataArrayList();
        QuestionJsonModel.QuestionMetadata metadata = (metadataArr.size() > 0) ? metadataArr.get(0) : null;
        ArrayList<String> keywords = (metadata != null) ?
                new ArrayList<>(Arrays.asList(metadata.getContent().split(","))) :
                new ArrayList<>();

        String htmlAnswer;
        if (answerModel.getAnswerContentArrayList() != null &&
                !answerModel.getAnswerContentArrayList().isEmpty()) {
            htmlAnswer = answerModel.getAnswerContentArrayList().get(0).getContent();
        } else {
            throw new IOException("AnswerMapper - map(): htmlAnswer can not be retrieved");
        }

        String question;
        if (questionModel.getQuestionNameArrayList() != null &&
                !questionModel.getQuestionNameArrayList().isEmpty()) {
            question = questionModel.getQuestionNameArrayList().get(0).getName();
        } else {
            throw new IOException("AnswerMapper - map(): question can not be retrieved");
        }

        return new AnswerContent(answerModel.getId(), htmlAnswer, question, keywords);
    }
}
