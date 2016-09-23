require 'synapse_pay_rest/client'
require 'synapse_pay_rest/http_client'
require 'synapse_pay_rest/error'
require 'synapse_pay_rest/version'
# base API clients
require 'synapse_pay_rest/api/users'
require 'synapse_pay_rest/api/nodes'
require 'synapse_pay_rest/api/transactions'
# model abstractions
require 'synapse_pay_rest/cip_document'
require 'synapse_pay_rest/document'
require 'synapse_pay_rest/social_document'
require 'synapse_pay_rest/virtual_document'
require 'synapse_pay_rest/physical_document'
require 'synapse_pay_rest/user'
require 'synapse_pay_rest/node'
require 'synapse_pay_rest/transaction'
require 'pry'

module SynapsePayRest
  # deprecated classes
  def self.const_missing(const_name)
    super unless const_name == :Trans
    warn caller.first + " DEPRECATION WARNING: the class SynapsePayRest::#{const_name} is deprecated. Use SynapsePayRest::Transactions instead."
    Transactions
  end
end
