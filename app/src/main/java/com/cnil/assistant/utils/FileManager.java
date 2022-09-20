package com.cnil.assistant.utils;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Pair;

import androidx.annotation.NonNull;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;


public class FileManager {
    public static String loadJSONFromAsset(@NonNull Context context, String fileName) throws IOException {
        String json = null;

        InputStream is = context.getAssets().open(fileName);
        byte[] buffer = new byte[is.available()];
        if (is.read(buffer) != -1) {
            json = new String(buffer, StandardCharsets.UTF_8);
        }
        is.close();

        return json;
    }

    public static @NonNull String loadJSONFromFile(String path) throws IOException {
        StringBuilder sb = new StringBuilder();
        File file = new File(path);
        if (file.exists()) {
            FileInputStream fin = new FileInputStream(file);
            BufferedReader reader = new BufferedReader(new InputStreamReader(fin));

            String line;
            while (null != (line = reader.readLine())) {
                sb.append(line).append("\n");
            }
            reader.close();
            fin.close();
        }

        return sb.toString();
    }

    public static void copyAssetFileToInternalStorage(AssetManager assetManager, String fromFileName, String toFolderPath)
            throws IOException {
        try {
            Pair<String, String> fileDetails = getFilePathAndName(toFolderPath, fromFileName);
            File f = new File(fileDetails.first);
            boolean isFolderCreated = true;
            if (!f.exists()) {
                isFolderCreated = f.mkdirs();
            }

            if (isFolderCreated) {
                File file = new File(toFolderPath + "/" + fromFileName);
                if (!file.exists()) {
                    InputStream is = assetManager.open(fromFileName);
                    byte[] buffer = new byte[is.available()];
                    if (is.read(buffer) != -1) {
                        FileOutputStream fos = new FileOutputStream(file);
                        fos.write(buffer);
                        fos.close();
                    }
                    is.close();
                }
            }
        } catch (IOException e) {
            throw new IOException(e);
        }
    }

    public static void copyFolderWithFilesToInternalStorage(AssetManager assetManager, String fromFilePath, String toFolderPath)
            throws IOException {
        try {
            File f = new File(toFolderPath);
            boolean isFolderCreated = true;
            if (!f.exists()) {
                isFolderCreated = f.mkdirs();
            }

            if (isFolderCreated) {
                String[] fileList = assetManager.list(fromFilePath);
                for (String filePath : fileList) {
                    String toArchiveFolderPath = toFolderPath.substring(0, toFolderPath.lastIndexOf("/"));
                    copyAssetFileToInternalStorage(assetManager, fromFilePath.concat("/").concat(filePath), toArchiveFolderPath);
                }
            }
        } catch (IOException e) {
            throw new IOException(e);
        }
    }

    public static boolean unzip(String zipFile, String location) {
        try {
            boolean isFolderCreated = true;
            File f = new File(location);
            if (!f.isDirectory()) {
                isFolderCreated = f.mkdirs();
            }

            if (isFolderCreated) {
                try {
                    ZipInputStream zipInputStream = new ZipInputStream(new FileInputStream(zipFile));
                    ZipEntry zEntry;
                    while ((zEntry = zipInputStream.getNextEntry()) != null) {
                        String path = location + "/" + zEntry.getName();
                        LogManager.addLog("Unzipping " + zEntry.getName() + " at " + path);

                        if (zEntry.isDirectory()) {
                            File unzipFile = new File(path);
                            if (!unzipFile.isDirectory()) {
                                if (!unzipFile.mkdirs()) {
                                    return false;
                                }
                                zipInputStream.closeEntry();
                            }
                        } else {
                            try (FileOutputStream fOut = new FileOutputStream(path, false)) {
                                BufferedOutputStream bufferedOutputStream = new BufferedOutputStream(fOut);
                                byte[] buffer = new byte[4 * 1024];
                                int read;
                                while ((read = zipInputStream.read(buffer)) != -1) {
                                    bufferedOutputStream.write(buffer, 0, read);
                                }

                                zipInputStream.closeEntry();
                                bufferedOutputStream.close();
                            }
                        }
                    }
                    zipInputStream.close();
                    LogManager.addLog("Unzipping fully completed. Location: " + location);

                    return true;
                } catch (Exception e) {
                    LogManager.addLog("Unzipping failed with exception: " + e.getMessage());
                    return false;
                }
            } else {
                LogManager.addLog("Unzipping failed with error: File is not created");
                return false;
            }
        } catch (Exception ex) {
            LogManager.addLog("Unzipping failed with exception: " + ex.getMessage());
            return false;
        }
    }

    public static boolean createFileFromInputStream(InputStream inputStream, String toFolderPath, String toFileName) {
        try {
            File f = new File(toFolderPath);
            boolean isFolderCreated = true;
            if (!f.exists()) {
                isFolderCreated = f.mkdirs();
            }

            boolean downloadResult = false;
            if (isFolderCreated) {
                File file = new File(toFolderPath + "/" + toFileName);
                if (!file.exists()) {
                    FileOutputStream outputStream = new FileOutputStream(file);
                    downloadResult = writeFromInputStreamToOutputStream(inputStream, outputStream);
                }
            }

            return downloadResult;
        } catch (FileNotFoundException fileNotFoundEx) {
            fileNotFoundEx.printStackTrace();
            return false;
        }
    }

