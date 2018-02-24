//
//  STCubeTransition.swift
//  STCubeTransition
//
//  Created by Sasi M on 23/02/18.
//  Copyright © 2018 LeanSwift Inc. All rights reserved.
//

import UIKit

/**
 A custom modal transition that presents and dismiss a controller with 3D cube roate effect.
 */

let kFlipAnimationKey = "FlipAnimation"
let kFadeOutAnimationKey = "FadeOutAnimation"
let kFadeInAnimationKey = "FadeInAnimation"
let kDefaultFocalLength = 1000.0

enum CubeTransitionDirection : Int {
    case Down = 1, Up, Left, Right
}

protocol CubeTransitionDelegate: class {
    func animationDidFinishWithView(displayView: UIView)
}

open class CubeTransition: UIViewController, CAAnimationDelegate {

    var isAnimating:Bool = false
    
    var animationLayer:CALayer?
    var fadeOutLayer:CALayer?
    var fadeInLayer:CALayer?
    
    var contentView:UIView?
    var rootView:UIView!
    
    var focalLength:Double = 0.0
    var fillContentViewToBounds:Bool = false
    
    
    var delegate:CubeTransitionDelegate?
    
    func translateView(faceView:UIView, withView hiddenView:UIView, toDirection aDirection:CubeTransitionDirection, withDetlay delay:Float) {
        
        self.contentView = hiddenView
        
        self.focalLength = kDefaultFocalLength
        
        if (isAnimating) {
            return
        }
        
        self.rootView = faceView
        self.animationLayer = CALayer.init()
        animationLayer?.frame = faceView.bounds
        
        var sublayerTransform:CATransform3D = CATransform3DIdentity
        sublayerTransform.m34 = CGFloat(1.0 / (-self.focalLength))
        animationLayer?.sublayerTransform = sublayerTransform
        rootView?.layer.addSublayer(animationLayer!)
    
        var t:CATransform3D = CATransform3DMakeTranslation(0.0, 0.0, 0.0)
        self.fadeOutLayer =  self.layerFromView(aView: faceView, withTransform: t)
        animationLayer?.addSublayer(self.fadeOutLayer!)
    
        let v:UIView = UIView.init(frame: rootView!.bounds)
        v.backgroundColor = UIColor.darkGray;
    
        switch aDirection {
        case .Down:
            t = CATransform3DTranslate(t, 0, -self.rootView.bounds.size.height, 0);
            t = CATransform3DRotate(t, CGFloat(Double.pi/2), 1, 0, 0);
            
        case .Up:
            t = CATransform3DRotate(t, CGFloat(-(Double.pi/2)), 1, 0, 0);
            t = CATransform3DTranslate(t, 0, self.rootView.bounds.size.height, 0);
            
        case .Left:
            t = CATransform3DRotate(t, CGFloat(Double.pi/2), 0, 1, 0);
            t = CATransform3DTranslate(t, self.rootView.bounds.size.width, 0, 0);
            
        case .Right:
            t = CATransform3DTranslate(t, -self.rootView.bounds.size.width, 0, 0);
            t = CATransform3DRotate(t, CGFloat(-(Double.pi/2)), 0, 1, 0);
        }
    
        self.fadeInLayer = self.layerFromView(aView: hiddenView, withTransform: t)
        animationLayer?.addSublayer(self.fadeInLayer!)
        
        v.frame = hiddenView.frame
        self.rootView!.backgroundColor = UIColor.clear
        self.rotateInDirection(aDirection: aDirection, duration: delay)
    }
    
    func layerFromView(aView:UIView, withTransform transform:CATransform3D) -> CALayer {
    
        let rect:CGRect = CGRect.init(x: 0.0,
                                      y: self.rootView.frame.size.height - aView.bounds.size.height,
                                      width: aView.bounds.size.width,
                                      height: aView.bounds.size.height)
        
        let imageLayer:CALayer = CALayer.init()
        imageLayer.anchorPoint = CGPoint.init(x: 1.0, y: 1.0)
        imageLayer.frame = rect
        imageLayer.transform = transform
    
        //Capture View
        UIGraphicsBeginImageContext(aView.frame.size)
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
        group.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        
        switch aDirection {
        case .Down:
            let toValue:Float = Float(self.rootView.bounds.size.height / 2)
            translation = CABasicAnimation.init(keyPath: "sublayerTransform.translation.y")
            translation?.toValue = NSNumber.init(value: toValue)
            rotation = CABasicAnimation.init(keyPath: "sublayerTransform.rotation.x")
            rotation?.toValue = NSNumber.init(value: -(Double.pi/2))
            translationZ = CABasicAnimation.init(keyPath: "sublayerTransform.translation.z")
            translationZ?.toValue = NSNumber.init(value: -toValue)
            
        case .Up:
            let toValue:Float = Float(self.rootView.bounds.size.height / 2)
            translation = CABasicAnimation.init(keyPath: "sublayerTransform.translation.y")
            translation?.toValue = NSNumber.init(value: -toValue)
            rotation = CABasicAnimation.init(keyPath: "sublayerTransform.rotation.x")
            rotation?.toValue = NSNumber.init(value: (Double.pi/2))
            translationZ = CABasicAnimation.init(keyPath: "sublayerTransform.translation.z")
            translationZ?.toValue = NSNumber.init(value: -toValue)
            
        case .Left:
            let toValue:Float = Float(self.rootView.bounds.size.width / 2)
            translation = CABasicAnimation.init(keyPath: "sublayerTransform.translation.x")
            translation?.toValue = NSNumber.init(value: -toValue)
            rotation = CABasicAnimation.init(keyPath: "sublayerTransform.rotation.y")
            rotation?.toValue = NSNumber.init(value: -(Double.pi/2))
            translationZ = CABasicAnimation.init(keyPath: "sublayerTransform.translation.z")
            translationZ?.toValue = NSNumber.init(value: -toValue)
            
        case .Right:
            let toValue:Float = Float(self.rootView.bounds.size.width / 2)
            translation = CABasicAnimation.init(keyPath: "sublayerTransform.translation.x")
            translation?.toValue = NSNumber.init(value: toValue)
            rotation = CABasicAnimation.init(keyPath: "sublayerTransform.rotation.y")
            rotation?.toValue = NSNumber.init(value: (Double.pi/2))
            translationZ = CABasicAnimation.init(keyPath: "sublayerTransform.translation.z")
            translationZ?.toValue = NSNumber.init(value: -toValue)
        }
        
        group.animations = [rotation!, translation!, translationZ!]
        group.fillMode = kCAFillModeForwards
        group.isRemovedOnCompletion = false
    
        CATransaction.begin()
        animationLayer?.add(group, forKey: kFlipAnimationKey)
        CATransaction.commit()
    }
    
    
    
    // MARK: Animation Delegate
    
    public func animationDidStart(_ anim: CAAnimation) {
        self.isAnimating = true
    }
    
    public func animationDidStop(_ animation:CAAnimation, finished:Bool) {
        self.delegate?.animationDidFinishWithView(displayView: contentView!)
        self.animationLayer!.removeFromSuperlayer()
        self.rootView.layer.removeAllAnimations()
        self.contentView?.layer.removeAllAnimations()
        self.isAnimating = false
    }
}



