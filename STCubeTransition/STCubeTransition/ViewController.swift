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
        
        cubeTranstion.translateView(faceView: self.faceView!,
                                    withView: subMenu!,
                                    toDirection: direction,
                                    withDetlay: 0.5)
    }


}

