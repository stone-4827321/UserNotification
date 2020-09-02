//
//  AppDelegate.m
//  UserNotification
//
//  Created by stone on 2020/9/2.
//  Copyright © 2020 3kMac. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>


@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

@synthesize window = _window;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"启动应用");
    //app未启动的情况下收到通知
    id obj;
    if((obj = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey])) {
        NSLog(@"本地通知启动：%@", obj);
    }
    else if((obj = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey])) {
        NSLog(@"远程通知启动：%@", obj);
    }
    
    application.applicationIconBadgeNumber = 0;
    
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNAuthorizationOptions options = UNAuthorizationOptionBadge |
                                         UNAuthorizationOptionSound |
                                         UNAuthorizationOptionAlert;
        if (@available(iOS 12.0, *)) {
            options = options | UNAuthorizationOptionProvidesAppNotificationSettings;
        }
                                
        [center requestAuthorizationWithOptions:options
                              completionHandler:^(BOOL granted, NSError *error) {
            //取得授权
            if (granted) {
            }
            //未取得授权
            else {
            }
            [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                NSLog(@"%@", settings);
            }];
        }];
        center.delegate = self;
    }
    else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    //注册远程推送
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    return YES;
}

#pragma mark - UNUserNotificationCenterDelegate

// 应用在前台时收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler NS_AVAILABLE_IOS(10_0) {
    NSLog(@"应用在前台时收到通知");

    /*
    配置前台可以显示的通知形式，如设置completionHandler(UNNotificationPresentationOptionAlert)后，当通知到达时应用在前台也能以Alert的方式显示通知
    UNNotificationPresentationOptionBadge   = (1 << 0),
    UNNotificationPresentationOptionSound   = (1 << 1),
    UNNotificationPresentationOptionAlert   = (1 << 2),
     */
    completionHandler(UNNotificationPresentationOptionAlert);
}

// 应用在前台、后台状态或未启动时点击通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler  NS_AVAILABLE_IOS(10_0) {
    NSLog(@"应用在前台、后台状态或未启动时点击通知 %@", response.notification);
    
    if ([response isKindOfClass:[UNTextInputNotificationResponse class]]) {
        UNTextInputNotificationResponse *textResponse = (UNTextInputNotificationResponse *)response;
        NSLog(@"点击通知时调用，输入框: %@",textResponse.userText);
    }
    else {
        NSLog(@"点击通知时调用，动作: %@",response.actionIdentifier);
        if ([response.actionIdentifier isEqualToString:UNNotificationDismissActionIdentifier]) {
            NSLog(@"点击了关闭");
        }
        else if([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
            NSLog(@"点击主界面");
        }
        else if([response.actionIdentifier isEqualToString:@"action"]) {
            NSLog(@"点击自定义按钮action");
        }
    }
    completionHandler();
}

// 应用在前台或后台状态时，点击系统的通知设置里"xxx通知设置"的按钮进入应用
- (void)userNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(nullable UNNotification *)notification NS_AVAILABLE_IOS(10_0) {
    NSLog(@"应用在前台或后台状态时，点击系统的通知设置里的按钮进入应用");
}

#pragma mark - UIApplicationDelegate

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"didReceiveLocalNotification");
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (@available(iOS 13.0, *)) {
        if (![deviceToken isKindOfClass:[NSData class]]) {
            return;
        }
        const unsigned *tokenBytes = (const unsigned *)[deviceToken bytes];
        NSString *strToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                              ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                              ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                              ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
        NSLog(@"deviceToken:%@", strToken);
    }
    else {
        NSString *token = [NSString
                       stringWithFormat:@"%@",deviceToken];
        token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
        token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
        token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSLog(@"deviceToken: %@", token);
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    //获取远程推送失败
    NSLog(@"获取远程推送失败：%@", error);//打印
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    NSLog(@"didReceiveRemoteNotification");
    completionHandler(UIBackgroundFetchResultNewData);
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
