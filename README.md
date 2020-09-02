# UserNotification

## 概述

- **本地推送**通过 App 本地定制，加入到系统的 Schedule 里，然后在指定的条件达成时推送的本机的 App 上。

![image](https://github.com/stone-4827321/UserNotification/blob/master/Images/%E6%8E%A8%E9%80%81%E6%A1%86%E6%9E%B6_UI.png)

- **远程推送**通过服务端向苹果推送服务器 Apple Push Notification Service (APNs) 发送 Notification Payload，APNs 再将推送下发到指定设备的指定 App 上。
  - 设备联网时（无论是蜂窝联网还是Wi-Fi联网）都会与 APNs 服务器建立一个长连接（persistent IP connection）；
  - 当应用服务器推送一条通知的时候，这条通知并不是直接推送给设备，而是先推送到 APNs 服务器， APNs 服务器再通过与设备建立的长连接把通知推送到设备上；
  - 远程推送必须要求设备连网状态下才能收到。而当设备处于非联网状态的时候，APNs 服务器会保留应用服务器所推送的最后一条通知，当设备转换为连网状态时，APNs 则把其保留的最后一条通知推送给设备。如果设备长时间处于非联网状态下，APNs 服务器为其保存的最后一条通知则会丢失。

![image](https://github.com/stone-4827321/UserNotification/blob/master/Images/%E6%8E%A8%E9%80%81%E6%A1%86%E6%9E%B6_%E6%9C%AC%E5%9C%B0%E6%8E%A8%E9%80%81.png)

### 推送优化

在 iOS 10 系统中，通知被整合进了 `UserNotification` 框架，相比之前的通知功能更加强大，主要表现在如下几点：
1.  通知回调的代码可以从 `AppDelegate` 中剥离。
2.  **支持向通知内容中添加媒体附件，例如音频，视频。**
3.  **支持自定义的通知界面。**
4.  **支持修改远程通知的内容。**
5.  支持与通知界面进行交互。
6.  支持通知分组。

## 管理和权限

- **`UNUserNotificationCenter`**  推送的管理中心。

  - 通知的注册，设置通知的提醒模式；
  - 通知的管理，增加和移除本地推送；
  - 设置通知回调的代理。

- 示例：请求通知授权

  ```objective-c
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  // 通知的模式
  UNAuthorizationOptions options = UNAuthorizationOptionBadge | 
                                   UNAuthorizationOptionSound | 
                                   UNAuthorizationOptionAlert;
  [center requestAuthorizationWithOptions:options
                        completionHandler:^(BOOL granted, NSError *error) {
      // 判断是否取得授权
      if (granted) {
      }
  }];
  // 设置通知回调的代理
  center.delegate = self;
  ```

  > 一旦用户拒绝了授权，再次调用该方法不会再进行弹窗请求授权。

- **`UNNotificationSettings`** 查看通知的权限

  - 权限：授权、未授权、未设置、临时通知（不会给用户授权的弹窗而直接尝试给用户推送，推送的消息只会以隐式推送的方式展示给用户）；

    ![image](https://github.com/stone-4827321/UserNotification/blob/master/Images/%E6%8E%A8%E9%80%81%E6%A1%86%E6%9E%B6_%E4%B8%B4%E6%97%B6%E6%8E%A8%E9%80%81.png)

  - 是否支持、允许或禁止：红点、声音、弹窗等通知送达样式，车载模式时仍推送，勿扰模式时收到重要通知可以声音提示，锁屏后仍显示，Siri 通过 AirPods 自动读出信息；

  - 通知预览是否显示：始终、解锁时、从不；

  - 系统的通知设置里是否显示一个"xxx通知设置"的按钮，点击后可进入应用（可设置直接进入到应用内部通知设置的页面）。

    ![image](https://github.com/stone-4827321/UserNotification/blob/master/Images/%E6%8E%A8%E9%80%81%E6%A1%86%E6%9E%B6_%E9%80%9A%E7%9F%A5%E8%AE%BE%E7%BD%AE.png)

- 注册远程推送

  ```objective-c
  [[UIApplication sharedApplication] registerForRemoteNotifications];
  ```

## 内容和投递

- **`UNNotificationRequest`** 通知请求。

  - 封装通知内容 `UNNotificationContent` 和触发器 `UNNotificationTrigger`，并投递到通知中心。

- **`UNNotificationContent`** 通知内容。

  - 封装通知的标题，内容，红点数等；
  - 通知分组的标识和分组的提示（结合 `UNNotificationCategory`）；

  ![image](https://github.com/stone-4827321/UserNotification/blob/master/Images/%E6%8E%A8%E9%80%81%E6%A1%86%E6%9E%B6_%E5%88%86%E7%BB%84.png)

  - 从通知启动应用时显示的图片；
  - 设置通知的声效 `UNNotificationSound`；
  - 为通知添加附件 `UNNotificationAttachment`；

- **`UNNotificationAttachment`** 多媒体附件

  - 通知附件：通知中可携带音频（最大5MB）、视频（最大50MB）、图片（最大10MB）等附件。
  - 本地附件可以从 bundle 路径中读取；如果是网络附件，需要从网络下载后保存到本地，然后使用本地路径读取，当通知送达后本地路径保存的附件会自动清除。

  - 附件初始化时的 `options` 配置字典中可以进行的配置包括：
    - `UNNotificationAttachmentOptionsTypeHintKey`：配置附件的类型，如果不设置则默认从扩展名中推断，`NSString` 类型，使用方法为 `(__bridge id _Nullable)kUTTypeImage;`），需要导入 `MobileCoreServices` 框架；
    - `UNNotificationAttachmentOptionsThumbnailHiddenKey`：配置是否隐藏缩略图，`NSNumber(Boolean)` 类型，默认为 NO；
    - `UNNotificationAttachmentOptionsThumbnailClippingRectKey`：配置使用一个标准的矩形来对图片进行裁剪以作为缩略图，`CGRect` 比例单位类型，使用方法为`(__bridge id _Nullable)CGRectCreateDictionaryRepresentation(CGRectMake(0.5, 0.5, 0.25 ,0.25));`；
    - `UNNotificationAttachmentOptionsThumbnailTimeKey`：配置使用动态图或视频中的某一帧作为缩略图，`NSNumber` 类型。

  - 通知内容的 `attachments` 属性虽然是一个数组，但是系统只会展示第一个附件的内容。可以发送多个附件，然后在要展示的时候再重新安排它们的顺序，以显示最符合情景的附件。自定义通知展示 UI 时可以用到多个附件。

- **`UNNotificationTrigger`** 通知触发器

  - 操作其子类来描述通知触发的条件，其子类包括： 

    - `UNTimeIntervalNotificationTrigger`：一定时间后触发的本地通知；

      > 如果该类型通知需要重复触发，间隔时间必须大于60s。

    - `UNCalendarNotificationTrigger`：到某个时间点触发的本地通知；

    - `UNLocationNotificationTrigger`：进入或离开某个地点时触发的本地通知；

    - `UNPushNotificationTrigger`：只能从系统获取的远程通知。

- 示例：投递本地通知

  ```objective-c
  UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
  content.body = @"body";
  content.title = @"title";
  content.subtitle = @"subtitle";
  content.userInfo = @{@"key" : @"value"};
  
  content.badge = @(1);
      
  content.launchImageName = @"1.png";
      
  // 声效
  content.sound = [UNNotificationSound defaultSound];
      
  // 分组标识
  content.threadIdentifier = threadIdentifier;
      
  // 分组时显示：summaryArgumentCount new messages from summaryArgument
  content.summaryArgument = @"my app";
  content.summaryArgumentCount = 1;
  UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"category" actions:@[] intentIdentifiers:@[] hiddenPreviewsBodyPlaceholder:@"%u stone" categorySummaryFormat:@"%u new messages from %@" options:UNNotificationCategoryOptionCustomDismissAction];
  // 必须设置可以显示的category集合
  [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObject:category]];
  // 必须设置且与category的标志一致
  content.categoryIdentifier = @"category";
  
  NSURL *attachmentURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"]];
  UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"attachment" URL:attachmentURL options:nil error:nil];
  content.attachments = @[attachment];
  
  // 触发器
  UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
      
  // 请求
  UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:dateString content:content trigger:trigger];
  // 投递请求    
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  [center addNotificationRequest:request withCompletionHandler:^(NSError *error) {
      NSLog(@"创建本地通知成功");
  }];
  ```


## 交互式操作

- **`UNNotificationCategory`** 当通知下拉时，增加交互操作功能。

- **`UNNotificationAction`** 交互按钮。
  - 系统模板最多支持添加4个用户交互按钮。

- **`UNTextInputNotificationAction`** 交互输入框。
  - 属于 `UNNotificationAction` 的子类。


- 示例：快捷交互

  ```objective-c
  // 交互按钮
  UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"action1" title:@"按钮" options:UNNotificationActionOptionNone];
  // 交互输入框
  UNTextInputNotificationAction *action2 = [UNTextInputNotificationAction actionWithIdentifier:@"action2" title:@"回复" options:UNNotificationActionOptionNone textInputButtonTitle:@"发送" textInputPlaceholder:@"默认回复语句"];
      
  UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"category" actions:@[action1, action2] intentIdentifiers:@[] hiddenPreviewsBodyPlaceholder:nil categorySummaryFormat:nil options:UNNotificationCategoryOptionCustomDismissAction];
  // 必须设置可以显示的category集合
  [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObject:category]];
      
  // 必须设置且与category的标志一致
  content.categoryIdentifier = @"category";
  ```

![image](https://github.com/stone-4827321/UserNotification/blob/master/Images/%E6%8E%A8%E9%80%81%E6%A1%86%E6%9E%B6_%E5%A4%9A%E5%AA%92%E4%BD%93%26%E4%BA%A4%E4%BA%92.png)

## 回调

- **`UNUserNotificationCenterDelegate`** 

  - 应用在前台时收到通知。
    - 在方法实现中需调用 `completionHandler`，配置前台收到通知的显示形式，包括红点、声音和弹框三种显示方法。

  ```objective-c
  - (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
      completionHandler(UNNotificationPresentationOptionAlert);
  }
  ```

  - 应用在前台、后台状态或未启动时点击通知。
    - 在方法实现中需调用 `completionHandler` 方法。

  ```objective-c
  - (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response
           withCompletionHandler:(void(^)(void))completionHandler {
      NSLog(@"后台、前台或杀死状态时点击通知");
      
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
          else if([response.actionIdentifier isEqualToString:@"xxx"]) {
              NSLog(@"点击自定义按钮xxx");
          }
      }
      completionHandler();
  }
  ```

  - 应用在前台或后台状态时，点击系统的通知设置里"xxx通知设置"的按钮进入应用。

  ```objective-c
  - (void)userNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(nullable UNNotification *)notification {
  }
  ```

- 兼容 `UIApplicationDelegate` 回调。

  - 获取远程推送的token（该回调方法无对应新版本，即未被废弃）。

  ```objective-c
  - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
      if (@available(iOS 13.0, *)) {
          const unsigned *tokenBytes = (const unsigned *)[deviceToken bytes];
          NSString *token = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x", ntohl(tokenBytes[0]),ntohl(tokenBytes[1]),ntohl(tokenBytes[2]),ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
          NSLog(@"deviceToken:%@", token);
      }
      else {
          NSString *token = [NSString stringWithFormat:@"%@",deviceToken];
          token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
          token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
          token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
          NSLog(@"deviceToken: %@", token);
      }
  }
  
  - (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
      NSLog(@"注册远程推送失败：%@", error);
  }
  ```

  - 本地通知到达，或点击通知进入应用。
    - 当应用在前台时，本地通知到达，会收到一次回调；
    - 当应用在后台时，本地通知到达后点击通知，会收到一次回调；
    - 当应用未启动时，本地通知到达后点击通知，会收到一次回调。

  ```objective-c
  // 低于iOS10版本
  - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;
  ```

  - 远程通知到达，或点击通知进入应用。

    - 当应用在前台时，远程通知到达，会收到一次回调；
    - 当应用在后台时，远程通知到达后点击通知，会收到一次回调；
    - 当应用未启动时，远程通知到达后点击通知，会收到一次回调；
    - 当应用在后台状态，且通知的aps中标记 `content-available: 1`，会在收到和点击通知时，各收到一次回调。
    - 若实现了新旧两种回调，则点击通知后收到的旧回调不再执行；
    - 当通知为静默推送时，则只会回调此方法（新回调不会收到）。

    > 静默推送的aps中只包含 content-available: 1，且只有应用处于前台或后台状态时才能收到回调。

  ```objective-c
  - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;
  
  // 低于iOS10版本，实现第一个方法后会屏蔽本方法，一般也无需实现此方法
  - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
  ```

  - 点击自定义交互按钮。

  ```objective-c
  // 本地通知，低于iOS9版本
  - (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)(void))completionHandler;
  
  // 本地通知，低于iOS10版本
  - (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)(void))completionHandler;
  
  // 远程通知，低于iOS9版本
  - (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)(void))completionHandler;
  
  // 远程通知，低于iOS10版本
  - (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)(void))completionHandler;
  ```

## Notification Content Extension

- 通知页面的构成：

  - **header** 是系统提供的一套标准的 UI，用于显示应用名；
  - **custom content** 是自定义的内容，就是 Notification Content Extension（通知内容扩展）；
  - **default content** 是系统的界面，主要用于显示通知的文本内容；
  - **notification action** 是用户交互操作按钮。

  ![image](https://github.com/stone-4827321/UserNotification/blob/master/Images/%E6%8E%A8%E9%80%81%E6%A1%86%E6%9E%B6_UI.png)

- 可以通过`Notification Content Extension` 来自定义以上视图的布局及增加自定义视图。

  - 新建 **Notification Content** 类型的 **Target**，该扩展中自带一个 storyboard 文件和一个 `NotificationViewController`  类，以及一个 info.plist 文件。
  - 配置使用 `NotificationViewController` （对应 NSExtensionPrincipalClass）或 storyboard 文件（对应 NSExtensionMainStoryboard）进行视图的显示载体。

  ![image](https://github.com/stone-4827321/UserNotification/blob/master/Images/%E6%8E%A8%E9%80%81%E6%A1%86%E6%9E%B6_%E8%87%AA%E5%AE%9A%E4%B9%89UI1.png)

  - 设置 category（对应 NSExtensionAttributes.UNNotificationExtensionCategory），使用本地通知时必须和本地通知设置的 category 属性 一致，使用远程通知时必须和 aps 中设置的 category 字段一致。可以设置多个 category 使得视图设计通用。

  ![image](https://github.com/stone-4827321/UserNotification/blob/master/Images/%E6%8E%A8%E9%80%81%E6%A1%86%E6%9E%B6_%E8%87%AA%E5%AE%9A%E4%B9%89UI2.png)

  > 如果以上设置正确但扩展不被执行，可尝试修改扩展的 Deployment Target 设置为 10.0。

  - 其他优化和修改：

    - 自定义界面的高度

    ```objective-c
    - (void)viewDidLoad {
        [super viewDidLoad];
        self.preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.frame), 50);
    }
    ```
    - 在上一步设置后发现视图的尺寸会有一个变化的过程：先展示成默认的大小且内容空白，之后才变成设置的大小——需要提前告诉系统自定义界面的大小，至少是估计的大小。

      设置自定义通知界面的高度与宽度（设备屏幕宽度）的比（对应 NSExtensionAttributes.UNNotificationExtensionInitialContentSizeRatio），系统根据这个比值来计算通知界面的高度。 

    ![image](https://github.com/stone-4827321/UserNotification/blob/master/Images/%E6%8E%A8%E9%80%81%E6%A1%86%E6%9E%B6_%E8%87%AA%E5%AE%9A%E4%B9%89UI3.png)
    
    - 隐藏系统默认的 default content 视图（对应 NSExtensionAttributes.UNNotificationExtensionDefaultContentHidden 设置为 YES）。

    - iOS12 系统及以上，点击通知后不再响应主应用的方法且不再进入主应用（对应 NSExtensionAttributes.UNNotificationExtensionUserInteractionEnabled 设置为 YES）。

  - 可选方法实现：

    - 响应交互式操作；
    - 动态修改 actions（新增，删除，替换等），需设置为点击后不消失。

    ```objective-c
    // 用户点击了通知时会被调用
    - (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption option))completion {
        NSLog(@"点击通知时调用 %@", response.actionIdentifier);
        
        // 点击后不消失，且不会传递给宿主APP（不会收到对应的通知回调）
        //completion(UNNotificationContentExtensionResponseOptionDoNotDismiss);
        // 点击后消失，且不会传递给宿主 APP
        //completion(UNNotificationContentExtensionResponseOptionDismiss);
        // 点击后消失，且传递给宿主 APP
        completion(UNNotificationContentExtensionResponseOptionDismissAndForwardAction);
        
        // 替换按钮
        //UNNotificationAction *action = [UNNotificationAction actionWithIdentifier:@"action3" title:@"按钮3" options:UNNotificationActionOptionAuthenticationRequired];
        //self.extensionContext.notificationActions = @[action];
        //completion(UNNotificationContentExtensionResponseOptionDoNotDismiss);
    }
    ```

    - 添加音视频播放的按钮。

  - iOS12 系统及以上允许用户与 custom content 中的视图进行交互。

    - 设置点击通知后不再进入主应用（对应 NSExtensionAttributes.UNNotificationExtensionUserInteractionEnabled 设置为 YES）。设置后也不会响应相关回调方法。

    - 添加自定义视图，如按钮及其回调事件
    - 在回调事件中可以执行以下方法：

    ```objective-c
    // 关闭通知页面
    [self.extensionContext dismissNotificationContentExtension];
    
    // 进入应用
    [self.extensionContext dismissNotificationContentExtension];
    ```


## Notification Service Extension

  - 在远程推送将要被显示出来前，提供修改显示内容的机会，最终给用户呈现一个更为丰富的通知。
    - 对通知进行内容添加，如添加附件，userInfo 等；
    - 在推送文本中使用密文，客户端收到推送通知后进行解码，保证了推送传输中的内容安全性。
  - 只支持远程推送，且必须是使用 alert 的提醒方式。
  - 有30秒的时间处理这个通知，可用于下载附件。
  - 推送文本 aps 中增加字段 **mutable-content**，其值为 1。

```objective-c
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
            //NSURL *url = [NSURL fileURLWithPath:[bundle pathForResource:@"2" ofType:@"png"]];
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

// 如果在指定的时间内（30s），contentHandler()代码块都没能被调用的话，系统会调用此方法
- (void)serviceExtensionTimeWillExpire {
    self.contentHandler(self.bestAttemptContent);
}
```
