//
//  RTSInputConditioner.m
//  RadioTools
//
//  Created by Erik Larsen on 12/16/13.
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

#include <sys/syscall.h>
#include <sys/kdebug.h>

#import "RTSInputConditioner.h"


@interface RTSInputConditioner()

@property (nonatomic, strong) RTSComplexVector *output;
@property (nonatomic) DSPSplitComplex intermediate;
@property (nonatomic) NSUInteger sizeElements;
@property (nonatomic) NSUInteger sizeBytes;

@end

@implementation RTSInputConditioner

- (id)init
{
    return self = [super init];
}

#pragma mark - Properties

- (DSPSplitComplex)intermediate
{
    if(!_intermediate.realp)
    {
        _intermediate.realp = malloc(self.sizeBytes);
    }
    if(!_intermediate.imagp)
    {
        _intermediate.imagp = malloc(self.sizeBytes);
    }
    return _intermediate;
}

- (RTSComplexVector *)output
{
    if(!_output)
    {
        _output = [[RTSComplexVector alloc]
                   initWithSizeElements:self.sizeElements];
    }
    return _output;
}

- (void)setSizeElements:(NSUInteger)sizeElements;
{
    if(_sizeElements != sizeElements)
    {
        _intermediate.realp = NULL;
        _intermediate.imagp = NULL;
        _sizeElements = sizeElements;
    }
}

- (NSUInteger)sizeBytes
{
    return self.sizeElements * sizeof(float);
}

#pragma mark - Conditioner

- (RTSComplexVector *)conditionInput:(NSData *)input
{
    syscall(SYS_kdebug_trace, APPSDBG_CODE(DBG_MACH_CHUD, 5) | DBG_FUNC_START, 0, 0, 0, 0);

    self.sizeElements = [input length] / 2;

    float shiftValue = -127.0f;

    vDSP_vfltu8([input bytes], 2, self.intermediate.realp, 1, self.sizeElements);
    vDSP_vsadd(self.intermediate.realp, 1, &shiftValue, self.output.realp, 1, self.sizeElements);

    vDSP_vfltu8([input bytes] + 1, 2, self.intermediate.imagp, 1, self.sizeElements);
    vDSP_vsadd(self.intermediate.imagp, 1, &shiftValue, self.output.imagp, 1, self.sizeElements);

    syscall(SYS_kdebug_trace, APPSDBG_CODE(DBG_MACH_CHUD, 5) | DBG_FUNC_END, 0, 0, 0, 0);

    return self.output;

}

@end
