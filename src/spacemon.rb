#!/usr/bin/env ruby

require 'elasticsearch'
require 'logger'
require 'awesome_print'
require 'socket'
require 'optimist'

INDEXNAME = "diskspace"
TYPENAME = "diskspace"

#START MAIN
opts = Optimist::options do
  opt :elasticsearch, "Elasticsearch hosts", :type=>:string
  opt :filter, "Only include these filesystems. Specify as a regex.", :type=>:string
end

lines = `df -P`.split(/\n/)

have_header = false
header = []

content = []

lines.each {|line|
  if not have_header
    header = line.split(/\s+/)
    have_header = true
    next
  end

  parts = /^(.*\S)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)%\s+(.*)$/.match(line)
  if parts
    data = Hash[header.zip(parts.captures)]
    data.each {|k,v|
    begin
      data[k] = Integer(v)
    rescue StandardError
    end

    }
    data['Hostname'] = Socket.gethostname
    data['Timestamp'] = DateTime.now
    content << data
  end

  }

if opts.filter
  ap opts.filter
  matcher = Regexp.compile(opts[:filter])
  filtered_content = content.filter { |entry|
    matcher.match(entry["Mounted"])
  }
else
  filtered_content = content
end

ap filtered_content

if opts.elasticsearch
  es = Elasticsearch::Client.new(:hosts=>opts.elasticsearch)
  result=es.cluster.health

  ops = []
  filtered_content.each do |entry|
    ops << {index: {_index: INDEXNAME, _type: TYPENAME, data: entry}}
  end
  es.bulk(body: ops)
end
