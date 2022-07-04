
Config { 

   -- appearance
     font =         "xft:Noto Sans Display Nerd Font:size=10"
   , bgColor =      "#222222"
   , fgColor =      "#bbbbbb"
   , position =     Top
   , border =       NoBorder
   , borderColor =  "#222222"

   -- layout
   , sepChar =  "%"   -- delineator between plugin names and straight text
   , alignSep = "}{"  -- separator between left-right alignment
   , template = "%XMonadLog% }{ %WM_NAME%"

   -- general behavior
   , lowerOnStart =     True    -- send to bottom of window stack on start
   , hideOnStart =      False   -- start with window unmapped (hidden)
   , allDesktops =      True    -- show on all desktops
   , overrideRedirect = True    -- set the Override Redirect flag (Xlib)
   , pickBroadest =     False   -- choose widest display (multi-monitor)
   , persistent =       True    -- enable/disable hiding (True = disabled)

   , commands = [ Run XMonadLog,
                  Run XPropertyLog "WM_NAME" ]
   }
