package com.cnil.assistant.models;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;


public class AnswerJsonModel {
    private static final String KEY_ID = "id";
    private static final String KEY_CONTENTS = "contents";

    private static final String KEY_FORMAT = "format";
    private static final String KEY_LOCALE = "locale";
    private static final String KEY_CONTENT = "content";


    private final String id;
    private final ArrayList<Content> answerContentArrayList = new ArrayList<>();


    public AnswerJsonModel(String response) throws JSONException{
        JSONObject jsonObj;

        jsonObj = new JSONObject(response);

        id = jsonObj.getString(KEY_ID);
        JSONArray namesJsonArray = jsonObj.getJSONArray(KEY_CONTENTS);
        for (int i = 0; i < namesJsonArray.length(); i++) {
            JSONObject jsonContentObj = namesJsonArray.getJSONObject(i);
            answerContentArrayList.add(new Content(jsonContentObj.getString(KEY_LOCALE),
                    jsonContentObj.getString(KEY_CONTENT),
                    jsonContentObj.getString(KEY_FORMAT)));
        }
    }

    public String getId() {
        return id;
    }

    public ArrayList<Content> getAnswerContentArrayList() {
        return answerContentArrayList;
    }

    public static final class Content {
        private final String locale;
        private final String content;
        private final String format;

        public Content(String locale, String content, String format) {
            this.locale = locale;
            this.content = content;
            this.format = format;
        }

        @SuppressWarnings("unused, RedundantSuppression")
        public String getLocale() {
            return locale;
        }

        public String getContent() {
            return content;
        }

        @SuppressWarnings("unused, RedundantSuppression")
        public String getFormat() {
            return format;
        }
    }
}
