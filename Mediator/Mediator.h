/*********************************************************************************
 *Copyright (c) 2016 Mediator Inc. All rights reserved.
 *FileName:  Mediator.h
 *Author:  黄牁轩
 *Date:  2016.4.2
 *Description:中间件实现单例
 **********************************************************************************/

#import <Foundation/Foundation.h>

@interface Mediator : NSObject

+ (instancetype)sharedInstance;
- (id)performTarget:(NSString*)targetName
               send:(NSString*)sendName
             params:(NSDictionary *)params;

@end
