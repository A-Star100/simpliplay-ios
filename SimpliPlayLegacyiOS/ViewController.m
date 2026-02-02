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
    // NO [alert release] here. ARC handles it.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *urlText = [[alertView textFieldAtIndex:0] text];
        
        // Safety: URL encoding for strings with spaces
        urlText = [urlText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *movieURL = [NSURL URLWithString:urlText];
        
        if (movieURL) {
            // ARC magic: Just assign it. It handles the retain for you.
            self.videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
            
            self.videoPlayer.view.frame = self.view.bounds;
            self.videoPlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.view addSubview:self.videoPlayer.view];
            
            [self.videoPlayer prepareToPlay]; 
            [self.videoPlayer play];
        }
    }
}
@end

// No dealloc needed
