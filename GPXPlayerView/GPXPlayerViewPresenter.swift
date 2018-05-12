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
        
        // Load GPX File
        let gpxData = try! Data(contentsOf: url)
        self.gpxFileData = try! Gpx(data: gpxData)
        
        // Add GPX File Data to Map
        self.updateGPXDataOnMap()
        
        // If file contains track data, fit the map to display the track
        if self.flatTrackLocations != nil && self.flatTrackLocations!.count > 0{
            self.gpxPlayerView?.zoomToFit(track: self.flatTrackLocations!)
        }
        // Else if file contains route data, fit the map to display the route
        else if (self.gpxFileData?.route != nil && self.gpxFileData!.route!.count > 0){
            let routePoints = self.gpxFileData?.route!.map { $0.coordinate }
            self.gpxPlayerView?.zoomToFit(track: routePoints!)
        }
        
        self.currentPlayerState = .stopped
    }
    
    public func play(){
        switch self.currentPlayerState {
        case .playing:
            break
        case .undefined:
            break
        case .paused:
            self.pauseResume()
            break
        default:
            self.currentPlayingIndex = 0
            self.gpxPlayerView?.initPlayer()
            self.playerTimer = self.buildPlayerTimer()
            self.currentPlayerState = .playing
            break
        }
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
    
    public func updateGPXDataOnMap(){
        
        guard self.gpxFileData != nil else { return }
        
        self.flatTrackLocations = [CLLocationCoordinate2D]()
        
        for currentTrack in (self.gpxFileData?.track!)! {
            let locations = currentTrack.map { $0.coordinate }
            self.gpxPlayerView?.addTrackToMap(track: locations)
            self.flatTrackLocations?.append(contentsOf: locations)
        }
        
        for currentWaypoint in (self.gpxFileData?.waypoints)!{
            self.gpxPlayerView?.addWaypointToMap(waypoint: currentWaypoint.coordinate)
        }
        
        if let route = self.gpxFileData?.route{
            let routePoints = route.map { $0.coordinate }
            self.gpxPlayerView?.addRouteToMap(route: routePoints)
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
