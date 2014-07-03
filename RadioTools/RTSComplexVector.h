//
//  RTSComplexVector.h
//  RadioTools
//
//  Created by Erik Larsen on 12/9/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@interface RTSComplexVector : NSObject

@property (nonatomic, readonly) float *realp;
@property (nonatomic, readonly) float *imagp;
@property (nonatomic) DSPSplitComplex splitComplex;
@property (nonatomic) DSPSplitComplex *splitComplexRef;
@property (nonatomic, readonly) int sizeElements;
@property (nonatomic, readonly) int sizeBytes;

- (id)initWithSplitComplex:(DSPSplitComplex)splitComplex sizeElements:(NSUInteger)length;
- (id)initWithReal:(float *)real imaginary:(float *)imaginary sizeElements:(NSUInteger)length;
- (id)initWithSizeElements:(NSUInteger)sizeElements;

@end
