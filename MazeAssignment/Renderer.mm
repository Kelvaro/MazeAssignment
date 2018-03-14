//
//  Copyright © 2017 Borna Noureddin. All rights reserved.
//

#import "Renderer.h"
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#include <chrono>
#include "GLESRenderer.hpp"
#include "maze.h"
// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_MODELVIEW_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_PASSTHROUGH,
    UNIFORM_SHADEINFRAG,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

@interface Renderer () {
    GLKView *theView;
    GLESRenderer glesRenderer;
    GLuint programObject;
    GLuint crateTexture;
    GLuint floorTexture;
    GLuint wallTextureOne, wallTextureTwo, wallTextureThree,wallTextureFour;
    std::chrono::time_point<std::chrono::steady_clock> lastTime;
    GLKMatrix4 mvp, mv, v, p;
    GLKMatrix3 normalMatrix;
    MazeGen *mazegen;
    float *vertices, *normals, *texCoords;
    int *indices, numIndices;
    float *quadVertices, *quadNormals, *quadTexCoords;
    int *quadIndices, quadNumIndices;
}

@end

@implementation Renderer

@synthesize isRotating;
@synthesize rotAngle;

bool isDay, isOn, isFoggy;
char *vShaderStrA, *fShaderStrA, *vShaderStrB, *fShaderStrB, *vShaderStrC, *fShaderStrC,*vShaderStrD,*fShaderStrD, *vShaderStrE,*fShaderStrE;


- (void)dealloc
{
    glDeleteProgram(programObject);
}

- (void)loadModels
{
    numIndices = glesRenderer.GenCube(1.0f, &vertices, &normals, &texCoords, &indices);
    quadNumIndices = glesRenderer.GenQuad(1.0f, &quadVertices, &quadNormals, &quadTexCoords, &quadIndices);
}

- (void)setup:(GLKView *)view
{
    isDay=true;
    isOn=false;
    isFoggy=false;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    mazegen = [[MazeGen alloc] init];
    [mazegen GenMaze:4 cols:4];
    if (!view.context) {
        NSLog(@"Failed to create ES context");
    }
    
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    theView = view;
    [EAGLContext setCurrentContext:view.context];
    if (![self setupShaders])
        return;
    rotAngle = 0.0f;
    isRotating = 1;

    crateTexture = [self setupTexture:@"crate.jpg"];
    floorTexture = [self setupTexture:@"floor.jpg"];
    wallTextureOne=[self setupTexture:@"wall1.jpg"];
    wallTextureTwo=[self setupTexture:@"wall2.jpg"];
    wallTextureThree=[self setupTexture:@"wall3.jpg"];
    wallTextureFour=[self setupTexture:@"wall4.jpg"];

    

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, crateTexture);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);

    glClearColor (1.0f, 1.0f, 1.0f, 1.0f );
    glEnable(GL_DEPTH_TEST);
    lastTime = std::chrono::steady_clock::now();
    
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
}

- (void)update
{
    auto currentTime = std::chrono::steady_clock::now();
    auto elapsedTime = std::chrono::duration_cast<std::chrono::milliseconds>(currentTime - lastTime).count();
    lastTime = currentTime;
    
    if (isRotating)
    {
        rotAngle += 0.001f * elapsedTime;
        if (rotAngle >= 360.0f)
            rotAngle = 0.0f;
    }

//    rotAngle = -1.6;
    // Perspective
    GLKMatrix4 m = GLKMatrix4MakeRotation(rotAngle, 1.0, 0.0, 1.0 );
    
    v = GLKMatrix4Translate(GLKMatrix4Identity, 0.0, 0.0, -5.0);
    
    mv = GLKMatrix4Multiply(v, m);
    
    normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mv), NULL);

    float aspect = (float)theView.drawableWidth / (float)theView.drawableHeight;
    p = GLKMatrix4MakePerspective(60.0f * M_PI / 180.0f, aspect, 1.0f, 20.0f);
    
    mvp = GLKMatrix4Multiply(p, mv);
}

