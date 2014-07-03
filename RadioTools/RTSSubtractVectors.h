//
//  RTSSubtractVectors.h
//  RadioTools
//
//  Created by Erik Larsen on 12/23/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTSComplexVector.h"
#import "RTSFloatVector.h"
#import "RTSVectorArithmetic.h"

@interface RTSSubtractVectors : RTSVectorArithmetic

- (RTSComplexVector *)subtractComplex:(NSArray *)input;
- (RTSFloatVector *)subtractFloat:(NSArray *)input;

@end
