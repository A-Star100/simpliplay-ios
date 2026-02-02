#import "ViewController.h"

@implementation ViewController
@synthesize videoPlayer;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SimpliPlay Legacy"
                                                    message:@"Enter URL:"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Play", nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
    
    // In MRC, we release after [show] because the view hierarchy 
    // now retains the alert. This prevents a memory leak.
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *urlText = [[alertView textFieldAtIndex:0] text];
        
        // Safety: URL encoding for strings with spaces or special chars
        urlText = [urlText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *movieURL = [NSURL URLWithString:urlText];
        
        if (movieURL) {
            // 1. Create the player (Reference Count: 1)
            MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
            
            // 2. Assign to property (Setter retains it, Count: 2)
            self.videoPlayer = player;
            
            // 3. Release local reference (Count: 1 - Balanced!)
            [player release];
            
            // Setup the view
            self.videoPlayer.view.frame = self.view.bounds;
            self.videoPlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.view addSubview:self.videoPlayer.view];
            
            // The "Magic" calls for legacy streaming stability
            [self.videoPlayer setShouldAutoplay:YES];
            [self.videoPlayer prepareToPlay]; 
            [self.videoPlayer play];
        }
    }
}

- (void)dealloc {
    // Stop and clean up the player when the view controller dies
    [videoPlayer stop];
    [videoPlayer.view removeFromSuperview];
    [videoPlayer release];
    [super dealloc];
}

@end
