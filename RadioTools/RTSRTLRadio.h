//
//  RTSRTLRadio.h
//  RadioTools
//
//  Created by Erik Larsen on 12/9/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTSRTLRadio : NSObject

@property (nonatomic) NSUInteger sampleRate;

- (id)initWithDelegate:(id)delegate
       sampleRate:(NSUInteger)sampleRate
      outputBufferSize:(NSUInteger)outputBufferSize;
- (void)start;
- (void)stop;

@end
