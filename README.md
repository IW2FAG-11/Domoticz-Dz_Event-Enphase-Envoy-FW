# Domoticz Dz_Event Enphase Envoy
## Description
This is a little DzEvent Domoticz script to grab consumption and prodution data from Envoy inverters.
I do this because other plugin is not stable and Integrated Domoticz plugin does not report correct data. 

## Motivation            

Enphase sends production and consumption data to amazon's AWS IoT servers using the mqtt service without our
explicit consent.
I decided to isolate the inverter from the network and manage production and consumption data locally in order
to optimize home consumption through home automation.

With their recent latest firmware update, version D7, obviously carried out remotely without being notified and
therefore modifying, as things stand, what was bought about a year ago without my approval.

As for me, as if they came to your house and changed the color of a car door without telling you ninete, in my
opinion it is a blatant modification of the characteristics of the object I had purchased.

Probably because of the ease of remote access to the system have at their sole discretion MODIFIED sil my object
to ensure security.

I proceeded to isolate the gateway of my microinverters through firewalls and with a scrip DzEvent and then catch
the data, asking their servers, every minute the necessary token.

Do I generate traffic injecting their servers ? Problems them, mosquitoes we should all do in order to re-enable
local access without too much and make sure that it is the local user to ask for update and not and is done
remotely in a sibylline way, modifying in fact what we had purchased.

