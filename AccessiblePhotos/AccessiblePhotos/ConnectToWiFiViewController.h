//
//  ConnectToWiFiViewController.h
//  AccessiblePhotos
//
//  Created by Dustin Adams on 10/2/15.
//
//

#import <UIKit/UIKit.h>


@interface ConnectToWiFiViewController : UIViewController <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
- (IBAction)okPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@end
