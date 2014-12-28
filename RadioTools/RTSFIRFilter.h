//
//  RTSFIRFilter.h
//  RadioTools
//
//  Created by Erik Larsen on 12/9/13.
//  Copyright (c) 2013 Erik Larsen.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import <Foundation/Foundation.h>
#import "RTSFloatVector.h"
#import "RTSComplexVector.h"

@interface RTSFIRFilter : NSObject

@property (nonatomic) int numberTaps;

- (instancetype)initLowpassWithSampleRate:(int)sampleRate transitionWidth:(int)transitionWidth
                    cutoff:(int)cutoff NS_DESIGNATED_INITIALIZER;
- (instancetype)initHighpassWithSampleRate:(int)sampleRate transitionWidth:(int)transitionWidth
                    cutoff:(int)cutoff NS_DESIGNATED_INITIALIZER;
- (instancetype)initBandpassWithSampleRate:(int)sampleRate transitionWidth:(int)transitionWidth
                       cutoffLow:(int)cutoffLow cutoffHigh:(int)cutoffHigh NS_DESIGNATED_INITIALIZER;
- (RTSComplexVector *)filterComplex:(RTSComplexVector *)input;
- (RTSFloatVector *)filterFloat:(RTSFloatVector *)input;

@end
