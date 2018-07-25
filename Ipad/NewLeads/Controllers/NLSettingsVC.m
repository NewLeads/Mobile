//
//  NLSettingsVC.m
//  NewLeads
//
//  Created by idevs.com on 13/03/2015.
//  Copyright (c) 2015 idevs.com. All rights reserved.
//

#import "NLSettingsVC.h"
#import "NLAppDelegate.h"
#import "NLFieldCellView.h"
#import "NLButtonCellView.h"
#import "NLSwitchCellView.h"
#import "NLBarcodeVC.h"
//
#import "NLDeviceController.h"

@interface NLSettingsVC ()
<
	UINavigationControllerDelegate
>

@end



@implementation NLSettingsVC

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	self.title = @"Settings";
	self.navigationController.delegate = self;
	
	self.rcTableOriginal = CGRectZero;
	
	[self loadDatasource];
	
	[self.viewTable registerNib:[UINib nibWithNibName:@"NLFieldCellView" bundle:nil] forCellReuseIdentifier:[NLFieldCellView reuseID]];
	[self.viewTable registerNib:[UINib nibWithNibName:@"NLButtonCellView" bundle:nil] forCellReuseIdentifier:[NLButtonCellView reuseID]];
	[self.viewTable registerNib:[UINib nibWithNibName:@"NLSwitchCellView" bundle:nil] forCellReuseIdentifier:[NLSwitchCellView reuseID]];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.navigationItem.rightBarButtonItem = self.barLogo;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	self.navigationController.navigationBar.hidden = NO;
	
	[self.viewTable reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}



#pragma mark - Actions
//
- (IBAction) onButtonDone:(id)sender
{
    [self updateDatasource];
}



#pragma mark - Core logic
//
- (void) setupChangesBlock:(NLSettingsDidChangedBlock) anChangesBlock
{
	self.changesBlock = anChangesBlock;
}

- (void) loadDatasource
{
	if( !self.dicSettings )
	{
		self.dicSettings = [NSMutableDictionary dictionary];
	}
	
	NSInteger compoundTAG	= NSNotFound;

	//
	// Scanner ID
	//
	compoundTAG = [self createTag:kScannerId inSection:0];
	[self.dicSettings setValue:[NSString stringWithFormat:@"%@", [NLContext shared].stationID] forKey:[self tagKeyWithTag:compoundTAG]];
	//
	// Server URL
	//
	compoundTAG = [self createTag:kServerURL inSection:0];
	[self.dicSettings setValue:[NLContext shared].clientURL forKey:[self tagKeyWithTag:compoundTAG]];
	//
	// Scan Mode
	//
	compoundTAG = [self createTag:kScanMode inSection:0];
    [NLDeviceController device].cardMode = [NLContext shared].isRawMode;
	[self.dicSettings setValue:[NSNumber numberWithBool:[NLDeviceController device].cardMode] forKey:[self tagKeyWithTag:compoundTAG]];
	/*
	//
	// Sketch Pad
	//
	compoundTAG = [self createTag:kSketchPad inSection:0];
	[self.dicSettings setValue:[NSNumber numberWithBool:[NLContext shared].isSketchPadAvail] forKey:[self tagKeyWithTag:compoundTAG]];
	//
	// Signature
	//
	compoundTAG = [self createTag:kSignature inSection:0];
	[self.dicSettings setValue:[NSNumber numberWithBool:[NLContext shared].isSignatureAvail] forKey:[self tagKeyWithTag:compoundTAG]];
	//
	// Write Pad
	//
	compoundTAG = [self createTag:kWritePad inSection:0];
	[self.dicSettings setValue:[NSNumber numberWithBool:[NLContext shared].isWritePadAvail] forKey:[self tagKeyWithTag:compoundTAG]];
	 */
	//
	// Biz Card
	//
	compoundTAG = [self createTag:kBizCard inSection:0];
	[self.dicSettings setValue:[NSNumber numberWithBool:[NLContext shared].isBizCardAvail] forKey:[self tagKeyWithTag:compoundTAG]];
	//
	// Barcode
	//
	compoundTAG = [self createTag:kBarcode inSection:0];
	[self.dicSettings setValue:[NSNumber numberWithBool:[NLContext shared].isBarCodeAvail] forKey:[self tagKeyWithTag:compoundTAG]];
	//
	// Intermec
	//
//	compoundTAG = [self createTag:kIntermec inSection:0];
//	[self.dicSettings setValue:[NSNumber numberWithBool:[NLContext shared].isIntermecAvail] forKey:[self tagKeyWithTag:compoundTAG]];
	//
	// Socket
	//
	compoundTAG = [self createTag:kSocket inSection:0];
	[self.dicSettings setValue:[NSNumber numberWithBool:[NLContext shared].isSocketAvail] forKey:[self tagKeyWithTag:compoundTAG]];
    //
    // Scan and Go
    //
    compoundTAG = [self createTag:kScanAndGo inSection:0];
    [self.dicSettings setValue:[NSNumber numberWithBool:[NLContext shared].isScanAndGo] forKey:[self tagKeyWithTag:compoundTAG]];
//	kBarcodeSettings,
}

