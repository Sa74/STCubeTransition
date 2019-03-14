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
private let kFlipAnimationKey = "FlipAnimation"
private let kDefaultFocalLength = 1000.0

/*
 Animation layer key to capture fromView
 */
private let fromViewKey = "FromView"

/*
 Cube transition direction options enum
 */
public enum CubeTransitionDirection : Int {
    case Down = 1, Up, Left, Right
}


fileprivate class Transition {
    
    let fromView: UIView
    let toView: UIView
    let overlayView: UIView
    let backgroundColor: UIColor
    
    var animationLayer: CALayer?
    
    /*
     * Completion closure that will get called every time
     * when the view transition is finished with contentView parameter
     */
    let completionHandler: (_ displayView: UIView) -> Void
    
    
    init(_ fromView: UIView, toView: UIView, overlayView: UIView, completion: @escaping (_ displayView: UIView) -> ()) {
        self.fromView = fromView
        self.toView = toView
        self.overlayView = overlayView
        self.backgroundColor = fromView.backgroundColor!
        self.completionHandler = completion
    }
}


open class CubeTransition: UIViewController, CAAnimationDelegate {
    
    private var focalLength:Double = 0.0
    private var transtionQueue = [UIView: Transition]()
    
    public func translateView(_ fromView: UIView, toView: UIView, direction: CubeTransitionDirection, duration: Float, completion: @escaping (_ displayView: UIView) -> ()) {
        
        if transtionQueue.keys.contains(fromView) {
            return
        }
        
        focalLength = kDefaultFocalLength
        
        let overlayView = UIView.init(frame: CGRect.init(origin: CGPoint.zero, size: fromView.frame.size))
        overlayView.alpha = 0
        overlayView.backgroundColor = fromView.superview?.backgroundColor
        fromView.addSubview(overlayView)
        
        let transition = Transition(fromView, toView: toView, overlayView: overlayView, completion: completion)
        
        let animationLayer = CALayer.init()
        animationLayer.frame = fromView.bounds
        
        var sublayerTransform:CATransform3D = CATransform3DIdentity
        sublayerTransform.m34 = CGFloat(1.0 / (-focalLength))
        animationLayer.sublayerTransform = sublayerTransform
        fromView.layer.addSublayer(animationLayer)
        
        var t:CATransform3D = CATransform3DMakeTranslation(0.0, 0.0, 0.0)
        let fadeOutLayer = fromView.fadeLayer(withTransform: t)
        animationLayer.addSublayer(fadeOutLayer)
        
        switch direction {
        case .Down:
            t = CATransform3DTranslate(t, 0, -fromView.bounds.size.height, 0);
            t = CATransform3DRotate(t, CGFloat(Double.pi/2), 1, 0, 0);
            
        case .Up:
            t = CATransform3DRotate(t, CGFloat(-(Double.pi/2)), 1, 0, 0);
            t = CATransform3DTranslate(t, 0, fromView.bounds.size.height, 0);
            
        case .Left:
            t = CATransform3DRotate(t, CGFloat(Double.pi/2), 0, 1, 0);
            t = CATransform3DTranslate(t, fromView.bounds.size.width, 0, 0);
            
        case .Right:
            t = CATransform3DTranslate(t, -fromView.bounds.size.width, 0, 0);
            t = CATransform3DRotate(t, CGFloat(-(Double.pi/2)), 0, 1, 0);
        }
        
        let fadeInLayer = toView.fadeLayer(withTransform: t)
        animationLayer.addSublayer(fadeInLayer)
        
        fromView.backgroundColor = UIColor.clear
        overlayView.alpha = 1
        
        rotateInDirection(transition: transition, direction: direction, animationLayer: animationLayer, duration: duration)
    }
    
