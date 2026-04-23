package org.mfmlekki.app

import android.os.Build
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onPostResume() {
        super.onPostResume()
        // Enable edge-to-edge display for all API levels
        // This ensures proper inset handling on Android 15+ (API 35+)
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        // For Android 15+, additionally ensure system bars are not drawn behind windows
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            window.setDecorFitsSystemWindows(false)
        }
    }
}
