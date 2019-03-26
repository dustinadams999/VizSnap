//
//  SingleCapturedContextViewController.m
//  AccessiblePhotos
//
//  Created by Adams Dustin on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SingleCapturedContextViewController.h"
#import "CapturedContextManager.h"
#import "CapturedContext.h"
#import "AudioTableViewController.h"
#import "ByDateTableViewController.h"


@interface SingleCapturedContextViewController ()

@end

@implementation SingleCapturedContextViewController

@synthesize capturedContext;
@synthesize timeLabel;
@synthesize dateLabel;
@synthesize locationLabel;
@synthesize imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dateLabel.text = [NSString stringWithFormat:@"Date: %@", [NSDateFormatter localizedStringFromDate:capturedContext.timestamp dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterNoStyle]];
    dateLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6];
    timeLabel.text = [NSString stringWithFormat:@"Time: %@", [NSDateFormatter localizedStringFromDate:capturedContext.timestamp dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterFullStyle]];
    timeLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6];
    if (capturedContext.placemark != nil)
    {
        locationLabel.text = [NSString stringWithFormat:@"Location: %@, %@, %@", capturedContext.placemark.country, capturedContext.placemark.administrativeArea, capturedContext.placemark.subLocality];
    }
    else
    {
        locationLabel.text = @"Location: (not available)";
    }
    locationLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6];
    imageView.image = capturedContext.uiImage;
}

//delete the current captured context
- (IBAction)deleteCurrentCapturedContext:(id)sender
{
    CapturedContext *currentCapturedContext = capturedContext;
    NSString *timestampString = [NSDateFormatter localizedStringFromDate:currentCapturedContext.timestamp dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete current photo?"
                                                    message:[NSString stringWithFormat:@"Are you sure you want to delete the currently selected photo taken at %@?", timestampString]
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        CapturedContext *currentCapturedContext = capturedContext;
        
        NSError *error;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:currentCapturedContext.photoFilePath])
        {
            if ([[NSFileManager defaultManager] removeItemAtPath:currentCapturedContext.photoFilePath error:&error] == NO)
            {
                NSLog(@"Error removing photo at %@, error: %@", currentCapturedContext.photoFilePath, [error localizedDescription]);
            }
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:currentCapturedContext.audioFilePath])
        {
            if ([[NSFileManager defaultManager] removeItemAtPath:currentCapturedContext.audioFilePath error:&error] == NO)
            {
                NSLog(@"Error removing audio at %@, error: %@", currentCapturedContext.audioFilePath, [error localizedDescription]);
            }
        }
        
        NSLog(@"Deleted photos.");
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Deleted photo.");
        
        [[CapturedContextManager sharedManager].capturedContexts removeObject:currentCapturedContext];
        [[CapturedContextManager sharedManager] saveCapturedContextList];
        
        UINavigationController *navController = self.navigationController;
        //ByDateTableViewController *byDateTableViewController = [[ByDateTableViewController alloc] init];
        //byDateTableViewController.
        
        
        [navController popViewControllerAnimated:NO];
        [navController popViewControllerAnimated:NO];
        [navController popViewControllerAnimated:NO];
        //[navController pushViewController:byDateTableViewController animated:YES];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
