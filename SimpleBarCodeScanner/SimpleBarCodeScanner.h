//
//  SimpleBarCodeScanner.h
//  SimpleBarCodeScannerExample
//
//  Created by . Carlin on 12/21/13.
//  Copyright (c) 2013 Carlin Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZBarSDK.h"

@class SimpleBarCodeScanner;
@protocol SimpleBarCodeScannerDelegate <NSObject>

	@required
    /** Scanner will call this method when it scans a code, and it won't call this again if it scans the same code twice in a row. */
	- (void)scanner:(SimpleBarCodeScanner *)scanner scannedCode:(NSString *)code;

@end

@interface SimpleBarCodeScanner : NSObject

    /** Delegate */
    @property (nonatomic, weak) id<SimpleBarCodeScannerDelegate> delegate;

    /** Last scanned code */
    @property (nonatomic, copy) NSString *lastCode;

    /** Types of codes to scan, defaults to all.
        When setting this array, make sure to use the appropriate values for your OS version. If in iOS 7 and above, use types from AVMetadataMachineReadableCodeObject, otherwise use ZBar's enums.
    */
    @property (nonatomic, strong) NSArray *codeTypes;

    /** Color of highlight frame, defaults to red */
    @property (nonatomic, strong) UIColor *highlightColor;
    
    /** Width of border of highlight frame, defaults to 4.0 */
    @property (nonatomic, assign) CGFloat highlightWidth; 

    /** Initialize scanner with view to be used for displaying the scanning */
    - (id)initWithView:(UIView *)view delegate:(id<SimpleBarCodeScannerDelegate>)delegate;
    
    /** Start capture session */
    - (void)start;
    
    /** Stop capture session */
    - (void)stop;

@end
