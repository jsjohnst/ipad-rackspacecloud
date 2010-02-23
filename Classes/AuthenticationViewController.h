//
//  AuthenticationViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/27/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AuthenticationViewController : UIViewController {
	
	// "Authenticating..."
	IBOutlet UIActivityIndicatorView *smallSpinner;
	IBOutlet UIActivityIndicatorView *largeSpinner;
	IBOutlet UILabel *smallAuthenticatingLabel;
	IBOutlet UILabel *largeAuthenticatingLabel;
	
	// Text Fields
	IBOutlet UITextField *usernameTextField;
	IBOutlet UITextField *apiKeyTextField;
	
	// Text Field Labels
	IBOutlet UILabel *usernameLabel;
	IBOutlet UILabel *apiKeyLabel;
	
	NSString *username;
	NSString *apiKey;
	
	// Data for the rest of the app
	NSArray *images;
	NSArray *flavors;
	
	NSUInteger imageLoadAttempts;
	NSUInteger flavorLoadAttempts;
	
	
	IBOutlet UIButton *statusButton;
	IBOutlet UIScrollView *statusScrollView;
	
	IBOutlet UIView *statusView;
	
	CGPoint startPosition;
	BOOL statusViewExpanded;
	IBOutlet UIToolbar *statusToolbar;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *smallSpinner;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *largeSpinner;
@property (nonatomic, retain) IBOutlet UILabel *smallAuthenticatingLabel;
@property (nonatomic, retain) IBOutlet UILabel *largeAuthenticatingLabel;
@property (nonatomic, retain) IBOutlet UITextField *usernameTextField;
@property (nonatomic, retain) IBOutlet UITextField *apiKeyTextField;

@property (nonatomic, retain) IBOutlet UIButton *statusButton;
@property (nonatomic, retain) IBOutlet UIScrollView *statusScrollView;

@property (nonatomic, retain) IBOutlet UIView *statusView;
@property (nonatomic, retain) IBOutlet UIToolbar *statusToolbar;

-(void)loginButtonPressed:(id)sender;
-(void)loadSettings;

@end
