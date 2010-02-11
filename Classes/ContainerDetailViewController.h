//
//  ContainerDetailViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/31/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"


@class ASICloudFilesContainer;

@interface ContainerDetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, CPPieChartDataSource> {
	id detailItem;
	UIPopoverController *popoverController;
	UINavigationBar *navigationBar;
	
	ASICloudFilesContainer *container;
	NSArray *containerLogFileObjects;
	NSMutableArray *logEntries;
	NSMutableDictionary *userAgentCounts;
	NSArray *sortedUserAgentCountKeys;
	
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *sizeLabel;
	IBOutlet UITextField *cdnUrlTextField;
	IBOutlet UISlider *ttlSlider;
	IBOutlet UILabel *ttlLabel;
	
	IBOutlet UITableView *logEntryTableView;
	IBOutlet UITableViewCell *nibLoadedLogEntryCell;
	
	IBOutlet UITableView *fileTableView;
	
	IBOutlet UITableView *userAgentTableView;
	
	IBOutlet UITableView *trafficTableView;
	
	IBOutlet UISegmentedControl *segmentedControl;
	
	// Tab Views
	IBOutlet UIView *filesSegmentView;
	IBOutlet UIView *logsSegmentView;
	IBOutlet UIView *trafficSegmentView;
	IBOutlet UIView *userAgentsSegmentView;
	
	UITableView *currentTableView;
	
	// Core Plot Charts
	@private
	IBOutlet CPLayerHostingView *userAgentPieChartView;
	CPXYGraph *userAgentPieChart;
	NSMutableArray *userAgentDataForChart;
	
	IBOutlet CPLayerHostingView *trafficLineGraphView;
	CPXYGraph *trafficGraph;
	NSMutableArray *trafficDataForGraph;

	
}

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) ASICloudFilesContainer *container;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *sizeLabel;
@property (nonatomic, retain) IBOutlet UITextField *cdnUrlTextField;
@property (nonatomic, retain) IBOutlet UISlider *ttlSlider;
@property (nonatomic, retain) IBOutlet UILabel *ttlLabel;

@property (nonatomic, retain) IBOutlet UITableViewCell *nibLoadedLogEntryCell;
@property (nonatomic, retain) IBOutlet UITableView *logEntryTableView;

@property (nonatomic, retain) IBOutlet UITableView *fileTableView;

@property (nonatomic, retain) IBOutlet UITableView *userAgentTableView;

@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, retain) IBOutlet UIView *filesSegmentView;
@property (nonatomic, retain) IBOutlet UIView *logsSegmentView;
@property (nonatomic, retain) IBOutlet UIView *trafficSegmentView;
@property (nonatomic, retain) IBOutlet UIView *userAgentsSegmentView;

@property (nonatomic, retain) IBOutlet UITableView *trafficTableView;

// Core Plot
@property (nonatomic, retain) IBOutlet CPLayerHostingView *userAgentPieChartView;
@property (readwrite, retain, nonatomic) NSMutableArray *userAgentDataForChart;

@property (nonatomic, retain) IBOutlet CPLayerHostingView *trafficLineGraphView;
@property (readwrite, retain, nonatomic) NSMutableArray *trafficDataForGraph;


- (void)ttlSliderMoved:(id)sender;
- (void)segmentedControlChanged:(id)sender;

@end
