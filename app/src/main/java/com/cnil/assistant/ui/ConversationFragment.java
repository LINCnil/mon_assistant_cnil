package com.cnil.assistant.ui;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.Context;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Pair;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.Toast;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.annotation.NonNull;

import androidx.appcompat.app.AlertDialog;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProviders;
import androidx.navigation.Navigation;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.cnil.assistant.CnilApplication;
import com.cnil.assistant.R;
import com.cnil.assistant.core.TaskCallback;
import com.cnil.assistant.models.AnswerContent;
import com.cnil.assistant.models.DebugInfoModel;
import com.cnil.assistant.models.ServerMetadataJsonResponse;
import com.cnil.assistant.models.VoiceAssistantError;
import com.cnil.assistant.ui.adapters.ConversationAdapter;
import com.cnil.assistant.ui.view.CustomEditText;
import com.cnil.assistant.utils.Constants;
import com.cnil.assistant.utils.DebugLogInfoManager;
import com.cnil.assistant.utils.LogManager;
import com.cnil.assistant.utils.UpdateArchiveManager;
import com.cnil.assistant.utils.Utils;

import java.util.ArrayList;
import java.util.Objects;


public class ConversationFragment extends BaseFragment {
    private static final int PERMISSIONS_REQUEST_CODE = 100;
    private static final String[] PERMISSIONS = {
            android.Manifest.permission.RECORD_AUDIO
    };

    private static final int RECYCLER_VIEW_LAST_ITEM_BOTTOM_PADDING = 32;

    private ImageButton recordImageButton;
    private RecyclerView recyclerView;
    private ConstraintLayout answerProgressContainer;
    private TextView answerProgressTitleTextView;
    private LinearLayout startViewContainer;
    private ImageButton sendTextImageButton;
    private CustomEditText utteranceEditText;
    private RelativeLayout bottomBarTextRelativeLayout;
    private RelativeLayout bottomBarMicRelativeLayout;
    private Button startViewWhatIsCNILButtonsButton;
    private Button startViewBookmarksButton;
    private Button startViewNewsButton;

    private ConversationAdapter answerSuggestionsAdapter;
    private ConversationViewModel conversationViewModel;

    private boolean isSofKeyboardShown = false;

    private UpdateArchiveManager updateManager;

    private AlertDialog updateErrorAlertDialog = null;
    private AlertDialog updateProgressAlertDialog = null;
    private AlertDialog suggestUpdateAlertDialog = null;


    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View createdView = inflater.inflate(R.layout.conversation_fragment, container, false);

        recyclerView = createdView.findViewById(R.id.recycler_view);
        startViewWhatIsCNILButtonsButton = createdView.findViewById(R.id.start_view_what_is_cnil_button);
        startViewBookmarksButton = createdView.findViewById(R.id.start_view_bookmarks_button);
        startViewNewsButton = createdView.findViewById(R.id.start_view_news_button);
        answerProgressContainer = createdView.findViewById(R.id.progress_details_bottom_bar_container);
        answerProgressTitleTextView = createdView.findViewById(R.id.progress_details_bottom_bar_text);
        startViewContainer = createdView.findViewById(R.id.cnil_start_view_container);
        recordImageButton = createdView.findViewById(R.id.record_button);
        ImageButton keyboardButton = createdView.findViewById(R.id.keyboard_button);
        sendTextImageButton = createdView.findViewById(R.id.send_text_image_button);
        utteranceEditText = createdView.findViewById(R.id.utterance_edit_text);
        ImageButton settingsImageButton = createdView.findViewById(R.id.settings_button);
        bottomBarTextRelativeLayout = createdView.findViewById(R.id.bottom_bar_text_relative_layout);
        bottomBarMicRelativeLayout = createdView.findViewById(R.id.bottom_bar_mic_relative_layout);

        conversationViewModel = ViewModelProviders.of(this).get(ConversationViewModel.class);

        answerSuggestionsAdapter = new ConversationAdapter((view, answerContent) ->
                openFullArticleView(view, answerContent, true));

        recyclerView.addItemDecoration(new MemberItemDecoration());

