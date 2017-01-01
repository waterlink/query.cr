# query

Query abstraction.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  query:
    github: waterlink/query.cr
    version: ~> 0.2
```

## Usage

```crystal
require "query"

include Query::CriteriaHelper
```

## `criteria(name)`

```crystal
criteria("first_name")
```

## Comparison (`==`, `!=`, `<`, `<=`, `>`, `>=`)

```crystal
criteria("first_name") == "John"    # => Equals<first_name, John>
criteria("second_name") != "Smith"  # => NotEquals<second_name, Smith>
criteria("age") < 24                # => LessThan<age, 24>
criteria("age") <= 24               # => LessThanOrEqual<age, 24>
criteria("age") > 24                # => MoreThan<age, 24>
criteria("age") >= 24               # => MoreThanOrEqual<age, 24>
```

## Inclusion (`in`)

```crystal
criteria("first_name").in(["John", "Bob"])  # => In<first_name, ["John", "Bob"]>
```

## Special (`is_true`, `is_not_true`, `is_false`, `is_not_false`, `is_unknown`, `is_not_unknown`, `is_null`, `is_not_null`)

```crystal
criteria("verified").is_true          # => IsTrue<verified>
criteria("verified").is_not_true      # => IsNotTrue<verified>
criteria("verified").is_false         # => IsFalse<verified>
criteria("verified").is_not_false     # => IsNotFalse<verified>
criteria("age").is_unknown            # => IsUnknown<age>
criteria("age").is_not_unknown        # => IsNotUnknown<age>
criteria("email").is_null             # => IsNull<email>
criteria("email").is_not_null         # => IsNotNull<email>
```

## Logic (`not`, `and`, `&`, `or`, `|`, `xor`, `^`)

```crystal
(criteria("age") > 21).not    # => Not<MoreThan<age, 21>>

(criteria("age") > 27).and (criteria("age") < 35)
# => And<MoreThan<age, 27>, LessThan<age, 35>>

(criteria("age") > 27) & (criteria("age") < 35)
# => And<MoreThan<age, 27>, LessThan<age, 35>>

(criteria("age") < 27).or (criteria("age") > 35)
# => Or<LessThan<age, 27>, MoreThan<age, 35>>

(criteria("age") < 27) | (criteria("age") > 35)
# => Or<LessThan<age, 27>, MoreThan<age, 35>>

(criteria("age") > 27).xor (criteria("age") < 35)
# => Xor<MoreThan<age, 27>, LessThan<age, 35>>

(criteria("age") > 27) ^ (criteria("age") < 35)
# => Xor<MoreThan<age, 27>, LessThan<age, 35>>
```

## Contributing

1. Fork it ( https://github.com/waterlink/query.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [waterlink](https://github.com/waterlink) Oleksii Fedorov - creator, maintainer
