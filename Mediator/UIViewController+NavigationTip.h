//
//  UIViewController+NavigationTip.h
//  Mediator
//
//  Created by huangkexuan on 16/8/3.
//  Copyright © 2016年 Cloud Funds Management. All rights reserved.
//


#import <UIKit/UIKit.h>

/**
 * @category NavigationTip
 *  中间件导航的错误提示
 */
@interface UIViewController (NavigationTip)

/**
 * URL可导航，参数错误无法生成ViewController
 */
+(nonnull UIViewController *) paramsError;

/**
 * URL可导航，但是提供者并没有对URL返回一个ViewController
 */
+(nonnull UIViewController *) notURLController;


/**
 * URL不可导航，提示用户无法通过LDBusMediator导航
 */
+(nonnull UIViewController *) notFound;


@end