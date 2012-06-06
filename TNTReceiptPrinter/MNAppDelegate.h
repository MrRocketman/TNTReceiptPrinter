//
//  MNAppDelegate.h
//  TNTReceiptPrinter
//
//  Created by James Adams on 6/6/12.
//  Copyright (c) 2012 Pencil Busters, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end
