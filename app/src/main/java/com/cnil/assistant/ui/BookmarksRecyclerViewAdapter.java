package com.cnil.assistant.ui;

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


public class BookmarksRecyclerViewAdapter extends ListAdapter<AnswerContent, BookmarksRecyclerViewAdapter.ArticlePreviewViewHolder> {

    private final RecyclerViewOnClickListener onBookmarksRecyclerViewClickListener;

    public BookmarksRecyclerViewAdapter(RecyclerViewOnClickListener onClickListener) {
        super(DIFF_CALLBACK);
        onBookmarksRecyclerViewClickListener = onClickListener;
    }

    @NonNull
    @Override
    public ArticlePreviewViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ArticlePreviewViewHolder(LayoutInflater.from(
                parent.getContext()).inflate(R.layout.article_preview_view_holder, parent,false),
                onBookmarksRecyclerViewClickListener);
    }

    @Override
    public void onBindViewHolder(@NonNull ArticlePreviewViewHolder holder, int position) {
        AnswerContent answerContent = getItem(position);
        if (answerContent != null) {
            holder.bind(answerContent);
        }
    }

    public static final DiffUtil.ItemCallback<AnswerContent> DIFF_CALLBACK =
            new DiffUtil.ItemCallback<AnswerContent>() {
                @Override
                public boolean areItemsTheSame(
                        @NonNull AnswerContent oldAnswerContent, @NonNull AnswerContent newAnswerContent) {
                    return oldAnswerContent.getId().equals(newAnswerContent.getId());
                }
                @Override
                public boolean areContentsTheSame(
                        @NonNull AnswerContent oldAnswerContent, @NonNull AnswerContent newAnswerContent) {
                    return oldAnswerContent.equals(newAnswerContent);
                }
            };

    public static class ArticlePreviewViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        private final RecyclerViewOnClickListener onClickListener;

        private final TextView previewRequestTextView;
        private final TextView previewResponseTextView;


        public ArticlePreviewViewHolder(@NonNull View itemView, RecyclerViewOnClickListener listener) {
            super(itemView);

            previewRequestTextView = itemView.findViewById(R.id.preview_request_text_view);
            previewResponseTextView = itemView.findViewById(R.id.preview_response_text_view);

            itemView.setOnClickListener(this);
            onClickListener = listener;
        }

        public void bind(@NonNull AnswerContent model) {
            if (model != null) {
                previewRequestTextView.setText(model.getRequest());
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    previewResponseTextView.setText(Html.fromHtml(model.getResponse(), Html.FROM_HTML_MODE_COMPACT).toString());
                } else {
                    previewResponseTextView.setText(Html.fromHtml(model.getResponse()).toString());
                }
            }
        }

        @Override
        public void onClick(View v) {
            onClickListener.onClickListener(v, getAdapterPosition());
        }
    }
}
