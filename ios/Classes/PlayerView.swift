//
//  Player.swift
//  Runner
//
//  Created by nguon pisey on 3/8/21.
//


import Foundation
import AVFoundation
import UIKit
import MediaPlayer

class PlayerView: UIView,FlutterStreamHandler {
    let TAG:String = "flutterPlayerIOS"
    var avPlayer: AVPlayer? {
        get {
            return playerLayer?.player
        }
        set {
            playerLayer?.player = newValue
        }
    }

    private(set) var playerItem: AVPlayerItem
    var playerLayer: AVPlayerLayer? {
        return layer as? AVPlayerLayer
    }
    private var eventChannelPlayerSink :FlutterEventSink?

    private(set) var playerMethodManager:PlayerMethodManager
    private(set) var binaryMessenger:FlutterBinaryMessenger
    private var downloadManager:DownloadManager?
    private var rate:Float = 1
    private var currentPosition = CMTime.init()
    private var wasPlaying:Bool = false
    private var currentStatusLoading = false
    private var playerItemBufferEmptyObserver: NSKeyValueObservation?
    private var playerItemBufferKeepUpObserver: NSKeyValueObservation?
    private var playerItemBufferFullObserver: NSKeyValueObservation?
    public static override var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    init(frame: CGRect, playerItem: AVPlayerItem,playerMethodManager:PlayerMethodManager,binaryMessenger:FlutterBinaryMessenger) {
        self.playerItem = playerItem
        self.playerMethodManager = playerMethodManager
        self.binaryMessenger = binaryMessenger
        super.init(frame: frame)
        self.setupAVPlayer()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func play() {
        avPlayer?.play()
        avPlayer?.rate = rate
        wasPlaying = true
    }
    
    func pause() {
        avPlayer?.pause()
        wasPlaying = false
    }
    func seek(to location: Int) {
        ///When player is playing, pause video, seek to new position and start again. This will prevent issues with seekbar jumps.
//        if wasPlaying == true {
//            avPlayer?.pause()
//        }

        avPlayer?.seek(
            to: CMTimeMake(value: Int64(location), timescale: 1000),
            toleranceBefore: .zero,
            toleranceAfter: .zero) { finished in
            if self.wasPlaying == true{
                self.avPlayer?.rate = self.rate
            }
            }
    }
    func setPlaybackSpeed(to speed:Double) {
        avPlayer?.rate = Float(speed)
        if wasPlaying == false {
            avPlayer?.pause()
        }
    }
    func setTrackParameter(urlQuality:String) {
        let avPlayerItem = AVPlayerItem(url: URL(string: urlQuality)!)
        avPlayer?.replaceCurrentItem(with: avPlayerItem)
        avPlayer?.seek(to: currentPosition)
        avPlayer?.rate = rate
    }
    
    func sendEvent(eventType:String,valueOfEvent:Any?){
        var data = Dictionary<String,Any>()
        data[Constant.KEY_EVENT_TYPE] = eventType
        data[Constant.KEY_VALUE_OF_EVENT] = valueOfEvent
        if eventChannelPlayerSink != nil {
            eventChannelPlayerSink!(data)
        }
    }
    
    func getBuffer() -> Int64{
        var bufferPosition:Int64 = 0
        for rangeValue in avPlayer!.currentItem!.loadedTimeRanges {
            let range = rangeValue.timeRangeValue
            let start = BetterPlayerTimeUtils.fltcmTime(toMillis: (range.start))
            var end = start + BetterPlayerTimeUtils.fltcmTime(toMillis: (range.duration))
            if !CMTIME_IS_INVALID(avPlayer!.currentItem!.forwardPlaybackEndTime) {
                let endTime = BetterPlayerTimeUtils.fltcmTime(toMillis: (avPlayer!.currentItem!.forwardPlaybackEndTime))
                if end > endTime {
                    end = endTime
                }
            }
            bufferPosition = end
        }
        return bufferPosition
    }
    func methodHandler(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void{
        // Note: this method is invoked on the UI thread.
        switch call.method{
        case Constant.METHOD_PLAY:
            play()
            break
            
        case Constant.METHOD_PAUSE:
            pause()
            break
        case Constant.METHOD_SEEK_TO:
            let positionMs = call.arguments as! Int
            seek(to: positionMs)
            break
        case Constant.METHOD_CHANGE_PLAYBACK_SPEED:
            let speed = call.arguments as! Double
            setPlaybackSpeed(to: speed)
            break
            
        case Constant.METHOD_CHANGE_QUALITY:
            let itemQualityHashMap = call.arguments as! Dictionary<String, Any>
            let urlQuality = itemQualityHashMap[Constant.KEY_URL_QUALITY] as! String
            setTrackParameter(urlQuality: urlQuality)
            break
            
        case Constant.METHOD_GET_DURATION_STATE:
            let currentPositionMs = Int(CMTimeConvertScale(avPlayer?.currentTime() ?? CMTime.init(), timescale: 1000, method: CMTimeRoundingMethod.roundHalfAwayFromZero).value)
            let totalDurationMs = Int(CMTimeConvertScale(avPlayer?.currentItem?.duration ?? CMTime.init(), timescale: 1000, method: CMTimeRoundingMethod.roundHalfAwayFromZero).value)
            currentPosition = avPlayer?.currentTime() ?? CMTime.init()
            var data = Dictionary<String,Any>()
            let bufferUpdate = getBuffer()
            data[Constant.KEY_CURRENT_POSITION] = currentPositionMs
            data[Constant.KEY_BUFFER_UPDATE] = bufferUpdate
            data[Constant.KEY_TOTAL_DURATION] = totalDurationMs
            result(data)
            break

        case Constant.METHOD_START_DOWNLOAD:
            ///Pending this feature
//            let data = call.arguments as! Dictionary<String,Any>
//            let urlQuality = data[Constant.KEY_URL_QUALITY] as! String
//            let titleMovie = data[Constant.KEY_TITLE_MOVIE] as! String
//            let bitrate = data[Constant.KEY_BITRATE] as! Int
//            downloadManager?.setupAssetDownload(videoUrl: urlQuality, titleMovie: titleMovie,bitrate: bitrate)
            break
        default:
            break
        }
    }
 
    
    func setupAVPlayer(){
        playerMethodManager.methodChannel(binaryMessenger: binaryMessenger, handler:methodHandler(call:result:))
        playerMethodManager.eventChannelPlayer(binaryMessenger: binaryMessenger,handler: self)
        downloadManager = DownloadManager(playerMethodManager: playerMethodManager)
        avPlayer = AVPlayer(playerItem: playerItem)
        
        ///This observe can use if nessessary
//        avPlayer?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: NSKeyValueObservingOptions.new, context: nil)
        avPlayer?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        
        NotificationCenter.default.addObserver(self,
                         selector: #selector(self.endPlay),
                         name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                         object: avPlayer?.currentItem)
        
        playerItemBufferEmptyObserver = avPlayer?.currentItem?.observe(\AVPlayerItem.isPlaybackBufferEmpty, options: [.new]) { [weak self] (_, _) in
            guard let self = self else { return }
            print("checkStatus Show Loading")
            self.sendEvent(eventType: Constant.EVENT_BUFFERING, valueOfEvent: nil)
        }
            
        playerItemBufferKeepUpObserver = avPlayer?.currentItem?.observe(\AVPlayerItem.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] (_, _) in
            guard let self = self else { return }
            self.sendEvent(eventType: Constant.EVENT_READY_TO_PLAY, valueOfEvent: nil)
        }
            
        playerItemBufferFullObserver = avPlayer?.currentItem?.observe(\AVPlayerItem.isPlaybackBufferFull, options: [.new]) { [weak self] (_, _) in
            guard let self = self else { return }
            self.sendEvent(eventType: Constant.EVENT_READY_TO_PLAY, valueOfEvent: nil)
        }
     
    }
    @objc func endPlay(){
        sendEvent(eventType: Constant.EVENT_FINISH, valueOfEvent: nil)
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if eventChannelPlayerSink == nil {
            eventChannelPlayerSink = events
        }
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath{
            
        case #keyPath(AVPlayerItem.status): break
            
        case "rate":
            rate = avPlayer?.rate ?? 1
            if avPlayer?.isPlaying == true {
                sendEvent(eventType: Constant.EVENT_PLAY,valueOfEvent: nil)
            }else{
                if avPlayer?.currentItem?.duration.seconds != avPlayer?.currentItem?.currentTime().seconds{
                    sendEvent(eventType: Constant.EVENT_PAUSE, valueOfEvent: nil)
                }
            
            }
        
            break
        case "playbackBufferEmpty":
            print("isPlaybackBufferEmpty")
            break
        case #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp):
            print(TAG, "isPlaybackLikelyToKeepUp")
            break
        case #keyPath(AVPlayerItem.isPlaybackBufferFull):
            print(TAG, "isPlaybackBufferFull")
            break
        case .none:
            break
        case .some(_):
            break
        }
    
    }
    

    // Remove Observer
    deinit {
        NotificationCenter.default.removeObserver(self)
        playerItemBufferEmptyObserver?.invalidate()
        playerItemBufferEmptyObserver = nil
            
        playerItemBufferKeepUpObserver?.invalidate()
        playerItemBufferKeepUpObserver = nil
            
        playerItemBufferFullObserver?.invalidate()
        playerItemBufferFullObserver = nil
    }
}
