package com.cnil.assistant.ui.adapters;

import android.os.Build;
import android.text.Html;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.ListAdapter;
import androidx.recyclerview.widget.RecyclerView;

import com.cnil.assistant.R;
import com.cnil.assistant.models.AnswerContent;
import com.cnil.assistant.ui.RecyclerViewOnClickListener;


public class VariantsAdapter extends ListAdapter<AnswerContent, VariantsAdapter.VariantsViewHolder> {
    private final RecyclerViewOnClickListener onRecyclerViewClickListener;


    public VariantsAdapter(RecyclerViewOnClickListener onClickListener) {
        super(DIFF_CALLBACK);
        onRecyclerViewClickListener = onClickListener;
    }

    @NonNull
    @Override
    public VariantsViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VariantsViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.variant_view_holder,
                        parent,false), onRecyclerViewClickListener);
    }

    @Override
    public void onBindViewHolder(@NonNull VariantsViewHolder holder, int position) {
        AnswerContent debugInfo = getItem(position);
        if (debugInfo != null) {
            holder.bind(debugInfo);
        }
    }

    public static final DiffUtil.ItemCallback<AnswerContent> DIFF_CALLBACK =
            new DiffUtil.ItemCallback<AnswerContent>() {
                @Override
                public boolean areItemsTheSame(
                        @NonNull AnswerContent oldDebugInfoModel, @NonNull AnswerContent newDebugInfoModel) {
                    return oldDebugInfoModel.getId().equals(newDebugInfoModel.getId());
                }
                @Override
                public boolean areContentsTheSame(
                        @NonNull AnswerContent oldDebugInfoModel, @NonNull AnswerContent newDebugInfoModel) {
                    return oldDebugInfoModel.equals(newDebugInfoModel);
                }
            };

    public static class VariantsViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        private final RecyclerViewOnClickListener onClickListener;
        private final TextView requestTextView;
        private final TextView responseTextView;
        private final TextView idRequestTextView;

        public VariantsViewHolder(@NonNull View itemView, RecyclerViewOnClickListener listener) {
            super(itemView);

            requestTextView = itemView.findViewById(R.id.answer_variant_request_text_view);
            responseTextView = itemView.findViewById(R.id.answer_variant_response_text_view);
            idRequestTextView = itemView.findViewById(R.id.id_request_text_view);

            itemView.setOnClickListener(this);
            onClickListener = listener;
        }

        public void bind(@NonNull AnswerContent model) {
            idRequestTextView.setText(String.format("%s", model.getId()));
            requestTextView.setText(model.getRequest());
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                responseTextView.setText(Html.fromHtml(model.getResponse(), Html.FROM_HTML_MODE_COMPACT).toString());
            } else {
                responseTextView.setText(Html.fromHtml(model.getResponse()).toString());
            }
        }

        @Override
        public void onClick(View v) {
            onClickListener.onClickListener(v, getAdapterPosition());
        }
    }
}
