//
//  Dod.m
//  btp
//
//  This file is part of BTP.                                                       
//
// BTP is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// BTP is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with BTP.  If not, see <http://www.gnu.org/licenses/>.
//
//  Copyright 2009 Project DoD Inc. All rights reserved.
//

#import "Dod.h"


@implementation Dod


@synthesize startButton;
@synthesize botButton;
@synthesize botButtonTime;
@synthesize cleanFrameButton;


- (id) init
{
	itFrame = [[ActionFrame alloc] init];
	iaFrame = [[ActionFrame alloc] init];
	iptFrame = [[ActionFrame alloc] init];
	ctFrame = [[ActionFrame alloc] init];
	caFrame = [[ActionFrame alloc] init];
	cptFrame = [[ActionFrame alloc] init];
	atFrame = [[ActionFrame alloc] init];
	aaFrame = [[ActionFrame alloc] init];
	aptFrame = [[ActionFrame alloc] init];
	ptFrame = [[ActionFrame alloc] init];
	maFrame = [[ActionFrame alloc] init];
	paFrame = [[ActionFrame alloc] init];
	mpFrame = [[ActionFrame alloc] init];
	pptFrame = [[ActionFrame alloc] init];
	
	loopPauseCond = [[NSCondition alloc] init];
	event = [[EventAction alloc] init];
	
	runLoopClean = TRUE;
	killRunLoop = TRUE;
	loopPause = FALSE;
	botOn = FALSE;
	farmBG = FALSE;
	
	loopTime = BTP_LOOP_TIME;
	
	return self;
}


- (void) dealloc
{
	[event release];
	[loopPauseCond release];
	
	[itFrame release];
	[iaFrame release];
	[iptFrame release];
	[ctFrame release];
	[caFrame release];
	[cptFrame release];
	[atFrame release];
	[aaFrame release];
	[aptFrame release];
	[ptFrame release];
	[maFrame release];
	[paFrame release];
	[mpFrame release];
	[pptFrame release];
	
    [super dealloc];
}


- (IBAction) quitButtonPress: (id)sender
{
	/* That's all folks. */
	exit(0);
}


- (IBAction) startButtonPress: (id)sender
{
	if ([[startButton title] compare: @"Start"] == NSOrderedSame && loopPause == FALSE)
	{
	    [startButton setTitle: @"Pause"];

	    if ([self initFrames] != BTP_RETURN_OK)
		{
			NSLog(@"Could not find frame command boxes trying again.");
			[event sendInput: @"/btp_dbg Could not find frame command boxes trying again."];
		}
	}
	else if ([[startButton title] compare: @"Start"] == NSOrderedSame)
	{
	    [startButton setTitle: @"Pause"];
	    loopPause = FALSE;
		[loopPauseCond signal];
	}
	else
	{
		[startButton setTitle: @"Start"];
		loopPause = TRUE;
	}
}


- (IBAction) setBotOnTrue: (id)sender
{
	botOn = TRUE;
}


- (IBAction) setBotOnFalse: (id)sender
{
	botOn = FALSE;
}


- (IBAction) setFarmBgTrue: (id)sender
{
	farmBG = TRUE;
}


- (IBAction) setFarmBgFalse: (id)sender
{
	farmBG = FALSE;
}


