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
  config.each_key { |targetDirectory|
    zonelist = config[targetDirectory]
    puts "#{targetDirectory} will contain #{zonelist}"
  }
end

read_config

