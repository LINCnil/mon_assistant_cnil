package com.cnil.assistant.models;

import android.util.Pair;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

public class ServerMetadataJsonResponse {
    private static final String KEY_VERSION_NAME = "version_name";
    private static final String KEY_FILES_ARRAY = "files";

    private static final String KEY_FILE = "file";
    private static final String KEY_CHECKSUM = "check_summ";

    private final String versionName;
    private final ArrayList<Pair<String, String>> filesInfoArrayList = new ArrayList<>();


    public ServerMetadataJsonResponse(String response) throws JSONException {
        JSONObject jsonObj;

        jsonObj = new JSONObject(response);

        versionName = jsonObj.getString(KEY_VERSION_NAME);
        JSONArray filesInfoJsonArray = jsonObj.getJSONArray(KEY_FILES_ARRAY);
        for (int i = 0; i < filesInfoJsonArray.length(); i++) {
            JSONObject jsonContentObj = filesInfoJsonArray.getJSONObject(i);
            filesInfoArrayList.add(new Pair<>(
                    jsonContentObj.getString(KEY_FILE),
                    jsonContentObj.getString(KEY_CHECKSUM)));
        }
    }

    public String getVersionName() {
        return versionName;
    }

    public ArrayList<Pair<String, String>> getFilesInfoArrayList() {
        return filesInfoArrayList;
    }
}
