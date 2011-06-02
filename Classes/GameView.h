//
//  GameView.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GameTile.h"


@interface GameView : NSView {

  NSEvent *mouseDownEvent;
	BOOL dragging;

}

- (void)initGameBoard;
- (GameTile *)tileAtPoint:(NSPoint)point;


@end
