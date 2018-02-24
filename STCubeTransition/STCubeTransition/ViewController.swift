//
//  ViewController.swift
//  STCubeTransition
//
//  Created by Sasi M on 23/02/18.
//  Copyright © 2018 LeanSwift Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CubeTransitionDelegate {
    
    @IBOutlet var faceView:UIView?
    var subMenu:UIView?
    
    let cubeTranstion:CubeTransition = CubeTransition()
    
    func animationDidFinishWithView(displayView: UIView) {
        self.faceView?.backgroundColor = self.subMenu?.backgroundColor
        self.subMenu?.removeFromSuperview()
        self.subMenu = nil
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        cubeTranstion.delegate = self
    }

    @IBAction func buttonTappen(sender: UIButton) {
        
        self.subMenu = UIView.init(frame: self.faceView!.bounds);
        
        let direction:CubeTransitionDirection = CubeTransitionDirection(rawValue: sender.tag)!
        
        switch direction {
        case .Down:
            subMenu!.backgroundColor = UIColor.red
        
        case .Up:
            subMenu!.backgroundColor = UIColor.blue
            
        case .Left:
            subMenu!.backgroundColor = UIColor.green
            
        case .Right:
            subMenu!.backgroundColor = UIColor.purple
        }
        
        cubeTranstion.translateView(faceView: self.faceView,
                                    withView: subMenu!,
                                    toDirection: direction,
                                    withDetlay: 0.5)
    }


}

