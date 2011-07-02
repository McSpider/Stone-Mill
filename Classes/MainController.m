//
//  MainController.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the New BSD license.
//

#import "MainController.h"


@implementation MainController


- (void)awakeFromNib
{

}

- (void)windowDidResignKey:(NSNotification *)notification
{
  [game setGameState:GamePaused];
}


@end
