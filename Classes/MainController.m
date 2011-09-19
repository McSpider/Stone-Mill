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

@end
