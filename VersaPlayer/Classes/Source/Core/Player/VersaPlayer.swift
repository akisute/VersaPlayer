//
//  VersaPlayer.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import AVFoundation

open class VersaPlayer: AVPlayer, AVAssetResourceLoaderDelegate {
    
    /// Dispatch queue for resource loader
    private let queue = DispatchQueue(label: "quasar.studio.versaplayer")
    
    /// VersaPlayer instance
    public weak var handler: VersaPlayerView?
    
    /// Caption text style rules
    lazy public private(set) var captionStyling: VersaPlayerCaptionStyling = {
        return VersaPlayerCaptionStyling(with: self)
    }()
    
    /// Whether player is buffering
    public var isBuffering: Bool = false
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemTimeJumped, object: self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self)
    }
    
    /// Play content
    override open func play() {
        handler?.playbackDelegate?.playbackWillBegin(player: self)
        if !(handler?.playbackDelegate?.playbackShouldBegin(player: self) ?? true) {
            return
        }
        super.play()
        handler?.playbackDelegate?.playbackDidBegin(player: self)
        handler?.controls?.onPlay()
    }
    
    /// Pause content
    override open func pause() {
        super.pause()
        handler?.controls?.onPause()
    }
    
    /// Replace current item with a new one
    ///
    /// - Parameters:
    ///     - item: AVPlayer item instance to be added
    override open func replaceCurrentItem(with item: AVPlayerItem?) {
        if let asset = item?.asset as? AVURLAsset, let vitem = item as? VersaPlayerItem, vitem.isEncrypted {
            asset.resourceLoader.setDelegate(self, queue: queue)
        }
        
        if currentItem != nil {
            currentItem!.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            currentItem!.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            currentItem!.removeObserver(self, forKeyPath: "playbackBufferFull")
            currentItem!.removeObserver(self, forKeyPath: "status")
        }
        
        super.replaceCurrentItem(with: item)
        
        if item != nil {
            currentItem!.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            currentItem!.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
            currentItem!.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
            currentItem!.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        }
    }
    
}

extension VersaPlayer {
    
    /// Start time
    ///
    /// - Returns: Player's current item start time as CMTime
    open func startTime() -> CMTime {
        guard let item = currentItem else {
            return CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        }
        
        if item.reversePlaybackEndTime.isValid {
            return item.reversePlaybackEndTime
        }else {
            return CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        }
    }
    
    /// End time
    ///
    /// - Returns: Player's current item end time as CMTime
    open func endTime() -> CMTime {
        guard let item = currentItem else {
            return CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        }
        
        if item.forwardPlaybackEndTime.isValid {
            return item.forwardPlaybackEndTime
        }else {
            if item.duration.isValid && !item.duration.isIndefinite {
                return item.duration
            }else {
                return item.currentTime()
            }
        }
    }
    
