//
//  ActionFrame.m
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

#import "ActionFrame.h"
#import "NSColor.h"

/* private method prototypes */
@interface ActionFrame ()

- (void) buildLetter;
- (void) buildColorMapping;
- (void) swapCopyOfSrc: (void *) src withDest: (void *) dst forSize: (int) bytecount;
- (void) swizzleBitmap: (NSBitmapImageRep *) bitmap;

@end


@implementation ActionFrame


/*
 * PUBLIC METHOD DEFINITIONS
 */


- (id) init
{	
    if (self = [super init])
    {
		/* Build a full-screen GL context */
		
		// Specify attributes of the GL graphics context
		NSOpenGLPixelFormatAttribute attributes[] = {
			NSOpenGLPFAFullScreen,
			NSOpenGLPFAScreenMask,
			CGDisplayIDToOpenGLDisplayMask(kCGDirectMainDisplay),
			(NSOpenGLPixelFormatAttribute) 0
		};
		
		glPixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
		if (!glPixelFormat)
			return nil;
		
        NSRect mainScreenRect = [[NSScreen mainScreen] frame];
        maxX = mainScreenRect.size.width;
        maxY = mainScreenRect.size.height;
    }
	
	frameX = 0;
	frameY = 0;
	letterSize = 0;
	
	event = [[EventAction alloc] init];
	colorMapping = [[NSMapTable alloc] init];
	
    return self;	
}


- (void) dealloc
{
	[glPixelFormat release];
	[colorMapping release];
	[event release];
	
    [super dealloc];
}


- (ProcessSerialNumber) eventWindow
{
	return eventWindow;
}


- (void) setEventWindow: (ProcessSerialNumber) win
{
	eventWindow = win;
	[event setEventWindow: eventWindow];
	
	[self buildLetter];
	[self buildColorMapping];
}


- (btp_return_t) findFrameWithRed: (NSString *) red
						withGreen: (NSString *) green
						 withBlue: (NSString *) blue
						  atPoint: (CGPoint *) pt
{
	NSInteger x;
	NSInteger y;
	NSColor *pixelColor;
	NSString *redHexValue;
	NSString *greenHexValue;
	NSString *blueHexValue;
	NSBitmapImageRep *bitmap;
	
	[self screenShot: &bitmap];
	
    for (y = pt->y; y <= maxY; y++)
	{
		for (x = pt->x; x <= maxX; x++)
		{
			pixelColor = [bitmap colorAtX: x y: y];
			[pixelColor getHexRed: &redHexValue getHexGreen: &greenHexValue getHexBlue: &blueHexValue];
			
			if ([red compare: redHexValue] == NSOrderedSame &&
				[green compare: greenHexValue] == NSOrderedSame &&
				[blue compare: blueHexValue] == NSOrderedSame)
			{
				frameX = x;
				frameY = y;
				pt->x = frameX;
				pt->y = frameY;

				[bitmap release];
				
				return BTP_RETURN_OK;
			}
		}
	}

	[bitmap release];
	
	return BTP_RETURN_FAIL;
}


- (btp_return_t) hasInput: (NSBitmapImageRep *) bitmap
{
	NSColor *pixelColor;
	NSString *redHexValue;
	NSString *greenHexValue;
	NSString *blueHexValue;

	pixelColor = [bitmap colorAtX: frameX y: frameY];
	[pixelColor getHexRed: &redHexValue getHexGreen: &greenHexValue getHexBlue: &blueHexValue];
	
	if ([redHexValue compare: @"ff"] == NSOrderedSame &&
		[greenHexValue compare: @"ff"] == NSOrderedSame &&
		[blueHexValue compare: @"ff"] == NSOrderedSame)
	{
		[pixelColor release];
		[redHexValue release];
		[greenHexValue release];
		[blueHexValue release];
		return BTP_RETURN_OK;
	}
	else
	{
		[pixelColor release];
		[redHexValue release];
		[greenHexValue release];
		[blueHexValue release];
		return BTP_RETURN_FAIL;
	}
}


