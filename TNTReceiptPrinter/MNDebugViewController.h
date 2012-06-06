//
//  MNFirstViewController.h
//  TNTReceiptPrinter
//
//  Created by James Adams on 6/6/12.
//  Copyright (c) 2012 Pencil Busters, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCDAsyncSocket;

@interface MNDebugViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{
    IBOutlet UITextView *receivedDataTextView;
    IBOutlet UITextField *dataToSendTextField;
    IBOutlet UISegmentedControl *dataToSendEndOfLineCharacterSegmentedControl;
    IBOutlet UILabel *statusLabel;
    IBOutlet UIButton *connectDisconnectButton;
    IBOutlet UIButton *printBitmapButton;
    BOOL connected;
    
    BOOL commandFinished;
    BOOL printingBitmap;
    
    GCDAsyncSocket *socket;
}

- (IBAction)endOfLineSegmentChange:(id)sender;
- (IBAction)sendToPrinter:(id)sender;
- (IBAction)connectDisconnectButtonPress:(id)sender;
- (IBAction)printBitmapButtonPress:(id)sender;

@end
