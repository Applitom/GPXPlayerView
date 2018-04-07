//
//  GPXPlayerView.swift
//  GPXPlayerView
//
//  Created by Tomer Shalom on 24/03/2018.
//  Copyright © 2018 Applitom. All rights reserved.
//

import UIKit
import MapKit

public class GPXPlayerView: UIView {
    
    public var playerTrackImage: UIImage?
    private var currentTrackAnnotation: MKPointAnnotation?
    private let gpxPlayerViewPresenter = GPXPlayerViewPresenter()
    private let mapView: MKMapView = MKMapView()
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.gpxPlayerViewPresenter.attachView(view: self)
        self.setupMapView()
    }
    
    private func setupMapView(){
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.mapView)
        self.fillWithView(self.mapView)
        self.mapView.delegate = self
        self.mapView.mapType = .hybridFlyover
    }
    
    public func loadGPXFile(fromURL url:URL){
        self.gpxPlayerViewPresenter.loadGPXFile(fromURL: url)
    }
    
    public func play(){
        self.gpxPlayerViewPresenter.play()
    }
    
    public func stop(){
        self.gpxPlayerViewPresenter.stop()
    }
    
    public func pauseResume(){
        self.gpxPlayerViewPresenter.pauseResume()
    }
}

// MARK: --- GPXPlayerViewProtocol ---
extension GPXPlayerView: GPXPlayerViewProtocol{
    func initPlayer() {
        self.currentTrackAnnotation = MKPointAnnotation()
        self.mapView.addAnnotation(self.currentTrackAnnotation!)
    }
    
    func moveCurrentTrackLocation(currentTrackLocation: CLLocationCoordinate2D) {
        self.currentTrackAnnotation?.coordinate = currentTrackLocation
    }
    
    func removeCurrentTrakLocationMarkFromMap(){
        guard self.currentTrackAnnotation != nil else { return }
        self.mapView.removeAnnotation(self.currentTrackAnnotation!)
        self.currentTrackAnnotation = nil
    }
    
    func addTrackToMap(track: [CLLocationCoordinate2D]) {
        let polyline = MKPolyline(coordinates: track, count: track.count)
        self.mapView.add(polyline)
    }
    
    func setMapCenter(center: CLLocationCoordinate2D) {
        self.mapView.setCenter(center, animated: true)
    }
    
    func zoomToFit(track: [CLLocationCoordinate2D]){
        let polyline = MKPolyline(coordinates: track, count: track.count)
        self.mapView.setVisibleMapRect(polyline.boundingMapRect, animated: true)
    }
}
// MARK: --- MKMapViewDelegate ---
extension GPXPlayerView: MKMapViewDelegate{
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.blue
        polylineRenderer.lineWidth = 3
        return polylineRenderer
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard self.playerTrackImage != nil else {
            return nil
        }
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "TrackAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.image = playerTrackImage
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
}

// MARK: --- View Helpers ---
extension GPXPlayerView
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
