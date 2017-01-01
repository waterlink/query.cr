module Query
  module CriteriaHelper
    def criteria(name)
      Criteria.new(name)
    end
  end

  module MacroHelper
    macro bi_operator(name, klass)
      def {{name.id}}(other)
        {{klass.id}}.new(self, other)
      end
    end

    macro u_operator(name, klass)
      def {{name.id}}
        {{klass.id}}.new(self)
      end
    end
  end

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
    include MacroHelper

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

    def inspect(io)
      io << "Query"
    end
  end

  class EmptyQuery < Query
    def inspect(io)
      io << "EMPTY_QUERY"
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
  end

  class BiOperator(Q, T) < Query
    getter left
    getter right

    def initialize(@left : Q, @right : T)
    end

    def ==(other : BiOperator(Q2, T2)) forall Q2, T2
      EqualityHelper.equals(left, other.left) &&
        EqualityHelper.equals(right, other.right)
    end

    def ==(other)
      false
    end

    def inspect(io)
      io << "#{self.class.name}<#{left.inspect}, #{right.inspect}>"
    end
  end

  class Equals(Q, T) < BiOperator(Q, T)
  end

  class NotEquals(Q, T) < BiOperator(Q, T)
  end

  class LessThan(Q, T) < BiOperator(Q, T)
  end

  class LessThanOrEqual(Q, T) < BiOperator(Q, T)
  end

  class MoreThan(Q, T) < BiOperator(Q, T)
  end

  class MoreThanOrEqual(Q, T) < BiOperator(Q, T)
  end

  class And(Q, T) < BiOperator(Q, T)
  end

  class Or(Q, T) < BiOperator(Q, T)
  end

  class Xor(Q, T) < BiOperator(Q, T)
  end

  class In(Q, T) < BiOperator(Q, T)
  end

  class UOperator(Q) < Query
    getter query

    def initialize(@query : Q)
    end

    def ==(other : UOperator(Q2)) forall Q2
      EqualityHelper.equals(query, other.query)
    end

    def ==(other)
      false
    end

    def inspect(io)
      io << "#{self.class.name}<#{query.inspect}>"
    end
  end

  class Not(Q) < UOperator(Q)
  end

  class IsTrue(Q) < UOperator(Q)
  end

  class IsNotTrue(Q) < UOperator(Q)
  end

  class IsFalse(Q) < UOperator(Q)
  end

  class IsNotFalse(Q) < UOperator(Q)
  end

  class IsUnknown(Q) < UOperator(Q)
  end

  class IsNotUnknown(Q) < UOperator(Q)
  end

  class IsNull(Q) < UOperator(Q)
  end

  class IsNotNull(Q) < UOperator(Q)
  end

  class Criteria < Query
    getter name

    def initialize(@name : String)
    end

    def inspect(io)
      io << "'#{name}'"
    end

    include MacroHelper
    bi_operator "==", Equals
    bi_operator "!=", NotEquals
    bi_operator "<", LessThan
    bi_operator "<=", LessThanOrEqual
    bi_operator ">", MoreThan
    bi_operator ">=", MoreThanOrEqual
    bi_operator "in", In
  end
end
