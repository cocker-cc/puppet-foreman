# Query Foreman in order to resolv a smart variable
# Foreman holds all the value names and their possible values,
# this function simply ask foreman for the right value for this host.


require "cgi"
require "net/http"
require "net/https"
require "uri"
require "timeout"

module Puppet::Parser::Functions
  newfunction(:smartvar, :type => :rvalue) do |args|
    #URL to query
    foreman_url  = "http://foreman"
    foreman_user = "admin"
    foreman_pass = "changeme"

    var = args[0]
    raise Puppet::ParseError, "Must provide a variable name to search for" if var.nil?

    fqdn = lookupvar("fqdn")

    uri = URI.parse(foreman_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'

    path = "/hosts/#{CGI.escape(fqdn)}/lookup_keys/#{CGI.escape(var)}"
    req = Net::HTTP::Get.new(path)
    req.basic_auth(foreman_user, foreman_pass)
    req['Content-Type'] = 'application/json'
    req['Accept'] = 'application/json'

    begin
      Timeout::timeout(5) { PSON.parse(http.request(req).body)["value"] }
    rescue Exception => e
      raise Puppet::ParseError, "Failed to contact Foreman #{e}"
    end

  end
end
