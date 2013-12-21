//
//  SimpleBarCodeScanner.h
//  SimpleBarCodeScannerExample
//
//  Created by . Carlin on 12/21/13.
//  Copyright (c) 2013 Carlin Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SimpleBarCodeScanner;
@protocol SimpleBarCodeScannerDelegate <NSObject>

	@required
	- (void)scanner:(SimpleBarCodeScanner *)scanner scannedCode:(NSString *)code;

@end

@interface SimpleBarCodeScanner : NSObject

    /** Delegate */
    @property (nonatomic, weak) id<SimpleBarCodeScannerDelegate> delegate;

    /** Last scanned code */
    @property (nonatomic, copy) NSString *lastCode;

    /** Types of codes to scan, defaults to all */
    @property (nonatomic, strong) NSArray *codeTypes;

    /** Color of highlight frame, defaults to red */
    @property (nonatomic, strong) UIColor *highlightColor;
    
    /** Width of border of highlight frame, default = 2.0 */
    @property (nonatomic, assign) CGFloat highlightWidth; 

    /** Initialize scanner with view to be used for displaying the scanning */
    - (id)initWithView:(UIView *)view delegate:(id<SimpleBarCodeScannerDelegate>)delegate;
    
    /** Start capture session */
    - (void)start;
    
    /** Stop capture session */
    - (void)stop;

@end
