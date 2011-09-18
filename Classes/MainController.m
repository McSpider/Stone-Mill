//
//  MainController.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the MIT license.
//

#import "MainController.h"


@implementation MainController


- (void)awakeFromNib
{
	[mainWindow center];
	[settingsWindow center];
}

- (void)windowDidResignKey:(NSNotification *)notification
{
  [game pauseGame:self];
}

- (void)windowWillClose:(NSNotification *)notification
{
	if ([notification object] == mainWindow) {
		[NSApp terminate:nil];
	}
}


-(IBAction)changeAIspeed:(id)sender
{
	[game setMoveRate:1 - ([sender doubleValue] / 100)];
}

-(IBAction)changeBlueAISmartness:(id)sender
{
	[game.bluePlayer setSmartness:[sender intValue]];
}

-(IBAction)changeGoldAISmartness:(id)sender
{
	[game.goldPlayer setSmartness:[sender intValue]];
}

@end
