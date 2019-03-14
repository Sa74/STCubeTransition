//
//  ViewController.swift
//  STCubeTransition
//
//  Created by Sasi M on 23/02/18.
//  Copyright © 2018 Sasi Moorthy.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var faceView:UIView?
    @IBOutlet var faceView1:UIView?
    var subMenu:UIView?
    var subMenu1:UIView?
    
    let cubeTranstion:CubeTransition = CubeTransition()
    
    @IBAction func buttonTappen(sender: UIButton) {
        
        if (subMenu == nil) {
            subMenu = UIView.init(frame: faceView!.bounds);
            subMenu1 = UIView.init(frame: faceView1!.bounds);
        } else {
            subMenu!.removeFromSuperview()
            subMenu1!.removeFromSuperview()
        }
        
        let direction:CubeTransitionDirection = CubeTransitionDirection(rawValue: sender.tag)!
        
        switch direction {
        case .Down:
            subMenu!.backgroundColor = UIColor.red
            subMenu1!.backgroundColor = UIColor.gray
        
        case .Up:
            subMenu!.backgroundColor = UIColor.blue
            subMenu1!.backgroundColor = UIColor.brown
            
        case .Left:
            subMenu!.backgroundColor = UIColor.green
            subMenu1!.backgroundColor = UIColor.orange
            
        case .Right:
            subMenu!.backgroundColor = UIColor.purple
            subMenu1!.backgroundColor = UIColor.yellow
        }
        
        cubeTranstion.translateView(faceView!, toView: subMenu!, direction: direction, duration: 0.5) { [weak self] (displayView) in
            self!.faceView?.backgroundColor = displayView.backgroundColor
        }
        
        cubeTranstion.translateView(faceView1!, toView: subMenu1!, direction: direction, duration: 0.5) { [weak self] (displayView) in
            self!.faceView1?.backgroundColor = displayView.backgroundColor
        }
    }
}

