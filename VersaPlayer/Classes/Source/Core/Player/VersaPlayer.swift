//
//  VersaPlayer.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import AVFoundation

open class VersaPlayer: AVPlayer {
    
    /// Dispatch queue for resource loader
    private let queue = DispatchQueue(label: "quasar.studio.versaplayer")
    
    /// VersaPlayer instance
    public private(set) weak var handler: VersaPlayerView?
    
    /// Caption text style rules
    lazy public private(set) var captionStyling: VersaPlayerCaptionStyling = {
        return VersaPlayerCaptionStyling(with: self)
    }()
    
    /// Whether player is buffering
    public private(set) var isBuffering: Bool = false
    
    /// The periodic time observer token, which is returned from `addPeriodicTimeObserver(forInterval:queue:using:)` for later use.
    private var periodicTimeObserver: Any?
    
    deinit {
        disposePlayerItemObservers()
        disposePlayerObservers()
    }
    
    init(handler: VersaPlayerView) {
        super.init()
        self.handler = handler
        self.preparePlayerObservers()
    }
    
}

// MARK: - Public

extension VersaPlayer {
    
    /// Play content
    override open func play() {
        if !(handler?.playbackDelegate?.playbackShouldBegin(player: self) ?? true) {
            return
        }
        super.play()
        handler?.playbackDelegate?.playbackDidBegin(player: self)
        handler?.controls?.onPlay()
    }
    
    /// Pause content
    override open func pause() {
        handler?.playbackDelegate?.playbackWillPause(player: self)
        super.pause()
        handler?.playbackDelegate?.playbackDidPause(player: self)
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
        disposePlayerItemObservers()
        super.replaceCurrentItem(with: item)
        preparePlayerItemObservers()
    }
    
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
    
}

// MARK: - Private

extension VersaPlayer {
    
    private func preparePlayerObservers() {
        periodicTimeObserver = addPeriodicTimeObserver(
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
    
    private func disposePlayerObservers() {
        if let observer = periodicTimeObserver {
            removeTimeObserver(observer)
        }
        
        removeObserver(self, forKeyPath: "status")
    }
    
    private func preparePlayerItemObservers() {
        guard let item = currentItem else { return }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item, queue: OperationQueue.main) { [weak self] (notification) in
            guard let self = self else { return }
            self.handler?.playbackDelegate?.playbackDidEnd(player: self)
            self.handler?.controls?.onPlaybackEnded()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemTimeJumped, object: item, queue: OperationQueue.main) { [weak self] (notification) in
            guard let self = self else { return }
            self.handler?.playbackDelegate?.playbackDidJump(player: self)
            self.handler?.controls?.onTimeChanged(toTime: self.currentTime()) // may or may not be needed...
        }
        
        item.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
    }
    
    private func disposePlayerItemObservers() {
        guard let item = currentItem else { return }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemTimeJumped, object: item)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        item.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        item.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        item.removeObserver(self, forKeyPath: "playbackBufferFull")
        item.removeObserver(self, forKeyPath: "status")
    }
    
    /// Value observer
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? VersaPlayer, obj == self {
            switch keyPath ?? "" {
            case "status":
                switch status {
                case AVPlayer.Status.unknown:
                    break
                case AVPlayer.Status.readyToPlay:
                    handler?.playbackDelegate?.playbackPlayerIsReady(player: self)
                case AVPlayer.Status.failed:
                    // `error` should always be available when `.failed`, but for some safety reason...
                    if let error = error {
                        handler?.playbackDelegate?.playbackPlayerDidFail(player: self, error: error)
                        handler?.controls?.onPlaybackFailed(error: error)
                    }
                @unknown default:
                    break
                }
            default:
                break
            }
        } else if let obj = object as? AVPlayerItem {
            switch keyPath ?? "" {
            case "status":
                if let value = change?[.newKey] as? Int, let status = AVPlayerItem.Status(rawValue: value) {
                    switch status {
                    case .unknown:
                        break
                    case .readyToPlay:
                        handler?.playbackDelegate?.playbackItemIsReady(player: self)
                    case .failed:
                        // `error` should always be available when `.failed`, but for some safety reason...
                        if let error = obj.error as NSError?, let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
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
                            handler?.playbackDelegate?.playbackItemDidFail(player: self, error: playbackError)
                            handler?.controls?.onPlaybackFailed(error: playbackError)
                        }
                    @unknown default:
                        break
                    }
                }
            case "playbackBufferEmpty":
                isBuffering = true
                handler?.playbackDelegate?.playbackStartBuffering(player: self)
                handler?.controls?.onStartBuffering()
            case "playbackLikelyToKeepUp":
                isBuffering = false
                handler?.playbackDelegate?.playbackEndBuffering(player: self)
                handler?.controls?.onEndBuffering()
            case "playbackBufferFull":
                isBuffering = false
                handler?.playbackDelegate?.playbackEndBuffering(player: self)
                handler?.controls?.onEndBuffering()
            default:
                break
            }
        }
    }
    
}

// MARK: - AVAssetResourceLoaderDelegate

extension VersaPlayer: AVAssetResourceLoaderDelegate {
    
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

// MARK: - Callbacks

extension VersaPlayer {
    
    func onIsReadyForDisplayUpdated(_ isReady: Bool) {
        handler?.playbackDelegate?.playbackRenderingAvailabilityDidUpdate(player: self, isReady: isReady)
    }
    
}
