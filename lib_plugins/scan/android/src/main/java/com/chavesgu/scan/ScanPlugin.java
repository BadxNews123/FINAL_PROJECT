package com.chavesgu.scan;

import android.app.Activity;
import android.os.AsyncTask;
import android.os.Build;
import android.os.VibrationEffect;
import android.os.Vibrator;

import androidx.annotation.NonNull;

import java.lang.ref.WeakReference;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

import static android.content.Context.VIBRATOR_SERVICE;

public class ScanPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  private MethodChannel channel;
  private Activity activity;
  private FlutterPluginBinding flutterPluginBinding;
  private MethodChannel.Result result;
  private QrCodeAsyncTask task;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    this.flutterPluginBinding = flutterPluginBinding;
  }

  private void configChannel(ActivityPluginBinding binding) {
    activity = binding.getActivity();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "chavesgu/scan");
    channel.setMethodCallHandler(this);
    flutterPluginBinding
        .getPlatformViewRegistry()
        .registerViewFactory(
            "chavesgu/scan_view",
            new ScanViewFactory(
                flutterPluginBinding.getBinaryMessenger(),
                flutterPluginBinding.getApplicationContext(),
                activity,
                binding));
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    configChannel(binding);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    configChannel(binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {}

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    flutterPluginBinding = null;
  }

  @Override
  public void onDetachedFromActivity() {
    activity = null;
    if (channel != null) {
      channel.setMethodCallHandler(null);
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    this.result = result;
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + Build.VERSION.RELEASE);
    } else if (call.method.equals("parse")) {
      String path = (String) call.arguments;
      task = new QrCodeAsyncTask(this, path);
      task.execute(path);
    } else {
      result.notImplemented();
    }
  }

  static class QrCodeAsyncTask extends AsyncTask<String, Integer, String> {
    private final WeakReference<ScanPlugin> pluginRef;
    private final String path;

    QrCodeAsyncTask(ScanPlugin plugin, String path) {
      this.pluginRef = new WeakReference<>(plugin);
      this.path = path;
    }

    @Override
    protected String doInBackground(String... strings) {
      return QRCodeDecoder.decodeQRCode(pluginRef.get().flutterPluginBinding.getApplicationContext(), path);
    }

    @Override
    protected void onPostExecute(String resultData) {
      super.onPostExecute(resultData);
      ScanPlugin plugin = pluginRef.get();
      if (plugin != null && plugin.result != null) {
        plugin.result.success(resultData);
        plugin.result = null;
      }

      plugin.task = null;

      if (resultData != null) {
        Vibrator vibrator = (Vibrator) plugin.flutterPluginBinding.getApplicationContext().getSystemService(VIBRATOR_SERVICE);
        if (vibrator != null) {
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createOneShot(50, VibrationEffect.DEFAULT_AMPLITUDE));
          } else {
            vibrator.vibrate(50);
          }
        }
      }
    }
  }
}
