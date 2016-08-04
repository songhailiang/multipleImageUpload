//
//  ViewController.m
//  afn_group_notify
//
//  Created by 宋海梁 on 16/8/1.
//  Copyright © 2016年 宋海梁. All rights reserved.
//

#import "ViewController.h"
#import <QBImagePickerController.h>
#import "AFFileClient.h"

#define Max_Image_Width     960         //照片最大宽度：竖拍时按宽度比压缩高度
#define Max_Image_Height    1280         //照片最大高度：横拍时按高度比压缩宽度

@interface ViewController ()<QBImagePickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray *uploadImageArray;

- (IBAction)pickImageButtonTouched:(id)sender;
- (IBAction)uploadButtonTouched:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {

    NSLog(@"dealloc --- %@",NSStringFromClass([self class]));
}

#pragma mark - Button Action

- (IBAction)pickImageButtonTouched:(id)sender {
    
    QBImagePickerController *photoPicker = [[QBImagePickerController alloc]init];
    photoPicker.mediaType = QBImagePickerMediaTypeImage;
    photoPicker.assetCollectionSubtypes = @[
                                            @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                            @(PHAssetCollectionSubtypeSmartAlbumFavorites),
                                            @(PHAssetCollectionSubtypeSmartAlbumPanoramas),
                                            @(PHAssetCollectionSubtypeSmartAlbumBursts),
                                            @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded)
                                            ];
    photoPicker.allowsMultipleSelection = YES;
    photoPicker.maximumNumberOfSelection = 9;
    photoPicker.prompt = @"请选择需要上传的图片";
    photoPicker.showsNumberOfSelectedAssets = YES;
    photoPicker.delegate = self;
    
    [self presentViewController:photoPicker animated:YES completion:nil];
}

- (IBAction)uploadButtonTouched:(id)sender {
    if (!self.uploadImageArray.count) {
        [self alert:@"请先选择图片"];
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    __block BOOL error = NO;
    
    [self.uploadImageArray enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
        
        dispatch_group_enter(group);
        [[AFFileClient sharedClient] upload:@"app/upload_file/imageList"
                                 parameters:nil
                                      files:@{@"upload":UIImageJPEGRepresentation(image, 0.8)}
                                   complete:^(ResponseData *response) {
                                       dispatch_group_leave(group);
                                       if (response.success) {
                                           NSLog(@"第%@张图片上传完成...",@(idx));
                                       }
                                       else {
                                           error = YES;
                                           NSLog(@"第%@张图片上传失败：%@",@(idx),response.message);
                                       }
        }];
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self doSomethingWhenAllImageUpload:error];
    });
}

- (void)doSomethingWhenAllImageUpload:(BOOL)error {

    NSLog(@"图片全部上传完成");
    if (error) {
        [self alert:@"图片上传失败！"];
    }
    else {
        [self alert:@"图片上传成功！"];
    }
}

#pragma mark - QBImagePickerController

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {

    if (!self.uploadImageArray) {
        self.uploadImageArray = [NSMutableArray array];
    }
    else {
        [self.uploadImageArray removeAllObjects];
    }
    
    CGSize targetSize = CGSizeMake(Max_Image_Width, Max_Image_Height);
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.synchronous = YES;
    
    PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
    for (PHAsset *asset in assets) {
        // Do something with the asset
        [imageManager requestImageForAsset:asset
                                targetSize:targetSize
                               contentMode:PHImageContentModeAspectFill
                                   options:options
                             resultHandler:^(UIImage *result, NSDictionary *info) {
                                 // 得到一张 UIImage，展示到界面上
                                 NSNumber *isDegraded = info[PHImageResultIsDegradedKey];
                                 
                                 if (!isDegraded.boolValue) {
                                     
                                     result = [self fixImageOrientation:result];
                                     
                                     [self.uploadImageArray addObject:result];
                                 }
                             }];
    }
    
    
    [imagePickerController dismissViewControllerAnimated:YES completion:^{
        [self alert:[NSString stringWithFormat:@"选择了%@张图片",@(self.uploadImageArray.count)]];
    }];
}

- (UIImage *)fixImageOrientation:(UIImage *)image {
    if(image.imageOrientation != UIImageOrientationUp){
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

- (void)alert:(NSString *)msg {

    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertVc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alertVc animated:YES completion:nil];
}

@end
