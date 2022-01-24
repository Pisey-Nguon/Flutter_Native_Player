//
//  DownloadManager.swift
//  Runner
//
//  Created by nguon pisey on 6/8/21.
//

///Pending this feature
//import Foundation
//import AVKit
//
//class DownloadManager:NSObject,AVAssetDownloadDelegate {
//    var configuration: URLSessionConfiguration?
//        var downloadSession: AVAssetDownloadURLSession?
//        var downloadIdentifier = "\(Bundle.main.bundleIdentifier!).background"
//
//    private var downloadTask:AVAssetDownloadTask?
//    private var titleMovie:String?
//    private var playerMethodManager:PlayerMethodManager
//
//    init(playerMethodManager:PlayerMethodManager) {
//        self.playerMethodManager = playerMethodManager
//    }
//
//    func setupAssetDownload(videoUrl: String,titleMovie:String,bitrate:Int) {
//        // Create new background session configuration.
//        configuration = URLSessionConfiguration.background(withIdentifier: downloadIdentifier)
//
//        // Create a new AVAssetDownloadURLSession with background configuration, delegate, and queue
//        downloadSession = AVAssetDownloadURLSession(configuration: configuration!,
//                                                    assetDownloadDelegate: self,
//                                                    delegateQueue: OperationQueue.main)
//
//
//        if let url = URL(string: videoUrl){
//            let asset = AVURLAsset(url: url)
//
//            // Create new AVAssetDownloadTask for the desired asset
//            if #available(iOS 10.0, *) {
//                downloadTask = downloadSession?.makeAssetDownloadTask(asset: asset,
//                                                                          assetTitle: titleMovie,
//                                                                          assetArtworkData: nil,
//                                                                          options: [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: bitrate])
//                downloadTask?.resume()
//                print("flutterPlayerIOS start download \(bitrate)")
//
//            }
//            // Start task and begin download
//
//        }
//    }
//    func resumeAssetDownload() {
//        downloadTask?.resume()
//    }
//    func pauseAssetDownload() {
//        downloadTask?.suspend()
//    }
//
//    func cancelAssetDownload() {
//        downloadTask?.cancel()
//    }
//
//    func deleteOfflineAsset(titleMovie:String) {
//        do {
//            let userDefaults = UserDefaults.standard
//            if let assetPath = userDefaults.value(forKey: titleMovie) as? String {
//                let baseURL = URL(fileURLWithPath: NSHomeDirectory())
//                let assetURL = baseURL.appendingPathComponent(assetPath)
//                try FileManager.default.removeItem(at: assetURL)
//                userDefaults.removeObject(forKey: titleMovie)
//            }
//        } catch {
//            print("An error occured deleting offline asset: \(error)")
//        }
//    }
//
//
//    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
//        // Do not move the asset from the download location
//        UserDefaults.standard.set(location.relativePath, forKey: titleMovie ?? "")
//        print("flutterPlayerIOS download completed name => \(location.relativePath) , tittleMovie => \(titleMovie)")
//    }
//
//    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
//        var percentComplete = 0.0
//        // Iterate through the loaded time ranges
//        for value in loadedTimeRanges {
//            // Unwrap the CMTimeRange from the NSValue
//            let loadedTimeRange = value.timeRangeValue
//            // Calculate the percentage of the total expected asset duration
//            percentComplete += loadedTimeRange.duration.seconds / timeRangeExpectedToLoad.duration.seconds
//        }
//        percentComplete *= 100
//        // Update UI state: post notification, update KVO state, invoke callback, etc.
//        print("flutterPlayerIOS percentageDownload \(percentComplete)")
//
//    }
//    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
//        print("flutterPlayerIOS didBecomeInvalidWithError \(error?.localizedDescription)")
//    }
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        print("flutterPlayerIOS didCompleteWithError \(error?.localizedDescription)")
//    }
//
//}