        utteranceEditText.setOnKeyBoardHideEventListener(this::onKeyboardButtonClick);
        utteranceEditText.addTextChangedListener(new TextWatcher() {
            public void afterTextChanged(Editable s) {}
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                sendTextImageButton.setVisibility(s.length() == 0 ? View.INVISIBLE : View.VISIBLE);
            }
        });
        keyboardButton.setOnClickListener(this::onKeyboardButtonClick);
        recordImageButton.setOnClickListener(v -> conversationViewModel.handleRecording());
        sendTextImageButton.setOnClickListener(v -> {
            hideKeyboard(v);
            handleText(Objects.requireNonNull(utteranceEditText.getText()).toString());
            utteranceEditText.setText("");
            bottomBarTextRelativeLayout.setVisibility(View.GONE);
            bottomBarMicRelativeLayout.setVisibility(View.VISIBLE);
        });
        settingsImageButton.setOnClickListener(v ->
            Navigation.findNavController(v).navigate(R.id.action_conversation_to_settings)
        );
        startViewWhatIsCNILButtonsButton.setOnClickListener(v ->
                conversationViewModel.getAnswerForId(requireContext().getString(R.string.quick_button_learn_more_about_cnil), "533",
                        (error, requestText, answerContentList) -> openFullArticleView(v, answerContentList.get(0), false)));
        startViewBookmarksButton.setOnClickListener(this::openBookmarksFragment);
        startViewNewsButton.setOnClickListener(v -> openNewsWebPage());
        createdView.findViewById(R.id.bookmarks_button).setOnClickListener(this::openBookmarksFragment);

        updateManager = new UpdateArchiveManager(MainActivity.getExecutorService());

        return createdView;
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        conversationViewModel.getConversationModelArrayListLiveData().observe(getViewLifecycleOwner(),
                list -> parentActivity.runOnUiThread(() -> {
                    answerSuggestionsAdapter.submitList(list);
                    recyclerView.setLayoutManager(new LinearLayoutManager(parentActivity));
                    recyclerView.setAdapter(answerSuggestionsAdapter);
                    recyclerView.scrollToPosition(list.size() - 1);
        }));
        conversationViewModel.getConversationStateLiveData().observe(getViewLifecycleOwner(),
                conversationState -> parentActivity.runOnUiThread(() -> {
                    updateUI(conversationState);
                    if (conversationState.equals(ConversationViewModel.ConversationStateEnum.INIT_FINISHED)) {
                        checkIfUpdateIsNeeded();
                    }
        }));

        startInit();
    }

    private void onKeyboardButtonClick(View v) {
        if (isSofKeyboardShown) {
            bottomBarTextRelativeLayout.setVisibility(View.GONE);
            bottomBarMicRelativeLayout.setVisibility(View.VISIBLE);
            hideKeyboard(v);
        } else {
            bottomBarTextRelativeLayout.setVisibility(View.VISIBLE);
            bottomBarMicRelativeLayout.setVisibility(View.GONE);
            showKeyboard();
        }
    }

    private void showKeyboard() {
        isSofKeyboardShown = true;
        InputMethodManager imm = (InputMethodManager) requireActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0);

        utteranceEditText.requestFocus();
    }

    private void hideKeyboard(@NonNull View view) {
        isSofKeyboardShown = false;
        InputMethodManager imm = (InputMethodManager) requireActivity().getSystemService(Activity.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
    }

    private void startInit() {
        if (hasPermissions()) {
            conversationViewModel.init(parentActivity);
        } else {
            requestPermissions(PERMISSIONS, PERMISSIONS_REQUEST_CODE);
        }
    }

    private void handleText(String text) {
        conversationViewModel.handleText(text);
    }

    private void openBookmarksFragment(View v) {
        ConversationFragmentDirections.ActionConversationToBookmarks action =
                ConversationFragmentDirections.actionConversationToBookmarks();
        action.setDatasetLocation(conversationViewModel.getFilesLocations().getFileDatasetFolderLocation());
        Navigation.findNavController(v).navigate(action);
    }

    private void openFullArticleView(View view, @NonNull AnswerContent answerContent, boolean areSimilarTopicsAvailable) {
        ConversationFragmentDirections.ActionConversationToArticle action =
                ConversationFragmentDirections.actionConversationToArticle();
        action.setRequestText(answerContent.getRequest());
        action.setResponseText(answerContent.getResponse());
        action.setAnswerId(answerContent.getId());
        action.setAreSimilarTopicsAvailable(areSimilarTopicsAvailable);
        Navigation.findNavController(view).navigate(action);
    }

    private void openNewsWebPage() {
        Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(Constants.CNIL_NEWS_WEB_PAGE_URL));
        startActivity(browserIntent);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == PERMISSIONS_REQUEST_CODE) {
            if (grantResults.length > 0 && hasPermissions()) {
                // Permission is granted
                conversationViewModel.init(parentActivity);
            } else {
                Toast.makeText(getContext(), R.string.denied_record_audio_permission, Toast.LENGTH_SHORT).show();
                startInit();
            }
        }
    }

    public static class MemberItemDecoration extends RecyclerView.ItemDecoration {
        @Override
        public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
            if (parent.getChildAdapterPosition(view) == Objects.requireNonNull(parent.getAdapter()).getItemCount() - 1) {
                outRect.bottom = RECYCLER_VIEW_LAST_ITEM_BOTTOM_PADDING;
            }
        }
    }

    private void updateUI(@NonNull ConversationViewModel.ConversationStateEnum conversationState) {
        switch (conversationState) {
            case INIT:
                startViewWhatIsCNILButtonsButton.setClickable(false);
                startViewBookmarksButton.setClickable(false);
                startViewNewsButton.setClickable(false);
                startViewContainer.setVisibility(View.VISIBLE);
                answerProgressContainer.setVisibility(View.VISIBLE);
                answerProgressTitleTextView.setText(R.string.answer_progress_initializing);
                recordImageButton.setImageDrawable(ContextCompat.getDrawable(requireContext(), R.drawable.ic_mic));
                recordImageButton.setImageTintList(null);
                recordImageButton.setBackground(ContextCompat.getDrawable(requireContext(), R.drawable.ic_record_button));
                recordImageButton.setEnabled(true);
                break;
            case INIT_FINISHED:
                startViewWhatIsCNILButtonsButton.setClickable(true);
                startViewBookmarksButton.setClickable(true);
                startViewNewsButton.setClickable(true);
                startViewContainer.setVisibility(View.VISIBLE);
                answerProgressContainer.setVisibility(View.GONE);
                recordImageButton.setImageDrawable(ContextCompat.getDrawable(requireContext(), R.drawable.ic_mic));
                recordImageButton.setImageTintList(null);
                recordImageButton.setBackground(ContextCompat.getDrawable(requireContext(), R.drawable.ic_record_button));
                recordImageButton.setEnabled(true);
                break;
            case IDLE:
                startViewWhatIsCNILButtonsButton.setClickable(true);
                startViewBookmarksButton.setClickable(true);
                startViewNewsButton.setClickable(true);
                startViewContainer.setVisibility(View.GONE);
                answerProgressContainer.setVisibility(View.GONE);
                recordImageButton.setImageDrawable(ContextCompat.getDrawable(requireContext(), R.drawable.ic_mic));
                recordImageButton.setImageTintList(null);
                recordImageButton.setBackground(ContextCompat.getDrawable(requireContext(), R.drawable.ic_record_button));
                recordImageButton.setEnabled(true);
                break;
            case LISTENING:
                startViewContainer.setVisibility(View.GONE);
                answerProgressContainer.setVisibility(View.VISIBLE);
                answerProgressTitleTextView.setText(R.string.answer_progress_listening);
                recordImageButton.setImageDrawable(ContextCompat.getDrawable(requireContext(), R.drawable.ic_mic));
                recordImageButton.setImageTintList(ContextCompat.getColorStateList(requireContext(), android.R.color.white));
                recordImageButton.setBackground(ContextCompat.getDrawable(requireContext(), R.drawable.ic_record_button_circle));
                recordImageButton.setEnabled(true);
                break;
            case PROCESSING:
                startViewContainer.setVisibility(View.GONE);
                answerProgressContainer.setVisibility(View.VISIBLE);
                answerProgressTitleTextView.setText(R.string.answer_progress_processing);
                recordImageButton.setImageDrawable(ContextCompat.getDrawable(requireContext(), R.drawable.ic_mic));
                recordImageButton.setImageTintList(ContextCompat.getColorStateList(requireContext(), android.R.color.white));
                recordImageButton.setBackground(ContextCompat.getDrawable(requireContext(), R.drawable.ic_record_button_circle));
                recordImageButton.setEnabled(false);
                break;
        }
    }

    private boolean hasPermissions() {
        for (String permission : PERMISSIONS) {
            if (ContextCompat.checkSelfPermission(requireActivity(), permission) != PackageManager.PERMISSION_GRANTED) {
                return false;
            }
        }
        return true;
    }

    public void checkIfUpdateIsNeeded() {
        updateManager.checkUpdateNecessity(parentActivity, (checkUpdateError, serverMetadataJsonResponse) ->
                parentActivity.runOnUiThread(() -> {
                    if ((checkUpdateError != null) &&
                            checkUpdateError.getErrorType().equals(VoiceAssistantError.ErrorType.NO_ERROR)) {
                        String availableVersion = serverMetadataJsonResponse.getVersionName();
                        if (Utils.isVersionAlreadyInstalled(parentActivity, availableVersion)) {
                            DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.COMMON,
                                    String.format("UpdateManager: files are up to date, version = %1$s", availableVersion));
                        } else if (Utils.isNewFilesVersionSupported(availableVersion)) {
                            DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.COMMON,
                                    String.format("UpdateManager: current version = %1$s, available version = %2$s",
                                            CnilApplication.readStringPreference(
                                                    parentActivity, Constants.SHARED_PREFERENCES_KEY_CURRENT_INSTALLED_VERSION, ""),
                                            availableVersion));
                            showSuggestUpdateDialog(parentActivity, serverMetadataJsonResponse);
                        } else {
                            DebugLogInfoManager.addDebugInfo(DebugInfoModel.ComponentTag.COMMON,
                                    String.format("UpdateManager: new version is not supported by the app. current version = %1$s, available version = %2$s",
                                            CnilApplication.readStringPreference(
                                                    parentActivity, Constants.SHARED_PREFERENCES_KEY_CURRENT_INSTALLED_VERSION, ""),
                                            availableVersion));
                        }
                    }
                })
        );
    }

    private void downloadModelsArchive(@NonNull ServerMetadataJsonResponse metadata, TaskCallback updateCallback) {
        String availableVersion = metadata.getVersionName();
        ArrayList<Pair<String, String>> fileInfoArrayList = metadata.getFilesInfoArrayList();
        String archiveUrl = Constants.SERVER_DOWNLOAD_ARCHIVE_API + "/" + availableVersion + "/" + fileInfoArrayList.get(0).first;

        updateManager.downloadArchive(parentActivity,
                archiveUrl,
                fileInfoArrayList.get(0).second,
                Constants.MODEL_ZIP_FOLDER_NAME,
                availableVersion,
                0,
                (updateError) -> parentActivity.runOnUiThread(() -> {
                    if (updateError != null) {
                        if (updateError.getErrorType().equals(VoiceAssistantError.ErrorType.NO_ERROR)) {
                            conversationViewModel.reloadModels((initError) -> {
                                        if (initError != null) {
                                            if (updateError.getErrorType().equals(VoiceAssistantError.ErrorType.NO_ERROR)) {
                                                downloadAudioArchive(metadata, updateCallback);
                                            } else {
                                                updateCallback.onTaskCompleted(updateError);
                                            }
                                        } else {
                                            updateCallback.onTaskCompleted(new VoiceAssistantError(VoiceAssistantError.ErrorType.ERROR, "downloadArchive init: Error is null"));
                                        }
                                    }
                            );
                        } else {
                            updateCallback.onTaskCompleted(updateError);
                        }
                    } else {
                        updateCallback.onTaskCompleted(new VoiceAssistantError(VoiceAssistantError.ErrorType.ERROR, "downloadArchive: Error is null"));
                    }
                })
        );
    }

    private void downloadAudioArchive(@NonNull ServerMetadataJsonResponse metadata, TaskCallback updateCallback) {
        String availableVersion = metadata.getVersionName();
        ArrayList<Pair<String, String>> fileInfoArrayList = metadata.getFilesInfoArrayList();
        String archiveUrl = Constants.SERVER_DOWNLOAD_ARCHIVE_API + "/" + availableVersion + "/" + fileInfoArrayList.get(1).first;

        updateManager.downloadArchive(parentActivity,
                archiveUrl,
                fileInfoArrayList.get(1).second,
                Constants.AUDIO_ZIP_FOLDER_NAME,
                availableVersion,
                1,
                (updateError) -> parentActivity.runOnUiThread(() -> {
                    if (updateError != null) {
                        if (updateError.getErrorType().equals(VoiceAssistantError.ErrorType.NO_ERROR)) {
                            parentActivity.runOnUiThread(() -> updateCallback.onTaskCompleted(updateError));
                        } else {
                            updateCallback.onTaskCompleted(updateError);
                        }
                    } else {
                        updateCallback.onTaskCompleted(new VoiceAssistantError(VoiceAssistantError.ErrorType.ERROR, "downloadAudioArchive: Error is null"));
                    }
                })
        );
    }

    private void startDownloadArchive(ServerMetadataJsonResponse metadata) {
        showUpdateProgressDialog();
        downloadModelsArchive(metadata, (updateError) -> {
            if (updateError != null) {
                if (updateError.getErrorType().equals(VoiceAssistantError.ErrorType.NO_ERROR)) {
                    dismissUpdateProgressDialog();
                } else {
                    dismissUpdateProgressDialog();
                    showUpdateErrorAlertDialog(metadata);
                }
            } else {
                dismissUpdateProgressDialog();
                showUpdateErrorAlertDialog(metadata);
            }
        });
    }

    private void showSuggestUpdateDialog(Context context, ServerMetadataJsonResponse metadata) {
        if (suggestUpdateAlertDialog == null) {
            AlertDialog.Builder alertDialogBuilder =
                    new AlertDialog.Builder(context)
                            .setTitle(R.string.update_dialog_header)
                            .setMessage(R.string.update_dialog_message)
                            .setPositiveButton(R.string.update_dialog_positive_button, (dialog, which) -> {
                                LogManager.addLog("ConversationViewModel - showSuggestUpdateDialog() Positive button(): User has accepted update");
                                dismissSuggestUpdateDialog();
                                startDownloadArchive(metadata);
                            })
                            .setNegativeButton(R.string.update_dialog_negative_button, (dialog, which) -> {
                                LogManager.addLog("ConversationViewModel - showSuggestUpdateDialog() Negative button(): User has declined update");
                                dismissSuggestUpdateDialog();
                            });
            suggestUpdateAlertDialog = alertDialogBuilder.show();
        }
    }

    private void dismissSuggestUpdateDialog() {
        if (suggestUpdateAlertDialog != null) {
            suggestUpdateAlertDialog.dismiss();
            suggestUpdateAlertDialog = null;
        }
    }

    private void showUpdateProgressDialog() {
        if (updateProgressAlertDialog == null) {
            AlertDialog.Builder updateProgressAlertDialogBuilder = new AlertDialog.Builder(parentActivity)
                    .setTitle(R.string.progress_dialog_header)
                    .setMessage(R.string.progress_dialog_message);
            updateProgressAlertDialog = updateProgressAlertDialogBuilder.show();
        }
    }

    private void dismissUpdateProgressDialog() {
        if (updateProgressAlertDialog != null) {
            updateProgressAlertDialog.dismiss();
            updateProgressAlertDialog = null;
        }
    }

    private void showUpdateErrorAlertDialog(ServerMetadataJsonResponse metadata) {
        if (updateErrorAlertDialog == null) {
            AlertDialog.Builder updateFailureAlertDialogBuilder =
                    new AlertDialog.Builder(parentActivity)
                            .setTitle(R.string.update_failure_dialog_header)
                            .setMessage(R.string.update_failure_dialog_message)
                            .setPositiveButton(R.string.ok_button, (errDialog, errWhich) -> {
                                LogManager.addLog("ConversationViewModel - showUpdateErrorDialog() Positive button(): Error ok");
                                dismissUpdateErrorAlertDialog();
                            })
                            .setNegativeButton(R.string.try_again_button, (errDialog, errWhich) -> {
                                LogManager.addLog("ConversationViewModel - showUpdateErrorDialog() Negative button(): Try again");
                                dismissUpdateErrorAlertDialog();
                                startDownloadArchive(metadata);
                            });
            updateErrorAlertDialog = updateFailureAlertDialogBuilder.show();
        }
    }

    private void dismissUpdateErrorAlertDialog() {
        if (updateErrorAlertDialog != null) {
            updateErrorAlertDialog.dismiss();
            updateErrorAlertDialog = null;
        }
    }
}
