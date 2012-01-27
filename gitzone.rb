#!/usr/bin/env ruby

require 'rubygems'
require 'net/dns/resolver'
require 'yaml'

$res = Net::DNS::Resolver.new

=begin
zonelist.each do |zone,ns|
  res.nameserver=ns
  fullzone = res.axfr(zone)
  puts fullzone
end
=end

def read_config(cfgFile)
  config = YAML.load_file(cfgFile)
  
  zonehash = {}
  
  config.each_key do |location|
    zonepair = {}
    
    config[location].each do |zone,ns|
      zonepair.store(zone, ns)
    end
    
    zonehash.store(location, zonepair)
  end
  
  return zonehash
end

zonelist = read_config("config.yaml")

puts zonelist.inspect

zonelist.each_key do |location|
  puts "Working with #{location}"
  zonelist[location].each do |zone,ns|
    puts "Setting nameserver to #{ns}"
    $res.nameserver=ns
    puts "Performing AXFR of zone #{zone}"
    fullzone = $res.axfr("#{zone}")
    puts fullzone
  end
end
