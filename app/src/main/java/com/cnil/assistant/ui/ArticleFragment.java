package com.cnil.assistant.ui;

import android.os.Build;
import android.os.Bundle;
import android.text.Html;
import android.text.method.LinkMovementMethod;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.navigation.Navigation;

import com.cnil.assistant.CnilApplication;
import com.cnil.assistant.R;
import com.cnil.assistant.core.tts.TextToSpeech;
import com.cnil.assistant.core.tts.TextToSpeechOggEngine;
import com.cnil.assistant.utils.Constants;
import com.cnil.assistant.utils.FileManager;
import com.cnil.assistant.utils.Utils;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;


public class ArticleFragment extends BaseFragment {

    private TextView requestTextView;
    private TextView responseTextView;
    private ImageButton bookmarksImageButton;
    private TextView similarTopicsTextView;
    private ImageButton playPauseImageButton;

    private ArrayList<String> bookmarksArrayList;
    private String answerId;

    private TextToSpeech textToSpeechEngine;


    @Override
    public View onCreateView(@NotNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View createdView = inflater.inflate(R.layout.article_full_view_fragment, container, false);

        requestTextView = createdView.findViewById(R.id.article_request_text_view);
        responseTextView = createdView.findViewById(R.id.article_response_text_view);
        bookmarksImageButton = createdView.findViewById(R.id.article_bookmarks_button);
        similarTopicsTextView = createdView.findViewById(R.id.article_similar_topics_text_view);
        playPauseImageButton = createdView.findViewById(R.id.play_pause_button);

        createdView.findViewById(R.id.back_image_view).
                setOnClickListener(v -> Navigation.findNavController(v).popBackStack());
        createdView.findViewById(R.id.article_bookmarks_button).
                setOnClickListener(v ->  handleSaveToBookmarksClick());

        playPauseImageButton.setOnClickListener(v -> handleAudioPlaying());

        return createdView;
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        String requestText = ArticleFragmentArgs.fromBundle(getArguments()).getRequestText();
        String responseText = ArticleFragmentArgs.fromBundle(getArguments()).getResponseText();
        answerId = ArticleFragmentArgs.fromBundle(getArguments()).getAnswerId();
        boolean areSimilarTopicsAvailable = ArticleFragmentArgs.fromBundle(getArguments()).getAreSimilarTopicsAvailable();

        requestTextView.setText(requestText);
        responseTextView.setText(responseText);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            responseTextView.setText(Html.fromHtml(responseText, Html.FROM_HTML_MODE_COMPACT));
        } else {
            responseTextView.setText(Html.fromHtml(responseText));
        }
        responseTextView.setClickable(true);
        responseTextView.setMovementMethod(LinkMovementMethod.getInstance());
        similarTopicsTextView.setVisibility(areSimilarTopicsAvailable ? View.VISIBLE : View.GONE);

        MainActivity.getExecutorService().execute(() -> {
            bookmarksArrayList = Utils.readBookmarksList(requireContext());
            parentActivity.runOnUiThread(() ->
                bookmarksImageButton.setImageResource(bookmarksArrayList.contains(answerId) ?
                        R.drawable.ic_bookmarks_on : R.drawable.ic_bookmarks)
            );
        });

        startAutoPlayAnswerTts(answerId);
    }

    @Override
    public void onPause() {
        textToSpeechEngine.stopSpeech();
        playPauseImageButton.setImageResource(textToSpeechEngine.getIsAudioPlaying() ?
                R.drawable.ic_audio_play_stop : R.drawable.ic_audio_play_start);

        super.onPause();
    }

    private void handleSaveToBookmarksClick() {
        if (bookmarksArrayList.contains(answerId)) {
            bookmarksArrayList.remove(answerId);
        } else {
            bookmarksArrayList.add(answerId);
        }

        bookmarksImageButton.setImageResource(bookmarksArrayList.contains(answerId) ?
                R.drawable.ic_bookmarks_on : R.drawable.ic_bookmarks);

        MainActivity.getExecutorService().execute(() -> FileManager.writeBookmarksListToFile(
                requireContext().getExternalFilesDir(null).toString().concat("/").concat(Constants.BOOKMARKS_FILE_NAME),
                bookmarksArrayList));
    }

    public void handleAudioPlaying() {
        if (textToSpeechEngine.getIsAudioConfigured()) {
            textToSpeechEngine.playPauseSpeech();
        } else {
            textToSpeechEngine.startSpeech(answerId, requireContext(), (v) ->
                    playPauseImageButton.setImageResource(R.drawable.ic_audio_play_start));
        }
        playPauseImageButton.setImageResource(textToSpeechEngine.getIsAudioPlaying() ?
                R.drawable.ic_audio_play_stop : R.drawable.ic_audio_play_start);
    }

    private void startAutoPlayAnswerTts(String answerId) {
        textToSpeechEngine = TextToSpeechOggEngine.getTtsInstance(MainActivity.getExecutorService());
        boolean isTtsAutoSpeechStartOn = CnilApplication.readBooleanPreference(requireContext(),
                Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_AUTO_START, true);
        if (isTtsAutoSpeechStartOn) {
            textToSpeechEngine.startSpeech(answerId, requireContext(), (v) ->
                    playPauseImageButton.setImageResource(R.drawable.ic_audio_play_start));
            playPauseImageButton.setImageResource(R.drawable.ic_audio_play_stop);
        }
    }
}
