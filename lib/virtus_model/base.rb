require 'virtus'
require 'active_model'

module VirtusModel
  class Base
    include ActiveModel::Model
    include Virtus.model

    set_callback :validate, :validate_associations

    # Get an array of attribute names.
    def self.attributes
      attribute_set.map(&:name)
    end

    # Is there an attribute with the provided name?
    def self.attribute?(name)
      attributes.include?(name)
    end

    # Is there an association with the provided name and type (optional)?
    def self.association?(name, *types)
      associations(*types).include?(name)
    end

    # Get an array of association names by type (optional).
    def self.associations(*types)
      classes = {
        one: Virtus::Attribute::EmbeddedValue,
        many: Virtus::Attribute::Collection
      }.select do |type, _|
        types.empty? || types.include?(type)
      end

      attribute_set.select do |field|
        classes.any? { |_, cls| field.class <= cls }
      end.map(&:name)
    end

    # Initialize attributes using the provided hash or object.
    def initialize(model = nil)
      assign_attributes(model)
    end

    # Recursively update attributes and return a self-reference.
    def assign_attributes(model)
      self.attributes = self.class.attributes.reduce({}) do |result, name|
        if model.respond_to?(name)
          result[name] = model.public_send(name)
        elsif model.respond_to?(:[])
          result[name] = model[name]
        end
        result
      end
      self
    end

    # Update attributes and validate.
    def update(model = nil, options = {})
      assign_attributes(model)
      validate(options)
    end

    # Two models are equal if their attributes are equal.
    def ==(other)
      if other.respond_to?(:attributes)
        self.attributes == other.attributes
      else
        self.attributes == other
      end
    end

    # Recursively convert all attributes to hash pairs.
    def export(options = nil)
      self.class.attributes.reduce({}) do |result, name|
        value = attributes[name]
        if self.class.association?(name, :many)
          result[name] = value ? value.map(&:export) : nil
        elsif self.class.association?(name, :one)
          result[name] = value ? value.export : nil
        else
          result[name] = value
        end
        result
      end
    end

    # Alias of #export.
    def to_hash(options = nil)
      export(options)
    end

    # Alias of #to_hash.
    def to_h(options = nil)
      to_hash(options)
    end

    # Alias of #export.
    def as_json(options = nil)
      export(options)
    end

    # Convert the #as_json result to JSON.
    def to_json(options = nil)
      as_json(options).to_json
    end

    protected

    # Validate all associations by type and import resulting errors.
    def validate_associations
      validate_associations_one
      validate_associations_many
    end

    # Validate "has_one" associations and import errors.
    def validate_associations_one
      self.class.associations(:one).each do |name|
        import_errors(name, attributes[name])
      end
    end

    # Validate "has_many" associations and import errors.
    def validate_associations_many
      self.class.associations(:many).each do |name|
        values = attributes[name] || []
        values.each.with_index do |value, index|
          import_errors("#{name}[#{index}]", value)
        end
      end
    end

    # Merge associated errors using the current validation context.
    def import_errors(name, model)
      return unless model.respond_to?(:validate)
      return if model.validate(validation_context)
      model.errors.each do |field, error|
        errors.add("#{name}[#{field}]", error)
      end
    end
  end
end