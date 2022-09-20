package com.cnil.assistant.utils;

import android.content.Context;

import androidx.annotation.NonNull;

import com.cnil.assistant.CnilApplication;
import com.cnil.assistant.core.TaskCallback;
import com.cnil.assistant.models.DebugInfoModel;
import com.cnil.assistant.models.ServerMetadataJsonResponse;
import com.cnil.assistant.models.VoiceAssistantError;
import com.cnil.assistant.utils.sslHelper.SSLConnectionManager;

import org.json.JSONException;

import java.io.IOException;
import java.io.InputStream;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.util.Objects;
import java.util.concurrent.Executor;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.Response;
import okhttp3.ResponseBody;


public class UpdateArchiveManager {
    private final Executor executor;
    private Context context;

    public UpdateArchiveManager(Executor ex) {
        executor = ex;
    }

    public void checkUpdateNecessity(final Context ctx, final CheckUpdateInterface checkUpdateCallback) {
        context = ctx;
        executor.execute(() -> {
            try {
                downloadMetadata(context, checkUpdateCallback);
            } catch (Exception e) {
                LogManager.addLog("UpdateArchiveManager - checkUpdateNecessity(): Exception = " + e.getMessage());
            }
        });
    }

    private static void downloadMetadata(Context context, CheckUpdateInterface updateCallback) {
        try {
            SSLConnectionManager.prepareRequest(context, Constants.SERVER_DOWNLOAD_METADATA_API, new Callback() {
                public void onResponse(@NonNull Call call, @NonNull Response response) throws IOException {
                    try (ResponseBody responseBody = response.body()) {
                        int responseCode = response.code();
                        LogManager.addLog("UpdateArchiveManager - downloadMetadata(): response code = " + responseCode);
                        if (responseCode == Constants.RESPONSE_CODE_SUCCESS) {
                            String resp = Objects.requireNonNull(responseBody).string();
                            LogManager.addLog("UpdateArchiveManager - downloadMetadata() onResponse(): Response = " + resp);

                            try {
                                ServerMetadataJsonResponse serverMetadataJsonResponse = new ServerMetadataJsonResponse(resp);
                                updateCallback.OnCheckResult(
                                        new VoiceAssistantError(VoiceAssistantError.ErrorType.NO_ERROR),
                                        serverMetadataJsonResponse);
                            } catch (JSONException e) {
                                LogManager.addLog("UpdateArchiveManager - downloadMetadata() onResponse(): Exception = " + e.getMessage());
                                updateCallback.OnCheckResult(new VoiceAssistantError(VoiceAssistantError.ErrorType.UPDATE_INVALID_RESPONSE_ERROR,
                                        String.format("UpdateArchiveManager - downloadMetadata() onResponse(): Exception = %1$s", e.getMessage())),
                                        null);
                            }
                        }
                    }
                }

                public void onFailure(@NonNull Call call, @NonNull IOException e) {
                    e.printStackTrace();
                    LogManager.addLog("UpdateArchiveManager - downloadMetadata() onFailure(): Exception = " + e.getMessage());

                    updateCallback.OnCheckResult(new VoiceAssistantError(VoiceAssistantError.ErrorType.UPDATE_NO_INTERNET_CONNECTION,
                            String.format("UpdateArchiveManager - downloadMetadata() onFailure(): Exception = %1$s", e.getMessage())),
                            null);
                }
            });
        } catch (IOException | NoSuchAlgorithmException | KeyManagementException e) {
            e.printStackTrace();
            LogManager.addLog("UpdateArchiveManager - downloadMetadata(): Exception: " + e.getMessage());

            updateCallback.OnCheckResult(new VoiceAssistantError(VoiceAssistantError.ErrorType.UPDATE_INVALID_RESPONSE_ERROR,
                    String.format("UpdateArchiveManager - downloadMetadata() catch(): Exception = %1$s", e.getMessage())),
                    null);
        }
    }

