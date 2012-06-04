
#include <stdio.h>

#include <CoreServices/CoreServices.h>
#include <3DconnexionClient/ConnexionClient.h>
#include <3DconnexionClient/ConnexionClientAPI.h>

typedef void(*VoidFunPtr)(void);
typedef void(*EventHandlerFunPtr)(int* a);

VoidFunPtr add = NULL;
VoidFunPtr rem = NULL;
EventHandlerFunPtr evt = NULL;

static void AddedDevice(io_connect_t connection)
{
   if (add)
     (*add)();
}

static void RemovedDevice(io_connect_t connection)
{
   if (rem)
     (*rem)();
}

static void HandleMessage(io_connect_t connection, natural_t messageType, void *messageArgument)
{
   ConnexionDeviceStatePtr msg;

   msg = (ConnexionDeviceStatePtr)messageArgument;

   switch(messageType) {
      case kConnexionMsgDeviceState:
         switch (msg->command) {
            case kConnexionCmdHandleAxis:
               if (evt)
                 (*evt)(msg->axis);
               break;
            case kConnexionCmdHandleButtons:
               printf("msg->value: %d\n", msg->value);
               printf("msg->buttons: %d\n", msg->buttons);
               break;
         }
         break;
   }
}

void setupConn(VoidFunPtr myadd, VoidFunPtr myrem, EventHandlerFunPtr myevt)
{
   add = myadd;
   rem = myrem;
   evt = myevt;
   OSErr err = InstallConnexionHandlers (HandleMessage, AddedDevice, RemovedDevice);
   UInt32 signature = kConnexionClientWildcard;
   UInt8 *name = "Haskell";
   UInt16 mode = kConnexionClientModeTakeOver;
   UInt32 mask = kConnexionMaskAll;
   UInt16 myID = RegisterConnexionClient(signature, name, mode, mask);
   CFRunLoopRun();
   UnregisterConnexionClient(myID);
   CleanupConnexionHandlers();
}


