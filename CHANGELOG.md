# Change Log

## [v4.2.1](https://github.com/twingly/twingly-amqp/tree/v4.2.1) (2016-11-17)
[Full Changelog](https://github.com/twingly/twingly-amqp/compare/v4.2.0...v4.2.1)

**Fixed bugs:**

- Undefined method `configuration' for Twingly::AMQP:Module \(NoMethodError\) [\#59](https://github.com/twingly/twingly-amqp/issues/59)

## [v4.2.0](https://github.com/twingly/twingly-amqp/tree/v4.2.0) (2016-11-16)
[Full Changelog](https://github.com/twingly/twingly-amqp/compare/v4.1.0...v4.2.0)

**Implemented enhancements:**

- Improve release documentation and changelog [\#52](https://github.com/twingly/twingly-amqp/issues/52)
- Guidelines how to test applications that use this library [\#11](https://github.com/twingly/twingly-amqp/issues/11)

**Fixed bugs:**

- Using default host variable results in "Can't modify frozen array" error [\#53](https://github.com/twingly/twingly-amqp/issues/53)
- Timeout threshold too low, increase or refactor? [\#44](https://github.com/twingly/twingly-amqp/issues/44)
- Test suite not reliable? [\#42](https://github.com/twingly/twingly-amqp/issues/42)

**Closed issues:**

- Log exceptions happening in on\_exception [\#46](https://github.com/twingly/twingly-amqp/issues/46)
- Add class for publishing messages [\#12](https://github.com/twingly/twingly-amqp/issues/12)

**Merged pull requests:**

- Rename QueuePublisher to DefaultExchangePublisher [\#58](https://github.com/twingly/twingly-amqp/pull/58) ([walro](https://github.com/walro))
- Make sure using default host doesn't raise error [\#55](https://github.com/twingly/twingly-amqp/pull/55) ([roback](https://github.com/roback))
- Improve release instructions and update change log [\#54](https://github.com/twingly/twingly-amqp/pull/54) ([walro](https://github.com/walro))
- Add TopicExchangePublisher class [\#51](https://github.com/twingly/twingly-amqp/pull/51) ([walro](https://github.com/walro))
- Remove sleeping in specs [\#50](https://github.com/twingly/twingly-amqp/pull/50) ([walro](https://github.com/walro))
- Configure pattern and ability to set logger [\#49](https://github.com/twingly/twingly-amqp/pull/49) ([walro](https://github.com/walro))
- Add RuboCop [\#48](https://github.com/twingly/twingly-amqp/pull/48) ([walro](https://github.com/walro))
- Introduce class for publishing to queues [\#47](https://github.com/twingly/twingly-amqp/pull/47) ([walro](https://github.com/walro))
- Minor improvements and fix unreliable test case [\#43](https://github.com/twingly/twingly-amqp/pull/43) ([walro](https://github.com/walro))
- Add instance documentation to README [\#41](https://github.com/twingly/twingly-amqp/pull/41) ([walro](https://github.com/walro))
- Split specs into integration and unit directories [\#38](https://github.com/twingly/twingly-amqp/pull/38) ([dentarg](https://github.com/dentarg))

## [v4.1.0](https://github.com/twingly/twingly-amqp/tree/v4.1.0) (2015-12-09)
[Full Changelog](https://github.com/twingly/twingly-amqp/compare/v4.0.0...v4.1.0)

**Merged pull requests:**

- Set expiration per ping [\#37](https://github.com/twingly/twingly-amqp/pull/37) ([roback](https://github.com/roback))

## [v4.0.0](https://github.com/twingly/twingly-amqp/tree/v4.0.0) (2015-12-08)
[Full Changelog](https://github.com/twingly/twingly-amqp/compare/v3.3.0...v4.0.0)

**Implemented enhancements:**

- Rename Twingly::AMQP::Ping to Pinger [\#33](https://github.com/twingly/twingly-amqp/issues/33)
- Add changelog [\#32](https://github.com/twingly/twingly-amqp/issues/32)
- Rename Twingly::AMQP::Subscription\#subscribe [\#28](https://github.com/twingly/twingly-amqp/issues/28)
- Improve test for Session.new without arguments [\#16](https://github.com/twingly/twingly-amqp/issues/16)

**Fixed bugs:**

- RUBY\_ENV should not matter [\#30](https://github.com/twingly/twingly-amqp/issues/30)

**Merged pull requests:**

- Remove RUBY\_ENV usage [\#36](https://github.com/twingly/twingly-amqp/pull/36) ([roback](https://github.com/roback))
- Rename Subscription\#subscribe to \#each\_message [\#35](https://github.com/twingly/twingly-amqp/pull/35) ([roback](https://github.com/roback))
- Rename Twingly::AMQP::Ping to Pinger [\#34](https://github.com/twingly/twingly-amqp/pull/34) ([roback](https://github.com/roback))
- Optionally set provider and priority per ping [\#31](https://github.com/twingly/twingly-amqp/pull/31) ([roback](https://github.com/roback))
- Improve tests for Session.new without arguments [\#27](https://github.com/twingly/twingly-amqp/pull/27) ([roback](https://github.com/roback))

## [v3.3.0](https://github.com/twingly/twingly-amqp/tree/v3.3.0) (2015-11-02)
[Full Changelog](https://github.com/twingly/twingly-amqp/compare/v3.2.1...v3.3.0)

**Implemented enhancements:**

- Allow more connection options [\#25](https://github.com/twingly/twingly-amqp/issues/25)
- Release to RubyGems [\#24](https://github.com/twingly/twingly-amqp/issues/24)

**Merged pull requests:**

- Allow more options [\#26](https://github.com/twingly/twingly-amqp/pull/26) ([roback](https://github.com/roback))

## [v3.2.1](https://github.com/twingly/twingly-amqp/tree/v3.2.1) (2015-10-30)
[Full Changelog](https://github.com/twingly/twingly-amqp/compare/v3.2.0...v3.2.1)

## [v3.2.0](https://github.com/twingly/twingly-amqp/tree/v3.2.0) (2015-10-30)
**Implemented enhancements:**

- Add timeout for subscription tests [\#21](https://github.com/twingly/twingly-amqp/issues/21)
- Make Connection class singleton [\#10](https://github.com/twingly/twingly-amqp/issues/10)
- Add class for subscribing to a queue [\#4](https://github.com/twingly/twingly-amqp/issues/4)
- Tests! [\#1](https://github.com/twingly/twingly-amqp/issues/1)

**Fixed bugs:**

- All messages are acked in Subscription\#subscribe [\#13](https://github.com/twingly/twingly-amqp/issues/13)

**Closed issues:**

- Option to enable AMQPS \(TLS\) [\#14](https://github.com/twingly/twingly-amqp/issues/14)
- Set source ip per ping [\#6](https://github.com/twingly/twingly-amqp/issues/6)

**Merged pull requests:**

- Optionally set source ip per ping [\#23](https://github.com/twingly/twingly-amqp/pull/23) ([roback](https://github.com/roback))
- Timeout for subscription tests [\#22](https://github.com/twingly/twingly-amqp/pull/22) ([roback](https://github.com/roback))
- Subscribe to default exchange [\#20](https://github.com/twingly/twingly-amqp/pull/20) ([roback](https://github.com/roback))
- Create class for handling messages [\#18](https://github.com/twingly/twingly-amqp/pull/18) ([roback](https://github.com/roback))
- Make connection class a singleton [\#17](https://github.com/twingly/twingly-amqp/pull/17) ([roback](https://github.com/roback))
- Allow TLS connections [\#15](https://github.com/twingly/twingly-amqp/pull/15) ([jage](https://github.com/jage))
- Tests [\#9](https://github.com/twingly/twingly-amqp/pull/9) ([roback](https://github.com/roback))
- AMQP subscription [\#8](https://github.com/twingly/twingly-amqp/pull/8) ([roback](https://github.com/roback))
- Adapt gem for remora [\#5](https://github.com/twingly/twingly-amqp/pull/5) ([roback](https://github.com/roback))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*