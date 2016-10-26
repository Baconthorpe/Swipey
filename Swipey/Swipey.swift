//
//  Swipey.swift
//  Swipey
//
//  Created by Ezekiel Abuhoff on 10/18/16.
//  Copyright © 2016 Ezekiel Abuhoff. All rights reserved.
//

import UIKit

// MARK:
public class SwipeDeck: UIView, SwipeCardDelegate {
    
    // MARK: Properties
    
    public var delegate: SwipeDeckDelegate?
    public var topIndex: Int {
        return internalTopIndex
    }
    
    private var numberOfCards: Int = 0
    private var internalTopIndex: Int = 0
    private var topCard: SwipeCard?
    private var bottomCard: SwipeCard?
    
    // MARK: View
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        reloadData()
    }
    
    // MARK: Population
    
    public func reloadData() {
        if let existingTopCard = topCard {
            existingTopCard.removeFromSuperview()
            topCard = nil
        }
        if let existingBottomCard = bottomCard {
            existingBottomCard.removeFromSuperview()
            bottomCard = nil
        }
        
        numberOfCards = numberOfCards(swipeDeck: self)
        if numberOfCards > 0 {
            // A top card is needed
            createTopCard()
        }
        if numberOfCards > 1 {
            // A bottom card is needed
            createBottomCard()
        }
    }
    
    private func createTopCard() {
        let size = CGSize(width: frame.size.width * 0.9, height: frame.size.height * 0.9)
        let index = numberOfCards - 1
        topCard = cardFor(index: index, swipeDeck: self)
        topCard!.frame.size = size
        topCard!.center = center
        topCard!.delegate = self
        topCard!.isUserInteractionEnabled = true
        addSubview(topCard!)
    }
    
    private func createBottomCard() {
        let size = CGSize(width: frame.size.width * 0.9, height: frame.size.height * 0.9)
        let index = numberOfCards - 2
        bottomCard = cardFor(index: index, swipeDeck: self)
        bottomCard!.frame.size = size
        bottomCard!.center = center
        bottomCard!.delegate = self
        bottomCard!.isUserInteractionEnabled = false
        addSubview(bottomCard!)
        sendSubview(toBack: bottomCard!)
    }
    
    // MARK: Swiping
    
    private func moveToNextCard() {
        numberOfCards -= 1
        topCard = bottomCard
        if let newTopCard = topCard {
            newTopCard.isUserInteractionEnabled = true
        }
        
        if numberOfCards > 1 {
            createBottomCard()
        } else {
            bottomCard = nil
        }
    }
    
    // MARK: Swipe Card Delegate
    
    public func swipedPositive(swipeCard: SwipeCard) {
        moveToNextCard()
        
        if let existingDelegate = delegate {
            existingDelegate.positiveSwipe(swipeDeck: self)
        }
    }
    
    public func swipedNegative(swipeCard: SwipeCard) {
        moveToNextCard()
        
        if let existingDelegate = delegate {
            existingDelegate.negativeSwipe(swipeDeck: self)
        }
    }
    
    public func swipeAnimationComplete(swipeCard: SwipeCard) {
        swipeCard.removeFromSuperview()
    }
    
    // MARK: Methods To Be Delegated
    
    private func numberOfCards(swipeDeck: SwipeDeck) -> Int {
        if let existingDelegate = delegate {
            return existingDelegate.numberOfCards(swipeDeck: swipeDeck)
        }
        return 0
    }
    
    private func cardFor(index: Int, swipeDeck: SwipeDeck) -> SwipeCard {
        if let existingDelegate = delegate {
            return existingDelegate.cardFor(index: index, swipeDeck: swipeDeck)
        }
        return SwipeCard()
    }
}

// MARK:
public protocol SwipeDeckDelegate {
    func numberOfCards(swipeDeck: SwipeDeck) -> Int
    func cardFor(index: Int, swipeDeck: SwipeDeck) -> SwipeCard
    func positiveSwipe(swipeDeck: SwipeDeck)
    func negativeSwipe(swipeDeck: SwipeDeck)
}

// MARK:
public class SwipeCard: TrackTouchView {
    
    // MARK: Properties
    
    public var delegate: SwipeCardDelegate?
    public var swipeOrientation: SwipeOrientation = .horizontal
    public private(set) var thresholdProximity = 0.0
    
