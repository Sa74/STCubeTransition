//
//  STCubeTransition.swift
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

/**
 A custom modal transition that presents and dismiss a controller with 3D cube roate effect.
 */

/*
 Flip animation key for animation layer
 */
let kFlipAnimationKey = "FlipAnimation"
let kDefaultFocalLength = 1000.0

/*
 Cube transition direction options enum
 */
public enum CubeTransitionDirection : Int {
    case Down = 1, Up, Left, Right
}

/*
 Cube transition delegate to handle animation completion
 */
@objc public protocol CubeTransitionDelegate: class {
    @objc optional func animationDidFinishWithView(displayView: UIView)
}

open class CubeTransition: UIViewController, CAAnimationDelegate {
    
    private var isAnimating:Bool = false
    
    private var animationLayer:CALayer?
    private var fadeOutLayer:CALayer?
    private var fadeInLayer:CALayer?
    
    private var contentView:UIView?
    private var overlayView:UIView?
    private var rootView:UIView!
    
    private var focalLength:Double = 0.0
    private var fillContentViewToBounds:Bool = false
    private var rootViewColor:UIColor!
    
    public weak var delegate:CubeTransitionDelegate?
    
    public func translateView(faceView:UIView, withView hiddenView:UIView, toDirection aDirection:CubeTransitionDirection, withDuration duration:Float) {
        
        contentView = hiddenView
        focalLength = kDefaultFocalLength
        if (isAnimating) {
            return
        }
        
        rootView = faceView
        overlayView = UIView.init(frame: CGRect.init(origin: CGPoint.zero, size: rootView!.frame.size))
        overlayView!.alpha = 0
        overlayView!.backgroundColor = rootView.superview?.backgroundColor
        rootView!.addSubview(overlayView!)
        
        animationLayer = CALayer.init()
        animationLayer?.frame = faceView.bounds
        
        var sublayerTransform:CATransform3D = CATransform3DIdentity
        sublayerTransform.m34 = CGFloat(1.0 / (-focalLength))
        animationLayer?.sublayerTransform = sublayerTransform
        rootView?.layer.addSublayer(animationLayer!)
        
        var t:CATransform3D = CATransform3DMakeTranslation(0.0, 0.0, 0.0)
        fadeOutLayer =  layerFromView(aView: faceView, withTransform: t)
        animationLayer?.addSublayer(fadeOutLayer!)
        
        let v:UIView = UIView.init(frame: rootView!.bounds)
        v.backgroundColor = UIColor.darkGray;
        
        switch aDirection {
        case .Down:
            t = CATransform3DTranslate(t, 0, -rootView.bounds.size.height, 0);
            t = CATransform3DRotate(t, CGFloat(Double.pi/2), 1, 0, 0);
            
        case .Up:
            t = CATransform3DRotate(t, CGFloat(-(Double.pi/2)), 1, 0, 0);
            t = CATransform3DTranslate(t, 0, rootView.bounds.size.height, 0);
            
        case .Left:
            t = CATransform3DRotate(t, CGFloat(Double.pi/2), 0, 1, 0);
            t = CATransform3DTranslate(t, rootView.bounds.size.width, 0, 0);
            
        case .Right:
            t = CATransform3DTranslate(t, -rootView.bounds.size.width, 0, 0);
            t = CATransform3DRotate(t, CGFloat(-(Double.pi/2)), 0, 1, 0);
        }
        
        fadeInLayer = layerFromView(aView: hiddenView, withTransform: t)
        animationLayer?.addSublayer(fadeInLayer!)
        
        v.frame = hiddenView.frame
        rootViewColor = rootView!.backgroundColor
        rootView!.backgroundColor = UIColor.clear
        overlayView!.alpha = 1
        rotateInDirection(aDirection: aDirection, duration: duration)
    }
    