    /// Prepare players playback delegate observers
    open func preparePlayerPlaybackDelegate() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let self = self else { return }
            self.handler?.playbackDelegate?.playbackDidEnd(player: self)
            self.handler?.controls?.onPlaybackEnded()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemTimeJumped, object: self, queue: OperationQueue.main) { [weak self] (notification) in
            guard let self = self else { return }
            self.handler?.playbackDelegate?.playbackDidJump(player: self)
            self.handler?.controls?.onTimeChanged(toTime: self.currentTime()) // may or may not be needed...
        }
        addPeriodicTimeObserver(
            forInterval: CMTime(
                seconds: 1,
                preferredTimescale: CMTimeScale(NSEC_PER_SEC)
            ),
            queue: DispatchQueue.main) { [weak self] (time) in
                guard let self = self else { return }
                self.handler?.playbackDelegate?.playbackTimeDidChange(player: self, to: time)
                self.handler?.controls?.onTimeChanged(toTime: time)
        }
        addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    /// Value observer
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? VersaPlayer, obj == self {
            if keyPath == "status" {
                switch status {
                case AVPlayer.Status.readyToPlay:
                    handler?.playbackDelegate?.playbackReady(player: self)
                case AVPlayer.Status.failed:
                    // TODO: get an error reason from the player!
                    handler?.playbackDelegate?.playbackDidFailed(with: .unknown)
                    handler?.controls?.onPlaybackFailed(error: VersaPlayerPlaybackError.unknown)
                default:
                    break;
                }
            }
        }else {
            switch keyPath ?? "" {
            case "status":
                if let value = change?[.newKey] as? Int, let status = AVPlayerItem.Status(rawValue: value), let item = object as? AVPlayerItem {
                    if status == .failed, let error = item.error as NSError?, let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
                        let playbackError: VersaPlayerPlaybackError
                        switch underlyingError.code {
                        case -12937:
                            playbackError = .authenticationError
                        case -16840:
                            playbackError = .unauthorized
                        case -12660:
                            playbackError = .forbidden
                        case -12938:
                            playbackError = .notFound
                        case -12661:
                            playbackError = .unavailable
                        case -12645, -12889:
                            playbackError = .mediaFileError
                        case -12318:
                            playbackError = .bandwidthExceeded
                        case -12642:
                            playbackError = .playlistUnchanged
                        case -12911:
                            playbackError = .decoderMalfunction
                        case -12913:
                            playbackError = .decoderTemporarilyUnavailable
                        case -1004:
                            playbackError = .wrongHostIP
                        case -1003:
                            playbackError = .wrongHostDNS
                        case -1000:
                            playbackError = .badURL
                        case -1202:
                            playbackError = .invalidRequest
                        default:
                            playbackError = .unknown
                        }
                        handler?.playbackDelegate?.playbackDidFailed(with: playbackError)
                        handler?.controls?.onPlaybackFailed(error: playbackError)
                    }
                }
            case "playbackBufferEmpty":
                isBuffering = true
                handler?.playbackDelegate?.startBuffering(player: self)
                handler?.controls?.onStartBuffering()
            case "playbackLikelyToKeepUp":
                isBuffering = false
                handler?.playbackDelegate?.endBuffering(player: self)
                handler?.controls?.onEndBuffering()
            case "playbackBufferFull":
                isBuffering = false
                handler?.playbackDelegate?.endBuffering(player: self)
                handler?.controls?.onEndBuffering()
            default:
                break;
            }
        }
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url else {
            print("VersaPlayerResourceLoadingError", #function, "Unable to read the url/host data.")
            loadingRequest.finishLoading(with: NSError(domain: "quasar.studio.error", code: -1, userInfo: nil))
            return false
        }
        
        print("VersaPlayerResourceLoading: \(url)")
        
        guard
            let certificateURL = handler?.decryptionDelegate?.urlFor(player: self),
            let certificateData = try? Data(contentsOf: certificateURL) else {
                print("VersaPlayerResourceLoadingError", #function, "Unable to read the certificate data.")
                loadingRequest.finishLoading(with: NSError(domain: "quasar.studio.error", code: -2, userInfo: nil))
                return false
        }
        
        let contentId = handler?.decryptionDelegate?.contentIdFor(player: self) ?? ""
        guard
            let contentIdData = contentId.data(using: String.Encoding.utf8),
            let spcData = try? loadingRequest.streamingContentKeyRequestData(forApp: certificateData, contentIdentifier: contentIdData, options: nil),
            let dataRequest = loadingRequest.dataRequest else {
                loadingRequest.finishLoading(with: NSError(domain: "quasar.studio.error", code: -3, userInfo: nil))
                print("VersaPlayerResourceLoadingError", #function, "Unable to read the SPC data.")
                return false
        }
        
        guard let ckcURL = handler?.decryptionDelegate?.contentKeyContextURLFor(player: self) else {
            loadingRequest.finishLoading(with: NSError(domain: "quasar.studio.error", code: -4, userInfo: nil))
            print("VersaPlayerResourceLoadingError", #function, "Unable to read the ckcURL.")
            return false
        }
        var request = URLRequest(url: ckcURL)
        request.httpMethod = "POST"
        request.httpBody = spcData
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                dataRequest.respond(with: data)
                loadingRequest.finishLoading()
            } else {
                print("VersaPlayerResourceLoadingError", #function, "Unable to fetch the CKC.")
                loadingRequest.finishLoading(with: NSError(domain: "quasar.studio.error", code: -5, userInfo: nil))
            }
        }
        task.resume()
        
        return true
    }
    
}
