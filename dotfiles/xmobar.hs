Config { 

   -- appearance
     font =         "TX-02 10"
   , additionalFonts = ["Noto Sans Display Nerd Font 12", 
                        "DejaVu Sans Mono Nerd Font 12", 
                        "Noto Sans Mono CJK JP 12", 
                        "Noto Color Emoji 12", 
                        "Noto Sans Hebrew 12"]
   , bgColor =      "#222222"
   , fgColor =      "#bbbbbb"
   , position =     Top
   , border =       NoBorder

   -- layout
   , sepChar =  "%"   -- delineator between plugin names and straight text
   , alignSep = "}{"  -- separator between left-right alignment
   , template = "%UnsafeXMonadLog% }{ %WM_NAME%"

   -- general behavior
   , lowerOnStart =     False    -- send to bottom of window stack on start
   , hideOnStart =      False   -- start with window unmapped (hidden)
   , allDesktops =      True    -- show on all desktops
   , overrideRedirect = True    -- set the Override Redirect flag (Xlib)
   , pickBroadest =     False   -- choose widest display (multi-monitor)
   , persistent =       False    -- enable/disable hiding (True = disabled)

   , commands = [ Run UnsafeXMonadLog,
                  Run XPropertyLog "WM_NAME" ]
}
