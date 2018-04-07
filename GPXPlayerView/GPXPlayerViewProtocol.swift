//
//  GPXPlayerViewProtocol.swift
//  GPXPlayerView
//
//  Created by Tomer Shalom on 24/03/2018.
//  Copyright © 2018 Applitom. All rights reserved.
//

import Foundation
import CoreLocation

protocol GPXPlayerViewProtocol: class {
    
    func addTrackToMap(track: [CLLocationCoordinate2D])
    func setMapCenter(center: CLLocationCoordinate2D)
    func zoomToFit(track: [CLLocationCoordinate2D])
    func initPlayer()
    func moveCurrentTrackLocation(currentTrackLocation: CLLocationCoordinate2D)
    func removeCurrentTrakLocationMarkFromMap()
}
