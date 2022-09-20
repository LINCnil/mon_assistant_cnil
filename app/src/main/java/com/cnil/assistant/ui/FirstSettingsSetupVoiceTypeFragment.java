package com.cnil.assistant.ui;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RadioButton;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;

import com.cnil.assistant.CnilApplication;
import com.cnil.assistant.R;
import com.cnil.assistant.utils.Constants;


public class FirstSettingsSetupVoiceTypeFragment extends Fragment {
    private RadioButton ttsMaleVoiceRadioButton;
    private TextView ttsMaleTextView;
    private RadioButton ttsFemaleVoiceRadioButton;
    private TextView ttsFemaleTextView;


    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             ViewGroup container, Bundle savedInstanceState) {
        View createdView = inflater.inflate(R.layout.first_settings_setup_view_pager_voice_type_fragment, container, false);

        ttsMaleVoiceRadioButton = createdView.findViewById(R.id.first_settings_setup_voice_male_radio_button);
        ttsMaleTextView = createdView.findViewById(R.id.first_settings_setup_voice_male_text_view);
        ttsFemaleVoiceRadioButton = createdView.findViewById(R.id.first_settings_setup_voice_female_radio_button);
        ttsFemaleTextView = createdView.findViewById(R.id.first_settings_setup_voice_female_text_view);

        boolean is_tts_female_voice = CnilApplication.readBooleanPreference(
                requireContext(), Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_FEMALE_VOICE, true);
        ttsFemaleVoiceRadioButton.setChecked(is_tts_female_voice);
        ttsFemaleTextView.setTextColor(ContextCompat.getColorStateList(requireContext(), R.color.primary_blue));

        ttsMaleVoiceRadioButton.setOnCheckedChangeListener(this::ttsMaleVoiceRadioButtonStateChange);
        ttsFemaleVoiceRadioButton.setOnCheckedChangeListener(this::ttsFemaleVoiceRadioButtonStateChange);

        return createdView;
    }

    private void ttsMaleVoiceRadioButtonStateChange(View buttonView, boolean isChecked) {
        ttsMaleVoiceRadioButton.setOnCheckedChangeListener(null);
        ttsFemaleVoiceRadioButton.setOnCheckedChangeListener(null);

        ttsMaleVoiceRadioButton.setChecked(true);
        ttsFemaleVoiceRadioButton.setChecked(false);
        ttsMaleTextView.setTextColor(ContextCompat.getColorStateList(requireContext(), R.color.primary_blue));
        ttsFemaleTextView.setTextColor(ContextCompat.getColorStateList(requireContext(), R.color.secondary_text));

        CnilApplication.writeBooleanPreference(requireContext(),
                Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_FEMALE_VOICE, false);

        ttsMaleVoiceRadioButton.setOnCheckedChangeListener(this::ttsMaleVoiceRadioButtonStateChange);
        ttsFemaleVoiceRadioButton.setOnCheckedChangeListener(this::ttsFemaleVoiceRadioButtonStateChange);
    }

    private void ttsFemaleVoiceRadioButtonStateChange(View buttonView, boolean isChecked) {
        ttsMaleVoiceRadioButton.setOnCheckedChangeListener(null);
        ttsFemaleVoiceRadioButton.setOnCheckedChangeListener(null);

        ttsMaleVoiceRadioButton.setChecked(false);
        ttsFemaleVoiceRadioButton.setChecked(true);
        ttsMaleTextView.setTextColor(ContextCompat.getColorStateList(requireContext(), R.color.secondary_text));
        ttsFemaleTextView.setTextColor(ContextCompat.getColorStateList(requireContext(), R.color.primary_blue));

        CnilApplication.writeBooleanPreference(requireContext(),
                Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_FEMALE_VOICE, true);

        ttsMaleVoiceRadioButton.setOnCheckedChangeListener(this::ttsMaleVoiceRadioButtonStateChange);
        ttsFemaleVoiceRadioButton.setOnCheckedChangeListener(this::ttsFemaleVoiceRadioButtonStateChange);
    }
}