- (void)draw:(CGRect)drawRect;
{
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
    glUniform1i(uniforms[UNIFORM_PASSTHROUGH], false);
    glUniform1i(uniforms[UNIFORM_SHADEINFRAG], true);

    glViewport(0, 0, (int)theView.drawableWidth, (int)theView.drawableHeight);
    glClear ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    glUseProgram ( programObject );
    
    glVertexAttribPointer ( 0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof ( GLfloat ), vertices );
    glEnableVertexAttribArray ( 0 );
    glVertexAttrib4f ( 1, 1.0f, 1.0f, 1.0f, 1.0f );
    
    
    GLKMatrix4 m = GLKMatrix4MakeRotation(rotAngle, 1.0, 0.0, 1.0 );
    mv = GLKMatrix4Multiply(v, m);
    mvp = GLKMatrix4Multiply(p, mv);
    normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mv), NULL);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, FALSE, (const float *)mv.m);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, FALSE, (const float *)mvp.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
    
    glVertexAttribPointer ( 0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof ( GLfloat ), vertices );
    glEnableVertexAttribArray ( 0 );
    glVertexAttribPointer ( 2, 3, GL_FLOAT, GL_FALSE, 3 * sizeof ( GLfloat ), normals );
    glEnableVertexAttribArray ( 2 );
    glVertexAttribPointer ( 3, 2, GL_FLOAT, GL_FALSE, 2 * sizeof ( GLfloat ), texCoords );
    glEnableVertexAttribArray ( 3 );
    
    glDrawElements ( GL_TRIANGLES, numIndices, GL_UNSIGNED_INT, indices );
    
    for (int row = 0; row < 4; row++)
        for (int col = 0; col < 4; col++)
        {
            
           // NSLog(@"drawing at %d %d", row, col);
            
            Cell c = [mazegen GetCell:col col:row];
            
            // floor
            GLKMatrix4 m = GLKMatrix4MakeTranslation(row, 0.0, -col);
            mv = GLKMatrix4Multiply(v, m);
            mvp = GLKMatrix4Multiply(p, mv);
            normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mv), NULL);
            [self drawWall];
            
            // walls
            if (c.N)
            {
                GLKMatrix4 m = GLKMatrix4MakeTranslation(row, 0.0, -col);
                m = GLKMatrix4RotateX(m, M_PI/2);
                mv = GLKMatrix4Multiply(v, m);
                mvp = GLKMatrix4Multiply(p, mv);
                normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mv), NULL);
                [self drawWall];
            }
            if (c.S)
            {
                GLKMatrix4 m = GLKMatrix4MakeTranslation(row, 0.0, -col);
                m = GLKMatrix4RotateX(m, M_PI/-2);
                mv = GLKMatrix4Multiply(v, m);
                mvp = GLKMatrix4Multiply(p, mv);
                normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mv), NULL);
                [self drawWall];
            }
            if (c.W)
            {
                GLKMatrix4 m = GLKMatrix4MakeTranslation(row, 0.0, -col);
                m = GLKMatrix4RotateZ(m, M_PI/-2);
                mv = GLKMatrix4Multiply(v, m);
                mvp = GLKMatrix4Multiply(p, mv);
                normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mv), NULL);
                [self drawWall];
            }
            if (c.E)
            {
                GLKMatrix4 m = GLKMatrix4MakeTranslation(row, 0.0, -col);
                m = GLKMatrix4RotateZ(m, M_PI/2);
                mv = GLKMatrix4Multiply(v, m);
                mvp = GLKMatrix4Multiply(p, mv);
                normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mv), NULL);
                [self drawWall];
            }
            
        }
}

-(void) drawWall{
    glVertexAttrib4f ( 1, 1.0f, 1.0f, 1.0f, 1.0f );
    glVertexAttribPointer ( 0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof ( GLfloat ), quadVertices );
    glEnableVertexAttribArray ( 0 );
    glVertexAttribPointer ( 2, 3, GL_FLOAT, GL_FALSE, 3 * sizeof ( GLfloat ), quadNormals );
    glEnableVertexAttribArray ( 2 );
    glVertexAttribPointer ( 3, 2, GL_FLOAT, GL_FALSE, 2 * sizeof ( GLfloat ), quadTexCoords );
    glEnableVertexAttribArray ( 3 );
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, FALSE, (const float *)mvp.m);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, FALSE, (const float *)mv.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
    
    glDrawElements ( GL_TRIANGLES, quadNumIndices, GL_UNSIGNED_INT, quadIndices );
    
    
}

