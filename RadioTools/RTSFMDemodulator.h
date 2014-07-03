//
//  RTSFMDemodulator.h
//  RadioTools
//
//  Created by Erik Larsen on 12/9/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import "RTSComplexVector.h"
#import "RTSFloatVector.h"

@interface RTSFMDemodulator : NSObject

- (RTSFloatVector *)demodulate:(RTSComplexVector *)input;

@end