    private static boolean writeFromInputStreamToOutputStream(InputStream inputStream, FileOutputStream outputStream) {
        BufferedInputStream bufferedInputStream = null;
        try {
            bufferedInputStream = new BufferedInputStream(inputStream);
            byte[] buffer = new byte[1024 * 4];
            int readBytes;

            while ((readBytes = bufferedInputStream.read(buffer, 0, buffer.length)) > 0) {
                LogManager.addLog("FileManager - writeFromInputStreamToOutputStream(): readBytes = " + readBytes);
                outputStream.write(buffer, 0, readBytes);
            }

            return true;
        } catch (IOException ioEx) {
            LogManager.addLog("FileManager - writeFromInputStreamToOutputStream(): IOException = " + ioEx.getMessage());
            return false;
        } catch (Exception e) {
            LogManager.addLog("FileManager - writeFromInputStreamToOutputStream(): Exception = " + e.getMessage());
            return false;
        } finally {
            try {
                if (bufferedInputStream != null) {
                    bufferedInputStream.close();
                }
                inputStream.close();
                outputStream.flush();
                outputStream.close();
            } catch (IOException ioEx) {
                LogManager.addLog("FileManager - writeFromInputStreamToOutputStream() finally: Exception = " + ioEx.getMessage());
            }
        }
    }

    public static boolean renameFile(String fromName, @NonNull String toName) {
        File oldFile = new File(toName);
        if (oldFile.exists()) {
            boolean isFolderDeleted = deleteFolder(oldFile);
            if (!isFolderDeleted || oldFile.exists()) {
                return false;
            }
        }

        boolean isRenamed = false;
        File newFile = new File(fromName);
        if (newFile.exists()) {
            isRenamed = newFile.renameTo(new File(toName));
        }

        return isRenamed;
    }

    public static boolean deleteFolder(String path) {
        File directory = new File(path);
        return deleteFolder(directory);
    }

    private static boolean deleteFolder(@NonNull File folder) {
        boolean isDeleted = false;
        if (folder.isDirectory()) {
            String[] children = folder.list();
            if (children != null && children.length == 0) {
                isDeleted = folder.delete();
                return isDeleted;
            }
            if (children != null) {
                for (String child : children) {
                    deleteFolder(new File(folder, child));
                    isDeleted = folder.delete();
                }
            }
        } else {
            isDeleted = folder.delete();
        }

        return isDeleted;
    }

    public static boolean checkIfFileIsLoaded(AssetManager assetManager, String fromFileName, String toFolderPath)
            throws IOException {
        File file = new File(toFolderPath + "/" + fromFileName);
        if (file.exists()) {
            return true;
        } else {
            copyAssetFileToInternalStorage(assetManager, fromFileName, toFolderPath);
        }

        return new File(toFolderPath + "/" + fromFileName).exists();
    }

    public static boolean loadAllFilesFromFolder(AssetManager assetManager, String fromFolderPath, String toFolderPath)
            throws IOException {
        File questionsFolder = new File(toFolderPath);

        boolean isFolderCreated = true;
        if (!questionsFolder.exists()) {
            isFolderCreated = questionsFolder.mkdirs();
        }

        if (isFolderCreated) {
            if (questionsFolder.exists() && questionsFolder.isDirectory() &&
                    Objects.requireNonNull(questionsFolder.list()).length > 0) {
                return true;
            } else {
                copyFolderWithFilesToInternalStorage(assetManager, fromFolderPath, toFolderPath);
            }
        }

        File questionsNewFolder = new File(toFolderPath);
        return questionsNewFolder.exists() && questionsNewFolder.isDirectory() &&
                Objects.requireNonNull(questionsNewFolder.list()).length > 0;
    }

    public static @NonNull Pair<String, String> getFilePathAndName(String folderPath, @NonNull String fileName) {
        if (fileName.contains("/")) {
            folderPath = folderPath.concat("/").concat(fileName.substring(0, fileName.lastIndexOf("/")));
            fileName = fileName.substring(fileName.lastIndexOf("/") + 1);
        }
        return new Pair<>(folderPath, fileName);
    }

    public static boolean createFolder(String path) {
        File f = new File(path);
        boolean isFolderCreated = true;
        if (!f.exists()) {
            isFolderCreated = f.mkdirs();
        }
        return isFolderCreated;
    }

    public static boolean doesFolderExist(String path) {
        File f = new File(path);
        return f.exists();
    }

//    public static void writeLogFile(String modelsFolderPath, String message) {
//        File file = new File(modelsFolderPath + "/log.txt");
//        try {
//            FileWriter fr = new FileWriter(file, true);
//            BufferedWriter br = new BufferedWriter(fr);
//            PrintWriter pr = new PrintWriter(br);
//            pr.println(String.format("%1$s: %2$s", new Date(), message));
//            pr.close();
//            br.close();
//            fr.close();
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
//    }

    public static void writeBookmarksListToFile(String bookmarksPath, List<String> bookmarks) {
        File file = new File(bookmarksPath);

        if (file.exists()) {
            deleteFolder(file);
        }

        try {
            FileWriter fr = new FileWriter(file, true);
            BufferedWriter br = new BufferedWriter(fr);
            PrintWriter pr = new PrintWriter(br);

            for (String id : bookmarks) {
                pr.println(id);
            }

            pr.close();
            br.close();
            fr.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static @NonNull ArrayList<String> readBookmarksListFromFile(String bookmarksPath) throws IOException {
        ArrayList<String> bookmarksArrayList = new ArrayList<>();

        File file = new File(bookmarksPath);
        if (file.exists()) {
            FileInputStream fin = new FileInputStream(file);
            BufferedReader reader = new BufferedReader(new InputStreamReader(fin));

            String line;
            while ((line = reader.readLine()) != null) {
               bookmarksArrayList.add(line);
            }
            reader.close();
            fin.close();
        }

        return bookmarksArrayList;
    }
}
