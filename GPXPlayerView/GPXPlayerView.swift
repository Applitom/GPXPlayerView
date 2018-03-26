//
//  GPXPlayerView.swift
//  GPXPlayerView
//
//  Created by Tomer Shalom on 24/03/2018.
//  Copyright © 2018 Applitom. All rights reserved.
//

import UIKit
import MapKit

fileprivate extension UIView
{
    fileprivate func fillWithView(_ view: UIView){
        let viewDict = ["view" : view]
        let horisontalFormat = "H:|[view]|"
        let verticalFormat = "V:|[view]|"
        let priority = UILayoutPriority.required
        
        let horisontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: horisontalFormat,
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: viewDict)
        for currConstraint in horisontalConstraints{
            currConstraint.priority = priority
        }
        self.addConstraints(horisontalConstraints)
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: verticalFormat,
                                                                 options: NSLayoutFormatOptions(rawValue: 0),
                                                                 metrics: nil,
                                                                 views: viewDict)
        for currConstraint in verticalConstraints{
            currConstraint.priority = priority
        }
        self.addConstraints(verticalConstraints)
        
        self.layoutIfNeeded()
    }
}

public class GPXPlayerView: UIView {

    let mapView: MKMapView = MKMapView()
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setupMapView()
    }
    
    private func setupMapView(){
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.mapView)
        self.fillWithView(self.mapView)
        self.mapView.delegate = self
    }
    
    public func loadGPXFile(fromURL url:URL){
        let gpxData = try! Data(contentsOf: url)
        let gpxFile = try! Gpx(data: gpxData)
        
        for currentTrack in gpxFile.track! {
            var locations = currentTrack.map { $0.coordinate }
            let polyline = MKPolyline(coordinates: &locations, count: locations.count)
            self.mapView.add(polyline)
        }
    }
}

extension GPXPlayerView: MKMapViewDelegate{
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.blue
        polylineRenderer.lineWidth = 3
        return polylineRenderer
    }
}
