void main( void )
{
    // vec4 topColor
    // vec4 botColor
    // vec3 size
    
    float mod = ((gl_FragCoord.y / size.y) * 2.0) - 1.0;
    float dom = 1.0 - mod;
    
    float r = (topColor.r * mod) + (botColor.r * dom);
    float g = (topColor.g * mod) + (botColor.g * dom);
    float b = (topColor.b * mod) + (botColor.b * dom);
    
    vec4 col = vec4(r, g, b, 1.0) * 0.73;
    vec4 tex = texture2D(u_texture, v_tex_coord) * 0.27;
    
    gl_FragColor = col + tex;
}