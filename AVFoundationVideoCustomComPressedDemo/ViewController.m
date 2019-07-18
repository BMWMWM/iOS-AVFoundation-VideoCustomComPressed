//
//  ViewController.m
//  AVFoundationVideoCustomComPressedDemo
//
//  Created by xhkj on 2019/7/17.
//  Copyright © 2019 MWM. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "VideoCompress.h"
#import <AVFoundation/AVFoundation.h>
#import <SVProgressHUD/SVProgressHUD.h>
@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}
- (IBAction)chooseVideoBtnClick:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        /*
         * 设置资源文件来源 图库 相机 相册
         * UIImagePickerControllerSourceTypePhotoLibrary,
         * UIImagePickerControllerSourceTypeCamera,
         * UIImagePickerControllerSourceTypeSavedPhotosAlbum
         **/
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        /*
         * 设置媒体类型
         * (NSString *)kUTTypeVideo 无声视频
         * (NSString *)kUTTypeMovie 有声视频
         * (NSString *)kUTTypeAudio 音频
         * 等...
         **/
        [self.imagePicker setMediaTypes:@[(NSString *)kUTTypeMovie]];
        self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
        
    }else{
        [self showAlertViewWithTitle:@"相机不可用" message:@"" withCancelButtonTitle:@"知道了"];
    }
}
- (IBAction)recordVideoBtnClick:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        /*
         * 设置资源文件来源 图库 相机 相册
         * UIImagePickerControllerSourceTypePhotoLibrary,
         * UIImagePickerControllerSourceTypeCamera,
         * UIImagePickerControllerSourceTypeSavedPhotosAlbum
         **/
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        /*
         * 设置媒体类型
         * (NSString *)kUTTypeVideo 无声视频
         * (NSString *)kUTTypeMovie 有声视频
         * (NSString *)kUTTypeAudio 音频
         * 等...
         **/
        [self.imagePicker setMediaTypes:@[(NSString *)kUTTypeMovie]];
        self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
        
    }else{
        [self showAlertViewWithTitle:@"相机不可用" message:@"" withCancelButtonTitle:@"知道了"];
    }
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    [self showAlertViewWithTitle:@"用户取消操作" message:@"" withCancelButtonTitle:@"好的"];

}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([type isEqualToString:@"public.movie"])
    {
        NSLog(@"===video URL = %@===", [info objectForKey:UIImagePickerControllerMediaURL]);
        //视频路径URL
        NSURL *outputUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:^{
            [self compressVideoWithVideoUrl:outputUrl];
        }];
    }
}
- (void)compressVideoWithVideoUrl:(NSURL *)outputUrl{
    [VideoCompress compressVideoWithVideoUrl:outputUrl withBiteRate:@(1500 * 1024) withFrameRate:@(30) withVideoWidth:@(960) withVideoHeight:@(540) compressComplete:^(id responseObjc) {
        NSString *filePathStr = [responseObjc objectForKey:@"urlStr"];
        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:filePathStr]];
        AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        //视频大小 MB
        unsigned long long fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:filePathStr error:nil].fileSize;
        float fileSizeMB = fileSize / (1024.0*1024.0);
        //视频宽高
        NSInteger videoWidth = videoTrack.naturalSize.width;
        NSInteger videoHeight = videoTrack.naturalSize.height;
        //比特率
        NSInteger kbps = videoTrack.estimatedDataRate / 1024;
        //帧率
        NSInteger frameRate = [videoTrack nominalFrameRate];
        NSLog(@"\nfileSize after compress = %.2f MB,\n videoWidth = %ld,\n videoHeight = %ld,\n video bitRate = %ld\n, video frameRate = %ld", fileSizeMB, videoWidth, videoHeight, kbps, frameRate);
//        NSData *videoData = [NSData dataWithContentsOfFile:filePathStr];
        //                    NSData *videoData = [NSData dataWithContentsOfURL:asset.URL];
        //在这里上传或者保存已经处理好的视频文件
        //保存视频至相册
        UISaveVideoAtPathToSavedPhotosAlbum(filePathStr, self, @selector(videoSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    }];
}
#pragma mark 保存视频后的回调
- (void)videoSavedToPhotosAlbum:(NSString *)videoUrlStr didFinishSavingWithError:(NSError*)error contextInfo:(id)contextInfo{
    NSString*message =@"提示";
    if(!error) {
        message = @"视频成功保存到相册";
    }else{
        message = [error description];
    }
    [self showAlertViewWithTitle:@"提示" message:message withCancelButtonTitle:@"确定"];
}
- (void)showAlertViewWithTitle:(NSString*)title message:(NSString*)msg withCancelButtonTitle:(NSString *)cancelButtonTitle{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
