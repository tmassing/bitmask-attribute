require 'active_support/core_ext'
require 'active_record'
require 'bitmask_attribute/value_proxy'
require 'bitmask_attribute/definition'

module BitmaskAttribute

  def self.included(model)
    model.extend ClassMethods
  end
    
  module ClassMethods
    
    def bitmask(attribute, options={}, &extension)
      unless options[:as] && options[:as].kind_of?(Array)
        raise ArgumentError, "Must provide an Array :as option"
      end
      bitmask_definitions[attribute] = BitmaskAttribute::Definition.new(attribute, options[:as].to_a, &extension)
      bitmask_definitions[attribute].install_on(self)
    end
    
    def bitmask_definitions
      @bitmask_definitions ||= {}
    end
    
    def bitmasks
      @bitmasks ||= {}
    end
      
  end
  
end

ActiveRecord::Base.instance_eval { include BitmaskAttribute }