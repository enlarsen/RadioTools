//
//  RTSMultiplyAdder.m
//  RadioTools
//
//  Created by Erik Larsen on 12/17/14.
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

#import "RTSMultiplyAdder.h"


@interface RTSMultiplyAdder()

@property (nonatomic, strong) RTSFloatVector *output;
@property (nonatomic) float multiplyer;
@property (nonatomic) float adder;
@property (nonatomic) NSUInteger sizeElements;
@property (nonatomic) NSUInteger sizeBytes;

@end

@implementation RTSMultiplyAdder

- (instancetype)init
{
    self = [self initWithMultiplyFactor:1.0 adder:0.0];
    return self;

}

- (instancetype)initWithMultiplyFactor:(NSInteger)multiplyer adder:(NSInteger)adder
{
    self = [super init];
    if(self)
    {
        _multiplyer = multiplyer;
        _adder = adder;
    }
    return self;
}

#pragma mark - Properties


- (RTSFloatVector *)output
{
    if(!_output)
    {
        _output = [[RTSFloatVector alloc]
                   initWithSizeElements:self.sizeElements];
    }
    return _output;
}

- (void)setSizeElements:(NSUInteger)sizeElements;
{
    if(_sizeElements != sizeElements)
    {
        _sizeElements = sizeElements;
        _output = nil;
    }
}

- (NSUInteger)sizeBytes
{
    return self.sizeElements * sizeof(float);
}

#pragma mark - Conditioner



- (RTSFloatVector *)multiplyAdd:(RTSFloatVector *)input
{
    syscall(SYS_kdebug_trace, APPSDBG_CODE(DBG_MACH_CHUD, 5) | DBG_FUNC_START, 0, 0, 0, 0);

    self.sizeElements = input.sizeElements;

    vDSP_vsmsa(input.vector, 1, &_multiplyer, &_adder, self.output.vector, 1, self.sizeElements);

    syscall(SYS_kdebug_trace, APPSDBG_CODE(DBG_MACH_CHUD, 5) | DBG_FUNC_END, 0, 0, 0, 0);

    return self.output;
    
}


@end
