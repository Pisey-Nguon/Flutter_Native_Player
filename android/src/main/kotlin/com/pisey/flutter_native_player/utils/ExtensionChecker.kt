package com.pisey.flutter_native_player.utils

fun String.extension():String {
    return this.substring(this.lastIndexOf(".") + 1)
}

fun String.filename():String{
    return this.substring(this.lastIndexOf('/') + 1)
}
fun String.isSrt():Boolean{
    return this.extension() == "srt"
}
fun String.isM3U8():Boolean{
    return this.extension() == "m3u8"
}