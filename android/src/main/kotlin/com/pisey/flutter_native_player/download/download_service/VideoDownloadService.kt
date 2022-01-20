
package com.pisey.flutter_native_player.download.download_service

import android.annotation.SuppressLint
import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import com.google.android.exoplayer2.offline.Download
import com.google.android.exoplayer2.offline.DownloadManager
import com.google.android.exoplayer2.offline.DownloadService
import com.google.android.exoplayer2.scheduler.PlatformScheduler
import com.google.android.exoplayer2.scheduler.Requirements.RequirementFlags
import com.google.android.exoplayer2.scheduler.Scheduler
import com.google.android.exoplayer2.util.NotificationUtil
import com.google.android.exoplayer2.util.Util
import com.pisey.flutter_native_player.download.notification.NotificationHelper
import com.pisey.flutter_native_player.R
import com.pisey.flutter_native_player.utils.BroadcastSender
import com.pisey.flutter_native_player.utils.PlayerUtil

/** A service for downloading media.  */
class VideoDownloadService : DownloadService(
    FOREGROUND_NOTIFICATION_ID,
    DEFAULT_FOREGROUND_NOTIFICATION_UPDATE_INTERVAL,
    PlayerUtil.DOWNLOAD_NOTIFICATION_CHANNEL_ID,
    R.string.exo_download_notification_channel_name,  /* channelDescriptionResourceId= */
    0
) {
    override fun getDownloadManager(): DownloadManager {
        // This will only happen once, because getDownloadManager is guaranteed to be called only once
        // in the life cycle of the process.
        val downloadManager = PlayerUtil.getDownloadManager( /* context= */this)
        val notificationHelper = PlayerUtil.getNotificationHelper( /* context= */this)
        downloadManager!!.addListener(
            TerminalStateNotificationHelper(
                this, notificationHelper, FOREGROUND_NOTIFICATION_ID + 1
            )
        )
        return downloadManager
    }

    override fun getScheduler(): Scheduler? {
        return if (Util.SDK_INT >= 21) PlatformScheduler(this, JOB_ID) else null
    }

    @SuppressLint("UnspecifiedImmutableFlag")
    private fun actionStop(context: Context, downloads: List<Download>): NotificationCompat.Action?{
        if (downloads.isEmpty()){
            return null
        }
        val intent = Intent(context, VideoDownloadService::class.java).apply {
            action = DownloadService.ACTION_REMOVE_DOWNLOAD
            putExtra(DownloadService.KEY_CONTENT_ID,downloads.first().request.id)
        }
        val pendingIntentRemove = PendingIntent.getService(context, 100, intent, PendingIntent.FLAG_UPDATE_CURRENT)
        return NotificationCompat.Action(null, "Cancel",pendingIntentRemove)
    }
    private fun getTitleMovie(downloads: List<Download>):String{
        return if (downloads.isNotEmpty()){
            downloads.first().request.id
        }else{
            ""
        }
    }

    override fun getForegroundNotification(
        downloads: List<Download>, @RequirementFlags notMetRequirements: Int
    ): Notification {
        BroadcastSender.sendBroadcastDownloadPercentage(context = applicationContext,downloadPercentage = downloads.firstOrNull()?.percentDownloaded?.toInt())
        return PlayerUtil.getNotificationHelper( /* context= */this)
            .buildProgressNotification( /* context= */
                this,
                R.drawable.ic_download,  /* contentIntent= */
                null,  /* message= */
                getTitleMovie(downloads),
                downloads,
                notMetRequirements,
                actionStop(this,downloads)
            )
    }

    /**
     * Creates and displays notifications for downloads when they complete or fail.
     *
     *
     * This helper will outlive the lifespan of a single instance of [DownloadService].
     * It is static to avoid leaking the first [DownloadService] instance.
     */
    private class TerminalStateNotificationHelper(
        context: Context, private val notificationHelper: NotificationHelper, firstNotificationId: Int
    ) : DownloadManager.Listener {
        private val context: Context = context.applicationContext
        private var nextNotificationId: Int = firstNotificationId

        override fun onDownloadChanged(
            downloadManager: DownloadManager, download: Download, finalException: Exception?
        ) {
            BroadcastSender.sendBroadcastDownloadStatus(context,download = download)
            val notification:Notification = when (download.state) {
                Download.STATE_COMPLETED -> {
                    notificationHelper.buildDownloadCompletedNotification(
                        context,
                        R.drawable.ic_download,  /* contentIntent= */
                        null,
                        download.request.id
                    )
                }
                Download.STATE_FAILED -> {
                    notificationHelper.buildDownloadFailedNotification(
                        context,
                        R.drawable.ic_download,  /* contentIntent= */
                        null,
                        download.request.id
                    )
                }

                else -> {
                    return
                }
            }
            NotificationUtil.setNotification(context, nextNotificationId++, notification)
        }

    }

    companion object {
        private const val JOB_ID = 1
        private const val FOREGROUND_NOTIFICATION_ID = 1
    }
}