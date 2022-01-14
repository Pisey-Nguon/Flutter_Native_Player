package com.pisey.flutter_native_player.download.model

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class PlayerResource(val mediaName:String, val mediaUrl:String,var subtitles:ArrayList<PlayerSubtitle> = ArrayList()):Parcelable
