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
    var avplayer: AVPlayer? {
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
    
    ///Pending this feature
//    private var downloadManager:DownloadManager?
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
        avplayer?.play()
        avplayer?.rate = rate
        wasPlaying = true
    }
    
    func pause() {
        avplayer?.pause()
        wasPlaying = false
    }
    
    func restart(){
        seek(to: 0)
        avplayer?.play()
    }
    func seek(to location: Int) {
        avplayer?.seek(
            to: CMTimeMake(value: Int64(location), timescale: 1000),
            toleranceBefore: .zero,
            toleranceAfter: .zero) { finished in
            if self.wasPlaying == true{
                self.avplayer?.rate = self.rate
            }
            }
    }
    func setPlaybackSpeed(to speed:Double) {
        avplayer?.rate = Float(speed)
        if wasPlaying == false {
            avplayer?.pause()
        }
    }
    func setTrackParameter(urlQuality:String) {
        let avPlayerItem = AVPlayerItem(url: URL(string: urlQuality)!)
        avplayer?.replaceCurrentItem(with: avPlayerItem)
        avplayer?.seek(to: currentPosition)
        avplayer?.rate = rate
    }
    
    ///Use to send event to flutter
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
        for rangeValue in avplayer!.currentItem!.loadedTimeRanges {
            let range = rangeValue.timeRangeValue
            let start = BetterPlayerTimeUtils.fltcmTime(toMillis: (range.start))
            var end = start + BetterPlayerTimeUtils.fltcmTime(toMillis: (range.duration))
            if !CMTIME_IS_INVALID(avplayer!.currentItem!.forwardPlaybackEndTime) {
                let endTime = BetterPlayerTimeUtils.fltcmTime(toMillis: (avplayer!.currentItem!.forwardPlaybackEndTime))
                if end > endTime {
                    end = endTime
                }
            }
            bufferPosition = end
        }
        return bufferPosition
    }
    
    func validateEventIsPlay(){
        if self.avplayer?.isPlaying == true{
            self.sendEvent(eventType: Constant.EVENT_PLAY, valueOfEvent: nil)
        }else{
            if avplayer?.currentItem?.isPlaybackBufferFull == false{
                self.sendEvent(eventType: Constant.EVENT_PAUSE, valueOfEvent: nil)
            }
        }
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
            
        case Constant.METHOD_RESTART:
            restart()
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
            let currentPositionMs = Int(CMTimeConvertScale(avplayer?.currentTime() ?? CMTime.init(), timescale: 1000, method: CMTimeRoundingMethod.roundHalfAwayFromZero).value)
            let totalDurationMs = Int(CMTimeConvertScale(avplayer?.currentItem?.duration ?? CMTime.init(), timescale: 1000, method: CMTimeRoundingMethod.roundHalfAwayFromZero).value)
            currentPosition = avplayer?.currentTime() ?? CMTime.init()
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
        case Constant.METHOD_IS_PLAYING:
            result(avplayer?.isPlaying)
            break
        default:
            break
        }
    }
 
    
    func setupAVPlayer(){
        playerMethodManager.methodChannel(binaryMessenger: binaryMessenger, handler:methodHandler(call:result:))
        playerMethodManager.eventChannelPlayer(binaryMessenger: binaryMessenger,handler: self)
        
        ///Pending this feature
//        downloadManager = DownloadManager(playerMethodManager: playerMethodManager)
        avplayer = AVPlayer(playerItem: playerItem)
        ///This observe can use if nessessary
        avplayer?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: NSKeyValueObservingOptions.new, context: nil)
        avplayer?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        
        NotificationCenter.default.addObserver(self,
                         selector: #selector(self.endPlay),
                         name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                         object: avplayer?.currentItem)
        
        playerItemBufferEmptyObserver = avplayer?.currentItem?.observe(\AVPlayerItem.isPlaybackBufferEmpty, options: [.new]) { [weak self] (_, _) in
            guard let self = self else { return }
            self.sendEvent(eventType: Constant.EVENT_LOADING, valueOfEvent: nil)
        }
            
        playerItemBufferKeepUpObserver = avplayer?.currentItem?.observe(\AVPlayerItem.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] (_, _) in
            guard let self = self else { return }
            self.sendEvent(eventType: Constant.EVENT_READY_TO_PLAY, valueOfEvent: nil)
        }
            
        playerItemBufferFullObserver = avplayer?.currentItem?.observe(\AVPlayerItem.isPlaybackBufferFull, options: [.new]) { [weak self] (_, _) in
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
        validateEventIsPlay()
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath{
            
        case #keyPath(AVPlayerItem.status):
            switch avplayer?.status {
            case .readyToPlay:
                sendEvent(eventType: Constant.EVENT_READY_TO_PLAY, valueOfEvent: nil)
                break
            case .failed:
                
                break
            case .unknown:
                break
            
            default: break
                
            }
            break
            
        case "rate":
            rate = avplayer?.rate ?? 1
            validateEventIsPlay()
        
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
