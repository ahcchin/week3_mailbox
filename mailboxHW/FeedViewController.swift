//
//  FeedViewController.swift
//  mailboxHW
//
//  Created by Andrew Chin on 8/18/14.
//  Copyright (c) 2014 Andrew Chin. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var rescheduleImageView: UIImageView!
    @IBOutlet weak var listImageView: UIImageView!
    @IBOutlet weak var feedImageView: UIImageView!
    
    @IBOutlet weak var backgroundContainerView: UIView!
    
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var leftIcon: UIImageView!
    @IBOutlet weak var rightIcon: UIImageView!
    
    var leftIconOriginX: CGFloat!
    var rightIconOriginX: CGFloat!
    var archiveThreshold = CGFloat(60)
    var deleteThreshold = CGFloat(260)
    var laterThreshold = CGFloat(-60)
    var toDoThreshold = CGFloat(-260)
    var messageHideFromMenuFrame = CGFloat(290)
    var state: Int!
    

    @IBOutlet var onMenuPan: UIPanGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: 320, height: feedImageView.frame.size.height + feedImageView.frame.origin.y)
        
        listImageView.alpha = 0
        rescheduleImageView.alpha = 0
        
        leftIconOriginX = leftIcon.frame.origin.x
        rightIconOriginX = rightIcon.frame.origin.x
        
        // Do any additional setup after loading the view.
        
        var edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: "onEdgePan:")
        edgeGesture.edges = UIRectEdge.Left
        mainContainerView.addGestureRecognizer(edgeGesture)
        onMenuPan.enabled = false
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rescheduleOnTap(sender: UITapGestureRecognizer) {
     
        rescheduleImageView.alpha = 0
        dismissMessage()
    }
    @IBAction func onListTap(sender: UITapGestureRecognizer) {
        listImageView.alpha = 0
        dismissMessage()
    }

    @IBAction func onMessagePan(panGestureRecognizer: UIPanGestureRecognizer) {
        
        var point = panGestureRecognizer.locationInView(view)
        var velocity = panGestureRecognizer.velocityInView(view)
        var translation = panGestureRecognizer.translationInView(view)
        
        if panGestureRecognizer.state == UIGestureRecognizerState.Began {
            
            //set background message to grey
            backgroundContainerView.backgroundColor = UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1)
            leftIcon.frame.origin.x = CGFloat(20)
            rightIcon.frame.origin.x = CGFloat(280)
            leftIcon.image = UIImage(named: "archive_icon")
            rightIcon.image = UIImage(named: "later_icon")
            leftIcon.alpha = 0
            rightIcon.alpha = 0
            
            
            println("Gesture began at: \(point)")
            
            
            
        } else if panGestureRecognizer.state == UIGestureRecognizerState.Changed {
            
            messageImageView.frame.origin.x = translation.x

            println("x translation: \(translation.x)")
            println("right icon origin: \(rightIcon.frame.origin.x)")
            println("right icon original origin: \(rightIconOriginX)")

            
            if (messageImageView.frame.origin.x > 0 && messageImageView.frame.origin.x < archiveThreshold) {
                //didn't meet archive threshold
                
                state = 0  //didn't archive
                
                leftIcon.alpha = (translation.x / archiveThreshold)
                
                backgroundContainerView.backgroundColor = UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1)
                println("state 0")

                
            } else if (messageImageView.frame.origin.x > archiveThreshold && messageImageView.frame.origin.x < deleteThreshold) {
                
                state = 1 //archive Message
                leftIcon.frame.origin.x =  leftIconOriginX + translation.x - archiveThreshold
                leftIcon.image = UIImage(named: "archive_icon")
                backgroundContainerView.backgroundColor = UIColor(red: 112/255, green: 217/255, blue: 98/255, alpha: 1)
                println("state 1")

                
                
                
            } else if (messageImageView.frame.origin.x >= deleteThreshold) {
                //delete message
                
                state = 2 //delete Message
                leftIcon.frame.origin.x = leftIconOriginX +
                translation.x - archiveThreshold
                leftIcon.image = UIImage(named: "delete_icon")
                backgroundContainerView.backgroundColor = UIColor(red: 235/255, green: 84/255, blue: 51/255, alpha: 1)
                println("state 2")

                
            } else if (messageImageView.frame.origin.x < 0 && messageImageView.frame.origin.x > laterThreshold) {
                
                state = 3 //didn't later
                backgroundContainerView.backgroundColor = UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1)
                
                rightIcon.alpha = abs((translation.x / archiveThreshold))

                println("state 3")


                
                
            } else if (messageImageView.frame.origin.x < laterThreshold && messageImageView.frame.origin.x > toDoThreshold) {
                state = 4 //later message
                rightIcon.image = UIImage(named: "later_icon")
                rightIcon.frame.origin.x = rightIconOriginX + translation.x - laterThreshold
                backgroundContainerView.backgroundColor = UIColor(red: 250/255, green: 211/255, blue: 51/255, alpha: 1)

                println("state 4")
                
                
            } else if (messageImageView.frame.origin.x < toDoThreshold) {
                
                state = 5 //to do message
                rightIcon.image = UIImage(named: "list_icon")
                rightIcon.frame.origin.x = rightIconOriginX + translation.x - laterThreshold
                backgroundContainerView.backgroundColor = UIColor(red: 216/255, green: 165/255, blue: 117/255, alpha: 1)
                println("state 5")
                
            }

        
        } else if panGestureRecognizer.state == UIGestureRecognizerState.Ended {
            println("Gesture ended at: \(point)")
            
            if (state == 0) {
                //message bounces to the left
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 2, options: nil, animations: {
                    () -> Void in
                        self.messageImageView.frame.origin.x = 0
                }, completion: nil)
                
            } else if (state == 1) {
                //archive Message
                
                println("message archived")
                dismissMessageRight()

               
            } else if (state == 2) {
                //delete message
                dismissMessageRight()
                println("message delete")
                
            } else if (state == 3) {
            //didn't meet threshold and bounces back
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 2, options: nil, animations: {
                    () -> Void in
                    self.messageImageView.frame.origin.x = 0
                    }, completion: nil)
                
                
                
            } else if (state == 4) {
                //later message
                println("message later")
                
                UIView.animateWithDuration(0.4, delay: 0, options: nil, animations: {
                    () -> Void in
                    self.messageImageView.frame.origin.x = -350
                    self.rightIcon.frame.origin.x = -350
                    }, completion: {
                        (value: Bool) in
                        UIView.animateWithDuration(0.1, animations: {
                            self.rescheduleImageView.alpha = 1
                        })

                })
                
                
            } else if (state == 5) {
                //to do message
                UIView.animateWithDuration(0.4, delay: 0, options: nil, animations: {
                    () -> Void in
                    self.messageImageView.frame.origin.x = -350
                    self.rightIcon.frame.origin.x = -350
                    }, completion: {
                        (value: Bool) in
                        UIView.animateWithDuration(0.1, animations: {
                            self.listImageView.alpha = 1
                        })
                        
                })

            
                println("message to do")
            }
        }
        
        
    }
    
    func dismissMessageRight () {
        
        UIView.animateWithDuration(0.4, delay: 0, options: nil, animations: {
            () -> Void in
            self.messageImageView.frame.origin.x = 350
            self.leftIcon.frame.origin.x = 350
            }, completion: {
                (value: Bool) in
                self.dismissMessage()
        })

        

    }
    
    func dismissMessageLeft () {
        
        UIView.animateWithDuration(0.4, delay: 0, options: nil, animations: {
            () -> Void in
            self.messageImageView.frame.origin.x = -350
            self.rightIcon.frame.origin.x = -350
            }, completion: {
                (value: Bool) in
                self.dismissMessage()
        })
    }
    
    func dismissMessage() {
        UIView.animateWithDuration(0.4, animations: {
            self.feedImageView.frame.origin.y -= 86
            }, completion: {
                (value: Bool) in
                self.feedImageView.frame.origin.y += 86
                //bring the view back, have to complete it after animation is done
                self.messageImageView.frame.origin.x = 0

        })

    }
    
    func onEdgePan(edgeGestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        var translation = edgeGestureRecognizer.translationInView(view)
        var velocity = edgeGestureRecognizer.velocityInView(view)
        
        if (edgeGestureRecognizer.state == UIGestureRecognizerState.Began) {

            
        } else if (edgeGestureRecognizer.state == UIGestureRecognizerState.Changed) {
            mainContainerView.frame.origin.x = translation.x

        
        } else if (edgeGestureRecognizer.state == UIGestureRecognizerState.Ended) {
            
            if (velocity.x > 0) {
                UIView.animateWithDuration(0.2, animations: {
                    self.mainContainerView.frame.origin.x = self.messageHideFromMenuFrame
                    self.onMenuPan.enabled = true

                })
            }
                else if (velocity.x < 0) {
                    UIView.animateWithDuration(0.2, animations: {
                        self.mainContainerView.frame.origin.x = 0
                        self.onMenuPan.enabled = false
                    })
            }
        }
    }
    
    
    @IBAction func onScreenTap(sender: AnyObject) {
        if (rescheduleImageView.alpha == 1) {
            UIView.animateWithDuration(0.2, animations: {
                () -> Void in
                self.rescheduleImageView.alpha = 0
            })
            dismissMessage()
            
        } else if (listImageView.alpha == 1) {
            UIView.animateWithDuration(0.2, animations: {
                () -> Void in
                self.feedImageView.alpha = 0
            })
            dismissMessage()
        }

    }
    
    @IBAction func onMainViewPan(sender: UIPanGestureRecognizer) {
        
        var translation = sender.translationInView(view)
        var velocity = sender.velocityInView(view)
        
     
        println("container frame: \(mainContainerView.frame.origin.x)")
        println("translation x: \(translation.x)")
        
        
        if (sender.state == UIGestureRecognizerState.Began) {
            
            
        } else if (sender.state == UIGestureRecognizerState.Changed) {
            mainContainerView.frame.origin.x = messageHideFromMenuFrame + translation.x
            
            
        } else if (sender.state == UIGestureRecognizerState.Ended) {
            
            if (velocity.x > 0) {
                UIView.animateWithDuration(0.2, animations: {
                    self.mainContainerView.frame.origin.x = self.messageHideFromMenuFrame
                    self.onMenuPan.enabled = true
                    
                })
            }
            else if (velocity.x < 0) {
                UIView.animateWithDuration(0.2, animations: {
                    self.mainContainerView.frame.origin.x = 0
                    self.onMenuPan.enabled = false
                })
            }
        }

        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
