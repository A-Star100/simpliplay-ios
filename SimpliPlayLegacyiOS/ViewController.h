#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

// Adding <UIAlertViewDelegate> tells the compiler this class can handle the alert buttons
@interface ViewController : UIViewController <UIAlertViewDelegate>

@property (retain, nonatomic) MPMoviePlayerController *videoPlayer;

@end