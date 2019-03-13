package org.snowkit.snow;

import android.os.Bundle;
import android.app.Activity;
import android.util.Log;

public class SnowActivity extends org.libsdl.app.SDLActivity {

    private final static String SNOW_TAG = "SNOW";
    public static Activity snow_activity;
    public native void snowInit();
    public native void snowQuit();

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.i(SNOW_TAG, ">>>>>>>>/ snow / On Create .....");
        snow_activity = this;
        snowInit();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.i(SNOW_TAG, ">>>>>>>>/ snow / On Destroy .....");
        snowQuit();
    }

    @Override
    protected void onPause() {
        super.onPause();
        Log.i(SNOW_TAG, ">>>>>>>>/ snow / On Pause .....");
    }

    @Override
    protected void onRestart() {
        super.onRestart();
        Log.i(SNOW_TAG, ">>>>>>>>/ snow / On Restart .....");
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.i(SNOW_TAG, ">>>>>>>>/ snow / On Resume .....");
    }

    @Override
    protected void onStart() {
        super.onStart();
        Log.i(SNOW_TAG, ">>>>>>>>/ snow / On Start .....");
    }

    @Override
    protected void onStop() {
        super.onStop();
        Log.i(SNOW_TAG, ">>>>>>>>/ snow / On Stop .....");
    }

} //SnowActivity

