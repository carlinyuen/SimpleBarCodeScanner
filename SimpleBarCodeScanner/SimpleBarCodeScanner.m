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

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


@interface SimpleBarCodeScanner() <
    AVCaptureMetadataOutputObjectsDelegate,
    ZBarReaderViewDelegate
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
    @property (nonatomic, strong) ZBarReaderView *readerView; 
    @property (nonatomic, strong) NSArray *defaultScannerTypes;

@end

@implementation SimpleBarCodeScanner


/** Initialize scanner with view to be used for displaying the scanning */
- (id)initWithView:(UIView *)view delegate:(id<SimpleBarCodeScannerDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        _view = view;
        _delegate = delegate;
         
        // Defaults
        _lastCode = nil;
        _highlightColor = nil;
        _highlightWidth = 0;  
        
        // Pre-iOS 7 support
        if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
        {
            _defaultScannerTypes = @[
                @(ZBAR_I25),
                @(ZBAR_QRCODE),
                @(ZBAR_EAN8),
                @(ZBAR_UPCE),
                @(ZBAR_ISBN10),
                @(ZBAR_UPCA),
                @(ZBAR_EAN13),
                @(ZBAR_ISBN13),
                @(ZBAR_DATABAR),
                @(ZBAR_DATABAR_EXP),
                @(ZBAR_CODE39),
                @(ZBAR_CODE128),
                @(ZBAR_CODE93),
            ];
            _codeTypes = [_defaultScannerTypes copy];
            
            ZBarImageScanner *scanner = [[ZBarImageScanner alloc] init];
            [self updateZBarScannerTypes];
            _readerView = [[ZBarReaderView alloc] initWithImageScanner:scanner];
            _readerView.readerDelegate = self;
            _readerView.frame = _view.bounds;
            [_view addSubview:_readerView];
        }
        else    // iOS 7
        {
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
        
            // Highlight View
            _highlightView = [UIView new];
            _highlightView.backgroundColor = [UIColor clearColor];
            _highlightView.layer.borderColor = [[UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.8] CGColor];
            _highlightView.layer.borderWidth = 4.0; 
            
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
    }
    return self;
}

- (void)dealloc
{
    if (_session) {
        [_session stopRunning];
    }
    _session = nil;
    
    _input = nil;
    _output = nil;
    
    if (_preview) {
        [_preview removeFromSuperlayer];
    }
    _preview = nil;
    
    if (_highlightView) {
        [_highlightView removeFromSuperview];
    }
    _highlightView = nil;
}


#pragma mark - Public Methods

/** Start capture session */
- (void)start
{
    if (self.readerView) {
        [self.readerView start]; 
    } else if (self.session) {
        [self.session startRunning];
    }
}

/** Stop capture session */
- (void)stop
{
    if (self.readerView) {
        [self.readerView stop]; 
    } else if (self.session) {
        [self.session stopRunning];
    }
}

/** Override setter for codeTypes to update ZBarScanner if needed */
- (void)setCodeTypes:(NSArray *)codeTypes
{
    _codeTypes = codeTypes;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) { // update zbar scanner
        [self updateZBarScannerTypes];
    }
}


#pragma mark - Private Methods

/** Update scanner types for ZBarScanner */
- (void)updateZBarScannerTypes
{
    if (self.readerView) {
        for (NSNumber *type in self.defaultScannerTypes) {
            [self.readerView.scanner setSymbology:[type integerValue] config:ZBAR_CFG_ENABLE to:[self.codeTypes containsObject:type]];
        }
    }
}


#pragma mark - ZBarReaderViewDelegate

- (void) readerView: (ZBarReaderView*) view
     didReadSymbols: (ZBarSymbolSet*) syms
          fromImage: (UIImage*) img
{

    NSString *detectionString = nil;
    for (ZBarSymbol *sym in syms)
	{
        detectionString = sym.data;
        
        // Only notify the delegate if wasn't scanned last time
        if (detectionString && ![detectionString isEqualToString:self.lastCode])
        {
            self.lastCode = detectionString;
        
            // Notify delegate
            if (self.delegate) {
                [self.delegate scanner:self scannedCode:sym.data];
            }
        }
        
        break;  // Break on first symbol found 
    }
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
        completion:^(BOOL finished) 
        {
            // Wait for animation to finish, and notify if new code
            if (finished && foundCode) 
            {
                bool isNewCode = ![self.lastCode isEqualToString:detectionString];
                if (isNewCode)
                {
                    // Update last code scanned   
                    self.lastCode = detectionString; 
                    
                    // Notify delegate
                    if (self.delegate) {
                        [self.delegate scanner:self scannedCode:self.lastCode];
                    }
                }
            } 
        }];
}

@end
