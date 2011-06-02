//
//  GamePlayer.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GameTile.h"

#define RobotPlayer (0)
#define HumanPlayer (1)


@interface GamePlayer : NSObject {
  int playerType;
  int placedTileCount;
  
  NSMutableArray *activeTiles;
}
@property int playerType;
@property int placedTileCount;


- (BOOL)isSetup;


@end