- (void) updateDatasource
{
	NSInteger compoundTAG	= NSNotFound;
	//
	// Scanner ID
	//
	compoundTAG = [self createTag:kScannerId inSection:0];
	[NLContext shared].stationID = [NSString stringWithFormat:@"%@", [self.dicSettings valueForKey:[self tagKeyWithTag:compoundTAG]]];
	//
	// Server URL
	//
	compoundTAG = [self createTag:kServerURL inSection:0];
	[NLContext shared].clientURL = [self.dicSettings valueForKey:[self tagKeyWithTag:compoundTAG]];
	//
	// Scan Mode
	//
	compoundTAG = [self createTag:kScanMode inSection:0];
	[NLDeviceController device].cardMode = [[self.dicSettings valueForKey:[self tagKeyWithTag:compoundTAG]] boolValue];
    [NLContext shared].isRawMode = [NLDeviceController device].cardMode;
	/*
	//
	// Sketch Pad
	//
	compoundTAG = [self createTag:kSketchPad inSection:0];
	[NLContext shared].isSketchPadAvail = [[self.dicSettings valueForKey:[self tagKeyWithTag:compoundTAG]] boolValue];
	//
	// Signature
	//
	compoundTAG = [self createTag:kSignature inSection:0];
	[NLContext shared].isSignatureAvail = [[self.dicSettings valueForKey:[self tagKeyWithTag:compoundTAG]] boolValue];
	//
	// Write Pad
	//
	compoundTAG = [self createTag:kWritePad inSection:0];
	[NLContext shared].isWritePadAvail = [[self.dicSettings valueForKey:[self tagKeyWithTag:compoundTAG]] boolValue];
	 */
	//
	// Biz Card
	//
	compoundTAG = [self createTag:kBizCard inSection:0];
	[NLContext shared].isBizCardAvail = [[self.dicSettings valueForKey:[self tagKeyWithTag:compoundTAG]] boolValue];
	//
	// Barcode
	//
	compoundTAG = [self createTag:kBarcode inSection:0];
	[NLContext shared].isBarCodeAvail = [[self.dicSettings valueForKey:[self tagKeyWithTag:compoundTAG]] boolValue];
	//
	// Intermec
	//
//	compoundTAG = [self createTag:kIntermec inSection:0];
//	[NLContext shared].isIntermecAvail = [[self.dicSettings valueForKey:[self tagKeyWithTag:compoundTAG]] boolValue];
	//
	// Socket
	//
	compoundTAG = [self createTag:kSocket inSection:0];
	[NLContext shared].isSocketAvail = [[self.dicSettings valueForKey:[self tagKeyWithTag:compoundTAG]] boolValue];
    //
    // Scan and Go
    //
    compoundTAG = [self createTag:kScanAndGo inSection:0];
    [NLContext shared].isScanAndGo = [[self.dicSettings valueForKey:[self tagKeyWithTag:compoundTAG]] boolValue];

	[[NLContext shared] saveAppSettings];
	
	if( self.changesBlock )
	{
		self.changesBlock(self);
	}	
}

