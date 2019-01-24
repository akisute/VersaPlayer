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

open class VersaPlayerControlsCoordinator: View, VersaPlayerGestureRecieverViewDelegate {

    /// VersaPlayer instance being used
    public weak var player: VersaPlayerView?
    
    /// VersaPlayerControls instance being used
    public weak var controls: VersaPlayerControls?
    
    /// VersaPlayerGestureRecieverView instance being used
    public var gestureReciever: VersaPlayerGestureRecieverView!

    deinit {
      #if DEBUG
          print("2 \(String(describing: self))")
      #endif
    }

    #if os(macOS)
    
    override open func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        configureView()
    }
    
    open override func layout() {
        super.layout()
        stretchToEdges()
    }
    
    #else
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        configureView()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        stretchToEdges()
    }
    
    #endif
    
    public func configureView() {
        if let h = superview as? VersaPlayerView {
            player = h
            if let controls = controls {
                addSubview(controls)
            }
            if gestureReciever == nil {
                gestureReciever = VersaPlayerGestureRecieverView()
                gestureReciever.delegate = self
                #if os(macOS)
                addSubview(gestureReciever, positioned: NSWindow.OrderingMode.below, relativeTo: nil)
                #else
                addSubview(gestureReciever)
                sendSubviewToBack(gestureReciever)
                #endif
            }
            stretchToEdges()
        }
    }
    
    public func stretchToEdges() {
        translatesAutoresizingMaskIntoConstraints = false
        if let parent = superview {
            topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
            leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
            bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        }
    }
    
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
        guard let controls = controls else { return }
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
        guard let player = player else { return }
        // Toggle between resizeAspect and resizeAspectFill of the video gravity
        switch player.renderingView.renderingLayer.playerLayer.videoGravity {
        case .resizeAspect:
            player.renderingView.renderingLayer.playerLayer.videoGravity = .resizeAspectFill
        case .resizeAspectFill:
            player.renderingView.renderingLayer.playerLayer.videoGravity = .resizeAspect
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
    
    #if os(tvOS)
    /// Swipe was recognized
    ///
    /// - Parameters:
    ///     - direction: gestureDirection
    open func didSwipe(with direction: UISwipeGestureRecognizer.Direction) {
        
    }
    #endif

}
