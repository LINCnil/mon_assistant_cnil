package com.cnil.assistant.core.tts;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.MediaPlayer;
import android.net.Uri;

import androidx.annotation.NonNull;

import com.cnil.assistant.CnilApplication;
import com.cnil.assistant.core.TaskCallback;
import com.cnil.assistant.models.DebugInfoModel;
import com.cnil.assistant.models.VoiceAssistantError;
import com.cnil.assistant.utils.Constants;
import com.cnil.assistant.utils.DebugLogInfoManager;
import com.cnil.assistant.utils.FileManager;
import com.cnil.assistant.utils.LogManager;

import org.json.JSONException;

import java.io.IOException;
import java.util.concurrent.Executor;


public class TextToSpeechOggEngine implements TextToSpeech {
    private static final String AUDIO_FILES_LOCATIONS_PATH = "audio_config.json";

    private static Executor executor;
    private AudioFilesLocations audioFilesLocations;

    private MediaPlayer mediaPlayer;
    private boolean isAudioConfigured;

    private static TextToSpeechOggEngine ttsInstance;


    public static TextToSpeechOggEngine getTtsInstance(Executor ex) {
        if (ttsInstance == null) {
            executor = ex;
            ttsInstance = new TextToSpeechOggEngine();
        }
        return ttsInstance;
    }

    @Override
    public void init(Context context, TaskCallback initCallback) {
        executor.execute(() -> {
            try {
                String audioFolderPath = context.getExternalFilesDir(null).toString().concat(Constants.AUDIO_ARCHIVE_FOLDER_NAME);

                if (FileManager.doesFolderExist(audioFolderPath)) {
                    String audioConfigFilePath = audioFolderPath.concat("/").concat(AUDIO_FILES_LOCATIONS_PATH);
                    if (FileManager.doesFolderExist(audioConfigFilePath)) {
                        audioFilesLocations = new AudioFilesLocations(FileManager.loadJSONFromFile(audioConfigFilePath));
                    } else {
                        audioFilesLocations = new AudioFilesLocations(FileManager.loadJSONFromAsset(context, AUDIO_FILES_LOCATIONS_PATH));
                        FileManager.copyAssetFileToInternalStorage(context.getAssets(), AUDIO_FILES_LOCATIONS_PATH, audioFolderPath);
                    }
                } else {
                    audioFilesLocations = new AudioFilesLocations(FileManager.loadJSONFromAsset(context, AUDIO_FILES_LOCATIONS_PATH));
                    FileManager.copyAssetFileToInternalStorage(context.getAssets(), AUDIO_FILES_LOCATIONS_PATH, audioFolderPath);
                }

                if (!verifyFilesAvailability(audioFilesLocations, context)) {
                    initCallback.onTaskCompleted(new VoiceAssistantError(VoiceAssistantError.ErrorType.INIT_FILES_DO_NOT_EXIST,
                            "TextToSpeechOggEngine - init(): Some init file(s) are missing"));
                }

                mediaPlayer = new MediaPlayer();
                initCallback.onTaskCompleted(new VoiceAssistantError(VoiceAssistantError.ErrorType.NO_ERROR));
            } catch (IOException | JSONException e) {
                e.printStackTrace();
                LogManager.addLog("TextToSpeechOggEngine - init(): Exception: " + e.getMessage());

                initCallback.onTaskCompleted(new VoiceAssistantError(VoiceAssistantError.ErrorType.INIT_FILES_DO_NOT_EXIST,
                        "TextToSpeechOggEngine - init(): Some init file(s) are missing"));
            }
        });
    }

