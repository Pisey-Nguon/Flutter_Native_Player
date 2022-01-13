package com.pisey.flutter_native_player.download_hls

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import com.pisey.flutter_native_player.Constant
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.offline.DownloadService
import io.flutter.plugin.common.EventChannel.EventSink

class MethodDownload(private val context: Context) {
    private var eventChannelPlayer: EventSink? = null
    private val downloadComponent = DownloadComponent()
    private var mBroadcastReceiver: BroadcastReceiver? = null
    fun startDownload(urlMovie:String,trackIndexMovie:Int) {
        val downloadRequest = downloadComponent.getDownloadRequest(urlMovie, trackIndexMovie)
        DownloadService.sendAddDownload(
            context,
            DemoDownloadService::class.java,
            downloadRequest,
            false
        )
    }

    fun cancelDownload() {
        DownloadService.sendRemoveAllDownloads(context, DemoDownloadService::class.java, false)
    }

    fun isDownloaded(url: String): Boolean {
        val mediaItem = MediaItem.fromUri(url)
        return DemoUtil.getDownloadTracker(context).isDownloaded(mediaItem)
    }

    private fun sendEvent(eventType:String,valueOfEvent:Any?){
        val data = HashMap<String,Any?>()
        data[Constant.KEY_EVENT_TYPE] = eventType
        data[Constant.KEY_VALUE_OF_EVENT] = valueOfEvent
        eventChannelPlayer?.success(data)
    }

    fun setEventChannelPlayer(eventSink: EventSink?){
        eventChannelPlayer = eventSink
    }


    fun removeEventListener() {
        context.unregisterReceiver(mBroadcastReceiver)
    }

    init {
        mBroadcastReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                when (intent?.action) {
                    ConstantDownload.ACTION_PERCENTAGE_DOWNLOADED -> {
                        val percentageDownloaded = intent.getFloatExtra(ConstantDownload.VALUE_PERCENTAGE_DOWNLOADED, 0.0f)
                        sendEvent(Constant.EVENT_PROGRESS_DOWNLOAD,percentageDownloaded.toDouble())
                    }
                    ConstantDownload.ACTION_STATUS_DOWNLOAD -> {
                        when(intent.getStringExtra(ConstantDownload.VALUE_STATUS_DOWNLOAD)){
                            ConstantDownload.DOWNLOAD_COMPLETED -> sendEvent(Constant.EVENT_DOWNLOAD_COMPLETED,null)
                            ConstantDownload.DOWNLOAD_FAILED -> sendEvent(Constant.EVENT_DOWNLOAD_FAILED,null)
                            ConstantDownload.DOWNLOAD_CANCELED -> sendEvent(Constant.EVENT_DOWNLOAD_CANCELED,null)
                            ConstantDownload.DOWNLOAD_STARTED -> sendEvent(Constant.EVENT_DOWNLOAD_STARTED,null)
                        }
                    }
                    else -> {
                        throw IllegalStateException("Unexpected value: " + intent?.action)
                    }
                }
            }
        }
        val intentFilter = IntentFilter()
        intentFilter.addAction(ConstantDownload.ACTION_PERCENTAGE_DOWNLOADED)
        intentFilter.addAction(ConstantDownload.ACTION_STATUS_DOWNLOAD)
        context.registerReceiver(mBroadcastReceiver, intentFilter)
    }
}