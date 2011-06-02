//
//  MainController.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GameView.h"


@interface MainController : NSObject {
  IBOutlet NSWindow *mainWindow;
  IBOutlet GameView *gameView;
}

@end
