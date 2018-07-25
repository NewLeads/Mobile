//
//  NLSettingsVC.h
//  NewLeads
//
//  Created by idevs.com on 13/03/2015.
//  Copyright (c) 2015 idevs.com. All rights reserved.
//

#import "NLCommonViewController.h"



typedef NS_ENUM(NSInteger, SettingsTAGS)
{
	kBase		= 0,
	kScannerId	= kBase,
	kServerURL,
	kScanMode,
//	kSketchPad,
//	kWritePad,
//	kSignature,
	kBizCard,
	kBarcode,
	kBarcodeSettings,
	//kIntermec,
	kSocket,
    kScanAndGo,
	kLogout,
	//---------
	kSettingsCount
};


@class NLSettingsVC;

typedef void(^NLSettingsDidChangedBlock)(NLSettingsVC * settingsVC);


@interface NLSettingsVC : NLCommonViewController
<
	UITableViewDataSource,
	UITableViewDelegate,
	UITextFieldDelegate
>
//
// UI - XIB:
@property (nonatomic, readwrite, assign) IBOutlet UITableView	* viewTable;
//
//Logic:
@property (nonatomic, readwrite, assign) CGRect			rcTableOriginal;
@property (nonatomic, readwrite, assign) UITextField	* activeField;
@property (nonatomic, readwrite, retain) NSIndexPath    * activePath;
//
// Datasource:
@property (nonatomic, readwrite, strong) NSMutableDictionary * dicSettings;
//
// Blocks:
@property (nonatomic, readwrite, copy) NLSettingsDidChangedBlock changesBlock;


- (void) setupChangesBlock:(NLSettingsDidChangedBlock) anChangesBlock;

@property (nonatomic, readwrite, assign) BOOL urlChanged;

@end
