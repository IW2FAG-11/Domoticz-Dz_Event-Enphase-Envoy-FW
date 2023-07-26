-- Dott. Valsasina Andrea HamRadioCall IW2FAG
-- Not Tested on Windows
-- Tested in Rpi 3B+ with debian version 10.13
-- Close Ip connection with Firewall on router to lock Data Bleeding
-- Direzione   Origine       Protocollo Porta     Destinazione
-- OUT     <Indirizzo IP Envoy> TCP     80, 443   reports.enphaseenergy.com
-- OUT     <Indirizzo IP Envoy> UDP     80        ping-udp.enphaseenergy.com
-- OUT     <Indirizzo IP Envoy> TCP     80, 443   home.enphaseenergy.com
--
-- DZ_Event file to grab data from enphase gateway and send to mine device

local debug = false

return {
    on = {
        timer = {'every minutes'},
        httpResponses = { 'loggedin', 'data' }
    },
    execute = function(domoticz, item)
	
		local env_OS = os.getenv('OS')
        if env_OS == "Windows_NT" then
            json = (loadfile "C:\\Program Files (x86)\\Domoticz\\scripts\\lua\\json.lua")()  -- For Windows
        else
            json = (loadfile "/home/pi/domoticz/scripts/lua/JSON.lua")()  -- For Linux
        end
	
		
---------------------------- Legge il SN e la versione  ------------------------
        if (item.isTimer) then
            local http=require'socket.http'
            local body, statusCode, headers, statusText = http.request('http://<YOUR ENVOY_IP>/info.xml')
            if (statusCode == 200) then
                if debug then
                    print('statusCode ', statusCode)
                    print('statusText ', statusText)
                    print('headers ')
                    for index,value in pairs(headers) do
                        print("\t",index, value)
                    end
                        print('body',body)
                end
                
            -- Removes unwanted text
                if string.match(body, "<sn>") then
                    envoyserial = (body:match("<sn>([^/]+)</sn>"))
                else
                    envoyserial = 'not found'
                end 
                
                if string.match(body, "<software>") then
                    envoyfirmware = (body:match("<software>([^/]+)</software>"))
                else
                    envoyfirmware = 'not found'
                end

                print("-- ENPHASE envoy serial numb: " ..envoyserial)
                print("-- ENPHASE envoy firmware is: " ..envoyfirmware)
            end
		end
		
--------------------------------------------------------------------------------		
		-- if (item.isTimer) then
            -- login
        --    domoticz.openURL({
        --        url = 'http://<YOUR ENVOY_IP>/info.xml',
        --        method = 'GET',
        --        callback = 'data'
        --    })
        --end


        if (item.isTimer) then
            -- login
            domoticz.openURL({
                url = 'https://enlighten.enphaseenergy.com/login/login.json?',
                method = 'POST',
                postData = { ['username'] = '<YOUR enlight username>', ['password'] = '<YOUR enlight passwork>' },
                callback = 'loggedin'
            })
        end

        if (item.isHTTPResponse and item.ok) then
            -- check to which request this response was the result
            if (item.trigger == 'loggedin') then
                -- we are logged in, now grab the session token from the header and
                -- fetch our data
                local token = item.headers['x-session-token']
                -- now we have the token, put it in the headers:
                domoticz.openURL({
                    url = 'https://<YOUR ENVOY_IP>/production.json?',
                    method = 'GET',
                    headers = { ['x-session-token'] = token },
                    callback = 'data'
                })
            else
                -- it must the data we requested
				local data = item.data
                -- do something with it

                if (item.statusCode == 200) then
                    if (data ~= nil and data ~= "") then
                        local jsonData   = json:decode(data)
                        local wNow       = jsonData.consumption[1].wNow
                        local pwrFactor  = jsonData.consumption[1].pwrFactor
                        local reactPwr   = jsonData.consumption[1].reactPwr
                        local rmsVoltage = jsonData.production[2].rmsVoltage
                        local wNowP      = jsonData.production[2].wNow
                        local pwrFactorP = jsonData.production[2].pwrFactor
                        local reactPwrP  = jsonData.production[2].reactPwr

                        print("rmsVoltage :"..rmsVoltage)
                        local rmsVoltage = domoticz.utils.round(rmsVoltage, 0)
                        domoticz.devices('Voltage').updateVoltage(rmsVoltage)

						-- domoticz.notify('Fire', 'The room is on fire', domoticz.PRIORITY_EMERGENCY)
						print(" CONSUMO")
						wNow = domoticz.utils.round(wNow, 0)
						--domoticz.devices('H_Rele2').switchOn()
						--domoticz.devices('H_Rele2').dump()  -- Per leggere tutti i parametri del device
						print("wNow : "..wNow.."W pwrFactor : "..pwrFactor.." reactPwr : "..reactPwr.."W")
						if wNow < 0 then
							local wNow = 0
						end
						domoticz.devices('Consumo in').updateElectricity(wNow)
		
						print(" PRODUZIONE")
						local wNowP = domoticz.utils.round(wNowP, 0)
						print("wNow : "..wNowP.."W pwrFactor : "..pwrFactorP.." reactPwr : "..reactPwrP.."W")
						if (wNowP < 0) then
							local wNowP = 0
						end
						domoticz.devices('Generazione in').updateElectricity(wNowP)
		
						local disponibile = wNowP - wNow
						
						domoticz.devices('Power_Disponibile').updateElectricity(disponibile)
                
					else
						domoticz.devices('Consumo in').updateElectricity(0)
						domoticz.devices('Generazione in').updateElectricity(0)
						domoticz.devices('Power_Disponibile').updateElectricity(0)
					end
                end
            end
        end
    end
}