    @Override
    public void startSpeech(String requestId, @NonNull Context context, TaskCallback audioPlayerEndCallback) {
        String audioFolderPath =
                context.getExternalFilesDir(null).toString().concat(Constants.AUDIO_ARCHIVE_FOLDER_NAME);
        boolean isFemaleVoiceSelected = CnilApplication.readBooleanPreference(context,
                Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_FEMALE_VOICE, true);
        String voiceFolder = isFemaleVoiceSelected ?
                audioFilesLocations.getFemaleAudioLocation() : audioFilesLocations.getMaleAudioLocation();
        boolean isTtsFullArticle = CnilApplication.readBooleanPreference(context,
                Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_FULL_ARTICLE, true);
        String appendixFullOrShort = isTtsFullArticle ?
                "" : "_short";

        Uri myUri = Uri.parse(String.format("/%1$s/%2$s/%3$s_content%4$s.ogg",
                audioFolderPath, voiceFolder.substring(0, voiceFolder.length() - 1), requestId, appendixFullOrShort));

        try {
            if (mediaPlayer != null) {
                mediaPlayer.reset();
                mediaPlayer.setAudioAttributes(new AudioAttributes.Builder()
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .build()
                );
                mediaPlayer.setOnCompletionListener(mp -> {
                            isAudioConfigured = false;
                            audioPlayerEndCallback.onTaskCompleted(new VoiceAssistantError(VoiceAssistantError.ErrorType.NO_ERROR));
                        });
                mediaPlayer.setDataSource(context, myUri);
                mediaPlayer.prepare();
                mediaPlayer.start();

                isAudioConfigured = true;

                DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.TTS, String.format("%1$s audio has started", myUri.toString()));
            }
        } catch (IOException e) {
            e.printStackTrace();
            LogManager.addLog("TextToSpeechOggEngine - startSpeech(): Exception: " + e.getMessage());
        }
    }

    @Override
    public void playPauseSpeech() {
        if (mediaPlayer != null) {
            if (mediaPlayer.isPlaying()) {
                mediaPlayer.pause();
            } else {
                mediaPlayer.start();
            }
        }
    }

    @Override
    public void stopSpeech() {
        isAudioConfigured = false;
        if (mediaPlayer != null && mediaPlayer.isPlaying()) {
            mediaPlayer.stop();
        }
    }

    @Override
    public void unload() {
        mediaPlayer.reset();
        mediaPlayer.release();
        mediaPlayer = null;
    }

    private boolean verifyFilesAvailability(@NonNull AudioFilesLocations filesLocations, @NonNull Context context) {
        String audioFolderPath = context.getExternalFilesDir(null).toString().concat(Constants.AUDIO_ARCHIVE_FOLDER_NAME);
        try {
            boolean[] areAllFilesLoadedArray = new boolean[2];
            String femaleFolderPath = filesLocations.getFemaleAudioLocation().substring(
                    0, filesLocations.getFemaleAudioLocation().length() - 1
            );
            String maleFolderPath = filesLocations.getMaleAudioLocation().substring(
                    0, filesLocations.getMaleAudioLocation().length() - 1
            );
            areAllFilesLoadedArray[0] = FileManager.loadAllFilesFromFolder(
                    context.getAssets(),
                    femaleFolderPath,
                    audioFolderPath.concat("/").concat(femaleFolderPath));
            areAllFilesLoadedArray[1] = FileManager.loadAllFilesFromFolder(
                    context.getAssets(),
                    maleFolderPath,
                    audioFolderPath.concat("/").concat(maleFolderPath));

            boolean areAllFilesLoaded = true;
            for (boolean b : areAllFilesLoadedArray) {
                if (!b) {
                    areAllFilesLoaded = false;
                    break;
                }
            }

            return areAllFilesLoaded;
        } catch (IOException e) {
            e.printStackTrace();
            LogManager.addLog("TextToSpeechOggEngine - verifyFilesAvailability(): Exception: " + e.getMessage());

            return false;
        }
    }

    @Override
    public boolean getIsAudioPlaying() {
        if (mediaPlayer != null)
            return mediaPlayer.isPlaying();
        else
            return false;
    }

    @Override
    public boolean getIsAudioConfigured() {
        return isAudioConfigured;
    }
}