- (btp_return_t) doAction: (NSBitmapImageRep *) bitmap
{
	NSColor *pixelColor;
	NSString *redHexValue;
	NSString *greenHexValue;
	NSString *blueHexValue;
	NSString *partOne;
	NSString *partTwo;
	
	pixelColor = [bitmap colorAtX: frameX y: frameY];
	[pixelColor getHexRed: &redHexValue getHexGreen: &greenHexValue getHexBlue: &blueHexValue];
	
	/* The result of this is an EventAction object, and the go instance
	   method calls the sequence of buttons to press for this color.  The
	   EventAction object is put together in the buildColorMapping method
	   of this class. */
	
	partOne = [redHexValue stringByAppendingString: greenHexValue];
	partTwo = [partOne stringByAppendingString: blueHexValue];
	
	[[colorMapping objectForKey: partTwo] go];
	
	[partOne release];
	[partTwo release];
	[pixelColor release];
	[redHexValue release];
	[greenHexValue release];
	[blueHexValue release];
	
	return BTP_RETURN_OK;
}


/* I hate this function.  It's such a hack, but it's how we did it in the btp.ahk
   file, so it's how we're going to do it here. In short, the IA frame is this frame
   we used to hack in test stuff. The btpclick command sends its junk to this frame,
   and replaces what is usually the target action with a click. I know, lame. */
- (btp_return_t) doSpecialAction: (NSBitmapImageRep *) bitmap
{
	NSColor *pixelColor;
	NSString *redHexValue;
	NSString *greenHexValue;
	NSString *blueHexValue;
	NSString *partOne;
	NSString *partTwo;
	
	pixelColor = [bitmap colorAtX: frameX y: frameY];
	[pixelColor getHexRed: &redHexValue getHexGreen: &greenHexValue getHexBlue: &blueHexValue];

	partOne = [redHexValue stringByAppendingString: greenHexValue];
	partTwo = [partOne stringByAppendingString: blueHexValue];
	
	/* If this is the click action than send a click. */
	if ([partTwo compare: @"000088"] == NSOrderedSame)
	{
		[event sendCenterClick: 10000000];
	}
	else
	{		
	    [[colorMapping objectForKey: partTwo] go];
	}

	[partOne release];
	[partTwo release];
	[pixelColor release];
	[redHexValue release];
	[greenHexValue release];
	[blueHexValue release];
	
	return BTP_RETURN_OK;
}


/*
 * PRIVATE METHOD DEFINITIONS
 */


- (void) buildLetter
{
	letter[letterSize] = [event getLetterMapping: @"a"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"b"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"c"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"d"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"e"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"f"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"g"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"h"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"i"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"j"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"k"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"l"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"m"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"n"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"o"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"p"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"q"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"r"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"s"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"t"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"u"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"v"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"w"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"x"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"y"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"z"];
	letterSize++;

	letter[letterSize] = [event getLetterMapping: @"`"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"-"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"="];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"["];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"]"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @";"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"'"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @","];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"."];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"/"];
	letterSize++;
	
	letter[letterSize] = [event getLetterMapping: @"1"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"2"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"3"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"4"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"5"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"6"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"7"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"8"];
	letterSize++;
	letter[letterSize] = [event getLetterMapping: @"9"];
	letterSize++;
}


