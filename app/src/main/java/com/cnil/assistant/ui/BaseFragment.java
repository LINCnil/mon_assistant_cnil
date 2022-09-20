package com.cnil.assistant.ui;

import android.os.Bundle;

import androidx.fragment.app.Fragment;


public abstract class BaseFragment extends Fragment {
    protected MainActivity parentActivity;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        parentActivity = (MainActivity) requireActivity();
    }
}
