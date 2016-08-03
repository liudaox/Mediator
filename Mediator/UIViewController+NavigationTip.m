//
//  UIViewController+NavigationTip.m
//  Mediator
//
//  Created by huangkexuan on 16/8/3.
//  Copyright © 2016年 Cloud Funds Management. All rights reserved.
//
#import "UIViewController+NavigationTip.h"
#import "MediatorTipViewController.h"


@implementation UIViewController (NavigationTip)

+(nonnull UIViewController *) paramsError{
    return [MediatorTipViewController paramsErrorTipController];
}


+(nonnull UIViewController *) notFound{
    return [MediatorTipViewController notFoundTipConctroller];
}


+(nonnull UIViewController *) notURLController{
    return [MediatorTipViewController notURLTipController];
}

@end