- (NSInteger) createTag:(NSInteger) anTag inSection:(NSInteger) anSection
{
	NSInteger index = ((anSection<<8) | anTag );
	
	return index;
}

- (NSString *) tagKeyWithTag:(NSInteger) anCompoundTag
{
	return [NSString stringWithFormat:@"%ld", (long)anCompoundTag];
}

- (NSIndexPath *) indexPathFromTag:(NSInteger) anTag
{
	// TODO: Think about more generic
	NSInteger section	= (anTag>>8)&0xFF;
	NSInteger row		= (anTag&0xFF);
	
	return [NSIndexPath indexPathForRow:row inSection:section];
}

- (UITextField *) fieldWithTAG:(NSInteger) anTag inTable:(UITableView *) anTable withPath:(NSIndexPath *) anPath
{
	if( !anTable && !anPath )
	{
		return nil;
	}
	
	UITableViewCell * currCell	= [anTable cellForRowAtIndexPath:anPath];
	UITextField * field			= nil;
	
	if( [currCell isKindOfClass:[NLFieldCellView class]] )
	{
		field = ((NLFieldCellView *)currCell).textField;
	}
	else
	{
		field = (UITextField *)[[currCell contentView] viewWithTag:anTag];
	}
	
	return ([field isKindOfClass:[UITextField class]] ? field : nil);
}

- (NLCellSwitchAction) cellSwitchActionBlock
{
	return [^(NSInteger tag, NSIndexPath * path, BOOL state)
	{
		[self.activeField resignFirstResponder];
		
		[self.dicSettings setValue:[NSNumber numberWithBool:state] forKey:[self tagKeyWithTag:tag]];
		
        [self updateDatasource];
		
		[self.viewTable reloadData];
		
	} copy];
}

- (NLCellButtonAction) cellButtonActionBlock
{
	return [^(UIButton *button)
	{
		[self.activeField resignFirstResponder];
		
		[NLPasswordAlertView show:@"Enter password"
						  message:@""
						  buttons:[NSArray arrayWithObjects:@"Cancel", @"Done", nil]
							block:^void(NLPasswordAlertView *alertView, NSString *fieldValue, NSInteger buttonIndex)
		 {
			 if( 0 == buttonIndex )
			 {
				 // Do nothing...
			 }
			 else if( 1 == buttonIndex )
			 {
				 if( !fieldValue || 0 == [fieldValue length] )
				 {
					 return;
				 }
				 
				 if( [kNLLogoutPassphrase isEqualToString:fieldValue] )
				 {
					 [[NLAppDelegate shared] logout];
				 }
				 else
				 {
					 [NLAlertView showError:@"Wrong password!"];
				 }
			 }
		 }];

	} copy];
}



#pragma mark - UITableViewDelegate
//
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( kServerURL == indexPath.row || kScannerId == indexPath.row )
	{
		return;
	}
	
	[self.activeField resignFirstResponder];
	
	if( kBarcodeSettings == indexPath.row && [NLContext shared].isBarCodeAvail)
	{
		NLBarcodeVC * bvc = [NLBarcodeVC new];
		
		[self.navigationController pushViewController:bvc animated:YES];
	}
}



