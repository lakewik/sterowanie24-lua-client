busid = 0  -- I2C Bus ID. Zawsze zero
sda= 4     -- numer pinu SDA (GPIO2)
scl= 3     -- numer pinu SCL (GPIO0)
addr=0x20  -- adres i2c naszego pcf
led = 0;  
-- Init i2c
i2c.setup(busid,sda,scl,i2c.SLOW)
-- Odczytywanie z expandera
function read_pcf8574(dev_addr)
     i2c.start(busid)
     i2c.address(busid, dev_addr , i2c.RECEIVER)
     bdata = i2c.read(busid,1)  -- Reads one byte
     i2c.stop(busid)
     return bdata
end
 

function write_pcf8574(dev_addr, value)
     i2c.start(busid)
     i2c.address(busid, dev_addr, i2c.TRANSMITTER)
     i2c.write(busid,value)
     i2c.stop(busid)
end
 



wifi.setmode(wifi.STATION)
wifi.sta.config("Lakewik AP3","Your_WiFi_Password")
print(wifi.sta.getip())
led1 = 3
led2 = 4

--gpio.mode(led1, gpio.OUTPUT)
--gpio.mode(led2, gpio.OUTPUT)
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        buf = buf.."<h1> ESP8266 Web Server</h1>";
        buf = buf.."<p>GPIO0 <a href=\"?pin=ON1\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF1\"><button>OFF</button></a></p>";
        buf = buf.."<p>GPIO2 <a href=\"?pin=ON2\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF2\"><button>OFF</button></a></p>";
        local _on,_off = "",""
	    write_pcf8574(0x20,  tonumber(_GET.pin))
        write_pcf8574(0x21,  tonumber(_GET.pinb))
        write_pcf8574(0x23,  tonumber(_GET.pinc))
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)

