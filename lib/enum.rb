module ActiveRecord
  class Enum
    extend ActiveRecord::Enumerations::OptionsHelper
    
    attr_reader :id, :name
    
    def initialize attrs = {}
      @id = attrs.delete(:id).to_i
      @name = attrs.delete(:name).to_s
      @label = attrs.delete(:label)
      define_extra_attributes_as_methods attrs
    end
    
    def self.create_from value, values, options
      required_attrs = case value
      when String, Symbol
        { :name => value }
      else
        value
      end
      required_attrs[:id] ||= values.index(value) + 1
      new options.merge(required_attrs)
    end
    
    def == other
      return id == other.id if other.is_a?(Enum)
      [id.to_s, name].include?(other.to_s)
    end
    
    def to_s
      @label ||= respond_to?(:desc) ? :desc : :titleize
      self.respond_to?(@label) ? self.send(@label) : self.name.send(@label)
    end
    
    def to_sym
      name.to_sym
    end
    
    def define_question_methods all_enums
      all_enums.each do |enum|
        meta_def("#{enum.name}?") { self == enum }
      end
    end
    
    def self.enumeration *config, &block
      add_option config, :enum_class => self
      define_enums_getter Factory.make_enums(*config, &block)
    end
    
    def self.[] name_or_id
      all.detect { |enum| enum == name_or_id }
    end
    
    private
    def define_extra_attributes_as_methods attrs
      attrs.each do |method, value|
        meta_def(method) { value }
      end
    end    
    
    def self.define_enums_getter enums
      cattr_accessor :all
      self.all = enums
    end
  end
end
