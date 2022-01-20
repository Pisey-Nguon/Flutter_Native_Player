package com.pisey.flutter_native_player.utils

import android.content.Context
import android.content.ContextWrapper
import java.io.*
import java.net.HttpURLConnection
import java.net.URL
import java.util.*
import java.util.concurrent.Callable

class DownloadFile (private val context: Context,private val url: String) : Callable<String?> {

    private var uri: String? = null
    override fun call(): String? {
        // Some long running task
        try {
            val u = URL(url)
            val conn = u.openConnection() as HttpURLConnection
            val contentLength: Int = conn.contentLength
            val stream = DataInputStream(u.openStream())
            val buffer = ByteArray(contentLength)
            stream.readFully(buffer)
            stream.close()
            val contextWrapper =  ContextWrapper(context)
            val directory = contextWrapper.getDir(context.filesDir.name, Context.MODE_PRIVATE)
            val file = File(directory, "${UUID.randomUUID()}.${url.extension()}")
            val fos = FileOutputStream(file, true)
            fos.write(buffer)
            fos.close()
            uri = file.toString()
        } catch (e: FileNotFoundException) {
            uri = null
        } catch (e: IOException) {
            uri = null

        }
        return uri
    }

}