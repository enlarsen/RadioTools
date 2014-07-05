//
//  RTSMultiplyConstant.m
//  RadioTools
//
//  Created by Erik Larsen on 12/23/13.
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

#import "RTSMultiplyConstant.h"

@interface RTSMultiplyConstant()

@property (nonatomic, strong) RTSComplexVector *intermediateComplex;
@property (nonatomic, strong) RTSFloatVector *intermediateFloat;
@property (nonatomic) NSUInteger sizeElements;

@end

@implementation RTSMultiplyConstant

- (void)setSizeElements:(NSUInteger)sizeElements
{
    if(_sizeElements != sizeElements)
    {
        _intermediateComplex = nil;
        _intermediateFloat = nil;
        _sizeElements = sizeElements;
    }
}

- (RTSComplexVector *)intermediateComplex
{
    if(!_intermediateComplex)
    {
        _intermediateComplex = [[RTSComplexVector alloc] initWithSizeElements:self.sizeElements];
    }
    return _intermediateComplex;
}

- (RTSFloatVector *)intermediateFloat
{
    if(_intermediateFloat)
    {
        _intermediateFloat = [[RTSFloatVector alloc] initWithSizeElements:self.sizeElements];
    }
    return _intermediateFloat;
}

- (RTSComplexVector *)multiplyComplexVectorByConstant:(RTSComplexVector *)input
                                         constant:(float *)constant
{
    self.sizeElements = input.sizeElements;

    vDSP_vsmul(input.realp, 1, constant, self.intermediateComplex.realp, 1, self.sizeElements);
    vDSP_vsmul(input.imagp, 1, constant, self.intermediateComplex.imagp, 1, self.sizeElements);

    return self.intermediateComplex;
}

- (RTSFloatVector *)multiplyFloatVectorByConstant:(RTSFloatVector *)input
                                         constant:(float *)constant
{
    self.sizeElements = input.sizeElements;

    vDSP_vsmul(input.vector, 1, constant, self.intermediateFloat.vector, 1, self.sizeElements);

    return self.intermediateFloat;

}

@end
