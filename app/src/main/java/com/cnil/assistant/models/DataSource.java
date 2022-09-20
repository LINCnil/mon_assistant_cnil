package com.cnil.assistant.models;

public class DataSource {
    public enum DataSourceType {
        AUDIO_STREAM,
        TEXT
    }

    private final DataSourceType selectedDataSourceType;
    private String dataSourceString;

    public DataSource() {
        selectedDataSourceType = DataSourceType.AUDIO_STREAM;
    }

    public DataSource(String text) {
        dataSourceString = text;
        selectedDataSourceType = DataSourceType.TEXT;
    }

    public String getStringDataSource() {
        return dataSourceString;
    }

    public DataSourceType getDataSourceType() {
        return selectedDataSourceType;
    }
}
