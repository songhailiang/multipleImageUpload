# multipleImageUpload
多图异步上传demo，使用dispatch_group_t实现当所有图片都上传完成时再执行下一步功能，亦可用在实现当若干个AFN异步请求都成功后再执行下一步功能

# 使用场景
我们知道使用AFNetworking进行网络请求，都是异步的，有时候我们需要等若干个无序的（2个或者更多个）异步请求都成功后再执行某些代码（比如demo里实现的多图上传功能），当遇到这种需求的时候，最简单的做法，或者说我们一般会采用的做法是，将一个异步请求嵌套在另一个异步请求中，就是在第一个请求成功返回后再调用第2个异步请求，这种做法其实是不太好的，既浪费了时间（因为完全可以多个异步请求同时发出），而且写出来的代码还很脏（2个异步请求还好，如果再多，呵呵，那画面自己想）。

# 如何使用dispatch group来实现上述场景中的需求

1.创建dispatch_group_t
```objc
dispatch_group_t group = dispatch_group_create();
```
2.使用dispatch_group_enter进入group，表示任务开始
```objc
dispatch_group_enter(group);
```
3.使用dispatch_group_leave退出group，表示任务完成
```objc
dispatch_group_leave(group);
```
4.使用dispatch_group_notify注册group里所有任务完成后的回调block
```objc
dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        [self doSomethingWhenAllImageUploadSuccess];
});
```

注：与dispatch_group_notify对应的还有一个叫dispatch_group_wait的东西，这2者的区别是：

dispatch_group_notify：是异步的，不阻塞当前线程
dispatch_group_wait：会阻塞当前线程，直到dispatch group中所有任务都完成才返回

完整的调用代码：
```objc
dispatch_group_t group = dispatch_group_create();
    
    [self.uploadImageArray enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
        
        dispatch_group_enter(group);
        [[AFFileClient sharedClient] upload:@"app/upload_file/imageList"
                                 parameters:nil
                                      files:@{@"upload":UIImageJPEGRepresentation(image, 0.8)}
                                   complete:^(ResponseData *response) {
            
                                       if (response.success) {
                                           NSLog(@"第%@张图片上传完成...",@(idx));
                                           
                                           dispatch_group_leave(group);
                                       }
                                       else {
                                           NSLog(@"第%@张图片上传失败：%@",@(idx),response.message);
                                       }
        }];
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        [self doSomethingWhenAllImageUploadSuccess];
    });
```

# 执行效果（异步回调顺序）
<img src='https://github.com/songhailiang/multipleImageUpload/blob/master/screenshot/screenshot2.png' width=400 />
