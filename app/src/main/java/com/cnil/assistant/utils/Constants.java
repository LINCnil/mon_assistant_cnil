package com.cnil.assistant.utils;

public class Constants {
    public static final String SERVER_DOWNLOAD_METADATA_API = "https://enovademoeurope.harman.com:8233/metadata/";
    public static final String SERVER_DOWNLOAD_ARCHIVE_API = "https://enovademoeurope.harman.com:8233/models";

    public static final int RESPONSE_CODE_SUCCESS = 200;

    public static final String ASSETS_VERSION_FILE_NAME = "version.txt";
    public static final String BOOKMARKS_FILE_NAME = "bookmarks.txt";

    public static final String MODEL_ZIP_FOLDER_NAME = "/model.zip";
    public static final String ARCHIVE_FOLDER_NAME = "/archive";
    public static final String ARCHIVE_TEMP_FOLDER_NAME = "/archive_temp";
    public static final String AUDIO_ZIP_FOLDER_NAME = "/audio.zip";
    public static final String AUDIO_ARCHIVE_FOLDER_NAME = "/audio_archive";
    public static final String AUDIO_ARCHIVE_TEMP_FOLDER_NAME = "/audio_archive_temp";

    public static final String KEY_FILE_FEMALE_AUDIO = "female_tts_audio_files";
    public static final String KEY_FILE_MALE_AUDIO = "male_tts_audio_files";

    public static final String SHARED_PREFERENCES_NAME = "CNIL_VA_ASSISTANT_SHARED_PREFERENCES_NAME";
    public static final String SHARED_PREFERENCES_KEY_ASSETS_MODELS_VERSION = "SHARED_PREFERENCES_KEY_ASSETS_MODELS_VERSION";
    public static final String SHARED_PREFERENCES_KEY_IS_FIRST_APP_LAUNCH = "SHARED_PREFERENCES_KEY_IS_FIRST_APP_LAUNCH";
    public static final String SHARED_PREFERENCES_KEY_CURRENT_INSTALLED_VERSION = "SHARED_PREFERENCES_KEY_CURRENT_INSTALLED_VERSION";
    public static final String SHARED_PREFERENCES_KEY_SETTINGS_RECORDING = "SHARED_PREFERENCES_KEY_SETTINGS_RECORDING";
    public static final String SETTINGS_RECORDING_OFF = "Off";
    public static final String SETTINGS_RECORDING_ON = "On";
    public static final String SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_FEMALE_VOICE = "SHARED_PREFERENCES_KEY_SETTINGS_IS_FEMALE_VOICE";
    public static final String SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_AUTO_START = "SHARED_PREFERENCES_KEY_SETTINGS_IS_AUTO_START";
    public static final String SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_FULL_ARTICLE = "SHARED_PREFERENCES_KEY_SETTINGS_IS_FULL_ARTICLE";

    public static final String DATE_TIME_FORMAT = "yyyy-MM-dd kk:mm:ss.SSS";

    public static final int QUANTITY_OF_ANSWER = 5;

    public static final double SUPPORTED_ARCHITECTURE_VERSION = 1.2;

    public static final String CNIL_NEWS_WEB_PAGE_URL = "https://www.cnil.fr/fr/actualites";
}