    fileprivate func rotateInDirection(transition: Transition, direction: CubeTransitionDirection, animationLayer: CALayer, duration: Float) {
        
        CATransaction.flush()
        var rotation:CABasicAnimation?
        var translation:CABasicAnimation?
        var translationZ:CABasicAnimation?
        
        let group:CAAnimationGroup = CAAnimationGroup.init()
        group.delegate = self
        group.duration = CFTimeInterval(duration)
        group.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        
        switch direction {
        case .Down:
            let toValue:Float = Float(transition.fromView.bounds.size.height / 2)
            translation = CABasicAnimation.init(keyPath: "sublayerTransform.translation.y")
            translation?.toValue = NSNumber.init(value: toValue)
            rotation = CABasicAnimation.init(keyPath: "sublayerTransform.rotation.x")
            rotation?.toValue = NSNumber.init(value: -(Double.pi/2))
            translationZ = CABasicAnimation.init(keyPath: "sublayerTransform.translation.z")
            translationZ?.toValue = NSNumber.init(value: -toValue)
            
        case .Up:
            let toValue:Float = Float(transition.fromView.bounds.size.height / 2)
            translation = CABasicAnimation.init(keyPath: "sublayerTransform.translation.y")
            translation?.toValue = NSNumber.init(value: -toValue)
            rotation = CABasicAnimation.init(keyPath: "sublayerTransform.rotation.x")
            rotation?.toValue = NSNumber.init(value: (Double.pi/2))
            translationZ = CABasicAnimation.init(keyPath: "sublayerTransform.translation.z")
            translationZ?.toValue = NSNumber.init(value: -toValue)
            
        case .Left:
            let toValue:Float = Float(transition.fromView.bounds.size.width / 2)
            translation = CABasicAnimation.init(keyPath: "sublayerTransform.translation.x")
            translation?.toValue = NSNumber.init(value: -toValue)
            rotation = CABasicAnimation.init(keyPath: "sublayerTransform.rotation.y")
            rotation?.toValue = NSNumber.init(value: -(Double.pi/2))
            translationZ = CABasicAnimation.init(keyPath: "sublayerTransform.translation.z")
            translationZ?.toValue = NSNumber.init(value: -toValue)
            
        case .Right:
            let toValue:Float = Float(transition.fromView.bounds.size.width / 2)
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
        group.setValue(transition.fromView, forKey: fromViewKey)
        
        CATransaction.begin()
        animationLayer.add(group, forKey: kFlipAnimationKey)
        
        transition.animationLayer = animationLayer
        transtionQueue[transition.fromView] = transition
        
        CATransaction.commit()
    }
    
    
    // MARK: CAAnimation delegate methods
    public func animationDidStop(_ animation:CAAnimation, finished:Bool) {
        
        guard let fromView = animation.value(forKey: fromViewKey) as? UIView else {
            return
        }
        
        guard let transtion = transtionQueue[fromView] else {
            return
        }
        
        let overlayView = transtion.overlayView
        overlayView.removeFromSuperview()
        
        let contentView = transtion.toView
        contentView.frame = fromView.frame
        
        fromView.backgroundColor = transtion.backgroundColor
        if (fromView.superview!.subviews.contains(contentView) == false) {
            fromView.superview!.addSubview(contentView)
        } else {
            fromView.superview!.bringSubviewToFront(contentView)
        }
        
        let animationLayer = transtion.animationLayer
        animationLayer?.removeFromSuperlayer()
        fromView.layer.removeAllAnimations()
        contentView.layer.removeAllAnimations()
        
        transtion.completionHandler(contentView)
        transtionQueue.removeValue(forKey: fromView)
    }
}

fileprivate extension UIView {
    
    func fadeLayer(withTransform transform:CATransform3D) -> CALayer {
        
        let imageLayer:CALayer = CALayer.init()
        imageLayer.anchorPoint = CGPoint.init(x: 1.0, y: 1.0)
        imageLayer.frame = bounds
        imageLayer.transform = transform
        
        //Capture View
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        imageLayer.contents = newImage.cgImage
        return imageLayer
    }
}



