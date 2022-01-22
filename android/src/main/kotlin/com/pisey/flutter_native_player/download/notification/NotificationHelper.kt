package com.pisey.flutter_native_player.download.notification

import android.annotation.SuppressLint
import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import androidx.core.app.NotificationCompat
import com.google.android.exoplayer2.C
import com.google.android.exoplayer2.offline.Download
import com.google.android.exoplayer2.scheduler.Requirements
import com.google.android.exoplayer2.scheduler.Requirements.RequirementFlags
import com.pisey.flutter_native_player.R

class NotificationHelper(context: Context, channelId: String?) {
    private val notificationBuilder: NotificationCompat.Builder = NotificationCompat.Builder(context.applicationContext, channelId!!)



    /**
     * Returns a progress notification for the given downloads.
     *
     * @param context A context.
     * @param smallIcon A small icon for the notification.
     * @param contentIntent An optional content intent to send when the notification is clicked.
     * @param message An optional message to display on the notification.
     * @param downloads The downloads.
     * @param notMetRequirements Any requirements for downloads that are not currently met.
     * @return The notification.
     */
    fun buildProgressNotification(
        context: Context,
        @DrawableRes smallIcon: Int,
        contentIntent: PendingIntent?,
        message: String?,
        downloads: List<Download>,
        @RequirementFlags notMetRequirements: Int,
        action: NotificationCompat.Action?
    ): Notification {
        var totalPercentage = 0f
        var downloadTaskCount = 0
        var allDownloadPercentagesUnknown = true
        var haveDownloadedBytes = false
        var haveDownloadingTasks = false
        var haveQueuedTasks = false
        var haveRemovingTasks = false
        for (i in downloads.indices) {
            val download = downloads[i]
            when (download.state) {
                Download.STATE_REMOVING -> haveRemovingTasks = true
                Download.STATE_QUEUED -> haveQueuedTasks = true
                Download.STATE_RESTARTING, Download.STATE_DOWNLOADING -> {
                    haveDownloadingTasks = true
                    val downloadPercentage = download.percentDownloaded
                    if (downloadPercentage != C.PERCENTAGE_UNSET.toFloat()) {
                        allDownloadPercentagesUnknown = false
                        totalPercentage += downloadPercentage
                    }
                    haveDownloadedBytes = haveDownloadedBytes or (download.bytesDownloaded > 0)
                    downloadTaskCount++
                }
                Download.STATE_STOPPED, Download.STATE_COMPLETED, Download.STATE_FAILED -> {
                }
                else -> {
                }
            }
        }
        val titleStringId: Int
        var showProgress = true
        if (haveDownloadingTasks) {
            titleStringId = R.string.exo_download_downloading
        } else if (haveQueuedTasks && notMetRequirements != 0) {
            showProgress = false
            titleStringId = if (notMetRequirements and Requirements.NETWORK_UNMETERED != 0) {
                // Note: This assumes that "unmetered" == "WiFi", since it provides a clearer message that's
                // correct in the majority of cases.
                R.string.exo_download_paused_for_wifi
            } else if (notMetRequirements and Requirements.NETWORK != 0) {
                R.string.exo_download_paused_for_network
            } else {
                R.string.exo_download_paused
            }
        } else if (haveRemovingTasks) {
            titleStringId = R.string.exo_download_removing
        } else {
            // There are either no downloads, or all downloads are in terminal states.
            titleStringId = NULL_STRING_ID
        }
        var maxProgress = 0
        var currentProgress = 0
        var indeterminateProgress = false
        if (showProgress) {
            maxProgress = 100
            if (haveDownloadingTasks) {
                currentProgress = (totalPercentage / downloadTaskCount).toInt()
                indeterminateProgress = allDownloadPercentagesUnknown && haveDownloadedBytes
            } else {
                indeterminateProgress = true
            }
        }
        return buildNotification(
            context,
            smallIcon,
            contentIntent,
            message,
            titleStringId,
            maxProgress,
            currentProgress,
            indeterminateProgress,  /* ongoing= */
            true,  /* showWhen= */
            false,
            action
        )
    }

    fun buildWaitingNotification(
        context: Context,
        @DrawableRes smallIcon: Int,
        contentIntent: PendingIntent?,
        message: String?

    ): Notification {

        return buildNotification(
            context,
            smallIcon,
            contentIntent,
            message,
            R.string.exo_download_downloading,
            100,
            0,
            true,  /* ongoing= */
            true,  /* showWhen= */
            false,
            null
        )
    }

    /**
     * Returns a notification for a completed download.
     *
     * @param context A context.
     * @param smallIcon A small icon for the notifications.
     * @param contentIntent An optional content intent to send when the notification is clicked.
     * @param message An optional message to display on the notification.
     * @return The notification.
     */
    fun buildDownloadCompletedNotification(
        context: Context,
        @DrawableRes smallIcon: Int,
        contentIntent: PendingIntent?,
        message: String?
    ): Notification {
        val titleStringId = R.string.exo_download_completed
        return buildEndStateNotification(context, smallIcon, contentIntent, message, titleStringId)
    }

    /**
     * Returns a notification for a failed download.
     *
     * @param context A context.
     * @param smallIcon A small icon for the notifications.
     * @param contentIntent An optional content intent to send when the notification is clicked.
     * @param message An optional message to display on the notification.
     * @return The notification.
     */
    fun buildDownloadFailedNotification(
        context: Context,
        @DrawableRes smallIcon: Int,
        contentIntent: PendingIntent?,
        message: String?
    ): Notification {
        @StringRes val titleStringId = R.string.exo_download_failed
        return buildEndStateNotification(context, smallIcon, contentIntent, message, titleStringId)
    }

    private fun buildEndStateNotification(
        context: Context,
        @DrawableRes smallIcon: Int,
        contentIntent: PendingIntent?,
        message: String?,
        @StringRes titleStringId: Int
    ): Notification {
        return buildNotification(
            context,
            smallIcon,
            contentIntent,
            message,
            titleStringId,  /* maxProgress= */
            0,  /* currentProgress= */
            0,  /* indeterminateProgress= */
            false,  /* ongoing= */
            false,  /* showWhen= */
            true,
            null
        )
    }

    @SuppressLint("RestrictedApi")
    private fun buildNotification(
        context: Context,
        @DrawableRes smallIcon: Int,
        contentIntent: PendingIntent?,
        message: String?,
        @StringRes titleStringId: Int,
        maxProgress: Int,
        currentProgress: Int,
        indeterminateProgress: Boolean,
        ongoing: Boolean,
        showWhen: Boolean,
        action:NotificationCompat.Action?
    ): Notification {
        notificationBuilder.setSmallIcon(smallIcon)
        notificationBuilder.setContentTitle(
            if (titleStringId == NULL_STRING_ID) null else context.resources.getString(titleStringId)
        )
        notificationBuilder.setContentIntent(contentIntent)
        notificationBuilder.setStyle(
            if (message == null) null else NotificationCompat.BigTextStyle().bigText(message)
        )
        if (action == null){
            notificationBuilder.mActions.clear()
        }else{
            if (notificationBuilder.mActions.size == 0){
                notificationBuilder.addAction(action)
            }
        }

        notificationBuilder.setProgress(maxProgress, currentProgress, indeterminateProgress)
        notificationBuilder.setOngoing(ongoing)
        notificationBuilder.setShowWhen(showWhen)
        return notificationBuilder.build()
    }

    companion object {
        @StringRes
        private val NULL_STRING_ID = 0
    }

}