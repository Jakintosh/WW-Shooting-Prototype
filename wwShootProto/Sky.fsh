void main( void )
{
    float mod = (v_tex_coord.y * 1.5) - 0.5;
    float dom = 1.0 - mod;
    
    float r = (topColor.r * mod) + (botColor.r * dom);
    float g = (topColor.g * mod) + (botColor.g * dom);
    float b = (topColor.b * mod) + (botColor.b * dom);
    
    vec4 col = vec4(r, g, b, 1.0) * 0.73;
    float tex = texture2D(u_texture, v_tex_coord).r * 0.27;
    
    gl_FragColor = col + tex;
//    gl_FragColor = vec4(mod, mod, mod, 1.0);
}