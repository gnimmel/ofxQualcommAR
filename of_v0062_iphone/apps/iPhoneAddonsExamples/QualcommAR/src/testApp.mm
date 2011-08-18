#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){	
	// register touch events
	ofRegisterTouchEvents(this);
	
	// initialize the accelerometer
	ofxAccelerometer.setup();
	
	//iPhoneAlerts will be sent to this.
	ofxiPhoneAlerts.addListener(this);
	
	//If you want a landscape oreintation 
	iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
	
	ofAddListener(qcAR.QCARTargetEvent,this,&testApp::newTargetInfo);
	
	ofBackground(255,255,255);
	qcAR.init();
	
	//note that the resume method should be called always after the view have been added to the main app window
	[ofxiPhoneGetUIWindow() addSubview:qcAR.qualcommAR.view];
	ofBackground(255,255,255);
	qcAR.resume();
}

//--------------------------------------------------------------
//this method will be called everytime QCAR finds a target information
//you need to implement all the rendering here using the QualcommARTargetInfo information
void testApp::newTargetInfo(QualcommARTargetInfo & t){
	//cout << "newInt   event:  " + ofToString(i) <<endl;
	
	//glClearColor(200.0, 200.0, 200.0, 0.0);
    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	
	glPushMatrix();
	
	// Load the projection matrix
	glMatrixMode(GL_PROJECTION);
	glLoadMatrixf(t.projectionMatrix->data);
	
	// Load the model-view matrix
	glMatrixMode(GL_MODELVIEW);
	glLoadMatrixf(t.modelViewMatrix->data);                           // Finished Drawing The Triangle*/
	
	
	ofEnableArbTex();
	ofSetColor(0, 0, 255);
	ofFill();
	glDisable(GL_TEXTURE_2D);
	//ofCircle(0, 0, 25);
	
	//draws a star
	
	ofSetPolyMode(OF_POLY_WINDING_NONZERO);
	
	ofBeginShape();
	
	
	
	ofVertex(0,30);
	
	ofVertex(10,10);
	
	ofVertex(30,10);
	
	ofVertex(20,-10);
	
	ofVertex(30,-30);
	
	ofVertex(0,-20);
	
	ofVertex(-30,-30);
	
	ofVertex(-20,-10);
	
	ofVertex(-30,10);
	
	ofVertex(-10,10);
	
	ofEndShape();
	
	glPopMatrix();
}

//--------------------------------------------------------------
void testApp::update(){

}

//--------------------------------------------------------------
void testApp::draw(){
	//if(ofGetElapsedTimeMillis() > 3000)
		//qcAR.draw();
}

//--------------------------------------------------------------
void testApp::exit(){

}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs &touch){

}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs &touch){

}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs &touch){

}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch){

}

//--------------------------------------------------------------
void testApp::lostFocus(){

}

//--------------------------------------------------------------
void testApp::gotFocus(){

}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){

}

