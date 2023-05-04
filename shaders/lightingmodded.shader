#version 130

uniform mat2x4 color_xform;
uniform sampler2D palettetex;
uniform sampler2D framebuf;
uniform float palette;

uniform vec2 screensize;
uniform float timer;

uniform float level_param;

varying vec2 worldPos;

uniform vec2 playerPos;
uniform float waterheight;

uniform vec4 light0;
uniform vec4 light1;
uniform vec4 light2;
uniform vec4 light3;
uniform vec4 light4;
uniform vec4 light5;
uniform vec4 light6;
uniform vec4 light7;


const vec4 light_color = vec4(1.0, 1.0, 1.0, .5); //r, g, b, a. the gradient light that is above (and on top) of the water
const float light_distance = 10;                //less = farther distance
const float glow_strength = 1;


#if COMPILING_VERTEX_PROGRAM

    void vert(){
        //gl_FrontColor = gl_Color * color_xform[0] + color_xform[1];
        vec4 outcolor = gl_Color * color_xform[0] + color_xform[1];
        gl_FrontColor = outcolor;
        gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
        worldPos = (gl_ModelViewMatrix * gl_Vertex).xy;
    }
    
#elif COMPILING_FRAGMENT_PROGRAM
    float hash(float x){
        return fract(sin(x)*43758.5453);
    }
    float noise( float u ){
        vec3 x = vec3(u, 0, 0);

        vec3 p = floor(x);
        vec3 f = fract(x);

        f       = f*f*(3.0-2.0*f);
        float n = p.x + p.y*57.0 + 113.0*p.z;

        return mix(mix(mix( hash(n+0.0), hash(n+1.0),f.x),
            mix( hash(n+57.0), hash(n+58.0),f.x),f.y),
            mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
    }

    vec4 gblend(vec4 a, vec4 b){
        return 1.0-(1.0-a)*(1.0-b);
    }

    void frag(){
        vec4 screencoords = gl_FragCoord;

        screencoords.x /= screensize.x;
        screencoords.y /= screensize.y;

        vec4 outcolor = texture(framebuf, screencoords.xy);
        

        float d = length(playerPos - worldPos);

        float ambient_light = level_param*level_param;
        float l_p = min(1.0, 60.0/(d+50.0));
        float l_0 = min(1.0, light0.z / (length(light0.xy - worldPos) + light0.z*.75));
        float l_1 = min(1.0, light1.z / (length(light1.xy - worldPos) + light1.z*.75));
        float l_2 = min(1.0, light2.z / (length(light2.xy - worldPos) + light2.z*.75));
        float l_3 = min(1.0, light3.z / (length(light3.xy - worldPos) + light3.z*.75));
        float l_4 = min(1.0, light4.z / (length(light4.xy - worldPos) + light4.z*.75));
        float l_5 = min(1.0, light5.z / (length(light5.xy - worldPos) + light5.z*.75));
        float l_6 = min(1.0, light6.z / (length(light6.xy - worldPos) + light6.z*.75));
        float l_7 = min(1.0, light7.z / (length(light7.xy - worldPos) + light7.z*.75));

const float light_strength = 3;

        l_p = l_p*l_p;
        l_0 = l_0*l_0*light_strength;
        l_1 = l_1*l_1*light_strength;
        l_2 = l_2*l_2*light_strength;
        l_3 = l_3*l_3*light_strength;
        l_4 = l_4*l_4*light_strength;
        l_5 = l_5*l_5*light_strength;
        l_6 = l_6*l_6*light_strength;
        l_7 = l_7*l_7*light_strength;


        float dy = waterheight - worldPos.y;

        dy += noise(worldPos.x / 32.0 +timer  * 2)*6;
        dy += noise(worldPos.x / 16.0 +timer  * -4.35)*3;
        dy += noise(worldPos.x / 8.0  +timer  * 1)*1.5;

        float glowval = -(dy / 360.0/* * ratio.y*/);
        glowval = glowval*light_distance;
        glowval += 1;
        glowval = clamp(glowval, 0.0, 1.0);
        glowval = glowval*glowval*glow_strength;
        


        float lightval = l_p+l_0+l_1+l_2+l_3+l_4+l_5+l_6+l_7 + glowval;

        lightval = 1.0-(1.0-lightval)*(1.0-ambient_light);


       // vec4 out_sat = vec4((outcolor.r+outcolor.g+outcolor.b)/3.0);

      //  outcolor = mix(out_sat, outcolor, lightval);

        outcolor *= min(1.5, lightval);



        //outcolor = gblend(outcolor, mix(vec4(0.0), light_color * light_color.a, glowval));


        outcolor.a = gl_Color.a;
        gl_FragColor = outcolor;
    }
    
#endif
