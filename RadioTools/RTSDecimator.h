//
//  RTSDecimator.h
//  RadioTools
//
//  Created by Erik Larsen on 12/9/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTSComplexVector.h"
#import "RTSFloatVector.h"

@interface RTSDecimator : NSObject

- (id)initWithFactor:(int)factor;

- (RTSComplexVector *)decimateComplex:(RTSComplexVector *)input;
- (RTSFloatVector *)decimateFloat:(RTSFloatVector *)input;


@end
