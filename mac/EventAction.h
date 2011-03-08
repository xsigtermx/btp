//
//  EventAction.h
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


@interface EventAction : NSObject {
	NSInteger downKeys[MAX_KEY_SIZE];
	NSInteger upKeys[MAX_KEY_SIZE];
	NSInteger downKeysCount;
	NSInteger upKeysCount;
	CGPoint center;
	ProcessSerialNumber eventWindow;

}

@property(assign) ProcessSerialNumber eventWindow;

- (id) init;
- (void) dealloc;
- (void) cleanAction;
- (void) sendCenterClick: (NSInteger) seconds;
- (void) go;
- (void) addActionDown: (CGKeyCode) key;
- (void) addActionUp: (CGKeyCode) key;
- (void) sendInput: (NSString *) input;
- (CGKeyCode) getLetterMapping: (NSString *) matchLetter;

@end
