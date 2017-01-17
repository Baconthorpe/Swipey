//
//  ViewController.swift
//  SwipeySample
//
//  Created by Ezekiel Abuhoff on 1/17/17.
//  Copyright © 2017 Ezekiel Abuhoff. All rights reserved.
//

import UIKit
import Swipey

class ViewController: UIViewController, SwipeDeckDelegate {

    // MARK: Lifecycle
    
    let colors = [UIColor.yellow,
                  UIColor.green,
                  UIColor.red,
                  UIColor.gray,
                  UIColor.orange]
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeDeck = SwipeDeck(frame: CGRect(x: 20, y: 20, width: 300, height: 300))
        swipeDeck.delegate = self
        swipeDeck.backgroundColor = UIColor.blue
        view.addSubview(swipeDeck)
    }
    
    // MARK: Swipe Deck
    
    func numberOfCards(swipeDeck: SwipeDeck) -> Int {
        // Return the number of cards you'll need for your swipe deck
        return colors.count
    }
    
    func cardFor(index: Int, swipeDeck: SwipeDeck) -> SwipeCard {
        // Produce a swipe card, like dequeueing a table view cell
        let swipeCard = swipeDeck.produceSwipeCard()
        // Customize the swipe card
        swipeCard.backgroundColor = colors[index]
        // Return the swipe card
        return swipeCard
    }
    
    func positiveSwipe(swipeDeck: SwipeDeck) {
        // React to a positive swipe
        print("positive swipe")
    }
    
    func negativeSwipe(swipeDeck: SwipeDeck) {
        // React to a negative swipe
        print("negative swipe")
    }
}

