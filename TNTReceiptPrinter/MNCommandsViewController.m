//
//  MNSecondViewController.m
//  TNTReceiptPrinter
//
//  Created by James Adams on 6/6/12.
//  Copyright (c) 2012 Pencil Busters, Inc. All rights reserved.
//

#import "MNCommandsViewController.h"
#import "GCDAsyncSocket.h"

#define HOST @"1.2.3.4"
#define HOST_PORT 2000
#define COMMAND_FINISHED 5

@interface MNCommandsViewController ()

- (void)connectToPrinter;
- (void)updateConnectButton;
- (void)sendCommandToPrinter:(NSString *)commandText;
- (void)writeStringToSocket:(NSString *)string;
- (void)writeDataToSocket:(NSData *)data;

@end

@implementation MNCommandsViewController

@synthesize scrollView;
@synthesize scrollViewContent;
@synthesize connectDisconnectButton;
@synthesize connectedStatusLabel;
@synthesize authorizedLabel;
@synthesize passwordTextField;
@synthesize networkNameTextField;
@synthesize sleepWakeButton;
@synthesize printerOfflineOnlineButton;
@synthesize textToPrintTextField;
@synthesize upsidedownOnOffButton;
@synthesize inverseOnOffButton;
@synthesize boldOnOffButton;
@synthesize strikeOnOffButton;
@synthesize doubleHeightOnOffButton;
@synthesize doubleWidthOnOffButton;
@synthesize lineFeedStepper;
@synthesize lineFeedValue;
@synthesize pixelFeedStepper;
@synthesize pixelFeedValue;
@synthesize characterSpacingStepper;
@synthesize characterSpacingValue;
@synthesize lineHeightStepper;
@synthesize lineHeightValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title = NSLocalizedString(@"Commands", @"Commands");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    scrollView.contentSize = scrollViewContent.frame.size;
    commandFinished = YES;
    
    // Setup our socket (GCDAsyncSocket).
	// The socket will invoke our delegate methods using the usual delegate paradigm.
	// However, it will invoke the delegate methods on a specified GCD delegate dispatch queue.
	// 
	// Now we can configure the delegate dispatch queue however we want.
	// We could use a dedicated dispatch queue for easy parallelization.
	// Or we could simply use the dispatch queue for the main thread.
	// 
	// The best approach for your application will depend upon convenience, requirements and performance.
	// 
	// For this simple example, we're just going to use the main thread.
	
	dispatch_queue_t mainQueue = dispatch_get_main_queue();
	socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    [self connectToPrinter];
}

