//
//  TileManager.m
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TileManager.h"


@implementation TileManager

- (id)init
{
  if (![super init]) {
    return nil;
  }
  player1 = [[GamePlayer alloc] init];
  [player1 setType:HumanPlayer];
  [player1 setColor:Blue];
  
  player2 = [[GamePlayer alloc] init];
  [player2 setType:RobotPlayer];
  [player2 setColor:Gold];
  return self;
}

- (BOOL)tilesCanJump
{
  return YES;
}

- (BOOL)gameIsSetup
{
  if (player1.isSetup && player2.isSetup)
    return YES;
  
  return NO;
}


@end
