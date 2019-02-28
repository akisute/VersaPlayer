//
//  VersaPlayerGestureRecieverViewDelegate.swift
//  VersaPlayerView Demo
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

#if os(macOS)

public protocol VersaPlayerGestureRecieverViewDelegate: AnyObject {
    
    /// Pinch was recognized
    ///
    /// - Parameters:
    ///     - scale: CGFloat scale
    func didPinch(with scale: CGFloat)
    
    /// Tap was recognized
    ///
    /// - Parameters:
    ///     - point: CGPoint at wich touch was recognized
    func didTap(at point: CGPoint)
    
    /// Double tap was recognized
    ///
    /// - Parameters:
    ///     - point: CGPoint at wich touch was recognized
    func didDoubleTap(at point: CGPoint)
    
    /// Pan was recognized
    ///
    /// - Parameters:
    ///     - translation: translation in view
    ///     - at: initial point recognized
    func didPan(with translation: CGPoint, initially at: CGPoint)
    
}

#elseif os(iOS)

public protocol VersaPlayerGestureRecieverViewDelegate: AnyObject {
    
    /// Pinch was recognized
    func didPinch(with gr: UIPinchGestureRecognizer)
    
    /// Tap was recognized
    func didTap(with gr: UITapGestureRecognizer)
    
    /// Double tap was recognized
    func didDoubleTap(with gr: UITapGestureRecognizer)
    
    /// Pan was recognized
    func didPan(with gr: UIPanGestureRecognizer)
    
}

#elseif os(tvOS)

public protocol VersaPlayerGestureRecieverViewDelegate: AnyObject {
    
    /// Tap was recognized
    func didTap(with gr: UITapGestureRecognizer)
    
    /// Double tap was recognized
    func didDoubleTap(with gr: UITapGestureRecognizer)
    
    /// Pan was recognized
    func didPan(with gr: UIPanGestureRecognizer)
    
    /// Swipe was recognized
    func didSwipe(with gr: UISwipeGestureRecognizer)
    
}

#endif
