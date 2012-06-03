
/* Required to prevent c2hs choking on OS X header blocks. */
#undef __BLOCKS__

#include <stdio.h>

/*#include <MacTypes.h>*/
#include <CoreServices/CoreServices.h>
#include <3DconnexionClient/ConnexionClient.h>
#include <3DconnexionClient/ConnexionClientAPI.h>

static void AddedDevice(io_connect_t connection)
{
   printf("added device\n");
}

static void RemovedDevice(io_connect_t connection)
{
   printf("removed device\n");
}

static void HandleMessage(io_connect_t connection, natural_t messageType, void *messageArgument)
{
   ConnexionDeviceStatePtr msg;

   msg = (ConnexionDeviceStatePtr)messageArgument;

   switch(messageType) {
      case kConnexionMsgDeviceState:
         switch (msg->command) {
            case kConnexionCmdHandleAxis:
               printf("%d, %d, %d, %d, %d, %d\n",
                     msg->axis[0], msg->axis[1], msg->axis[2],
                     msg->axis[3], msg->axis[4], msg->axis[5]);
               break;
            case kConnexionCmdHandleButtons:
               printf("msg->value: %d\n", msg->value);
               printf("msg->buttons: %d\n", msg->buttons);
               break;
         }
         break;
   }
}

void setupConn()
{
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


