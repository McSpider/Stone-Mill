//
//  GameScene.h
//  StoneMill
//
//  Created by Ben K on 12/01/09.
//  All code is provided under the MIT license.
//

#import <Cocoa/Cocoa.h>
#import "GameController.h"

#define VIEW_PADDING (50)

@interface GameSceneLayer : CCLayer {  
  GameTile *activeTile;
  NSDictionary *validDropPositions;
	BOOL dragging;
  BOOL mouseDown;
  
  NSPoint viewCenter;
  NSRect viewFrame;
  GameController *game;
  
  CCSprite *boardLayout;
}

@property (nonatomic, readonly) NSPoint viewCenter;
@property (nonatomic, readonly) NSRect viewFrame;
@property (nonatomic, retain) CCSprite *boardLayout;

@property (nonatomic, assign) GameController *game;

- (void)cleanupSprite:(CCSprite* )inSprite;

@end


@interface GameScene : CCScene {
	GameSceneLayer *layer;  
}

@property (nonatomic, retain) GameSceneLayer *layer;

+ (id)scene;

@end
