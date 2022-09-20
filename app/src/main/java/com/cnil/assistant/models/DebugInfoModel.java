package com.cnil.assistant.models;

import com.cnil.assistant.utils.LogManager;

import java.util.Date;
import java.util.Objects;


public class DebugInfoModel {
    @SuppressWarnings("unused, RedundantSuppression")
    public enum ComponentTag {STT, NLP, DB, TTS, COMMON}

    private final int recordId;
    private final ComponentTag componentTag;
    private final String message;
    private final Date timestamp;

    public DebugInfoModel(int recordId, ComponentTag componentTag, String message) {
        this.recordId = recordId;
        this.componentTag = componentTag;
        this.message = message;
        timestamp = new Date();

        LogManager.addLog(String.format("DebugInfoModel - DebugInfoModel(): componentTag = %1$s, message = %2$s, timestamp = %3$s",
                componentTag, message, timestamp));
    }

    public int getRecordId() {
        return recordId;
    }

    public ComponentTag getComponentTag() {
        return componentTag;
    }

    public String getMessage() {
        return message;
    }

    public Date getTimestamp() {
        return timestamp;
    }

    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) return false;
        DebugInfoModel debugInfoModel = (DebugInfoModel) o;
        return Objects.equals(message, debugInfoModel.message) &&
                Objects.equals(componentTag, debugInfoModel.componentTag) &&
                Objects.equals(timestamp, debugInfoModel.timestamp);
    }
}
