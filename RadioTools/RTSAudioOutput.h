//
//  RTSAudioOutput.h
//  RadioTools
//
//  Created by Erik Larsen on 12/9/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <RadioTools/RadioTools.h>

@interface RTSAudioOutput : NSObject

- (void)playSoundBuffer:(RTSFloatVector *)audio;
- (id)initWithSampleRate:(UInt32)rate;


@end
