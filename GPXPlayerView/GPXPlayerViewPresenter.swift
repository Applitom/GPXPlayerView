//
//  GPXPlayerViewPresenter.swift
//  GPXPlayerView
//
//  Created by Tomer Shalom on 24/03/2018.
//  Copyright © 2018 Applitom. All rights reserved.
//

import Foundation
import CoreLocation

private enum PlayerState{
    case undefined
    case stopped
    case playing
    case paused
}

class GPXPlayerViewPresenter {

    private weak var gpxPlayerView: GPXPlayerViewProtocol?
    private var gpxFileData: Gpx?
    private var flatTrackLocations: [CLLocationCoordinate2D]?
    
    private var playerTimer: Timer?
    private var currentPlayingIndex = 0
    private var currentPlayerState = PlayerState.undefined
    
    public func attachView(view: GPXPlayerViewProtocol){
        self.gpxPlayerView = view
    }
    
    public func loadGPXFile(fromURL url:URL){
        let gpxData = try! Data(contentsOf: url)
        
        self.gpxFileData = try! Gpx(data: gpxData)
        self.flatTrackLocations = [CLLocationCoordinate2D]()
        
        for currentTrack in (self.gpxFileData?.track!)! {
            let locations = currentTrack.map { $0.coordinate }
            self.gpxPlayerView?.addTrackToMap(track: locations)
            self.flatTrackLocations?.append(contentsOf: locations)
        }
        
        if self.flatTrackLocations != nil && self.flatTrackLocations!.count > 0{
            self.gpxPlayerView?.zoomToFit(track: self.flatTrackLocations!)
        }
        
        self.currentPlayerState = .stopped
    }
    
    public func play(){
        guard self.currentPlayerState != .undefined else { return }
        
        self.currentPlayingIndex = 0
        self.gpxPlayerView?.initPlayer()
        self.playerTimer = self.buildPlayerTimer()
        self.currentPlayerState = .playing
    }
    
    public func stop(){
        guard self.currentPlayerState != .undefined else { return }
        self.playerTimer?.invalidate()
        self.playerTimer = nil
        self.currentPlayingIndex = 0
        self.gpxPlayerView?.removeCurrentTrakLocationMarkFromMap()
        self.currentPlayerState = .stopped
    }
    
    public func pauseResume(){
        if (self.currentPlayerState == .playing){
            self.playerTimer?.invalidate()
            self.currentPlayerState = .paused
        }
        else if (self.currentPlayerState == .paused){
            self.playerTimer = self.buildPlayerTimer()
            self.currentPlayerState = .playing
        }
    }
    
    // MARK: Privates
    @objc private func playerTick(){
        guard self.flatTrackLocations != nil && self.flatTrackLocations!.count > 0 else {
            return
        }
        
        if (self.currentPlayingIndex >= self.flatTrackLocations!.count){
            self.currentPlayingIndex = 0
        }
        
        self.gpxPlayerView?.moveCurrentTrackLocation(currentTrackLocation: self.flatTrackLocations![self.currentPlayingIndex])
        self.currentPlayingIndex += 1
    }
    
    private func buildPlayerTimer() -> Timer{
        return Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(playerTick), userInfo: nil, repeats: true)
    }
    
    deinit {
        self.playerTimer?.invalidate()
    }
}
