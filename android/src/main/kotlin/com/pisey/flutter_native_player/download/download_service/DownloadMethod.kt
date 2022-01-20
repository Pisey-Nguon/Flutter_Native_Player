package com.pisey.flutter_native_player.download.download_service

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.offline.Download
import com.google.android.exoplayer2.offline.DownloadService
import com.pisey.flutter_native_player.constants.Constant
import com.pisey.flutter_native_player.download.model.DownloadEventModel
import com.pisey.flutter_native_player.download.model.PlayerResource
import com.pisey.flutter_native_player.utils.PlayerUtil
import com.pisey.flutter_native_player.constants.ConstantDownload
import io.flutter.plugin.common.EventChannel

class DownloadMethod(private val context: Context) {
    private var mBroadcastReceiver:BroadcastReceiver? = null
    fun startDownload(playerResource: PlayerResource?, trackIndexMovie:Int) {
        val intent = Intent(context, PrepareDownloadService::class.java)
        intent.putExtra(Constant.EXO_PLAYER_RESOURCE,playerResource)
        intent.putExtra(Constant.KEY_TRACK_INDEX,trackIndexMovie)
        context.startService(intent)
    }

    fun cancelDownload() {
        DownloadService.sendRemoveAllDownloads(context, VideoDownloadService::class.java, false)
    }

    fun isDownloaded(url: String): Boolean {
        val mediaItem = MediaItem.fromUri(url)
        return PlayerUtil.getDownloadTracker(context).isDownloaded(mediaItem)
    }

    private fun sendEvent(eventChannelPlayer: EventChannel.EventSink?,eventType:String,valueOfEvent:Any?){
        val data = HashMap<String,Any?>()
        data[Constant.KEY_EVENT_TYPE] = eventType
        data[Constant.KEY_VALUE_OF_EVENT] = valueOfEvent
        eventChannelPlayer?.success(data)
    }

    fun removeEventListener() {
        mBroadcastReceiver?.let { context.unregisterReceiver(it) }
    }

    fun setEventChannelPlayer(eventSink: EventChannel.EventSink?){
        mBroadcastReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                when (intent?.action) {
                    ConstantDownload.ACTION_DOWNLOAD_PERCENTAGE -> {
                        val percentageDownloaded = intent.getIntExtra(ConstantDownload.DATA_DOWNLOAD_PERCENTAGE, 0)
                        sendEvent(eventSink, Constant.EVENT_PROGRESS_DOWNLOAD,percentageDownloaded.toDouble())
                    }
                    ConstantDownload.ACTION_DOWNLOAD_STATUS -> {
                        val downloadEventModel = intent.getParcelableExtra<DownloadEventModel>(
                            ConstantDownload.DATA_DOWNLOAD_STATUS)
                        when(downloadEventModel?.state){
                            Download.STATE_COMPLETED -> sendEvent(eventSink,
                                Constant.EVENT_DOWNLOAD_COMPLETED,null)
                            Download.STATE_FAILED -> sendEvent(eventSink,
                                Constant.EVENT_DOWNLOAD_FAILED,null)
                            Download.STATE_STOPPED -> sendEvent(eventSink,
                                Constant.EVENT_DOWNLOAD_CANCELED,null)
                            Download.STATE_DOWNLOADING -> sendEvent(eventSink,
                                Constant.EVENT_DOWNLOAD_STARTED,null)
                            Download.STATE_QUEUED -> sendEvent(eventSink,
                                Constant.EVENT_DOWNLOAD_QUEUED,null)
                        }
                    }
                    else -> {
                        throw IllegalStateException("Unexpected value: " + intent?.action)
                    }
                }
            }
        }
        val intentFilter = IntentFilter()
        intentFilter.addAction(ConstantDownload.ACTION_DOWNLOAD_PERCENTAGE)
        intentFilter.addAction(ConstantDownload.ACTION_DOWNLOAD_STATUS)
        context.registerReceiver(mBroadcastReceiver, intentFilter)
    }

}