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
  
  zonelist = Hash.new()
  
  config.each_key { |targetDirectory|
    #zonelist.set("#{targetDirectory}", config[targetDirectory])
    zonelist = { targetDirectory => config[targetDirectory] }
    puts "#{targetDirectory} will contain #{zonelist.key(targetDirectory)}"
  }
end

read_config

