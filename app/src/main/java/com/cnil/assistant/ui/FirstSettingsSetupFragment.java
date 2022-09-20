package com.cnil.assistant.ui;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

import androidx.navigation.Navigation;
import androidx.viewpager.widget.ViewPager;

import com.cnil.assistant.R;
import com.cnil.assistant.ui.adapters.FirstSettingsSetupViewPagerAdapter;
import com.google.android.material.tabs.TabLayout;

import org.jetbrains.annotations.NotNull;


public class FirstSettingsSetupFragment extends BaseFragment {
    private Button skipButton;
    private Button nextButton;
    private Button backButton;
    private Button doneButton;

    @Override
    public View onCreateView(@NotNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View createdView = inflater.inflate(R.layout.first_settings_setup_fragment, container, false);

        skipButton = createdView.findViewById(R.id.first_settings_setup_skip_button);
        nextButton = createdView.findViewById(R.id.first_settings_setup_next_button);
        backButton = createdView.findViewById(R.id.first_settings_setup_back_button);
        doneButton = createdView.findViewById(R.id.first_settings_setup_done_button);

        FirstSettingsSetupViewPagerAdapter firstSettingsSetupPagerAdapter =
                new FirstSettingsSetupViewPagerAdapter(getChildFragmentManager());
        ViewPager viewPager = createdView.findViewById(R.id.first_settings_setup_view_pager);
        viewPager.setAdapter(firstSettingsSetupPagerAdapter);
        viewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageSelected(int position) {
                skipButton.setVisibility(position == 1 ? View.GONE : View.VISIBLE);
                nextButton.setVisibility(position == 1 ? View.GONE : View.VISIBLE);
                backButton.setVisibility(position == 1 ? View.VISIBLE : View.GONE);
                doneButton.setVisibility(position == 1 ? View.VISIBLE : View.GONE);
            }

            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {}

            @Override
            public void onPageScrollStateChanged(int state) {}
        });

        TabLayout tabLayout = createdView.findViewById(R.id.first_settings_setup_tab_layout);
        tabLayout.setupWithViewPager(viewPager);

        skipButton.setOnClickListener(v ->
                Navigation.findNavController(v).navigate(R.id.action_first_settings_setup_to_conversation)
        );
        nextButton.setOnClickListener(v ->
                viewPager.setCurrentItem(1)
        );
        backButton.setOnClickListener(v ->
                viewPager.setCurrentItem(0)
        );
        doneButton.setOnClickListener(v ->
                Navigation.findNavController(v).navigate(R.id.action_first_settings_setup_to_conversation)
        );

        return createdView;
    }
}
