//
//  SimpleBarCodeScanner.m
//  SimpleBarCodeScannerExample
//
//  Created by . Carlin on 12/21/13.
//  Copyright (c) 2013 Carlin Creations. All rights reserved.
//

#import "SimpleBarCodeScanner.h"

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#import "ZBarSDK.h"

@interface SimpleBarCodeScanner() <
    AVCaptureMetadataOutputObjectsDelegate
>
    
    /** View to display scanning in */
    @property (nonatomic, strong) UIView *view;
    @property (nonatomic, strong) UIView *highlightView; 

    // iOS 7 Scanning with AVCapture
    @property (nonatomic, strong) AVCaptureSession *session;
    @property (nonatomic, strong) AVCaptureDevice *device;
    @property (nonatomic, strong) AVCaptureDeviceInput *input; 
    @property (nonatomic, strong) AVCaptureMetadataOutput *output;  
    @property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;   
    
    // ZBarSDK Scanning

@end

@implementation SimpleBarCodeScanner


/** Initialize scanner with view to be used for displaying the scanning */
- (id)initWithView:(UIView *)view delegate:(id<SimpleBarCodeScannerDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        _lastCode = nil;
        _codeTypes = @[
            AVMetadataObjectTypeAztecCode, 
            AVMetadataObjectTypeCode128Code, 
            AVMetadataObjectTypeCode39Code, 
            AVMetadataObjectTypeCode39Mod43Code,
            AVMetadataObjectTypeCode93Code, 
            AVMetadataObjectTypeEAN13Code, 
            AVMetadataObjectTypeEAN8Code,  
            AVMetadataObjectTypePDF417Code, 
            AVMetadataObjectTypeQRCode, 
            AVMetadataObjectTypeUPCECode,   
        ];
    
        _view = view;
        _delegate = delegate;
        
        // Highlight View
        _highlightView = [UIView new];
        _highlightView.backgroundColor = [UIColor clearColor];
        _highlightView.layer.borderColor = [[UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.8] CGColor];
        _highlightView.layer.borderWidth = 4.0; 
        _highlightColor = nil;
        _highlightWidth = 0;
        
        // AVCapture Setup
        _session = [[AVCaptureSession alloc] init];
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        NSError *error = nil;
        _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
        if (_input) {
            [_session addInput:_input];
        } else {
            NSLog(@"Error Initializing Bar Code Scanner: %@", error);
        }

        _output = [[AVCaptureMetadataOutput alloc] init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [_session addOutput:_output];

        _output.metadataObjectTypes = [_output availableMetadataObjectTypes];

        // Capture preview
        _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        _preview.frame = _view.bounds;
        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [_view.layer addSublayer:_preview];
    }
    return self;
}

- (void)dealloc
{
    [_session stopRunning];
    _session = nil;
    _input = nil;
    _output = nil;
    [_preview removeFromSuperlayer];
    _preview = nil;
    [_highlightView removeFromSuperview];
    _highlightView = nil;
}

/** Start capture session */
- (void)start
{
    [self.session startRunning];
}

/** Stop capture session */
- (void)stop
{
    [self.session stopRunning];
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    bool foundCode = false;

    for (AVMetadataObject *metadata in metadataObjects) {
        if ([self.codeTypes containsObject:metadata.type])
        {
            barCodeObject = (AVMetadataMachineReadableCodeObject *)
                [self.preview transformedMetadataObjectForMetadataObject:
                    (AVMetadataMachineReadableCodeObject *)metadata];
            
            highlightViewRect = barCodeObject.bounds;
            detectionString = 
                [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                
            if (detectionString != nil) {
                foundCode = ![detectionString isEqualToString:self.lastCode];
                break;
            }
        }
    }

    // Update color / width of highlight if changed
    if (self.highlightWidth > 0) {
        self.highlightView.layer.borderWidth = self.highlightWidth;
    }
    if (self.highlightColor) {
        self.highlightView.layer.borderColor = [self.highlightColor CGColor];
    }
       
    // Show highlightview
    [self.view addSubview:self.highlightView]; 
    [UIView animateWithDuration:0.1 delay:0 
        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut 
        animations:^{
            self.highlightView.frame = highlightViewRect; 
            self.highlightView.alpha = (detectionString) ? 1 : 0;
        } 
        completion:^(BOOL finished) {
            if (foundCode) 
            {
                self.lastCode = detectionString; // Update last code scanned   
                if (self.delegate) {
                    [self.delegate scanner:self scannedCode:self.lastCode];
                }
            } 
        }];
}

@end
