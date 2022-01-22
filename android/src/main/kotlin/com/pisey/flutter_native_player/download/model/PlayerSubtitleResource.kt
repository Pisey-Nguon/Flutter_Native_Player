package com.pisey.flutter_native_player.download.model

import android.os.Parcelable
import kotlinx.android.parcel.Parcelize

@Parcelize
data class PlayerSubtitleResource(var subtitleUrl:String, val language: String):Parcelable