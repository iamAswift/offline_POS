package com.creatoryard.inventory

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootCompletedReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "CreatorYardBoot"
    }

    override fun onReceive(
        context: Context,
        intent: Intent
    ) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) {
            return
        }

        Log.i(
            TAG,
            "Android boot completed. Launching Creator Yard Inventory."
        )

        try {
            val launchIntent =
                context.packageManager.getLaunchIntentForPackage(
                    context.packageName
                )

            if (launchIntent == null) {
                Log.e(
                    TAG,
                    "Unable to find Creator Yard Inventory launch activity."
                )
                return
            }

            launchIntent.addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
            )

            context.startActivity(launchIntent)

        } catch (exception: Exception) {
            Log.e(
                TAG,
                "Failed to launch Creator Yard Inventory after boot.",
                exception
            )
        }
    }
}
