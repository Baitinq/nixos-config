import System.IO
import System.Exit

import qualified Data.List as L
import qualified Data.Map  as M

import XMonad

import qualified XMonad.StackSet as W

import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ServerMode
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.EwmhDesktops

import XMonad.Layout.Gaps
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances

import XMonad.Actions.CycleWS

import XMonad.Util.ClickableWorkspaces

------------------------------------------------------------------------
-- Workspaces
-- The default number of workspaces (virtual screens) and their names.
--
myWorkspaces :: [String]
myWorkspaces = map show [1..9]


------------------------------------------------------------------------
-- Window rules
-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [
    ]



------------------------------------------------------------------------
-- Layouts
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.

gap         = 7

myGaps       = gaps [(U, gap), (R, gap), (L, gap), (D, gap)]
addSpace     = spacing gap

tiledLayout = tiled
                where
                  -- default tiling algorithm partitions the screen into two panes
                  tiled   = Tall nmaster delta ratio

                  -- The default number of windows in the master pane
                  nmaster = 1

                  -- Default proportion of screen occupied by master pane
                  ratio   = 1/2

                  -- Percent of screen to increment by when resizing panes
                  delta   = 3/100

layouts      =  tiledLayout

myLayout    = mkToggle (NOBORDERS ?? NBFULL ?? EOT)
              $ avoidStruts $ myGaps $ addSpace
              $ layouts

------------------------------------------------------------------------
-- Colors and borders

-- Width of the window border in pixels.
myBorderWidth = 1

myNormalBorderColor     = "#000000"
myFocusedBorderColor    = "#005577"

--This sets the "_NET_WM_STATE_FULLSCREEN" window property, helping some programs such as firefox to adjust acoordingly to fullscreen mode
--In a perfect world we shouldnt need to do this manually but it seems like ewmhFullscreen/others dont implement this functionality
setFullscreenProp :: Bool -> Window -> X ()
setFullscreenProp b win = withDisplay $ \dpy -> do
                      state  <- getAtom "_NET_WM_STATE"
                      fullsc <- getAtom "_NET_WM_STATE_FULLSCREEN"
                      if b
                        then io $ changeProperty32 dpy win state 4 propModeReplace [fromIntegral fullsc]
                        else io $ changeProperty32 dpy win state 4 propModeReplace []

--Hide xmobar -> Hide borders -> Set fullscreen -> Set fullscreenprops
toggleFullScreen :: X ()
toggleFullScreen = do
                    mIsFullScreen <- withWindowSet (isToggleActive NBFULL . W.workspace . W.current)
                    case mIsFullScreen of
                      Just isFullScreen -> if isFullScreen
                                            then withFocused (setFullscreenProp False) >> sendMessage (Toggle NBFULL) >> sendMessage ToggleStruts 
                                            else sendMessage ToggleStruts >> sendMessage (Toggle NBFULL)  >> withFocused (setFullscreenProp True)
                      Nothing -> return ()


    ------------------------------------------------------------------------
-- External commands
myCommands :: [(String, X ())]
myCommands =
        [ ("decrease-master-size"      , sendMessage Shrink                               )
        , ("increase-master-size"      , sendMessage Expand                               )
        , ("decrease-master-count"     , sendMessage $ IncMasterN (-1)                    )
        , ("increase-master-count"     , sendMessage $ IncMasterN ( 1)                    )
        , ("focus-prev"                , windows W.focusUp                                )
        , ("focus-next"                , windows W.focusDown                              )
        , ("focus-master"              , windows W.focusMaster                            )
        , ("swap-with-prev"            , windows W.swapUp                                 )
        , ("swap-with-next"            , windows W.swapDown                               )
        , ("swap-with-master"          , windows W.swapMaster                             )
        , ("togglefullscreen"          , toggleFullScreen                                 )
        , ("togglefloating"            , withFocused toggleFloat                          )
        , ("next-layout"               , sendMessage NextLayout                           )
        , ("cycle-workspace"           , toggleWS                                         )
        , ("kill-window"               , kill                                             )
        , ("quit"                      , io $ exitWith ExitSuccess                        )
        , ("restart"                   , spawn "xmonad --recompile; xmonad --restart"     )
        ]

-----------------------------------------------------------------------
-- Custom server mode

myServerModeEventHook = serverModeEventHookCmd' $ return myCommands'
myCommands' = ("list-commands", listMyServerCmds) : myCommands ++ wscs ++ sccs -- ++ spcs
    where
        wscs = [((m ++ s), windows $f s) | s <- myWorkspaces
               , (f, m) <- [(W.view, "focus-workspace-"), (W.shift, "send-to-workspace-")] ]

        sccs = [((m ++ show sc), screenWorkspace (fromIntegral sc) >>= flip whenJust (windows . f))
               | sc <- [0..10], (f, m) <- [(W.view, "focus-screen-"), (W.shift, "send-to-screen-")]]

listMyServerCmds :: X ()
listMyServerCmds = spawn ("echo '" ++ asmc ++ "' | xmessage -file -")
    where asmc = concat $ "Available commands:" : map (\(x, _)-> "    " ++ x) myCommands'

------------------------------------------------------------------------
-- Mouse bindings
--
-- Focus rules
-- True if your focus should follow your mouse cursor.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

toggleFloat w = windows (\s -> if M.member w (W.floating s)
                            then W.sink w s
                            else (W.float w (W.RationalRect 0.125 0.125 0.75 0.75) s))

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
  [
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modMask, button1),
     (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Toggle float on the window
    , ((modMask, button2),
       (\w -> focus w >> toggleFloat w))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3),
       (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
  ]

------------------------------------------------------------------------
-- Run xmonad with all the defaults we set up.
--

myStatusBar = statusBarProp "xmobar" (do 
                                        numWindows <- getNumberOfWindowsInWorkpace
                                        return $ xmobarPP {
                                                    ppCurrent = if numWindows > 0
                                                                        then xmobarBorder "Top" "#bbbbbb" 4 . xmobarColor "#bbbbbb" "#005577" . wrap "  " "  "
                                                                        else xmobarColor "#bbbbbb" "#005577" . wrap "  " "  "
                                                  , ppTitle = id
                                                  , ppSep = " |  "
                                                  , ppLayout = (\_ -> "")
                                                  , ppHidden = (\s -> clickableWrap ((read s::Int) - 1) (createDwmBox "#bbbbbb" ("  " ++ s ++ "  "))) --better way to clickablewrap . 
                                                  , ppHiddenNoWindows = (\s -> clickableWrap ((read s::Int) - 1) ("  " ++ s ++ "  "))
                                          }
                                      )
                                      where
                                        getNumberOfWindowsInWorkpace = withWindowSet (pure . length . W.index)
                                        createDwmBox color prefix = "<box type=HBoth offset=L19 color="++color++"><box type=Top mt=3 color="++color++"><box type=Top color="++color++">" ++ prefix ++ "</box></box></box>"

main :: IO ()
main = do
  xmonad . withSB myStatusBar . docks . ewmhFullscreen . ewmh
         $ def {
                focusFollowsMouse  = myFocusFollowsMouse,
                borderWidth        = myBorderWidth,
                workspaces         = myWorkspaces,
                normalBorderColor  = myNormalBorderColor,
                focusedBorderColor = myFocusedBorderColor,

                mouseBindings      = myMouseBindings,

                layoutHook         = myLayout,
                handleEventHook    = myServerModeEventHook,
                manageHook         = myManageHook
                }