- (void)viewDidUnload
{
    connectedStatusLabel = nil;
    passwordTextField = nil;
    networkNameTextField = nil;
    textToPrintTextField = nil;
    lineFeedValue = nil;
    pixelFeedValue = nil;
    characterSpacingValue = nil;
    lineHeightValue = nil;
    connectDisconnectButton = nil;
    sleepWakeButton = nil;
    printerOfflineOnlineButton = nil;
    upsidedownOnOffButton = nil;
    inverseOnOffButton = nil;
    boldOnOffButton = nil;
    strikeOnOffButton = nil;
    doubleHeightOnOffButton = nil;
    doubleWidthOnOffButton = nil;
    scrollView = nil;
    scrollViewContent = nil;
    authorizedLabel = nil;
    lineFeedStepper = nil;
    pixelFeedStepper = nil;
    characterSpacingStepper = nil;
    lineHeightStepper = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Private Methods

- (void)connectToPrinter
{
    NSString *host = HOST;
    uint16_t hostPort = HOST_PORT;
    
    NSLog(@"Connecting to \"%@\" on port %hu...", host, hostPort);
    NSError *error = nil;
    connectAttemptDate = [NSDate date];
    // Attempt socket connection
    [socket connectToHost:host onPort:hostPort withTimeout:1.0 error:&error];
}

- (void)disconnectFromPrinter
{
    connectAttemptDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
    [socket disconnect];
}

- (void)updateConnectButton
{
    if(connectedStatus == kConnected)
    {
        [connectDisconnectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    }
    else 
    {
        [connectDisconnectButton setTitle:@"Connect" forState:UIControlStateNormal];
    }
}

- (void)sendCommandToPrinter:(NSString *)commandText
{
    commandText = [commandText stringByAppendingString:@"\n"];
    [self writeStringToSocket:commandText];
}

- (void)writeStringToSocket:(NSString *)string
{
    NSLog(@"Sending: %@", string);
    NSData *requestData = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataToSocket:requestData];
}

- (void)writeDataToSocket:(NSData *)data
{
    while(commandFinished == NO)
    {
        NSLog(@"Waiting for command finished");
    }
    
    NSLog(@"Write");
    [socket writeData:data withTimeout:-1 tag:0];
    commandFinished = NO;
}

#pragma mark - Socket Delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@"didConnectToHost:%@ port:%hu", host, port);
	[socket readDataWithTimeout:-1 tag:0];
    connectedStatusLabel.text = @"Connected";
    connectedStatus = kConnected;
    [self updateConnectButton];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSDate *errorDate = [NSDate date];
    authorizedLabel.text = @"Not Authorized";
	NSLog(@"DidDisconnectWithError: %@", err);
    
    // Waiting for IP
    if([errorDate timeIntervalSinceDate:connectAttemptDate] > 0.9)
    {
        connectedStatusLabel.text = @"Waiting For IP...";
        connectedStatus = kWaitingForIPAddress;
        // Keep Trying
        [self connectToPrinter];
    }
    else if([errorDate timeIntervalSinceDate:connectAttemptDate] > 0.0)
    {
        connectedStatusLabel.text = @"Printer Is Busy...";
        connectedStatus = kPrinterBusy;
        // Keep Trying
        [self connectToPrinter];
    }
    else
    {
        connectedStatusLabel.text = @"Disconnected";
        connectedStatus = kDisconnected;
    }
    
    [self updateConnectButton];
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"didAcceptNewSocket:%@", newSocket);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	//NSLog(@"didWriteDataWithTag:%ld", tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSLog(@"didReadData:withTag:%ld", tag);
	
	NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"Response:\n%@", httpResponse);
    
    NSRange stringRange;
    stringRange = [httpResponse rangeOfString:@"Authorized"];
    if(stringRange.location != NSNotFound)
    {
        authorizedLabel.text = @"Authorized";
    }
    
    stringRange = [httpResponse rangeOfString:[NSString stringWithFormat:@"%c", COMMAND_FINISHED]];
    if(stringRange.location != NSNotFound)
    {
        commandFinished = YES;
        NSLog(@"commandFinished");
    }
    
    [socket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    NSLog(@"didReadPartialData:withTag:%ld", tag);
}

#pragma mark - UITextField Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - IBActions

- (IBAction)connectDisconnectButtonTouch:(id)sender 
{
    if(connectedStatus != kConnected)
    {
        connectedStatusLabel.text = @"Connecting...";
        [self connectToPrinter];
    }
    else
    {
        [self disconnectFromPrinter];
    }
}

- (IBAction)authorizePasswordButtonTouch:(id)sender 
{
    [self sendCommandToPrinter:[NSString stringWithFormat:@"P0 V%@", [passwordTextField text]]];
}

- (IBAction)changePasswordButtonTouch:(id)sender 
{
    [self sendCommandToPrinter:[NSString stringWithFormat:@"P06 V%@", [passwordTextField text]]];
}

- (IBAction)requestNetworkNameButtonTouch:(id)sender 
{
    
}

- (IBAction)changeNetworkNameButtonTouch:(id)sender 
{
    [self sendCommandToPrinter:[NSString stringWithFormat:@"P07 V%@", [networkNameTextField text]]];
}

