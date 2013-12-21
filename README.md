SimpleBarCodeScanner
====================

Simple bar code scanner library that uses both iOS 7 libraries as well as ZBarSDK for iOS 6 and below support. Keywords: Objc, Xcode, iOS, bar codes, scanning.

## Integration
Super simple. 5 steps:

 1. Import the header:

		#import "SimpleBarCodeScanner.h"

 2. Create an instance of the SimpleBarCodeScanner using the view you want to
   preview in and a delegate for when codes are scanned:

		self.scanner = [[SimpleBarCodeScanner alloc] initWithView:self.view delegate:self];

 3. Start the scanner whenever you're ready:

		[self.scanner start];

 4. Implement the delegate method:

		- (void)scanner:(SimpleBarCodeScanner *)scanner scannedCode:(NSString *)code
		{
			NSLog(@"Scanned Code: %@", code);
			[self.scanner stop];	// If you want to stop the session
		}

 5. Finally, add required libraries in the next section. See notes if you need
   pre-iOS 7 scanning too.

### Required Libraries / Frameworks
 - AVFoundation.framework (for ZBarSDK & iOS 7, status optional)
 - QuartzCore.framework (for ZBarSDK, status required)
 - CoreMedia.framework (for ZBarSDK, status optional)
 - CoreVideo.framework (for ZBarSDK, status optional)
 - libiconv.dylib (forZBarSDK, status required)

### Customization
You can set the types of codes to scan for (for iOS 7 and below), by setting the
<code>codeTypes</code> property. However, make sure you use the right types for
your particular OS: for iOS 7 please use types from AVMetadataMachineReadableCodeObject,
and for pre-iOS 7 use the enums from ZBarSDK.

You can also customize the highlight view in iOS 7 (it's just a UIView with clear background
and colored border) by setting <code>highlightColor</code> and
<code>highlightWidth</code>. Unfortunately pre-iOS 7 uses the ZBarSDK and
customizing the highlight is unavailable there.

### ZBarSDK Notes
 - If scanning in pre-iOS 7 is important, check integration notes for the ZBarSDK 
 on their [website](http://zbar.sourceforge.net/iphone/sdkdoc/install.html) 
 or [my github repo](https://github.com/carlinyuen/ZBarSDKarmv7s).



