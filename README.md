# NabuManager
NabuManager is a very useful class that makes the communication with both Nabu and Nabu X so easy and simple, but yet so powerful

[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/razer-dev/NabuManager/blob/master/LICENSE)

<br></br>
## Features

**NabuManager** is:

  * simple and elegant to use
  * very powerful, giving access to all features with just one or two lines of code
  * well documentated
  * designed as a singleton, being very easy to use just out of the box

## How to implement NabuManager in your app

1. Register your app in the Dev Hub from http://developer.razerzone.com/nabu/ It will have to be approved to get an App Id
2. Follow the steps listed here: http://developer.razerzone.com/nabu/guides/develop-ios/ to set up your Xcode project
3. Create an URL scheme callback in the "URL Types" section from your Info.plist (this is the way your app communicates with the Nabu Utility)
4. Import NabuManager.h in AppDelegate.h or in the bridging header (if you are using Swift). After that, just copy and paste the following code in the AppDelegate file (this way you handle the way your app opens URLs)

 **Objective-C**
  ```objective-c
  - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
      [[NabuDataManager sharedDataManager] validateURLResponse: url withBlock: nil];

      return true;
  }
  ```
  **Swift**
  ```swift
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
      NabuDataManager.sharedDataManager().validateURLResponse(url, withBlock: nil)
        
      return true
  }
  ```

5. You now have all the Nabu's features at your fingertips with just one class. NabuManager is a singleton, only one instance lives at a time, so you can access it's public methods this way:

 **Objective-C**
  ```objective-c
  [[NabuManager sharedNabuManager] method1];
  [[NabuManager sharedNabuManager] method2: 3]; // For a method that takes one argument

  [NabuManager sharedNabuManager].property1;
  ```
  **Swift**
  ```swift
  NabuManager.sharedNabuManager().method1();
  NabuManager.sharedNabuManager().method2(3); // For a method that takes one argument

  NabuManager.sharedNabuManager().property1;
  ```

6. For every method's description please check it's documentation by pressing the Alt key and clicking on that method, or just checking the header. You can also take advantage of the documentation website.

  **Warning: Some methods could take more time to be executed due to the interaction with the Nabu Utility, that's why it is recommended to call the methods asynchronously, like this:**

 **Objective-C**
  ```objective-c
  dispatch_queue_t backgroundOperationQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
  dispatch_async(operationQueue, ^{
      [[NabuManager sharedNabuManager] sendNotificationWithMessage: @"Some notification text" andIconResId: @"The id of your icon resource"];
  });
  ```
  **Swift**
  ```swift
  let backgroundOperationQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
  dispatch_async(operationQueue, {
      NabuManager.sharedNabuManager().sendNotificationWithMessage("Some notification text", andIconResId: "The id of your icon resource")
  })
  ```
