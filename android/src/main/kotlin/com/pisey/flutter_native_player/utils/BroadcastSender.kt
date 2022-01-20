package com.pisey.flutter_native_player.utils

import android.content.Context
import android.content.Intent
import com.google.android.exoplayer2.offline.Download
import com.pisey.flutter_native_player.download.model.DownloadEventModel
import com.pisey.flutter_native_player.constants.ConstantDownload

object BroadcastSender {
    @JvmStatic
    fun sendBroadcastDownloadPercentage(context: Context,downloadPercentage:Int?) {
        val intent = Intent(ConstantDownload.ACTION_DOWNLOAD_PERCENTAGE)
        downloadPercentage?.let {
            intent.putExtra(ConstantDownload.DATA_DOWNLOAD_PERCENTAGE,downloadPercentage)
        }
        context.sendBroadcast(intent)
    }

    @JvmStatic
    fun sendBroadcastDownloadStatus(context: Context, download:Download) {
        val intent = Intent(ConstantDownload.ACTION_DOWNLOAD_STATUS)
        val downloadEventModel = DownloadEventModel(state = download.state,mediaUrl = download.request.uri.toString())
        intent.putExtra(ConstantDownload.DATA_DOWNLOAD_STATUS, downloadEventModel)
        context.sendBroadcast(intent)
    }

    @JvmStatic
    fun sendBroadcastDownloadStatus(context: Context, downloadEventModel: DownloadEventModel) {
        val intent = Intent(ConstantDownload.ACTION_DOWNLOAD_STATUS)
        intent.putExtra(ConstantDownload.DATA_DOWNLOAD_STATUS, downloadEventModel)
        context.sendBroadcast(intent)
    }
}