require("eyesy")

modeTitle = "bezierFlower"       -- name the mode


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

tau = 2 * math.pi



num=64

--blendModes = {Alpha=1, Add=2, Multiply=4, Screen=5}
blendModes = {1,2,4,5}
    noiseMultiplier = math.random(0.05, 0.030)
    noiseStep = math.random(10)
    circleSize = 15;
    radius = 100;

----------------------------------------------------
function setup()
    of.noFill()
	  bg = of.Color(255,255,255,255)
	  fg = of.Color()
    of.enableAlphaBlending()
    of.enableSmoothing()
    of.enableAntiAliasing()
    
    --mytimer = of.timer()
    startTime = of.getElapsedTimeMillis()
    bTimerReached = false
    position = 0.1
    speed = 120
    colorspeed = 120
    start = 0
    
   	knob1 = 1
   	knob2 = 1
   	knob3 = 1
   	knob4 = 1
   	knob5 = 1

--    noiseSeed(int(random(0.0, 10000.0)))
    
    centerX = w2
    centerY = h2

end

----------------------------------------------------
function update()
  	midi.knobs(midi_msg)						-- update knobs with midi input

  --colorPickHsb( knob5, bg )
    of.setBackgroundColor( bg )
--    of.noFill()

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

----------------------------------------------------
function draw()
    -- OSD
    osd.osd_button (osd_state)

    k2 = knob2 * peak/2  
    k3 = knob3 -- * peak/2  
    k4 = knob4 -- * peak*2
    k5 = knob5 -- * peak/4
    

--    of.enableBlendMode(blendModes[4])
--
--    of.translate( w2, h2 )   
--
--    of.pushMatrix()
--  of.setColor(128)
  
  distance =  peak* 300
  mouseAngle = peak

  step = math.pi/100
    

--------(g)--------------------------------------
	-- 
	-- 		ofBezierVertex
	-- 
	-- 		with ofBezierVertex we can draw a curve from the current vertex
	--		through the the next three vertexes we pass in.
	--		(two control points and the final bezier point)
	--
	of.pushMatrix()
  of.translate(w2, h2);
			
	local offset = 100
	local x0 = 0
	local y0 = 0
	local x1 = 100+50*math.cos(of.getElapsedTimef()*1.0)
	local y1 = 100+(200*knob1)*math.sin(of.getElapsedTimef()/5)
	local x2 = 225+150*math.cos(of.getElapsedTimef()*1.0)
	local y2 = 100+(200*knob2)*math.sin(of.getElapsedTimef()/2)
	local x3 = 450
	local y3 = 100
	
	of.fill()
	of.enableAlphaBlending()


	--,math.random(100,math.sin(of.getElapsedTimef())*200)

	for i=0,14 do
	fg = of.Color(math.sin(of.getElapsedTimef()+500)*255,math.sin(of.getElapsedTimef()+750)*225,math.sin(of.getElapsedTimef())*150, 100)
	of.setColor( fg )
    of.beginShape()
      of.vertex(x0, y0)
      of.bezierVertex(x1, y1, x2, y2, x3, y3)
      of.nextContour(true)
    of.endShape(false)

--		of.fill()
    fg:invert()
    of.setColor( fg )
--		of.drawCircle(x0, y0, 4)
		of.drawCircle(x1, y1, 4)
		of.drawCircle(x2, y2, 4)
--		of.drawCircle(x3, y3, 4)
		of.drawCircle(x1, y3, 4)

    of.rotateDeg(24)
    
  end 	
  of.popMatrix()
	
	of.disableAlphaBlending()
	---------------------------------------



--  of.rotateDeg(90);
--    of.pushMatrix()
--      of.translate(w2, h2);
--      of.rotateDeg(i);
--      of.translate(-w2, -h2);
--      
--      rheight = math.random(90,150)
--
--      of.setColor(0,128,128)
--      of.fill()
--      rect1Pos = glm.vec3( centerX-2, centerY, 0 )
--      myRect1 = of.Rectangle(rect1Pos, 2, rheight*2)
--      of.drawRectangle(myRect1)
--      
--      of.setColor(255,0,0)
--      of.fill()
--      rect2Pos = glm.vec3( centerX-2, centerY+distance, 0 )
--      myRect2 = of.Rectangle(rect2Pos, 2, -rheight)
--      of.drawRectangle(myRect2)
--            
--
--    of.popMatrix()
--  end
--
--
  
--  for i=1, 361 do
--    audioR = inR[ round(i * audiomult,0) ]
--    audioL = inL[ round(i * audiomult,0)]
--  end

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