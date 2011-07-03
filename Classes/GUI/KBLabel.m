//
//  KBLabel.m
//  KBClasses
//
//  Created by Ben K on 2011/03/08.
//  All code is provided under the MIT license. Copyright 2011 Ben K
//

#import "KBLabel.h"


@implementation KBLabel

- (id)initWithCoder:(NSCoder *)decoder;
{
	if (![super initWithCoder:decoder])
		return nil;
	
	[[self cell] setBackgroundStyle:NSBackgroundStyleRaised];
	return self;
}


@end
