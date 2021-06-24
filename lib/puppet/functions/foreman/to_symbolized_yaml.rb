# frozen_string_literal: true

require 'yaml'
# @summary
#   Convert a data structure and output it as YAML while symbolizing keys
#
# In Foreman often YAML files have symbols as keys. Since it's hard to do that
# from Puppet, this function does it for you.
#
# @example How to output YAML
#   # output yaml to a file
#     file { '/tmp/my.yaml':
#       ensure  => file,
#       content => foreman::to_symbolized_yaml($myhash),
#     }
# @example Use options control the output format
#   file { '/tmp/my.yaml':
#     ensure  => file,
#     content => foreman::to_symbolized_yaml($myhash, {indentation: 4})
#   }
Puppet::Functions.create_function(:'foreman::to_symbolized_yaml') do
  # @param data
  # @param options
  #
  # @return [String]
  dispatch :to_symbolized_yaml do
    param 'Any', :data
    optional_param 'Hash', :options
    # this is only for Testing-Reasons, because Rspec cannot test sensitive Returnvalues
    optional_param 'Boolean', :sensitive
  end

  def to_symbolized_yaml(data, options = {}, sensitive = true)
    # data eventually contains Elements of Datatype Sensitive
    data_unsensitive = deep_unwrap(data)

    # actually symbolize the Firstlevel-Keys
    if data_unsensitive.is_a?(Hash)
      data_unsensitive = Hash[data_unsensitive.map { |k, v| [k.to_sym, v] }]
    end

    # we return the YAML as Datatype Sensitive, if the Input contains Elements of Datatype Sensitive
    if sensitive && has_sensitive_value(data)
      Puppet::Pops::Types::PSensitiveType::Sensitive.new(data_unsensitive.to_yaml(options))
    else
      data_unsensitive.to_yaml(options)
    end
  end

  ### Helper-Functions

  def has_sensitive_value(data)
    found = false
    if data.is_a?(Hash)
      data.each do |key, val|
        found = true if has_sensitive_value(val)
      end
    elsif data.is_a?(Array)
      data.each do |val|
        found = true if has_sensitive_value(val)
      end
    elsif data.respond_to?(:unwrap)
      found = true
    else
      # do nothing; keep current Value of Variable found
    end

    found
  end

  def deep_unwrap(data)
    if data.is_a?(Hash)
      data.map do |key, val|
        [key, deep_unwrap(val)]
      end.to_h
    elsif data.is_a?(Array)
      data.map do |val|
        deep_unwrap(val)
      end
    elsif data.respond_to?(:unwrap)
      data.unwrap
    else
      data
    end
  end
end
