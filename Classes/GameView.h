//
//  GameView.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GameController.h"


@interface GameView : NSView {
  NSEvent *mouseDownEvent;
  GameTile *clickedTile;
	BOOL dragging;
  
  IBOutlet GameController *game;
}


@end