- (void) buildColorMapping
{
	NSInteger r = 0;
	NSInteger g = 0;
	NSInteger b = 0;
	NSInteger state = 1;
	NSInteger letterIndex = 0;
	NSInteger startColor;
	CGKeyCode key;
	NSMutableArray *hex = [[NSMutableArray alloc] init];
	EventAction *eventAction;
	
	[hex addObject: @"00"];
	[hex addObject: @"11"];
	[hex addObject: @"22"];
	[hex addObject: @"33"];
	[hex addObject: @"44"];
	[hex addObject: @"55"];
	[hex addObject: @"66"];
	[hex addObject: @"77"];
	[hex addObject: @"88"];
	[hex addObject: @"99"];
	[hex addObject: @"aa"];
	[hex addObject: @"bb"];
	[hex addObject: @"cc"];
	[hex addObject: @"dd"];
	[hex addObject: @"ee"];
	[hex addObject: @"ff"];
	
	/* These are a bunch of fringe cases that we added outside the normal
	 programatic indexes. */

	/* DO NOTHING */
	eventAction = [[EventAction alloc] init];
	[eventAction setEventWindow: eventWindow];
	[colorMapping setObject: eventAction forKey:
	 [[[hex objectAtIndex: r] stringByAppendingString:
	   [hex objectAtIndex: g]] stringByAppendingString:
	  [hex objectAtIndex: b]]];
	colorMappingMax++;
	b++;
	[eventAction release];
	
	/* CRTL-1 */
	eventAction = [[EventAction alloc] init];
	[eventAction setEventWindow: eventWindow];
	[eventAction addActionDown: 59];
	[eventAction addActionDown: 18];
	[eventAction addActionUp: 18];
	[eventAction addActionUp: 59];
	[colorMapping setObject: eventAction forKey:
	 [[[hex objectAtIndex: r] stringByAppendingString:
	   [hex objectAtIndex: g]] stringByAppendingString:
	  [hex objectAtIndex: b]]];
	letterIndex++;
	b++;
	[eventAction release];
	
	/* UP + SPACE */
	eventAction = [[EventAction alloc] init];
	[eventAction setEventWindow: eventWindow];
	[eventAction addActionDown: 126];
	[eventAction addActionDown: 49];
	[eventAction addActionUp: 49];
	[eventAction addActionUp: 126];
	[colorMapping setObject: eventAction forKey:
	 [[[hex objectAtIndex: r] stringByAppendingString:
	   [hex objectAtIndex: g]] stringByAppendingString:
	  [hex objectAtIndex: b]]];
	colorMappingMax++;
	b++;
	[eventAction release];
	
	/* DOWN + SPACE */
	eventAction = [[EventAction alloc] init];
	[eventAction setEventWindow: eventWindow];
	[eventAction addActionDown: 125];
	[eventAction addActionDown: 49];
	[eventAction addActionUp: 49];
	[eventAction addActionUp: 125];
	[colorMapping setObject: eventAction forKey:
	 [[[hex objectAtIndex: r] stringByAppendingString:
	   [hex objectAtIndex: g]] stringByAppendingString:
	  [hex objectAtIndex: b]]];
	colorMappingMax++;
	b++;
	[eventAction release];
	
	/* LEFT */
	eventAction = [[EventAction alloc] init];
	[eventAction setEventWindow: eventWindow];
	[eventAction addActionDown: 123];
	[eventAction addActionUp: 123];
	[colorMapping setObject: eventAction forKey:
	 [[[hex objectAtIndex: r] stringByAppendingString:
	   [hex objectAtIndex: g]] stringByAppendingString:
	  [hex objectAtIndex: b]]];
	colorMappingMax++;
	b++;
	[eventAction release];
	
	/* RIGHT */
	eventAction = [[EventAction alloc] init];
	[eventAction setEventWindow: eventWindow];
	[eventAction addActionDown: 124];
	[eventAction addActionUp: 124];
	[colorMapping setObject: eventAction forKey:
	 [[[hex objectAtIndex: r] stringByAppendingString:
	   [hex objectAtIndex: g]] stringByAppendingString:
	  [hex objectAtIndex: b]]];
	colorMappingMax++;
	b++;
	[eventAction release];
	
	/* SPACE */
	eventAction = [[EventAction alloc] init];
	[eventAction setEventWindow: eventWindow];
	[eventAction addActionDown: 49];
	[eventAction addActionUp: 49];
	[colorMapping setObject: eventAction forKey:
	 [[[hex objectAtIndex: r] stringByAppendingString:
	   [hex objectAtIndex: g]] stringByAppendingString:
	  [hex objectAtIndex: b]]];
	colorMappingMax++;
	b++;
	[eventAction release];
	
	/* DOWN (z-axis) This is the 'x' key */
	eventAction = [[EventAction alloc] init];
	[eventAction setEventWindow: eventWindow];
	[eventAction addActionDown: 7];
	[eventAction addActionUp: 7];
	[colorMapping setObject: eventAction forKey:
	 [[[hex objectAtIndex: r] stringByAppendingString:
	   [hex objectAtIndex: g]] stringByAppendingString:
	  [hex objectAtIndex: b]]];
	colorMappingMax++;
	b++;
	[eventAction release];
	
	/* This code brought to you by the letter 't' */
	eventAction = [[EventAction alloc] init];
	[eventAction setEventWindow: eventWindow];
	[eventAction addActionDown: 17];
	[eventAction addActionUp: 17];
	[colorMapping setObject: eventAction forKey:
	 [[[hex objectAtIndex: r] stringByAppendingString:
	   [hex objectAtIndex: g]] stringByAppendingString:
	  [hex objectAtIndex: b]]];
	colorMappingMax++;
	b++;
	startColor = b;
	[eventAction release];
	
	for (r = 0; r < [hex count]; r++)
	{
		for (g = 0; g < [hex count]; g++)
		{
			for (b = 0; b < [hex count]; b++)
			{
				/* Throw the mapping together here.  This could be done a bunch
				 of different ways, but constructing an object of actions was
				 the easiest.  A less memory intensive way to do this would
				 be to make a language parser and translate that at runtime. */
				if (startColor)
				{
					b = startColor;
					letterIndex = startColor - 1;
					startColor = 0;
				}
				
				if (state == 1)
				{
					/* This maps to CTRL */
					eventAction = [[EventAction alloc] init];
					[eventAction addActionDown: 59];
					key = letter[letterIndex];
					[eventAction addActionDown: key];
					[eventAction addActionUp: key];
					[eventAction addActionUp: 59];
				}
				else if (state == 2)
				{
					/* This maps to CTRL-SHIFT */
					eventAction = [[EventAction alloc] init];
					[eventAction addActionDown: 59];
					[eventAction addActionDown: 56];
					key = letter[letterIndex];
					[eventAction addActionDown: key];
					[eventAction addActionUp: key];
					[eventAction addActionUp: 56];
					[eventAction addActionUp: 59];
				}
				else if (state == 3)
				{
					/* This maps to ALT */
					eventAction = [[EventAction alloc] init];
					[eventAction addActionDown: 58];
					key = letter[letterIndex];
					[eventAction addActionDown: key];
					[eventAction addActionUp: key];
					[eventAction addActionUp: 58];
				}
				else if (state == 4)
				{
					/* This maps to ALT-SHIFT */
					eventAction = [[EventAction alloc] init];
					[eventAction addActionDown: 58];
					[eventAction addActionDown: 56];
					key = letter[letterIndex];
					[eventAction addActionDown: key];
					[eventAction addActionUp: key];
					[eventAction addActionUp: 56];
					[eventAction addActionUp: 58];
				}
				else if (state == 5)
				{
					/* This maps to ALT-CTRL */
					eventAction = [[EventAction alloc] init];
					[eventAction addActionDown: 58];
					[eventAction addActionDown: 59];
					key = letter[letterIndex];
					[eventAction addActionDown: key];
					[eventAction addActionUp: key];
					[eventAction addActionUp: 59];
					[eventAction addActionUp: 58];
				}
				else if (state == 6)
				{
					/* This maps to ALT-CTRL-SHIFT */
					eventAction = [[EventAction alloc] init];
					[eventAction addActionDown: 58];
					[eventAction addActionDown: 59];
					[eventAction addActionDown: 56];
					key = letter[letterIndex];
					[eventAction addActionDown: key];
					[eventAction addActionUp: key];
					[eventAction addActionUp: 56];
					[eventAction addActionUp: 59];
					[eventAction addActionUp: 58];
				}
				
				[eventAction setEventWindow: eventWindow];
				[colorMapping setObject: eventAction forKey:
				 [[[hex objectAtIndex: r] stringByAppendingString:
				   [hex objectAtIndex: g]] stringByAppendingString:
				  [hex objectAtIndex: b]]];
				colorMappingMax++;
				letterIndex++;
				[eventAction release];
				
				if (letterIndex > 44 || (letterIndex > 35 && state == 1))
				{
					letterIndex = 0;
					state++;
					
					/* If you were to look at the btp.ahk here, we would be building
					 target strings for those targets that are outside the number of key
					 presses we have.  As it turns out, we make it very far in our bindings,
					 and while it's nice to have, we do not need these strings on the MAC. */
					if (state > 6)
						goto rick_rolled;
				}
			}
		}
	}
	
rick_rolled:
	
	[hex release];
}


