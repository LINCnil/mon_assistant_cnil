package com.cnil.assistant.ui;

import android.app.AlertDialog;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.Nullable;
import androidx.navigation.Navigation;

import com.cnil.assistant.BuildConfig;
import com.cnil.assistant.CnilApplication;
import com.cnil.assistant.R;
import com.cnil.assistant.utils.Constants;

import org.jetbrains.annotations.NotNull;


public class SettingsFragment extends BaseFragment {
    private AlertDialog recordingOptionDialog;
    private TextView recordingOptionTextView;

    @Override
    public View onCreateView(@NotNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View createdView = inflater.inflate(R.layout.settings_fragment, container, false);
        recordingOptionTextView = createdView.findViewById(R.id.settings_section_recording_option);
        createdView.findViewById(R.id.settings_section_assistants_voice_linear_layout).
                setOnClickListener((View v) ->
                        Navigation.findNavController(v).navigate(R.id.action_settings_to_assistants_speech)
                );
        createdView.findViewById(R.id.settings_section_recording_linear_layout).
                setOnClickListener((View v) -> showRecordingRadioButtonDialog());
        if (BuildConfig.DEV) {
            createdView.findViewById(R.id.settings_section_logs_linear_layout).setVisibility(View.VISIBLE);
            createdView.findViewById(R.id.settings_section_logs_linear_layout).
                    setOnClickListener((View v) ->
                            Navigation.findNavController(v).navigate(R.id.action_settings_to_debug_info)
                    );
        }
        createdView.findViewById(R.id.settings_section_about_relative_layout).
                setOnClickListener((View v) ->
                    Navigation.findNavController(v).navigate(R.id.action_settings_to_settings_about_info)
                );
        createdView.findViewById(R.id.back_image_view).
                setOnClickListener(v ->
                    Navigation.findNavController(v).popBackStack(R.id.conversation_fragment, false)
                );

        return createdView;
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        String selectedRecordingOption = CnilApplication.readStringPreference(requireContext(),
                Constants.SHARED_PREFERENCES_KEY_SETTINGS_RECORDING, Constants.SETTINGS_RECORDING_OFF);
        recordingOptionTextView.setText(selectedRecordingOption.equals(Constants.SETTINGS_RECORDING_OFF) ?
                getString(R.string.settings_section_recording_off) :
                getString(R.string.settings_section_recording_on));
    }

    private void showRecordingRadioButtonDialog() {
        CharSequence[] recordingOptionsList = {
                getString(R.string.settings_section_recording_off),
                getString(R.string.settings_section_recording_on)};
        int selectedItem = CnilApplication.readStringPreference(requireContext(),
                Constants.SHARED_PREFERENCES_KEY_SETTINGS_RECORDING,
                Constants.SETTINGS_RECORDING_OFF).equals(Constants.SETTINGS_RECORDING_OFF) ? 0 : 1;

        AlertDialog.Builder builder = new AlertDialog.Builder(parentActivity);
        builder.setTitle(R.string.settings_section_recording);
        builder.setSingleChoiceItems(recordingOptionsList, selectedItem,
                (dialog, item) -> {
                    recordingOptionTextView.setText(recordingOptionsList[item]);
                    String selectedOption = recordingOptionsList[item].equals(
                            getString(R.string.settings_section_recording_off)) ?
                            Constants.SETTINGS_RECORDING_OFF : Constants.SETTINGS_RECORDING_ON;
                    CnilApplication.writeStringPreference(requireContext(),
                            Constants.SHARED_PREFERENCES_KEY_SETTINGS_RECORDING, selectedOption);
                    recordingOptionDialog.dismiss();
                });
        recordingOptionDialog = builder.create();
        recordingOptionDialog.show();
    }
}
