package com.pisey.flutter_native_player

import android.annotation.SuppressLint
import android.content.Context
import android.net.Uri
import android.view.LayoutInflater
import android.view.View
import com.pisey.flutter_native_player.download_hls.MethodDownload
import com.pisey.flutter_native_player.download_hls.StreamBuilder
import com.google.android.exoplayer2.ExoPlaybackException
import com.google.android.exoplayer2.PlaybackParameters
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.SimpleExoPlayer
import com.google.android.exoplayer2.offline.DownloadHelper
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector.ParametersBuilder
import com.google.android.exoplayer2.ui.PlayerView
import com.google.android.exoplayer2.upstream.DataSource
import com.pisey.flutter_native_player.download_hls.DemoUtil

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

@Suppress("UNCHECKED_CAST")
@SuppressLint("InflateParams")
class PlayerNativeView(private val context: Context,private val id: Int,private val binaryMessenger: BinaryMessenger, private val creationParams: Map<String, Any>):PlatformView {
    private val nativeView: View = LayoutInflater.from(context).inflate(R.layout.player_view,null)
    private val playerMethodManager = PlayerMethodManager()
    private val methodDownload = MethodDownload(context)
    private var eventChannelPlayer: EventChannel.EventSink? = null
    private lateinit var foregroundPlayer:View
    private lateinit var playerView:PlayerView
    private lateinit var player:SimpleExoPlayer
    private lateinit var dataSourceFactory: DataSource.Factory
    private lateinit var trackSelector:DefaultTrackSelector

    override fun getView(): View {
        return nativeView
    }

    override fun dispose() {
        player.release()
        methodDownload.removeEventListener()
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
                Player.STATE_BUFFERING -> sendEvent(Constant.EVENT_BUFFERING,null)
                Player.STATE_ENDED -> sendEvent(Constant.EVENT_FINISH,null)
                Player.STATE_IDLE -> {}
            }
        }

        override fun onPlayerError(error: ExoPlaybackException) {
            player.prepare()
        }

        override fun onIsPlayingChanged(isPlaying: Boolean) {
            if (isPlaying){
                sendEvent(Constant.EVENT_PLAY,null)
            }else{
                sendEvent(Constant.EVENT_PAUSE,null)
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
        dataSourceFactory = DemoUtil.getDataSourceFactory(context)
        player = SimpleExoPlayer.Builder(context).setTrackSelector(trackSelector).build()
        player.addListener(playerListener)
        foregroundPlayer = view.findViewById(R.id.foregroundPlayer)
        playerView = view.findViewById(R.id.playerView)
        playerView.player = player
        playerView.player?.playWhenReady = true
    }
    private fun validateDownloadRequest(){
        val url = Uri.parse(creationParams[Constant.MP_URL_STREAMING] as String)
        val downloadRequest = DemoUtil.getDownloadTracker(context).getDownloadRequest(url)

        if (downloadRequest != null){
            val mediaSource = DownloadHelper.createMediaSource(downloadRequest,dataSourceFactory)
            mediaSource.let { player.setMediaSource(it) }
        }else{
            val mediaSource = StreamBuilder.buildVideoMediaSource(url,dataSourceFactory)
            mediaSource?.let { player.setMediaSource(it) }
        }
    }
    private fun releasePlayer(){
        player.release()
        foregroundPlayer.visibility = View.VISIBLE
    }
    private fun reInitPlayer(){
        foregroundPlayer.visibility = View.GONE
        setupNativeView()
        validateDownloadRequest()
        player.prepare()
    }


    private fun implementEventFromFlutter(){
        playerMethodManager.methodChannel(binaryMessenger, MethodChannel.MethodCallHandler { call, result ->
            when(call.method){
                Constant.METHOD_PLAY -> {
                    player.play()
                }
                Constant.METHOD_PAUSE -> {
                    player.pause()
                }
                Constant.METHOD_SEEK_TO -> {
                    player.seekTo((call.arguments as Int).toLong())
                }
                Constant.METHOD_RELEASE_PLAYER -> releasePlayer()
                Constant.METHOD_INIT_PLAYER -> reInitPlayer()
                Constant.METHOD_CHANGE_PLAYBACK_SPEED -> setSpeed((call.arguments as Double))
                Constant.METHOD_CHANGE_QUALITY -> setTrackParameters(call.arguments)
                Constant.METHOD_GET_DURATION_STATE -> setResultCurrentPositionAndBuffer(result)
                Constant.METHOD_START_DOWNLOAD -> startDownloadVideo(call.arguments)
                Constant.METHOD_CANCEL_DOWNLOAD -> cancelDownloadVideo()
                Constant.METHOD_SHOW_DEVICES -> {}
            }
        })
        playerMethodManager.eventChannel(binaryMessenger,object :EventChannel.StreamHandler{
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventChannelPlayer = events
                player.prepare()
                methodDownload.setEventChannelPlayer(eventChannelPlayer)
                if (methodDownload.isDownloaded(player.currentMediaItem?.playbackProperties?.uri.toString())){
                    sendEvent(Constant.EVENT_DOWNLOAD_COMPLETED,null)
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
        val urlMovie = data[Constant.KEY_URL_MOVIE] as String
        val trackIndexMovie = data[Constant.KEY_TRACK_INDEX] as Int
        methodDownload.startDownload(urlMovie,trackIndexMovie)
    }
    private fun cancelDownloadVideo(){
        methodDownload.cancelDownload()
    }

    init {
        implementEventFromFlutter()
        setupNativeView()
        validateDownloadRequest()
    }

}