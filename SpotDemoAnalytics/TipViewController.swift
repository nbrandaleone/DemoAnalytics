//
//  TipViewController.swift
//  SpotDemoAnalytics
//
//  Created by Nick Brandaleone on 6/10/15.
//  Copyright (c) 2015 Nick Brandaleone. All rights reserved.
//

/* This VC handles all the animation of the spinning tips */

import UIKit

private let kTipViewOffset: CGFloat = 500   // pushes the View offscreen by this constant
private let kTipViewHeight: CGFloat = 400
private let kTipViewWidth:  CGFloat = 300


class TipViewController: UIViewController {
    
    var tipView: TipView!
    var animator: UIDynamicAnimator!
    var attachmentBehavior: UIAttachmentBehavior!
    var snapBehavior: UISnapBehavior!
    var panBehavior: UIAttachmentBehavior!
    
    var tips = [Tip]()  // holds data from ViewController in array
    var index = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = UIColor(white: 0, alpha: 0.5)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupAnimator()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // create Tip Views. Read in Nib of TipView for basic look and feel
    func createTipView() -> TipView? {
        if let view = UINib(nibName: "TipView", bundle: nil).instantiateWithOwner(nil, options: nil).first as! TipView? {
            view.frame = CGRect(x: 0, y: 0, width: kTipViewWidth, height: kTipViewHeight)
            return view
        }
        return nil
    }
    
    // MARK: Setting up the physics of UIDynamics engine
    
    // Sets the center and transform properties on the tip view
    func updateTipView(tipeview: UIView, position: TipViewPosition) {
        var center = CGPoint(x: CGRectGetWidth(view.bounds)/2, y: CGRectGetHeight(view.bounds)/2)
        tipView.center = position.viewCenter(center)
        tipView.transform = position.viewTransform()
    }
    
    // Removes all behaviors from the physics engine. Updates the tip view position,
    // and starts the physics engine
    func resetTipView(tipView: UIView, position: TipViewPosition) {
        animator.removeAllBehaviors()
        
        updateTipView(tipView, position: position)
        animator.updateItemUsingCurrentState(tipView)
        
        animator.addBehavior(attachmentBehavior)
        animator.addBehavior(snapBehavior)
    }
    
    /* We have created 2 important dynamic constraints. One, the tipView is attached as by an invisible string or rod
    to an anchor point below the center of the SuperView.  This creates the pendulum effect. The length of the "string" is offset by kTipViewOffset in the y axis
    of the superView. The snap behavior will bring the tipView back to the center with a spring-like animation effect. */
    func setupAnimator(){
        
        animator = UIDynamicAnimator(referenceView: view)
        var center = CGPoint(x: CGRectGetWidth(view.bounds)/2, y: CGRectGetHeight(view.bounds)/2)
        
        // Create first tipView
        tipView = createTipView()
        view.addSubview(tipView)
        
        snapBehavior = UISnapBehavior(item: tipView, snapToPoint: center)
        
        center.y += kTipViewOffset
        attachmentBehavior = UIAttachmentBehavior(item: tipView, offsetFromCenter: UIOffset(horizontal: 0, vertical: kTipViewOffset), attachedToAnchor: center)
        
        // assign the first tipView data, and rotate it in from the right
        setupTipView(tipView, index: 0)
        resetTipView(tipView, position: .RotatedRight)
        
        // To handle dragging interaction, we create a pan gesture recognizer
        let pan = UIPanGestureRecognizer(target: self, action: "panTipView:")
        view.addGestureRecognizer(pan)
    }
    
    // This enumeration will hold the states of the tip view that we are interested in
    enum TipViewPosition: Int {
        case Default
        case RotatedLeft
        case RotatedRight
        
        // Push the center of the tip down and to the right/left of the superView
        func viewCenter(var center: CGPoint) -> CGPoint {
            switch self {
            case .RotatedLeft:
                center.y += kTipViewOffset
                center.x -= kTipViewOffset
                
            case .RotatedRight:
                center.y += kTipViewOffset
                center.x += kTipViewOffset
                
            default:
                ()
            }
            return center
        }
        
