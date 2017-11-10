# VirtusModel [![Build Status](https://travis-ci.org/derek-schaefer/virtus_model.svg)](https://travis-ci.org/derek-schaefer/virtus_model)

A practical and pleasant union of [Virtus](https://rubygems.org/gems/virtus) and [ActiveModel](https://rubygems.org/gems/activemodel).

## Installation

Ruby version 2.0.0 or greater is required.

```shell
$ gem install virtus_model
```

## Examples

First, familiarize yourself with the Virtus and ActiveModel libraries.

```ruby
#
# Class definitions
#

class ModelOne < VirtusModel::Base
  attribute :name, String

  validates :name, presence: true
end

class ModelTwo < VirtusModel::Base
  attribute :models, Array[ModelOne]

  validates :models, presence: true
end

#
# Class methods
#

raise unless ModelOne.attributes == [:name]

raise unless ModelOne.attribute?(:name)

raise if ModelOne.attribute?(:other)

raise unless ModelTwo.associations == [:models]

raise unless ModelTwo.association?(:models)

raise if ModelTwo.association?(:other)

#
# Instance methods
#

model1 = ModelOne.new(name: 'hello')

raise unless model1.attributes == { name: 'hello' }

raise unless model1.valid?

model1.assign_attributes(name: nil)

raise if model1.valid?

raise unless model1.errors[:name] == ["can't be blank"]

raise unless model1.update(name: 'hello')

model2 = ModelTwo.new(models: [model1.attributes])

raise unless model2.valid?

model2.assign_attributes(models: [])

raise if model2.valid?

raise unless model2.errors[:models] == ["can't be blank"]

raise if model2.update(models: [{ name: nil }])

raise unless model2.errors[:'models[0][name]'] == ["can't be blank"]

raise unless model2.update(models: [model1])

raise unless model2.export == { models: [{ name: 'hello' }] }

raise unless ModelTwo.new(model2.export) == model2
```
