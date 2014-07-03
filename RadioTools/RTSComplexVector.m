//
//  RTSComplexVector.m
//  RadioTools
//
//  Created by Erik Larsen on 12/9/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

/* Notes
 
 Manages the individual NSData buffers for real and imaginary.
 Properties for vDSP split complex vectors.

 */

#import "RTSComplexVector.h"

@interface RTSComplexVector()

@property (nonatomic, strong) NSMutableData *real;
@property (nonatomic, strong) NSMutableData *imaginary;

@end



@implementation RTSComplexVector

- (id)init __attribute__((unavailable("init not available")));
{
    return nil;
}

- (id)initWithSplitComplex:(DSPSplitComplex)splitComplex sizeElements:(NSUInteger)length
{
    if(splitComplex.realp && splitComplex.imagp)
    {
        return [self initWithReal:splitComplex.realp
                        imaginary:splitComplex.imagp
                     sizeElements:length];
    }
    else
    {
        return nil;
    }
 }

// Designated initializer
- (id)initWithReal:(float *)real imaginary:(float *)imaginary sizeElements:(NSUInteger)length
{
    if(self = [super init])
    {
        if(real && imaginary)
        {
        _real = [[NSMutableData alloc] initWithBytes:real
                                       length:length * sizeof(float)];
        _imaginary = [[NSMutableData alloc] initWithBytes:imaginary
                                            length:length * sizeof(float)];
        }
    }
    return self;
}

- (id)initWithSizeElements:(NSUInteger)sizeElements
{
    if(self = [super init])
    {
        _real = [[NSMutableData alloc] initWithLength:sizeElements * sizeof(float)];
        _imaginary = [[NSMutableData alloc] initWithLength:sizeElements * sizeof(float)];
    }
    return self;
}

#pragma mark - Properties


- (float *)realp
{
    return (float *)[self.real mutableBytes];
}

- (float *)imagp
{
    return (float *)[self.imaginary mutableBytes];
}

- (DSPSplitComplex)splitComplex
{
    [self checkSplitComplex];
    return _splitComplex;
}

- (DSPSplitComplex *)splitComplexRef
{
    [self checkSplitComplex];
    return &_splitComplex;
}

- (void)checkSplitComplex
{
    if(_splitComplex.realp == nil || _splitComplex.imagp == nil)
    {
        _splitComplex.realp = self.realp;
        _splitComplex.imagp = self.imagp;
    }

}

- (int)sizeElements
{
    return (int)self.real.length / sizeof(float);
}

- (int)sizeBytes
{
    return (int)self.real.length;
}


@end