#pragma mark - UITableViewDelegate
//
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if( kLogout == indexPath.row )
	{
		return 66;
	}
	return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 66;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return kSettingsCount;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	UILabel * l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 66)];
	l.backgroundColor	= [UIColor clearColor];
	l.numberOfLines		= 2;
	l.textColor			= [UIColor darkGrayColor];
	l.textAlignment		= NSTextAlignmentCenter;
	l.text				= [NSString stringWithFormat:@"Version:\n%@", [[NLContext shared] appVersion]];
	
	return l;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell * cell = nil;
	
	NSInteger compoundTAG	= [self createTag:indexPath.row inSection:indexPath.section];
	NSString * tagKey		= [self tagKeyWithTag:compoundTAG];
	
	
	if( kScannerId == indexPath.row )
	{
		NLFieldCellView * tempCell		= [tableView dequeueReusableCellWithIdentifier:[NLFieldCellView reuseID] forIndexPath:indexPath];
		tempCell.labelTitle.text		= @"Scanner ID";
		tempCell.textField.tag			= compoundTAG;
		tempCell.textField.delegate		= self;
		tempCell.textField.keyboardType	= UIKeyboardTypeAlphabet;
		tempCell.textField.returnKeyType= UIReturnKeyNext;
		tempCell.textField.text			= [NSString stringWithFormat:@"%@", [self.dicSettings valueForKey:tagKey]];
		[tempCell.textField addTarget:self action:@selector(textFieldDidChangedValue:) forControlEvents:UIControlEventEditingChanged];
		
		cell = tempCell;
	}
	else if( kServerURL == indexPath.row )
	{
		NLFieldCellView * tempCell		= [tableView dequeueReusableCellWithIdentifier:[NLFieldCellView reuseID] forIndexPath:indexPath];
		tempCell.labelTitle.text		= @"Client URL";
		tempCell.textField.tag			= compoundTAG;
		tempCell.textField.delegate		= self;
		tempCell.textField.keyboardType	= UIKeyboardTypeURL;
		tempCell.textField.returnKeyType= UIReturnKeyNext;
		tempCell.textField.text			= [self.dicSettings valueForKey:tagKey];
		[tempCell.textField addTarget:self action:@selector(textFieldDidChangedValue:) forControlEvents:UIControlEventEditingChanged];
		
		cell = tempCell;
	}
	else if( kScanMode == indexPath.row )
	{
		NLSwitchCellView * tempCell = [tableView dequeueReusableCellWithIdentifier:[NLSwitchCellView reuseID] forIndexPath:indexPath];
		tempCell.text	= [NSString stringWithFormat:@"Scan Mode: %@", [NLDeviceController device].cardModeText];
		tempCell.TAG	= compoundTAG;
		tempCell.state	= [[self.dicSettings valueForKey:tagKey] boolValue];
		
		[tempCell setupSwitchAction:[self cellSwitchActionBlock]];
		
		cell = tempCell;
	}
	/*
	else if( kSketchPad == indexPath.row )
	{
		NLSwitchCellView * tempCell = [tableView dequeueReusableCellWithIdentifier:[NLSwitchCellView reuseID] forIndexPath:indexPath];
		tempCell.text	= @"Sketch Pad";
		tempCell.TAG	= compoundTAG;
		tempCell.state	= [[self.dicSettings valueForKey:tagKey] boolValue];
		
		[tempCell setupSwitchAction:[self cellSwitchActionBlock]];
		
		cell = tempCell;
	}
	else if( kWritePad == indexPath.row )
	{
		NLSwitchCellView * tempCell = [tableView dequeueReusableCellWithIdentifier:[NLSwitchCellView reuseID] forIndexPath:indexPath];
		tempCell.text	= @"Write Pad";
		tempCell.TAG	= compoundTAG;
		tempCell.state	= [[self.dicSettings valueForKey:tagKey] boolValue];
		
		[tempCell setupSwitchAction:[self cellSwitchActionBlock]];
		
		cell = tempCell;
	}
	else if( kSignature == indexPath.row )
	{
		NLSwitchCellView * tempCell = [tableView dequeueReusableCellWithIdentifier:[NLSwitchCellView reuseID] forIndexPath:indexPath];
		tempCell.text	= @"Signature";
		tempCell.TAG	= compoundTAG;
		tempCell.state	= [[self.dicSettings valueForKey:tagKey] boolValue];
		
		[tempCell setupSwitchAction:[self cellSwitchActionBlock]];
		
		cell = tempCell;
	}
	 */
	else if( kBizCard == indexPath.row )
	{
		NLSwitchCellView * tempCell = [tableView dequeueReusableCellWithIdentifier:[NLSwitchCellView reuseID] forIndexPath:indexPath];
		tempCell.text	= @"Biz Card";
		tempCell.TAG	= compoundTAG;
		tempCell.state	= [[self.dicSettings valueForKey:tagKey] boolValue];
		
		[tempCell setupSwitchAction:[self cellSwitchActionBlock]];
		
		cell = tempCell;
	}
	else if( kBarcode == indexPath.row )
	{
		NLSwitchCellView * tempCell = [tableView dequeueReusableCellWithIdentifier:[NLSwitchCellView reuseID] forIndexPath:indexPath];
		tempCell.text	= @"Barcode";
		tempCell.TAG	= compoundTAG;
		tempCell.state	= [[self.dicSettings valueForKey:tagKey] boolValue];
		
		[tempCell setupSwitchAction:[self cellSwitchActionBlock]];
		
		cell = tempCell;
	}
	else if( kBarcodeSettings == indexPath.row )
	{
		static NSString * regularCellID = @"regularCellID";
		
		UITableViewCell * tempCell = [tableView dequeueReusableCellWithIdentifier:regularCellID];
		if( !tempCell )
		{
			tempCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:regularCellID];
		}
		tempCell.tag			= compoundTAG;
		tempCell.textLabel.text	= @"Barcode Settings";
		
		NSInteger barcodeTAG= [self createTag:kBarcode inSection:0];
		BOOL barcodeEnabled	= [[self.dicSettings valueForKey:[self tagKeyWithTag:barcodeTAG]] boolValue];
		
		tempCell.textLabel.textColor = (barcodeEnabled ? [UIColor blackColor] : [UIColor grayColor]);
		tempCell.accessoryType	= ( barcodeEnabled ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone);
		
		cell = tempCell;
	}
