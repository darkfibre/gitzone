require 'rubygems'
require 'net/dns/resolver'

res = Net::DNS::Resolver.new()

zonelist = { "example.com" => "1.2.3.4", "example2.com" => "2.3.4.5" }

zonelist.each { |zone,ns|
  puts "#{zone} is at #{ns}"
}

