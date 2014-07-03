//
//  RTSIIRFilter.h
//  RadioTools
//
//  Created by Erik Larsen on 12/15/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTSFloatVector.h"
#import "RTSComplexVector.h"

@interface RTSIIRFilter : NSObject

- (id)initLowpassWithSampleRate:(NSUInteger)sampleRate
                         cutoff:(NSUInteger)cutoff
                              Q:(NSUInteger)Q;

- (id)initHighpassWithSampleRate:(NSUInteger)sampleRate
                          cutoff:(NSUInteger)cutoff
                               Q:(NSUInteger)Q;

- (id)initBandpassWithSampleRate:(NSUInteger)sampleRate
                       cutoffLow:(NSUInteger)cutoffLow
                      cutoffHigh:(NSUInteger)cutoffHigh;

- (RTSComplexVector *)filterComplex:(RTSComplexVector *)input;
- (RTSFloatVector *)filterFloat:(RTSFloatVector *)input;

@end
