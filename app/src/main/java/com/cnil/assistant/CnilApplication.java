package com.cnil.assistant;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;

import androidx.annotation.NonNull;

import com.cnil.assistant.utils.Constants;
import com.cnil.assistant.utils.LogManager;


public class CnilApplication extends Application {
    private static CnilApplication instance;

    public static Context getAppContext(){
        return instance.getApplicationContext();
    }

    @Override
    public void onCreate() {
        super.onCreate();

        instance = this;
        LogManager.generateLogsFilePath(getAppContext());
    }

    public static String readStringPreference(@NonNull Context context, String key, String defaultValue) {
        SharedPreferences sharedPref =
                context.getSharedPreferences(Constants.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
        return sharedPref.getString(key, defaultValue);
    }

    public static void writeStringPreference(@NonNull Context context, String key, String value) {
        SharedPreferences sharedPref =
                context.getSharedPreferences(Constants.SHARED_PREFERENCES_NAME,Context.MODE_PRIVATE);
        sharedPref.edit().putString(key, value).apply();
    }

    public static boolean readBooleanPreference(@NonNull Context context, String key, boolean defaultValue) {
        SharedPreferences sharedPref =
                context.getSharedPreferences(Constants.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
        return sharedPref.getBoolean(key, defaultValue);
    }

    public static void writeBooleanPreference(@NonNull Context context, String key, boolean value) {
        SharedPreferences sharedPref =
                context.getSharedPreferences(Constants.SHARED_PREFERENCES_NAME,Context.MODE_PRIVATE);
        sharedPref.edit().putBoolean(key, value).apply();
    }
}
