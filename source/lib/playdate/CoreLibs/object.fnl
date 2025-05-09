; Playdate object helpers and misc
(import-macros {: defns : div : inspect} :source.lib.macros)

(fn table.shallowcopy [orig other]
  (let [cloned (or other {})]
    (each [key val (pairs orig)]
      (tset cloned key val))
    cloned))

(defns :basics
  [ds (require :source.lib.playdate.CoreLibs.datastore)
   keyboard (require :source.lib.playdate.CoreLibs.keyboard)
   sound (require :source.lib.playdate.CoreLibs.sound)
   menu (require :source.lib.playdate.CoreLibs.menu)
   pathfinder (require :source.lib.playdate.CoreLibs.pathfinder)]
  (local drag-scale 0.2)
  (local input-state
         {:timer 0
          :elapsed 0
          :crank
          {:active false :movement 0 :angle 0 :last 0 :accel 0}
          :key-map
          {:a "s" :b "a"
           :up "up" :down "down" :left "left" :right "right"}
          :invert-map
          {"s" :a "a" :b
           :up "up" :down "down" :left "left" :right "right"}
          :buttons-held
          {:a -1 :b -1 :up -1 :down -1 :left -1 :right -1}
          ;; Virtual mapping button input with keyboard / mouse
          :love-press
          {:crank false :a false :b false :up false :down false :left false :right false}
          ;; Tracks touch ids
          :touches {}
          :just-pressed
          {:a false :b false :up false :down false :left false :right false}
          :just-released
          {:a false :b false :up false :down false :left false :right false}
          })
  (local frame {:top 20 :bottom 20 :left 120 :right 220})
  (local fake-buttons [{:btn :crank
                        :radius 35
                        :x (- frame.left 95) :y (+ 180 frame.top)
                        :w 70 :h 70
                        }
                       {:btn :b
                        :x (- frame.left 110) :y (+ -10 frame.top)
                        :radius 35
                        :w 70 :h 70}
                       {:btn :a
                        :x (- frame.left 80) :y (+ 80 frame.top)
                        :radius 35
                        :w 70 :h 70}
                       {:btn :up
                        :x (+ frame.left 400 88) :y (+ frame.top 5)
                        :w 50 :h 80}
                       {:btn :down
                        :x (+ frame.left 400 88) :y (+ frame.top 155)
                        :w 50 :h 80}
                       {:btn :left
                        :x (+ frame.left 400 10) :y (+ frame.top 95)
                        :w 80 :h 50}
                       {:btn :right
                        :x (+ frame.left 400 135) :y (+ frame.top 95)
                        :w 80 :h 50}
                       ])
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
const vec4 WHITE = vec4(176.0 / 255.0, 174.0 / 255.0, 167.0 / 255.0, 1.0);
const vec4 BLACK = vec4(49.0 / 255.0, 47.0 / 255.0, 40.0 / 255.0, 1.0);
const vec4 TRANSPARENT = vec4(0.0, 0.0, 0.0, 0.0);
const vec4 DEBUG = vec4(1.0, 0.0, 0.0, 0.5); // used when rendering via playdate.debugDraw()


int getPatternData(int x, int y) {
    int id = (x + y * 8);
    for (int i=0; i<64; i++) {
        if (i == id) return pattern[i];
    }
}

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
  if (mode == 1) // ---------- fillWhite
  {
    if (outputcolor.a > 0.0)
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
  else if (mode == 2) // ---------- fillBlack
  {
    if (outputcolor.a > 0.0)
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
  else if (mode == 4) // ---------- whitetransparent
  {
    if (outputcolor.a > 0.0)
    {
      if (debugDraw)
      {
        return DEBUG;
      }

      // choose white or black based on saturation
      float saturation = rgb2hsv(vec3(outputcolor)).z;
      // ideally this value is 0.5f (halfway) not sure why this doesn't work?
      if (saturation >= 0.45)
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
  // else if (mode == 7) // ---------- ???
  // {
  //  // unused
  // }
  else if (mode == 8) // ---------- pattern
  {
    // this mode does not exist on PD - this is to implement playdate.graphics.setPattern()

    // Use mod() to get the position of the current pixel within the 8x8 pattern
    int x = int(mod(screen_coords.x, 8.0));
    int y = int(mod(screen_coords.y, 8.0));

    // Use \"x\" and \"y\" multiplied by \"w\" to index into the pattern array
    if (getPatternData(x, y) == 1) {
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
  else // ---------- copy
  {
    if (outputcolor.a > 0.0)
    {
      if (debugDraw)
      {
        return DEBUG;
      }

      // choose white or black based on saturation
      float saturation = rgb2hsv(vec3(outputcolor)).z;
      // ideally this value is 0.5f (halfway) not sure why this doesn't work?
      if (saturation >= 0.45)
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

  (fn draw-fps []
    (let [delta (love.timer.getAverageDelta)]
    ;; -- Display the frame time in milliseconds for convenience.
    ;; -- A lower frame time means more frames per second.
      (love.graphics.print (string.format "%.1f fps" (/ 1000 (* 1000 delta))) 320 10))
    )

  (fn textinput [typed]
    (if typed
        (tset playdate.keyboard :text typed)))

  (fn keypressed [key]
    (let [mapped (?. input-state :invert-map key)]
      (if mapped
          (tset input-state :love-press mapped true))))

  (fn keyreleased [key]
    (let [mapped (?. input-state :invert-map key)]
      (if mapped
          (tset input-state :love-press mapped false))))

  (fn mousepressed [x y button]
    (let [real-x (/ x canvas-scale)
          real-y (/ y canvas-scale)]
      (each [i btn (ipairs fake-buttons)]
        (if (and
             (<= btn.x real-x) (>= (+ btn.x btn.w) real-x)
             (<= btn.y real-y) (>= (+ btn.y btn.h) real-y))
            (do
              (tset input-state :love-press btn.btn true)
              (tset input-state :mouse-pressed [btn.btn])))
        )))

  (fn touchpressed [id x y button]
    (let [real-x (/ x canvas-scale)
          real-y (/ y canvas-scale)]
      (each [i btn (ipairs fake-buttons)]
        (if (and
             (<= btn.x real-x) (>= (+ btn.x btn.w) real-x)
             (<= btn.y real-y) (>= (+ btn.y btn.h) real-y))
            (do
              (tset input-state :love-press btn.btn true)
              (tset input-state :touches id btn.btn)))
        )))

  (fn mousereleased [x y button is-touch]
    (let [real-x (/ x canvas-scale)
          real-y (/ y canvas-scale)]
      (each [i btn (ipairs (or input-state.mouse-pressed []))]
        (if (= btn :crank)
            (tset input-state :crank :accel 0))
        (tset input-state :love-press btn false))
      (tset input-state :mouse-pressed [])
      ))

  (fn touchreleased [id x y]
    (let [real-x (/ x canvas-scale)
          real-y (/ y canvas-scale)]
      (let [btn (?. input-state.touches id)]
        (if btn
            (do
              (if _G.playdate.keyboard.keyboard-state.open?
                  (_G.playdate.keyboard.-closeKeyboard (= btn :a)))
              (tset input-state :love-press btn false)))
        (tset input-state :touches id nil))
      ))

  (fn wheelmoved [x y]
    (let [y-scaled (* y 1.5)
          new-angle (+ input-state.crank.angle y-scaled)
          new-angle (if (< new-angle 0)
                        (math.fmod (+ 360 new-angle) 360)
                        (math.fmod new-angle 360))
          angle-changed? (not= new-angle input-state.crank.angle)]
      (tset input-state :crank :movement (+ input-state.crank.movement y-scaled))
      (tset input-state :crank :last input-state.crank.angle)
      (tset input-state :crank :angle new-angle)
      (if angle-changed?
          (tset input-state :crank :active true))
      ))

  (fn mousemoved [x y dx dy]
    (if input-state.love-press.crank
        (let [y-scaled (+ (* dy drag-scale) (* dx drag-scale))
              accel (+ input-state.crank.accel y-scaled)
              new-angle (+ input-state.crank.angle accel)]
          (tset input-state :crank :accel accel)
          (tset input-state :crank :movement (+ input-state.crank.movement accel))
          (tset input-state :crank :last input-state.crank.angle)
          (tset input-state :crank :angle new-angle)
          )))

  (fn touchmoved [id x y dx dy]
    (if (= (. input-state :touches id) :crank)
        (let [y-scaled (+ (* dy drag-scale) (* dx drag-scale))
              accel (+ input-state.crank.accel y-scaled)
              new-angle (+ input-state.crank.angle accel)]
          (tset input-state :crank :accel accel)
          (tset input-state :crank :movement (+ input-state.crank.movement accel))
          (tset input-state :crank :last input-state.crank.angle)
          (tset input-state :crank :angle new-angle)
          )))

  (fn love-load []
    (set love.keypressed keypressed)
    (set love.keyreleased keyreleased)
    (set love.mousepressed mousepressed)
    (set love.mousereleased mousereleased)
    (set love.mousemoved mousemoved)
    (set love.touchpressed touchpressed)
    (set love.touchreleased touchreleased)
    (set love.touchmoved touchmoved)
    (set love.wheelmoved wheelmoved)
    (love.window.setTitle "Playdate Game")
    (love.window.setMode (+ (* 400 canvas-scale) (* (+ frame.left frame.right) canvas-scale))
                         (+ (* 240 canvas-scale) (* (+ frame.top frame.bottom) canvas-scale)))
    ;; (love.graphics.setBackgroundColor COLOR_WHITE.r COLOR_WHITE.g COLOR_WHITE.b 1)
    ;; (love.graphics.setColor COLOR_BLACK.r COLOR_BLACK.g COLOR_BLACK.b 1)
    (love.graphics.setLineStyle "smooth")
    (love.graphics.setLineWidth 1)
    (love.graphics.setShader shader)
    (tset _G.playdate.graphics :_shader shader)
    (tset _G.playdate.graphics :_bg COLOR_WHITE)
    (tset _G.playdate.graphics :_fg COLOR_BLACK)
    (tset _G.playdate :_canvas canvas)
    (tset input-state :timer (math.floor (* 1000 (love.timer.getTime))))
    (shader:send "mode" 0)
    (canvas:setFilter "nearest" "nearest")
    )


  (fn updateInputTimers! [{: key-map : buttons-held : just-pressed : just-released : timer : elapsed : love-press &as input-state}]
    (let [now     (math.floor (* (love.timer.getTime) 1000))
          elapsed  (- now timer)]
      (tset input-state :elapsed elapsed)
      (tset input-state :timer now)
      (each [key time-held (pairs buttons-held)]
        (let [button-pressed? (. love-press key)]
          (if (and button-pressed? (< time-held 0))
              (do (tset just-pressed key true)
                  (tset just-released key false)
                  (tset buttons-held key (+ (math.max time-held 0) elapsed)))
              button-pressed?
              (do
                (tset just-pressed key false)
                (tset just-released key false)
                (tset buttons-held key (+ (math.max time-held 0) elapsed)))
              (> time-held 0)
              (do
                (tset just-pressed key false)
                (tset just-released key true)
                (tset buttons-held key -1))
              (do
                (tset just-released key false)
                (tset just-pressed key false)
                (tset buttons-held key -1)
                ))))
      )
    )

  (fn love-update []
    (updateInputTimers! input-state))

  (fn love-draw-start []
    (love.graphics.clear COLOR_WHITE.r COLOR_WHITE.g COLOR_WHITE.b 1)
    (love.graphics.setCanvas canvas)
    ;; Early update of offset can get lost (Love requires it in the draw loop)
    ;; (love.graphics.translate _G.playdate.graphics._tx _G.playdate.graphics._ty)
    ;; TODO - do we always want this?
    (love.graphics.clear COLOR_WHITE.r COLOR_WHITE.g COLOR_WHITE.b 1)
    )
  (fn love-draw-end []
    (keyboard.-maybeDraw)
    (love.graphics.setCanvas)
    (love.graphics.push :all)
    (love.graphics.origin)
    (love.graphics.setShader)
    (love.graphics.setColor 0.8 0.7 0.2)
    (love.graphics.rectangle "fill" 0 0
                             (* (+ 400 frame.left frame.right) canvas-scale) (* (+ 240 frame.top frame.bottom) canvas-scale))
    (love.graphics.setColor COLOR_WHITE.r COLOR_WHITE.g COLOR_WHITE.b 1)
    (love.graphics.rectangle "fill" frame.left frame.top
                             (* 400 canvas-scale) (* 240 canvas-scale))
    (love.graphics.setLineWidth 8)
    (love.graphics.setColor 0.1 0.1 0.1 1)
    (love.graphics.rectangle "line" frame.left frame.top
                             (* 400 canvas-scale) (* 240 canvas-scale))
    (love.graphics.setColor 1 1 1 1)
    (love.graphics.draw canvas (* frame.left canvas-scale) (* frame.top canvas-scale) 0 canvas-scale)
    (each [i btn (ipairs fake-buttons)]
      (let [is-pressed? (. input-state :love-press btn.btn)
            push-inset (if is-pressed? 1 0)]
        (case btn
          {:btn :crank : radius : x : y }
          (let [crank-angle input-state.crank.angle
                rads (math.rad crank-angle)
                crank-x (* (math.cos rads) radius)
                crank-y (* (math.sin rads) radius)
                knob-offset (if is-pressed? -0.1 0)
                ]
            (love.graphics.setColor 0.2 0.2 0.2)
            (love.graphics.circle "line" (* (+ x 0 radius) canvas-scale) (* (+ y 0 radius) canvas-scale)
                                  (* radius canvas-scale))
            (love.graphics.setColor (+ 0.8 knob-offset) (+ 0.75 knob-offset) (+ 0.3 knob-offset))
            (love.graphics.circle "fill" (* (+ x crank-x radius) canvas-scale) (* (+ y crank-y radius) canvas-scale)
                                  (* 10 canvas-scale))
            )
          {: radius : x : y : btn}
          (do (love.graphics.setColor 0.2 0.2 0.2)
              (love.graphics.circle "fill" (* (+ x 1 radius) canvas-scale) (* (+ y 1 radius) canvas-scale)
                                    (* radius canvas-scale))
              (love.graphics.setColor 0.8 0.75 0.3)
              (love.graphics.circle "fill" (* (+ x push-inset radius) canvas-scale) (* (+ y push-inset radius) canvas-scale)
                                    (* radius canvas-scale))
              (love.graphics.setColor 0.2 0.2 0.3)
              (love.graphics.printf btn
                                    (* (+ x radius -4) canvas-scale)
                                    (* (+ y radius -8) canvas-scale)
                                    radius))
          {: w : h : x : y : btn}
          (do (love.graphics.setColor 0.2 0.2 0.2)
              (love.graphics.rectangle "fill"
                                       (+ 1 (* x canvas-scale)) (+ 1 (* y canvas-scale))
                                       (* w canvas-scale) (* h canvas-scale))
              (love.graphics.setColor 0.8 0.75 0.3)
              (love.graphics.rectangle "fill"
                                       (+ push-inset (* x canvas-scale)) (+ push-inset (* y canvas-scale))
                                       (* w canvas-scale) (* h canvas-scale))
              (love.graphics.setColor 0.2 0.2 0.3)
              )))
      )

    (love.graphics.pop)
    (tset _G.playdate :_last-image (canvas:newImageData))
    )

  (tset _G.playdate :geometry {})
  (tset _G.playdate :geometry :rect
        (defns :rect []
          (fn unpack [self]
            (values self.x self.y self.width self.height))

          ;; TODO: handle point as input for x
          (fn containsPoint [self x y]
            (and (<= self.x x (+ self.x self.width))
                 (<= self.y y (+ self.y self.height))
                 ))

          (fn insetBy [self minus-x minus-y]
            (let [minus-y (or minus-y minus-x)
                  dx (div minus-x 2)
                  dy (div minus-y 2)
                  new-x (+ self.x dx)
                  new-y (+ self.y dy)
                  new-height (- self.height dy)
                  new-width (- self.width dx)]
              ;; TODO: maybe way to call new on module direct?
              (_G.playdate.geometry.rect.new new-x new-y new-width new-height)
              ))

          (fn new [x y width height]
            (let [new-rect {: x : y : width : height
                            :h height :w width}]
              (setmetatable new-rect {:__index _G.playdate.geometry.rect})
              new-rect))
          ))

  (fn getSecondsSinceEpoch []
    (values (os.time)
            (math.floor (* 1000 (love.timer.getTime))))
    )

  (fn getCrankChange []
    (let [scale 0.5
          change input-state.crank.movement
          acceleration (math.rad (math.pow change 2))
          accelerated (* change acceleration)]
      (tset input-state :crank :movement 0)
      (values change accelerated)))

  (tset _G.playdate :getSecondsSinceEpoch getSecondsSinceEpoch)
  (tset _G.playdate :getCrankChange getCrankChange)
  (tset _G.playdate :drawFPS draw-fps)
  (tset _G.playdate :love-load love-load)
  (tset _G.playdate :love-update love-update)
  (tset _G.playdate :love-draw-start love-draw-start)
  (tset _G.playdate :love-draw-end love-draw-end)

  (tset _G.playdate :kButtonA "a")
  (tset _G.playdate :kButtonB "b")
  (tset _G.playdate :kButtonUp "up")
  (tset _G.playdate :kButtonDown "down")
  (tset _G.playdate :kButtonLeft "left")
  (tset _G.playdate :kButtonRight "right")

  (tset _G.playdate :buttonJustPressed
        (fn button-just-pressed [key]
          (. input-state :just-pressed key)
          ))

  (tset _G.playdate :buttonIsPressed
        (fn button-pressed [key]
          (let [time-held (. input-state :buttons-held key)]
            (> time-held -1))
          ))
  )
