; Playdate object helpers and misc
(import-macros {: defns} :source.lib.macros)

(fn table.shallowcopy [orig other]
  (let [cloned (or other {})]
    (each [key val (pairs orig)]
      (tset cloned key val))
    cloned))

(defns :basics []
  (local timestamp 0)
  (local canvas (love.graphics.newCanvas 400 240))
  (local canvas-scale 1)
  (local COLOR_WHITE { :r (/ 176 255) :g (/ 174 255) :b (/ 167 255) })
  (local COLOR_BLACK { :r (/ 49  255) :g (/ 47  255) :b (/ 40  255)  })

  ;; Shader borrowed from playbit to force black/white/red
  (local shader (love.graphics.newShader "
extern int mode;
extern bool debugDraw;
extern int pattern[64];

// color constants that match playdate colors
const vec4 WHITE =        vec4(176.0f / 255.0f, 174.0f / 255.0f, 167.0f / 255.0f, 1);
const vec4 BLACK =        vec4( 49.0f / 255.0f,  47.0f / 255.0f,  40.0f / 255.0f, 1);
const vec4 TRANSPARENT =  vec4(0, 0, 0, 0);
const vec4 DEBUG =        vec4(1, 0, 0, 0.5); // used when rendering via playdate.debugDraw()

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 screen_coords)
{
  vec4 outputcolor = Texel(tex, tex_coords) * color;
  if (mode == 1)                          // ---------- fillWhite
  {
    if (outputcolor.a > 0) 
    {
      if (debugDraw)
      {
        return DEBUG;
      }
      else
      {
        return WHITE;
      }
    }
    else
    {
      return TRANSPARENT;
    }
  }
  else if (mode == 2)                     // ---------- fillBlack
  {
    if (outputcolor.a > 0) 
    {
      if (debugDraw)
      {
        return DEBUG;
      }
      else
      {
        return BLACK;
      }
    }
    else
    {
      return TRANSPARENT;
    }
  }
  // else if (mode == 2)                  // ---------- XOR
  // {
  //   // TODO: XOR drawmode
  // }
  // else if (mode == 3)                  // ---------- NXOR
  // {
  //   // TODO: NXOR drawmode
  // }
  else if (mode == 4)                  // ---------- whitetransparent
  {
    if (outputcolor.a > 0)
    {
      if (debugDraw)
      {
        return DEBUG;
      }

      // choose white or black based on saturation
      float saturation = rgb2hsv(vec3(outputcolor)).z;
      // ideally this value is 0.5f (halfway) not sure why this doesn't work?
      if (saturation >= 0.45f)
      {
        return TRANSPARENT;
      }
      else
      {
        return BLACK;
      }
    }
    else
    {
      // transparent pixel
      return TRANSPARENT;
    }
  }
  // else if (mode == 5)                  // ---------- blacktransparent
  // {
  //   // TODO: blackTransparent drawmode
  // }
  // else if (mode == 6)                  // ---------- inverted
  // {
  //   // TODO: inverted drawmode
  // }
  else if (mode == 7)                     // ---------- ???
  {
    // unused
  }
  else if (mode == 8)                     // ---------- pattern
  {
    // this mode does not exist on PD - this is to implement playdate.graphics.setPattern()

    // Use mod() to get the position of the current pixel within the 8x8 pattern
    int x = int(mod(screen_coords.x, 8.0));
    int y = int(mod(screen_coords.y, 8.0));

    // Use \"x\" and \"y\" multiplied by \"w\" to index into the pattern array
    if (pattern[x + y * 8] == 1) {
      if (debugDraw)
      {
        return DEBUG;
      }
      else
      {
        return WHITE;
      }
    } else {
      return BLACK;
    }
  }
  else                                    // ---------- copy
  {
    if (outputcolor.a > 0)
    {
      if (debugDraw)
      {
        return DEBUG;
      }

      // choose white or black based on saturation
      float saturation = rgb2hsv(vec3(outputcolor)).z;
      // ideally this value is 0.5f (halfway) not sure why this doesn't work?
      if (saturation >= 0.45f)
      {
        return WHITE;
      }
      else
      {
        return BLACK;
      }
    }
    else
    {
      // transparent pixel
      return TRANSPARENT;
    }
  }
}
"))

  (fn draw-fps [] "TODO")
  (fn love-load []
    (love.window.setMode (* 400 canvas-scale) (* 240 canvas-scale))
    (love.graphics.setBackgroundColor COLOR_WHITE.r COLOR_WHITE.g COLOR_WHITE.b)
    (love.graphics.setColor COLOR_BLACK.r COLOR_BLACK.g COLOR_BLACK.b)
    (love.graphics.setShader shader)
    (canvas:setFilter "nearest" "nearest")
    )
  (fn love-update [] "TODO")
  (fn love-draw-start []
    (love.graphics.setCanvas canvas)
    (love.graphics.clear)
    )
  (fn love-draw-end []
    (love.graphics.setCanvas)
    (love.graphics.draw canvas 0 0 0 canvas-scale)
    )

  (tset _G.playdate :geometry {})
  (tset _G.playdate :geometry :rect
        (defns :rect []
          (fn insetBy [self] "TODO")
          (fn new [x y width height]
            {: x : y : width : height : insetBy})
          ))
  (tset _G.playdate :drawFPS draw-fps)
  (tset _G.playdate :love-load love-load)
  (tset _G.playdate :love-update love-update)
  (tset _G.playdate :love-draw-start love-draw-start)
  (tset _G.playdate :love-draw-end love-draw-end)
  )
