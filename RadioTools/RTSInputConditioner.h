//
//  RTSInputConditioner.h
//  RadioTools
//
//  Created by Erik Larsen on 12/16/13.
//  Copyright (c) 2013 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTSComplexVector.h"

@interface RTSInputConditioner : NSObject

- (RTSComplexVector *)conditionInput:(NSData *)input;

@end
