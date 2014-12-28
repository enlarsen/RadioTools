//
//  RTSComplexVector.m
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

- (instancetype)init __attribute__((unavailable("init not available")));
{
    return nil;
}

- (instancetype)initWithSplitComplex:(DSPSplitComplex)splitComplex sizeElements:(NSUInteger)length
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
- (instancetype)initWithReal:(float *)real imaginary:(float *)imaginary sizeElements:(NSUInteger)length
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

- (instancetype)initWithSizeElements:(NSUInteger)sizeElements
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
