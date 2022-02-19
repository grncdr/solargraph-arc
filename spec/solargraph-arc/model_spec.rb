require 'spec_helper'

RSpec.describe Solargraph::Arc::Model do
  let(:api_map) { Solargraph::ApiMap.new }

  it "generates methods for singular association" do
    load_string 'app/models/transaction.rb', <<-RUBY
      class Transaction < ActiveRecord::Base
        belongs_to :account
        has_one :category
      end
    RUBY

    assert_public_instance_method(api_map, "Transaction#account", ["Account"]) do |pin|
      expect(pin.location.range.to_hash).to eq({
        :start => { :line => 1, :character => 0 },
        :end => { :line=>1, :character => 8 }
      })
    end

    assert_public_instance_method(api_map, "Transaction#category", ["Category"])
  end

  it "generates methods for association with custom class_name" do
    load_string 'app/models/transaction.rb', <<-RUBY
      class Transaction < ActiveRecord::Base
        belongs_to :account, class_name: 'CustomAccount'
      end
    RUBY

    assert_public_instance_method(api_map, "Transaction#account", ["CustomAccount"])
  end

  it "generates methods for plural associations" do
    load_string 'app/models/account.rb', <<-RUBY
      class Account < ActiveRecord::Base
        has_many :transactions
        has_and_belongs_to_many :things
      end
    RUBY

    assert_public_instance_method(
      api_map,
      "Account#transactions",
      ["ActiveRecord::Associations::CollectionProxy<Transaction>"]
    )
    assert_public_instance_method(
      api_map,
      "Account#things",
      ["ActiveRecord::Associations::CollectionProxy<Thing>"]
    )
  end

  it "generates methods for scope" do
    load_string 'app/models/transaction.rb', <<-RUBY
      class Transaction < ActiveRecord::Base
        scope :positive, ->(arg) { where(foo: "bar")}
      end
    RUBY

    assert_class_method(
      api_map,
      "Transaction.positive",
      ["Class<Transaction>"]
    )
  end

  it "generates scope methods with parameters" do
    load_string 'app/models/person.rb', <<-RUBY
      class Person < ActiveRecord::Base
        scope :taller_than, ->(min_height) { where("height > ?", min_height) }
      end
    RUBY

    assert_class_method(
      api_map,
      "Person.taller_than",
      ["Class<Person>"]
    ) do |pin|
      expect(pin.parameters).not_to be_empty
      expect(pin.parameters.first.name).to eq("min_height")
    end
  end
end

