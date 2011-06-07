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
  NSEvent *mouseDraggedEvent;
  GameTile *activeTile;
	BOOL dragging;
  
  IBOutlet GameController *game;
}


@end
