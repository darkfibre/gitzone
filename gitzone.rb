#!/usr/bin/env ruby

require 'rubygems'
require 'net/dns/resolver'
require 'yaml'

$res = Net::DNS::Resolver.new


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
    $res.nameserver=ns
    puts "Performing AXFR of zone #{zone}"
    fullzone = $res.axfr("#{zone}")
    puts fullzone
  end
end
