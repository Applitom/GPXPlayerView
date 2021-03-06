//
//  ViewController.swift
//  GPXPlayerViewExample
//
//  Created by Tomer Shalom on 25/03/2018.
//  Copyright © 2018 Applitom. All rights reserved.
//

import UIKit
import GPXPlayerView

class GpxFileViewController: UIViewController {

    public var sampleName: String?
    
    @IBOutlet weak var gpxPlayerView: GPXPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gpxPlayerView.playerTrackImage = UIImage(named: "snowboard")
        
        self.gpxPlayerView.routePolylineStyle.strokeColor = UIColor.red
        self.gpxPlayerView.routePolylineStyle.lineWidth = 1
        
        self.gpxPlayerView.trackPolylineStyle.strokeColor = UIColor.white
        self.gpxPlayerView.trackPolylineStyle.lineWidth = 2
        
        if let sampleNameToLoad = self.sampleName{
            let gpxURL = Bundle(for: GpxFileViewController.self).url(forResource: sampleNameToLoad, withExtension: "gpx")
            self.gpxPlayerView.loadGPXFile(fromURL: gpxURL!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func stopPressed(_ sender: Any) {
        self.gpxPlayerView.stop()
    }
    
    @IBAction func playPressed(_ sender: Any) {
        self.gpxPlayerView.play()
    }
    
    @IBAction func pauseResumePressed(_ sender: Any) {
        self.gpxPlayerView.pauseResume()
    }
}