- (btp_return_t) initFrames
{
	int tries = 0;
	Boolean framesNotFound = TRUE;
	btp_return_t ret;
	CGPoint pt;
	ProcessSerialNumber wowWindow;
	
	memset(&pt, 0, sizeof(CGPoint));
	
	killRunLoop = FALSE;
	
	usleep(BTP_WAIT_SLEEP);
	
	GetFrontProcess(&wowWindow);
	
	[event setEventWindow: wowWindow];
	[itFrame setEventWindow: wowWindow];
	[iaFrame setEventWindow: wowWindow];
	[iptFrame setEventWindow: wowWindow];
	[ctFrame setEventWindow: wowWindow];
	[caFrame setEventWindow: wowWindow];
	[cptFrame setEventWindow: wowWindow];
	[atFrame setEventWindow: wowWindow];
	[aaFrame setEventWindow: wowWindow];
	[aptFrame setEventWindow: wowWindow];
	[ptFrame setEventWindow: wowWindow];
	[maFrame setEventWindow: wowWindow];
	[paFrame setEventWindow: wowWindow];
	[mpFrame setEventWindow: wowWindow];
	[pptFrame setEventWindow: wowWindow];
	
	[event sendInput: @"/btp_finit\n"];
	usleep(BTP_WAIT_SLEEP);
	
	while (framesNotFound)
	{
		if (tries >= 3)
			return BTP_RETURN_FRAMES_NOT_FOUND;
		
		tries++;
		memset(&pt, 0, sizeof(CGPoint));
		
	    if ([itFrame findFrameWithRed: @"00" withGreen: @"00" withBlue: @"11" atPoint: &pt] != BTP_RETURN_OK)
	    	continue;
	
    	if ([iaFrame findFrameWithRed: @"00" withGreen: @"00" withBlue: @"22" atPoint: &pt] != BTP_RETURN_OK)
    		continue;
	
	    if ([iptFrame findFrameWithRed: @"00" withGreen: @"00" withBlue: @"33" atPoint: &pt] != BTP_RETURN_OK)
	     	continue;
	
	    if ([ctFrame findFrameWithRed: @"00" withGreen: @"00" withBlue: @"44" atPoint: &pt] != BTP_RETURN_OK)
	    	continue;
	
    	if ([caFrame findFrameWithRed: @"00" withGreen: @"00" withBlue: @"55" atPoint: &pt] != BTP_RETURN_OK)
    		continue;
	
    	if ([cptFrame findFrameWithRed: @"00" withGreen: @"00" withBlue: @"66" atPoint: &pt] != BTP_RETURN_OK)
    		continue;
	
    	if ([atFrame findFrameWithRed: @"00" withGreen: @"00" withBlue: @"77" atPoint: &pt] != BTP_RETURN_OK)
    		continue;
	
    	if ([aaFrame findFrameWithRed: @"00" withGreen: @"00" withBlue: @"88" atPoint: &pt] != BTP_RETURN_OK)
    		continue;
	
	    if ([aptFrame findFrameWithRed: @"00" withGreen: @"00" withBlue: @"99" atPoint: &pt] != BTP_RETURN_OK)
	    	continue;
	
    	if ([ptFrame findFrameWithRed: @"00" withGreen: @"00" withBlue: @"aa" atPoint: &pt] != BTP_RETURN_OK)
    		continue;
	
    	if ([maFrame findFrameWithRed: @"00" withGreen: @"00" withBlue: @"bb" atPoint: &pt] != BTP_RETURN_OK)
    		continue;
	
	    if ([paFrame findFrameWithRed: @"00" withGreen: @"00" withBlue: @"cc" atPoint: &pt] != BTP_RETURN_OK)
	    	continue;
	
		if ([mpFrame findFrameWithRed: @"00" withGreen: @"00" withBlue: @"dd" atPoint: &pt] != BTP_RETURN_OK)
    		continue;
	
	    if ([pptFrame findFrameWithRed: @"00" withGreen: @"00" withBlue: @"ee" atPoint: &pt] != BTP_RETURN_OK)
	    	continue;
		
		framesNotFound = FALSE;
		[event sendInput: [[self cleanFrameButton] stringValue]];
	}
	
	ret = [self runThread];
	return ret;
}


- (btp_return_t) runThread
{
	runLoopClean = FALSE;

	[NSThread detachNewThreadSelector:@selector(runLoop:) toTarget:self withObject:nil];

	return BTP_RETURN_OK;
}


- (void) runLoop: (id)data
{
	NSInteger loopCount = 0;
	NSInteger farmCount = 0;
	NSBitmapImageRep *bitmap;
	
	while (!(killRunLoop))
	{
		NSAutoreleasePool *thread_pool = [[NSAutoreleasePool alloc] init];
		
		if (loopPause == TRUE)
		{
			[loopPauseCond lock];
			[loopPauseCond wait];
			[loopPauseCond unlock];
		}
		
		if ([[self botButtonTime] intValue] <= loopCount)
		{
			loopCount = 0;
			
			if (botOn == TRUE)
				[event sendInput: [[self botButton] stringValue]];
		}
			
		if (farmCount > BTP_FARM_BG_TIME)
		{
			farmCount = 0;
			
			if (farmBG == TRUE)
			{
				[event sendInput: @"h"];
				[event sendInput: @"h"];
			}
		}
		
		[itFrame screenShot: &bitmap];
		
		/* Read colors from each frame and hit the button mapped to that
		   frame color. */
		if ([itFrame hasInput: bitmap] == BTP_RETURN_OK)
		{
			[iaFrame doSpecialAction: bitmap];
			[iptFrame doAction: bitmap];
			[ctFrame doAction: bitmap];
			[caFrame doAction: bitmap];
			[cptFrame doAction: bitmap];
			[atFrame doAction: bitmap];
			[aaFrame doAction: bitmap];
			[aptFrame doAction: bitmap];
			[ptFrame doAction: bitmap];
			[maFrame doAction: bitmap];
			[paFrame doAction: bitmap];
			[mpFrame doAction: bitmap];
			[pptFrame doAction: bitmap];

			[event sendInput: [[self cleanFrameButton] stringValue]];
		}

		[bitmap autorelease];
		[thread_pool drain];

		loopCount += loopTime;
		farmCount++;
		
		usleep(loopTime);
	}
	
	runLoopClean = TRUE;
	
	return;
}

@end
