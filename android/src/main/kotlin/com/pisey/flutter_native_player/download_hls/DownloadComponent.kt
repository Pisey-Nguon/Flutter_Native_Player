package com.pisey.flutter_native_player.download_hls

import android.net.Uri
import com.google.android.exoplayer2.offline.DownloadRequest
import com.google.android.exoplayer2.offline.StreamKey
import com.google.android.exoplayer2.util.MimeTypes
import java.util.*

class DownloadComponent {
    fun getDownloadRequest(urlMovie: String, trackIndex: Int?): DownloadRequest {
        val streamKeys = ArrayList<StreamKey>()
        streamKeys.add(StreamKey(0, 0, trackIndex!!))
        streamKeys.add(StreamKey(0, 1, 0))
        return DownloadRequest.Builder(urlMovie, Uri.parse(urlMovie))
            .setMimeType(MimeTypes.APPLICATION_M3U8)
            .setData(urlMovie.toByteArray())
            .setStreamKeys(streamKeys)
            .build()
    }
}