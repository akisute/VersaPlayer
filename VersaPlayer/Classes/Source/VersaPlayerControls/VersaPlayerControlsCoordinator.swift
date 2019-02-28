//
//  VersaPlayerControlsCoordinator.swift
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
import CoreMedia
import AVFoundation

class VersaPlayerControlsCoordinator: View {
    
    /// VersaPlayer instance being used
    private(set) weak var playerView: VersaPlayerView?
    
    /// VersaPlayerControls instance being used
    let controls: VersaPlayerControls
    
    /// VersaPlayerGestureRecieverView instance being used
    let gestureReciever: VersaPlayerGestureRecieverView
    
    init(playerView: VersaPlayerView, controls: VersaPlayerControls, gestureReciever: VersaPlayerGestureRecieverView?) {
        self.playerView = playerView
        self.controls = controls
        if let gestureReciever = gestureReciever {
            self.gestureReciever = gestureReciever
        } else {
            self.gestureReciever = VersaPlayerGestureRecieverView()
        }
        
        super.init(frame: .zero)
        
        self.controls.controlsCoordinator = self
        if self.gestureReciever.delegate == nil {
            self.gestureReciever.delegate = self
        }
        
        #if os(macOS)
        addSubview(self.controls)
        addSubview(self.gestureReciever, positioned: NSWindow.OrderingMode.below, relativeTo: nil)
        #else
        addSubview(self.controls)
        addSubview(self.gestureReciever)
        sendSubviewToBack(self.gestureReciever)
        #endif
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - View

extension VersaPlayerControlsCoordinator {
    
    #if os(macOS)
    
    open override func layout() {
        super.layout()
        controls.frame = bounds
        gestureReciever.frame = bounds
    }
    
    #else
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        controls.frame = bounds
        gestureReciever.frame = bounds
    }
    
    #endif
    
}

// MARK: - VersaPlayerGestureRecieverViewDelegate

#if os(macOS)

extension VersaPlayerControlsCoordinator: VersaPlayerGestureRecieverViewDelegate {
    
    /// Notifies when pinch was recognized
    ///
    /// - Parameters:
    ///     - scale: CGFloat value
    open func didPinch(with scale: CGFloat) {
        
    }
    
    /// Notifies when tap was recognized
    ///
    /// - Parameters:
    ///     - point: CGPoint at which tap was recognized
    open func didTap(at point: CGPoint) {
        // Toggle between show/hide of the controls
        if controls.behaviour.showingControls {
            controls.behaviour.hide()
        } else {
            controls.behaviour.show()
        }
    }
    
    /// Notifies when tap was recognized
    ///
    /// - Parameters:
    ///     - point: CGPoint at which tap was recognized
    open func didDoubleTap(at point: CGPoint) {
        guard let playerView = playerView else { return }
        // Toggle between resizeAspect and resizeAspectFill of the video gravity
        switch playerView.renderingView.playerLayer.videoGravity {
        case .resizeAspect:
            playerView.renderingView.playerLayer.videoGravity = .resizeAspectFill
        case .resizeAspectFill:
            playerView.renderingView.playerLayer.videoGravity = .resizeAspect
        case .resize:
            // Do nothing for non-aspect resize
            break
        default:
            // NEVER happens because AVLayerVideoGravity is an ObjC enum so this switch is actually exhaustive...
            break
        }
    }
    
    /// Notifies when pan was recognized
    ///
    /// - Parameters:
    ///     - translation: translation of pan in CGPoint representation
    ///     - at: initial point recognized
    open func didPan(with translation: CGPoint, initially at: CGPoint) {
        
    }
    
}

#elseif os(iOS)

extension VersaPlayerControlsCoordinator: VersaPlayerGestureRecieverViewDelegate {
    
    open func didPinch(with gr: UIPinchGestureRecognizer) {
    }
    
    open func didTap(with gr: UITapGestureRecognizer) {
        // Toggle between show/hide of the controls
        if controls.behaviour.showingControls {
            controls.behaviour.hide()
        } else {
            controls.behaviour.show()
        }
    }
    
    open func didDoubleTap(with gr: UITapGestureRecognizer) {
        guard let playerView = playerView else { return }
        // Toggle between resizeAspect and resizeAspectFill of the video gravity
        switch playerView.renderingView.playerLayer.videoGravity {
        case .resizeAspect:
            playerView.renderingView.playerLayer.videoGravity = .resizeAspectFill
        case .resizeAspectFill:
            playerView.renderingView.playerLayer.videoGravity = .resizeAspect
        case .resize:
            // Do nothing for non-aspect resize
            break
        default:
            // NEVER happens because AVLayerVideoGravity is an ObjC enum so this switch is actually exhaustive...
            break
        }
    }
    
    open func didPan(with gr: UIPanGestureRecognizer) {
    }
    
}

#elseif os(tvOS)

extension VersaPlayerControlsCoordinator: VersaPlayerGestureRecieverViewDelegate {
    
    open func didTap(with gr: UITapGestureRecognizer) {
        // Toggle between show/hide of the controls
        if controls.behaviour.showingControls {
            controls.behaviour.hide()
        } else {
            controls.behaviour.show()
        }
    }
    
    open func didDoubleTap(with gr: UITapGestureRecognizer) {
        guard let playerView = playerView else { return }
        // Toggle between resizeAspect and resizeAspectFill of the video gravity
        switch playerView.renderingView.playerLayer.videoGravity {
        case .resizeAspect:
            playerView.renderingView.playerLayer.videoGravity = .resizeAspectFill
        case .resizeAspectFill:
            playerView.renderingView.playerLayer.videoGravity = .resizeAspect
        case .resize:
            // Do nothing for non-aspect resize
            break
        default:
            // NEVER happens because AVLayerVideoGravity is an ObjC enum so this switch is actually exhaustive...
            break
        }
    }
    
    open func didPan(with gr: UIPanGestureRecognizer) {
    }
    
    open func didSwipe(with gr: UISwipeGestureRecognizer) {
    }
    
}

#endif