- (void) screenShot: (NSBitmapImageRep **) bitmap
{
	NSOpenGLContext *mGLContext;
	NSBitmapImageRep *bm;
	GLint viewport[4];
	long bytewidth;
	GLint width;
	GLint height;
	long bytes;
 
	// Create OpenGL context used to render
	mGLContext = [[NSOpenGLContext alloc] initWithFormat:glPixelFormat shareContext:nil];
	
	if (!mGLContext)
		return;
	
	// Set our context as the current OpenGL context
	[mGLContext makeCurrentContext];
	
	// Set full-screen mode
	[mGLContext setFullScreen];
	
	glReadBuffer(GL_FRONT);
	glGetIntegerv(GL_VIEWPORT, viewport);

	width = viewport[2];
	height = viewport[3];
	
	bytewidth = width * 4;
	bytewidth = (bytewidth + 3) & ~3;
	bytes = bytewidth * height;
	
	bm = [[NSBitmapImageRep alloc]     initWithBitmapDataPlanes:NULL
												     pixelsWide:width
													 pixelsHigh:height
												   bitsPerSample:8
												samplesPerPixel:3
													   hasAlpha:NO
													   isPlanar:NO
												 colorSpaceName:NSDeviceRGBColorSpace
												   bitmapFormat:NSAlphaFirstBitmapFormat
													bytesPerRow:bytewidth
												   bitsPerPixel:8 * 4];
	
	glFinish();
	glPixelStorei(GL_PACK_ALIGNMENT, 4);
	glPixelStorei(GL_PACK_ROW_LENGTH, 0);
	glPixelStorei(GL_PACK_SKIP_ROWS, 0);
	glPixelStorei(GL_PACK_SKIP_PIXELS, 0); 
	
	glReadPixels(0, 0, width, height, GL_RGBA,
				 GL_UNSIGNED_INT_8_8_8_8_REV,
				 [bm bitmapData]);
	
	[self swizzleBitmap: bm];
	*bitmap = bm;
	
	[mGLContext release];
}