- (IBAction)sleepWakePrinterButtonTouch:(id)sender 
{
    if(sleep == NO)
    {
        [self sendCommandToPrinter:@"P03"];
        [self.sleepWakeButton setTitle:@"Wake Printer" forState:UIControlStateNormal];
    }
    else
    {
        [self sendCommandToPrinter:@"P02"];
        [self.sleepWakeButton setTitle:@"Sleep Printer" forState:UIControlStateNormal];
    }
    
    sleep = !sleep;
}

- (IBAction)printerOfflineOnlineButtonTouch:(id)sender 
{
    if(printerOffline == NO)
    {
        [self sendCommandToPrinter:@"P05"];
        [self.printerOfflineOnlineButton setTitle:@"Printer Online" forState:UIControlStateNormal];
    }
    else
    {
        [self sendCommandToPrinter:@"P04"];
        [self.printerOfflineOnlineButton setTitle:@"Printer Offline" forState:UIControlStateNormal];
    }
    
    printerOffline = !printerOffline;
}

- (IBAction)iOSBitmapButtonTouch:(id)sender 
{
    
}

- (IBAction)defaultBitmapButtonTouch:(id)sender 
{
    [self sendCommandToPrinter:@"P11"];
}

- (IBAction)restoreDefaultPrinterSettingsButtonTouch:(id)sender 
{
    [self sendCommandToPrinter:@"P97"];
    // TODO: Set all of the iPhone values to default
}

- (IBAction)restoreDefaultNetworkSettingsButtonTouch:(id)sender 
{
    [self sendCommandToPrinter:@"P98"];
}

- (IBAction)resetPrinterButtonTouch:(id)sender 
{
    [self sendCommandToPrinter:@"P99"];
}

- (IBAction)printTextButtonTouch:(id)sender 
{
    [self sendCommandToPrinter:[NSString stringWithFormat:@"P01 V%@", [textToPrintTextField text]]];
}

- (IBAction)upsidedownOnOffButtonTouch:(id)sender 
{
    if(upsidedownOn == NO)
    {
        [self sendCommandToPrinter:@"F02 V1"];
        [self.upsidedownOnOffButton setTitle:@"Upsidedown Off" forState:UIControlStateNormal];
    }
    else
    {
        [self sendCommandToPrinter:@"F02 V0"];
        [self.upsidedownOnOffButton setTitle:@"Upsidedown On" forState:UIControlStateNormal];
    }
    
    upsidedownOn = !upsidedownOn;
}

- (IBAction)inverseOnOffButtonTouch:(id)sender 
{
    if(inverseOn == NO)
    {
        [self sendCommandToPrinter:@"F01 V1"];
        [self.inverseOnOffButton setTitle:@"Inverse Off" forState:UIControlStateNormal];
    }
    else
    {
        [self sendCommandToPrinter:@"F01 V0"];
        [self.inverseOnOffButton setTitle:@"Inverse On" forState:UIControlStateNormal];
    }
    
    inverseOn = !inverseOn;
}

- (IBAction)boldOnOffButtonTouch:(id)sender 
{
    if(boldOn == NO)
    {
        [self sendCommandToPrinter:@"F06 V1"];
        [self.boldOnOffButton setTitle:@"Bold Off" forState:UIControlStateNormal];
    }
    else
    {
        [self sendCommandToPrinter:@"F06 V0"];
        [self.boldOnOffButton setTitle:@"Bold On" forState:UIControlStateNormal];
    }
    
    boldOn = !boldOn;
}

- (IBAction)strikeOnOffButtonTouch:(id)sender 
{
    if(strikeOn == NO)
    {
        [self sendCommandToPrinter:@"F05 V1"];
        [self.strikeOnOffButton setTitle:@"Strike Off" forState:UIControlStateNormal];
    }
    else
    {
        [self sendCommandToPrinter:@"F05 V0"];
        [self.strikeOnOffButton setTitle:@"Strike On" forState:UIControlStateNormal];
    }
    
    strikeOn = !strikeOn;
}

