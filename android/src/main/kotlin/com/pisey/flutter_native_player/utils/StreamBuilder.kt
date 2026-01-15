package com.pisey.flutter_native_player.utils

import android.net.Uri
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.exoplayer.source.MediaSource
import androidx.media3.exoplayer.source.ProgressiveMediaSource
import androidx.media3.exoplayer.source.hls.HlsMediaSource
import androidx.media3.datasource.DataSource
import androidx.media3.common.util.Util

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