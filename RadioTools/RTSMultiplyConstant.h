//
//  RTSMultiplyConstant.h
//  RadioTools
//
//  Created by Erik Larsen on 12/23/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTSComplexVector.h"
#import "RTSFloatVector.h"

@interface RTSMultiplyConstant : NSObject

- (RTSComplexVector *)multiplyComplexVectorByConstant:(RTSComplexVector *)input
                                             constant:(float *)constant;

- (RTSFloatVector *)multiplyFloatVectorByConstant:(RTSFloatVector *)input
                                         constant:(float *)constant;
@end
