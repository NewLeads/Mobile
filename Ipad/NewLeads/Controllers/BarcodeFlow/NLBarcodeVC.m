//
//  NLBarcodeVC.m
//  NewLeads
//
//  Created by idevs.com on 27/01/2015.
//  Copyright (c) 2015 idevs.com. All rights reserved.
//

#import "NLBarcodeVC.h"
#import "NLBarcodeDatasource.h"
#import "NLContext.h"

@interface NLBarcodeVC ()
<
	UITableViewDataSource,
	UITableViewDelegate,
	UINavigationControllerDelegate
>
//
// UI - XIB:
@property (nonatomic, assign) IBOutlet UITableView * viewTable;
//
// Logic
@property (nonatomic, retain) NLBarcodeDatasource	* barcodeDatasource;

@end



@implementation NLBarcodeVC

- (void) viewDidLoad
{
    [super viewDidLoad];
	
	self.title = @"Barcode Type";
	self.navigationItem.rightBarButtonItem = self.barLogo;
	self.navigationController.delegate = self;
	
	self.barcodeDatasource = [NLBarcodeDatasource new];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.viewTable reloadData];
}



#pragma mark - UITableViewDelegate
//
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NLBarcode * barcode = [[self.barcodeDatasource barcodes:NO] objectAtIndex:indexPath.row];
	
	[self.barcodeDatasource selectItem:![barcode isSelected] atIndex:indexPath.row];
	
	[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}



#pragma mark - UITableViewDatasource
//
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[self.barcodeDatasource barcodes:NO] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell * cell = nil;
	
	static NSString * cellID = @"cellID";
	
	cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if( !cell )
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
	}

	NLBarcode * barcode = [[self.barcodeDatasource barcodes:NO] objectAtIndex:indexPath.row];
	cell.textLabel.text = barcode.codeName;
	cell.detailTextLabel.text = barcode.codeDescription;
	cell.accessoryType	= ([barcode isSelected] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
	
	return cell;
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if( ![viewController isKindOfClass:[self class]] )
	{
		self.navigationController.delegate = nil;
		
		[self.barcodeDatasource flushData];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kNLNotifBarcodeSettingsWasChanged object:nil];
	}
}

@end