        // Rotate the tip 90 degrees right or left
        func viewTransform() -> CGAffineTransform {
            switch self {
            case .RotatedLeft:
                return CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                
            case .RotatedRight:
                return CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                
            default:
                return CGAffineTransformIdentity
            }
        }
    }
    
    // MARK : Read Tip model to setup view properly. Update page controller (dots on bottom of page)
    // I had to make the background black (or dark color) to see the dots.
    func setupTipView(tipView: TipView, index: Int) {
        if index < tips.count {
            let tip = tips[index]
            tipView.tip = tip
            
            tipView.pageControl.numberOfPages = tips.count
            tipView.pageControl.currentPage = index
            println("The pageControl number is: \(tipView.pageControl.currentPage)")
        }
        else {
            tipView.tip = nil
        }
    }
    
    // MARK: Pan Behavior for swiping the tips left/right
    /*
    When the pan behavior begins, we have 5 things to do.
    1) We remove the snap behavior, so we can move the tip without it snapping back on us.
    We then create an attachment behavior (anchor point) to the touch location.
    2) We update the anchor point to follow the touch location as the pan continues.
    3) When the pan stops, we have to determine whether to proceed with animation or not.
    4) If we cancel the transition, we remove the pan bahavior, and re-implement the original snap behavior.
    5) If we proceed with the transition, we reset the attachment anchor, and call 'resetTipView' to bring
    the tip back on-scren from the opposite direction.
    */
    func panTipView(pan: UIPanGestureRecognizer) {
        let location = pan.locationInView(view)
        
        switch pan.state {
        case .Began:
            animator.removeBehavior(snapBehavior)
            panBehavior = UIAttachmentBehavior(item: tipView, attachedToAnchor: location)
            animator.addBehavior(panBehavior)
            
        case .Changed:
            panBehavior.anchorPoint = location
            
        case .Ended:
            fallthrough
        case .Cancelled:
            let center = CGPoint(x: CGRectGetWidth(view.bounds)/2, y: CGRectGetHeight(view.bounds)/2)
            let offset = location.x - center.x
            if fabs(offset) < 100 {                 // somewhat arbitrary number
                animator.removeBehavior(panBehavior)
                animator.addBehavior(snapBehavior)
            }
            else {
                var nextIndex = self.index
                var position = TipViewPosition.RotatedRight
                var nextPosition = TipViewPosition.RotatedLeft
                
                if offset > 0 {
                    nextIndex -= 1
                    nextPosition = .RotatedLeft
                    position = .RotatedRight
                }
                else {
                    nextIndex += 1
                    nextPosition = .RotatedRight
                    position = .RotatedLeft
                }
                if nextIndex < 0 {
                    nextIndex = 0
                    nextPosition = .RotatedRight
                }
                
                let duration = 0.4
                let center = CGPoint(x: CGRectGetWidth(view.bounds)/2, y: CGRectGetHeight(view.bounds)/2)
                
                panBehavior.anchorPoint = position.viewCenter(center) // push current tip off of the screen
                
                // bring the new tip on the screen after duration seconds (0.4 s)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC))), dispatch_get_main_queue()){
                    [self]
                    
                    // if we have seen all the tips, dismiss tip view controller
                    if nextIndex >= self.tips.count {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    else {  // otherwise, we set up the next tip, read in the model, and set proper location for rotation in
                        self.index = nextIndex
                        self.setupTipView(self.tipView, index: nextIndex)
                        self.resetTipView(self.tipView, position: nextPosition)
                    }
                }
            }
        default:
            ()  // no-op
        }       // end of switch statement
    }           // end of panTipView
    
}               // end of class

/*******************************************************************************/

// This extension allow for easier creation of Tips, and setup characteristics of the VC
extension UIViewController {
    
    func presentTips(tips: [Tip], animated: Bool, completion: (() -> Void)?) {
        let controller = TipViewController()
        controller.tips = tips
        
        controller.modalPresentationStyle = .OverFullScreen
        controller.modalTransitionStyle = .CrossDissolve
        presentViewController(controller, animated: animated, completion: completion)
    }
}

