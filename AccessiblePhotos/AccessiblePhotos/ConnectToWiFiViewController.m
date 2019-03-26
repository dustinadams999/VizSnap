//
//  ConnectToWiFiViewController.m
//  AccessiblePhotos
//
//  Created by Dustin Adams on 10/2/15.
//
//

#import "ConnectToWiFiViewController.h"
#import "Reachability.h"

@interface ConnectToWiFiViewController ()
{
    bool okButtonReady;
}
@end

@implementation ConnectToWiFiViewController
@synthesize loadingLabel;
@synthesize okButton;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    okButtonReady = false;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    okButtonReady = false;
    //First we need to check if there is wifi available. If not, alert the user that they need to be connected to wifi. If the user loses wifi at all during the process, then we need to cancel the uploading process. Way too much data to be going over the waves to be done on someone's data plan
    

    
    
    //Reachability class is taken from Apple code, see in the util folder
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
    {
        //No internet
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"WiFi" message:@"You must be connected to WiFi to upload your photos. Press OK to be taken back to your photo album." delegate:self
                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if (status == ReachableViaWiFi)
    {
        //set accessibility label
        //loadingLabel.accessibilityLabel = @"Uploading your photos now.";
        //UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, loadingLabel);
        //[loadingLabel accessibilityElementDidBecomeFocused];
        //UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Swipe right, and double tap OK to start uploading your photos and audio files.");
        okButtonReady = true;
        
        //delay a couple seconds and announce the VoiceOver message
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self announceVoiceOver];
        });
    }
    else if (status == ReachableViaWWAN)
    {
        //3G, 4G, LTE, or other internet data service
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"WiFi" message:@"You must be connected to WiFi to upload your photos. Press OK to be taken back to your photo album." delegate:self
                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    //end Apple Reachability code
}

-(IBAction)okPressed:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"WiFi" message:@"Are you sure you want to upload all your photos? This will take a few minutes." delegate:self
                          cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{

    if (buttonIndex == 0)
    {
        if (!okButtonReady)
        {
            //OK button
            self.tabBarController.selectedIndex = 1;
        }
    }
    
    if(buttonIndex == 1)
    {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Uploading your photos now.");
        //WiFi
        [self uploadAllPhotos];
    }

}

-(void)announceVoiceOver
{
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Swipe left 5 times and double tap OK to start uploading your photos and audio files.");
}

-(void)uploadAllPhotos
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //Here we need to gather all the file names from the documents directory
    
    NSArray * dirContents =
    [fileManager contentsOfDirectoryAtURL:[NSURL URLWithString:documentsDirectory]
               includingPropertiesForKeys:@[]
                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                    error:nil];
    //Now that we have the directory contents, upload all of it using the uploadFile method down below
    for (int i = 0; i < [dirContents count]; i++)
    {
        NSString *fileName = [[[dirContents objectAtIndex:i] absoluteString] lastPathComponent];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        //There are 3 file types: .wav, .jpg, and .plist
        if([[fileName pathExtension] isEqualToString:@"wav"])//type wav
        {
            
            NSData *dummySoundFile = [NSData dataWithContentsOfFile:filePath];
            NSLog(@"%@", [self uploadFile:dummySoundFile withPath:@"https://users.soe.ucsc.edu/~dustinadams/vizSnap/upload.php" withFileName:fileName]);
        }
        else if([[fileName pathExtension] isEqualToString:@"jpg"])//type jpg
        {
            UIImage *dummyImage = [UIImage imageWithContentsOfFile:filePath];
            NSData *dummyData = UIImageJPEGRepresentation(dummyImage, .5);
            NSLog(@"%@", [self uploadFile:dummyData withPath:@"https://users.soe.ucsc.edu/~dustinadams/vizSnap/upload.php" withFileName:fileName]);
        }
        else if([[fileName pathExtension] isEqualToString:@"plist"])//type plist
        {
            NSData *dummyData = [NSData dataWithContentsOfFile:filePath];
            NSLog(@"%@", [self uploadFile:dummyData withPath:@"https://users.soe.ucsc.edu/~dustinadams/vizSnap/upload.php" withFileName:fileName]);
        }
    }
    okButton.accessibilityLabel = @"Loading is now complete.";
    okButton.accessibilityHint = @"Loading is now complete.";
    loadingLabel.accessibilityLabel = @"Loading is now complete.";
    loadingLabel.accessibilityHint = @"Loading is now complete.";
    [loadingLabel setText:@"Loading complete."];
    
}

-(NSString *)uploadFile:(NSData *)data withPath:(NSString *)urlString withFileName:(NSString *)fileName
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", fileName]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:data]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    return returnString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
