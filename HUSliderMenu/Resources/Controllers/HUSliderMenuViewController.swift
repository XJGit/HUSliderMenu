//
//  ViewController.swift
//  HUSliderMenu
//
//  Created by jewelz on 15/7/13.
//  Copyright (c) 2015年 yangtzeu. All rights reserved.
//

import UIKit

class HUSliderMenuViewController: UIViewController, HULeftMenuDelegate, HULeftMenuDataSource, UIGestureRecognizerDelegate {
    
    ///是否允许缩放效果
    var allowTransformWithScale = true
    
    ///是否允许弹簧效果
    var allowSpringAnimation = true
    
    //设置菜单按钮标题
    var leftMenuBarItemTitle: String = "Menu"
    
    //设置菜单按钮图标
    var leftMenuBarItemImage: String = "menu.png"
    
    var menuView: HULeftMenu!
   
    private var bg: UIImageView!
    private var currentViewController: UIViewController!
    private var contentViewControllers: [UIViewController] = []
    private var menuWidth: CGFloat = 0.0
    private let scale: CGFloat = 0.78
    private let animationDuration: NSTimeInterval = 0.5
    private let springDamping: CGFloat = 0.7
    private let springVelocity: CGFloat = 20
    private let maskTag = 10
    private var canMoveLeft = false
    
    private let sWidth = UIScreen.mainScreen().bounds.width
    
    var backgroundImage: UIImage {  //设置左侧菜单背景图片
        set {
            bg.image = newValue
        }
        get {
            return bg.image!
        }
    }
    
   
   // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bg = UIImageView(frame: view.bounds)
        view.addSubview(bg)
        
        let width = UIScreen.mainScreen().bounds.width * scale
        let height = UIScreen.mainScreen().bounds.height
       
        var leftMenu = HULeftMenu(frame: CGRect(x: 0, y: 0, width: width, height: height))
        leftMenu.delegate = self
        leftMenu.dataSoruce = self
        view.addSubview(leftMenu)
        
        self.menuWidth = width
        
