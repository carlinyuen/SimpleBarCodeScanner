//
//  CCViewController.m
//  SimpleBarCodeScannerExample
//
//  Created by . Carlin on 12/21/13.
//  Copyright (c) 2013 Carlin Creations. All rights reserved.
//

#import "CCViewController.h"

#import "SimpleBarCodeScanner.h"

@interface CCViewController () <SimpleBarCodeScannerDelegate>

    @property (nonatomic, strong) SimpleBarCodeScanner *scanner;
    
@end

@implementation CCViewController   

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.scanner = [[SimpleBarCodeScanner alloc] initWithView:self.view delegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.scanner start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scanner:(SimpleBarCodeScanner *)scanner scannedCode:(NSString *)code
{
    NSLog(@"Scanned Code: %@", code);
    [self.scanner stop];
}

@end
