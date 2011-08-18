//
//  QualcommAR.mm
//  qcARTest
//
//  Created by Roger Palà on 01/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QualcommAR.h"


#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <QCAR/QCAR.h>
#import <QCAR/Tracker.h>
#import <QCAR/CameraDevice.h>
#import <QCAR/VideoBackgroundConfig.h>
#import <QCAR/Renderer.h>
#import <QCAR/Tool.h>
#import <QCAR/Trackable.h>
#import <QCAR/UpdateCallback.h>
#import <QCAR/Marker.h>
#import <QCAR/UIGLViewProtocol.h>


@interface QualcommAR (PrivateMethods)
- (void)setFramebuffer;
- (BOOL)presentFramebuffer;
- (void)createFramebuffer;
- (void)deleteFramebuffer;
- (int)loadTextures;
- (void)updateApplicationStatus:(status)newStatus;
- (void)bumpAppStatus;
- (void)initApplication;
- (void)initQCAR;
- (void)initApplicationAR;
- (void)loadTracker;
- (void)startCamera;
- (void)stopCamera;
- (void)configureVideoBackground;
- (void)initRendering;
@end

@implementation QualcommAR


// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
	if (self) {
        
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        ARData.QCARFlags = QCAR::GL_11;
		
		isDrawable = false;
		
        //RData.QCARFlags = QCAR::GL_11;
        
        NSLog(@"QCAR OpenGL flag: %d", ARData.QCARFlags);
        
		if (!context) {
            NSLog(@"Failed to create ES context");
        }
		
    }
    
    return self;
}

- (void)dealloc
{
    
	[self deleteFramebuffer];
    
    // Tear down context
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];
    [super dealloc];
}

- (void)createFramebuffer
{
	
    if (context && !defaultFramebuffer) {
        [EAGLContext setCurrentContext:context];
        
        // Create default framebuffer object
        glGenFramebuffersOES(1, &defaultFramebuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
        
        // Create colour renderbuffer and allocate backing store
        glGenRenderbuffersOES(1, &colorRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
        
        // Allocate the renderbuffer's storage (shared with the drawable object)
        [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
        glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &framebufferWidth);
        glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &framebufferHeight);
        
        // Create the depth render buffer and allocate storage
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, framebufferWidth, framebufferHeight);
        
        // Attach colour and depth render buffers to the frame buffer
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
        
        // Leave the colour render buffer bound so future rendering operations will act on it
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    }
	
}

