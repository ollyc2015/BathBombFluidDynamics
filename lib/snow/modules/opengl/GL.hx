package snow.modules.opengl;


//Platform defines

#if snow_web

    typedef GL                  = snow.modules.opengl.web.GL;
    typedef GLActiveInfo        = snow.modules.opengl.web.GL.GLActiveInfo;
    typedef GLBuffer            = snow.modules.opengl.web.GL.GLBuffer;
    typedef GLContextAttributes = snow.modules.opengl.web.GL.GLContextAttributes;
    typedef GLFramebuffer       = snow.modules.opengl.web.GL.GLFramebuffer;
    typedef GLProgram           = snow.modules.opengl.web.GL.GLProgram;
    typedef GLRenderbuffer      = snow.modules.opengl.web.GL.GLRenderbuffer;
    typedef GLShader            = snow.modules.opengl.web.GL.GLShader;
    typedef GLTexture           = snow.modules.opengl.web.GL.GLTexture;
    typedef GLUniformLocation   = snow.modules.opengl.web.GL.GLUniformLocation;

#else

    typedef GL                  = snow.modules.opengl.native.GL;
    typedef GLActiveInfo        = snow.modules.opengl.native.GL.GLActiveInfo;
    typedef GLBuffer            = snow.modules.opengl.native.GL.GLBuffer;
    typedef GLContextAttributes = snow.modules.opengl.native.GL.GLContextAttributes;
    typedef GLFramebuffer       = snow.modules.opengl.native.GL.GLFramebuffer;
    typedef GLProgram           = snow.modules.opengl.native.GL.GLProgram;
    typedef GLRenderbuffer      = snow.modules.opengl.native.GL.GLRenderbuffer;
    typedef GLShader            = snow.modules.opengl.native.GL.GLShader;
    typedef GLTexture           = snow.modules.opengl.native.GL.GLTexture;
    typedef GLUniformLocation   = snow.modules.opengl.native.GL.GLUniformLocation;


        //:todo: this isn't current, so defining this will just break things
    #if snow_render_gl_native
        typedef GLLink              = snow.modules.opengl.native.GL_Native.GLLink;
    #end


#end //!snow_web
