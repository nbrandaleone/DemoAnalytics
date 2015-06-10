//
//  TipView.swift
//  SpotDemoAnalytics
//
//  Created by Nick Brandaleone on 6/10/15.
//  Copyright (c) 2015 Nick Brandaleone. All rights reserved.
//

import UIKit

/*
This class handles assigning data from the model into the View.
It is called during TipView creation.

The nil coalescing operator (a ?? b) unwraps an optional a if it contains a value, 
or returns a default value b if a is nil.
The expression a is always of an optional type. The expression b must match the type that is stored inside a.
*/

class TipView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var tip: Tip? {
        didSet {
            titleLabel.text = tip?.title ?? "No Title"
            summaryLabel.text = tip?.summary ?? "No Summary"
            imageView.image = tip?.image
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    // To keep AutoLayout from using entire frame. We must keep to our bounds.
    // This becomes an issue during rotation, when the frame and bounds differ significantly
    override func alignmentRectForFrame(frame: CGRect) -> CGRect {
        return bounds
    }
}
