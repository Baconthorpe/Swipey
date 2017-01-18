![logo](SwipeyLogo-01.png)

Swipey is a simple swipe card library by Zeke Abuhoff. By swipe card library, I mean it provides a UI element that can be swiped. You know: like on Tinder.

## Sample Project

To see Swipey in action right away, check out the sample project included in this repo.

## Usage

Swipey provides two UIView subclasses to build your swipe interface: `SwipeCard` and `SwipeDeck`. Each `SwipeCard` instance is an item that can be swiped one or the other by the user. The `SwipeDeck` is the element that contains several cards and manages which one is currently displayed.

To get started, you can instantiate a `SwipeDeck` in code or in Interface Builder, just like any `UIView` subclass.

```swift
let swipeDeck = SwipeDeck(frame: CGRect(x: 20, y: 20, width: 300, height: 300))
```

In order to determine what card to display, the `SwipeDeck` instance relies on a delegate, much like `UITableView`.

```swift
swipeDeck.delegate = self
```

Whatever object is set as the delegate, that object must conform to the `SwipeDeckDelegate` protocol. That protocol includes four delegate methods.

```swift
// The SwipeDeck will call the method below to determine how many cards are in the deck.
func numberOfCards(swipeDeck: SwipeDeck) -> Int {
    // Return the number of cards you'll need for your swipe deck
    return 5
}

// The SwipeDeck will call the method below whenever it needs to display a new card.
func cardFor(index: Int, swipeDeck: SwipeDeck) -> SwipeCard {
    // Produce a swipe card, like dequeueing a table view cell
    let swipeCard = swipeDeck.produceSwipeCard()
    // Customize the swipe card
    swipeCard.backgroundColor = UIColor.blue
    // Return the swipe card
    return swipeCard
}

// The SwipeDeck will call the method below when the user swipes in a positive direction.
func positiveSwipe(swipeDeck: SwipeDeck) {
    // React to a positive swipe
    print("positive swipe")
}

// The SwipeDeck will call the method below when the user swipes in a negative direction.
func negativeSwipe(swipeDeck: SwipeDeck) {
    // React to a negative swipe
    print("negative swipe")
}
```

Once you've defined the delegate methods and set the deck's delegate, the deck will automatically display whatever the delegate methods specify.

## License
[MIT License](LICENSE)
