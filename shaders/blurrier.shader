#version 130

uniform sampler2D palettetex;
uniform sampler2D framebuf;
uniform vec2 screensize;

varying vec2 screencoords;
varying vec2 ratio;

varying vec2 blurcoords[25];

#if COMPILING_VERTEX_PROGRAM

    void vert(){
        gl_FrontColor = vec4(1,1,1,1);
        gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

        screencoords = (gl_Position.xy+vec2(1, 1))*.5;

        float scale_x = screensize.x / 1280.0;
        float scale_y = screensize.y / 720.0;
        float scale_min = min(scale_x, scale_y);
        ratio = vec2(scale_min / scale_x, scale_min / scale_y);
        ratio.y *= (1280.0/720.0);

        blurcoords[0] = screencoords.xy + vec2(-2,-2) * ratio * .0007;
        blurcoords[1] = screencoords.xy + vec2(-1,-2) * ratio * .0007;
        blurcoords[2] = screencoords.xy + vec2( 0,-2) * ratio * .0007;
        blurcoords[3] = screencoords.xy + vec2( 1,-2) * ratio * .0007;
        blurcoords[4] = screencoords.xy + vec2( 2,-2) * ratio * .0007;

        blurcoords[5] = screencoords.xy + vec2(-2,-1) * ratio * .0007;
        blurcoords[6] = screencoords.xy + vec2(-1,-1) * ratio * .0007;
        blurcoords[7] = screencoords.xy + vec2( 0,-1) * ratio * .0007;
        blurcoords[8] = screencoords.xy + vec2( 1,-1) * ratio * .0007;
        blurcoords[9] = screencoords.xy + vec2( 2,-1) * ratio * .0007;

        blurcoords[10] = screencoords.xy + vec2(-2, 0) * ratio * .0007;
        blurcoords[11] = screencoords.xy + vec2(-1, 0) * ratio * .0007;
        blurcoords[12] = screencoords.xy + vec2( 0, 0) * ratio * .0007;
        blurcoords[13] = screencoords.xy + vec2( 1, 0) * ratio * .0007;
        blurcoords[14] = screencoords.xy + vec2( 2, 0) * ratio * .0007;

        blurcoords[15] = screencoords.xy + vec2(-2, 1) * ratio * .0007;
        blurcoords[16] = screencoords.xy + vec2(-1, 1) * ratio * .0007;
        blurcoords[17] = screencoords.xy + vec2( 0, 1) * ratio * .0007;
        blurcoords[18] = screencoords.xy + vec2( 1, 1) * ratio * .0007;
        blurcoords[19] = screencoords.xy + vec2( 2, 1) * ratio * .0007;

        blurcoords[20] = screencoords.xy + vec2(-2, 2) * ratio * .0007;
        blurcoords[21] = screencoords.xy + vec2(-1, 2) * ratio * .0007;
        blurcoords[22] = screencoords.xy + vec2( 0, 2) * ratio * .0007;
        blurcoords[23] = screencoords.xy + vec2( 1, 2) * ratio * .0007;
        blurcoords[24] = screencoords.xy + vec2( 2, 2) * ratio * .0007;
    }
    
#elif COMPILING_FRAGMENT_PROGRAM

    void frag(){
		float Pi = 6.28318530718; // Pi*2
    
		// GAUSSIAN BLUR SETTINGS {{{
		float Directions = 16.0; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
		float Quality = 3.0; // BLUR QUALITY (Default 4.0 - More is better but slower)
		float Size = 8.0; // BLUR SIZE (Radius)
		// GAUSSIAN BLUR SETTINGS }}}
	
		vec2 Radius = Size/screensize.xy;
		
		// Normalized pixel coordinates (from 0 to 1)
		vec2 uv = screencoords.xy;
		// Pixel colour
		vec4 Color = texture(framebuf, uv);
		
		// Blur calculations
		for( float d=0.0; d<Pi; d+=Pi/Directions)
		{
			for(float i=1.0/Quality; i<=1.0; i+=1.0/Quality)
			{
				Color += texture( framebuf, uv+vec2(cos(d),sin(d))*Radius*i);		
			}
		}
		
		Color /= Quality * Directions - 15.0;
		
        gl_FragColor = Color;
    }
    
#endif
