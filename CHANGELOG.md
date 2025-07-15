# Changelog

## [v6.2.0](https://github.com/twingly/twingly-amqp/tree/v6.2.0) (2025-07-15)

[Full Changelog](https://github.com/twingly/twingly-amqp/compare/v6.1.0...v6.2.0)

**Merged pull requests:**

- Add channel error callback to Subscription [\#106](https://github.com/twingly/twingly-amqp/pull/106) ([vikiv480](https://github.com/vikiv480))

## [v6.1.0](https://github.com/twingly/twingly-amqp/tree/v6.1.0) (2023-12-13)

[Full Changelog](https://github.com/twingly/twingly-amqp/compare/v6.0.0...v6.1.0)

**Implemented enhancements:**

- Let TopicExchangePublisher\#publish accept routing\_key [\#60](https://github.com/twingly/twingly-amqp/issues/60)

**Merged pull requests:**

- Make it possible to override publishing options [\#104](https://github.com/twingly/twingly-amqp/pull/104) ([roback](https://github.com/roback))

## [v6.0.0](https://github.com/twingly/twingly-amqp/tree/v6.0.0) (2023-10-13)

[Full Changelog](https://github.com/twingly/twingly-amqp/compare/v5.2.0...v6.0.0)

**Fixed bugs:**

- Wait for messages correctly in specs [\#102](https://github.com/twingly/twingly-amqp/issues/102)
- `cancel!` does nothing for a "non-blocking" subscriber [\#86](https://github.com/twingly/twingly-amqp/issues/86)

**Merged pull requests:**

- Make sure Subscriber tests wait for messages to be consumed [\#103](https://github.com/twingly/twingly-amqp/pull/103) ([roback](https://github.com/roback))
- Make it possible to cancel non-blocking subscribers [\#101](https://github.com/twingly/twingly-amqp/pull/101) ([roback](https://github.com/roback))
- Use quorum queues by default instead of classic queues [\#100](https://github.com/twingly/twingly-amqp/pull/100) ([roback](https://github.com/roback))
- Keep GitHub Actions file up-to-date [\#99](https://github.com/twingly/twingly-amqp/pull/99) ([roback](https://github.com/roback))
- Test with latest Rubies [\#98](https://github.com/twingly/twingly-amqp/pull/98) ([roback](https://github.com/roback))
- Test with latest Rubies [\#97](https://github.com/twingly/twingly-amqp/pull/97) ([walro](https://github.com/walro))
- Ruby 3.0.0 on CI [\#96](https://github.com/twingly/twingly-amqp/pull/96) ([walro](https://github.com/walro))

## [v5.2.0](https://github.com/twingly/twingly-amqp/tree/v5.2.0) (2021-02-02)

[Full Changelog](https://github.com/twingly/twingly-amqp/compare/v5.0.1...v5.2.0)

**Implemented enhancements:**

- Various warnings [\#85](https://github.com/twingly/twingly-amqp/issues/85)

**Fixed bugs:**

- Specs fail when random order is set [\#90](https://github.com/twingly/twingly-amqp/issues/90)

**Merged pull requests:**

- Add docker compose file for testing [\#95](https://github.com/twingly/twingly-amqp/pull/95) ([Pontus4](https://github.com/Pontus4))
- Set connection instance as default argument [\#94](https://github.com/twingly/twingly-amqp/pull/94) ([walro](https://github.com/walro))
- Add functionality for publishing delayed messages [\#93](https://github.com/twingly/twingly-amqp/pull/93) ([roback](https://github.com/roback))
- CI on GitHub actions [\#92](https://github.com/twingly/twingly-amqp/pull/92) ([walro](https://github.com/walro))
- Spec improvements [\#91](https://github.com/twingly/twingly-amqp/pull/91) ([Pontus4](https://github.com/Pontus4))
- Add specs for Subscription\#cancel! [\#89](https://github.com/twingly/twingly-amqp/pull/89) ([Pontus4](https://github.com/Pontus4))
- Run CI tests on JRuby [\#88](https://github.com/twingly/twingly-amqp/pull/88) ([Pontus4](https://github.com/Pontus4))
- Remove requires from individual components [\#87](https://github.com/twingly/twingly-amqp/pull/87) ([Pontus4](https://github.com/Pontus4))
- Fix release instructions [\#84](https://github.com/twingly/twingly-amqp/pull/84) ([walro](https://github.com/walro))

## [v5.0.1](https://github.com/twingly/twingly-amqp/tree/v5.0.1) (2020-09-09)

[Full Changelog](https://github.com/twingly/twingly-amqp/compare/v5.0.0...v5.0.1)

**Implemented enhancements:**

- Gem outputs warnings with Ruby version \>= 2.7 \< 3.0 [\#81](https://github.com/twingly/twingly-amqp/issues/81)
- Use same consumer\_threads default value as bunny [\#68](https://github.com/twingly/twingly-amqp/issues/68)

**Closed issues:**

- Optional ping options [\#2](https://github.com/twingly/twingly-amqp/issues/2)

**Merged pull requests:**

- Remove rubocop as dependency [\#83](https://github.com/twingly/twingly-amqp/pull/83) ([Chrizpy](https://github.com/Chrizpy))
- Add support for Ruby 2.7.1 [\#82](https://github.com/twingly/twingly-amqp/pull/82) ([Pontus4](https://github.com/Pontus4))
- Bump rake version [\#80](https://github.com/twingly/twingly-amqp/pull/80) ([walro](https://github.com/walro))
- Test with latest Ruby versions on Travis [\#79](https://github.com/twingly/twingly-amqp/pull/79) ([roback](https://github.com/roback))
- Change consumer thread default to 1 to match Bunny [\#77](https://github.com/twingly/twingly-amqp/pull/77) ([walro](https://github.com/walro))

## [v5.0.0](https://github.com/twingly/twingly-amqp/tree/v5.0.0) (2019-03-01)

[Full Changelog](https://github.com/twingly/twingly-amqp/compare/v4.5.0...v5.0.0)

**Fixed bugs:**

- Publishing an Array raises error or yields unexpected result [\#71](https://github.com/twingly/twingly-amqp/issues/71)

**Merged pull requests:**

- Use more recent rubies on Travis [\#76](https://github.com/twingly/twingly-amqp/pull/76) ([walro](https://github.com/walro))
- Do not convert Array to Hash when publishing [\#75](https://github.com/twingly/twingly-amqp/pull/75) ([roback](https://github.com/roback))
- DRY up publisher specs [\#74](https://github.com/twingly/twingly-amqp/pull/74) ([roback](https://github.com/roback))
- Publisher: Extract all duplicated methods to a base class [\#73](https://github.com/twingly/twingly-amqp/pull/73) ([roback](https://github.com/roback))

## [v4.5.0](https://github.com/twingly/twingly-amqp/tree/v4.5.0) (2018-09-25)

[Full Changelog](https://github.com/twingly/twingly-amqp/compare/v4.4.0...v4.5.0)

**Closed issues:**

- Be able to subscribe to multiple routing keys [\#69](https://github.com/twingly/twingly-amqp/issues/69)

**Merged pull requests:**

- Make it possible to subscribe using multiple routing keys [\#70](https://github.com/twingly/twingly-amqp/pull/70) ([roback](https://github.com/roback))

## [v4.4.0](https://github.com/twingly/twingly-amqp/tree/v4.4.0) (2018-07-02)

[Full Changelog](https://github.com/twingly/twingly-amqp/compare/v4.3.0...v4.4.0)

**Implemented enhancements:**

- Remove signal trap code [\#63](https://github.com/twingly/twingly-amqp/issues/63)
- Remove workaround for "frozen array" error in bunny [\#57](https://github.com/twingly/twingly-amqp/issues/57)
- Possible to stop/cancel the subscription from caller [\#45](https://github.com/twingly/twingly-amqp/issues/45)

**Merged pull requests:**

- Allow custom options in ping message [\#67](https://github.com/twingly/twingly-amqp/pull/67) ([roback](https://github.com/roback))
- Remove workaround for frozen arrary bug [\#66](https://github.com/twingly/twingly-amqp/pull/66) ([walro](https://github.com/walro))
- Remove unused signal trap code [\#65](https://github.com/twingly/twingly-amqp/pull/65) ([roback](https://github.com/roback))
- Require RuboCop \>= 0.49 [\#64](https://github.com/twingly/twingly-amqp/pull/64) ([walro](https://github.com/walro))

## [v4.3.0](https://github.com/twingly/twingly-amqp/tree/v4.3.0) (2016-12-19)

[Full Changelog](https://github.com/twingly/twingly-amqp/compare/v4.2.1...v4.3.0)

**Closed issues:**

- Non-blocking subscribe \(\#on\_each\_message\) [\#29](https://github.com/twingly/twingly-amqp/issues/29)

**Merged pull requests:**

- Bounded queues [\#62](https://github.com/twingly/twingly-amqp/pull/62) ([jage](https://github.com/jage))
- Non-blocking subscribe \(\#on\_each\_message\) [\#61](https://github.com/twingly/twingly-amqp/pull/61) ([roback](https://github.com/roback))

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

[Full Changelog](https://github.com/twingly/twingly-amqp/compare/db2f355cf6a4a4fb1ba2b215e7ed014bd9817b39...v3.2.0)

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



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
