/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 Ricardo Quesada
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *
 * File autogenerated with Xcode. Adapted for cocos2d needs.
 */

// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.
#import <Availability.h>
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED


#import "../../Support/OpenGL_Internal.h"
#import "ES2Renderer.h"

@implementation ES2Renderer

@synthesize context=context_;

// Create an OpenGL ES 2.0 context
- (id) initWithDepthFormat:(unsigned int)depthFormat withPixelFormat:(unsigned int)pixelFormat withSharegroup:(EAGLSharegroup*)sharegroup withMultiSampling:(BOOL) multiSampling withNumberOfSamples:(unsigned int) requestedSamples
{
    self = [super init];
    if (self)
    {
		if( ! sharegroup )
			context_ = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		else 
			context_ = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:sharegroup];

        if (!context_ || ![EAGLContext setCurrentContext:context_] )
        {
            [self release];
            return nil;
        }

        // Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
        glGenFramebuffers(1, &defaultFramebuffer_);
        glGenRenderbuffers(1, &colorRenderbuffer_);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer_);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer_);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer_);
		
		depthFormat_ = depthFormat;
		
		CHECK_GL_ERROR_DEBUG();
    }

    return self;
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{
    // Allocate color buffer backing based on the current layer size
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer_);

    [context_ renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth_);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight_);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }

	if (depthFormat_) 
	{
		if( ! depthBuffer_ )
			glGenRenderbuffers(1, &depthBuffer_);
	
		glBindRenderbuffer(GL_RENDERBUFFER, depthBuffer_);

		glRenderbufferStorage(GL_RENDERBUFFER, depthFormat_, backingWidth_, backingHeight_);

		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBuffer_);
		
		// bind color buffer
		glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer_);
	}

	CHECK_GL_ERROR_DEBUG();

    return YES;
}

-(CGSize) backingSize
{
	return CGSizeMake( backingWidth_, backingHeight_);
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | size = %ix%i>", [self class], self, backingWidth_, backingHeight_];
}

- (unsigned int) colorRenderBuffer
{
	return colorRenderbuffer_;
}

- (unsigned int) defaultFrameBuffer
{
	return defaultFramebuffer_;
}

- (unsigned int) msaaFrameBuffer
{
	return msaaFramebuffer_;	
}

- (unsigned int) msaaColorBuffer
{
	return msaaColorbuffer_;	
}

- (void)dealloc
{
    // Tear down GL
    if (defaultFramebuffer_) {
        glDeleteFramebuffers(1, &defaultFramebuffer_);
        defaultFramebuffer_ = 0;
    }

    if (colorRenderbuffer_) {
        glDeleteRenderbuffers(1, &colorRenderbuffer_);
        colorRenderbuffer_ = 0;
    }
	
	if( depthBuffer_ ) {
		glDeleteRenderbuffers(1, &depthBuffer_ );
		depthBuffer_ = 0;
	}

    // Tear down context
    if ([EAGLContext currentContext] == context_)
        [EAGLContext setCurrentContext:nil];

    [context_ release];
    context_ = nil;

    [super dealloc];
}

@end

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
