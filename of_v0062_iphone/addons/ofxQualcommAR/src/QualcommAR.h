//
//  QualcommAR.h
//  qcARTest
//
//  Created by Roger Palà on 01/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//#import <Cocoa/Cocoa.h>


#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#include "ofxiPhone.h"
#import <QCAR/QCAR.h>
#import <QCAR/Tool.h>
#import <QCAR/UIGLViewProtocol.h>
#import "ofMain.h"
#import "ofxiPhoneExtras.h"
#import "ofxQualcommAR.h"
#import "QualcommARTargetInfo.h"

// Application status
typedef enum _status {
    APPSTATUS_UNINITED,
    APPSTATUS_INIT_APP,
    APPSTATUS_INIT_QCAR,
    APPSTATUS_INIT_APP_AR,
    APPSTATUS_INIT_TRACKER,
    APPSTATUS_INITED,
    APPSTATUS_CAMERA_STOPPED,
    APPSTATUS_CAMERA_RUNNING,
    APPSTATUS_ERROR
} status;


class ofxQualcommAR;

@interface QualcommAR : UIView <UIGLViewProtocol> {
	
@public
	
	EAGLContext *context;
    
    // The pixel dimensions of the CAEAGLLayer.
    GLint framebufferWidth;
    GLint framebufferHeight;
    
    // The OpenGL ES names for the framebuffer and renderbuffers used to render
    // to this view.
    GLuint defaultFramebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;
	
	// OpenGL projection matrix
    QCAR::Matrix44F projectionMatrix;
	
	QualcommARTargetInfo targetInfo;
	
	bool isDrawable;
    
    struct tagARData {
        CGRect screenRect;
        NSMutableArray* textures;   // Textures
        int QCARFlags;              // QCAR initialisation flags
        status appStatus;           // Current app status
    } ARData;
	
	ofxQualcommAR * ofxQualcommARPtr;
	
}

- (void)renderFrameQCAR;    // Render frame method called by QCAR
- (void)onCreate;
- (void)onDestroy;
- (void)onResume;
- (void)onPause;

@end
