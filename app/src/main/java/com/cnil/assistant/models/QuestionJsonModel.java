package com.cnil.assistant.models;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;


public class QuestionJsonModel {
    private static final String KEY_ID = "id";
    private static final String KEY_NAMES = "names";
    private static final String KEY_METADATA = "metadata";

    private static final String KEY_NAME = "name";
    private static final String KEY_LOCALE = "locale";
    private static final String KEY_CONTENT = "content";

    private final String id;
    private final ArrayList<QuestionName> questionNamesArrayList = new ArrayList<>();
    private final ArrayList<QuestionMetadata> questionMetadataArrayList = new ArrayList<>();


    public QuestionJsonModel(String response) throws JSONException {
        JSONObject jsonObj;

        jsonObj = new JSONObject(response);

        id = jsonObj.getString(KEY_ID);
        JSONArray namesJsonArray = jsonObj.getJSONArray(KEY_NAMES);
        for (int i = 0; i < namesJsonArray.length(); i++) {
            JSONObject jsonNameObj = namesJsonArray.getJSONObject(i);
            questionNamesArrayList.add(new QuestionName(jsonNameObj.getString(KEY_NAME), jsonNameObj.getString(KEY_LOCALE)));
        }
        JSONArray metadataJsonArray = jsonObj.getJSONArray(KEY_METADATA);
        for (int i = 0; i < metadataJsonArray.length(); i++) {
            JSONObject jsonMetaObj = metadataJsonArray.getJSONObject(i);
            questionMetadataArrayList.add(new QuestionMetadata(jsonMetaObj.getString(KEY_LOCALE),
                    jsonMetaObj.getString(KEY_NAME),
                    jsonMetaObj.getString(KEY_CONTENT)));
        }
    }

    @SuppressWarnings("unused, RedundantSuppression")
    public String getId() {
        return id;
    }

    public ArrayList<QuestionName> getQuestionNameArrayList() {
        return questionNamesArrayList;
    }

    public ArrayList<QuestionMetadata> getQuestionMetadataArrayList() {
        return questionMetadataArrayList;
    }

    public static final class QuestionName {
        private final String name;
        private final String locale;

        public QuestionName(String name, String locale) {
            this.locale = locale;
            this.name = name;
        }

        public String getName() {
            return name;
        }

        @SuppressWarnings("unused, RedundantSuppression")
        public String getLocale() {
            return locale;
        }
    }

    public static final class QuestionMetadata {
        private final String locale;
        private final String name;
        private final String content;

        public QuestionMetadata(String name, String locale, String content) {
            this.locale = locale;
            this.name = name;
            this.content = content;
        }

        @SuppressWarnings("unused, RedundantSuppression")
        public String getName() {
            return name;
        }

        @SuppressWarnings("unused, RedundantSuppression")
        public String getLocale() {
            return locale;
        }

        public String getContent() {
            return content;
        }
    }
}
