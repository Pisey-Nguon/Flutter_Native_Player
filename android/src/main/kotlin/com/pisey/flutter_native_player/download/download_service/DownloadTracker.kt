
package com.pisey.flutter_native_player.download.download_service

import android.content.Context
import android.net.Uri
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.offline.Download
import com.google.android.exoplayer2.offline.DownloadIndex
import com.google.android.exoplayer2.offline.DownloadManager
import com.google.android.exoplayer2.offline.DownloadRequest
import com.google.android.exoplayer2.upstream.HttpDataSource
import com.google.android.exoplayer2.util.Assertions
import com.google.android.exoplayer2.util.Log
import java.io.IOException
import java.util.*
import java.util.concurrent.CopyOnWriteArraySet

/** Tracks media that has been downloaded.  */
class DownloadTracker(
    context: Context,
    httpDataSourceFactory: HttpDataSource.Factory?,
    downloadManager: DownloadManager?
) {
    /** Listens for changes in the tracked downloads.  */
    interface Listener {
        /** Called when the tracked downloads changed.  */
        fun onDownloadsChanged()
    }

    private val context: Context
    private val httpDataSourceFactory: HttpDataSource.Factory?
    private val listeners: CopyOnWriteArraySet<Listener>
    private val downloads: HashMap<Uri, Download>
    private val downloadIndex: DownloadIndex
    fun addListener(listener: Listener) {
        Assertions.checkNotNull(listener)
        listeners.add(listener)
    }

    fun removeListener(listener: Listener) {
        listeners.remove(listener)
    }

    fun isDownloaded(mediaItem: MediaItem): Boolean {
        val download = downloads[Assertions.checkNotNull(mediaItem.localConfiguration).uri]
        return download != null && download.state != Download.STATE_FAILED
    }

    fun getDownloadRequest(uri: Uri): DownloadRequest? {
        val download = downloads[uri]
        return if (download != null && download.state != Download.STATE_FAILED) download.request else null
    }

    private fun loadDownloads() {
        try {
            downloadIndex.getDownloads().use { loadedDownloads ->
                while (loadedDownloads.moveToNext()) {
                    val download = loadedDownloads.download
                    downloads[download.request.uri] = download
                }
            }
        } catch (e: IOException) {
            Log.w(TAG, "Failed to query downloads", e)
        }
    }

    private inner class DownloadManagerListener : DownloadManager.Listener {
        override fun onDownloadChanged(
            downloadManager: DownloadManager, download: Download, finalException: Exception?
        ) {
            downloads[download.request.uri] = download
            for (listener in listeners) {
                listener.onDownloadsChanged()
            }
        }

        override fun onDownloadRemoved(downloadManager: DownloadManager, download: Download) {
            downloads.remove(download.request.uri)
            for (listener in listeners) {
                listener.onDownloadsChanged()
            }
        }
    }


    companion object {
        private const val TAG = "DownloadTracker"
    }

    init {
        this.context = context.applicationContext
        this.httpDataSourceFactory = httpDataSourceFactory
        listeners = CopyOnWriteArraySet()
        downloads = HashMap()
        downloadIndex = downloadManager!!.downloadIndex
        downloadManager.addListener(DownloadManagerListener())
        loadDownloads()
    }
}