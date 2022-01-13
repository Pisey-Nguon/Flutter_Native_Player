package com.pisey.flutter_native_player.download_hls

import android.net.Uri
import com.google.android.exoplayer2.C
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.source.SingleSampleMediaSource
import com.google.android.exoplayer2.source.hls.HlsMediaSource
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.util.MimeTypes
import com.google.android.exoplayer2.util.Util

object StreamBuilder {

    fun buildVideoMediaSource(uri: Uri, dataSourceFactory: DataSource.Factory): MediaSource? {
        return buildVideoMediaSource(uri,dataSourceFactory, null)
    }

    private fun buildVideoMediaSource(uri: Uri, dataSourceFactory: DataSource.Factory, overrideExtension: String?): MediaSource? {
        return when (@C.ContentType val type = Util.inferContentType(uri, overrideExtension)) {
            C.TYPE_HLS -> HlsMediaSource.Factory(dataSourceFactory).setAllowChunklessPreparation(true).createMediaSource(MediaItem.fromUri(uri))
            C.TYPE_OTHER -> ProgressiveMediaSource.Factory(dataSourceFactory).createMediaSource(MediaItem.fromUri(uri))
            else -> throw IllegalStateException("Unsupported type: $type")
        }
    }
    fun buildSubtitleMediaSource(uri:Uri,language:String,dataSourceFactory: DataSource.Factory):MediaSource{
        val factory = SingleSampleMediaSource.Factory(dataSourceFactory)
        val subtitleFormat = MediaItem.Subtitle(uri,MimeTypes.APPLICATION_SUBRIP,language,C.SELECTION_FLAG_DEFAULT)
        return factory.createMediaSource( subtitleFormat, C.TIME_UNSET)
    }

}