package com.cnil.assistant.ui;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.navigation.Navigation;

import com.cnil.assistant.R;
import com.cnil.assistant.utils.Utils;

import org.jetbrains.annotations.NotNull;


public class SettingsAboutFragment extends BaseFragment {
    @Override
    public View onCreateView(@NotNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View createdView = inflater.inflate(R.layout.settings_about_fragment, container, false);

        createdView.findViewById(R.id.back_image_view).setOnClickListener(v ->
                Navigation.findNavController(v).popBackStack(R.id.settings_fragment, false));

        ((TextView)(createdView.findViewById(R.id.settings_section_app_version_text_view))).
                setText(String.format("%1$s (%2$s)",
                        Utils.getApplicationVersion(requireContext()),
                        Utils.getApplicationVersionCode(requireContext())));
        ((TextView)(createdView.findViewById(R.id.settings_section_model_version_text_view))).
                setText(Utils.getModelVersion(requireContext()));

        return createdView;
    }
}
