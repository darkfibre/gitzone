#!/usr/bin/env ruby

require 'rubygems'
require 'net/dns/resolver'
require 'yaml'

res = Net::DNS::Resolver.new()

zonelist = ReaderYAML.new('zonelist.yaml')


zonelist.each do |zone,ns|
  res.nameserver=ns
  fullzone = res.axfr(zone)
  puts fullzone
end


class ReaderYAML
  def initialize(file)
    lines File.read(file)
    @h = YAML::load(lines)
  end
end
