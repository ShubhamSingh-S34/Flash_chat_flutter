package co.appbrewery.flash_chat;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
<activity android:name=".MainActivity"
    android:theme="@style/LaunchTheme"
            // some code omitted
            >
  <!-- Specify that the launch screen should continue being displayed -->
  <!-- until Flutter renders its first frame. -->
  <meta-data
    android:name="io.flutter.embedding.android.SplashScreenDrawable"
    android:resource="@drawable/launch_background" />

  <!-- Theme to apply as soon as Flutter begins rendering frames -->
  <meta-data
    android:name="io.flutter.embedding.android.NormalTheme"
    android:resource="@style/NormalTheme"
            />

  <!-- some code omitted -->
</activity>
}
