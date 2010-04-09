//
//  LogoutViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 4/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "LogoutViewController.h"
#import "ASICloudFilesRequest.h"
#import "UIViewController+SpinnerView.h"
#import "ASICloudServersFlavorRequest.h"
#import "ASICloudServersImageRequest.h"


@implementation LogoutViewController

#pragma mark -
#pragma mark Utilities

-(void)restorePreviousLogin {
    [ASICloudFilesRequest setUsername:initialUsername];
    [ASICloudFilesRequest setApiKey:initialApiKey];
    [ASICloudServersFlavorRequest setFlavors:initialFlavors];
    [ASICloudServersImageRequest setImages:initialImages];
    [ASICloudFilesRequest setStorageURL:initialStorageURL];
    [ASICloudFilesRequest setCdnManagementURL:initialCdnManagementURL];
    [ASICloudFilesRequest setServerManagementURL:initialServerManagementURL];
}

#pragma mark -
#pragma mark HTTP Requests

-(void)loadFlavors {
	ASICloudServersFlavorRequest *flavorRequest = [ASICloudServersFlavorRequest listRequest];
	[flavorRequest setDelegate:self];
	[flavorRequest setDidFinishSelector:@selector(flavorListRequestFinished:)];
	[flavorRequest setDidFailSelector:@selector(flavorListRequestFailed:)];
	[flavorRequest startAsynchronous];
}

-(void)loadImages {
	ASICloudServersImageRequest *imageRequest = [ASICloudServersImageRequest listRequest];
	[imageRequest setDelegate:self];
	[imageRequest setDidFinishSelector:@selector(imageListRequestFinished:)];
	[imageRequest setDidFailSelector:@selector(imageListRequestFailed:)];
	[imageRequest startAsynchronous];
}

#pragma mark -
#pragma mark HTTP Response Handlers

-(void)flavorListRequestFinished:(ASICloudServersFlavorRequest *)request {
	[self hideSpinnerView];
	[ASICloudServersFlavorRequest setFlavors:[request flavors]];
	
	// we're done.  now let's get to the app
    [self dismissModalViewControllerAnimated:YES];
}

-(void)flavorListRequestFailed:(ASIHTTPRequest *)request {
	flavorLoadAttempts++;
	if (flavorLoadAttempts < 3) {
		// try again
		[self loadFlavors];
	} else {
		[self hideSpinnerView];
		[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"loading server flavors"];
        [self restorePreviousLogin];
	}
}

-(void)imageListRequestFinished:(ASICloudServersImageRequest *)request {
	[ASICloudServersImageRequest setImages:[request images]];
	[self loadFlavors];
}

-(void)imageListRequestFailed:(ASIHTTPRequest *)request {
	imageLoadAttempts++;
	if (imageLoadAttempts < 3) {
		// try again
		[self loadImages];
	} else {
		[self hideSpinnerView];
		[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"loading server images"];
        [self restorePreviousLogin];
	}
	
}

-(void)authenticationRequestFinished:(ASICloudFilesRequest *)request {
	if ([request isSuccess]) {
		NSDictionary *responseHeaders = [request responseHeaders];
		[ASICloudFilesRequest setAuthToken:[responseHeaders objectForKey:@"X-Auth-Token"]];
		[ASICloudFilesRequest setStorageURL:[responseHeaders objectForKey:@"X-Storage-Url"]];
		[ASICloudFilesRequest setCdnManagementURL:[responseHeaders objectForKey:@"X-Cdn-Management-Url"]];
		[ASICloudFilesRequest setServerManagementURL:[responseHeaders objectForKey:@"X-Server-Management-Url"]];	
        
		[self loadImages];
	} else {
		[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"authenticating"];
		[self hideSpinnerView];
        [self restorePreviousLogin];
	}	
}

-(void)authenticationRequestFailed:(ASIHTTPRequest *)request {
    
	[self hideSpinnerView];
	
	NSString *title = @"";
	NSString *message = @"";
	
	if ([request responseStatusCode] == 401) {
		title = @"Authentication Failure";
		message = @"Please check your User Name and API Key.";
	} else {
		title = @"Connection Failure";
		message = @"Please check your connection and try again.";
	}
	
	[self alert:title message:message];	
    [self restorePreviousLogin];
}

#pragma mark -
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

-(void)loginButtonPressed:(id)sender {
    NSString *username;
    NSString *apiKey;
    
    initialUsername = [ASICloudFilesRequest username];
    initialApiKey = [ASICloudFilesRequest apiKey];
    initialFlavors = [NSArray arrayWithArray:[ASICloudServersFlavorRequest flavors]];
    initialImages = [NSArray arrayWithArray:[ASICloudServersImageRequest images]];
    initialStorageURL = [NSString stringWithString:[ASICloudFilesRequest storageURL]];
    initialCdnManagementURL = [NSString stringWithString:[ASICloudFilesRequest cdnManagementURL]];
    initialServerManagementURL = [NSString stringWithString:[ASICloudFilesRequest serverManagementURL]];
    
    [self showSpinnerView];
    
    if (selectedIndex == 0) {
        // it's the primary account
        username = [defaults stringForKey:@"username_preference"];
        apiKey = [defaults stringForKey:@"api_key_preference"];
    } else {
        // it's a secondary account
        NSDictionary *secondaryAccounts = [defaults objectForKey:@"secondary_accounts"];
        NSArray *keys = [secondaryAccounts keysSortedByValueUsingSelector:@selector(compare:)];
        username = [keys objectAtIndex:selectedIndex - 1];
        apiKey = [secondaryAccounts objectForKey:username];
    }
    
    [ASICloudFilesRequest setUsername:username];
    [ASICloudFilesRequest setApiKey:apiKey];
    ASICloudFilesRequest *request = [ASICloudFilesRequest authenticationRequest];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(authenticationRequestFinished:)];
    [request setDidFailSelector:@selector(authenticationRequestFailed:)];
    [request startAsynchronous];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    
    accountCount = 1; // for the primary account
    
    NSDictionary *secondaryAccounts = [defaults objectForKey:@"secondary_accounts"];
    accountCount += [secondaryAccounts count];
    
    accounts = [[NSMutableArray alloc] initWithCapacity:accountCount];
    
    NSString *primaryUsername = [defaults stringForKey:@"username_preference"];
    [accounts addObject:primaryUsername];
    
    if ([primaryUsername isEqualToString:[ASICloudFilesRequest username]]) {
        selectedIndex = 0;
    }
    
    NSArray *keys = [secondaryAccounts keysSortedByValueUsingSelector:@selector(compare:)];
    for (int i = 0; i < [keys count]; i++) {
        NSString *username = [keys objectAtIndex:i];
        [accounts addObject:username];
        if ([username isEqualToString:[ASICloudFilesRequest username]]) {
            selectedIndex = i + 1;
        }
    }
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return accountCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Choose Account To Log In";
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = [accounts objectAtIndex:indexPath.row];
    
    if (indexPath.row == selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndex = indexPath.row;
    [tableView reloadData];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [accounts release];
    [super dealloc];
}


@end

