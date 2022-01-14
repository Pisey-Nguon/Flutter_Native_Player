package com.pisey.flutter_native_player.download.download_service

import android.app.Service
import android.content.Intent
import android.net.Uri
import android.os.IBinder
import com.google.android.exoplayer2.offline.Download
import com.google.android.exoplayer2.offline.Download.FAILURE_REASON_NONE
import com.google.android.exoplayer2.offline.DownloadRequest
import com.google.android.exoplayer2.offline.DownloadService
import com.google.android.exoplayer2.offline.StreamKey
import com.google.android.exoplayer2.util.MimeTypes
import com.google.android.exoplayer2.util.NotificationUtil
import com.google.gson.Gson
import com.pisey.flutter_native_player.Constant
import com.pisey.flutter_native_player.R
import com.pisey.flutter_native_player.download.model.PlayerResource
import com.pisey.flutter_native_player.download.utils.BroadcastSender
import com.pisey.flutter_native_player.download.utils.DownloadFile
import com.pisey.flutter_native_player.download.utils.PlayerUtil
import com.pisey.flutter_native_player.download.utils.TaskRunner

class PrepareDownloadService:Service() {

    override fun onBind(p0: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()
        NotificationUtil.createNotificationChannel(
            this,
            PlayerUtil.DOWNLOAD_NOTIFICATION_CHANNEL_ID,
            R.string.application_name,
            R.string.exo_download_description,
            NotificationUtil.IMPORTANCE_LOW
        )
    }

    private fun downloadSubtitles(playerResource: PlayerResource?, completed:() -> Unit){
        val clone = playerResource?.copy()
        playerResource?.let { resource ->
            resource.subtitles.forEachIndexed {index, subtitleModel ->
                TaskRunner().executeAsync(DownloadFile(this, subtitleModel.urlSubtitle), object : TaskRunner.Callback<String?> {
                    override fun onComplete(result: String?) {
                        if (result != null){
                            clone?.subtitles?.get(index)?.urlSubtitle = result
                        }
                        if (index == playerResource.subtitles.size - 1){
                            completed.invoke()
                        }
                    }
                })
            }

        }
    }

    private fun getDownloadRequest(playerResource: PlayerResource, trackIndex: Int): DownloadRequest {
        val playerResourceGson = Gson().toJson(playerResource)
        val streamKeys = ArrayList<StreamKey>()
        streamKeys.add(StreamKey(0, 0, trackIndex))
        streamKeys.add(StreamKey(0, 1, 0))
        return DownloadRequest.Builder(playerResource.mediaName, Uri.parse(playerResource.mediaUrl))
            .setMimeType(MimeTypes.APPLICATION_M3U8)
            .setData(playerResourceGson.toByteArray())
            .setStreamKeys(streamKeys)
            .build()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = PlayerUtil.getNotificationHelper(this).buildWaitingNotification(this, R.drawable.ic_download_done,  /* contentIntent= */null, null)
        NotificationUtil.setNotification(this, 1, notification)

        val playerResource = intent?.getParcelableExtra<PlayerResource>(Constant.EXO_PLAYER_RESOURCE)
        val trackIndexMovie = intent?.getIntExtra(Constant.KEY_TRACK_INDEX,0)
        val request =  DownloadRequest.Builder(playerResource!!.mediaName,Uri.parse(playerResource.mediaUrl))
            .setMimeType(MimeTypes.APPLICATION_M3U8)
            .build()
        val download = Download(request,Download.STATE_QUEUED,0,0,0,0,FAILURE_REASON_NONE)
        BroadcastSender.sendBroadcastDownloadStatus(this,download = download)

        downloadSubtitles(playerResource,completed = {
            val downloadRequest = getDownloadRequest(playerResource, trackIndexMovie!!)
            downloadRequest.let { DownloadService.sendAddDownload(this@PrepareDownloadService, VideoDownloadService::class.java, it,false) }
        })
        return super.onStartCommand(intent, flags, startId)
    }

}