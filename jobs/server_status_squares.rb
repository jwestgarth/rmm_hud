#!/usr/bin/env ruby
require 'net/http'
require 'uri'
 
#
### Global Config
#
# httptimeout => Number in seconds for HTTP Timeout. Set to ruby default of 60 seconds.
# ping_count => Number of pings to perform for the ping method
#
httptimeout = 60
ping_count = 10

# 
# Check whether a server is Responding you can set a server to 
# check via http request or ping
#
# Server Options
#   name
#       => The name of the Server Status Tile to Update
#   url
#       => Either a website url or an IP address. Do not include https:// when using ping method.
#   method
#       => http
#       => ping
#
# Notes:
#   => If the server you're checking redirects (from http to https for example) 
#      the check will return false
#
servers = [
    {name: 'sss-gateway', url: '192.168.1.1', method: 'ping'},
    {name: 'sss-reddit', url: 'http://www.reddit.com/', method: 'http'},
    {name: 'sss-github', url: 'https://github.com/', method: 'http'},
    {name: 'sss-brokenserver', url: '192.168.1.100', method: 'ping'},
]
 
SCHEDULER.every '1m', :first_in => 0 do |job|
    servers.each do |server|
        if server[:method] == 'http'
            begin
                uri = URI.parse(server[:url])
                http = Net::HTTP.new(uri.host, uri.port)
                http.read_timeout = httptimeout
                if uri.scheme == "https"
                    http.use_ssl=true
                    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
                end
                request = Net::HTTP::Get.new(uri.request_uri)
                response = http.request(request)
                if response.code == "200"
                    result = 1
                else
                    result = 0
                end
            rescue Timeout::Error
                result = 0
            rescue Errno::ETIMEDOUT
                result = 0
            rescue Errno::EHOSTUNREACH
                result = 0
            rescue Errno::ECONNREFUSED
                result = 0
            rescue SocketError => e
                result = 0
            end
        elsif server[:method] == 'ping'
            result = `ping -q -c #{ping_count} #{server[:url]}`
            if ($?.exitstatus == 0)
                result = 1
            else
                result = 0
            end
        end

        send_event(server[:name], result: result)
    end
end