//	else if( kIntermec == indexPath.row )
//	{
//		NLSwitchCellView * tempCell = [tableView dequeueReusableCellWithIdentifier:[NLSwitchCellView reuseID] forIndexPath:indexPath];
//		tempCell.text	= @"Intermec";
//		tempCell.TAG	= compoundTAG;
//		tempCell.state	= [[self.dicSettings valueForKey:tagKey] boolValue];
//		
//		[tempCell setupSwitchAction:[self cellSwitchActionBlock]];
//		
//		cell = tempCell;
//	}
	else if( kSocket == indexPath.row )
	{
		NLSwitchCellView * tempCell = [tableView dequeueReusableCellWithIdentifier:[NLSwitchCellView reuseID] forIndexPath:indexPath];
		tempCell.text	= @"Socket";
		tempCell.TAG	= compoundTAG;
		tempCell.state	= [[self.dicSettings valueForKey:tagKey] boolValue];
		
		[tempCell setupSwitchAction:[self cellSwitchActionBlock]];
		
		cell = tempCell;
	}
    else if( kScanAndGo == indexPath.row )
    {
        NLSwitchCellView * tempCell = [tableView dequeueReusableCellWithIdentifier:[NLSwitchCellView reuseID] forIndexPath:indexPath];
        tempCell.text	= @"Scan and Go";
        tempCell.TAG	= compoundTAG;
        tempCell.state	= [[self.dicSettings valueForKey:tagKey] boolValue];
        
        [tempCell setupSwitchAction:[self cellSwitchActionBlock]];
        
        cell = tempCell;
    }
	else if( kLogout == indexPath.row )
	{
		NLButtonCellView * tempCell= [tableView dequeueReusableCellWithIdentifier:[NLButtonCellView reuseID] forIndexPath:indexPath];
		tempCell.tag	= compoundTAG;
		
		[tempCell.btnAction setTitle:@"Reload Settings" forState:UIControlStateNormal];
		[tempCell.btnAction setBackgroundColor:[UIColor redColor]];
		
		[tempCell setupCompletion:[self cellButtonActionBlock]];
		
		cell = tempCell;
	}

	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.backgroundColor = [UIColor clearColor];
	
	return cell;
}



