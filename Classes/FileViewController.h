//
//  FileViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 3/11/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class ASICloudFilesObject, ASICloudFilesContainer;

@interface FileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate> {
    ASICloudFilesContainer *container;
	ASICloudFilesObject *file;
	IBOutlet UITableView *tableView;
}

@property (nonatomic, retain) ASICloudFilesContainer *container;
@property (nonatomic, retain) ASICloudFilesObject *file;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil container:(ASICloudFilesContainer *)aContainer file:(ASICloudFilesObject *)aFile;

@end
