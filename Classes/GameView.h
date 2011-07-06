//
//  GameView.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the MIT license.
//

#import <Cocoa/Cocoa.h>
#import "GameController.h"

#define ViewPadding (50)


@interface GameView : NSView {
  GameTile *activeTile;
  NSDictionary *validDropPositions;
	BOOL dragging;
  BOOL mouseDown;
  
  IBOutlet GameController *game;
}


@end
