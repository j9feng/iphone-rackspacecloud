
/*
     File: TapDetectingImageView.h
 Abstract: UIImageView subclass that responds to taps and notifies its delegate.
 
  Version: 1.1be incorporated.
 
 */

@protocol TapDetectingImageViewDelegate;


@interface TapDetectingImageView : UIImageView {
	
    id <TapDetectingImageViewDelegate> delegate;
    
    // Touch detection
    CGPoint tapLocation;         // Needed to record location of single tap, which will only be registered after delayed perform.
    BOOL multipleTouches;        // YES if a touch event contains more than one touch; reset when all fingers are lifted.
    BOOL twoFingerTapIsPossible; // Set to NO when 2-finger tap can be ruled out (e.g. 3rd finger down, fingers touch down too far apart, etc).
}

@property (nonatomic, assign) id <TapDetectingImageViewDelegate> delegate;

@end


/*
 Protocol for the tap-detecting image view's delegate.
 */
@protocol TapDetectingImageViewDelegate <NSObject>

@optional
- (void)tapDetectingImageView:(TapDetectingImageView *)view gotSingleTapAtPoint:(CGPoint)tapPoint;
- (void)tapDetectingImageView:(TapDetectingImageView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint;
- (void)tapDetectingImageView:(TapDetectingImageView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint;

@end