#pragma mark - UITextFieldDelegate
//
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
	self.activeField = textField;
	self.activePath = [self indexPathFromTag:textField.tag];
	
	[self.viewTable scrollToRowAtIndexPath:self.activePath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void) textFieldDidChangedValue:(UITextField*)textField
{
	NSString * newText = textField.text;
	
	[self.dicSettings setValue:newText forKey:[self tagKeyWithTag:textField.tag]];
    
    if (textField.keyboardType	== UIKeyboardTypeURL)
    {
        self.urlChanged = YES;
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
	self.activePath = nil;
}

- (BOOL) textFieldShouldReturn:(UITextField *) textField
{
	[self jumpFromTAG:textField.tag forward:YES];
	
	return NO;
}



#pragma mark >>> Navigation across the fields
//
- (void) jumpFromTAG:(NSInteger) currentTAG forward:(BOOL) isForward
{
	//
	// This is custom rule to jumping between fields
	// Also I like this http://stackoverflow.com/a/5889795 solution
	//
	self.activeField = nil;
	self.activePath = nil;
	
	NSInteger nextTag = currentTAG + (isForward ? 1 : -1);
	
	// Switch between tables:
	//
	if( isForward )
	{
		if( kServerURL == currentTAG ) // End of table
		{
			nextTag = kScannerId;
		}
	}
	else
	{
		if( kScannerId == currentTAG ) // Begin of table
		{
			nextTag = kServerURL;
		}
	}
	
	self.activePath = [self indexPathFromTag:nextTag];
	//
	// We need this step because "cellForRowAtIndexPath" returns nil in case of
	// off-visible cell. So we scroll to required cell and read textfield value.
	//
	if( ![[self.viewTable indexPathsForVisibleRows] containsObject:self.activePath] )
	{
		[self.viewTable scrollToRowAtIndexPath:self.activePath atScrollPosition:UITableViewScrollPositionTop animated:NO];
	}
	UITextField * tf = [self fieldWithTAG:nextTag inTable:self.viewTable withPath:self.activePath];
	
	if( tf )
	{
		UIResponder* nextResponder = tf;
		if (nextResponder)
		{
			// Found next responder, so set it.
			[nextResponder becomeFirstResponder];
			
			self.activeField = tf;
		}
	}
}

#pragma mark >>> Keyboard actions
//
- (void) keyboardWillShow:(NSNotification *)notification
{
	NSDictionary * info		= [notification userInfo];
	CGRect rcKeyboard		= [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	//	CGSize keyboardSize		= rcKeyboard.size;
	//	CGFloat offset			= 0;
	//
	//	if( UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) )
	//	{
	//		offset = keyboardSize.height;
	//    }
	//	else
	//	{
	//		offset = keyboardSize.width;
	//    }
	
	if(CGRectIsEmpty(self.rcTableOriginal) )
	{
		self.rcTableOriginal = self.viewTable.frame;
	}
	
	CGRect rcTable = self.viewTable.frame;
	
	CGFloat dY = rcKeyboard.origin.y - rcTable.size.height;
	dY = (0 > dY ? [UIApplication sharedApplication].statusBarFrame.size.height : dY);
	
	CGFloat dH = dY + rcTable.size.height;
	dH = (dH > rcKeyboard.origin.y ? dH - rcKeyboard.origin.y : 0);
	
	rcTable.origin.y = dY;
	rcTable.size.height -= dH;
	
	[UIView animateWithDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]
						  delay:0.0
						options:UIViewAnimationOptionBeginFromCurrentState
					 animations:^(void)
	 {
		 self.viewTable.frame = rcTable;
	 }
					 completion:^(BOOL finished)
	 {
		 self.viewTable.scrollEnabled = YES;
		 [self.viewTable scrollToRowAtIndexPath:self.activePath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	 }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
	NSDictionary* info	= [notification userInfo];
	
	CGRect rcTable = self.rcTableOriginal;
	
	[UIView animateWithDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]
						  delay:0.0
						options:UIViewAnimationOptionBeginFromCurrentState
					 animations:^(void)
	 {
		 self.viewTable.frame = rcTable;
	 }
					 completion:^(BOOL finished)
	 {
		 self.viewTable.scrollEnabled = NO;
	 }];
}



#pragma mark - UINavigationControllerDelegate
//
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if( ![viewController isKindOfClass:[self class]] )
	{
		self.navigationController.delegate = nil;
		[self onButtonDone:nil];
	}
}

@end
