#import "ViewController.h"

@implementation ViewController
@synthesize videoPlayer; // Creates the getter/setter for your player

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SimpliPlay Legacy for iOS"
                                                    message:@"Enter URL:"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Play", nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *urlText = [[alertView textFieldAtIndex:0] text];
        NSURL *movieURL = [NSURL URLWithString:urlText];
        
        // Retain the player so it stays in memory
        self.videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
        
        self.videoPlayer.view.frame = self.view.bounds;
        self.videoPlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:self.videoPlayer.view];
        [self.videoPlayer play];
    }
}
@end