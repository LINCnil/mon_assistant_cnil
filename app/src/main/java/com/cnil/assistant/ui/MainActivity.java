package com.cnil.assistant.ui;

import androidx.appcompat.app.AppCompatActivity;
import androidx.navigation.NavGraph;
import androidx.navigation.NavInflater;
import androidx.navigation.fragment.NavHostFragment;

import android.os.Bundle;

import com.cnil.assistant.BuildConfig;
import com.cnil.assistant.CnilApplication;
import com.cnil.assistant.R;
import com.cnil.assistant.utils.Constants;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;


public class MainActivity extends AppCompatActivity {
    private static ExecutorService executorService;
    private static final int NUMBER_OF_THREADS_IN_POOL = 2;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);

        executorService = Executors.newFixedThreadPool(NUMBER_OF_THREADS_IN_POOL);

        if (BuildConfig.DEV && BuildConfig.DEBUG) {
            CnilApplication.writeStringPreference(this,
                    Constants.SHARED_PREFERENCES_KEY_SETTINGS_RECORDING, Constants.SETTINGS_RECORDING_ON);
        }

        NavHostFragment navHostFragment = (NavHostFragment) getSupportFragmentManager().findFragmentById(R.id.nav_host_fragment);
        if (navHostFragment != null) {
            NavInflater inflater = navHostFragment.getNavController().getNavInflater();
            NavGraph graph = inflater.inflate(R.navigation.nav_graph);

            if (CnilApplication.readBooleanPreference(this, Constants.SHARED_PREFERENCES_KEY_IS_FIRST_APP_LAUNCH, true)) {
                graph.setStartDestination(R.id.first_settings_fragment);
                CnilApplication.writeBooleanPreference(this, Constants.SHARED_PREFERENCES_KEY_IS_FIRST_APP_LAUNCH, false);
            } else {
                graph.setStartDestination(R.id.conversation_fragment);
            }
            navHostFragment.getNavController().setGraph(graph);
        }
    }

    public static ExecutorService getExecutorService() {
        return executorService;
    }
}