        self.menuView = leftMenu
        
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panGestureHandle:"))
        
    }
    
    //MARK: - API
    var viewControllers: [UIViewController] {
        set {
            
            for viewController in newValue {
                self.setupViewController(viewController)
            }
            contentViewControllers = self.childViewControllers as! [UIViewController]
            view.addSubview(contentViewControllers[0].view)
            self.currentViewController = contentViewControllers[0]
        }
        
        get {
            return contentViewControllers
        }
    }

    
    func numberOfItems() -> Int {
        return 0
    }
    
    func leftMenu(menu: HULeftMenu, menuItemAtIndex index: Int) -> AnyObject {
        let item = menu.menuItemAtIndex(index) as! HUMenuItenCell
        return item
    }
    
    func leftMenu(menu: HULeftMenu, didSelectedItemAtIndex index: Int, toNewItem newIndex: Int) {
       
        if index >= self.contentViewControllers.count {
            return
        }
        
        if newIndex >= self.contentViewControllers.count {
            return
        }
        
        let oldVc = self.contentViewControllers[index] as! UINavigationController
        oldVc.view.removeFromSuperview()
        oldVc.removeFromParentViewController()
        
        let newVc = self.contentViewControllers[newIndex] as! UINavigationController
        
        view.addSubview(newVc.view)
        newVc.view.transform = oldVc.view.transform
        self.addChildViewController(newVc)
        
        self.currentViewController = newVc
        
        self.viewAnimationWithSpring(allowSpringAnimation, animation: { () -> () in
            newVc.view.transform = CGAffineTransformIdentity
        })
        
//        if allowSpringAnimation {
//            
//            UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: springDamping, initialSpringVelocity: springVelocity, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
//                newVc.view.transform = CGAffineTransformIdentity
//            }, completion: { (finished) -> Void in
//                
//            })
//        
//        } else {
//            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
//                newVc.view.transform = CGAffineTransformIdentity
//            })
//        }
        
        //移除遮盖
        self.currentViewController.view.viewWithTag(maskTag)?.removeFromSuperview()
        
        canMoveLeft = true
    }
    
    
     func sliderLeft() {
 
        self.viewAnimationWithSpring(allowSpringAnimation, animation: { () -> () in
            //self.showLeftMenu()
            var mask = UIButton.buttonWithType(.Custom) as! UIButton
            mask.tag = self.maskTag
            mask.frame = self.currentViewController.view.frame
            mask.addTarget(self, action: "hideLeftMenu:", forControlEvents: .TouchUpInside)
            self.currentViewController.view.addSubview(mask)
            
            let leftPadding = self.sWidth * (1-self.scale) * 0.5
            let tX = self.menuWidth - leftPadding
            
            if CGAffineTransformIsIdentity(self.currentViewController.view.transform) {
                
                self.canMoveLeft = true
                
                var trans = CGAffineTransformMakeTranslation(self.sWidth*self.scale, 0)
                
                if self.allowTransformWithScale {
                    var scaleform = CGAffineTransformMakeScale(self.scale, self.scale)
                    trans = CGAffineTransformTranslate(scaleform, tX/self.scale, 0);
                    
                }
                
                self.currentViewController.view.transform = trans
                
                
            } else {
                self.canMoveLeft = false
                self.currentViewController.view.transform = CGAffineTransformIdentity
                
            }
            
        })
        
    }
    
    //MARK: - maskButton clicked hidden the menu
    func hideLeftMenu(sender: UIButton) {   //点击右侧关闭
        //println("hideLeftMenu")
        self.hiddenLeftMenu()
        sender.removeFromSuperview()
    }
    
    //MARK: - handle gesture
    func panGestureHandle(recognizer: UIPanGestureRecognizer) {
        var offsetX: CGFloat = 0.0, ex: CGFloat = 0.0
        
        if recognizer.state == .Changed {
            
             offsetX = recognizer.translationInView(view).x
            if offsetX < 0 { //左滑
                if canMoveLeft {
                   //self.transWithOffSet(offsetX)
                    self.transformTranslate(true, withOffset: offsetX)
                    
                   println("origin : \(currentViewController.view.frame.origin.x)")
                    
                    if currentViewController.view.frame.origin.x < 0 {
                        self.hiddenLeftMenu()
                    }
                }
            }
            
            

            if offsetX > 0 { //右滑
                //self.transRightWithOffSet(offsetX)
                if currentViewController.view.frame.origin.x >= sWidth*scale { return }
                println("pan right")
                self.transformTranslate(false, withOffset: offsetX)
            }
            // println("offsetX: \(offsetX)")
            return
        }
        
        if recognizer.state == .Ended {
             var ex = recognizer.translationInView(view).x
            if abs(ex) > sWidth * 0.5 {
               // self.transRightWithOffSet(sWidth*scale)
                self.transformTranslate(false, withOffset: sWidth*scale)
                
            } else {
                self.hiddenLeftMenu()
            }
           // println("ex: \(ex)")
        }
       
            //self.sliderLeft()
     }
    
    // MARK: only for pangesture
