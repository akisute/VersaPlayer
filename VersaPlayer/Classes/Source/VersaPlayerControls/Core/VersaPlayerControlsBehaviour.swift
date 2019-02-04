//
//  VersaPlayerControlsBehaviour.swift
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
import Foundation

open class VersaPlayerControlsBehaviour {
    
    /// VersaPlayerControls instance being controlled
    public weak var controls: VersaPlayerControls?
    
    /// Whether controls are bieng displayed
    public var showingControls: Bool = true
    
    /// Whether controls should be hidden when showingControls is true
    public var shouldHideControls: Bool = true
    
    /// Whether controls should be shown when showingControls is false
    public var shouldShowControls: Bool = true
    
    /// Elapsed time between controls being shown and current time
    public var elapsedTime: TimeInterval = 0
    
    /// Last time when controls were shown
    public var activationTime: TimeInterval = 0
    
    /// At which TimeInterval controls hide automatically
    public var deactivationTimeInterval: TimeInterval = 3
    
    /// Custom deactivation block
    public var deactivationBlock: ((VersaPlayerControls) -> Void)? = nil
    
    /// Custom activation block
    public var activationBlock: ((VersaPlayerControls) -> Void)? = nil
    
    /// Constructor
    ///
    /// - Parameters:
    ///     - controls: VersaPlayerControls to be controlled.
    public init(with controls: VersaPlayerControls) {
        self.controls = controls
    }
    
    /// Update ui based on time
    ///
    /// - Parameters:
    ///     - time: TimeInterval to check whether to update controls.
    open func update(with time: TimeInterval) {
        guard let controls = controls, let handler = controls.controlsCoordinator?.playerView else { return }
        elapsedTime = time
        if showingControls
            && shouldHideControls
            && !handler.player.isBuffering
            && !handler.isSeeking
            && handler.isPlaying {
            let timediff = elapsedTime - activationTime
            if timediff >= deactivationTimeInterval {
                hide()
            }
        }
    }
    
    /// Default activation block
    private static func defaultActivationBlock(_ controls: VersaPlayerControls) {
        controls.isHidden = false
        #if os(macOS)
        controls.alphaValue = 1
        #else
        UIView.animate(withDuration: 0.3) {
            controls.alpha = 1
        }
        #endif
    }
    
    /// Default deactivation block
    private static func defaultDeactivationBlock(_ controls: VersaPlayerControls) {
        #if os(macOS)
        controls.alphaValue = 0
        #else
        UIView.animate(withDuration: 0.3, animations: {
            controls.alpha = 0
        }) {
            if $0 {
                controls.isHidden = true
            }
        }
        #endif
    }
    
    /// Hide the controls
    open func hide() {
        guard let controls = controls else { return }
        
        if let deactivationBlock = deactivationBlock {
            deactivationBlock(controls)
        } else {
            VersaPlayerControlsBehaviour.defaultDeactivationBlock(controls)
        }
        showingControls = false
    }
    
    /// Show the controls
    open func show() {
        guard shouldShowControls, let controls = controls else { return }
        
        activationTime = elapsedTime
        if let activationBlock = activationBlock {
            activationBlock(controls)
        } else {
            VersaPlayerControlsBehaviour.defaultActivationBlock(controls)
        }
        showingControls = true
    }
    
}
