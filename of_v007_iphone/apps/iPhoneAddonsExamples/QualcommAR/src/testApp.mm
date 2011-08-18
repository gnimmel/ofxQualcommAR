#include "testApp.h"


//--------------------------------------------------------------
void testApp::setup(){
    ofSetLogLevel(OF_LOG_VERBOSE);    
	
	ofSetVerticalSync(true);
	
	
	
    
    // we need GL_TEXTURE_2D for our models coords.
    
	
	
	

	bAnimate		= true;
	bAnimateMouse 	= false;
	animationTime	= 0.0;
    
    [ofxiPhoneGetGLView() removeFromSuperview];
	
    
    ofAddListener(qcAR.QCARTargetEvent,this,&testApp::newTargetInfo);
	
    ofEnableAlphaBlending();
	ofBackground(255,0,0, 0);
    
    ofxiPhoneSetGLViewTransparent(true);
    
	qcAR.init();
	
	//note that the resume method should be called always after the view have been added to the main app window
	[ofxiPhoneGetUIWindow() addSubview:qcAR.qualcommAR.view];
	
    //ofxiPhoneSendGLViewToBack();
	qcAR.resume();
}

//--------------------------------------------------------------
//this method will be called everytime QCAR finds a target information
//you need to implement all the rendering here using the QualcommARTargetInfo information
void testApp::newTargetInfo(QualcommARTargetInfo & t){
	//cout << "newTargetInfo  " <<endl;
	
	//glClearColor(200.0, 200.0, 200.0, 0.0);
    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glDisable(GL_TEXTURE_2D);

	
	glPushMatrix();
	
	// Load the projection matrix
	glMatrixMode(GL_PROJECTION);
	glLoadMatrixf(t.projectionMatrix->data);
	//glScalef(1, -1, 1);
	
	
	
	// Load the model-view matrix
	glMatrixMode(GL_MODELVIEW);
	
	glLoadIdentity();
	
	ofEnableLighting();
	light.enable();
	//light.setDirectional();
	
	light.setPosition(50, 50, 50);
	
	//ofFloatColor ambient_color(1.0, 0.0, 0.0, 1.0);
    //light.setAmbientColor(ambient_color);
	light.draw();
	
	glLoadMatrixf(t.modelViewMatrix->data);
	//glTranslatef(0.0f, 0.0f, -kObjectScale);
	
	// this uses depth information for occlusion
	// rather than always drawing things on top of each other
	glEnable(GL_DEPTH_TEST);
	
	
	
	ofPushStyle();
		ofSetColor(255, 255, 255);
		ofBox(0, 0, 0, 40);
	ofPopStyle();
	
	ofDisableLighting();
	light.disable();
	
	glPushMatrix();
	
		glScalef(1, -1, 1);
		ofEnableArbTex();
		ofSetColor(0, 0, 255);
		ofDrawBitmapString("fps: "+ofToString(ofGetFrameRate(), 2), 10, 15);
	
	glPopMatrix();
	
	ofFill();
	
		
	//glEnable(GL_DEPTH);)
	
	
	glDisable(GL_DEPTH_TEST);
	
	//draws a star
	
	/*ofSetPolyMode(OF_POLY_WINDING_NONZERO);
	
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
	
	ofEndShape();*/
	
	glPopMatrix();
}

//--------------------------------------------------------------
void testApp::update(){

	
 

     
}

//--------------------------------------------------------------
void testApp::draw(){
    //glClearColor(200.0, 200.0, 200.0, 0.0);
    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
  /*ofBackground(50, 50, 50, 0);
    ofSetColor(255, 255, 255, 255);
    
	//note we have to enable depth buffer in main.mm
	//see: window->enableDepthBuffer(); in main.mm

	glEnable(GL_DEPTH_TEST);	
    ofPushMatrix();
		ofTranslate(model.getPosition().x, model.getPosition().y, 0);
		ofRotate(-mouseX, 0, 1, 0);
		ofTranslate(-model.getPosition().x, -model.getPosition().y, 0);
    
		model.drawFaces();
    ofPopMatrix();

    ofDrawBitmapString("fps: "+ofToString(ofGetFrameRate(), 2), 10, 15);
    ofDrawBitmapString("fingers 2-5 load models", 10, 30);
    ofDrawBitmapString("num animations for this model: " + ofToString(model.getAnimationCount()), 10, 45);*/

}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs &touch){
	
	/*if( touch.id >= 1 ){
		
		switch (touch.id) {
		
			case 1:
				model.loadModel("dwarf.x");
				model.setPosition(ofGetWidth()/2, (float)ofGetHeight() * 0.75 , 0);
				model.setScale(1.2, 1.2, 1.2);	
				ofDisableSeparateSpecularLight();
				break;
			case 2:
				model.loadModel("TurbochiFromXSI.dae");
				model.setPosition(ofGetWidth()/2, (float)ofGetHeight() * 0.75 , 0);
				model.setRotation(0,90,1,0,0);
				model.setScale(1.2, 1.2, 1.2);
				ofEnableSeparateSpecularLight();
				break;				
			case 3:
				model.loadModel("squirrel/NewSquirrel.3ds");
				model.setPosition(ofGetWidth()/2, (float)ofGetHeight() * 0.75 , 0);
				model.setRotation(0,-90,1,0,0);
				ofDisableSeparateSpecularLight();
				break;
			case 4:
				model.loadModel("astroBoy_walk.dae");
				model.setPosition(ofGetWidth()/2, (float)ofGetHeight() * 0.75 , 0);
				ofEnableSeparateSpecularLight();
				break;
								
			default:
				break;
		}


		mesh = model.getMesh(0);
		position = model.getPosition();
		normScale = model.getNormalizedScale();
		scale = model.getScale();
		sceneCenter = model.getSceneCenter();
		material = model.getMaterialForMesh(0);
		tex = model.getTextureForMesh(0);
	}*/
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
void testApp::touchCancelled(ofTouchEventArgs& args){

}



