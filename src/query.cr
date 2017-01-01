module Query
  module CriteriaHelper
    def criteria(name)
      Criteria[name]
    end
  end

  module MacroHelper
    macro bi_operator(name, klass)
      def {{name.id}}(other)
        {{klass.id}}[self, other]
      end
    end

    macro u_operator(name, klass)
      def {{name.id}}
        {{klass.id}}[self]
      end
    end
  end

  module EqualityHelper
    def self.equals(left : Query, right : Query)
      if left.query_name != "Criteria"
        return left == right
      end

      if right.query_name != "Criteria"
        return false
      end

      left.left == right.left
    end

    def self.equals(left, right)
      left == right
    end
  end

  abstract class Any
    abstract def inspect(io)
    abstract def to_s(io)
    abstract def equals(other)
    abstract def value

    def ==(other)
      equals(other)
    end

    def self.any_or_query(value : Query)
      value
    end

    def self.any_or_query(value : Any)
      value
    end

    def self.any_or_query(value : T) forall T
      AnyImp(T).new(value)
    end

    def self.value_of(value : Any)
      value.value
    end

    def self.value_of(value : T) forall T
      value
    end
  end

  class AnyImp(T) < Any
    getter value

    def initialize(@value : T)
    end

    def inspect(io)
      value.inspect(io)
    end

    def to_s(io)
      value.to_s(io)
    end

    def equals(other)
      if other.is_a?(AnyImp)
        value == other.value
      else
        value == other
      end
    end
  end

  class Query
    include MacroHelper

    getter query_name
    getter left
    getter right

    def initialize(@query_name : String, @left : Query|Any, @right : Query|Any)
    end

    def self.new_u_query(query_name, left : L) forall L
      Query.new(query_name, left, AnyImp(Nil).new(nil))
    end

    bi_operator "&", And
    bi_operator "and", And
    bi_operator "|", Or
    bi_operator "or", Or
    bi_operator "xor", Xor
    bi_operator "^", Xor

    u_operator "not", Not

    u_operator "is_true", IsTrue
    u_operator "is_not_true", IsNotTrue
    u_operator "is_false", IsFalse
    u_operator "is_not_false", IsNotFalse
    u_operator "is_unknown", IsUnknown
    u_operator "is_not_unknown", IsNotUnknown
    u_operator "is_null", IsNull
    u_operator "is_not_null", IsNotNull

    def ==(other : Query)
      query_name == other.query_name &&
        EqualityHelper.equals(left, other.left) &&
        EqualityHelper.equals(right, other.right)
    end

    def ==(other)
      false
    end

    def inspect(io)
      io << query_name

      if !left.nil?
        io << "<"
        io << left.inspect

        if !right.nil?
          io << ", "
          io << right.inspect
        end

        io << ">"
      end

    end
  end

  class EmptyQuery < Query
    def initialize
      @query_name = "EMPTY_QUERY"
      @left = AnyImp(Nil).new(nil)
      @right = AnyImp(Nil).new(nil)
    end

    def self.[]
      EmptyQuery.new
    end

    macro empty_bi_operator(name)
      def {{name.id}}(other) : Query
        other
      end
    end

    empty_bi_operator "&"
    empty_bi_operator "and"
    empty_bi_operator "|"
    empty_bi_operator "or"

    def not : Query
      self
    end

    def inspect(io)
      io << "EMPTY_QUERY"
    end
  end

  macro bi_query(name)
    class {{ name.id }}
      def self.[](left, right)
        Query.new({{ name.id.stringify }}, Any.any_or_query(left), Any.any_or_query(right))
      end
    end
  end

  macro u_query(name)
    class {{ name.id }}
      def self.[](left)
        Query.new_u_query({{ name.id.stringify }}, Any.any_or_query(left))
      end
    end
  end

  bi_query Equals
  bi_query NotEquals
  bi_query LessThan
  bi_query LessThanOrEqual
  bi_query MoreThan
  bi_query MoreThanOrEqual
  bi_query And
  bi_query Or
  bi_query Xor
  bi_query In

  u_query Not
  u_query IsTrue
  u_query IsNotTrue
  u_query IsFalse
  u_query IsNotFalse
  u_query IsUnknown
  u_query IsNotUnknown
  u_query IsNull
  u_query IsNotNull

  class Criteria < Query
    def initialize(name : String)
      @query_name = "Criteria"
      @left = AnyImp(String).new(name)
      @right = AnyImp(Nil).new(nil)
    end

    def self.[](name)
      Criteria.new(name)
    end

    include MacroHelper
    bi_operator "==", Equals
    bi_operator "!=", NotEquals
    bi_operator "<", LessThan
    bi_operator "<=", LessThanOrEqual
    bi_operator ">", MoreThan
    bi_operator ">=", MoreThanOrEqual
    bi_operator "in", In

    def name
      Any.value_of(left)
    end
  end
end
