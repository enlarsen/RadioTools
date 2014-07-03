//
//  RTSAddVectors.h
//  RadioTools
//
//  Created by Erik Larsen on 12/22/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTSComplexVector.h"
#import "RTSFloatVector.h"
#import "RTSVectorArithmetic.h"

@interface RTSAddVectors : RTSVectorArithmetic

- (RTSComplexVector *)addComplex:(NSArray *)input;
- (RTSFloatVector *)addFloat:(NSArray *)input;

@end
