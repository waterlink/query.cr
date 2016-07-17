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

  module Query
    abstract def inspect(io)

    def not
      Not.new(self)
    end

    include MacroHelper
    bi_operator "&", And
  end

  class EmptyQuery
    include Query

    def inspect(io)
      io << "EMPTY_QUERY"
    end
  end

  class BiOperator(T)
    include Query

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
      io << "#{self.class.name}<#{left.inspect}, #{right.inspect}>"
    end
  end

  class Equals(T) < BiOperator(T)
  end

  class NotEquals(T) < BiOperator(T)
  end

  class LessThan(T) < BiOperator(T)
  end

  class LessThanOrEqual(T) < BiOperator(T)
  end

  class MoreThan(T) < BiOperator(T)
  end

  class MoreThanOrEqual(T) < BiOperator(T)
  end

  class And(T) < BiOperator(T)
  end

  class Not
    include Query

    getter query

    def initialize(@query : Query)
    end

    def ==(other : self)
      EqualityHelper.equals(query, other.query)
    end

    def ==(other)
      false
    end

    def inspect(io)
      io << "Not<#{query.inspect}>"
    end
  end

  class Criteria
    include Query

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
  end
end
