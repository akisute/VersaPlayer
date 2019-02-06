//
//  VPlaybackDelegate.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import Foundation
import AVFoundation

public protocol VersaPlayerPlaybackDelegate: AnyObject {
    
    /// Called just before starting playback to determine whether if playback should begin on the specified player
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    ///
    /// - Returns: Boolean to determine whether to play or not, `true` to play, `false` to not play
    func playbackShouldBegin(player: VersaPlayer) -> Bool
    
    /// Notifies when playback did begin
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    func playbackDidBegin(player: VersaPlayer)
    
    /// Notifies when player ended playback
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    func playbackDidEnd(player: VersaPlayer)
    
    /// Notifies when playback will be paused by a user interaction, or by code using `pause()` method.
    /// Any other reasons to make the player stopped is not covered by this callback.
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    func playbackWillPause(player: VersaPlayer)
    
    /// Notifies when playback is paused by a user interaction, or by code using `pause()` method.
    /// Any other reasons to make the player stopped is not covered by this callback.
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    func playbackDidPause(player: VersaPlayer)
    
    /// Whether if playback is skipping frames
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    func playbackDidJump(player: VersaPlayer)
    
    /// Notifies when playback time changes
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    ///     - time: Current time
    func playbackTimeDidChange(player: VersaPlayer, to time: CMTime)
    
    /// Notifies when player starts buffering
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    func playbackStartBuffering(player: VersaPlayer)
    
    /// Notifies when player ends buffering
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    func playbackEndBuffering(player: VersaPlayer)
    
    /// Notifies when the player is ready to start playback. Note that even though this notification is called,
    /// the underlying current item may not yet be ready for playback. Also note that this callback will be called
    /// only once per same player instance while `playbackItemIsReady()` will be called every time the current item is
    /// updated and loaded to be ready.
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    func playbackPlayerIsReady(player: VersaPlayer)
    
    /// Notifies when playback of the current item is ready to play.
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    func playbackItemIsReady(player: VersaPlayer)
    
    /// Notifies when the player rendering is ready, meaning the player can display its content immediately.
    /// Even if `playbackItemIsReady()` is called, the underlying rendering system may not always ready. It may take
    /// some additional time to be prepared.
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    ///     - isReady: `true` when the rendering is ready and available right now, `false` otherwise.
    func playbackRenderingAvailabilityDidUpdate(player: VersaPlayer, isReady: Bool)
    
    /// Notifies when the player stops working because of the error.
    /// You must abandon the current player after this callback is called, because the player is already errored out.
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    ///     - error: player error
    func playbackPlayerDidFail(player: VersaPlayer, error: Error)
    
    /// Notifies when playback fails with an error. Note that this is caused when the playback of player items are failed,
    /// not when the player itself is failed to do anything with errors.
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    ///     - error: playback error
    func playbackItemDidFail(player: VersaPlayer, error: VersaPlayerPlaybackError)
    
}
