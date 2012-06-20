//
//  MNSecondViewController.h
//  TNTReceiptPrinter
//
//  Created by James Adams on 6/6/12.
//  Copyright (c) 2012 Pencil Busters, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCDAsyncSocket;

enum 
{
    kDisconnected,
    kConnected,
    kWaitingForIPAddress,
    kPrinterBusy,
};

enum
{
    kNoUnderline,
    kThinUnderline,
    kThickUnderline,
};

enum
{
    kLeftAlignment,
    kCenterAlignment,
    kRightAlignment,
};

enum
{
    kSmallTextSize,
    kMediumTextSize,
    kLargeTextSize,
};

@interface MNCommandsViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *scrollViewContent;
    IBOutlet UIButton *connectDisconnectButton;
    IBOutlet UILabel *connectedStatusLabel;
    int connectedStatus;
    IBOutlet UILabel *authorizedLabel;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UITextField *networkNameTextField;
    IBOutlet UIButton *sleepWakeButton;
    BOOL sleep;
    IBOutlet UIButton *printerOfflineOnlineButton;
    BOOL printerOffline;
    IBOutlet UITextField *textToPrintTextField;
    IBOutlet UIButton *upsidedownOnOffButton;
    BOOL upsidedownOn;
    IBOutlet UIButton *inverseOnOffButton;
    BOOL inverseOn;
    IBOutlet UIButton *boldOnOffButton;
    BOOL boldOn;
    IBOutlet UIButton *strikeOnOffButton;
    BOOL strikeOn;
    IBOutlet UIButton *doubleHeightOnOffButton;
    BOOL doubleHeightOn;
    IBOutlet UIButton *doubleWidthOnOffButton;
    BOOL doubleWidthOn;
    IBOutlet UIStepper *lineFeedStepper;
    IBOutlet UILabel *lineFeedValue;
    IBOutlet UIStepper *pixelFeedStepper;
    IBOutlet UILabel *pixelFeedValue;
    IBOutlet UIStepper *characterSpacingStepper;
    IBOutlet UILabel *characterSpacingValue;
    IBOutlet UIStepper *lineHeightStepper;
    IBOutlet UILabel *lineHeightValue;
    
    GCDAsyncSocket *socket;
    NSDate *connectAttemptDate;
    
    BOOL commandFinished;
}

@property (readonly, strong) IBOutlet UIScrollView *scrollView;
@property (readonly, strong) IBOutlet UIView *scrollViewContent;
@property (readonly, strong) IBOutlet UIButton *connectDisconnectButton;
@property (readonly, strong) IBOutlet UILabel *connectedStatusLabel;
@property (readonly, strong) IBOutlet UILabel *authorizedLabel;
@property (readonly, strong) IBOutlet UITextField *passwordTextField;
@property (readonly, strong) IBOutlet UITextField *networkNameTextField;
@property (readonly, strong) IBOutlet UIButton *sleepWakeButton;
@property (readonly, strong) IBOutlet UIButton *printerOfflineOnlineButton;
@property (readonly, strong) IBOutlet UITextField *textToPrintTextField;
@property (readonly, strong) IBOutlet UIButton *upsidedownOnOffButton;
@property (readonly, strong) IBOutlet UIButton *inverseOnOffButton;
@property (readonly, strong) IBOutlet UIButton *boldOnOffButton;
@property (readonly, strong) IBOutlet UIButton *strikeOnOffButton;
@property (readonly, strong) IBOutlet UIButton *doubleHeightOnOffButton;
@property (readonly, strong) IBOutlet UIButton *doubleWidthOnOffButton;
@property (readonly, strong) IBOutlet UIStepper *lineFeedStepper;
@property (readonly, strong) IBOutlet UILabel *lineFeedValue;
@property (readonly, strong) IBOutlet UIStepper *pixelFeedStepper;
@property (readonly, strong) IBOutlet UILabel *pixelFeedValue;
@property (readonly, strong) IBOutlet UIStepper *characterSpacingStepper;
@property (readonly, strong) IBOutlet UILabel *characterSpacingValue;
@property (readonly, strong) IBOutlet UIStepper *lineHeightStepper;
@property (readonly, strong) IBOutlet UILabel *lineHeightValue;

- (IBAction)connectDisconnectButtonTouch:(id)sender;
- (IBAction)authorizePasswordButtonTouch:(id)sender;
- (IBAction)changePasswordButtonTouch:(id)sender;
- (IBAction)requestNetworkNameButtonTouch:(id)sender;
- (IBAction)changeNetworkNameButtonTouch:(id)sender;
- (IBAction)sleepWakePrinterButtonTouch:(id)sender;
- (IBAction)printerOfflineOnlineButtonTouch:(id)sender;
- (IBAction)iOSBitmapButtonTouch:(id)sender;
- (IBAction)defaultBitmapButtonTouch:(id)sender;
- (IBAction)restoreDefaultPrinterSettingsButtonTouch:(id)sender;
- (IBAction)restoreDefaultNetworkSettingsButtonTouch:(id)sender;
- (IBAction)resetPrinterButtonTouch:(id)sender;
- (IBAction)printTextButtonTouch:(id)sender;
- (IBAction)upsidedownOnOffButtonTouch:(id)sender;
- (IBAction)inverseOnOffButtonTouch:(id)sender;
- (IBAction)boldOnOffButtonTouch:(id)sender;
- (IBAction)strikeOnOffButtonTouch:(id)sender;
- (IBAction)xHeightOnOffButtonTouch:(id)sender;
- (IBAction)xWidthOnOffButtonTouch:(id)sender;
- (IBAction)underlineSegmentedControlValueChanged:(id)sender;
- (IBAction)textAlignmentSegmentedControlVallueChanged:(id)sender;
- (IBAction)textSizeSegmentedControlValueChanged:(id)sender;
- (IBAction)lineFeedButtonTouch:(id)sender;
- (IBAction)lineFeedStepperValueChanged:(id)sender;
- (IBAction)pixelFeedButtonTouch:(id)sender;
- (IBAction)pixelFeedStepperValueChanged:(id)sender;
- (IBAction)characterSpacingStepperValueChanged:(id)sender;
- (IBAction)lineHeightStepperValueChanged:(id)sender;
- (IBAction)openCashDrawerButtonTouch:(id)sender;

@end
