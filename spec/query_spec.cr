require "./spec_helper"

include Query::CriteriaHelper

module Query
  describe CriteriaHelper do
    it "can compare criteria to number" do
      (criteria("age") == 21).should eq(
        Equals.new(Criteria.new("age"), 21)
      )

      (criteria("age") != 21).should eq(
        NotEquals.new(Criteria.new("age"), 21)
      )

      (criteria("age") < 21).should eq(
        LessThan.new(Criteria.new("age"), 21)
      )

      (criteria("age") <= 21).should eq(
        LessThanOrEqual.new(Criteria.new("age"), 21)
      )

      (criteria("age") > 21).should eq(
        MoreThan.new(Criteria.new("age"), 21)
      )

      (criteria("age") >= 21).should eq(
        MoreThanOrEqual.new(Criteria.new("age"), 21)
      )
    end

    it "can compare criteria to a string" do
      (criteria("name") == "John Smith").should eq(
        Equals.new(Criteria.new("name"), "John Smith")
      )
    end

    it "can compare criteria to another criteria" do
      (criteria("password") == criteria("confirmation")).should eq(
        Equals.new(Criteria.new("password"), Criteria.new("confirmation"))
      )
    end
  end

  describe Not do
    it "negates query" do
      ((criteria("password") == criteria("confirmation")).not).should eq(
        Not.new(Equals.new(Criteria.new("password"), Criteria.new("confirmation")))
      )
    end

    it "negates other query" do
      ((criteria("name") != "John Smith").not).should eq(
        Not.new(NotEquals.new(Criteria.new("name"), "John Smith"))
      )
    end

    it "is not the same as some other query with the same type signature" do
      ((criteria("password") == criteria("confirmation")).not).should_not eq(
        (criteria("name") == criteria("other_name")).not
      )
    end
  end

  describe And do
    it "can intersect two queries" do
      ((criteria("age") >= 21) & (criteria("age") < 42)).should eq(
        And.new((criteria("age") >= 21), (criteria("age") < 42))
      )
    end

    it "is not the same as some other query with the same type signature" do
      ((criteria("age") >= 21) & (criteria("age") < 42)).should_not eq(
        And.new((criteria("age") >= 19), (criteria("points") < 42))
      )
    end

    # it "can be used to append things" do
    #   q = EmptyQuery.new
    #   query_hash = {"number_of_dependents" => 0}
    #
    #   query_hash.each do |key, value|
    #     q = q.& criteria(key) == value
    #   end
    #
    #   q.should eq(
    #     Equals.new(Criteria.new("number_of_dependents"), 0)
    #   )
    # end
  end

  describe Equals do
    describe "equality" do
      it "is equal when both arguments are same" do
        one = Equals.new(criteria("age"), 21)
        two = Equals.new(criteria("age"), 21)
        one.should eq(two)
      end

      it "is not equal when first argument is not same" do
        one = Equals.new(criteria("age"), 21)
        two = Equals.new(criteria("strength"), 21)
        one.should_not eq(two)
      end

      it "is not equal when second argument is not same" do
        one = Equals.new(criteria("age"), 21)
        two = Equals.new(criteria("age"), 42)
        one.should_not eq(two)
      end
    end
  end
end
