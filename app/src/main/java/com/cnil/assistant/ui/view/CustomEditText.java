package com.cnil.assistant.ui.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.KeyEvent;

import androidx.annotation.NonNull;

import com.google.android.material.textfield.TextInputEditText;


public class CustomEditText extends TextInputEditText {
    private KeyboardEventListener listener;


    public CustomEditText(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    public boolean onKeyPreIme(int keyCode, @NonNull KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN) {
            if (listener != null) {
                listener.onKeyboardHide(this);
                return true;
            }
        }

        return false;
    }

    public void setOnKeyBoardHideEventListener(KeyboardEventListener listenerObject) {
        listener = listenerObject;
    }
}
