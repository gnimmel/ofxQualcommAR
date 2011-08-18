/*
 *  ofxQualcommAR.h
 *  qcARTest
 *
 *  Created by Roger Palà on 28/07/2011.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */


#pragma once

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#include "ofxiPhone.h"
#import <QCAR/QCAR.h>
#import <QCAR/Tool.h>
#import <QCAR/UIGLViewProtocol.h>
#import "ofMain.h"
#import "QualcommARViewController.h"
#import "QualcommAR.h"
#include "ofEvents.h"
#include "QualcommARTargetInfo.h"

class ofxQualcommAR {//: public ofBaseHasPixels, ofBaseDraws{
	
public:		
	ofxQualcommAR();
	~ofxQualcommAR();
	
	void init();
	void pause();
	void resume();
	void drawTrackable(QualcommARTargetInfo &targetInfo);
	
	
	ofEvent<QualcommARTargetInfo> QCARTargetEvent;
	
	QualcommARViewController * qualcommAR;
	
protected:
	
	
};



