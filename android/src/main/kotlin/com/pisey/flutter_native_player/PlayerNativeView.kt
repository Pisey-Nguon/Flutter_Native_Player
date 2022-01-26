package com.pisey.flutter_native_player

import android.annotation.SuppressLint
import android.content.Context
import android.net.Uri
import android.view.LayoutInflater
import android.view.View
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.offline.DownloadHelper
import com.google.android.exoplayer2.offline.DownloadRequest
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector.ParametersBuilder
import com.google.android.exoplayer2.ui.PlayerView
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.util.Util
import com.pisey.flutter_native_player.constants.Constant
import com.pisey.flutter_native_player.download.download_service.DownloadMethod
import com.pisey.flutter_native_player.download.model.PlayerResource
import com.pisey.flutter_native_player.utils.JsonUtil
import com.pisey.flutter_native_player.utils.PlayerUtil
import com.pisey.flutter_native_player.utils.StreamBuilder
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.util.*

@Suppress("UNCHECKED_CAST")
@SuppressLint("InflateParams")
class PlayerNativeView(private val context: Context,private val binaryMessenger: BinaryMessenger, private val creationParams: Map<String, Any>):PlatformView {
    private val nativeView: View = LayoutInflater.from(context).inflate(R.layout.player_view,null)
    private val playerMethodManager = PlayerMethodManager()
    private val downloadMethod = DownloadMethod(context)
    private var eventChannelPlayer: EventChannel.EventSink? = null
    private var downloadRequest:DownloadRequest? = null
    private var playWhenReady = true
    private lateinit var playerView:PlayerView
    private lateinit var player:ExoPlayer
    private lateinit var dataSourceFactory: DataSource.Factory
    private lateinit var trackSelector:DefaultTrackSelector

    override fun getView(): View {
        return nativeView
    }

    override fun dispose() {
        player.release()
        downloadMethod.removeEventListener()
    }

    private val playerListener = object:Player.Listener{
        override fun onPlaybackStateChanged(state: Int) {
            when(state){
                Player.STATE_READY -> {
                    sendEvent(Constant.EVENT_READY_TO_PLAY,null)
                    if (player.isPlaying){
                        sendEvent(Constant.EVENT_PLAY,null)
                    }else{
                        sendEvent(Constant.EVENT_PAUSE,null)
                    }
                }
                Player.STATE_BUFFERING -> sendEvent(Constant.EVENT_LOADING,null)
                Player.STATE_ENDED -> sendEvent(Constant.EVENT_FINISH,null)
                Player.STATE_IDLE -> {}
            }
        }

        override fun onPlayerError(error: PlaybackException) {
            player.prepare()
        }

        override fun onIsPlayingChanged(isPlaying: Boolean) {
            if (isPlaying){
                sendEvent(Constant.EVENT_PLAY,null)
            }else{
                if(player.currentPosition < player.duration){
                    sendEvent(Constant.EVENT_PAUSE,null)
                }
            }
        }
    }
    private fun sendEvent(eventType:String,valueOfEvent:Any?){
        val data = HashMap<String,Any?>()
        data[Constant.KEY_EVENT_TYPE] = eventType
        data[Constant.KEY_VALUE_OF_EVENT] = valueOfEvent
        eventChannelPlayer?.success(data)
    }

    private fun setupNativeView(){
        trackSelector = DefaultTrackSelector(context)
        trackSelector.parameters = ParametersBuilder(context).setRendererDisabled(C.TRACK_TYPE_VIDEO, true).build()
        dataSourceFactory = PlayerUtil.getDataSourceFactory(context)
        player = ExoPlayer.Builder(context).setTrackSelector(trackSelector).build()
        player.addListener(playerListener)
        playerView = view.findViewById(R.id.playerView)
        playerView.player = player
        playerView.player?.playWhenReady = playWhenReady
    }
    private fun validateDownloadRequest(){
        val playerResourceString = creationParams[Constant.KEY_PLAYER_RESOURCE] as String
        playWhenReady = creationParams[Constant.KEY_PLAY_WHEN_READY] as Boolean
        val map = JsonUtil.jsonToMap(playerResourceString)
        val playerResource = PlayerResource(videoUrl = map["videoUrl"] as String)
        downloadRequest = PlayerUtil.getDownloadTracker(context).getDownloadRequest(Uri.parse(playerResource.videoUrl))

        if (downloadRequest != null){
            val mediaSource = DownloadHelper.createMediaSource(downloadRequest!!,dataSourceFactory)
            mediaSource.let { player.setMediaSource(it) }
        }else{
            val mediaSource = StreamBuilder.buildVideoMediaSource(Uri.parse(playerResource.videoUrl),dataSourceFactory)
            mediaSource.let { player.setMediaSource(it) }
        }
    }

