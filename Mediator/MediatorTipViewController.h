//
//  MediatorTipViewController.h
//  Mediator
//
//  Created by huangkexuan on 16/8/3.
//  Copyright © 2016年 Cloud Funds Management. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediatorTipViewController : UIViewController

@property (nonatomic, readonly) BOOL isparamsError;
@property (nonatomic, readonly) BOOL isNotURLSupport;
@property (nonatomic, readonly) BOOL isNotFound;

+(nonnull UIViewController *)paramsErrorTipController;

+(nonnull UIViewController *)notURLTipController;

+(nonnull UIViewController *)notFoundTipConctroller;

-(void)showDebugTipController:(nonnull NSURL *)URL
               withParameters:(nullable NSDictionary *)parameters;

@end
