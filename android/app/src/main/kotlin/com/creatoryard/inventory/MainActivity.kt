package com.creatoryard.inventory

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    companion object {
        private const val TAG = "CreatorYardKiosk"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
        )

        applyImmersiveMode()
        configureKioskIfDeviceOwner()
        tryStartLockTask()
    }

    override fun onResume() {
        super.onResume()

        applyImmersiveMode()
        configureKioskIfDeviceOwner()
        tryStartLockTask()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)

        if (hasFocus) {
            applyImmersiveMode()
        }
    }

    private fun applyImmersiveMode() {
        @Suppress("DEPRECATION")
        window.decorView.systemUiVisibility =
            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
                View.SYSTEM_UI_FLAG_FULLSCREEN or
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
    }

    private fun configureKioskIfDeviceOwner() {
        try {
            val devicePolicyManager =
                getSystemService(DevicePolicyManager::class.java)

            if (devicePolicyManager == null) {
                Log.w(
                    TAG,
                    "DevicePolicyManager is unavailable."
                )
                return
            }

            val packageName =
                applicationContext.packageName

            if (!devicePolicyManager.isDeviceOwnerApp(packageName)) {
                Log.i(
                    TAG,
                    "Creator Yard is not Device Owner. Kiosk policy will not be configured."
                )
                return
            }

            val adminComponent =
                ComponentName(
                    this,
                    KioskDeviceAdminReceiver::class.java
                )

            devicePolicyManager.setLockTaskPackages(
                adminComponent,
                arrayOf(packageName)
            )

            Log.i(
                TAG,
                "Creator Yard added to Lock Task allowlist."
            )

            devicePolicyManager.setLockTaskFeatures(
                adminComponent,
                DevicePolicyManager.LOCK_TASK_FEATURE_GLOBAL_ACTIONS
            )

            Log.i(
                TAG,
                "Lock Task configured with global actions enabled."
            )

        } catch (securityException: SecurityException) {
            Log.w(
                TAG,
                "Unable to configure kiosk policy. Creator Yard may not have Device Owner authority yet.",
                securityException
            )

        } catch (exception: Exception) {
            Log.e(
                TAG,
                "Unexpected error while configuring kiosk policy.",
                exception
            )
        }
    }

    private fun tryStartLockTask() {
        try {
            val devicePolicyManager =
                getSystemService(DevicePolicyManager::class.java)

            if (devicePolicyManager == null) {
                return
            }

            val packageName =
                applicationContext.packageName

            if (
                !devicePolicyManager.isDeviceOwnerApp(packageName) &&
                !devicePolicyManager.isLockTaskPermitted(packageName)
            ) {
                Log.i(
                    TAG,
                    "Lock Task is not permitted. Running normally."
                )
                return
            }

            if (devicePolicyManager.isLockTaskPermitted(packageName)) {
                Log.i(
                    TAG,
                    "Starting Creator Yard Lock Task mode."
                )

                startLockTask()
            }

        } catch (exception: Exception) {
            Log.w(
                TAG,
                "Lock Task is not currently available.",
                exception
            )
        }
    }
}
