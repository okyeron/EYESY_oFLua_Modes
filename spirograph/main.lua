require("eyesy")

modeTitle = "spirograph"       -- name the mode

-- based on code from https://github.com/rspt/processing-spirograph

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
c = glm.vec3( w2, h2, 0 )   -- center in glm vector

num=64


----------------------------------------------------
function setup()
    of.noFill()
	  bg = of.Color(0,0,0,0)
	  fg = of.Color()
    saturation = 255

    --mytimer = of.timer()
    startTime = of.getElapsedTimeMillis()
    bTimerReached = false
    position = 0.1
    speed = 120
    colorspeed = 120
    start = 0
    
   	knob1 = 0.9 -- 0.05
   	knob2 = 0.6
   	knob3 = 0.0
   	knob4 = 0.5
   	knob5 = 0.1

    centerX = w2
    centerY = h2
    hval = h *1.5
    
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
        colorCycle( start, saturation, fg ) 
         
        if position > 1 then
          position = 0
        end
    else 
      bTimerReached = false
    end
    
    
end

function colorCycle(startHue, sat, name) -- startHue is 0-255
    hue = (startHue + 0.5) % 255  
    start = hue 
    name:setHsb(hue, sat, 255 )
end

----------------------------------------------------
function draw()
    -- OSD
--    osd.osd_button (osd_state)

    
  a = knob1 * 400 -- knob1 -- a = position * 400 -- knob1
  hi = knob2 * hval
  b = knob3 * 400

    --amplitude = 1000 + knob3*4000   
    
    
--    of.setLineWidth(knob5 * 5)   

--    of.pushMatrix()

--    of.rotateXDeg(knob1*180)
--    of.rotateYDeg(knob2*180)
--    of.rotateXDeg(position*2*180)
--    of.rotateYDeg(position*2*180)


--    ringoffset = 360/num
--    offset = 256/num

  audiomult = 0.70
  hi = hi * peak 
  a = a * peak 

  
  for i=1, 361 do
    audioR = inR[ round(i * audiomult,0) ]
--    audioL = inL[ round(i * audiomult,0)]
    saturation = 255 - math.abs(audioR) * 255 * 2
    
    colorPickHsb( knob5 + elapsed/100 + position/4, fg )
    of.setColor( fg )
--    of.noFill()
    
    t = math.rad(i)
    ot = math.rad(i-1)
    d = a*t
    od = a*ot

    oxpos = (a-b)*math.cos(ot)+hi*math.cos(od)
    oypos = (a-b)*math.sin(ot)+hi*math.sin(od)

    xpos = (a-b)*math.cos(t)+hi*math.cos(d)
    ypos = (a-b)*math.sin(t)+hi*math.sin(d)

    of.drawLine(centerX+oxpos, centerY+oypos, centerX+xpos, centerY+ypos)
  end

    
--    of.popMatrix()

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