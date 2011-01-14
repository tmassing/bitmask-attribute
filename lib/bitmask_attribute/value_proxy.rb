module BitmaskAttribute

  class ValueProxy < Array
      
    def initialize(record, attribute, &extension)
      @record = record
      @attribute = attribute
      find_mapping
      instance_eval(&extension) if extension
      super(extract_values)
    end
    
    # =========================
    # = OVERRIDE TO SERIALIZE =
    # =========================
    
    %w(<< push).each do |override|
      class_eval(<<-EOEVAL)
        def #{override}(*args)
          super.tap do
            updated!
          end
        end
      EOEVAL
    end
    
    def replace(other_ary)
      unsupported_attribute_error_check(other_ary.reject { |i| @mapping.key? i })
      super.tap do
        updated!
      end
    end
    
    def to_i
      inject(0) { |memo, value| memo | @mapping[value] }
    end
  
    #######
    private
    #######
    
    def updated!
      validate!
      uniq!
      serialize!
    end
    
    def validate!
      return if empty?
      errors = []
      dup.each do |value|
        unless @mapping.key? value
          errors << delete(value)
        end
      end
      unsupported_attribute_error_check(errors)
    end
    
    def serialize!
      @record.send(:write_attribute, @attribute, to_i)
    end
  
    def extract_values
      stored = [@record.send(:read_attribute, @attribute) || 0, 0].max
      @mapping.inject([]) do |values, (value, bitmask)|
        values.tap do
          values << value.to_sym if (stored & bitmask > 0)
        end
      end        
    end
    
    def find_mapping
      unless (@mapping = @record.class.bitmasks[@attribute])
        raise ArgumentError, "Could not find mapping for bitmask attribute :#{@attribute}"
      end
    end
    
    def unsupported_attribute_error_check(errors)
      raise ArgumentError, "Unsupported #{"value".pluralize} for '#{@attribute}': #{errors}" unless errors.empty?
    end
      
  end

end