- (void) swapCopyOfSrc: (void *) src withDest: (void *) dst forSize: (int) bytecount
{
    uint32_t *srcP;
    uint32_t *dstP;
    uint32_t p0, p1, p2, p3;
    uint32_t u0, u1, u2, u3;
    
    srcP = src;
    dstP = dst;
#define SWAB_PIXEL(p) (((p) << 8) | ((p) >> 24))
	
    while (bytecount >= 16)
    {
        p3 = srcP[3];
        p2 = srcP[2];
        p1 = srcP[1];
        p0 = srcP[0];
        
        u3 = SWAB_PIXEL(p3);
        u2 = SWAB_PIXEL(p2);
        u1 = SWAB_PIXEL(p1);
        u0 = SWAB_PIXEL(p0);
        srcP += 4;
		
        dstP[3] = u3;
        dstP[2] = u2;
        dstP[1] = u1;
        dstP[0] = u0;
        bytecount -= 16;
        dstP += 4;
    }
    while (bytecount >= 4)
    {
        p0 = *srcP++;
        bytecount -= 4;
        *dstP++ = SWAB_PIXEL(p0);
    }
}


- (void) swizzleBitmap: (NSBitmapImageRep *) bitmap
{
    int top;
	int bottom;
    void *buffer;
    void *topP;
    void *bottomP;
    void *base;
    int rowBytes;
	
    rowBytes = [bitmap bytesPerRow];
    top = 0;
    bottom = [bitmap pixelsHigh] - 1;
    base = [bitmap bitmapData];
    buffer = malloc(rowBytes);
    
    while (top < bottom)
    {
        topP = (top * rowBytes) + base;
        bottomP = (bottom * rowBytes) + base;
        
        [self swapCopyOfSrc: topP withDest: buffer forSize: rowBytes];
        [self swapCopyOfSrc: bottomP withDest: topP forSize: rowBytes];
        bcopy(buffer, bottomP, rowBytes);
        
        top++;
        bottom--;
    }
	
    free(buffer);
}

@end
