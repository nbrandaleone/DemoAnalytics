//
//  ViewController.swift
//  SpotDemoAnalytics
//
//  Created by Nick Brandaleone on 6/9/15.
//  Copyright (c) 2015 Nick Brandaleone. All rights reserved.
//

import UIKit

/* This primary VC is only used to import mock data for demo.
    Method 'presentTips' is defined in an extension in TipViewController. */

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        presentTips([
            Tip(title: "Parking Spot Revenue", summary: "Bar chart", image: UIImage(named: "barchart")),
            Tip(title: "Average Price", summary: "Angular Guage", image: UIImage(named: "angularguage")),
            Tip(title: "Sales Price", summary: "Bubble Chart", image: UIImage(named: "bubble"))
            ], animated: true, completion: nil)
    }
}

