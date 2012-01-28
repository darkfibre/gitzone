#!/usr/bin/env ruby

require 'rubygems'
require 'dnsruby'
require 'yaml'

$res = Dnsruby::ZoneTransfer.new
$res.transfer_type = Dnsruby::Types.AXFR

def read_config(cfgFile)
  config = YAML.load_file(cfgFile)
  
  configHash = {}
  
  config.each_key do |location|
    zonepair = {}
    
    config[location].each do |zone,ns|
      zonepair.store(zone, ns)
    end
    
    configHash.store(location, zonepair)
  end
  
  return configHash
end

zoneList = read_config("config.yaml")

puts zoneList.inspect

zoneList.each_key do |location|
  puts "Working with #{location}"
  
  zoneList[location].each do |zone,ns|
    puts "Setting nameserver to #{ns}"
    $res.server = ns
    
    puts "Performing AXFR of zone #{zone}"
    fullzone = $res.transfer("#{zone}")
    
    if(fullzone)
      fullzone.each do |rr|
        puts rr.inspect
      end
    end
  end
end
