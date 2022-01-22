package com.pisey.flutter_native_player.download.model

import android.os.Parcelable
import kotlinx.android.parcel.Parcelize

@Parcelize
data class DownloadEventModel(val state:Int, val mediaUrl:String):Parcelable
