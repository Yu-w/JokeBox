//
//  ViewController.swift
//  JokeBox
//
//  Created by Wang Yu on 5/24/15.
//  Copyright (c) 2015 Yu Wang. All rights reserved.
//

import UIKit
import Spring

class MainViewController: UIViewController, JokeManagerDelegate, ImageGetterDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundMaskView: UIView!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var jokeLabel: SpringLabel!
    @IBOutlet weak var maskButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var shareLabelsView: UIView!
    @IBOutlet weak var jokeLabelActivityIndicator: UIActivityIndicatorView!
    
    var placeHolderImageIndex: Int {
        get {
            let random: Int = Int(rand() % 11)
            return random
        }
    }
    var imageGetter: ImageGetter = ImageGetter()
    var jokeMgr: JokeManager = JokeManager()
    var imageUrls = [String]() {
        didSet {
            for var index = 0; index < imageUrls.count-1; index++ {
                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
                    let imageData = NSData(contentsOfURL: NSURL(string: self.imageUrls[index])!)
                    dispatch_async(dispatch_get_main_queue()) {
                        if imageData != nil {
                            var hasIdenticalImage: Bool = false
                            let curImage: UIImage = UIImage(data: imageData!)!
                            for image in self.images {
                                if image.size == curImage.size {
                                    hasIdenticalImage = true
                                }
                            }
                            if hasIdenticalImage == false {
                                self.images.append(curImage)
                            }
                        }
                    }
                }
            }
        }
    }
    var images = [UIImage]()
    var jokes = [Joke]()
    var currentNumber: Int = 0 {
        didSet {
            if currentNumber >= 25 {
                jokeMgr.getManyRandomJoke()
                imageGetter.getFlickrInterestingnessPhotos()
                currentNumber = 0
                images.removeAll(keepCapacity: true)
                jokeLabelActivityIndicator.startAnimating()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        jokeMgr.delegate = self
        imageGetter.delegate = self
        imageGetter.getFlickrInterestingnessPhotos()
        
        insertBlurView(backgroundMaskView, UIBlurEffectStyle.Dark)
        insertBlurView(headerView, UIBlurEffectStyle.Dark)
        
        animator = UIDynamicAnimator(referenceView: view)
        
        dialogView.alpha = 0
        jokeLabel.numberOfLines = 0
        jokeLabel.text = ""
        jokeLabel.adjustsFontSizeToFitWidth = true
        jokeLabelActivityIndicator.hidesWhenStopped = true
        jokeLabelActivityIndicator.startAnimating()
        
        jokeMgr.getManyRandomJoke()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(Bool())
        jokeLabel.text = ""
        if !jokes.isEmpty {
            jokeLabel.text = jokes[currentNumber].content
        }
        if jokeLabel.text == "" {
            jokeMgr.getOneRandomJoke()

        }
        
        let scale = CGAffineTransformMakeScale(0.5, 0.5)
        let translate = CGAffineTransformMakeTranslation(0, -200)
        dialogView.transform = CGAffineTransformConcat(scale, translate)
        
        spring(0.5) {
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            self.dialogView.transform = CGAffineTransformConcat(scale, translate)
        }
        dialogView.alpha = 1
        
        if !images.isEmpty {
            let currentImage = images.removeAtIndex(0)
            fadeChangeBackgroundImage(currentImage)
            imageView.image = currentImage
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
        } else {
            setCurrentImageAsRandomImageInPlaceHolder()
        }
    }
    
    func setCurrentImageAsRandomImageInPlaceHolder() {
        let currentImage: UIImage? = UIImage(named: "placeHoldImage\(placeHolderImageIndex)")
        fadeChangeBackgroundImage(currentImage!)
        imageView.image = currentImage
    }

    func gotOneRandomJoke(joke: Joke) {
        if jokeLabel.text == "" {
            self.jokeLabel.text = joke.content
            jokeLabel.animation = "fadeIn"
            jokeLabel.animate()
            jokeLabelActivityIndicator.stopAnimating()
        }
    }
    
    func gotManyRandomJokes(jokes: [Joke]) {
        self.jokes = jokes
        jokeLabelActivityIndicator.stopAnimating()
    }
    
    func gotFlickrInterestingnessPhotoUrls(urlList: [String]) {
        imageUrls = urlList
    }
    
    @IBAction func maskButtonDidPress(sender: AnyObject) {
        spring(0.5) {
            self.maskButton.alpha = 0
        }
        hideShareView()
    }
    func showMask() {
        self.maskButton.hidden = false
        self.maskButton.alpha = 0
        spring(0.5) {
            self.maskButton.alpha = 1
        }
    }

//    @IBAction func shareButtonDidPress(sender: AnyObject) {
//        shareView.hidden = false
//        showMask()
//        shareView.transform = CGAffineTransformMakeTranslation(0, 200)
//        emailButton.transform = CGAffineTransformMakeTranslation(0, 200)
//        twitterButton.transform = CGAffineTransformMakeTranslation(0, 200)
//        facebookButton.transform = CGAffineTransformMakeTranslation(0, 200)
//        shareLabelsView.alpha = 0
//        
//        spring(0.5) {
//            self.shareView.transform = CGAffineTransformMakeTranslation(0, 0)
//            self.dialogView.transform = CGAffineTransformMakeScale(0.8, 0.8)
//        }
//        springWithDelay(0.5, 0.05, {
//            self.emailButton.transform = CGAffineTransformMakeTranslation(0, 0)
//        })
//        springWithDelay(0.5, 0.10, {
//            self.twitterButton.transform = CGAffineTransformMakeTranslation(0, 0)
//        })
//        springWithDelay(0.5, 0.15, {
//            self.facebookButton.transform = CGAffineTransformMakeTranslation(0, 0)
//        })
//        springWithDelay(0.5, 0.2, {
//            self.shareLabelsView.alpha = 1
//        })
//    }
    func hideShareView() {
        spring(0.5) {
            self.shareView.transform = CGAffineTransformMakeTranslation(0, 0)
            self.dialogView.transform = CGAffineTransformMakeScale(1, 1)
            self.shareView.hidden = true
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    var animator : UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var gravityBehaviour : UIGravityBehavior!
    var snapBehavior : UISnapBehavior!
    
    @IBOutlet var panRecognizer: UIPanGestureRecognizer!
    @IBAction func handleGesture(sender: AnyObject) {
        let myView = dialogView
        let location = sender.locationInView(view)
        let boxLocation = sender.locationInView(dialogView)
        
        if sender.state == UIGestureRecognizerState.Began {
            animator.removeBehavior(snapBehavior)
            
            let centerOffset = UIOffsetMake(boxLocation.x - CGRectGetMidX(myView.bounds), boxLocation.y - CGRectGetMidY(myView.bounds));
            attachmentBehavior = UIAttachmentBehavior(item: myView, offsetFromCenter: centerOffset, attachedToAnchor: location)
            attachmentBehavior.frequency = 0
            
            animator.addBehavior(attachmentBehavior)
        }
        else if sender.state == UIGestureRecognizerState.Changed {
            attachmentBehavior.anchorPoint = location
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            animator.removeBehavior(attachmentBehavior)
            
            snapBehavior = UISnapBehavior(item: myView, snapToPoint: CGPoint(x: view.center.x, y: view.center.y - 45))
            animator.addBehavior(snapBehavior)
            
            let translation = sender.translationInView(view)
            if translation.y > 100 {
                animator.removeAllBehaviors()
                
                var gravity = UIGravityBehavior(items: [dialogView])
                gravity.gravityDirection = CGVectorMake(0, 10)
                animator.addBehavior(gravity)
                
                delay(0.3) {
                    self.refreshView()
                }
            }
        }
    }
    
    func refreshView() {
        currentNumber++
        animator.removeAllBehaviors()
        
        snapBehavior = UISnapBehavior(item: dialogView, snapToPoint: CGPoint(x: view.center.x, y: view.center.y - 45))
        attachmentBehavior.anchorPoint = CGPoint(x: view.center.x, y: view.center.y - 45)
        
        dialogView.center = CGPoint(x: view.center.x, y: view.center.y - 45)
        viewDidAppear(true)
    }
    
    func fadeChangeBackgroundImage(toImage: UIImage) {
        UIView.transitionWithView(self.backgroundImageView, duration: 1.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.backgroundImageView.image = toImage
        }, completion: nil)
    }
    
}
