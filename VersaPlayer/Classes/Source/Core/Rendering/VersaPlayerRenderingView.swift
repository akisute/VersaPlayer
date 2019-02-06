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
    
    /// VPlayerLayer instance used to render player content
    public var renderingLayer: VersaPlayerLayer!
    
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
        initializeRenderingLayer(playerView: playerView)
        isReadyForDisplayKVO = renderingLayer.playerLayer.observe(\AVPlayerLayer.isReadyForDisplay, options: [.new]) { [weak self] _, change in
            self?.playerView?.player.onIsReadyForDisplayUpdated(change.newValue!)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if os(macOS)
    
    private func initializeRenderingLayer(playerView: VersaPlayerView) {
        renderingLayer = VersaPlayerLayer(playerView: playerView)
        layer = renderingLayer.playerLayer
    }
    
    open override func layout() {
        super.layout()
        renderingLayer.frame = bounds
        renderingLayer.playerLayer.frame = bounds
    }
    
    #else
    
    private func initializeRenderingLayer(playerView: VersaPlayerView) {
        renderingLayer = VersaPlayerLayer(playerView: playerView)
        layer.addSublayer(renderingLayer.playerLayer)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        renderingLayer.frame = bounds
        renderingLayer.playerLayer.frame = bounds
    }
    
    #endif
    
}
