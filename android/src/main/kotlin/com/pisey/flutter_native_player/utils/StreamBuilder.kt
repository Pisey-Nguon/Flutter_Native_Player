package com.pisey.flutter_native_player.utils

import android.net.Uri
import com.google.android.exoplayer2.C
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.source.hls.HlsMediaSource
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.util.Util

object StreamBuilder {

    fun buildVideoMediaSource(uri: Uri, dataSourceFactory: DataSource.Factory): MediaSource {
        return buildVideoMediaSource(uri,dataSourceFactory, null)
    }

    private fun buildVideoMediaSource(uri: Uri, dataSourceFactory: DataSource.Factory, overrideExtension: String?): MediaSource {
        return when (@C.ContentType val type = Util.inferContentType(uri, overrideExtension)) {
            C.TYPE_HLS -> HlsMediaSource.Factory(dataSourceFactory).setAllowChunklessPreparation(true).createMediaSource(MediaItem.fromUri(uri))
            C.TYPE_OTHER -> ProgressiveMediaSource.Factory(dataSourceFactory).createMediaSource(MediaItem.fromUri(uri))
            else -> throw IllegalStateException("Unsupported type: $type")
        }
    }

}