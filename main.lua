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

        lives = 8,      --number of possible scenes/player lives
        status = true,  --status of active game 
        saved = false,  --save game configs upon reset
        modeA = 0,      --ASCII group
        modeC = 0,      --Conversion format
        modeR = 0,      --Representation direction
        caseMin = 0,    --Min byte rep of ASCII char 
        caseMax = 0,    --Max byte rep of ASCII char        

      --Update player lives left
        takeLife = function(self)
            self.lives = self.lives - 1     --take a life             
            if self.lives == 0 then self.status = false end   --flag game over
        end,

      --Update player scene based on current lives left
        dispScene = function(self) 
            print('\n\n' .. self.scenes[self.lives])
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
    local number = io.read("*n")    --first char is non#: nil --first non# char: ends read --wont accept empty string       
  --Returns the number user inputed
    return tonumber(number)
  end

  --Recursive function to get user input of type=string for hex
  local getHexRep = function(self)
    local hexstr = io.read(2)   --recalls if number is not hex or 2 digits
    if tonumber(hexstr, 16) == nil  or #hexstr ~= 2 then return self:getHexRep() end             
  --Returns the HEX string that user inputed
    return hexstr
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
    if setup.saved == 0 then
      setup.modeA = modeSel(1)                --mode for upper or lower case
      setup.modeC = modeSel(2)                --mode for decimal or hex case
      setup.modeR = modeSel(3)                --mode for direction of representation
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
    genRange()
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
      io.write(question .. "\nByte:\t     ")    --string representing a Char
    else                                                                          
      io.write(setup.modeC == 0 and question_prompt[3] or question_prompt[4])      
      question = setup.modeC == 0 and question or string.format('%x', genByte)   
      io.write(question .. "\nChar:\t     ")    --string representing Byte in decimal or hex
    end 
  --Returns a string
    return question
  end

--Generate the Answer given a Question
  local getAnswer = function ()
    local question = getQuestion()
    local answer = nil    
    --Display the answer given a question
    if setup.modeR == 0 then                                                         
      answer = setup.modeC == 0 and string.byte(question) or string.format('%x', tonumber(string.byte(question))) --string(byte)                
    else                                                                          
      answer = setup.modeC == 0 and string.char(question) or string.char(tonumber(question, 16))                                       --string(char)        
    end    
  --Returns a string
    return answer
  end

--Get user Attempt and compare to Answer
  local getAttempt = function()
    local answer = getAnswer()
    print(answer)
    --[[if modeR == 0 then                                                             
      attempt = modeC == 0 and tostring(setup:getNumber()) or setup:getHexRep()         
    else                                                                               
      attempt = string.char(tonumber(io.read(), 16))                           
    end--]]
  end

--Continue playing prompt to restart game or exit -- could add function to keep current settings and skip that part or not
  local contPlay = function()
    io.write("Y/y to play again\t")
    local userInput = io.read(1)    
    if userInput == "Y" or userInput == "y" then 
      setup.status = true     
      setup.lives = 8  
    end
    io.write("\nY/y to replay w/ same mode selections?\t")
    userInput = io.read(1)
    if userInput == "Y" or userInput == "y" then 
      setup.saved = true
    else
      setup.saved = false
    end
  end


--Update game
  setup.update = function()
    --while setup.status do
      while setup.status do
        getAttempt()
      end
      --[[contPlay()   
    end
    os.execute("clear")]]
  end


    --[[setup.update = function(self)      
        print("Game On!!\n\n" .. self.scenes[8])
--where i left off-------------------------------------------------------------------------------------------------------        
        
--where i left off-------------------------------------------------------------------------------------------------------       

        if attempt == answer then io.write("Correct: \t")
        else
            io.write("Wrong: \t")
            self:takeLife()
        end              
        io.write(string.char(question) .. " = " .. answer .. '\n')

        self:dispScene()
--where i left off-------------------------------------------------------------------------------------------------------    
    end  --]]

  

    return setup
end

--Main-------------------------------------------------------------------------------------------------------
local game = Setup()
game:update()



--print(tonumber(io.read(2), 16))
--print(io.read(2))
--print(string.char(tonumber(string.format('%x', 72) , 16)))
-------------------------------------------------------------------------------------------------------------

--[[ ASCII --  --  --[Char :  Byte(dec) : Byte(hex)]--  --  --  --  --  --  --  --  -|
|    A : 65  : 41     F : 70  : 46     K : 75  : 4b     P : 80  : 50    U : 85  : 55 |
|    B : 66  : 42     G : 71  : 47     L : 76  : 4c     Q : 81  : 51    V : 86  : 56 |
|    C : 67  : 43     H : 72  : 48     M : 77  : 4d     R : 82  : 52    W : 87  : 57 |
|    D : 68  : 44     I : 73  : 49     N : 78  : 4e     S : 83  : 53    X : 88  : 58 |
|    E : 69  : 45     J : 74  : 4a     O : 79  : 4f     T : 84  : 54    Y : 89  : 59 |
|                                                                       Z : 90  : 5a |
|-  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  -|  
|    a : 97  : 61     f : 102 : 66     k : 107 : 6b     p : 112 : 70    u : 117 : 75 |
|    b : 98  : 62     g : 103 : 67     l : 108 : 6c     q : 113 : 71    v : 118 : 76 |
|    c : 99  : 63     h : 104 : 68     m : 109 : 6d     r : 114 : 72    w : 119 : 77 |
|    d : 100 : 64     i : 105 : 69     n : 110 : 6e     s : 115 : 73    x : 120 : 78 |
|    e : 101 : 65     j : 106 : 6a     o : 111 : 6f     t : 116 : 74    y : 121 : 79 | 
|                                                                       z : 122 : 7a |
|-  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  -|  
--]]
    