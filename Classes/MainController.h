//
//  MainController.h
//  StoneMill
//
//  Created by Ben K on 2011/06/02.
//  All code is provided under the MIT license.
//

#import <Cocoa/Cocoa.h>
#import "GameController.h"


@interface MainController : NSObject {
  IBOutlet NSWindow *mainWindow;
  IBOutlet NSWindow *settingsWindow;
  
  IBOutlet GameController *game;
}

@end
