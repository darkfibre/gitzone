#!/usr/bin/env ruby

require 'rubygems'
require 'net/dns/resolver'
require 'yaml'

res = Net::DNS::Resolver.new()

#zonelist = ReaderYAML.new('config.yaml')

#puts zonelist

=begin
zonelist.each do |zone,ns|
  res.nameserver=ns
  fullzone = res.axfr(zone)
  puts fullzone
end
=end

def read_config
  config = YAML.load_file("config.yaml")
  
  @zonelist = {}
  
  config.each_key do |location|

    config[location].each do |zone,ns|
      @zonelist.store(location, zone => ns)
    end
    
  end
end

read_config

puts @zonelist.inspect

