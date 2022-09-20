package com.cnil.assistant.ui.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.ListAdapter;
import androidx.recyclerview.widget.RecyclerView;

import com.cnil.assistant.R;
import com.cnil.assistant.models.DebugInfoModel;
import com.cnil.assistant.utils.Constants;

import java.text.SimpleDateFormat;
import java.util.Locale;


public class DebugInfoAdapter extends ListAdapter<DebugInfoModel, DebugInfoAdapter.DebugInfoViewHolder> {
    public DebugInfoAdapter() {
        super(DIFF_CALLBACK);
    }

    @NonNull
    @Override
    public DebugInfoViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new DebugInfoViewHolder(
                LayoutInflater.from(parent.getContext()).inflate(R.layout.debug_info_view_holder,
                        parent,false));
    }

    @Override
    public void onBindViewHolder(@NonNull DebugInfoViewHolder holder, int position) {
        DebugInfoModel debugInfo = getItem(position);
        if (debugInfo != null) {
            holder.bind(debugInfo);
        }
    }

    public static final DiffUtil.ItemCallback<DebugInfoModel> DIFF_CALLBACK =
            new DiffUtil.ItemCallback<DebugInfoModel>() {
                @Override
                public boolean areItemsTheSame(
                        @NonNull DebugInfoModel oldDebugInfoModel, @NonNull DebugInfoModel newDebugInfoModel) {
                    return oldDebugInfoModel.getRecordId() == newDebugInfoModel.getRecordId();
                }
                @Override
                public boolean areContentsTheSame(
                        @NonNull DebugInfoModel oldDebugInfoModel, @NonNull DebugInfoModel newDebugInfoModel) {
                    return oldDebugInfoModel.equals(newDebugInfoModel);
                }
            };

    public static class DebugInfoViewHolder extends RecyclerView.ViewHolder {
        private final Locale[] LOCALES = {
                Locale.getDefault(),
                Locale.US,
                Locale.FRANCE
        };

        private final TextView componentTagTextView;
        private final TextView messageTextView;
        private final TextView timestampTextView;

        public DebugInfoViewHolder(@NonNull View itemView) {
            super(itemView);

            componentTagTextView = itemView.findViewById(R.id.component_tag_text_view);
            messageTextView = itemView.findViewById(R.id.message_text_view);
            timestampTextView = itemView.findViewById(R.id.timestamp_text_view);
        }

        public void bind(@NonNull DebugInfoModel model) {
            componentTagTextView.setText(model.getComponentTag().name());
            messageTextView.setText(model.getMessage());
            timestampTextView.setText(new SimpleDateFormat(Constants.DATE_TIME_FORMAT, LOCALES[2]).format(model.getTimestamp()));
        }
    }
}
