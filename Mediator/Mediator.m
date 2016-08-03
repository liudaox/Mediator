/*********************************************************************************
 *Copyright (c) 2016 Mediator Inc. All rights reserved.
 *FileName:  Mediator.m
 *Author:  黄牁轩
 *Date:  2016.4.2
 *Description:中间件实现UI总线
 **********************************************************************************/

#import "Mediator.h"
#import "MediatorNavigator.h"
#import "MediatorConnectorPrt.h"
#import "MediatorTipViewController.h"

NSString* const routeViewControllerKey = @"routeViewController";
NSString *__nonnull const routeModeKey = @"routeType";

//全部保存各个模块的connector实例
static NSMutableDictionary<NSString *, id<MediatorConnectorPrt>> *g_connectorMap = nil;


@implementation Mediator

#pragma mark - 向总控制中心注册挂接点

+(void)registerConnector:(nonnull id<MediatorConnectorPrt>)connector{
    if (![connector conformsToProtocol:@protocol(MediatorConnectorPrt)]) {
        return;
    }
    
    @synchronized(g_connectorMap) {
        if (g_connectorMap == nil){
            g_connectorMap = [[NSMutableDictionary alloc] initWithCapacity:5];
        }
        
        NSString *connectorClsStr = NSStringFromClass([connector class]);
        if ([g_connectorMap objectForKey:connectorClsStr] == nil) {
            [g_connectorMap setObject:connector forKey:connectorClsStr];
        }
    }
}


#pragma mark - 页面跳转接口

//判断某个URL能否导航
+(BOOL)canRouteURL:(nonnull NSURL *)URL{
    if(!g_connectorMap || g_connectorMap.count <= 0) return NO;
    
    __block BOOL success = NO;
    //遍历connector不能并发
    [g_connectorMap enumerateKeysAndObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull key, id<MediatorConnectorPrt>  _Nonnull connector, BOOL * _Nonnull stop) {
        if([connector respondsToSelector:@selector(canOpenURL:)]){
            if ([connector canOpenURL:URL]) {
                success = YES;
                *stop = YES;
            }
        }
    }];
    
    return success;
}


+(BOOL)routeURL:(nonnull NSURL *)URL{
    return [self routeURL:URL withParameters:nil];
}


+(BOOL)routeURL:(nonnull NSURL *)URL withParameters:(nullable NSDictionary *)params{
    if(!g_connectorMap || g_connectorMap.count <= 0) return NO;
    
    __block BOOL success = NO;
    __block int queryCount = 0;
    NSDictionary *userParams = [self userParametersWithURL:URL andParameters:params];
    [g_connectorMap enumerateKeysAndObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull key, id<MediatorConnectorPrt>  _Nonnull connector, BOOL * _Nonnull stop) {
        queryCount++;
        if([connector respondsToSelector:@selector(connectToOpenURL:params:)]){
            id returnObj = [connector connectToOpenURL:URL params:userParams];
            if(returnObj && [returnObj isKindOfClass:[UIViewController class]]){
                if ([returnObj isKindOfClass:[MediatorTipViewController class]]) {
                    MediatorTipViewController *tipController = (MediatorTipViewController *)returnObj;
                    if (tipController.isNotURLSupport) {
                        success = YES;
                    } else {
                        success = NO;
#if DEBUG
                        [tipController showDebugTipController:URL withParameters:params];
                        success = YES;
#endif
                    }
                } else if ([returnObj class] == [UIViewController class]){
                    success = YES;
                } else {
                    [[MediatorNavigator navigator] hookShowURLController:returnObj baseViewController:params[routeViewControllerKey] routeMode:params[routeModeKey]?[params[routeModeKey] intValue]:NavigationModePush];
                    success = YES;
                }
                
                *stop = YES;
            }
        }
    }];
    
    
#if DEBUG
    if (!success && queryCount == g_connectorMap.count) {
        [((MediatorTipViewController *)[UIViewController notFound]) showDebugTipController:URL withParameters:params];
        return NO;
    }
#endif
    
    return success;
}


+(nullable UIViewController *)viewControllerForURL:(nonnull NSURL *)URL{
    return [self viewControllerForURL:URL withParameters:nil];
}


+(nullable UIViewController *)viewControllerForURL:(nonnull NSURL *)URL withParameters:(nullable NSDictionary *)params{
    if(!g_connectorMap || g_connectorMap.count <= 0) return nil;
    
    __block UIViewController *returnObj = nil;
    __block int queryCount = 0;
    NSDictionary *userParams = [self userParametersWithURL:URL andParameters:params];
    [g_connectorMap enumerateKeysAndObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull key, id<MediatorConnectorPrt>  _Nonnull connector, BOOL * _Nonnull stop) {
        queryCount++;
        if([connector respondsToSelector:@selector(connectToOpenURL:params:)]){
            returnObj = [connector connectToOpenURL:URL params:userParams];
            if(returnObj && [returnObj isKindOfClass:[UIViewController class]]){
                *stop = YES;
            }
        }
    }];
    
    
#if DEBUG
    if (!returnObj && queryCount == g_connectorMap.count) {
        [((MediatorTipViewController *)[UIViewController notFound]) showDebugTipController:URL withParameters:params];
        return nil;
    }
#endif
    
    
    if (returnObj) {
        if ([returnObj isKindOfClass:[MediatorTipViewController class]]) {
#if DEBUG
            [((MediatorTipViewController *)returnObj) showDebugTipController:URL withParameters:params];
#endif
            return nil;
        } else if([returnObj class] == [UIViewController class]){
            return nil;
        } else {
            return returnObj;
        }
    }
    
    return nil;
}


/**
 * 从url获取query参数放入到参数列表中
 */
+(NSDictionary *)userParametersWithURL:(nonnull NSURL *)URL andParameters:(nullable NSDictionary *)params{
    NSArray *pairs = [URL.query componentsSeparatedByString:@"&"];
    NSMutableDictionary *userParams = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        if (kv.count == 2) {
            NSString *key = [kv objectAtIndex:0];
            NSString *value = [self URLDecodedString:[kv objectAtIndex:1]];
            [userParams setObject:value forKey:key];
        }
    }
    [userParams addEntriesFromDictionary:params];
    return [NSDictionary dictionaryWithDictionary:userParams];
}


/**
 * 对url的value部分进行urlDecoding
 */
+(nonnull NSString *)URLDecodedString:(nonnull NSString *)urlString
{
    NSString *result = urlString;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0
    result = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                   (__bridge CFStringRef)urlString,
                                                                                                   CFSTR(""),
                                                                                                   kCFStringEncodingUTF8);
#else
    result = [urlString stringByRemovingPercentEncoding];
#endif
    return result;
}


#pragma mark - 服务调用接口

+(nullable id)serviceForProtocol:(nonnull Protocol *)protocol{
    if(!g_connectorMap || g_connectorMap.count <= 0) return nil;
    
    __block id returnServiceImp = nil;
    [g_connectorMap enumerateKeysAndObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull key, id<MediatorConnectorPrt>  _Nonnull connector, BOOL * _Nonnull stop) {
        if([connector respondsToSelector:@selector(connectToHandleProtocol:)]){
            returnServiceImp = [connector connectToHandleProtocol:protocol];
            if(returnServiceImp){
                *stop = YES;
            }
        }
    }];
    
    return returnServiceImp;
}

@end
