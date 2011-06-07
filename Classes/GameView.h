//
//  GameView.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>
#import "GameController.h"


@interface GameView : NSView {
  GameTile *activeTile;
  NSArray *validDropPositions;
	BOOL dragging;
  BOOL mouseDown;
  
  IBOutlet GameController *game;
}


@end
