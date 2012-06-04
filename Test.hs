
import Graphics.Rendering.OpenGL
import Graphics.UI.GLUT
import Data.IORef
import Control.Concurrent

import Input.H3DConnexion

import Cube

scaleTranslation :: GLdouble
scaleTranslation = 2e-3/1280.0
scaleRotation :: GLdouble
scaleRotation = 2e-3/4000.0

data ViewState = ViewState (Vector3 GLdouble) (Vector3 GLdouble)

{-reshape s@(Size w h) = do-}
  {-viewport $= (Position 0 0, s)-}
{-reshape screenSize@(Size w h) = do-}
  {-viewport $= ((Position 0 0), screenSize)-}
  {-matrixMode $= Projection-}
  {-loadIdentity-}
  {-let-}
    {-near   = 0-}
    {-far    = 80-}
    {-fov    = 90-}
    {-ang    = (fov*pi)/(360 :: Double)-}
    {-top    = near / ( cos(ang) / sin(ang) )-}
    {-aspect = fromIntegral(w)/fromIntegral(h)-}
    {-right  = top*aspect-}
  {-frustum (realToFrac (-right))-}
          {-(realToFrac right)-}
          {-(realToFrac (-top))-}
          {-(realToFrac top)-}
          {-(realToFrac near)-}
          {-(realToFrac far)-}
  {-print near-}
  {-matrixMode $= Modelview 0-}
  {-postRedisplay Nothing-}

reshape size@(Size w h) = do
   viewport $= (Position 0 0, size)
   matrixMode $= Projection
   loadIdentity
   perspective 40 (fromIntegral w / fromIntegral h) 0.1 100
   matrixMode $= Modelview 0
   loadIdentity
   postRedisplay Nothing

keyboardMouse key state modifiers position = return ()
keyboardMouse key state modifiers position = return ()

display mv = do
  clear [ColorBuffer]
  ViewState pos rot <- readMVar mv
  loadIdentity
  let Vector3 rx ry rz = rot
  rotate rx (Vector3 1 0 0)
  rotate ry (Vector3 0 1 0)
  rotate rz (Vector3 0 0 1)
  preservingMatrix $ do
    translate pos
    cube (0.2 :: GLdouble)
  flush

h3dcHandler :: ViewState -> Event -> ViewState
h3dcHandler (ViewState (Vector3 x y z) rv) e =
  ViewState (Vector3 x' y' z') (Vector3 rx ry rz)
  where
    dx = scaleTranslation * (fromIntegral (axisX e))
    dy = scaleTranslation * (fromIntegral (axisY e))
    dz = scaleTranslation * (fromIntegral (axisZ e))
    x' = x + dx
    y' = y - dy
    z' = z - dz
    rx = scaleRotation * (fromIntegral (axisU e))
    ry = scaleRotation * (fromIntegral (axisV e))
    rz = scaleRotation * (fromIntegral (axisW e))

idle = postRedisplay Nothing
idle2 mv c = do
  e <- pollAxes c
  old_vs <- takeMVar mv
  let new_vs = h3dcHandler old_vs e
  putMVar mv new_vs
  postRedisplay Nothing

nullEvtHandler e = do
  print e
  return ()

main = do
  (progname,_) <- getArgsAndInitialize
  createWindow "Hello World"
  shadeModel $= Smooth
  {-depthFunc $= Just Less-}
  lighting $= Enabled
  light (Light 0) $= Enabled
  ambient (Light 0) $= Color4 1 1 1 1
  materialDiffuse Front $= Color4 0.5 0.5 0.5 1
  materialSpecular Front $= Color4 1 1 1 1
  materialShininess Front $= 25
  colorMaterial $= Just (Front, Diffuse)

  let add_handler = putStrLn "HS Added"
  let rem_handler = putStrLn "HS Removed"
  mv <- newMVar $ ViewState (Vector3 (0::GLdouble) 0 0)
                            (Vector3 (0::GLdouble) 0 0)
  c <- start3DConn add_handler rem_handler nullEvtHandler
  displayCallback $= (display mv)
  reshapeCallback $= Just reshape
  idleCallback $= Just (idle2 mv c)
  keyboardMouseCallback $= Just keyboardMouse

  mainLoop
  stop3DConn c
