//
//  Dod.h
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
#import "ActionFrame.h"

@interface Dod : NSObject {
	IBOutlet NSButton *startButton;
	IBOutlet NSTextField *botButtonTime;
	IBOutlet NSTextField *botButton;
	IBOutlet NSTextField *cleanFrameButton;
	
	@private
	NSInteger loopTime;
	BOOL botOn;
	BOOL farmBG;
	BOOL runLoopClean;
	BOOL killRunLoop;
	BOOL loopPause;
	ActionFrame *itFrame;
	ActionFrame *iaFrame;
	ActionFrame *iptFrame;
	ActionFrame *ctFrame;
	ActionFrame *caFrame;
	ActionFrame *cptFrame;
	ActionFrame *atFrame;
	ActionFrame *aaFrame;
	ActionFrame *aptFrame;
	ActionFrame *ptFrame;
	ActionFrame *maFrame;
	ActionFrame *paFrame;
	ActionFrame *mpFrame;
	ActionFrame *pptFrame;
	NSCondition *loopPauseCond;
	EventAction *event;
}

@property(assign) NSButton *startButton;
@property(assign) NSTextField *botButtonTime;
@property(assign) NSTextField *botButton;
@property(assign) NSTextField *cleanFrameButton;

- (id) init;
- (void) dealloc;
- (IBAction) quitButtonPress: (id)sender;
- (IBAction) startButtonPress: (id)sender;
- (IBAction) setBotOnTrue: (id)sender;
- (IBAction) setBotOnFalse: (id)sender;
- (IBAction) setFarmBgTrue: (id)sender;
- (IBAction) setFarmBgFalse: (id)sender;
- (btp_return_t) initFrames;
- (btp_return_t) runThread;
- (void) runLoop: (id)data;

@end
