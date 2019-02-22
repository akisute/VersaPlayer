//
//  VPlayerRenderingView.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

#if os(macOS)
import Cocoa
#else
import UIKit
#endif
import AVKit

open class VersaPlayerRenderingView: View {
    
    private var isReadyForDisplayKVO: NSKeyValueObservation?
    
    private weak var playerView: VersaPlayerView?
    
    
    deinit {
        if let kvo = isReadyForDisplayKVO {
            kvo.invalidate()
            isReadyForDisplayKVO = nil
        }
    }

    /// Constructor
    ///
    /// - Parameters:
    ///     - player: VersaPlayer instance to render.
    public init(playerView: VersaPlayerView) {
        super.init(frame: CGRect.zero)
        self.playerView = playerView
        playerLayer.player = playerView.player
        isReadyForDisplayKVO = playerLayer.observe(\AVPlayerLayer.isReadyForDisplay, options: [.new]) { [weak self] _, change in
            self?.playerView?.player.onIsReadyForDisplayUpdated(change.newValue!)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if os(macOS)
    
    override open func makeBackingLayer() -> CALayer {
        return AVPlayerLayer()
    }
    
    public var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    #else
    
    override open class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    public var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    #endif
    
}
