require "./spec_helper"

include Query::CriteriaHelper

module Query
  describe CriteriaHelper do
    it "can compare criteria to number" do
      (criteria("age") == 21).should eq(
        Equals[Criteria["age"], 21]
      )

      (criteria("age") != 21).should eq(
        NotEquals[Criteria["age"], 21]
      )

      (criteria("age") < 21).should eq(
        LessThan[Criteria["age"], 21]
      )

      (criteria("age") <= 21).should eq(
        LessThanOrEqual[Criteria["age"], 21]
      )

      (criteria("age") > 21).should eq(
        MoreThan[Criteria["age"], 21]
      )

      (criteria("age") >= 21).should eq(
        MoreThanOrEqual[Criteria["age"], 21]
      )
    end

    it "can compare criteria to a string" do
      (criteria("name") == "John Smith").should eq(
        Equals[Criteria["name"], "John Smith"]
      )
    end

    it "can compare criteria to another criteria" do
      (criteria("password") == criteria("confirmation")).should eq(
        Equals[Criteria["password"], Criteria["confirmation"]]
      )
    end
  end

  describe Not do
    it "negates query" do
      ((criteria("password") == criteria("confirmation")).not).should eq(
        Not[Equals[Criteria["password"], Criteria["confirmation"]]]
      )
    end

    it "negates other query" do
      ((criteria("name") != "John Smith").not).should eq(
        Not[NotEquals[Criteria["name"], "John Smith"]]
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
        And[(criteria("age") >= 21), (criteria("age") < 42)]
      )
    end

    it "is not the same as some other query with the same type signature" do
      ((criteria("age") >= 21) & (criteria("age") < 42)).should_not eq(
        And[(criteria("age") >= 19), (criteria("points") < 42)]
      )
    end

    it "can be used to append things in a LOOP from datastructure such as Hash" do
      q = EmptyQuery.new

      query_hash = {
        "number_of_dependents" => 0,
        "age" => 25,
        "stuff" => "hello world",
      }

      query_hash.each do |k, v|
        q = q.& criteria(k) == v
      end

      q.should eq(
        And[
          And[
            (criteria("number_of_dependents") == 0),
            (criteria("age") == 25)
          ],
          (criteria("stuff") == "hello world")
        ]
      )
    end
  end

  describe Or do
    it "can unify two queries" do
      ((criteria("age") < 16) | (criteria("age") > 64)).should eq(
        Or[(criteria("age") < 16), (criteria("age") > 64)]
      )
    end

    it "can be used to append things" do
      q = EmptyQuery.new
      q = q.| criteria("number_of_dependents") == 0
      q = q.| criteria("age") == 25
      q = q.| criteria("stuff") == "hello world"

      q.should eq(
        Or[
          Or[
            (criteria("number_of_dependents") == 0),
            (criteria("age") == 25)
          ],
          (criteria("stuff") == "hello world")
        ]
      )
    end
  end

  describe "combining And and Or" do
    it "can be used to append things with And and Or interchangeably" do
      q = EmptyQuery.new

      query_hash = {"number_of_dependents" => 0, "age" => 25, "stuff" => "hello world"}

      q = q.| criteria("number_of_dependents") == 0
      q = q.& criteria("age") == 25
      q = q.| criteria("stuff") == "hello world"

      q.should eq(
        Or[
          And[
            (criteria("number_of_dependents") == 0),
            (criteria("age") == 25)
          ],
          (criteria("stuff") == "hello world")
        ]
      )
    end
  end

  describe IsTrue do
    it "works" do
      (criteria("has_dependents").is_true).should eq(
        IsTrue[criteria("has_dependents")]
      )
    end
  end

  describe In do
    it "works" do
      (criteria("age").in([18, 19, 20, 21])).should eq(
        In[criteria("age"), [18, 19, 20, 21]]
      )
    end
  end

  describe Criteria do
    describe "equality" do
      it "is equal when names are equal" do
        one = criteria("age")
        two = criteria("age")
        one.should eq(two)
      end
    end
  end

  describe Equals do
    describe "equality" do
      it "is equal when both arguments are same" do
        one = Equals[criteria("age"), 21]
        two = Equals[criteria("age"), 21]
        one.should eq(two)
      end

      it "is not equal when first argument is not same" do
        one = Equals[criteria("age"), 21]
        two = Equals[criteria("strength"), 21]
        one.should_not eq(two)
      end

      it "is not equal when second argument is not same" do
        one = Equals[criteria("age"), 21]
        two = Equals[criteria("age"), 42]
        one.should_not eq(two)
      end
    end
  end
end
