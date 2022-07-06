import System.IO
import System.Exit

import qualified Data.List as L

import XMonad
import XMonad.Actions.Navigation2D
import XMonad.Actions.UpdatePointer

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName

import XMonad.Layout.Gaps
import XMonad.Layout.Fullscreen
import XMonad.Layout.BinarySpacePartition as BSP
import XMonad.Layout.NoBorders
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Spacing
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoFrillsDecoration
import XMonad.Layout.Renamed
import XMonad.Layout.Simplest
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.ZoomRow

import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Cursor

import Graphics.X11.ExtraTypes.XF86
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import XMonad.Hooks.ServerMode
import XMonad.Actions.WorkspaceNames

import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP

import XMonad.Actions.CycleWS

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
      isFullscreen --> (doF W.focusDown <+> doFullFloat)
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
addSpace     = renamed [CutWordsLeft 2] . spacing gap

tiledLayout = renamed [Replace "[]"]  $ tiled
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

myLayout    = smartBorders
              $ mkToggle (NOBORDERS ?? FULL ?? EOT)
              $ avoidStruts $ myGaps $ addSpace
              $ layouts

------------------------------------------------------------------------
-- Colors and borders

-- Width of the window border in pixels.
myBorderWidth = 1

myNormalBorderColor     = "#000000"
myFocusedBorderColor    = "#005577"

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
        , ("togglefullscreen"          , sendMessage $ Toggle FULL                        )
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

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
  [
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modMask, button1),
     (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2),
       (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3),
       (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
  ]

------------------------------------------------------------------------
-- Run xmonad with all the defaults we set up.
--

getNumberOfWindowsInWorkpace :: X Int
getNumberOfWindowsInWorkpace = withWindowSet (pure . length . W.index)

myStatusBar = statusBarProp "xmobar" (do 
                                        numWindows <- getNumberOfWindowsInWorkpace
                                        return $ xmobarPP {
                                                    ppCurrent = if numWindows > 0
                                                                        then xmobarBorder "Top" "#bbbbbb" 4 . xmobarColor "#bbbbbb" "#005577" . wrap "  " "  "
                                                                        else xmobarColor "#bbbbbb" "#005577" . wrap "  " "  "
                                                  , ppTitle = id
                                                  , ppSep = " |  "
                                                  , ppLayout = (\_ -> "")
                                                  , ppHidden = createDwmBox "#bbbbbb" . wrap "  " "  "
                                                  , ppHiddenNoWindows = wrap "  " "  "
                                          }
                                      )
                                      where
                                        createDwmBox color prefix = "<box type=HBoth offset=L19 color="++color++"><box type=Top mt=3 color="++color++"><box type=Top color="++color++">" ++ prefix ++ "</box></box></box>"

main :: IO ()
main = do
  xmonad . withSB myStatusBar . docks
         $ def {
                focusFollowsMouse  = myFocusFollowsMouse,
                borderWidth        = myBorderWidth,
                workspaces         = myWorkspaces,
                normalBorderColor  = myNormalBorderColor,
                focusedBorderColor = myFocusedBorderColor,

                mouseBindings      = myMouseBindings,

                layoutHook         = myLayout,
                handleEventHook    = fullscreenEventHook <+> myServerModeEventHook,
                manageHook         = manageDocks <+> myManageHook
                }