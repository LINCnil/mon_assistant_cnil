package com.cnil.assistant.ui.adapters;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentStatePagerAdapter;

import com.cnil.assistant.ui.FirstSettingsSetupAutoPlayFragment;
import com.cnil.assistant.ui.FirstSettingsSetupVoiceTypeFragment;


public class FirstSettingsSetupViewPagerAdapter extends FragmentStatePagerAdapter {
    public FirstSettingsSetupViewPagerAdapter(FragmentManager fm) {
        super(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT);
    }

    @Override
    public @NonNull Fragment getItem(int position) {
        Fragment fragment;
        switch (position) {
            case 0:
                fragment = new FirstSettingsSetupVoiceTypeFragment();
                break;
            case 1:
                fragment = new FirstSettingsSetupAutoPlayFragment();
                break;
            default:
                throw new UnsupportedOperationException();
        }
        return fragment;
    }

    @Override
    public int getCount() {
        return 2;
    }
}