- (bool)setupShaders
{
    // Load shaders
    vShaderStrA = glesRenderer.LoadShaderFile([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"Shader.vsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"Shader.vsh"] pathExtension]] cStringUsingEncoding:1]);
    fShaderStrA = glesRenderer.LoadShaderFile([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"Shader.fsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"Shader.fsh"] pathExtension]] cStringUsingEncoding:1]);
            programObject = glesRenderer.LoadProgram(vShaderStrA, fShaderStrA);
    
    vShaderStrB = glesRenderer.LoadShaderFile([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"ShaderB.vsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"ShaderB.vsh"] pathExtension]] cStringUsingEncoding:1]);
    fShaderStrB = glesRenderer.LoadShaderFile([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"ShaderB.fsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"ShaderB.fsh"] pathExtension]] cStringUsingEncoding:1]);

    vShaderStrC = glesRenderer.LoadShaderFile([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"ShaderC.vsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"ShaderC.vsh"] pathExtension]] cStringUsingEncoding:1]);
    fShaderStrC = glesRenderer.LoadShaderFile([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"ShaderC.fsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"ShaderC.fsh"] pathExtension]] cStringUsingEncoding:1]);
    
    
    vShaderStrD = glesRenderer.LoadShaderFile([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"ShaderD.vsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"ShaderD.vsh"] pathExtension]] cStringUsingEncoding:1]);
    fShaderStrD = glesRenderer.LoadShaderFile([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"ShaderD.fsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"ShaderD.fsh"] pathExtension]] cStringUsingEncoding:1]);
    
    vShaderStrE = glesRenderer.LoadShaderFile([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"ShaderE.vsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"ShaderE.vsh"] pathExtension]] cStringUsingEncoding:1]);
    fShaderStrE = glesRenderer.LoadShaderFile([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"ShaderE.fsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"ShaderE.fsh"] pathExtension]] cStringUsingEncoding:1]);
    
    programObject = glesRenderer.LoadProgram(vShaderStrA, fShaderStrA);
    
    
    if (programObject == 0)
        return false;
    
    // Set up uniform variables
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(programObject, "modelViewProjectionMatrix");
    uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(programObject, "modelViewMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(programObject, "normalMatrix");
    uniforms[UNIFORM_PASSTHROUGH] = glGetUniformLocation(programObject, "passThrough");
    uniforms[UNIFORM_SHADEINFRAG] = glGetUniformLocation(programObject, "shadeInFrag");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(programObject, "texSampler");

    return true;
}

- (void)DayNightToggle{
    if(isDay){
        programObject = glesRenderer.LoadProgram(vShaderStrB, fShaderStrB);
        glClearColor (0.2f, 0.2f, 0.2f, 0.2f );
        isDay=false;
    }
    else{
        programObject = glesRenderer.LoadProgram(vShaderStrA, fShaderStrA);
        glClearColor (1.0f, 1.0f, 1.0f, 1.0f );
        isDay=true;
    }
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(programObject, "modelViewProjectionMatrix");
    uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(programObject, "modelViewMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(programObject, "normalMatrix");
    uniforms[UNIFORM_PASSTHROUGH] = glGetUniformLocation(programObject, "passThrough");
    uniforms[UNIFORM_SHADEINFRAG] = glGetUniformLocation(programObject, "shadeInFrag");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(programObject, "texSampler");

}

-(void)FlashlightToggle{
    if(isOn){
        programObject = glesRenderer.LoadProgram(vShaderStrA, fShaderStrA);
        glClearColor (1.0f, 1.0f, 1.0f, 1.0f );
        isOn=false;
    }
    else{
        programObject = glesRenderer.LoadProgram(vShaderStrC, fShaderStrC);
        glClearColor (0.2f, 0.2f, 0.2f, 0.2f );
        isOn=true;
    }
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(programObject, "modelViewProjectionMatrix");
    uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(programObject, "modelViewMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(programObject, "normalMatrix");
    uniforms[UNIFORM_PASSTHROUGH] = glGetUniformLocation(programObject, "passThrough");
    uniforms[UNIFORM_SHADEINFRAG] = glGetUniformLocation(programObject, "shadeInFrag");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(programObject, "texSampler");
}

-(void)FogToggle:(char)para{
    if(isFoggy){
        programObject = glesRenderer.LoadProgram(vShaderStrA, fShaderStrA);
        glClearColor (1.0f, 1.0f, 1.0f, 1.0f );
        isFoggy=false;
    }
    else{
        if(para=='D'){
          programObject = glesRenderer.LoadProgram(vShaderStrD, fShaderStrD);
        }
        else if(para=='E'){
         programObject = glesRenderer.LoadProgram(vShaderStrE, fShaderStrE);
        }

        glClearColor (0.5f, 0.5f, 0.5f, 0.5f );
        isFoggy=true;
    }
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(programObject, "modelViewProjectionMatrix");
    uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(programObject, "modelViewMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(programObject, "normalMatrix");
    uniforms[UNIFORM_PASSTHROUGH] = glGetUniformLocation(programObject, "passThrough");
    uniforms[UNIFORM_SHADEINFRAG] = glGetUniformLocation(programObject, "shadeInFrag");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(programObject, "texSampler");
}

// Load in and set up texture image (adapted from Ray Wenderlich)
- (GLuint)setupTexture:(NSString *)fileName
{
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte *spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    return texName;
}

@end

