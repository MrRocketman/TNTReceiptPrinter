//
//  MNSecondViewController.m
//  TNTReceiptPrinter
//
//  Created by James Adams on 6/6/12.
//  Copyright (c) 2012 Pencil Busters, Inc. All rights reserved.
//

#import "MNCommandsViewController.h"
#import "GCDAsyncSocket.h"

#define HOST @"169.254.1.1"
#define HOST_PORT 2000
#define COMMAND_FINISHED 5

@interface MNCommandsViewController ()

- (void)connectToPrinter;
- (void)updateConnectButton;
- (void)writeDataToSocket:(NSData *)data;

@end

@implementation MNCommandsViewController

@synthesize connectDisconnectButton;
@synthesize connectedStatusLabel;
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
@synthesize lineFeedValue;
@synthesize pixelFeedValue;
@synthesize characterSpacingValue;
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

- (void)writeDataToSocket:(NSData *)data
{
    [socket writeData:data withTimeout:-1 tag:0];
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
	NSLog(@"DidDisconnectWithError: %@", err);
    NSLog(@"timeInterval:%f", [errorDate timeIntervalSinceDate:connectAttemptDate]);
    
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
    
    /*for(int i = 0; i < [httpResponse length]; i ++)
    {
        if([httpResponse characterAtIndex:i] == COMMAND_FINISHED)
        {
            commandFinished = YES;
        }
    }
    
    [receivedDataTextView setText:[NSString stringWithFormat:@"%@%@", [receivedDataTextView text], httpResponse]];
    [receivedDataTextView scrollRangeToVisible:NSMakeRange([receivedDataTextView.text length], 0)];*/
    [socket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    NSLog(@"didReadPartialData:withTag:%ld", tag);
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

- (IBAction)authorizePasswordButtonTouch:(id)sender {
}

- (IBAction)changePasswordButtonTouch:(id)sender {
}

- (IBAction)requestNetworkNameButtonTouch:(id)sender {
}

- (IBAction)changeNetworkNameButtonTouch:(id)sender {
}

- (IBAction)sleepWakePrinterButtonTouch:(id)sender {
}

- (IBAction)printerOfflineOnlineButtonTouch:(id)sender {
}

- (IBAction)iOSBitmapButtonTouch:(id)sender {
}

- (IBAction)defaultBitmapButtonTouch:(id)sender {
}

- (IBAction)restoreDefaultPrinterSettingsButtonTouch:(id)sender {
}

- (IBAction)restoreDefaultNetworkSettingsButtonTouch:(id)sender {
}

- (IBAction)resetPrinterButtonTouch:(id)sender {
}

- (IBAction)printTextButtonTouch:(id)sender {
}

- (IBAction)upsidedownOnOffButtonTouch:(id)sender {
}

- (IBAction)inverseOnOffButtonTouch:(id)sender {
}

- (IBAction)boldOnOffButtonTouch:(id)sender {
}

- (IBAction)strikeOnOffButtonTouch:(id)sender {
}

- (IBAction)xHeightOnOffButtonTouch:(id)sender {
}

- (IBAction)xWidthOnOffButtonTouch:(id)sender {
}

- (IBAction)underlineSegmentedControlValueChanged:(id)sender {
}

- (IBAction)textAlignmentSegmentedControlVallueChanged:(id)sender {
}

- (IBAction)textSizeSegmentedControlValueChanged:(id)sender {
}

- (IBAction)lineFeedButtonTouch:(id)sender {
}

- (IBAction)lineFeedStepperValueChanged:(id)sender {
}

- (IBAction)pixelFeedButtonTouch:(id)sender {
}

- (IBAction)pixelFeedStepperValueChanged:(id)sender {
}

- (IBAction)characterSpacingStepperValueChanged:(id)sender {
}

- (IBAction)lineHeightStepperValueChanged:(id)sender {
}



@end
