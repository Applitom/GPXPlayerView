//
//  GPXPlayerView.swift
//  GPXPlayerView
//
//  Created by Tomer Shalom on 24/03/2018.
//  Copyright © 2018 Applitom. All rights reserved.
//

import UIKit
import MapKit

class TrackPlayerPositionAnnotation: MKPointAnnotation {}
class WaypointAnnotation: MKPointAnnotation {}

class TrackPolyline: MKPolyline {}
class RoutePolyline: MKPolyline {}

public struct GPXViewPolylineStyle{
    public var strokeColor: UIColor = UIColor.blue
    public var lineWidth: CGFloat = 3
}

public class GPXPlayerView: UIView {
    
    public var playerTrackImage: UIImage?
    public var waypointImage: UIImage?
    public var trackPolylineStyle = GPXViewPolylineStyle(){
        didSet{
            self.mapView.removeOverlays(self.mapView.overlays)
            self.gpxPlayerViewPresenter.updateGPXDataOnMap()
        }
    }
    
    public var routePolylineStyle = GPXViewPolylineStyle(){
        didSet{
            self.mapView.removeOverlays(self.mapView.overlays)
            self.gpxPlayerViewPresenter.updateGPXDataOnMap()
        }
    }
    
    private var currentTrackAnnotation: TrackPlayerPositionAnnotation?
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
        self.currentTrackAnnotation = TrackPlayerPositionAnnotation()
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
        let polyline = TrackPolyline(coordinates: track, count: track.count)
        self.mapView.add(polyline)
    }
    
    func addRouteToMap(route: [CLLocationCoordinate2D]) {
        let polyline = RoutePolyline(coordinates: route, count: route.count)
        self.mapView.add(polyline)
    }
    
    func addWaypointToMap(waypoint: CLLocationCoordinate2D) {
        let waypointAnnotation = WaypointAnnotation()
        waypointAnnotation.coordinate = waypoint
        
        self.mapView.addAnnotation(waypointAnnotation)
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
        
        if (overlay is RoutePolyline){
            polylineRenderer.strokeColor = self.routePolylineStyle.strokeColor
            polylineRenderer.lineWidth = self.routePolylineStyle.lineWidth
        }
        else if (overlay is TrackPolyline){
            polylineRenderer.strokeColor = self.trackPolylineStyle.strokeColor
            polylineRenderer.lineWidth = self.trackPolylineStyle.lineWidth
        }
        
        return polylineRenderer
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        if annotation is TrackPlayerPositionAnnotation && self.playerTrackImage != nil {
            return buildTrackPlayerPositionAnnotationView(mapView: mapView, viewFor: annotation)
        }
        else if annotation is WaypointAnnotation && self.waypointImage != nil {
            return buildWaypointAnnotationView(mapView: mapView, viewFor: annotation)
        }

        return nil
    }
    
    private func buildTrackPlayerPositionAnnotationView(mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView{
        let identifier = "TrackPlayerPositionAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.image = self.playerTrackImage
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView!
    }
    
    private func buildWaypointAnnotationView(mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView{
        let identifier = "WaypointAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.image = self.waypointImage
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView!
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
