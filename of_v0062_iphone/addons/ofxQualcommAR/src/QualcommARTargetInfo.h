/*
 *  QualcommARTargetInfo.h
 *  QualcommARImageTarget
 *
 *  Created by Roger Palà on 04/08/2011.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#pragma once

#import <QCAR/QCAR.h>
//#import <QCAR/Tool.h>

class QualcommARTargetInfo {
	
public:		
	int targetID;
	QCAR::Matrix44F* modelViewMatrix;
	QCAR::Matrix44F* projectionMatrix;
protected:
	
	
};