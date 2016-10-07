//
//  AnimationClass.swift
//  testApplicationCalendar
//
//  Created by JayT on 2016-03-06.
//  Copyright © 2016 OS-Tech. All rights reserved.
//

import UIKit
class AnimationClass {

    class func BounceEffect() -> (UIView, @escaping (Bool) -> Void) -> () {

        return {
            view, completion in
            view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(
                withDuration: 0.5,
                delay: 0, usingSpringWithDamping: 0.3,
                initialSpringVelocity: 0.1,
                options: UIViewAnimationOptions.beginFromCurrentState,
                animations: {
                    view.transform = CGAffineTransform(scaleX: 1, y: 1)
                },
                completion: completion
            )
        }

    }

    class func fadeOutEffect() -> (UIView, @escaping (Bool) -> Void) -> () {

        return {
            view, completion in
            UIView.animate(withDuration: 0.6,
                           delay: 0, usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0,
                           options: [],
                           animations: {
                                view.alpha = 0
                            },
                           completion: completion)
        }

    }

    fileprivate class func get3DTransformation(_ angle: Double) ->
                                                            CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 500.0
        transform = CATransform3DRotate(transform,
                                CGFloat(angle * M_PI / 180.0), 0, 1, 0.0)
        return transform
    }

    class func flipAnimation(_ view: UIView, completion: (() -> Void)?) {
        let angle = 180.0
        view.layer.transform = get3DTransformation(angle)
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: { () -> Void in
                            view.layer.transform = CATransform3DIdentity
                        }) { (finished) -> Void in
                            completion?()
        }
    }

}
