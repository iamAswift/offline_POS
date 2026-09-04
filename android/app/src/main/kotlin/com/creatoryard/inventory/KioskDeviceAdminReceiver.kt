package com.creatoryard.inventory

import android.app.admin.DeviceAdminReceiver
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class KioskDeviceAdminReceiver : DeviceAdminReceiver() {

    companion object {
        private const val TAG = "CreatorYardDeviceAdmin"
    }

    override fun onEnabled(
        context: Context,
        intent: Intent
    ) {
        super.onEnabled(context, intent)

        Log.i(
            TAG,
            "Creator Yard device administrator enabled."
        )

        configureKiosk(context)
    }

    override fun onProfileProvisioningComplete(
        context: Context,
        intent: Intent
    ) {
        super.onProfileProvisioningComplete(
            context,
            intent
        )

        Log.i(
            TAG,
            "Creator Yard provisioning completed."
        )

        configureKiosk(context)
    }

    private fun configureKiosk(
        context: Context
    ) {
        try {
            val devicePolicyManager =
                context.getSystemService(
                    DevicePolicyManager::class.java
                )

            if (devicePolicyManager == null) {
                Log.e(
                    TAG,
                    "DevicePolicyManager is unavailable."
                )
                return
            }

            val adminComponent =
                ComponentName(
                    context,
                    KioskDeviceAdminReceiver::class.java
                )

            val packageName =
                context.packageName

            if (
                Build.VERSION.SDK_INT >=
                Build.VERSION_CODES.LOLLIPOP
            ) {
                devicePolicyManager.setLockTaskPackages(
                    adminComponent,
                    arrayOf(packageName)
                )

                Log.i(
                    TAG,
                    "Creator Yard added to Lock Task allowlist."
                )
            }

            if (
                Build.VERSION.SDK_INT >=
                Build.VERSION_CODES.P
            ) {
                devicePolicyManager.setLockTaskFeatures(
                    adminComponent,
                    DevicePolicyManager.LOCK_TASK_FEATURE_GLOBAL_ACTIONS
                )

                Log.i(
                    TAG,
                    "Global actions enabled for Lock Task."
                )
            }

        } catch (securityException: SecurityException) {

            Log.w(
                TAG,
                "Kiosk policy could not be configured because the app is not yet Device Owner.",
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
}
