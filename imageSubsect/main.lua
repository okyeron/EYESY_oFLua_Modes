---- Text Example
require("eyesy")                    -- include the eyesy library
modeTitle = "Example - Image Subsect"       -- name the mode
print(modeTitle)                    -- print the mode title

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
c = glm.vec3( w2, h2, 0 )   -- center in glm vector


blendModes = {1,2,4,5}

---------------------------------------------------------------------------
-- the setup function runs once before the update and draw loops
function setup() 
    fg = of.Color(255)
    bg = of.Color(0,0,0,0)
    
    myFbo = of.Fbo()            -- 1st define an Fbo class
    myFbo:allocate( w, h)     -- then we need to 'allocate' space for the fbo, define the size

    of.setBackgroundAuto(false)
--    of.enableAlphaBlending()

   
    -------------------- define the font class
    myFont = of.TrueTypeFont()                          -- define font
    -- load arial font, at size 32px
    myFont:load("arial.ttf", 64, true, true, true, 80, 200 )                        
    
    gridX = 3
    gridY = 40
    gridW = round(w/gridX)
    gridH = round(h/gridY)
    offset = 0
    knob3 = 0.1
    knob2 = 0.95
    knob4 = 0.2
    knob5 = 0.5
    
        ---------------- fill a table of image paths, looks for Images folder
    myDirect = of.Directory()                       -- define the Directory Class
    myImg = of.Image()          					-- define Image class 
    thePath = basedir --              -- get current path
    --thePath = myDirect:getPath()                    
    --print("path", myDirect:getAbsolutePath())
    theImgDirectory =  thePath .. "/imageSubsect/Images"         -- look in 'Images'
    imgDir = of.Directory( theImgDirectory )        -- define new Directory class
    imgDir:allowExt( "png" )                        -- load only .png files
    imgDir:allowExt( "jpg" )                        -- and load only .jpg files
    imgDir:listDir()                                -- list the directory
    imgTable = {}                                   -- define the table
    for i = 0, imgDir:size()-1 do                   -- for the size of new directory do
        imagePath = imgDir:getPath( i )             -- load paths into a table
        print( "loaded image :", imagePath )              -- print so we can see what is loaded
        imgTable[ i + 1 ] = imagePath               -- fill the table
    end


    -- so we know that the setup was succesful
    print("done setup") 
end
---------------------------------------------------------------------------
-- update function runs on loop
function update()
  	midi.knobs(midi_msg)						-- update knobs with midi input

    of.setBackgroundColor( bg )
--       offset = knob1*40
    gridY = knob5*60
    gridH = round(h/gridY)
    gridX = knob4*10
    gridW = round(w/gridX)

end

---------------------------------------------------------------------------
-- the main draw function also runs on loop
function draw()
    osd.osd_button (osd_state)


    amplitude = knob3*100  
    image_index = math.floor( knob1 * (imgDir:size()-1) ) + 1   -- knob1 index

    myImg:load( imgTable[ image_index ] )                       -- load the image
    
    imgW = myImg:getWidth()                     -- get the width
    imgH = myImg:getHeight()                    -- get the height
    myImg:setAnchorPoint( imgW/2, imgH/2 )      -- move anchor point to center of image
    
    of.pushMatrix()
    of.translate( w2, h2 )                      -- move to the center of the top left
--    of.enableBlendMode(blendModes[3])
    myImg:draw( 0, 0 )  -- draw the image underneath
    of.popMatrix()

    myFbo:beginFbo()                        -- begin the fbo buffer, following will render off-screen               
    of.clear(0,0,0,0) -- clear the buffer to black

    of.setColor( 255 )
    
--    of.setColor(of.random(255))
    --of.scale(of.random(0.1, 10.0));
    --myFont:drawStringAsShapes("$", 0, 0) -- w2/2-myFont:stringWidth("A")/2,h2/2+myFont:stringHeight("A")/2
--    myFont:drawString("HELLO", 200, 280) 
--    myFont:drawString("WORLD", 200, 450) 

    of.translate( w2, h2 )                      -- move to the center of the top left
    
--    of.enableBlendMode(blendModes[1])
    myImg:draw( 0, 0 )                   -- draw the image on top

    --of.drawCircle(150, 150, 100);
    myFbo:endFbo()      

      aoffset = 256/gridX


    for i = 0, gridX do 
        for p = 0, gridY do

          audioL = inL[i*2+1] * amplitude
          audioR = inR[i*2+1]* amplitude/2
          
          if p % math.random(0,5) > math.random(0,20) then
            colorPickHsb( knob2+audioR/6, fg )
          else 
            colorPickHsb( knob2 , fg ) 
          end
          
          of.setColor( fg )
          -- math.abs(inR[i*aoffset]*amplitude/8 )
          
           drawX = (gridW+offset+audioL)*i  + (audioL * amplitude * of.random(-1, 1))
           drawY = (gridH+offset)*p  -- + (audioR * amplitude * of.random(-1, 1))
           readX = (gridW)*i + round(math.sin((of.getFrameNum()+(i*gridX)+p)/100.)*10, 2)
           readY = (gridH)*p
--           w = gridW
--           h = gridH
           myFbo:getTexture():drawSubsection(drawX, drawY, w, h, readX, readY)

        end
    end
--    of.disableBlendMode()

end


function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

------------------------------------ Color Function
-- this is how the knobs pick color
function colorPickHsb( knob, name )
    -- middle of the knob will be bright RBG, far right white, far left black
    
    k6 = (knob * 5) + 1                     -- split knob into 8ths
    hue = (k6 * 255) % 255 
    kLow = math.min( knob, 0.49 ) * 2       -- the lower half of knob is 0 - 1
    kLowPow = math.pow( kLow, 2 )
    kH = math.max( knob, 0.5 ) - 0.5    
    kHigh = 1 - (kH*2)                      -- the upper half is 1 - 0
    kHighPow = math.pow( kHigh, 0.5 )
    
    bright = kLow * 255                     -- brightness is 0 - 1
    sat = kHighPow * 255                    -- saturation is 1 - 0
    
    name:setHsb( hue, sat, bright )         -- set the ofColor, defined above
end


---------------------------------------------------------------------------
------ function for audio average, takes the whole 100 pt audio buffer and averages.
function avG()  
    a = 0
    for i = 1, 100 do
        aud = math.abs( inL[i])
        a = a + aud
    end
    x = a / 100
    if( x <= 0.001 ) then
        x = 0
    else
        x = x
    end
    return  x
end  
-- the exit function ends the update and draw loops
function exit()
    -- so we know the script is done
    print("script finished")
end