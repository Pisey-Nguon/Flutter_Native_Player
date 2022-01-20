package com.pisey.flutter_native_player.utils

import android.os.Handler
import android.os.Looper
import java.util.concurrent.Callable
import java.util.concurrent.Executor
import java.util.concurrent.Executors

class TaskRunner {
    private val executor: Executor = Executors.newSingleThreadExecutor() // change according to your requirements
    private val handler = Handler(Looper.getMainLooper())

    interface Callback<R> {
        fun onComplete(result: R)
    }

    fun <R> executeAsync(callable: Callable<R>, callback: Callback<R>) {
        executor.execute {
            val result = callable.call()
            handler.post { callback.onComplete(result) }
        }
    }
}