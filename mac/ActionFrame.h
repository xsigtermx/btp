//
//  ActionFrame.h
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

#import <Cocoa/Cocoa.h>
#import "EventAction.h"

@interface ActionFrame : NSObject {
	int maxX;
	int maxY;
	int frameX;
	int frameY;
	int letter[LETTER_MAX_SIZE];
	int letterSize;
	NSInteger colorMappingMax;
	NSOpenGLPixelFormat *glPixelFormat;
	ProcessSerialNumber eventWindow;
	NSMapTable *colorMapping;
	EventAction *event;
}


- (id) init;
- (void) dealloc;
- (ProcessSerialNumber) eventWindow;
- (void) setEventWindow: (ProcessSerialNumber) win;
- (btp_return_t) hasInput: (NSBitmapImageRep *) bitmap;
- (btp_return_t) doAction: (NSBitmapImageRep *) bitmap;
- (btp_return_t) doSpecialAction: (NSBitmapImageRep *) bitmap;
- (void) screenShot: (NSBitmapImageRep **) bitmap;
- (btp_return_t) findFrameWithRed: (NSString *) red
						withGreen: (NSString *) green
						 withBlue: (NSString *) blue
						  atPoint: (CGPoint *) pt;


@end
