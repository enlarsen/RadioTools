//
//  RTSLowPassFilter.h
//  RadioTools
//
//  Created by Erik Larsen on 12/9/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTSFloatVector.h"
#import "RTSComplexVector.h"

@interface RTSFIRFilter : NSObject

@property (nonatomic) int numberTaps;

- (id)initLowpassWithSampleRate:(int)sampleRate transitionWidth:(int)transitionWidth
                    cutoff:(int)cutoff;
- (id)initHighpassWithSampleRate:(int)sampleRate transitionWidth:(int)transitionWidth
                    cutoff:(int)cutoff;
- (id)initBandpassWithSampleRate:(int)sampleRate transitionWidth:(int)transitionWidth
                       cutoffLow:(int)cutoffLow cutoffHigh:(int)cutoffHigh;
- (RTSComplexVector *)filterComplex:(RTSComplexVector *)input;
- (RTSFloatVector *)filterFloat:(RTSFloatVector *)input;

@end
