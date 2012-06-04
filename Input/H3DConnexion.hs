{-# LANGUAGE ForeignFunctionInterface #-}

-- | Drivers for 3Dconnexion devices

module Input.H3DConnexion
  ( start3DConn
  , stop3DConn
  , pollAxes
  , axisX
  , axisY
  , axisZ
  , axisU
  , axisV
  , axisW
  , Event(..)
  , H3DConn
  ) where

import Foreign.C.Types
import Foreign.Ptr
import Foreign.Marshal.Array
import Foreign.Storable
import Control.Monad
import Control.Concurrent

data Event = Axis {
              axisX :: Int,
              axisY :: Int,
              axisZ :: Int,
              axisU :: Int,
              axisV :: Int,
              axisW :: Int
           }
           | Button
  deriving Show

data H3DConn = H3DConn (MVar Event) ThreadId

foreign import ccall "wrapper"
  wrapVoid :: IO () -> IO (FunPtr (IO ()))
foreign import ccall "wrapper"
  wrapEventHandler :: (Ptr CShort -> IO ()) ->
                      IO (FunPtr (Ptr CShort -> IO ()))

foreign import ccall safe "c_3dconn.h setupConn"
  setupConn :: FunPtr (IO ()) ->
               FunPtr (IO ()) ->
               FunPtr (Ptr CShort -> IO ()) ->
               IO ()

makeEventHandler :: MVar Event -> (Event -> IO ()) -> Ptr CShort -> IO ()
makeEventHandler mv handler axes = do
  [x,y,z,u,v,w] <- liftM (map fromIntegral) $ peekArray 6 axes
  let evt = Axis x y z u v w
  swapMVar mv evt
  handler evt

start3DConn :: IO () ->             -- ^ Added handler
               IO () ->             -- ^ Removed handler
               (Event -> IO ()) ->  -- ^ Event handler
               IO H3DConn
start3DConn add_handler rem_handler evt_handler = do
  a <- wrapVoid add_handler
  r <- wrapVoid rem_handler
  mv <- newMVar $ Axis 0 0 0 0 0 0
  e <- wrapEventHandler $ makeEventHandler mv evt_handler
  tid <- forkOS $ setupConn a r e
  return $ H3DConn mv tid

pollAxes :: H3DConn -> IO Event
pollAxes (H3DConn mv _) = readMVar mv

stop3DConn :: H3DConn -> IO ()
stop3DConn c = do
  putStrLn "Stop"

