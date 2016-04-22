/*********************************************************************************
 *Copyright (c) 2016 Mediator Inc. All rights reserved.
 *FileName:  Mediator.m
 *Author:  黄牁轩
 *Date:  2016.4.2
 *Description:中间件实现单例
 **********************************************************************************/

#import <UIKit/UIKit.h>
#import "Mediator.h"
#import <objc/runtime.h>

@implementation Mediator

#pragma mark - public methods-单例模式
+ (instancetype)sharedInstance
{
    static Mediator *mediator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[Mediator alloc] init];
    });
    return mediator;
}

- (id)performTarget:(NSString*)targetName send:(NSString*)sendName params:(NSDictionary *)params
{
    Class targetClass = NSClassFromString(targetName);
    id target;
    
    if(targetClass)
    {
        if([targetClass isKindOfClass:[UIViewController class]])
        {
               target = [[targetClass alloc] init];
            
        }else if([targetClass isKindOfClass:[NSObject class]])
        {
            SEL sel = NSSelectorFromString(@"sharedManager");//单例模式
            if([targetClass respondsToSelector:sel]) {
                return  [targetClass performSelector:sel];
                
            }else
            {
                   target = [[targetClass alloc] init];
               SEL action = NSSelectorFromString(sendName);
                if ([target respondsToSelector:action]) {
                    return [target performSelector:action withObject:params];//返回方法
                } else {
                    //未知方法
                    return nil;
                }
            }
        }else {
            //未知对象
            return nil;
        }
    }

    //查无此类
    return nil;
}

@end
