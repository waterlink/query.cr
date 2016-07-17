require "spec"

module EqualityHelper
  def self.equals(left : Criteria, right : Criteria)
    left.name == right.name
  end

  def self.equals(left : Criteria, right)
    false
  end

  def self.equals(left, right)
    left == right
  end
end

class Query
  def &(other) : Query
    And.new(self, other)
  end

  def not : Query
    Not.new(self)
  end

  def inspect(io)
    io << "Query"
  end
end

class EmptyQuery < Query
  def ==(other : EmptyQuery)
    true
  end

  def ==(other)
    false
  end

  def inspect(io)
    io << "EMPTY_QUERY"
  end
end

class BiOperator(T) < Query
  getter left
  getter right

  def initialize(@left : Query, @right : T)
  end

  def ==(other : self)
    EqualityHelper.equals(left, other.left) &&
      EqualityHelper.equals(right, other.right)
  end

  def ==(other)
    false
  end

  def inspect(io)
    io << "#{self.class.name}(#{left.inspect}, #{right.inspect})"
  end
end

class And(T) < BiOperator(T)
end

class Equals(T) < BiOperator(T)
end

class Not < Query
  getter query

  def initialize(@query : Query)
  end

  def ==(other : self)
    EqualityHelper.equals(query, other.query)
  end

  def inspect(io)
    io << "Not(#{query.inspect})"
  end
end

class Criteria < Query
  getter name

  def initialize(@name : String)
  end

  def ==(other) : Query
    Equals.new(self, other)
  end

  def inspect(io)
    io << "Criteria(#{name.inspect})"
  end
end

def criteria(name)
  Criteria.new(name)
end

it "can be used to append things" do
  q = EmptyQuery.new
  query_hash = {"number_of_dependents" => 0}

  query_hash.each do |key, value|
    q = q.& criteria(key) == value
  end

  pp typeof(q)

  q.should eq(
    And.new(EmptyQuery.new, Equals.new(Criteria.new("number_of_dependents"), 0))
  )
end

it "can be used to compare criteria to criteria" do
  q = criteria("id") == criteria("other.id")
  q.should eq(
    Equals.new(Criteria.new("id"), Criteria.new("other.id"))
  )
end

it "can be negated" do
  q = criteria("id") == criteria("other.id")
  pp typeof(q)
  q.not.should eq(
    Not.new(Equals.new(Criteria.new("id"), Criteria.new("other.id")))
  )
end
