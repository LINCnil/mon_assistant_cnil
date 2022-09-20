package com.cnil.assistant.ui;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.SwitchCompat;
import androidx.fragment.app.Fragment;

import com.cnil.assistant.CnilApplication;
import com.cnil.assistant.R;
import com.cnil.assistant.utils.Constants;


public class FirstSettingsSetupAutoPlayFragment extends Fragment {
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View createdView = inflater.inflate(R.layout.first_settings_setup_view_pager_auto_play_fragment, container, false);

        SwitchCompat autoPlayAutoSpeechSwitch = createdView.findViewById(R.id.first_settings_setup_auto_play_auto_speech_switch);
        SwitchCompat autoPlayFullArticleSwitch = createdView.findViewById(R.id.first_settings_setup_auto_play_full_article_switch);

        boolean isTtsAutoSpeechStartOn = CnilApplication.readBooleanPreference(requireContext(),
                Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_AUTO_START, true);
        boolean isTtsFullArticleOn = CnilApplication.readBooleanPreference(requireContext(),
                Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_FULL_ARTICLE, true);
        autoPlayAutoSpeechSwitch.setChecked(isTtsAutoSpeechStartOn);
        autoPlayFullArticleSwitch.setChecked(isTtsFullArticleOn);

        autoPlayAutoSpeechSwitch.setOnCheckedChangeListener((buttonView, isChecked) ->
                CnilApplication.writeBooleanPreference(requireContext(),
                Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_AUTO_START, isChecked));
        autoPlayFullArticleSwitch.setOnCheckedChangeListener((buttonView, isChecked) ->
                CnilApplication.writeBooleanPreference(requireContext(),
                Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_FULL_ARTICLE, isChecked));

        return createdView;
    }
}
