{-# LANGUAGE ForeignFunctionInterface, EmptyDataDecls #-}

-- | Drivers for 3Dconnexion devices

module Input.H3DConnexion
  ( start3DConn
  , stop3DConn
  ) where

import Foreign.C.Types
import Foreign.Ptr
import Foreign.Storable

foreign import ccall safe "c_3dconn.h setupConn"
  setupConn :: IO ()

start3DConn :: IO ()
start3DConn = do
  putStrLn "Start"
  setupConn

stop3DConn :: IO ()
stop3DConn = do
  putStrLn "Stop"

