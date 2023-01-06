--[[  User-Module Imports
]]--create a console version of a ASCII hangman game
math.randomseed(os.time())

local function HangMan()    
    local hangMan = {        
        scenes = {  --Prints [7-lines by 9-char's] for each of the 8 states  
        "  +---+\n  |   |\n  O   |\n /|\\  |\n / \\  |\n      |\n=========",  --Game Off = 1Lifes

        "  +---+\n  |   |\n  O   |\n /|\\  |\n /    |\n      |\n=========",   --2Life

        "  +---+\n  |   |\n  O   |\n /|\\  |\n      |\n      |\n=========",   --3Lifes

        "  +---+\n  |   |\n  O   |\n /|   |\n      |\n      |\n=========",    --4Lifes

        "  +---+\n  |   |\n  O   |\n  |   |\n      |\n      |\n=========",    --5Lifes        

        "  +---+\n  |   |\n  O   |\n      |\n      |\n      |\n=========",    --6Lifes

        "  +---+\n  |   |\n      |\n      |\n      |\n      |\n=========",    --7Lifes

        "  +---+\n      |\n      |\n      |\n      |\n      |\n========="     --Game On = 8Lifes                
        },
        finalScene = "  +---+\n      |\n      |\n  O   |\n /|\\  |\n / \\  |\n=========",
        lives = 8,      --number of possible scenes/player lives
        score = 0,
        rounds = 0,
        status = true,  --status of active game 
        saved = false,  --save game configs upon reset
        modeA = 0,      --ASCII group
        modeC = 0,      --Conversion format
        modeR = 0,      --Representation direction
        caseMin = 0,    --Min byte rep of ASCII char 
        caseMax = 0,    --Max byte rep of ASCII char        

      --Update player lives -1
        takeLife = function(self)
          self.lives = self.lives - 1     --take a life             
          if self.lives == 0 then self.status = false end   --flag game over
          self.rounds = self.rounds + 1
        end,

      --Update player lives +1
        giveLife = function(self)
          self.lives = self.lives + 1     --take a life             
          if self.lives == 8 then self.lives = 8 end   --max lives
          self.score = self.score + 1
          self.rounds = self.rounds + 1
        end,

      --Update player scene based on current lives left
        dispScene = function(self) 
            io.write('\n\n' .. self.scenes[self.lives] .. '\n')
            io.close()
        end
      }
    --Return the Hangman Game characteristics Table = {scences,lives,status,takeLife(),dispScene()}
      return hangMan         
end

local function Setup()
  --Create object of Game to inherent and declare new object values
  local setup = HangMan()

  --Recursive function to get user input of type=number only
  local getNumber = function(self)
    local number = io.read("*n", "*l")    --first char is non#: nil --first non# char: ends read --wont accept empty string           
    io.close()
  --Returns the number user inputed
    return tonumber(number)
  end

  --Recursive function to get user input of type=string for hex
  local getHexRep = function(self)
    local hexstr = io.read(2)   --recalls if number is not hex or 2 digits
    if tonumber(hexstr, 16) == nil  or #hexstr ~= 2 then return self:getHexRep() end             
    io.close()
  --Returns the HEX string that user inputed
    return hexstr
  end

  local clearTerminal = function()
    for i=1,100 do
      io.write('\n')
    end
    io.close()
  end

  local delay = function(sec)
    local halt = os.clock()
    sec = sec or 0.0
    --os.diff(t2,t1) could be utilized to do the same 
    while os.clock() - halt + 2E-6 < sec do io.close() end      
  --Returns number
    --return os.clock() - halt
  end

  --Pre-game configuration utility getting user input for game functions -- could make more scalable by storing text in a file
  local modeSel = function(mode)        
    --ASCII,Conversion, and Representation selection prompts                              
    local mode_prompt =  {[1] = "Select ASCII mode\n\t0 for lower case\n\t1 for UPPER case",
                          [2] = "Select Conversion mode\n\t0 for decimal\n\t1 for hex",
                          [3] = "Select Representation mode\n\t0 for Char-->Byte\n\t1 for Byte-->Char"}
    local ascii_select = {[1] = "lower Case selected",
                          [2] = "UPPER Case selected"}
    local conv_select =  {[1] = "Decimal Conversion selected",
                          [2] = "Hexi-decimal Conversion selected"}                                    
    local rep_select =   {[1] = "ASCII representation Char-->Byte selected",
                          [2] = "ASCII representation Byte-->Char selected"}
    --Get ASCII mode selection from user  
    print(mode_prompt[mode])        
    local userInput = getNumber()
    if userInput ~= 0 and userInput ~= 1 then            
      userInput = 0
    end        
    --Display correlated choice per mode selection  
    if mode == 1 then       print(ascii_select[userInput+1] .. '\n')
    elseif mode == 2 then   print(conv_select[userInput+1] .. '\n')
    elseif mode == 3 then   print(rep_select[userInput+1] .. '\n')
    else
      print("Critical Error: Mode Select function")
      setup.status = false   --Offer to restart game
    end
  --Returns users selection as number = [0,1] given 1 of 3 mode selections
    return userInput
  end

  --Assign users mode selections for current game
  local configMode = function()  
    if setup.saved == false then
      setup.modeA = modeSel(1)                --mode for upper or lower case
      setup.modeC = modeSel(2)                --mode for decimal or hex case
      setup.modeR = modeSel(3)                --mode for direction of representation    
    else
      print("Modes unchanged: 1")
    end
    --[[  Mode State Table
        (modeA==0)=(lowerCase) (modeC==0)=(DecimalRep)      (modeR==0)=(Char-->Byte)
        (modeA==1)=(upperCase) (modeC==1)=(Hexi-DecimalRep) (modeR==1)=(Byte-->Char)  ]]
  --no Return
  end

  --Assign ASCII mode range to generate random character
  local genRange = function()
    configMode()
    if not setup.saved then
      setup.caseMin = setup.modeA == 1 and 'A' or 'a'    --if mode=true then A else a
      setup.caseMax = setup.modeA == 1 and 'Z' or 'z'    --if mode=true then Z else z
    end    
  --no Return
  end

  --Generate random number function within the selected ASCII range
  local randChar = function()    
    genByte = math.random(tonumber(string.byte(setup.caseMin)), tonumber(string.byte(setup.caseMax)))
  --Returns generated Byte representation type=number
    return genByte
  end

--Create a question
  local getQuestion = function()     
    local genByte = randChar()    
    local question = nil   
    local question_prompt = {[1] = "ASCII Byte representation in [Decimal] for\nChar:\t\t",
                             [2] = "ASCII Byte representation in [Hexi-decimal] for\nChar:\t\t",
                             [3] = "ASCII Char representation from [Decimal] for\nByte:\t\t",
                             [4] = "ASCII Char representation from [Hexi-Decimal] for\nByte:\t\t"}       
    --Display prompt for each representation direction ASCII Char<-->Byte  
    if setup.modeR == 0 then 
      io.write(setup.modeC == 0 and question_prompt[1] or question_prompt[2])
      question = string.char(genByte)   
      io.write(question .. "\nByte:\t\t     ")    --string representing a Char
    else                                                                          
      io.write(setup.modeC == 0 and question_prompt[3] or question_prompt[4])      
      question = setup.modeC == 0 and question or string.format('%x', genByte)   
      io.write(question .. "\nChar:\t\t     ")    --string representing Byte in decimal or hex
    end 
  --Returns a string
    return tostring(question)
  end

--Generate the Answer given a Question
  local getAnswer = function ()
    local question = getQuestion()
    local answer = nil    
    --Display the answer given a question
    if setup.modeR == 0 then                                                         
      answer = setup.modeC == 0 and string.byte(question) or string.format('%x', tonumber(string.byte(question))) --string(byte)                
    else                                                                          
      answer = setup.modeC == 0 and string.char(question) or string.char(tonumber(question, 16))                  --string(char)        
    end    
  --Returns a string
    return question, tostring(answer)
  end

--Get user Attempt and compare to Answer
  local playGame = function()
    delay(0.25)
    local question, answer = getAnswer()
    local attempt = tostring(getNumber())
    local last_life, game_over = "\n\n\t\tLast Chance\t", "\n\n\t\tGame Over!!\nFinal Score\t"

    if attempt == answer then 
      io.write("Correct: ")
      setup:giveLife()
    else
      io.write("Wrong: ")
      setup:takeLife()      
    end              
    
    io.write("\t\t" .. question .. " = " .. answer .. '\n')    
    delay(0.75)
    clearTerminal()

    if setup.lives == 1 then io.write(last_life)
    elseif setup.lives == 0 then io.write(game_over)
    else 
      io.write("\n\n\t\tLIVES: " .. setup.lives .. '\t')
    end
    
    io.write(setup.score .. ":" .. setup.rounds .. '\n') 
    io.close()
    delay(0.25)    
    
----Where i left off----still need to do all 4 cases---------------------------------------------------------
    --[[if modeR == 0 then                                                             
      attempt = modeC == 0 and tostring(setup:getNumber()) or setup:getHexRep()         
    else                                                                               
      attempt = string.char(tonumber(io.read(), 16))                           
    end--]]
-------------------------------------------------------------------------------------------------------------
  end

--Continue playing prompt to restart game or exit
  local contPlay = function()
    --Get input to continue or exit 
    io.write("\n\n\t\tY/y to play again\t")
    local quit = tostring(io.read())

    --Explicit input
    if quit == "Y" or quit == "y" then 
      setup.status = true     
      setup.lives = 8  
      setup.score = 0
      setup.rounds = 0
      --Get input to save or reset game settings
      io.write("\nY/y to replay w/ same mode selections?\t")
      userInput = io.read()
      io.close()      
      --Explicit input
      if userInput == "Y" or userInput == "y" then 
        setup.saved = true else setup.saved = false
      end
    else
      setup.status = false    
    end    
    delay(1)
    clearTerminal()
  --no Return    
  end


--Update game
  setup.update = function(self)                
    clearTerminal() --clear screen
    repeat
      if self.saved == false then genRange() else io.write("\n\n\tModes unchanged\n") end
      io.write("\t\tGame On!!\n" .. self.scenes[8] .. '\n')
      io.close()
      while self.status == true do                    
        playGame()
        if self.lives ~= 0 then 
          io.write(self.scenes[self.lives] .. '\n')        
        else
          io.write(self.finalScene .. '\n')
        end
        io.close()
      end  
      contPlay()
    until self.status == false
  end

  return setup
end

--Main Body--------------------------------------------------------------------------------------------------
local game = Setup()
game:update()
-------------------------------------------------------------------------------------------------------------
