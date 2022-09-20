package com.cnil.assistant.utils;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.core.content.pm.PackageInfoCompat;

import com.cnil.assistant.CnilApplication;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class Utils {
    public static @NonNull String getApplicationVersion(@NonNull Context context) {
        try {
            return context.getPackageManager().
                    getPackageInfo(context.getPackageName(), 0).versionName;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

        return "";
    }

    public static @NonNull String getApplicationVersionCode(@NonNull Context context) {
        try {
            return String.valueOf(PackageInfoCompat.getLongVersionCode(context.getPackageManager().
                    getPackageInfo(context.getPackageName(), 0)));
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

        return "";
    }

    public static @NonNull String getModelVersion(@NonNull Context context) {
        return CnilApplication.readStringPreference(
                context, Constants.SHARED_PREFERENCES_KEY_CURRENT_INSTALLED_VERSION, "-");
    }

    public static @NonNull String logAppLaunchDetails(@NonNull Context context) {
        String format = "\n[%1$s]: %2$s;";
        try {
            PackageInfo pInfo = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);

            return "Application launch details:" +
                    String.format(format, "AppVersion", pInfo.versionName) +
                    String.format(format, "Device manufacturer", Build.MANUFACTURER) +
                    String.format(format, "Device model", Build.MODEL);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

        return "";
    }

    private static @NonNull String getFileChecksum(@NonNull MessageDigest digest, @NonNull File file)
            throws IOException {
        byte[] byteArray = new byte[1024];
        int bytesCount;

        FileInputStream fis = new FileInputStream(file);
        while ((bytesCount = fis.read(byteArray)) != -1) {
            digest.update(byteArray, 0, bytesCount);
        }
        fis.close();

        byte[] bytes = digest.digest();

        StringBuilder sb = new StringBuilder();
        for (byte aByte : bytes) {
            sb.append(Integer.toString((aByte & 0xff) + 0x100, 16).substring(1));
        }

        return sb.toString();
    }

    public static boolean isMD5ChecksumMatches(String inputFilePath, @NonNull String targetChecksum)
            throws NoSuchAlgorithmException, IOException {
        MessageDigest md5Digest = MessageDigest.getInstance("MD5");
        String checksum = getFileChecksum(md5Digest, new File(inputFilePath));

        return targetChecksum.equals(checksum);
    }

    public static boolean isVersionAlreadyInstalled(Context context, String availableVersion) {
        String currentVersion = CnilApplication.readStringPreference(
                context, Constants.SHARED_PREFERENCES_KEY_CURRENT_INSTALLED_VERSION, "");
        return currentVersion.equals(availableVersion);
    }

    public static boolean isNewFilesVersionSupported(String availableVersion) {
        double minDefaultVersion = 1.0;
        double newVersion;

        String pattern = "v(\\d+[.]\\d+)_";
        Matcher matcher = Pattern.compile(pattern).matcher(availableVersion);
        if (matcher.find()) {
            String versionPattern = matcher.group();
            try {
                newVersion = Double.parseDouble(versionPattern.substring(1, versionPattern.length() - 1));
            } catch (NumberFormatException nfEx) {
                LogManager.addLog("Utils - isNewFilesVersionSupported(): NumberFormatException occurred: " + nfEx.getMessage());
                newVersion = minDefaultVersion;
            }
             return newVersion == Constants.SUPPORTED_ARCHITECTURE_VERSION;
        }

        return false;
    }

    public static ArrayList<String> readBookmarksList(Context context) {
        ArrayList<String> bookmarksArrayListTemp = new ArrayList<>();

        try {
            bookmarksArrayListTemp = FileManager.readBookmarksListFromFile(
                    context.getExternalFilesDir(null).toString().concat("/").concat(Constants.BOOKMARKS_FILE_NAME));
        } catch (IOException e) {
            e.printStackTrace();
        }

        return bookmarksArrayListTemp;
    }
}
