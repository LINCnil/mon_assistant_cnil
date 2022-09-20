package com.cnil.assistant.ui;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.cnil.assistant.R;
import com.cnil.assistant.models.DebugInfoModel;
import com.cnil.assistant.ui.adapters.DebugInfoAdapter;
import com.cnil.assistant.utils.DebugLogInfoManager;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;


public class DebugInfoFragment extends BaseFragment implements DebugLogInfoManager.Observer {
    private RecyclerView recyclerView;

    private DebugInfoAdapter debugInfoRecyclerViewAdapter;

    @Override
    public View onCreateView(@NotNull LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View createdView = inflater.inflate(R.layout.debug_info_fragment, container, false);

        recyclerView = createdView.findViewById(R.id.debug_info_recycler_view);
        Button clearLogsButton = createdView.findViewById(R.id.debug_info_clear_logs_button);
        Button exportLogsButton = createdView.findViewById(R.id.debug_info_export_logs_button);

        clearLogsButton.setOnClickListener(v -> DebugLogInfoManager.clearLogs());
        exportLogsButton.setOnClickListener(v -> DebugLogInfoManager.exportDebugInfoToFile(getContext()));

        debugInfoRecyclerViewAdapter = new DebugInfoAdapter();

        return createdView;
    }

    @Override
    public void onResume() {
        super.onResume();
        DebugLogInfoManager.addObserver(this);
    }

    @Override
    public void onPause() {
        super.onPause();
        DebugLogInfoManager.removeObserver(this);
    }

    public void onDebugInfoUpdated(ArrayList<DebugInfoModel> list) {
        debugInfoRecyclerViewAdapter.submitList(list);
        recyclerView.setLayoutManager(new LinearLayoutManager(parentActivity));
        recyclerView.setAdapter(debugInfoRecyclerViewAdapter);
        recyclerView.scrollToPosition(list.size() - 1);
    }
}
