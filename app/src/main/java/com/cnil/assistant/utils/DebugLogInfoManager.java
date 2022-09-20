package com.cnil.assistant.utils;

import android.content.Context;

import com.cnil.assistant.models.DebugInfoModel;

import java.io.File;
import java.io.FileWriter;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;


public class DebugLogInfoManager {
    private static final ArrayList<DebugInfoModel> debugInfoArrayList = new ArrayList<>();
    private static int debugInfoRecordId = 0;

    private static final String LOGS_FOLDER_NAME = "logs";
    private static final String LOGS_FILE_NAME_FORMAT = "CNIL_VA_log_%1$s.txt";


    public static void addDebugInfo(DebugInfoModel.ComponentTag componentTag, String message) {
        debugInfoArrayList.add(new DebugInfoModel(debugInfoRecordId++, componentTag, message));
        notifyObservers();
    }

    public static void clearLogs() {
        debugInfoArrayList.clear();
        notifyObservers();
    }

    public static void exportDebugInfoToFile(Context context) {
        try {
            String timeStamp = new SimpleDateFormat(Constants.DATE_TIME_FORMAT, Locale.FRANCE).format(new Date());
            String folderName = String.format("%1$s//%2$s", context.getExternalFilesDir(null).toString(), LOGS_FOLDER_NAME);
            File directory = new File(folderName);

            boolean isFolderCreated = true;
            if (!directory.exists()) {
                isFolderCreated = directory.mkdirs();
            }

            if (isFolderCreated) {
                File file = new File(folderName + "/" + String.format(LOGS_FILE_NAME_FORMAT, timeStamp));

                FileWriter writer = new FileWriter(file);
                for (int i = 0; i < debugInfoArrayList.size(); i++) {
                    DebugInfoModel debugInfo = debugInfoArrayList.get(i);
                    writer.append(String.format("[%1$s]: %2$s - %3$s\n", debugInfo.getTimestamp(), debugInfo.getComponentTag(), debugInfo.getMessage()));
                }

                writer.flush();
                writer.close();
            }
        } catch (Exception e) {
            LogManager.addLog("DebugLogInfoManager - exportDebugInfoToFile(): Exception = " + e.getMessage());
        }
    }


    private static final List<Observer> observers = new ArrayList<>();

    private static void notifyObservers() {
        for (int i = 0; i < observers.size(); i++) {
            observers.get(i).onDebugInfoUpdated(debugInfoArrayList);
        }
    }

    public static void addObserver(Observer observer) {
        observers.add(observer);
        notifyObservers();
    }

    public static void removeObserver(Observer observer) {
        observers.remove(observer);
    }

    public interface Observer {
        void onDebugInfoUpdated(ArrayList<DebugInfoModel> list);
    }
}