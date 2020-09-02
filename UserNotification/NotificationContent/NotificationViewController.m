//
//  NotificationViewController.m
//  NotificationContent
//
//  Created by stone on 2020/9/2.
//  Copyright © 2020 3kMac. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@property IBOutlet UILabel *label;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"NotificationViewController viewDidLoad");
    
    self.preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.frame), 50);
    // Do any required interface initialization here.
}

- (void)didReceiveNotification:(UNNotification *)notification {
    UNNotificationContent *content = notification.request.content;

    self.label.text = notification.request.content.body;
    
    CGRect rect = self.view.bounds;
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = content.title;
    label.backgroundColor = [UIColor yellowColor];
    self.label = label;
    [self.view addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor redColor];
    rect.size.width /= 2.0;
    button.frame = rect;
    [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

// 用户点击了通知时会被调用
- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption option))completion {
    NSLog(@"点击通知时调用 %@", response.actionIdentifier);
    if ([response isKindOfClass:[UNTextInputNotificationResponse class]]) {
        UNTextInputNotificationResponse *textResponse = (UNTextInputNotificationResponse *)response;
        NSLog(@"点击通知时调用输入框: %@",textResponse.userText);
    }
    else {
        NSLog(@"点击通知时调用动作: %@",response.actionIdentifier);
    }
    
    
    // 点击后不消失，且不会传递给宿主APP（不会收到对应的通知回调）
    //completion(UNNotificationContentExtensionResponseOptionDoNotDismiss);
    // 点击后消失，且不会传递给宿主 APP
    //completion(UNNotificationContentExtensionResponseOptionDismiss);
    // 点击后消失，且传递给宿主 APP
    completion(UNNotificationContentExtensionResponseOptionDoNotDismiss);
    
//    UNNotificationAction *action = [UNNotificationAction actionWithIdentifier:@"action3" title:@"按钮3" options:UNNotificationActionOptionAuthenticationRequired];
//    self.extensionContext.notificationActions = @[action];
//    completion(UNNotificationContentExtensionResponseOptionDoNotDismiss);
}

- (void)click:(id)sender {
    self.label.text = @"click button";
    if (@available(iOS 12.0, *)) {
        // 进入主应用
        //[self.extensionContext performNotificationDefaultAction];
        // 关闭通知页面
        [self.extensionContext dismissNotificationContentExtension];
    }
}

@end

