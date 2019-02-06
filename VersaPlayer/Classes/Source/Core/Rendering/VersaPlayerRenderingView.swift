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
    
    private weak var playerView: VersaPlayerView?
    
    deinit {
        removeObserver(renderingLayer.playerLayer, forKeyPath: "isReadyForDisplay")
    }

    /// Constructor
    ///
    /// - Parameters:
    ///     - player: VersaPlayer instance to render.
    public init(playerView: VersaPlayerView) {
        super.init(frame: CGRect.zero)
        self.playerView = playerView
        initializeRenderingLayer(playerView: playerView)
        addObserver(renderingLayer.playerLayer, forKeyPath: "isReadyForDisplay", options: .new, context: nil)
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
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? AVPlayerLayer, obj == renderingLayer.playerLayer {
            switch keyPath ?? "" {
            case "isReadyForDisplay":
                playerView?.player.onIsReadyForDisplayUpdated(renderingLayer.playerLayer.isReadyForDisplay)
            default:
                break
            }
        }
    }
    
}
