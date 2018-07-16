#!/usr/bin/env ruby

require 'nmap/xml'
require 'trollop'
require 'pp'
require 'csv'
require 'yaml'


opts = Trollop::options do
	opt :csv, "Output to CSV", :type => :string
	opt :nmap, "Nmap XML", :type => :string
	opt :toscreen, "Output to screen"
	opt :liveiponly, "Output to screen hosts with at least one open port"
	opt :livescript, "Output only hosts which have output from a script called X", :type => :string
	opt :port, "Hosts with a certain port open", :type => :integer

end

if opts[:toscreen]
	Nmap::XML.new(opts[:nmap]) do |xml|
		puts "IP\tDNS Name\tPort number\tPort protocol\tPort state\tPort service"
	  xml.each_host do |host|
	    host.each_port do |port|
	      puts "#{host.ip}\t#{host}\t#{port.number}\t#{port.protocol}\t#{port.state}\t#{port.service}"
	  	end
	  end
	end
end

if opts[:csv]
	CSV.open(opts[:csv] + ".csv", "w+") do |csv|
		Nmap::XML.new(opts[:nmap]) do |xml|
			csv << ["IP", "DNS Name", "Port number", "Port protocol", "Port state", "Port service", "Notes"]
			xml.each_host do |host|
				host.each_port do |port|
					csv << [host.ip, host, port.number, port.protocol, port.state, port.service]
				end
			end
		end
	end
end


if opts[:liveiponly]
	live = []
	Nmap::XML.new(opts[:nmap]) do |xml|
		xml.each_host do |host|
			islive = false
			host.each_port do |port|
				if port.state == :open
					islive = true
				end
			end
			if islive == true
				live << host.ip
			end
		end
	end
	puts live
end

if opts[:livescript]
	live = []
	Nmap::XML.new(opts[:nmap]) do |xml|
		xml.each_host do |host|
			islive = false
			host.each_port do |port|
				port.scripts.each do |k, v|
					if k == opts[:livescript]
						unless v.nil?
							islive = true
						end
					end
				end
			end
			if islive == true
				live << host.ip
			end
		end
	end
	puts live
end

if opts[:port]
	open = []
	Nmap::XML.new(opts[:nmap]) do |xml|
		xml.each_host do |host|
			host.each_port do |port|
				if port.number == opts[:port] and port.state == :open
					puts host.ip
				end
			end
		end
	end
end
