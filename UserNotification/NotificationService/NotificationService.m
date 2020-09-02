//
//  NotificationService.m
//  notificationExtension
//
//  Created by stone on 2018/9/19.
//  Copyright © 2018年 duoyi. All rights reserved.
//

#import "NotificationService.h"
#import <UIKit/UIKit.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    //推送文本为
    /*
    {
        "aps" : {
            "alert" : {
                "body" : "body",
                "subtitle" : "subtitle",
                "title" : "title"
            },
            "badge" : 1,
            "image" : "https://upload-images.jianshu.io/upload_images/2317908-982261619c1775d9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240",
            "mutable-content" : 1,
            "sound" : "default"
        }
    }
    */
    
//    UNNotificationAction *action = [UNNotificationAction actionWithIdentifier:@"action" title:@"按钮" options:UNNotificationActionOptionAuthenticationRequired];
//    UNNotificationCategory *category;
//    if (@available(iOS 12.0, *)) {
//         category = [UNNotificationCategory categoryWithIdentifier:@"category" actions:@[action] intentIdentifiers:@[] hiddenPreviewsBodyPlaceholder:@"stone" categorySummaryFormat:@"%u new messages from %@" options:UNNotificationCategoryOptionCustomDismissAction];
//    } else {
//        category = [UNNotificationCategory categoryWithIdentifier:@"category" actions:@[action] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
//    }
//    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObject:category]];
//    // 必须设置且与category的标志一致
//    self.bestAttemptContent.categoryIdentifier = @"category";
    
    NSDictionary *dict = self.bestAttemptContent.userInfo;
    dict = dict[@"aps"];
    
    //由于推送文本可能同时包含movie、audio、image字段，此时应该建立一套优先顺序，如优先判断是否有movie，否则判断是否有audio，最后则是image
    if (dict[@"movie"]) {
        //...
    }
    else if (dict[@"audio"]) {
        //...
    }
    else if (dict[@"image"]) {
        NSString *image = dict[@"image"];
        //本地附件
        if (![image hasPrefix:@"http"]) {
            NSBundle *bundle = [NSBundle mainBundle];
            NSURL *url = [NSURL fileURLWithPath:[bundle pathForResource:image.stringByDeletingPathExtension ofType:image.pathExtension]];
            //    NSURL *url = [NSURL fileURLWithPath:[bundle pathForResource:@"2" ofType:@"png"]];
            UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"attachment"
                                                                                                  URL:url
                                                                                              options:nil
                                                                                                error:nil];
            if(attachment) {
                self.bestAttemptContent.attachments = @[attachment];
            }
            self.contentHandler(self.bestAttemptContent);
        }
        //网络附件
        else {
            NSURL *url = [NSURL URLWithString:image];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            if (!request) {
                self.contentHandler(self.bestAttemptContent);
                return;
            }
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                if (!error) {
                    NSString *fileName = image.pathExtension;
                    if (fileName.length) {
                        fileName = [NSString stringWithFormat:@"%f.%@", [[NSDate date] timeIntervalSince1970], fileName];
                    }
                    if (!fileName.length) {
                        fileName = response.suggestedFilename;
                    }
                    if (!fileName.length) {
                        NSString *extension = [[response.MIMEType componentsSeparatedByString:@"/"] lastObject];
                        if (extension) {
                            fileName = [NSString stringWithFormat:@"%f.%@", [[NSDate date] timeIntervalSince1970], extension];
                        }
                    }
                    if (fileName.length) {
                        NSString *fullPath = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/%@", fileName];
                        NSFileManager *manager = [NSFileManager defaultManager];
                        if ([manager fileExistsAtPath:fullPath]) {
                            [manager removeItemAtPath:fullPath error:nil];
                        }
                        NSURL *fullUrl = [NSURL fileURLWithPath:fullPath];
                        if ([manager moveItemAtURL:location toURL:fullUrl error:nil]) {
                            UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"attachment"
                                                                                                                  URL:fullUrl
                                                                                                              options:nil
                                                                                                                error:nil];
                            if (attachment) {
                                self.bestAttemptContent.attachments = @[attachment];
                            }
                        }
                    }
                }
                self.contentHandler(self.bestAttemptContent);
            }];
            [task resume];
        }
    }
    else {
        self.contentHandler(self.bestAttemptContent);
    }
}

- (void)serviceExtensionTimeWillExpire {
    self.contentHandler(self.bestAttemptContent);
}

@end

