//
//  AVPlayerExtension.swift
//  Runner
//
//  Created by nguon pisey on 5/8/21.
//


import Foundation
import AVFoundation

extension AVPlayer {
    
    var isPlaying: Bool {
        if (self.rate != 0 && self.error == nil) {
            return true
        } else {
            return false
        }
    }
    
}
