//
//  Presentr.swift
//  Presentr
//
//  Created by Daniel Lozano on 5/10/16.
//  Copyright © 2016 Icalia Labs. All rights reserved.
//

import Foundation
import UIKit

struct PresentrConstants {
    struct Values {
        static let defaultSideMargin: Float = 30.0
        static let defaultHeightPercentage: Float = 0.66
    }
    struct Strings {
        static let alertTitle = "Alert"
        static let alertBody = "This is an alert."
    }
}

/// Main Presentr class. This is the point of entry for using the framework.
public class Presentr: NSObject {

    /// This must be set during initialization, but can be changed to reuse a Presentr object.
    public var presentationType: PresentationType
    
    /// The type of transition animation to be used to present the view controller. This is optional, if not provided the default for each presentation type will be used.
    public var transitionType: TransitionType?

    /// Should the presented controller have rounded corners. Default is true, except for .BottomHalf and .TopHalf presentation types.
    public var roundCorners = true
    
    /// Should the presented controller dismiss on background tap. Default is true, except for .BottomHalf and .TopHalf presentation types.
    public var dismissOnTap = true
    
    // MARK: Init
    
    public init(presentationType: PresentationType){
        self.presentationType = presentationType
    }
    
    // MARK: Class Helper Methods
    
    /**
     Public helper class method for creating and configuring an instance of the 'AlertViewController'
     
     - parameter title: Title to be used in the Alert View Controller.
     - parameter body: Body of the message to be displayed in the Alert View Controller.
     
     - returns: Returns a configured instance of 'AlertViewController'
     */
    public static func alertViewController(title title: String = PresentrConstants.Strings.alertTitle, body: String = PresentrConstants.Strings.alertBody) -> AlertViewController {
        let bundle = NSBundle(forClass: self)
        let alertController = AlertViewController(nibName: "Alert", bundle: bundle)
        alertController.titleText = title
        alertController.bodyText = body
        return alertController
    }
    
    // MARK: Private Methods

    /**
     Private method for presenting a view controller, using the custom presentation. Called from the UIViewController extension.
     
     - parameter presentingVC: The view controller which is doing the presenting.
     - parameter presentedVC:  The view controller to be presented.
     - parameter animated:     Animation boolean.
     - parameter completion:   Completion block.
     */
    private func presentViewController(presentingViewController presentingVC: UIViewController, presentedViewController presentedVC: UIViewController, animated: Bool, completion: (() -> Void)?){
        let transition = transitionType ?? presentationType.defaultTransitionType()
        if let systemTransition = transition.systemTransition(){
            presentedVC.modalTransitionStyle = systemTransition
        }
        presentedVC.transitioningDelegate = self
        presentedVC.modalPresentationStyle = .Custom
        presentingVC.presentViewController(presentedVC, animated: animated, completion: nil)
    }

}

// MARK: - UIViewControllerTransitioningDelegate

extension Presentr: UIViewControllerTransitioningDelegate{
    
    public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return presentationController(presented, presenting: presenting)
    }
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        return animation()
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        return animation()
    }
    
    // MARK: - Private Helper's
    
    private func presentationController(presented: UIViewController, presenting: UIViewController) -> PresentrController {
        let presentationController = PresentrController(presentedViewController: presented,
                                                        presentingViewController: presenting,
                                                        presentationType: presentationType,
                                                        roundCorners: roundCorners,
                                                        dismissOnTap: dismissOnTap)
        return presentationController
    }
    
    private func animation() -> PresentrAnimation?{
        if let animation = transitionType?.animation() {
            return animation
        }else{
            return nil
        }
    }
    
}

// MARK: - UIViewController extension to provide customPresentViewController(_:viewController:animated:completion:) method

public extension UIViewController {
    func customPresentViewController(presentr: Presentr, viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        presentr.presentViewController(presentingViewController: self,
                                       presentedViewController: viewController,
                                       animated: animated,
                                       completion: completion)
    }
}