//    private func transWithOffSet(offset: CGFloat) {
//       // canMoveLeft = true
//
//        if allowSpringAnimation {
//            UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: springDamping, initialSpringVelocity: springVelocity, options: nil, animations: { () -> Void in
//                
//                var trans = CGAffineTransformTranslate(self.currentViewController.view.transform, offset, 0)
//                self.currentViewController.view.transform = trans
//                }, completion: { (finished) -> Void in
//                    
//            })
//        } else {
//            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
//                var trans = CGAffineTransformMakeTranslation(offset, 0)
//                self.currentViewController.view.transform = trans
//                
//            })
//        }
//        
//    }

    //MARK: - 通过滑动位置处理菜单位置 translate为true向左划，false右划
    private func transformTranslate(translae: Bool, withOffset offset: CGFloat) {
        // canMoveLeft = true
        var trans: CGAffineTransform?
        self.viewAnimationWithSpring(allowSpringAnimation, animation: { () -> () in
            if translae {
                trans = CGAffineTransformTranslate(self.currentViewController.view.transform, offset, 0)
            } else {
                self.canMoveLeft = true
                trans = CGAffineTransformMakeTranslation(offset, 0)
            }
            self.currentViewController.view.transform = trans!
        })
        
//        if allowSpringAnimation {
//            UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: springDamping, initialSpringVelocity: springVelocity, options: nil, animations: { () -> Void in
//                
//                var trans = CGAffineTransformTranslate(self.currentViewController.view.transform, offset, 0)
//                self.currentViewController.view.transform = trans
//                }, completion: { (finished) -> Void in
//                    
//            })
//        } else {
//            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
//                var trans = CGAffineTransformMakeTranslation(offset, 0)
//                self.currentViewController.view.transform = trans
//                
//            })
//        }
        
    }
    
//    private func transRightWithOffSet(offset: CGFloat) {
//        canMoveLeft = true
//        var trans: CGAffineTransform?
//        if allowSpringAnimation {
//            
//            UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: springDamping, initialSpringVelocity: springVelocity, options: nil, animations: { () -> Void in
//                
//                trans = CGAffineTransformMakeTranslation(offset, 0)
//                self.currentViewController.view.transform = trans!
//                
//                }, completion: { (finished) -> Void in
//                    
//            })
//        } else {
//            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
//                trans = CGAffineTransformMakeTranslation(offset, 0)
//                
//            })
//        }
//        self.currentViewController.view.transform = trans!
//    }
    
    private func hiddenLeftMenu() {
        
        println("-------------hiddenLeftMenu--------------")
        
        self.viewAnimationWithSpring(allowSpringAnimation, animation: { () -> () in
            self.currentViewController.view.transform = CGAffineTransformIdentity
        })
        
//        if allowSpringAnimation {
//            UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: springDamping, initialSpringVelocity: springVelocity, options: nil, animations: { () -> Void in
//                
//                self.currentViewController.view.transform = CGAffineTransformIdentity
//                
//                }, completion: { (finished) -> Void in
//                    
//            })
//        } else {
//            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
//                self.currentViewController.view.transform = CGAffineTransformIdentity
//            })
//        }
        
        canMoveLeft = false
    }
    
    
    //MARK - gestureRecognizer delegate
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let nav: UINavigationController = self.currentViewController as? UINavigationController {
            if nav.viewControllers.count == 1 {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - private func
    
    /*private func showLeftMenu() {
    
        

        
    }*/
    
    private func viewAnimationWithSpring(spring: Bool, animation:() -> ()) {
        if spring {
            UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: springDamping, initialSpringVelocity: springVelocity, options: nil, animations: { () -> Void in
                
                animation()
                
                }, completion: { (finished) -> Void in
                    
            })
            
        } else {
            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                
                animation()
            })
        }
    }

    
    private func setupViewController(viewController: UIViewController) {
       
        let leftBtn = self.leftMenuBarItem()
        
        let nav = UINavigationController(rootViewController: viewController)
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        
        self.addChildViewController(nav)
    }
    
   private func leftMenuBarItem() -> UIButton {
        let leftBtn = UIButton.buttonWithType(.Custom) as! UIButton
        leftBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 44)
    
    
        if let image =  UIImage(named: self.leftMenuBarItemImage) {
            leftBtn.setImage(image, forState:.Normal)
            leftBtn.contentHorizontalAlignment = .Left
        } else {
            leftBtn.setTitle(self.leftMenuBarItemTitle, forState: .Normal)
            leftBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        }
    
    
        leftBtn.addTarget(self, action: "sliderLeft", forControlEvents: .TouchUpInside)
    
        return leftBtn
    }
    
  

}