    private var startingFrame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
    private lazy var threshold: Double = self.setThreshold()
    private func setThreshold() -> Double {
        if swipeOrientation == .horizontal {
            return Double(frame.width / 2)
        }
        return Double(frame.height / 2)
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Touch Detection
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        startingFrame = frame
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        moveToOffset()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        let positiveSwipe = thresholdProximity >= 1.0
        let negativeSwipe = thresholdProximity <= -1.0
        
        if positiveSwipe {
            animateSwipe(positive: true)
        } else if negativeSwipe {
            animateSwipe(positive: false)
        } else {
            animateReturn()
        }
        
        // Report to delegate
        if let existingDelegate = delegate {
            if positiveSwipe {
                existingDelegate.swipedPositive(swipeCard: self)
            } else if negativeSwipe {
                existingDelegate.swipedNegative(swipeCard: self)
            }
            //            existingDelegate.trackedTouchEnded(swipeView: self)
        }
    }
    
    // MARK: Movement and Animation
    
    func moveToOffset() {
        if swipeOrientation == .horizontal {
            frame.origin.x = startingFrame.origin.x + currentOffset.x
            thresholdProximity = Double(currentOffset.x) / threshold
        } else {
            frame.origin.y = startingFrame.origin.y + currentOffset.y
            thresholdProximity = Double(currentOffset.y) / threshold
        }
    }
    
    func animateSwipe(positive: Bool) {
        if positive && swipeOrientation == .horizontal {
            isUserInteractionEnabled = false
            
            UIView.animate(withDuration: 1.0, animations: {
                self.frame.origin.x = self.startingFrame.origin.x + self.startingFrame.width * 3
                }, completion: { (completed) in
                    self.completeSwipe()
            })
        } else if positive && swipeOrientation == .vertical {
            UIView.animate(withDuration: 1.0, animations: {
                self.frame.origin.y = self.startingFrame.origin.y + self.startingFrame.height * 3
                }, completion: { (completed) in
                    self.completeSwipe()
            })
        } else if !positive && swipeOrientation == .horizontal {
            UIView.animate(withDuration: 1.0, animations: {
                self.frame.origin.x = self.startingFrame.origin.x - self.startingFrame.width * 3
                }, completion: { (completed) in
                    self.completeSwipe()
            })
        } else if !positive && swipeOrientation == .vertical {
            UIView.animate(withDuration: 1.0, animations: {
                self.frame.origin.y = self.startingFrame.origin.y - self.startingFrame.height * 3
                }, completion: { (completed) in
                    self.completeSwipe()
            })
        }
    }
    
    func completeSwipe() {
        if let existingDelegate = delegate {
            existingDelegate.swipeAnimationComplete(swipeCard: self)
        } else {
            self.removeFromSuperview()
        }
    }
    
    func animateReturn() {
        isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.5, animations: {
            self.frame.origin = self.startingFrame.origin
            }, completion: { (completed) in
                self.startingFrame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
                self.isUserInteractionEnabled = true
        })
    }
}

// MARK:
public enum SwipeOrientation {
    case horizontal
    case vertical
}

// MARK:
public protocol SwipeCardDelegate {
    func swipedPositive(swipeCard: SwipeCard)
    func swipedNegative(swipeCard: SwipeCard)
    func swipeAnimationComplete(swipeCard: SwipeCard)
}

// MARK:
public class TrackTouchView: UIView {
    
    public var touchOrigin = CGPoint(x: 0.0, y: 0.0)
    public var currentOffset = CGPoint(x: 0.0, y: 0.0)
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touchPoint: CGPoint = averageLocationFrom(touches: touches)
        touchOrigin = touchPoint
        currentOffset = CGPoint(x: 0.0, y: 0.0)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let touchPoint: CGPoint = averageLocationFrom(touches: touches)
        currentOffset.x = touchPoint.x - touchOrigin.x
        currentOffset.y = touchPoint.y - touchOrigin.y
    }
}

// MARK:
internal extension UIView {
    func averageLocationFrom(touches: Set<UITouch>) -> CGPoint {
        let touchArray = Array(touches)
        var totalX = 0.0
        var totalY = 0.0
        for touch in touchArray {
            totalX += Double(touch.preciseLocation(in: superview).x)
            totalY += Double(touch.preciseLocation(in: superview).y)
        }
        let averageX = totalX / Double(touches.count)
        let averageY = totalY / Double(touches.count)
        
        return CGPoint(x: averageX, y: averageY)
    }
}
