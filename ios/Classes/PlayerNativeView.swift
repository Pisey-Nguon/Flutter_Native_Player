//
//  PlayerNativeView.swift
//  Runner
//
//  Created by nguon pisey on 2/8/21.
//

import Foundation
import Flutter
import AVKit
import UIKit
import AVFoundation

class PlayerNativeView: NSObject,FlutterPlatformView {
    let frame: CGRect;
    let viewId: Int64;
    let messenger:FlutterBinaryMessenger
    var playerItem: AVPlayerItem!
    var playWhenReady:Bool = true
    let playerMethodManager = PlayerMethodManager()


    init(_ frame: CGRect,viewID: Int64,messenger:FlutterBinaryMessenger,args :Any?) {
        self.frame = frame
        self.viewId = viewID
        self.messenger = messenger
        if(args is NSDictionary){
            let dict = args as! NSDictionary
            let playerResourceJsonString = dict.value(forKey: Constant.KEY_PLAYER_RESOURCE) as! String
            playWhenReady = dict.value(forKey: Constant.KEY_PLAY_WHEN_READY) as! Bool
            let playerResource = try! JSONDecoder().decode(PlayerResource.self, from: Data(playerResourceJsonString.utf8))
            playerItem = AVPlayerItem(url: URL(string: playerResource.videoUrl)!)
        }
    
    }
    
    
    func view() -> UIView {
        let frameLayout = CGRect()
        let player = PlayerView(frame: frameLayout, playerItem: playerItem!,playerMethodManager: playerMethodManager, binaryMessenger: messenger)
        player.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        player.playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        if playWhenReady{
            player.play()
        }
        return player
    }
}
