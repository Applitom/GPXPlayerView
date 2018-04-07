//
//  ViewController.swift
//  GPXPlayerViewExample
//
//  Created by Tomer Shalom on 25/03/2018.
//  Copyright © 2018 Applitom. All rights reserved.
//

import UIKit
import GPXPlayerView

class ViewController: UIViewController {

    @IBOutlet weak var gpxPlayerView: GPXPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.gpxPlayerView.playerTrackImage = UIImage(named: "snowboard")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loadPressed(_ sender: Any) {
        let gpxURL = Bundle(for: ViewController.self).url(forResource: "Sample", withExtension: "gpx")
        self.gpxPlayerView.loadGPXFile(fromURL: gpxURL!)
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

