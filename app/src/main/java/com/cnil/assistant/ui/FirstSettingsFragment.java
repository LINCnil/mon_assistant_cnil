package com.cnil.assistant.ui;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.navigation.Navigation;

import com.cnil.assistant.CnilApplication;
import com.cnil.assistant.R;
import com.cnil.assistant.utils.Constants;

import org.jetbrains.annotations.NotNull;


public class FirstSettingsFragment extends BaseFragment {
    @Override
    public View onCreateView(@NotNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View createdView = inflater.inflate(R.layout.first_settings_fragment, container, false);

        CnilApplication.writeBooleanPreference(
                requireContext(), Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_FEMALE_VOICE, true);
        CnilApplication.writeBooleanPreference(
                requireContext(), Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_AUTO_START, true);
        CnilApplication.writeBooleanPreference(
                requireContext(), Constants.SHARED_PREFERENCES_KEY_SETTINGS_IS_TTS_FULL_ARTICLE, true);

        createdView.findViewById(R.id.first_settings_start_button).setOnClickListener(v ->
                Navigation.findNavController(v).navigate(R.id.action_first_settings_to_setup));
        createdView.findViewById(R.id.first_settings_skip_button).setOnClickListener(v ->
                Navigation.findNavController(v).navigate(R.id.action_first_settings_to_conversation));

        return createdView;
    }
}
