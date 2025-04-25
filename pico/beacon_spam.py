import gc
import sys
import random
import network
import uasyncio as asyncio
from machine import Pin

# Helper to detect uasyncio v3
IS_UASYNCIO_V3 = hasattr(asyncio, "__version__") and asyncio.__version__ >= (3,)

wifi_interface = network.WLAN(network.AP_IF)


def start_access_point(ssid):
    """Starts Wi-Fi AP mode with the specified SSID."""
    wifi_interface.active(False)
    wifi_interface.config(essid=ssid, security=0)
    wifi_interface.active(True)


class BeaconSpamApp:
    def __init__(self, ssid_list):
        self.ssid_list = ssid_list
        self.current_index = 0
        self.stop_requested = False

    def setup_button_interrupts(self):
        """Set up button interrupts to stop the app."""
        button_left = Pin(13, Pin.IN, Pin.PULL_UP)
        button_left.irq(trigger=Pin.IRQ_FALLING, handler=self.request_stop)

    def request_stop(self, pin):
        """Handler to set the stop_requested flag."""
        self.stop_requested = True

    async def start(self):
        """Start the beacon spam loop."""
        # Get the event loop
        loop = asyncio.get_event_loop()

        # Add global exception handler
        if IS_UASYNCIO_V3:
            loop.set_exception_handler(self._handle_exception)

        # Set up button interrupts
        self.setup_button_interrupts()

        # Start broadcasting SSIDs
        while not self.stop_requested:
            ssid = self.ssid_list[self.current_index]
            print(f"Broadcasting SSID: {ssid}")
            start_access_point(ssid)
            self.current_index = (self.current_index + 1) % len(self.ssid_list)

        # Stop the Wi-Fi AP
        self.stop()

    @staticmethod
    def _handle_exception(loop, context):
        """Global exception handler for uasyncio v3."""
        sys.print_exception(context["exception"])
        sys.exit()

    def stop(self):
        """Stop the Wi-Fi AP."""
        print("Stopping beacon spam...")
        wifi_interface.active(False)


try:
    ssids = []
    for _ in range(100):
        i = random.randint(10000, 99999)
        ssids.append(f"AmongUs-{i}")
    
    app = BeaconSpamApp(ssids)
    if IS_UASYNCIO_V3:
        asyncio.run(app.start())
    else:
        loop = asyncio.get_event_loop()
        loop.run_until_complete(app.start())
except Exception as e:
    sys.print_exception(e)
finally:
    if IS_UASYNCIO_V3:
        asyncio.new_event_loop()  # Clear retained state
