package com.pisey.flutter_native_player.download.model

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class PlayerResource(val videoUrl:String, var playerSubtitleResources:ArrayList<PlayerSubtitleResource> = ArrayList()):Parcelable
