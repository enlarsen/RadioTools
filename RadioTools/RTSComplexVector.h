//
//  RTSComplexVector.h
//  RadioTools
//
//  Created by Erik Larsen on 12/9/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
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
#import <Accelerate/Accelerate.h>

@interface RTSComplexVector : NSObject

@property (nonatomic, readonly) float *realp;
@property (nonatomic, readonly) float *imagp;
@property (nonatomic) DSPSplitComplex splitComplex;
@property (nonatomic) DSPSplitComplex *splitComplexRef;
@property (nonatomic, readonly) int sizeElements;
@property (nonatomic, readonly) int sizeBytes;

- (instancetype)initWithSplitComplex:(DSPSplitComplex)splitComplex sizeElements:(NSUInteger)length;
- (instancetype)initWithReal:(float *)real imaginary:(float *)imaginary sizeElements:(NSUInteger)length NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithSizeElements:(NSUInteger)sizeElements NS_DESIGNATED_INITIALIZER;

@end