- (void)deleteFramebuffer
{
    if (context) {
        [EAGLContext setCurrentContext:context];
        
		
        if (defaultFramebuffer) {
            glDeleteFramebuffersOES(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer) {
            glDeleteRenderbuffersOES(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
        
        if (depthRenderbuffer) {
            glDeleteRenderbuffersOES(1, &depthRenderbuffer);
            depthRenderbuffer = 0;
        }
		
    }
}

- (void)setFramebuffer
{
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (!defaultFramebuffer) {
            // Perform on the main thread to ensure safe memory allocation for
            // the shared buffer.  Block until the operation is complete to
            // prevent simultaneous access to the OpenGL context
            [self performSelectorOnMainThread:@selector(createFramebuffer) withObject:self waitUntilDone:YES];
        }
        
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    }
}

- (BOOL)presentFramebuffer
{
    BOOL success = FALSE;
    
    if (context) {
        [EAGLContext setCurrentContext:context];
        
		
        glBindRenderbufferOES(GL_FRAMEBUFFER_OES, colorRenderbuffer);
        
        success = [context presentRenderbuffer:GL_FRAMEBUFFER_OES];
    }
    
    return success;
}

- (void)layoutSubviews
{
    // The framebuffer will be re-created at the beginning of the next setFramebuffer method call.
    [self deleteFramebuffer];
}

////////////////////////////////////////////////////////////////////////////////
- (void)onCreate
{
    NSLog(@"QualcommAR onCreate()");
    ARData.appStatus = APPSTATUS_UNINITED;
    
    
	[self updateApplicationStatus:APPSTATUS_INIT_APP];
    
}

////////////////////////////////////////////////////////////////////////////////
- (void)onDestroy
{
    NSLog(@"QualcommAR onDestroy()");
    
    
    // Deinitialise QCAR SDK
    QCAR::deinit();
}


////////////////////////////////////////////////////////////////////////////////
- (void)onResume
{
    NSLog(@"QualcommAR onResume()");
    // QCAR-specific resume operation
    QCAR::onResume();
    
    if (APPSTATUS_CAMERA_STOPPED == ARData.appStatus) {
        [self updateApplicationStatus:APPSTATUS_CAMERA_RUNNING];
    }
}


////////////////////////////////////////////////////////////////////////////////
- (void)onPause
{
    NSLog(@"QualcommAR onPause()");
    // QCAR-specific pause operation
    QCAR::onPause();
    
    if (APPSTATUS_CAMERA_RUNNING == ARData.appStatus) {
        [self updateApplicationStatus:APPSTATUS_CAMERA_STOPPED];
    }
}

////////////////////////////////////////////////////////////////////////////////
- (void)updateApplicationStatus:(status)newStatus
{
    if (newStatus != ARData.appStatus && APPSTATUS_ERROR != ARData.appStatus) {
        ARData.appStatus = newStatus;
        NSLog(@"New status: %d", newStatus);
        switch (ARData.appStatus) {
            case APPSTATUS_INIT_APP:
                // Initialise the application
                [self initApplication];
                [self updateApplicationStatus:APPSTATUS_INIT_QCAR];
                break;
                
            case APPSTATUS_INIT_QCAR:
                // Initialise QCAR
                [self performSelectorInBackground:@selector(initQCAR) withObject:nil];
                break;
                
            case APPSTATUS_INIT_APP_AR:
                // AR-specific initialisation
                [self initApplicationAR];
                [self updateApplicationStatus:APPSTATUS_INIT_TRACKER];
                break;
                
            case APPSTATUS_INIT_TRACKER:
                // Load tracker data
                [self performSelectorInBackground:@selector(loadTracker) withObject:nil];
                break;
                
            case APPSTATUS_INITED:
                // Here we could make QCAR::setHint calls to set the maximum
                // number of simultaneous targets and split work over multiple
                // frames
                [self updateApplicationStatus:APPSTATUS_CAMERA_RUNNING];
                break;
                
            case APPSTATUS_CAMERA_RUNNING:
                [self startCamera];
                break;
                
            case APPSTATUS_CAMERA_STOPPED:
                [self stopCamera];
                break;
                
            default:
                NSLog(@"updateApplicationStatus: invalid app status");
                break;
        }
    }
    
    if (APPSTATUS_ERROR == ARData.appStatus) {
        // Application initialisation failed, display an alert view
		NSLog(@"QualcommAR INIT FAILED!");
		
    }
}

////////////////////////////////////////////////////////////////////////////////
// Bump the application status on one step
- (void)bumpAppStatus
{
    [self updateApplicationStatus:(status)(ARData.appStatus + 1)];
}


////////////////////////////////////////////////////////////////////////////////
// Initialise the application
- (void)initApplication
{
    NSLog(@"initApplication");
	
	//[[UIDevice currentDevice] setOrientation:UIInterfaceOrientationLandscapeRight];
	
	// Get the device screen dimensions
    ARData.screenRect = [[UIScreen mainScreen] bounds];
    
    // Inform QCAR that the drawing surface has been created
    QCAR::onSurfaceCreated();
    
	//ARData.screenRect.size.width = 480;
	//ARData.screenRect.size.height = 320;
	
	cout << "ARData.screenRect.origin.x: " << ARData.screenRect.origin.x << endl;
	cout << "ARData.screenRect.origin.y: " << ARData.screenRect.origin.y << endl;
	cout << "ARData.screenRect.size.width: " << ARData.screenRect.size.width << endl;
	cout << "ARData.screenRect.size.height: " << ARData.screenRect.size.height<< endl;
	
	
    // Inform QCAR that the drawing surface size has changed
    QCAR::onSurfaceChanged(ARData.screenRect.size.height, ARData.screenRect.size.width);
}


////////////////////////////////////////////////////////////////////////////////
// Initialise QCAR [performed on a background thread]
- (void)initQCAR
{
    NSLog(@"initQCAR");
	// Background thread must have its own autorelease pool
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    QCAR::setInitParameters(ARData.QCARFlags);
    
    int nPercentComplete = 0;
    
    do {
        nPercentComplete = QCAR::init();
    } while (0 <= nPercentComplete && 100 > nPercentComplete);
    
    NSLog(@"QCAR::init percent: %d", nPercentComplete);
    
    if (0 > nPercentComplete) {
        ARData.appStatus = APPSTATUS_ERROR;
    }
	
    // Continue execution on the main thread
    [self performSelectorOnMainThread:@selector(bumpAppStatus) withObject:nil waitUntilDone:NO];
    
    [pool release];
    
    if (0 > nPercentComplete) {
        ARData.appStatus = APPSTATUS_ERROR;
    }
}

////////////////////////////////////////////////////////////////////////////////
// Initialise the AR parts of the application
- (void)initApplicationAR
{
    // Initialise rendering
    [self initRendering];
}


////////////////////////////////////////////////////////////////////////////////
// Load the tracker data [performed on a background thread]
- (void)loadTracker
{
    NSLog(@"loadTracker");
	int nPercentComplete = 0;
	
    // Background thread must have its own autorelease pool
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
    // Load the tracker data
    do {
        nPercentComplete = QCAR::Tracker::getInstance().load();
    } while (0 <= nPercentComplete && 100 > nPercentComplete);
	
    if (0 > nPercentComplete) {
        ARData.appStatus = APPSTATUS_ERROR;
    }
    
    // Continue execution on the main thread
    [self performSelectorOnMainThread:@selector(bumpAppStatus) withObject:nil waitUntilDone:NO];
    
    [pool release];
}


////////////////////////////////////////////////////////////////////////////////
// Start capturing images from the camera
- (void)startCamera
{
    NSLog(@"startCamera");
	// Initialise the camera
    if (QCAR::CameraDevice::getInstance().init()) {
        // Configure video background
        [self configureVideoBackground];
        
        // Select the default mode
        if (QCAR::CameraDevice::getInstance().selectVideoMode(QCAR::CameraDevice::MODE_DEFAULT)) {
            // Start camera capturing
            if (QCAR::CameraDevice::getInstance().start()) {
                // Start the tracker
                QCAR::Tracker::getInstance().start();
                
                // Cache the projection matrix
                const QCAR::CameraCalibration& cameraCalibration = QCAR::Tracker::getInstance().getCameraCalibration();
                projectionMatrix = QCAR::Tool::getProjectionGL(cameraCalibration, 2.0f, 2000.0f);
				//ofxQualcommARPtr->projectionMatrix = &projectionMatrix;
				targetInfo.projectionMatrix = &projectionMatrix;
            }
        }
		
		isDrawable = true;
    }
	
	
}


////////////////////////////////////////////////////////////////////////////////
// Stop capturing images from the camera
- (void)stopCamera
{
    NSLog(@"stopCamera");
	isDrawable = false;
	QCAR::Tracker::getInstance().stop();
    QCAR::CameraDevice::getInstance().stop();
    QCAR::CameraDevice::getInstance().deinit();
}


////////////////////////////////////////////////////////////////////////////////
// Configure the video background
- (void)configureVideoBackground
{
	NSLog(@"configureVideoBackground");
	
	// Get the default video mode
    QCAR::CameraDevice& cameraDevice = QCAR::CameraDevice::getInstance();
    QCAR::VideoMode videoMode = cameraDevice.getVideoMode(QCAR::CameraDevice::MODE_DEFAULT);
    
    // Configure the video background
    QCAR::VideoBackgroundConfig config;
    config.mEnabled = true;
    config.mSynchronous = true;
    config.mPosition.data[0] = 0.0f;
    config.mPosition.data[1] = 0.0f;
    
    // Compare aspect ratios of video and screen.  If they are different
    // we use the full screen size while maintaining the video's aspect
    // ratio, which naturally entails some cropping of the video.
    // Note - screenRect is portrait but videoMode is always landscape,
    // which is why "width" and "height" appear to be reversed.
    float arVideo = (float)videoMode.mWidth / (float)videoMode.mHeight;
    float arScreen = ARData.screenRect.size.height / ARData.screenRect.size.width;
    
    if (arVideo > arScreen)
    {
        // Video mode is wider than the screen.  We'll crop the left and right edges of the video
        config.mSize.data[0] = (int)ARData.screenRect.size.width * arVideo;
        config.mSize.data[1] = (int)ARData.screenRect.size.width;
    }
    else
    {
        // Video mode is taller than the screen.  We'll crop the top and bottom edges of the video.
        // Also used when aspect ratios match (no cropping).
        config.mSize.data[0] = (int)ARData.screenRect.size.height;
        config.mSize.data[1] = (int)ARData.screenRect.size.height / arVideo;
    }
	
	
    
    // Set the config
    QCAR::Renderer::getInstance().setVideoBackgroundConfig(config);
}

////////////////////////////////////////////////////////////////////////////////
// Initialise OpenGL rendering
- (void)initRendering
{
    glClearColor(0.0f, 0.0f, 0.0f, QCAR::requiresAlpha() ? 0.0f : 1.0f);
	
	
	
	/*
	 // Define the clear colour
	 glClearColor(0.0f, 0.0f, 0.0f, QCAR::requiresAlpha() ? 0.0f : 1.0f);
	 
	 // Generate the OpenGL texture objects
	 for (int i = 0; i < [ARData.textures count]; ++i) {
	 GLuint nID;
	 Texture* texture = [ARData.textures objectAtIndex:i];
	 glGenTextures(1, &nID);
	 [texture setTextureID: nID];
	 glBindTexture(GL_TEXTURE_2D, nID);
	 glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	 glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	 glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [texture width], [texture height], 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)[texture pngData]);
	 }
	 
	 // OpenGL 2 initialisation
	 shaderProgramID = ShaderUtils::createProgramFromBuffer(vertexShader, fragmentShader);
	 vertexHandle = glGetAttribLocation(shaderProgramID, "vertexPosition");
	 normalHandle = glGetAttribLocation(shaderProgramID, "vertexNormal");
	 textureCoordHandle = glGetAttribLocation(shaderProgramID, "vertexTexCoord");
	 mvpMatrixHandle = glGetUniformLocation(shaderProgramID, "modelViewProjectionMatrix");*/
}



////////////////////////////////////////////////////////////////////////////////
// Draw the current frame using OpenGL
//
// This method is called by QCAR when it wishes to render the current frame to
// the screen.
//
// *** QCAR will call this method on a single background thread ***

- (void)renderFrameQCAR
{
	//cout << "renderFrameQCAR " << endl;
	//cout << "drawing" << endl;
	
	ofxiPhoneLockGLContext();
	[self setFramebuffer];
	
	
	// Clear colour and depth buffers
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glDisable(GL_TEXTURE_2D);
	
	
	// Render video background and retrieve tracking state
	QCAR::State state = QCAR::Renderer::getInstance().begin();
	
	
	//NSLog(@"active trackables: %d", state.getNumActiveTrackables());
	
	if (QCAR::GL_11 & ARData.QCARFlags) {
		//glEnable(GL_TEXTURE_2D);
		//glDisable(GL_LIGHTING);
		//glEnableClientState(GL_VERTEX_ARRAY);
		//glEnableClientState(GL_NORMAL_ARRAY);
		//glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	}
	
	//glEnable(GL_DEPTH_TEST);
	//glEnable(GL_CULL_FACE);
	
	
	
	for(int i = 0; i < state.getNumActiveTrackables(); ++i) {
		
		
		// Get the trackable
		const QCAR::Trackable* trackable = state.getActiveTrackable(i);
		QCAR::Matrix44F modelViewMatrix = QCAR::Tool::convertPose2GLMatrix(trackable->getPose());        
		
		// Check the type of the trackable:
		//assert(trackable->getType() == QCAR::Trackable::MARKER);
		const QCAR::Marker* marker = static_cast<const QCAR::Marker*>(trackable);
		
		// Choose the texture based on the marker ID
		int textureIndex = marker->getMarkerId();
		
		
		targetInfo.targetID = textureIndex;
		targetInfo.modelViewMatrix = &modelViewMatrix;
		
		
		ofxQualcommARPtr->drawTrackable(targetInfo);
		
		
		
	}
	
	/*glDisable(GL_DEPTH_TEST);
	 glDisable(GL_CULL_FACE);
	 
	 if (QCAR::GL_11 & ARData.QCARFlags) {
	 glDisable(GL_TEXTURE_2D);
	 glDisableClientState(GL_VERTEX_ARRAY);
	 glDisableClientState(GL_NORMAL_ARRAY);
	 glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	 }*/
	
	
	
	QCAR::Renderer::getInstance().end();
	
	
	[self presentFramebuffer];
	
	ofxiPhoneUnlockGLContext();
	
	/*if (APPSTATUS_CAMERA_RUNNING == ARData.appStatus) {
        //[self setFramebuffer];
		//        
		//        // Clear colour and depth buffers
		//        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        // Render video background and retrieve tracking state
        QCAR::State state = QCAR::Renderer::getInstance().begin();
        //NSLog(@"active trackables: %d", state.getNumActiveTrackables());
        
        //glEnable(GL_DEPTH_TEST);
		//        glEnable(GL_CULL_FACE);
        
        // Did we find any trackables this frame?
        for(int i = 0; i < state.getNumActiveTrackables(); ++i) {
            // Get the trackable
            const QCAR::Trackable* trackable = state.getActiveTrackable(i);
            QCAR::Matrix44F modelViewMatrix = QCAR::Tool::convertPose2GLMatrix(trackable->getPose());        
            
            // Check the type of the trackable:
            assert(trackable->getType() == QCAR::Trackable::MARKER);
            const QCAR::Marker* marker = static_cast<const QCAR::Marker*>(trackable);
            
            // Choose the texture based on the marker ID
            int textureIndex = marker->getMarkerId();
			
			cout << "marker id: " << textureIndex << endl;
			
            //assert(textureIndex < [ARData.textures count]);
			//            const Texture* const thisTexture = [ARData.textures objectAtIndex:textureIndex];
			//            
			//            const GLvoid* vertices = 0;
			//            const GLvoid* normals = 0;
			//            const GLvoid* indices = 0;
			//            const GLvoid* texCoords = 0;
			//            int numIndices = 0;
			//            
			//            // Select which model to draw
			//            switch (marker->getMarkerId()) {
			//                case 0:
			//                    vertices = &QobjectVertices[0];
			//                    normals = &QobjectNormals[0];
			//                    indices = &QobjectIndices[0];
			//                    texCoords = &QobjectTexCoords[0];
			//                    numIndices = NUM_Q_OBJECT_INDEX;
			//                    break;
			//                case 1:
			//                    vertices = &CobjectVertices[0];
			//                    normals = &CobjectNormals[0];
			//                    indices = &CobjectIndices[0];
			//                    texCoords = &CobjectTexCoords[0];
			//                    numIndices = NUM_C_OBJECT_INDEX;
			//                    break;
			//                case 2:
			//                    vertices = &AobjectVertices[0];
			//                    normals = &AobjectNormals[0];
			//                    indices = &AobjectIndices[0];
			//                    texCoords = &AobjectTexCoords[0];
			//                    numIndices = NUM_A_OBJECT_INDEX;
			//                    break;
			//                default:
			//                    vertices = &RobjectVertices[0];
			//                    normals = &RobjectNormals[0];
			//                    indices = &RobjectIndices[0];
			//                    texCoords = &RobjectTexCoords[0];
			//                    numIndices = NUM_R_OBJECT_INDEX;
			//                    break;
			//            }
			//            
			//            // Render with OpenGL 2
			//            QCAR::Matrix44F modelViewProjection;
			//            ShaderUtils::translatePoseMatrix(-kLetterTranslate, -kLetterTranslate, 0.f, &modelViewMatrix.data[0]);
			//            ShaderUtils::scalePoseMatrix(kLetterScale, kLetterScale, kLetterScale, &modelViewMatrix.data[0]);
			//            ShaderUtils::multiplyMatrix(&projectionMatrix.data[0], &modelViewMatrix.data[0], &modelViewProjection.data[0]);
			//            
			//            glUseProgram(shaderProgramID);
			//            
			//            glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, vertices);
			//            glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, normals);
			//            glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
			//            
			//            glEnableVertexAttribArray(vertexHandle);
			//            glEnableVertexAttribArray(normalHandle);
			//            glEnableVertexAttribArray(textureCoordHandle);
			//            
			//            glActiveTexture(GL_TEXTURE0);
			//            glBindTexture(GL_TEXTURE_2D, [thisTexture textureID]);
			//            glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (GLfloat*)&modelViewProjection.data[0]);
			//            glDrawElements(GL_TRIANGLES, numIndices, GL_UNSIGNED_SHORT, indices);
			//            
			//            ShaderUtils::checkGlError("FrameMarkers renderFrameQCAR");
        }
        
		// glDisable(GL_DEPTH_TEST);
		//        glDisable(GL_CULL_FACE);
		//        glDisableVertexAttribArray(vertexHandle);
		//        glDisableVertexAttribArray(normalHandle);
		//        glDisableVertexAttribArray(textureCoordHandle);
        
        QCAR::Renderer::getInstance().end();
        
    }*/
	
}
@end