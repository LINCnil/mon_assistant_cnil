package com.cnil.assistant.ui.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.ListAdapter;
import androidx.recyclerview.widget.RecyclerView;

import com.cnil.assistant.R;
import com.cnil.assistant.models.AnswerContent;
import com.cnil.assistant.models.ConversationModel;
import com.cnil.assistant.ui.callbacks.AnswerVariantsRecyclerViewOnClickListener;

import java.util.ArrayList;


public class ConversationAdapter extends ListAdapter<ConversationModel, ConversationAdapter.ConversationViewHolder> {
    private final AnswerVariantsRecyclerViewOnClickListener onRecyclerViewClickListener;


    public ConversationAdapter(AnswerVariantsRecyclerViewOnClickListener onRecyclerClickListener) {
        super(DIFF_CALLBACK);
        onRecyclerViewClickListener = onRecyclerClickListener;
    }

    @NonNull
    @Override
    public ConversationViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        if (viewType == ConversationModel.ConversationType.ANSWER.getValue()) {
            return new AnswerViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.answer_view_holder, parent,false),
                    onRecyclerViewClickListener);
        } else if (viewType == ConversationModel.ConversationType.ANSWER_REQUEST_FAILED.getValue()) {
            return new AnswerRequestFailedViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.nothing_found_view_holder, parent,false));
        }
        return new AnswerRequestFailedViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.nothing_found_view_holder, parent,false));
    }

    @Override
    public void onBindViewHolder(@NonNull ConversationViewHolder holder, int position) {
        ConversationModel conversationModel = getItem(position);
        if (conversationModel != null) {
            holder.bind(conversationModel);
        }
    }

    @Override
    public int getItemViewType(int position) {
        ConversationModel conversationModel = getItem(position);
        return conversationModel.getConversationType().getValue();
    }

    public static final DiffUtil.ItemCallback<ConversationModel> DIFF_CALLBACK =
        new DiffUtil.ItemCallback<ConversationModel>() {
            @Override
            public boolean areItemsTheSame(
                    @NonNull ConversationModel oldConversationModel, @NonNull ConversationModel newConversationModel) {
                return oldConversationModel.getRequestId() == newConversationModel.getRequestId();
            }
            @Override
            public boolean areContentsTheSame(
                    @NonNull ConversationModel oldUser, @NonNull ConversationModel newUser) {
                return oldUser.equals(newUser);
            }
        };

    public abstract static class ConversationViewHolder extends RecyclerView.ViewHolder {
        public ConversationViewHolder(@NonNull View itemView) { super(itemView); }

        public abstract void bind(ConversationModel model);
    }

    public static class AnswerViewHolder extends ConversationViewHolder {
        private final Context context;
        private final AnswerVariantsRecyclerViewOnClickListener onClickListener;
        private ArrayList<AnswerContent> answerContentsArrayList;
        private final RecyclerView variantsRecyclerView;
        private final TextView sttRequestTextView;


        public AnswerViewHolder(@NonNull View itemView,
                                AnswerVariantsRecyclerViewOnClickListener listener) {
            super(itemView);

            context = itemView.getContext();
            onClickListener = listener;

            variantsRecyclerView = itemView.findViewById(R.id.options_recycler_view);
            sttRequestTextView = itemView.findViewById(R.id.stt_request_text_view);
        }

        @Override
        public void bind(@NonNull ConversationModel model) {
            if (model.getAnswersList() != null && model.getAnswersList().size() > 0) {
                sttRequestTextView.setText(model.getRequestText());

                answerContentsArrayList = new ArrayList<>(model.getAnswersList());
                VariantsAdapter variantsRecyclerViewAdapter = new VariantsAdapter((view, position) ->
                        onClickListener.onClickListener(view, answerContentsArrayList.get(position))
                );
                variantsRecyclerViewAdapter.submitList(answerContentsArrayList);
                variantsRecyclerView.setLayoutManager(new LinearLayoutManager(context));
                variantsRecyclerView.setAdapter(variantsRecyclerViewAdapter);
            }
        }
    }

    public static class AnswerRequestFailedViewHolder extends ConversationViewHolder {

        public AnswerRequestFailedViewHolder(@NonNull View itemView) {
            super(itemView);
        }

        @Override
        public void bind(@NonNull ConversationModel model) {}
    }
}