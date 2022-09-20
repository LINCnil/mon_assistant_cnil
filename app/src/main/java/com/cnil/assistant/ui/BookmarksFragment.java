package com.cnil.assistant.ui;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProviders;
import androidx.navigation.Navigation;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.cnil.assistant.R;
import com.cnil.assistant.utils.Constants;
import com.cnil.assistant.utils.FileManager;
import com.cnil.assistant.utils.Utils;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;


public class BookmarksFragment extends BaseFragment {

    private TextView noBookmarksHeaderTextView;
    private TextView noBookmarksTextView;
    private RecyclerView bookmarksRecyclerView;
    private BookmarksRecyclerViewAdapter bookmarksRecyclerViewAdapter;

    private ArrayList<String> bookmarksArrayList;
    private BookmarksViewModel bookmarksViewModel;
    private String datasetLocation;


    @Override
    public View onCreateView(@NotNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View createdView = inflater.inflate(R.layout.bookmarks_fragment, container, false);

        bookmarksViewModel = ViewModelProviders.of(this).get(BookmarksViewModel.class);

        noBookmarksHeaderTextView = createdView.findViewById(R.id.bookmarks_no_bookmarks_header_text_view);
        noBookmarksTextView = createdView.findViewById(R.id.bookmarks_no_bookmarks_text_view);
        bookmarksRecyclerView = createdView.findViewById(R.id.bookmarks_recycler_view);

        bookmarksRecyclerViewAdapter = new BookmarksRecyclerViewAdapter((view, position) -> {
            BookmarksFragmentDirections.ActionBookmarksToArticle action =
                    BookmarksFragmentDirections.actionBookmarksToArticle();
            action.setRequestText(bookmarksRecyclerViewAdapter.getCurrentList().get(position).getRequest());
            action.setResponseText(bookmarksRecyclerViewAdapter.getCurrentList().get(position).getResponse());
            action.setAnswerId(bookmarksRecyclerViewAdapter.getCurrentList().get(position).getId());
            action.setAreSimilarTopicsAvailable(false);
            Navigation.findNavController(view).navigate(action);
        });

        createdView.findViewById(R.id.back_image_view).
                setOnClickListener(v -> Navigation.findNavController(v).popBackStack());

        createdView.findViewById(R.id.bookmarks_delete_image_view).
                setOnClickListener(v -> deleteAllBookmarks());

        return createdView;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        datasetLocation = BookmarksFragmentArgs.fromBundle(getArguments()).getDatasetLocation();
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        bookmarksViewModel.getAnswerContentArrayListLiveData().observe(getViewLifecycleOwner(),
                list -> parentActivity.runOnUiThread(() -> {
                    bookmarksRecyclerViewAdapter.submitList(list);
                    bookmarksRecyclerView.setLayoutManager(new LinearLayoutManager(parentActivity));
                    bookmarksRecyclerView.setAdapter(bookmarksRecyclerViewAdapter);

                    setUI();
                }));

        MainActivity.getExecutorService().execute(() -> {
            bookmarksArrayList = Utils.readBookmarksList(requireContext());

            if (bookmarksArrayList.size() > 0) {
                bookmarksViewModel.getAnswerForId(requireContext(), bookmarksArrayList, datasetLocation);
            }

            parentActivity.runOnUiThread(this::setUI);
        });
    }

    private void setUI() {
        if (bookmarksArrayList.size() > 0) {
            bookmarksRecyclerView.setVisibility(View.VISIBLE);
            noBookmarksHeaderTextView.setVisibility(View.GONE);
            noBookmarksTextView.setVisibility(View.GONE);
        } else {
            bookmarksRecyclerView.setVisibility(View.GONE);
            noBookmarksHeaderTextView.setVisibility(View.VISIBLE);
            noBookmarksTextView.setVisibility(View.VISIBLE);
        }
    }

    private void deleteAllBookmarks() {
        if (bookmarksArrayList != null && bookmarksViewModel != null) {
            bookmarksArrayList.clear();
            bookmarksViewModel.clearList();

            MainActivity.getExecutorService().execute(() -> FileManager.writeBookmarksListToFile(
                    requireContext().getExternalFilesDir(null).toString().concat("/").concat(Constants.BOOKMARKS_FILE_NAME),
                    bookmarksArrayList));
        }
    }
}
