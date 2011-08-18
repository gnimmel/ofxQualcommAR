/*
 *  ofxQualcommAR.cpp
 *  qcARTest
 *
 *  Created by Roger Palà on 28/07/2011.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "ofxQualcommAR.h"



ofxQualcommAR::ofxQualcommAR()
{
	cout << "ofxQualcommAR::ofxQualcommAR()" << endl;
}

ofxQualcommAR::~ofxQualcommAR()
{
	cout << "ofxQualcommAR::~ofxQualcommAR()" << endl;
	// AR-specific actions
    [(QualcommAR*)qualcommAR.view onDestroy];
	[qualcommAR release];
}

void ofxQualcommAR::init()
{
	cout << "ofxQualcommAR::init()" << endl;
	//CGRect screenBounds = [[UIScreen mainScreen] bounds];
    //qualcommAR = [[QualcommAR alloc] initWithFrame: screenBounds];
	
	qualcommAR	= [[QualcommARViewController alloc] init];
	//[ofxiPhoneGetUIWindow() addSubview:qualcommAR.view];
	
	
	((QualcommAR*)qualcommAR.view)->ofxQualcommARPtr = this;
	[(QualcommAR*)qualcommAR.view onCreate];
}

void ofxQualcommAR::pause()
{
	[(QualcommAR*)qualcommAR.view onPause];
}

void ofxQualcommAR::drawTrackable(QualcommARTargetInfo &targetInfo)
{
	//cout << "marker id: " << textureIndex << endl;
	
	
	
	ofNotifyEvent(QCARTargetEvent,targetInfo,this);
	

}

void ofxQualcommAR::resume()
{
	[(QualcommAR*)qualcommAR.view onResume];
}