- (IBAction)xHeightOnOffButtonTouch:(id)sender 
{
    if(doubleHeightOn == NO)
    {
        [self sendCommandToPrinter:@"F03 V1"];
        [self.doubleHeightOnOffButton setTitle:@"2x Height Off" forState:UIControlStateNormal];
    }
    else
    {
        [self sendCommandToPrinter:@"F03 V0"];
        [self.doubleHeightOnOffButton setTitle:@"2x Height On" forState:UIControlStateNormal];
    }
    
    doubleHeightOn = !doubleHeightOn;
}

- (IBAction)xWidthOnOffButtonTouch:(id)sender 
{
    if(doubleWidthOn == NO)
    {
        [self sendCommandToPrinter:@"F04 V1"];
        [self.doubleWidthOnOffButton setTitle:@"2x Width Off" forState:UIControlStateNormal];
    }
    else
    {
        [self sendCommandToPrinter:@"F04 V0"];
        [self.doubleWidthOnOffButton setTitle:@"2x Width On" forState:UIControlStateNormal];
    }
    
    doubleWidthOn = !doubleWidthOn;
}

- (IBAction)underlineSegmentedControlValueChanged:(id)sender 
{
    switch ([(UISegmentedControl *)sender selectedSegmentIndex]) 
    {
        case kNoUnderline:
            [self sendCommandToPrinter:@"F11 V0"];
            break;
        case kThinUnderline:
            [self sendCommandToPrinter:@"F11 V1"];
            break;
        case kThickUnderline:
            [self sendCommandToPrinter:@"F11 V2"];
            break;
        default:
            break;
    }
}

- (IBAction)textAlignmentSegmentedControlVallueChanged:(id)sender 
{
    switch ([(UISegmentedControl *)sender selectedSegmentIndex]) 
    {
        case kLeftAlignment:
            [self sendCommandToPrinter:@"F07 VL"];
            break;
        case kCenterAlignment:
            [self sendCommandToPrinter:@"F07 VC"];
            break;
        case kRightAlignment:
            [self sendCommandToPrinter:@"F07 VR"];
            break;
        default:
            break;
    }
}

- (IBAction)textSizeSegmentedControlValueChanged:(id)sender 
{
    switch ([(UISegmentedControl *)sender selectedSegmentIndex]) 
    {
        case kSmallTextSize:
            [self sendCommandToPrinter:@"F10 VS"];
            break;
        case kMediumTextSize:
            [self sendCommandToPrinter:@"F10 VM"];
            break;
        case kLargeTextSize:
            [self sendCommandToPrinter:@"F10 VL"];
            break;
        default:
            break;
    }
}

- (IBAction)lineFeedButtonTouch:(id)sender 
{
    [self sendCommandToPrinter:[NSString stringWithFormat:@"F08 V%d", (int)[lineFeedStepper value]]];
}

- (IBAction)lineFeedStepperValueChanged:(id)sender 
{
    self.lineFeedValue.text = [NSString stringWithFormat:@"%d", (int)[lineFeedStepper value]];
}

- (IBAction)pixelFeedButtonTouch:(id)sender 
{
    [self sendCommandToPrinter:[NSString stringWithFormat:@"F09 V%d", (int)[pixelFeedStepper value]]];
}

- (IBAction)pixelFeedStepperValueChanged:(id)sender
{
    self.pixelFeedValue.text = [NSString stringWithFormat:@"%d", (int)[pixelFeedStepper value]];
}

- (IBAction)characterSpacingStepperValueChanged:(id)sender 
{
    self.characterSpacingValue.text = [NSString stringWithFormat:@"%d", (int)[characterSpacingStepper value]];
    [self sendCommandToPrinter:[NSString stringWithFormat:@"F12 V%d", (int)[characterSpacingStepper value]]];
}

- (IBAction)lineHeightStepperValueChanged:(id)sender
{
    self.lineHeightValue.text = [NSString stringWithFormat:@"%d", (int)[lineHeightStepper value]];
    [self sendCommandToPrinter:[NSString stringWithFormat:@"F13 V%d", (int)[lineHeightStepper value]]];
}

- (IBAction)openCashDrawerButtonTouch:(id)sender 
{
    [self sendCommandToPrinter:@"P12"];
}



@end
