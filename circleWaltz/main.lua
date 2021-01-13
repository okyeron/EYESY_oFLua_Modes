require("eyesy")

modeTitle = "circleWaltz"       -- name the mode

-- based on https://www.openprocessing.org/sketch/748916

---------------------------------------------------------------------------
-- helpful global variables 
w = of.getWidth()           -- global width  
h = of.getHeight()          -- global height of screen
w2 = w / 2                  -- width half 
h2 = h / 2                  -- height half
w4 = w / 4                  -- width quarter
h4 = h / 4                  -- height quarter
w8 = w / 8                  -- width 8th
h8 = h / 8                  -- height 8th
w16 = w / 16                  -- width 16th
h16 = h / 16                  -- height 16th
--c = glm.vec3( w2, h2, 0 )   -- center in glm vector

TAU = 2 * math.pi

num=64

--blendModes = {Alpha=1, Add=2, Multiply=4, Screen=5}
blendModes = {1,2,4,5}

----------------------------------------------------
function setup()
    of.noFill()
	  bg = of.Color(0,0,0,0)
	  fg = of.Color()
--    of.enableAlphaBlending()
    of.enableSmoothing()
    of.enableAntiAliasing()
    
    --mytimer = of.timer()
    startTime = of.getElapsedTimeMillis()
    bTimerReached = false
    position = 0.1
    speed = 120
    colorspeed = 120
    start = 0
    
   	knob1 = 0.9
   	knob2 = 0.75
   	knob3 = 1
   	knob4 = 1
   	knob5 = 1

    MAX_CIRCLE_CNT = 1500
    MIN_CIRCLE_CNT = 150
    MAX_VERTEX_CNT = 30
    MIN_VERTEX_CNT = 3
   
--   print ("blend",blendModes[3])
end

----------------------------------------------------
function update()
  	midi.knobs(midi_msg)						-- update knobs with midi input

  --colorPickHsb( knob5, bg )
    of.setBackgroundColor( bg )
    of.noFill()

    elapsed = of.getElapsedTimeMillis() - startTime
    if (elapsed >= speed and not bTimerReached) then
        bTimerReached = true       
        startTime = of.getElapsedTimeMillis()
        position = position + 0.001
        if position > 1 then
          position = 0
        end
    else 
      bTimerReached = false
    end

end

function updateCntByMouse() 
  xoffset = math.abs(knob1*w - w / 2)
  yoffset = math.abs(k2*h - h / 2)
  circleCnt = of.map(xoffset, 0, w / 2, MAX_CIRCLE_CNT, MIN_CIRCLE_CNT)
  vertexCnt = of.map(yoffset, 0, h / 2, MAX_VERTEX_CNT, MIN_VERTEX_CNT)
end

function getCenterByTheta(theta, time, scale) 
  direction = glm.vec3(math.cos(theta), math.sin(theta),0)
  distance = 0.6 * k4 + 0.2 * math.cos(theta * 6.0 + math.cos(theta * 8.0 + time))
  circleCenter =  direction * distance * scale
  return circleCenter
end 

function getSizeByTheta(theta, time, scale) 
  offset = 0.2 * k5 + 0.12 * math.cos(theta * 9.0 - time * 2.0)
  circleSize = scale * offset
  return circleSize
end

function getColorByTheta(theta, time) 
    th = 8.0 * theta + time * 2.0
    r = 0.6 + 0.4 * math.cos(th)
    g = 0.6 + 0.4 * math.cos(th - math.pi / 3)
    b = 0.6 + 0.4 * math.cos(th - math.pi * 2.0 / 3.0)
    alpha = of.map(circleCnt, MIN_CIRCLE_CNT, MAX_CIRCLE_CNT, 200, 50)
    return of.Color(r * 255, g * 255, b * 255, alpha)
end

----------------------------------------------------
function draw()
    -- OSD
    osd.osd_button (osd_state)

    k2 = knob2 * peak/2  
    k3 = knob3 -- * peak/2  
    k4 = knob4 -- * peak*2
    k5 = knob5 -- * peak/4
    

    of.enableBlendMode(blendModes[4])

    of.translate( w2, h2 )   

    updateCntByMouse()

    for ci = 0, circleCnt do 
      time = of.getFrameNum() / 20
      thetaC = of.map(ci, 0, circleCnt, 0, TAU)
      scale = 400 * k3

      circleCenter = getCenterByTheta(thetaC, time, scale)
      circleSize = getSizeByTheta(thetaC, time, scale)
      c = getColorByTheta(thetaC, time*2)

      of.setColor(c)
      of.noFill()
      of.pushMatrix()
--      of.rotateZDeg(knob4*180)
      
      of.beginShape()
      for vi = 0, vertexCnt do
        thetaV = of.map(vi, 0, vertexCnt, 0, TAU)
        x = circleCenter.x + math.cos(thetaV) * circleSize
        y = circleCenter.y + math.sin(thetaV) * circleSize
        of.vertex(x, y)
      end
      of.endShape(true)
 
      of.popMatrix()

   end



 
--    of.pushMatrix()
--    of.rotateXDeg(knob1*180)
--    of.rotateYDeg(knob2*180)


  
--  for i=1, 361 do
--    audioR = inR[ round(i * audiomult,0) ]
--    audioL = inL[ round(i * audiomult,0)]
--  end

--    of.popMatrix()

    of.disableBlendMode()

end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end


------------------------------------ Color Function
-- this is how the knobs pick color
function colorPickHsb( knob, name )
	-- middle of the knob will be bright RBG, far right white, far left black
	
	k6 = (knob * 5) + 1						-- split knob into 8ths
	hue = (k6 * 255) % 255 
	kLow = math.min( knob, 0.49 ) * 2		-- the lower half of knob is 0 - 1
	kLowPow = math.pow( kLow, 2 )
	kH = math.max( knob, 0.5 ) - 0.5	
	kHigh = 1 - (kH*2)						-- the upper half is 1 - 0
	kHighPow = math.pow( kHigh, 0.5 )
	
	bright = kLow * 255						-- brightness is 0 - 1
	sat = kHighPow * 255					-- saturation is 1 - 0
	
	name:setHsb( hue, sat, bright )			-- set the ofColor, defined above
end


----------------------------------------------------
function exit()
	print("script finished")
end