    public void downloadArchive(@NonNull Context context, String url, String checksum, String folder, String version, int archiveType, TaskCallback updateCallback) {
        String pathToFile = context.getExternalFilesDir(null).toString() + folder;

        boolean isZipFolderDeleted = true;
        if (FileManager.doesFolderExist(pathToFile)) {
            isZipFolderDeleted = FileManager.deleteFolder(pathToFile);
        }
        LogManager.addLog("UpdateArchiveManager - downloadArchive(): isZipFolderDeleted = " + isZipFolderDeleted);

        try {
            SSLConnectionManager.prepareRequest(context, url, new Callback() {
                public void onResponse(@NonNull Call call, @NonNull Response response) throws IOException {
                    try (ResponseBody responseBody = response.body()) {
                        int responseCode = response.code();
                        LogManager.addLog("UpdateArchiveManager - downloadArchive() onResponse(): Response code = " + responseCode);
                        if (responseCode == Constants.RESPONSE_CODE_SUCCESS) {
                            try (InputStream inputStream = Objects.requireNonNull(responseBody).byteStream()) {
                                String pathToOutputFile = pathToFile.substring(0, pathToFile.lastIndexOf("/"));
                                String nameOutputFile = pathToFile.substring(pathToFile.lastIndexOf("/") + 1);
                                boolean zipFileDownloadResult = FileManager.createFileFromInputStream(inputStream, pathToOutputFile, nameOutputFile);

                                if (zipFileDownloadResult && Utils.isMD5ChecksumMatches(pathToFile, checksum)) {
                                    unzipArchive(context, pathToFile, version, archiveType, updateCallback);
                                } else {
                                    LogManager.addLog(String.format("UpdateArchiveManager - downloadArchive() onResponse(): " +
                                            "zipFileDownloadResult is = %1$s, Utils.isMD5ChecksumMatches(pathToFile, checksum) = %2$s",
                                            zipFileDownloadResult, Utils.isMD5ChecksumMatches(pathToFile, checksum)));

                                    updateCallback.onTaskCompleted(new VoiceAssistantError(VoiceAssistantError.ErrorType.UPDATE_INVALID_RESPONSE_ERROR,
                                            String.format("UpdateArchiveManager - downloadArchive() onResponse(): " +
                                                            "zipFileDownloadResult is = %1$s, Utils.isMD5ChecksumMatches(pathToFile, checksum) = %2$s",
                                                    zipFileDownloadResult, Utils.isMD5ChecksumMatches(pathToFile, checksum))));
                                }
                            } catch (NoSuchAlgorithmException e) {
                                e.printStackTrace();
                                LogManager.addLog("UpdateArchiveManager - downloadArchive() onResponse(): Exception: " + e.getMessage());

                                updateCallback.onTaskCompleted(new VoiceAssistantError(VoiceAssistantError.ErrorType.UPDATE_INVALID_RESPONSE_ERROR,
                                        String.format("UpdateArchiveManager - downloadArchive() onResponse(): Exception = %1$s", e.getMessage())));
                            }
                        }
                    }
                }

                public void onFailure(@NonNull Call call, @NonNull IOException e) {
                    e.printStackTrace();
                    LogManager.addLog("UpdateArchiveManager - downloadArchive() onFailure(): Exception = " + e.getMessage());

                    updateCallback.onTaskCompleted(new VoiceAssistantError(VoiceAssistantError.ErrorType.UPDATE_NO_INTERNET_CONNECTION,
                            String.format("UpdateArchiveManager - downloadArchive() onFailure(): Exception = %1$s", e.getMessage())));
                }
            });
        } catch (NoSuchAlgorithmException | KeyManagementException | IOException e) {
            e.printStackTrace();
            LogManager.addLog("UpdateArchiveManager - downloadArchive() Exception: " + e.getMessage());

            updateCallback.onTaskCompleted(new VoiceAssistantError(VoiceAssistantError.ErrorType.UPDATE_INVALID_RESPONSE_ERROR,
                    String.format("UpdateArchiveManager - downloadArchive() Exception(): Exception = %1$s", e.getMessage())));
        }
    }

    private static void unzipArchive(@NonNull Context context, String pathToFile, String version, int archiveType, TaskCallback updateCallback) {
        String targetFolderName = Constants.AUDIO_ARCHIVE_FOLDER_NAME;
        String tempFolderName = Constants.AUDIO_ARCHIVE_TEMP_FOLDER_NAME;
        String zipFolderName = Constants.AUDIO_ZIP_FOLDER_NAME;
        if (archiveType == 0) {
            targetFolderName = Constants.ARCHIVE_FOLDER_NAME;
            tempFolderName = Constants.ARCHIVE_TEMP_FOLDER_NAME;
            zipFolderName = Constants.MODEL_ZIP_FOLDER_NAME;
        }

        String modelsPath = context.getExternalFilesDir(null).toString();
        boolean unzipResult = FileManager.unzip(pathToFile, modelsPath + tempFolderName);

        boolean isZipFolderDeleted = true;
        if (FileManager.doesFolderExist(modelsPath + zipFolderName)) {
            isZipFolderDeleted = FileManager.deleteFolder(modelsPath + zipFolderName);
        }
        LogManager.addLog("UpdateArchiveManager - unzipArchive(): isZipFolderDeleted = " + isZipFolderDeleted);

        if (unzipResult) {
            boolean renameResult = FileManager.renameFile(
                    modelsPath + tempFolderName, modelsPath + targetFolderName);
            if (renameResult) {
                CnilApplication.writeStringPreference(
                        context, Constants.SHARED_PREFERENCES_KEY_CURRENT_INSTALLED_VERSION, version);

                DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.COMMON,
                        String.format("UpdateManager: New files download and unzip process successfully finished, version = %1$s", version));
                updateCallback.onTaskCompleted(new VoiceAssistantError(VoiceAssistantError.ErrorType.NO_ERROR));
            } else {
                boolean isTempFolderDeleted = true;
                if (FileManager.doesFolderExist(modelsPath + tempFolderName)) {
                    isTempFolderDeleted = FileManager.deleteFolder(modelsPath + tempFolderName);
                }
                LogManager.addLog("UpdateArchiveManager - unzipArchive(): isTempFolderDeleted = " + isTempFolderDeleted);

                DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.COMMON,
                        String.format("UpdateManager: New files download and unzip process finished with error, version = %1$s", version));
                updateCallback.onTaskCompleted(new VoiceAssistantError(VoiceAssistantError.ErrorType.UPDATE_INVALID_RESPONSE_ERROR,
                        String.format("UpdateArchiveManager - unzipArchive(): New files download and unzip process finished with error, version = %1$s", version)));
            }
        } else {
            DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.COMMON,
                    String.format("UpdateManager: New files download and unzip process finished with error, version = %1$s", version));
            updateCallback.onTaskCompleted(new VoiceAssistantError(VoiceAssistantError.ErrorType.UPDATE_INVALID_RESPONSE_ERROR,
                    String.format("UpdateArchiveManager - unzipArchive(): New files download and unzip process finished with error, version = %1$s", version)));
        }
    }
}