    func layerFromView(aView:UIView, withTransform transform:CATransform3D) -> CALayer {
        
        let rect:CGRect = CGRect.init(x: 0.0,
                                      y: rootView.frame.size.height - aView.bounds.size.height,
                                      width: aView.bounds.size.width,
                                      height: aView.bounds.size.height)
        
        let imageLayer:CALayer = CALayer.init()
        imageLayer.anchorPoint = CGPoint.init(x: 1.0, y: 1.0)
        imageLayer.frame = rect
        imageLayer.transform = transform
        
        //Capture View
        UIGraphicsBeginImageContextWithOptions(aView.frame.size, false, 0)
        aView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        imageLayer.contents = newImage.cgImage
        return imageLayer
    }
    
    
    func rotateInDirection(aDirection:CubeTransitionDirection, duration aDuration:Float) {
        CATransaction.flush()
        var rotation:CABasicAnimation?
        var translation:CABasicAnimation?
        var translationZ:CABasicAnimation?
        
        let group:CAAnimationGroup = CAAnimationGroup.init()
        group.delegate = self
        group.duration = CFTimeInterval(aDuration)
        group.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        
        switch aDirection {
        case .Down:
            let toValue:Float = Float(rootView.bounds.size.height / 2)
            translation = CABasicAnimation.init(keyPath: "sublayerTransform.translation.y")
            translation?.toValue = NSNumber.init(value: toValue)
            rotation = CABasicAnimation.init(keyPath: "sublayerTransform.rotation.x")
            rotation?.toValue = NSNumber.init(value: -(Double.pi/2))
            translationZ = CABasicAnimation.init(keyPath: "sublayerTransform.translation.z")
            translationZ?.toValue = NSNumber.init(value: -toValue)
            
        case .Up:
            let toValue:Float = Float(rootView.bounds.size.height / 2)
            translation = CABasicAnimation.init(keyPath: "sublayerTransform.translation.y")
            translation?.toValue = NSNumber.init(value: -toValue)
            rotation = CABasicAnimation.init(keyPath: "sublayerTransform.rotation.x")
            rotation?.toValue = NSNumber.init(value: (Double.pi/2))
            translationZ = CABasicAnimation.init(keyPath: "sublayerTransform.translation.z")
            translationZ?.toValue = NSNumber.init(value: -toValue)
            
        case .Left:
            let toValue:Float = Float(rootView.bounds.size.width / 2)
            translation = CABasicAnimation.init(keyPath: "sublayerTransform.translation.x")
            translation?.toValue = NSNumber.init(value: -toValue)
            rotation = CABasicAnimation.init(keyPath: "sublayerTransform.rotation.y")
            rotation?.toValue = NSNumber.init(value: -(Double.pi/2))
            translationZ = CABasicAnimation.init(keyPath: "sublayerTransform.translation.z")
            translationZ?.toValue = NSNumber.init(value: -toValue)
            
        case .Right:
            let toValue:Float = Float(rootView.bounds.size.width / 2)
            translation = CABasicAnimation.init(keyPath: "sublayerTransform.translation.x")
            translation?.toValue = NSNumber.init(value: toValue)
            rotation = CABasicAnimation.init(keyPath: "sublayerTransform.rotation.y")
            rotation?.toValue = NSNumber.init(value: (Double.pi/2))
            translationZ = CABasicAnimation.init(keyPath: "sublayerTransform.translation.z")
            translationZ?.toValue = NSNumber.init(value: -toValue)
        }
        
        group.animations = [rotation!, translation!, translationZ!]
        group.fillMode = CAMediaTimingFillMode.forwards
        group.isRemovedOnCompletion = false
        
        CATransaction.begin()
        animationLayer?.add(group, forKey: kFlipAnimationKey)
        CATransaction.commit()
    }
    
    
    // MARK: CAAnimation delegate methods
    public func animationDidStop(_ animation:CAAnimation, finished:Bool) {
        overlayView?.removeFromSuperview()
        overlayView = nil
        rootView!.backgroundColor = rootViewColor
        contentView!.frame = rootView.frame
        if (rootView.superview?.subviews.contains(contentView!) == false) {
            rootView.superview?.addSubview(contentView!)
        } else {
            rootView.superview?.bringSubviewToFront(contentView!)
        }
        
        delegate?.animationDidFinishWithView?(displayView: contentView!)
        animationLayer!.removeFromSuperlayer()
        rootView.layer.removeAllAnimations()
        contentView?.layer.removeAllAnimations()
        isAnimating = false
    }
}