    private fun restart(){
        player.seekTo(0)
        player.playWhenReady = true
    }
    private fun releasePlayer(){
        player.release()
    }


    private fun implementEventFromFlutter(){
        playerMethodManager.methodChannel(binaryMessenger, MethodChannel.MethodCallHandler { call, result ->
            when (call.method) {
                Constant.METHOD_PLAY -> player.play()
                Constant.METHOD_PAUSE -> player.pause()
                Constant.METHOD_SEEK_TO -> player.seekTo((call.arguments as Int).toLong())
                Constant.METHOD_RELEASE_PLAYER -> releasePlayer()
                Constant.METHOD_CHANGE_PLAYBACK_SPEED -> setSpeed((call.arguments as Double))
                Constant.METHOD_CHANGE_QUALITY -> setTrackParameters(call.arguments)
                Constant.METHOD_GET_DURATION_STATE -> setResultCurrentPositionAndBuffer(result)
                Constant.METHOD_START_DOWNLOAD -> startDownloadVideo(call.arguments)
                Constant.METHOD_CANCEL_DOWNLOAD -> cancelDownloadVideo()
                Constant.METHOD_SHOW_DEVICES -> {}
                Constant.METHOD_IS_PLAYING -> result.success(player.isPlaying)
                Constant.METHOD_RESTART -> restart()
            }
        })
        playerMethodManager.eventChannel(binaryMessenger,object :EventChannel.StreamHandler{
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventChannelPlayer = events
                player.prepare()
                downloadMethod.setEventChannelPlayer(eventChannelPlayer)
                if (downloadMethod.isDownloaded(player.currentMediaItem?.localConfiguration?.uri.toString())){
                    val playerResourceJsonString = downloadRequest?.data?.let { Util.fromUtf8Bytes(it) }
                    sendEvent(Constant.EVENT_DOWNLOAD_COMPLETED,playerResourceJsonString)
                }else{
                    sendEvent(Constant.EVENT_DOWNLOAD_NOT_YET,null)
                }
            }

            override fun onCancel(arguments: Any?) {
            }

        })
    }


    private fun setSpeed(value: Double) {
        val bracketedValue = value.toFloat()
        val playbackParameters = PlaybackParameters(bracketedValue)
        player.playbackParameters = playbackParameters
    }

    private fun setTrackParameters(arguments:Any) {
        val data = arguments as HashMap<String,Any>
        val width = data[Constant.KEY_WIDTH] as Int
        val height = data[Constant.KEY_HEIGHT] as Int
        val bitrate = data[Constant.KEY_BITRATE] as Int
        val parametersBuilder: ParametersBuilder = trackSelector.buildUponParameters()
        if (width != 0 && height != 0) {
            parametersBuilder.setMaxVideoSize(width, height)
        }
        if (bitrate != 0) {
            parametersBuilder.setMaxVideoBitrate(bitrate)
        }
        if (width == 0 && height == 0 && bitrate == 0) {
            parametersBuilder.clearVideoSizeConstraints()
            parametersBuilder.setMaxVideoBitrate(Int.MAX_VALUE)
        }
        trackSelector.setParameters(parametersBuilder)
    }
    private fun setResultCurrentPositionAndBuffer(result:MethodChannel.Result){
        val currentPosition = player.currentPosition
        val totalDuration = player.duration
        val bufferUpdate = player.bufferedPosition
        val data = HashMap<String,Any>()
        data[Constant.KEY_CURRENT_POSITION] = currentPosition
        data[Constant.KEY_TOTAL_DURATION] = totalDuration
        data[Constant.KEY_BUFFER_UPDATE] = bufferUpdate
        result.success(data)
    }

    private fun startDownloadVideo(arguments: Any){
        val data = arguments as HashMap<String, Any>
        val trackIndexMovie = data[Constant.KEY_TRACK_INDEX] as Int
        val playerResourceString = data[Constant.KEY_PLAYER_RESOURCE] as String
        val map = JsonUtil.jsonToMap(playerResourceString)
        val playerResource = PlayerResource(videoUrl = map["videoUrl"] as String)
        downloadMethod.startDownload(playerResource,trackIndexMovie)
    }
    private fun cancelDownloadVideo(){
        downloadMethod.cancelDownload()
    }

    init {
        implementEventFromFlutter()
        setupNativeView()
        validateDownloadRequest()
    }

}