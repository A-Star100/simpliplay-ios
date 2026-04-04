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
    // arc handles memory management
    // so dont release alert mem with alert release
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *urlText = [[alertView textFieldAtIndex:0] text];
        
        // url encoding for strings with spaces
        // spaces are the greatest enemy
        urlText = [urlText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *movieURL = [NSURL URLWithString:urlText];
        
        if (movieURL) {
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
