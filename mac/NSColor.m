//
//  NSColor.m
//  btp
//
//  This file is part of BTP.                                                       
//
//  BTP is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  BTP is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with BTP.  If not, see <http://www.gnu.org/licenses/>.
//
//  Copyright 2009 Project DoD Inc. All rights reserved.
//

#import "NSColor.h"

@implementation NSColor (NSColorHexadecimalValue)

- (void) getHexRed: (NSString **) redHexValue
	   getHexGreen: (NSString **) greenHexValue
		getHexBlue: (NSString **) blueHexValue
{
	CGFloat redFloatValue, greenFloatValue, blueFloatValue;
	NSInteger redIntValue, greenIntValue, blueIntValue;
	
	//Convert the NSColor to the RGB color space before we can access its components
	NSColor *convertedColor = [self colorUsingColorSpaceName: NSDeviceRGBColorSpace];
	
	if(convertedColor)
	{
		// Get the red, green, and blue components of the color
		[convertedColor getRed: &redFloatValue green: &greenFloatValue blue: &blueFloatValue alpha: NULL];
		
		// Convert the components to numbers (unsigned decimal integer) between 0 and 255
		redIntValue=redFloatValue*255.99999f;
		greenIntValue=greenFloatValue*255.99999f;
		blueIntValue=blueFloatValue*255.99999f;
		
		// Convert the numbers to hex strings
		*redHexValue = [NSString stringWithFormat: @"%02x", redIntValue];
		*greenHexValue = [NSString stringWithFormat: @"%02x", greenIntValue];
		*blueHexValue = [NSString stringWithFormat: @"%02x", blueIntValue];
	}
	
	return;
}

@end

