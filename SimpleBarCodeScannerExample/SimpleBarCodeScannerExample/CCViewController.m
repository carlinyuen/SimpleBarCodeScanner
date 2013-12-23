//
//  CCViewController.m
//  SimpleBarCodeScannerExample
//
//  Created by . Carlin on 12/21/13.
//  Copyright (c) 2013 Carlin Creations. All rights reserved.
//

#import "CCViewController.h"

#import "SimpleBarCodeScanner.h"

@interface CCViewController () <SimpleBarCodeScannerDelegate
    , UIAlertViewDelegate
>

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
    [[[UIAlertView alloc] initWithTitle:@"Code Scanned" message:code delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.scanner start];
}

@end
