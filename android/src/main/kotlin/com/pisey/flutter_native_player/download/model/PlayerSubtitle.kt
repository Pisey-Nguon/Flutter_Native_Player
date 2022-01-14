package com.pisey.flutter_native_player.download.model

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class PlayerSubtitle(var urlSubtitle:String, val language: String):Parcelable