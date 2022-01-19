//
//  BetterPlayerTimeUtils.swift
//  Runner
//
//  Created by nguon pisey on 9/8/21.
//

import Foundation
class BetterPlayerTimeUtils {
    class func fltcmTime(toMillis time: CMTime) -> Int64 {
        if time.timescale == 0 {
            return 0
        }
        return Int64((Int64(time.value) * 1000) / Int64(time.timescale))
    }

    class func fltnsTimeInterval(toMillis interval: TimeInterval) -> Int64 {
        return Int64(interval * 1000.0)
    }
}
