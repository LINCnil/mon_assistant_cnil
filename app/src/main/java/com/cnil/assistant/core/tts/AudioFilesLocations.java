package com.cnil.assistant.core.tts;

import com.cnil.assistant.utils.Constants;

import org.json.JSONException;
import org.json.JSONObject;


public class AudioFilesLocations {
    private final String fileFemaleAudioLocation;
    private final String fileMaleAudioLocation;

    public AudioFilesLocations(String response) throws JSONException {
        JSONObject jsonObj = new JSONObject(response);

        fileFemaleAudioLocation = jsonObj.getString(Constants.KEY_FILE_FEMALE_AUDIO);
        fileMaleAudioLocation = jsonObj.getString(Constants.KEY_FILE_MALE_AUDIO);
    }

    public String getFemaleAudioLocation() {
        return fileFemaleAudioLocation;
    }

    public String getMaleAudioLocation() {
        return fileMaleAudioLocation;
    }
}
