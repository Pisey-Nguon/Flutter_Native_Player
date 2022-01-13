package com.pisey.flutter_native_player.download_hls

import android.content.Context
import android.content.Intent
import com.google.android.exoplayer2.offline.Download

object BroadcastSender {
    @JvmStatic
    fun sendBroadcastPercentage(context: Context, downloads: List<Download>) {
        if (downloads.isNotEmpty()) {
            val intent = Intent(ConstantDownload.ACTION_PERCENTAGE_DOWNLOADED)
            intent.putExtra(
                ConstantDownload.VALUE_PERCENTAGE_DOWNLOADED,
                downloads[0].percentDownloaded
            )
            context.sendBroadcast(intent)
        }
    }

    @JvmStatic
    fun sendBroadcastStatusDownload(context: Context, statusDownload: String?) {
        val intent = Intent(ConstantDownload.ACTION_STATUS_DOWNLOAD)
        intent.putExtra(ConstantDownload.VALUE_STATUS_DOWNLOAD, statusDownload)
        context.sendBroadcast(intent)
    }
}