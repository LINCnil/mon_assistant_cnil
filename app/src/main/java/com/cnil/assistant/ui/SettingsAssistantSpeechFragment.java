package com.cnil.assistant.ui;

import android.app.AlertDialog;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.appcompat.widget.SwitchCompat;
import androidx.navigation.Navigation;

import com.cnil.assistant.CnilApplication;
import com.cnil.assistant.R;
import com.cnil.assistant.utils.Constants;

import org.jetbrains.annotations.NotNull;


public class SettingsAssistantSpeechFragment extends BaseFragment {

    private AlertDialog assistantVoiceOptionDialog;
    private TextView assistantVoiceTextView;

    private AlertDialog speechDurationOptionDialog;
    private TextView speechDurationTextView;


    @Override
    public View onCreateView(@NotNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View createdView = inflater.inflate(R.layout.settings_assistance_speech_fragment, container, false);

        assistantVoiceTextView = createdView.findViewById(R.id.settings_assistant_voice_option_text_view);
        speechDurationTextView = createdView.findViewById(R.id.settings_assistant_voice_auto_start_duration_option_text_view);

        SwitchCompat autoStartSwitch = createdView.findViewById(R.id.settings_assistant_voice_auto_start_switch);

        createdView.findViewById(R.id.back_image_view).setOnClickListener(v ->
                Navigation.findNavController(v).popBackStack(R.id.settings_fragment, false));

        createdView.findViewById(R.id.settings_assistant_voice_linear_layout).setOnClickListener((View v) -> showVoiceOptionDialog());
        createdView.findViewById(R.id.settings_assistant_voice_auto_start_duration_linear_layout).setOnClickListener((View v) -> showDurationOptionDialog());

        boolean isFemaleVoiceSelected = CnilApplication.readBooleanPreference(requireContext(),
                Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_FEMALE_VOICE, true);
        assistantVoiceTextView.setText(isFemaleVoiceSelected ?
                getString(R.string.settings_section_voice_female) :
                getString(R.string.settings_section_voice_male));

        boolean isFullArticleSelected = CnilApplication.readBooleanPreference(requireContext(),
                Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_FULL_ARTICLE, true);
        speechDurationTextView.setText(isFullArticleSelected ?
                getString(R.string.settings_section_assistant_auto_start_speech_full) :
                getString(R.string.settings_section_assistant_auto_start_speech_short));

        boolean isTtsAutoSpeechStartOn = CnilApplication.readBooleanPreference(requireContext(),
                Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_AUTO_START, true);
        autoStartSwitch.setChecked(isTtsAutoSpeechStartOn);
        autoStartSwitch.setOnCheckedChangeListener((buttonView, isChecked) ->
                CnilApplication.writeBooleanPreference(requireContext(),
                        Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_AUTO_START, isChecked));

        return createdView;
    }

    private void showVoiceOptionDialog() {
        CharSequence[] voiceOptionsList = {
                getString(R.string.settings_section_voice_female),
                getString(R.string.settings_section_voice_male)};
        int selectedItem = CnilApplication.readBooleanPreference(requireContext(),
                Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_FEMALE_VOICE, true)
                ? 0 : 1;

        AlertDialog.Builder builder = new AlertDialog.Builder(parentActivity);
        builder.setTitle(R.string.first_launch_settings_assistants_voice);
        builder.setSingleChoiceItems(voiceOptionsList, selectedItem,
                (dialog, item) -> {
                    assistantVoiceTextView.setText(voiceOptionsList[item]);
                    boolean selectedOption = voiceOptionsList[item].equals(
                            getString(R.string.settings_section_voice_female));
                    CnilApplication.writeBooleanPreference(requireContext(),
                            Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_FEMALE_VOICE, selectedOption);

                    if (assistantVoiceOptionDialog != null) {
                        assistantVoiceOptionDialog.dismiss();
                        assistantVoiceOptionDialog = null;
                    }
                });
        assistantVoiceOptionDialog = builder.create();
        assistantVoiceOptionDialog.show();
    }

    private void showDurationOptionDialog() {
        CharSequence[] durationOptionsList = {
                getString(R.string.settings_section_assistant_auto_start_speech_full),
                getString(R.string.settings_section_assistant_auto_start_speech_short)};
        int selectedItem = CnilApplication.readBooleanPreference(requireContext(),
                Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_FULL_ARTICLE, true)
                ? 0 : 1;

        AlertDialog.Builder builder = new AlertDialog.Builder(parentActivity);
        builder.setTitle(R.string.settings_section_assistant_auto_start_speech_duration);
        builder.setSingleChoiceItems(durationOptionsList, selectedItem,
                (dialog, item) -> {
                    speechDurationTextView.setText(durationOptionsList[item]);
                    boolean selectedOption = durationOptionsList[item].equals(
                            getString(R.string.settings_section_assistant_auto_start_speech_full));
                    CnilApplication.writeBooleanPreference(requireContext(),
                            Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_FULL_ARTICLE, selectedOption);

                    if (speechDurationOptionDialog != null) {
                        speechDurationOptionDialog.dismiss();
                        speechDurationOptionDialog = null;
                    }
                });
        speechDurationOptionDialog = builder.create();
        speechDurationOptionDialog.show();
    }
}
