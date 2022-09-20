package com.cnil.assistant.utils;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;


public class LogManager {
    private static final String CNIL_VA_TAG = "CNIL_VA";

    @SuppressWarnings({"FieldCanBeLocal", "RedundantSuppression", "unused"})
    private static String modelsFolderPath = "";

    public static void generateLogsFilePath(@NonNull Context ctx) {
        modelsFolderPath = ctx.getExternalFilesDir(null).toString();
    }

    public static void addLog(String message) {
        Log.d(CNIL_VA_TAG, message);
        // Uncomment once logs are needed
        //writeToFile(message);
    }


    // Uncomment once logs are needed
//    private static void writeToFile(String message) {
//        if (!modelsFolderPath.equals("")) {
//            FileManager.writeLogFile(modelsFolderPath, message);
//        }
//    }
}
