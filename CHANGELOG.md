# Changelog

## [1.5.0](https://github.com/trento-project/wanda/tree/1.4.0/compare/1.4.0...1.5.0) - 2025-05-23

### What's Changed

* Check vendor deps on CI (#594) @balanza
* Update build dependency requirements (again) (#597) @stefanotorresi
* Fix typo in rust package alias (#596) @stefanotorresi
* Add gatherer docs (#588) @balanza
* Bump RHAI rustler (#591) @balanza
* Operations messaging with web (#577) @arbulu89
* Multiple amqp consumer publisher (#575) @arbulu89
* Adjust doc (#571) @nelsonkopliku
* Refactor customization opt out flag (#569) @nelsonkopliku
* relax rust requirement to allow for patch updates (#557) @stefanotorresi
* change base image and update dependencies (#545) @stefanotorresi
* update license notice (#546) @stefanotorresi
* Add hexadecimal value hint to id section (#542) @arbulu89
* Fix docs description in Evaluation Scope (#539) @EMaksy
* Update specification.md (#538) @EMaksy

#### Features

* Add CODEOWNERS (#612) @nelsonkopliku
* Add saptune change solution operation to the catalog (#608) @nelsonkopliku
* Propagate user in messages (#604) @nelsonkopliku
* Publish checks customization messages (#602) @nelsonkopliku
* Receive operator execution reports (#599) @arbulu89
* Send operator execution request to agents (#595) @arbulu89
* Expose resolved original values (#592) @nelsonkopliku
* Add boolean to accepted value types (#590) @nelsonkopliku
* Add support to updating checks customizations (#587) @nelsonkopliku
* Rabbitmq explicit ssl support  (#586) @CDimonaco
* Using custom values in checks executions (#584) @nelsonkopliku
* Improve api routes (#573) @nelsonkopliku
* Reset check customization (#572) @nelsonkopliku
* Set operation as aborted (#562) @arbulu89
* Checks selection (#563) @nelsonkopliku
* Add customization auth policy (#566) @nelsonkopliku
* Retrieve customizations for a specific execution group (#564) @nelsonkopliku
* Enrich catalog operation data (#559) @arbulu89
* Customize check action (#561) @nelsonkopliku
* Add check customization capabilities (#556) @nelsonkopliku
* Refactor check loading (#560) @nelsonkopliku
* Checks customizability detection (#558) @nelsonkopliku
* Operations controller (#554) @arbulu89
* Operations timeout (#551) @arbulu89
* Operations registry (#549) @arbulu89
* Extract abilities from token so they can be matched for authorization (#552) @nelsonkopliku
* Add customizable key to disable checks customization for certain checks (#550) @EMaksy
* Save operations in the database (#547) @arbulu89
* Create and use enum modules (#548) @arbulu89
* Operations orchestration skeleton (#543) @arbulu89

#### Bug Fixes

* Add ipv6 bug fix (#607) @EMaksy
* Deduplicate execution targets (#605) @nelsonkopliku

#### Maintenance

* Update CI (#611) @stefanotorresi
* Adjust amqp configs (#603) @nelsonkopliku
* Bump rust toolchain (#593) @nelsonkopliku
* Upgrade github actions runner ubuntu version (#585) @arbulu89
* Move json view tests to correct folder (#553) @arbulu89
* Create and use enum modules (#548) @arbulu89
* Update dockerfiles to use correct elixir/erlang versions (#544) @arbulu89

#### Dependencies

<details>
<summary>16 changes</summary>
* Bump docker/metadata-action from 5.6.1 to 5.7.0 (#583) @[dependabot[bot]](https://github.com/apps/dependabot)
* Bump docker/login-action from 3.3.0 to 3.4.0 (#598) @[dependabot[bot]](https://github.com/apps/dependabot)
* Bump telemetry_poller from 1.1.0 to 1.2.0 (#601) @[dependabot[bot]](https://github.com/apps/dependabot)
* Bump ex_doc from 0.37.1 to 0.38.1 (#610) @[dependabot[bot]](https://github.com/apps/dependabot)
* Bump ranch from 2.1.0 to 2.2.0 (#574) @[dependabot[bot]](https://github.com/apps/dependabot)
* Bump trento contracts to 0.2.0 (#582) @CDimonaco
* Bump ex_doc from 0.37.0 to 0.37.1 (#570) @[dependabot[bot]](https://github.com/apps/dependabot)
* Bump ranch from 1.8.0 to 2.1.0 (#565) @[dependabot[bot]](https://github.com/apps/dependabot)
* Bump ex_doc from 0.36.1 to 0.37.0 (#567) @[dependabot[bot]](https://github.com/apps/dependabot)
* Bump postgrex from 0.19.3 to 0.20.0 (#568) @[dependabot[bot]](https://github.com/apps/dependabot)
* Bump phoenix from 1.7.14 to 1.7.18 (#537) @[dependabot[bot]](https://github.com/apps/dependabot)
* Bump ecto from 3.12.4 to 3.12.5 (#534) @[dependabot[bot]](https://github.com/apps/dependabot)
* Bump dialyxir from 1.4.4 to 1.4.5 (#530) @[dependabot[bot]](https://github.com/apps/dependabot)
* Bump postgrex from 0.19.2 to 0.19.3 (#529) @[dependabot[bot]](https://github.com/apps/dependabot)
* Update gen_rmq to cdimonaco/gen_rmq version 5 (#555) @CDimonaco
* Bump docker/metadata-action from 5.5.1 to 5.6.1 (#531) @[dependabot[bot]](https://github.com/apps/dependabot)

</details>
**Full Changelog**: https://github.com/trento-project/wanda/compare/1.4.0...1.5.0

## [1.4.0](https://github.com/trento-project/wanda/tree/1.4.0) (2024-11-11)

[Full Changelog](https://github.com/trento-project/wanda/compare/1.3.0...1.4.0)

**Implemented enhancements:**

- Require trento-checks and remove premium source [#523](https://github.com/trento-project/wanda/pull/523) ([arbulu89](https://github.com/arbulu89))
- Adapted the existing checks to work with ascs_ers cluster [#475](https://github.com/trento-project/wanda/pull/475) ([ksanjeet](https://github.com/ksanjeet))
- Add pr template [#473](https://github.com/trento-project/wanda/pull/473) ([EMaksy](https://github.com/EMaksy))
- Updated metadata of cluster_type with hana_scale_out for existing checks [#469](https://github.com/trento-project/wanda/pull/469) ([ksanjeet](https://github.com/ksanjeet))
- Update Checks schema [#435](https://github.com/trento-project/wanda/pull/435) ([jamie-suse](https://github.com/jamie-suse))

**Merged pull requests:**

- Bump credo from 1.7.8 to 1.7.10 [#527](https://github.com/trento-project/wanda/pull/527) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump phoenix_ecto from 4.6.2 to 4.6.3 [#525](https://github.com/trento-project/wanda/pull/525) ([dependabot[bot]](https://github.com/apps/dependabot))
- Add premium deprecation warning [#522](https://github.com/trento-project/wanda/pull/522) ([janvhs](https://github.com/janvhs))
- Add ensa_version and filesystem_type env docs [#521](https://github.com/trento-project/wanda/pull/521) ([arbulu89](https://github.com/arbulu89))
- Remove view directory from lib/wanda_web [#520](https://github.com/trento-project/wanda/pull/520) ([EMaksy](https://github.com/EMaksy))
- Bump ecto from 3.12.3 to 3.12.4 [#519](https://github.com/trento-project/wanda/pull/519) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump ecto_sql from 3.12.0 to 3.12.1 [#518](https://github.com/trento-project/wanda/pull/518) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump open_api_spex from 3.21.1 to 3.21.2 [#517](https://github.com/trento-project/wanda/pull/517) ([dependabot[bot]](https://github.com/apps/dependabot))
- Remove all premium references [#516](https://github.com/trento-project/wanda/pull/516) ([janvhs](https://github.com/janvhs))
- Fix swaggerui action [#515](https://github.com/trento-project/wanda/pull/515) ([dottorblaster](https://github.com/dottorblaster))
- Bump dialyxir from 1.4.3 to 1.4.4 [#514](https://github.com/trento-project/wanda/pull/514) ([dependabot[bot]](https://github.com/apps/dependabot))
- Migrate Wanda to Phoenix 1.7 and Remove Phoenix.View [#513](https://github.com/trento-project/wanda/pull/513) ([EMaksy](https://github.com/EMaksy))
- Bump credo from 1.7.7 to 1.7.8 [#512](https://github.com/trento-project/wanda/pull/512) ([dependabot[bot]](https://github.com/apps/dependabot))
- Remove checks from the catalog since they now are in their own repo [#511](https://github.com/trento-project/wanda/pull/511) ([dottorblaster](https://github.com/dottorblaster))
- Bump open_api_spex from 3.21.0 to 3.21.1 [#510](https://github.com/trento-project/wanda/pull/510) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bye second compose file [#509](https://github.com/trento-project/wanda/pull/509) ([janvhs](https://github.com/janvhs))
- Bump plug_cowboy from 2.7.1 to 2.7.2 [#508](https://github.com/trento-project/wanda/pull/508) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump open_api_spex from 3.20.1 to 3.21.0 [#507](https://github.com/trento-project/wanda/pull/507) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump ecto from 3.12.2 to 3.12.3 [#506](https://github.com/trento-project/wanda/pull/506) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump excoveralls from 0.18.2 to 0.18.3 [#505](https://github.com/trento-project/wanda/pull/505) ([dependabot[bot]](https://github.com/apps/dependabot))
- Add VOLUME mount to both dockerfile and sles dockerfile [#504](https://github.com/trento-project/wanda/pull/504) ([dottorblaster](https://github.com/dottorblaster))
- Bump ecto from 3.12.1 to 3.12.2 [#502](https://github.com/trento-project/wanda/pull/502) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump credo from 1.7.5 to 1.7.7 [#501](https://github.com/trento-project/wanda/pull/501) ([dependabot[bot]](https://github.com/apps/dependabot))
- Add a test for the processor module [#500](https://github.com/trento-project/wanda/pull/500) ([dottorblaster](https://github.com/dottorblaster))
- Bump telemetry_metrics from 0.6.2 to 1.0.0 [#499](https://github.com/trento-project/wanda/pull/499) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump telemetry_poller from 1.0.0 to 1.1.0 [#498](https://github.com/trento-project/wanda/pull/498) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump ex_machina from 2.7.0 to 2.8.0 [#497](https://github.com/trento-project/wanda/pull/497) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump faker from 0.17.0 to 0.18.0 [#496](https://github.com/trento-project/wanda/pull/496) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump unplug from 1.0.0 to 1.1.0 [#495](https://github.com/trento-project/wanda/pull/495) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump joken from 2.6.0 to 2.6.2 [#494](https://github.com/trento-project/wanda/pull/494) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump ex_doc from 0.31.1 to 0.34.2 [#493](https://github.com/trento-project/wanda/pull/493) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump mox from 1.1.0 to 1.2.0 [#492](https://github.com/trento-project/wanda/pull/492) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump yaml_elixir from 2.9.0 to 2.11.0 [#491](https://github.com/trento-project/wanda/pull/491) ([dependabot[bot]](https://github.com/apps/dependabot))
- Fix API endpoint versioning in executions controller v2 tests [#490](https://github.com/trento-project/wanda/pull/490) ([dottorblaster](https://github.com/dottorblaster))
- Bump ecto_sql from 3.11.1 to 3.12.0 [#489](https://github.com/trento-project/wanda/pull/489) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump open_api_spex from 3.19.1 to 3.20.1 [#487](https://github.com/trento-project/wanda/pull/487) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump excoveralls from 0.18.0 to 0.18.2 [#486](https://github.com/trento-project/wanda/pull/486) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump docker/login-action from 3.2.0 to 3.3.0 [#485](https://github.com/trento-project/wanda/pull/485) ([dependabot[bot]](https://github.com/apps/dependabot))
- Openapi spex objects refactor [#484](https://github.com/trento-project/wanda/pull/484) ([CDimonaco](https://github.com/CDimonaco))
- Add architecture type docs [#482](https://github.com/trento-project/wanda/pull/482) ([arbulu89](https://github.com/arbulu89))
- Fix deps in trento-wanda.spec [#480](https://github.com/trento-project/wanda/pull/480) ([stefanotorresi](https://github.com/stefanotorresi))
- Add rust to asdf tooling [#479](https://github.com/trento-project/wanda/pull/479) ([dottorblaster](https://github.com/dottorblaster))
- Set minimum required rust version to 1.66 [#478](https://github.com/trento-project/wanda/pull/478) ([stefanotorresi](https://github.com/stefanotorresi))
- Bump phoenix_ecto from 4.4.3 to 4.6.2 [#476](https://github.com/trento-project/wanda/pull/476) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update sapservices gatherer doc [#474](https://github.com/trento-project/wanda/pull/474) ([CDimonaco](https://github.com/CDimonaco))
- Bump phoenix from 1.6.16 to 1.7.14 [#472](https://github.com/trento-project/wanda/pull/472) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump docker/build-push-action from 5 to 6 [#471](https://github.com/trento-project/wanda/pull/471) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump docker/login-action from 3.1.0 to 3.2.0 [#437](https://github.com/trento-project/wanda/pull/437) ([dependabot[bot]](https://github.com/apps/dependabot))
- Decouple checks from being contained in the project [#436](https://github.com/trento-project/wanda/pull/436) ([dottorblaster](https://github.com/dottorblaster))
- Phoenix 1.7 upgrade [#432](https://github.com/trento-project/wanda/pull/432) ([gagandeepb](https://github.com/gagandeepb))
- Bump rhai_rustler from 1.0.2 to 1.1.1 [#387](https://github.com/trento-project/wanda/pull/387) ([dependabot[bot]](https://github.com/apps/dependabot))

## [1.3.0](https://github.com/trento-project/wanda/tree/1.3.0) (2024-05-22)

[Full Changelog](https://github.com/trento-project/wanda/compare/1.2.0...1.3.0)

**Implemented enhancements:**

- Pin erlang version to 26.2.1 [#431](https://github.com/trento-project/wanda/pull/431) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Specify elixir version >= 1.15 in rpm spec [#430](https://github.com/trento-project/wanda/pull/430) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Update execution endpoint schemas to include `expect_enum` expectation [#373](https://github.com/trento-project/wanda/pull/373) ([arbulu89](https://github.com/arbulu89))
- Load expect_enum expectations from catalog [#371](https://github.com/trento-project/wanda/pull/371) ([arbulu89](https://github.com/arbulu89))
- Non boolean expectation - expect_enum [#369](https://github.com/trento-project/wanda/pull/369) ([arbulu89](https://github.com/arbulu89))
- Upgrade elixir 1.15.7 [#355](https://github.com/trento-project/wanda/pull/355) ([arbulu89](https://github.com/arbulu89))
- Enforce `target_type` in Check's metadata [#347](https://github.com/trento-project/wanda/pull/347) ([jamie-suse](https://github.com/jamie-suse))

**Fixed bugs:**

- Use tumbleweed in final container stage [#356](https://github.com/trento-project/wanda/pull/356) ([arbulu89](https://github.com/arbulu89))

**Merged pull requests:**

- Require elixir>=1.15 in dockerfile [#433](https://github.com/trento-project/wanda/pull/433) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Release 1.3.0 [#424](https://github.com/trento-project/wanda/pull/424) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Check 816815 - enhance check to use systemd gatherer v2 [#423](https://github.com/trento-project/wanda/pull/423) ([angelabriel](https://github.com/angelabriel))
- Updated metadata for ASCS ERS cluster usage for check 49591F [#422](https://github.com/trento-project/wanda/pull/422) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 15F7A8 [#421](https://github.com/trento-project/wanda/pull/421) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check DA114A [#420](https://github.com/trento-project/wanda/pull/420) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 222A57 [#419](https://github.com/trento-project/wanda/pull/419) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 205AF7 [#418](https://github.com/trento-project/wanda/pull/418) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 9FAAD0 [#417](https://github.com/trento-project/wanda/pull/417) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 00081D [#416](https://github.com/trento-project/wanda/pull/416) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 373DB8 [#415](https://github.com/trento-project/wanda/pull/415) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage [#414](https://github.com/trento-project/wanda/pull/414) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check C3166E [#413](https://github.com/trento-project/wanda/pull/413) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 33403D [#412](https://github.com/trento-project/wanda/pull/412) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check A1244C [#411](https://github.com/trento-project/wanda/pull/411) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 24ABCB [#410](https://github.com/trento-project/wanda/pull/410) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 68626E [#409](https://github.com/trento-project/wanda/pull/409) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 822E47 [#408](https://github.com/trento-project/wanda/pull/408) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check FB0E0D [#407](https://github.com/trento-project/wanda/pull/407) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check CAEFF1 [#406](https://github.com/trento-project/wanda/pull/406) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check D028B9 [#405](https://github.com/trento-project/wanda/pull/405) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 816815 [#404](https://github.com/trento-project/wanda/pull/404) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 21FCA6 [#403](https://github.com/trento-project/wanda/pull/403) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check F50AF5 [#402](https://github.com/trento-project/wanda/pull/402) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 156F64 [#401](https://github.com/trento-project/wanda/pull/401) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 845CC9 [#400](https://github.com/trento-project/wanda/pull/400) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 53D035 [#399](https://github.com/trento-project/wanda/pull/399) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 790926 [#398](https://github.com/trento-project/wanda/pull/398) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 7E0221 [#397](https://github.com/trento-project/wanda/pull/397) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check B089BE [#396](https://github.com/trento-project/wanda/pull/396) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 32CFC6 [#395](https://github.com/trento-project/wanda/pull/395) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check DC5429 [#394](https://github.com/trento-project/wanda/pull/394) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 9FEFB0 [#393](https://github.com/trento-project/wanda/pull/393) ([ksanjeet](https://github.com/ksanjeet))
- Updated metadata for ASCS ERS cluster usage for check 61451E [#392](https://github.com/trento-project/wanda/pull/392) ([ksanjeet](https://github.com/ksanjeet))
- Bump peaceiris/actions-gh-pages from 3 to 4 [#390](https://github.com/trento-project/wanda/pull/390) ([dependabot[bot]](https://github.com/apps/dependabot))
- Pin docker-compose postgres to 15 [#389](https://github.com/trento-project/wanda/pull/389) ([arbulu89](https://github.com/arbulu89))
- Bump postgrex from 0.17.4 to 0.17.5 [#388](https://github.com/trento-project/wanda/pull/388) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump credo from 1.7.3 to 1.7.5 [#386](https://github.com/trento-project/wanda/pull/386) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump open_api_spex from 3.18.1 to 3.18.3 [#385](https://github.com/trento-project/wanda/pull/385) ([dependabot[bot]](https://github.com/apps/dependabot))
- Add ascsers_cluster gatherer docs [#384](https://github.com/trento-project/wanda/pull/384) ([arbulu89](https://github.com/arbulu89))
- Openapi no additional properties take two [#383](https://github.com/trento-project/wanda/pull/383) ([EMaksy](https://github.com/EMaksy))
- check 61451E - check for consecutive semicolons (jsc#TRNT-2015) [#382](https://github.com/trento-project/wanda/pull/382) ([angelabriel](https://github.com/angelabriel))
- Bump docker/login-action from 3.0.0 to 3.1.0 [#381](https://github.com/trento-project/wanda/pull/381) ([dependabot[bot]](https://github.com/apps/dependabot))
- Fix api audience of access token [#377](https://github.com/trento-project/wanda/pull/377) ([CDimonaco](https://github.com/CDimonaco))
- Add V3 backward compatibility check in CI [#376](https://github.com/trento-project/wanda/pull/376) ([arbulu89](https://github.com/arbulu89))
- Update ci.yaml [#375](https://github.com/trento-project/wanda/pull/375) ([stefanotorresi](https://github.com/stefanotorresi))
- Add expect_enum to check definition schema [#374](https://github.com/trento-project/wanda/pull/374) ([arbulu89](https://github.com/arbulu89))
- Add expect_enum documentation [#372](https://github.com/trento-project/wanda/pull/372) ([arbulu89](https://github.com/arbulu89))
- Add unknown expect type in openapi schemas [#370](https://github.com/trento-project/wanda/pull/370) ([arbulu89](https://github.com/arbulu89))
- Remove leftover start execution schema [#368](https://github.com/trento-project/wanda/pull/368) ([arbulu89](https://github.com/arbulu89))
- Update license year to 2024 [#367](https://github.com/trento-project/wanda/pull/367) ([EMaksy](https://github.com/EMaksy))
- Restore API versioning check in CI [#366](https://github.com/trento-project/wanda/pull/366) ([arbulu89](https://github.com/arbulu89))
- Rpm package [#364](https://github.com/trento-project/wanda/pull/364) ([rtorrero](https://github.com/rtorrero))
- Bump docker/metadata-action from 5.5.0 to 5.5.1 [#361](https://github.com/trento-project/wanda/pull/361) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump peter-evans/repository-dispatch from 2 to 3 [#360](https://github.com/trento-project/wanda/pull/360) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump styfle/cancel-workflow-action from 0.12.0 to 0.12.1 [#359](https://github.com/trento-project/wanda/pull/359) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update LICENSE [#358](https://github.com/trento-project/wanda/pull/358) ([stefanotorresi](https://github.com/stefanotorresi))
- Check 373DB8 (jsc#TRNT-2156) [#357](https://github.com/trento-project/wanda/pull/357) ([angelabriel](https://github.com/angelabriel))
- Bump actions/cache from 3 to 4 [#354](https://github.com/trento-project/wanda/pull/354) ([dependabot[bot]](https://github.com/apps/dependabot))
- adjust reference information and the documentation links (jsc#TRNT-2043) [#352](https://github.com/trento-project/wanda/pull/352) ([angelabriel](https://github.com/angelabriel))
- Bump docker/metadata-action from 5.4.0 to 5.5.0 [#351](https://github.com/trento-project/wanda/pull/351) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump docker/metadata-action from 5.3.0 to 5.4.0 [#350](https://github.com/trento-project/wanda/pull/350) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump actions/upload-artifact from 3 to 4 [#349](https://github.com/trento-project/wanda/pull/349) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump docker/metadata-action from 5.0.0 to 5.3.0 [#346](https://github.com/trento-project/wanda/pull/346) ([dependabot[bot]](https://github.com/apps/dependabot))

## [1.2.0](https://github.com/trento-project/wanda/tree/1.2.0) (2023-11-14)

[Full Changelog](https://github.com/trento-project/wanda/compare/1.1.0...1.2.0)

**Implemented enhancements:**

- Restrict SUSE Dockerfile target arch to x86_64 [#340](https://github.com/trento-project/wanda/pull/340) ([rtorrero](https://github.com/rtorrero))
- Add products gatherer docs [#338](https://github.com/trento-project/wanda/pull/338) ([arbulu89](https://github.com/arbulu89))
- Port execution view to v2 and cover execution controller with tests [#337](https://github.com/trento-project/wanda/pull/337) ([dottorblaster](https://github.com/dottorblaster))
- Add os-release gatherer docs [#335](https://github.com/trento-project/wanda/pull/335) ([rtorrero](https://github.com/rtorrero))
- Add mount_info gatherer docs [#334](https://github.com/trento-project/wanda/pull/334) ([arbulu89](https://github.com/arbulu89))
- Add docs for sapservices gatherer [#333](https://github.com/trento-project/wanda/pull/333) ([CDimonaco](https://github.com/CDimonaco))
- Fix CI openapi generation [#332](https://github.com/trento-project/wanda/pull/332) ([dottorblaster](https://github.com/dottorblaster))
- Remove legacy api schema [#331](https://github.com/trento-project/wanda/pull/331) ([dottorblaster](https://github.com/dottorblaster))
- Api versioning plug [#326](https://github.com/trento-project/wanda/pull/326) ([dottorblaster](https://github.com/dottorblaster))
- Add missing metadata reference in Structure section [#324](https://github.com/trento-project/wanda/pull/324) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Disp work gatherer docs [#323](https://github.com/trento-project/wanda/pull/323) ([arbulu89](https://github.com/arbulu89))
- Add versioning info to gatherers docs [#322](https://github.com/trento-project/wanda/pull/322) ([rtorrero](https://github.com/rtorrero))
- Add metadata documentation [#321](https://github.com/trento-project/wanda/pull/321) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Add sapinstance-hostname-resolver gatherer doc [#320](https://github.com/trento-project/wanda/pull/320) ([rtorrero](https://github.com/rtorrero))
- Add systemd@v2 gatherer documentation [#319](https://github.com/trento-project/wanda/pull/319) ([arbulu89](https://github.com/arbulu89))
- Pin all the gatherer version in checks to v1 [#317](https://github.com/trento-project/wanda/pull/317) ([CDimonaco](https://github.com/CDimonaco))
- Update rabbitmq image in docker-compose [#315](https://github.com/trento-project/wanda/pull/315) ([dottorblaster](https://github.com/dottorblaster))
- Update checks definition schema [#312](https://github.com/trento-project/wanda/pull/312) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Add sapcontrol gatherer documentation [#311](https://github.com/trento-project/wanda/pull/311) ([arbulu89](https://github.com/arbulu89))
- Add metadata support [#309](https://github.com/trento-project/wanda/pull/309) ([dottorblaster](https://github.com/dottorblaster))
- Refactor checks from when to metadata [#308](https://github.com/trento-project/wanda/pull/308) ([nelsonkopliku](https://github.com/nelsonkopliku))
- dir_scan gatherer docs [#307](https://github.com/trento-project/wanda/pull/307) ([CDimonaco](https://github.com/CDimonaco))
- Add documentation for sysctl gatherer [#304](https://github.com/trento-project/wanda/pull/304) ([rtorrero](https://github.com/rtorrero))
- Add fstab gatherer docs [#301](https://github.com/trento-project/wanda/pull/301) ([CDimonaco](https://github.com/CDimonaco))
- Add saptune gatherer documentation [#299](https://github.com/trento-project/wanda/pull/299) ([rtorrero](https://github.com/rtorrero))
- Add groups gatherer docs [#298](https://github.com/trento-project/wanda/pull/298) ([CDimonaco](https://github.com/CDimonaco))
- Add passwd gatherer documentation [#296](https://github.com/trento-project/wanda/pull/296) ([arbulu89](https://github.com/arbulu89))
- Add a pipeline step that checks for APIs changes compatibility [#280](https://github.com/trento-project/wanda/pull/280) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Load fake facts config from proper location [#279](https://github.com/trento-project/wanda/pull/279) ([nelsonkopliku](https://github.com/nelsonkopliku))

**Fixed bugs:**

- Fix redirection when a query string is involved [#330](https://github.com/trento-project/wanda/pull/330) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Missed versioning changes [#329](https://github.com/trento-project/wanda/pull/329) ([rtorrero](https://github.com/rtorrero))
- Fix typo in html tag [#328](https://github.com/trento-project/wanda/pull/328) ([arbulu89](https://github.com/arbulu89))
- Fix CI behaviour when on main branch [#302](https://github.com/trento-project/wanda/pull/302) ([jamie-suse](https://github.com/jamie-suse))
- Fix cache-miss in CI pipeline [#300](https://github.com/trento-project/wanda/pull/300) ([jamie-suse](https://github.com/jamie-suse))
- Handle gathered fact nil value [#297](https://github.com/trento-project/wanda/pull/297) ([arbulu89](https://github.com/arbulu89))

**Merged pull requests:**

- Bump dialyxir from 1.4.1 to 1.4.2 [#327](https://github.com/trento-project/wanda/pull/327) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump ex_doc from 0.30.8 to 0.30.9 [#325](https://github.com/trento-project/wanda/pull/325) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump ex_doc from 0.30.7 to 0.30.8 [#318](https://github.com/trento-project/wanda/pull/318) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump ex_doc from 0.30.6 to 0.30.7 [#316](https://github.com/trento-project/wanda/pull/316) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump styfle/cancel-workflow-action from 0.11.0 to 0.12.0 [#306](https://github.com/trento-project/wanda/pull/306) ([dependabot[bot]](https://github.com/apps/dependabot))
- Add sap_profiles gatherer documentation [#305](https://github.com/trento-project/wanda/pull/305) ([arbulu89](https://github.com/arbulu89))
- Bump credo from 1.7.0 to 1.7.1 [#303](https://github.com/trento-project/wanda/pull/303) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump mox from 1.0.2 to 1.1.0 [#295](https://github.com/trento-project/wanda/pull/295) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump docker/build-push-action from 4 to 5 [#294](https://github.com/trento-project/wanda/pull/294) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump docker/metadata-action from 4.6.0 to 5.0.0 [#293](https://github.com/trento-project/wanda/pull/293) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump docker/setup-buildx-action from 2 to 3 [#292](https://github.com/trento-project/wanda/pull/292) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump docker/login-action from 2.2.0 to 3.0.0 [#291](https://github.com/trento-project/wanda/pull/291) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump actions/checkout from 3 to 4 [#290](https://github.com/trento-project/wanda/pull/290) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump dialyxir from 1.3.0 to 1.4.1 [#289](https://github.com/trento-project/wanda/pull/289) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump ex_doc from 0.30.5 to 0.30.6 [#286](https://github.com/trento-project/wanda/pull/286) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump open_api_spex from 3.17.3 to 3.18.0 [#285](https://github.com/trento-project/wanda/pull/285) ([dependabot[bot]](https://github.com/apps/dependabot))
- Add target_type [#284](https://github.com/trento-project/wanda/pull/284) ([dottorblaster](https://github.com/dottorblaster))
- Bump ex_doc from 0.30.4 to 0.30.5 [#282](https://github.com/trento-project/wanda/pull/282) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump ex_doc from 0.30.3 to 0.30.4 [#278](https://github.com/trento-project/wanda/pull/278) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump docker/metadata-action from 4.4.0 to 4.6.0 [#254](https://github.com/trento-project/wanda/pull/254) ([dependabot[bot]](https://github.com/apps/dependabot))

## [1.1.0](https://github.com/trento-project/wanda/tree/1.1.0) (2023-08-02)

[Full Changelog](https://github.com/trento-project/wanda/compare/1.0.0...1.1.0)

**Implemented enhancements:**

- Refactor demo server [#271](https://github.com/trento-project/wanda/pull/271) ([EMaksy](https://github.com/EMaksy))
- initial checks for VMware vSphere (jsc#TRNT-1682) [#259](https://github.com/trento-project/wanda/pull/259) ([yeoldegrove](https://github.com/yeoldegrove))
- update reference section to clarify the package version decision [#255](https://github.com/trento-project/wanda/pull/255) ([angelabriel](https://github.com/angelabriel))
- Add when conditions for resource types, propagate the resource type in the ExecutionCompleted event [#253](https://github.com/trento-project/wanda/pull/253) ([dottorblaster](https://github.com/dottorblaster))
- Add user friendly failure message (jsc#TRNT-1825) [#237](https://github.com/trento-project/wanda/pull/237) ([angelabriel](https://github.com/angelabriel))

**Fixed bugs:**

- Fix formatting in demo guide [#275](https://github.com/trento-project/wanda/pull/275) ([EMaksy](https://github.com/EMaksy))
- fixes found by checks-checker [#260](https://github.com/trento-project/wanda/pull/260) ([yeoldegrove](https://github.com/yeoldegrove))
- Add default failure message for expect_same expectations [#243](https://github.com/trento-project/wanda/pull/243) ([nelsonkopliku](https://github.com/nelsonkopliku))

**Merged pull requests:**

- Bump rhai_rustler to v1.0.2 [#276](https://github.com/trento-project/wanda/pull/276) ([fabriziosestito](https://github.com/fabriziosestito))
- Bump rhai_rustler from 1.0.0 to 1.0.1 [#270](https://github.com/trento-project/wanda/pull/270) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump ex_doc from 0.30.2 to 0.30.3 [#269](https://github.com/trento-project/wanda/pull/269) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump jason from 1.4.0 to 1.4.1 [#266](https://github.com/trento-project/wanda/pull/266) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump ex_doc from 0.29.4 to 0.30.2 [#265](https://github.com/trento-project/wanda/pull/265) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump rhai_rustler to v1.0.0 [#264](https://github.com/trento-project/wanda/pull/264) ([fabriziosestito](https://github.com/fabriziosestito))
- Update contracts usage [#258](https://github.com/trento-project/wanda/pull/258) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Document target_type inside env [#256](https://github.com/trento-project/wanda/pull/256) ([dottorblaster](https://github.com/dottorblaster))
- Bump phoenix_ecto from 4.4.0 to 4.4.2 [#252](https://github.com/trento-project/wanda/pull/252) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump docker/login-action from 2.1.0 to 2.2.0 [#251](https://github.com/trento-project/wanda/pull/251) ([dependabot[bot]](https://github.com/apps/dependabot))
- Document cluster type support [#248](https://github.com/trento-project/wanda/pull/248) ([arbulu89](https://github.com/arbulu89))
- Bump open_api_spex from 3.16.1 to 3.17.3 [#246](https://github.com/trento-project/wanda/pull/246) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update copyright year to 2023 [#240](https://github.com/trento-project/wanda/pull/240) ([EMaksy](https://github.com/EMaksy))
- Bump docker/metadata-action from 4.3.0 to 4.4.0 [#234](https://github.com/trento-project/wanda/pull/234) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump dialyxir from 1.2.0 to 1.3.0 [#232](https://github.com/trento-project/wanda/pull/232) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump excoveralls from 0.16.0 to 0.16.1 [#231](https://github.com/trento-project/wanda/pull/231) ([dependabot[bot]](https://github.com/apps/dependabot))

## [1.0.0](https://github.com/trento-project/wanda/tree/1.0.0) (2023-04-26)

[Full Changelog](https://github.com/trento-project/wanda/compare/0.1.0...1.0.0)

**Implemented enhancements:**

- Make cors optional on production [#206](https://github.com/trento-project/wanda/pull/206) ([arbulu89](https://github.com/arbulu89))
- Build wanda with premium checks, if available [#179](https://github.com/trento-project/wanda/pull/179) ([nelsonkopliku](https://github.com/nelsonkopliku))

**Fixed bugs:**

- Expectation results result to false when some agent evaluation is missing [#224](https://github.com/trento-project/wanda/pull/224) ([arbulu89](https://github.com/arbulu89))

**Merged pull requests:**

- enhance remediation section to clarify the value setting [#235](https://github.com/trento-project/wanda/pull/235) ([angelabriel](https://github.com/angelabriel))
- Add failure message documentation [#230](https://github.com/trento-project/wanda/pull/230) ([dottorblaster](https://github.com/dottorblaster))
- Bump ex_doc from 0.29.2 to 0.29.4 [#229](https://github.com/trento-project/wanda/pull/229) ([dependabot[bot]](https://github.com/apps/dependabot))
- Rename `health_test.exs` -> `health_controller_test.exs` [#228](https://github.com/trento-project/wanda/pull/228) ([jamie-suse](https://github.com/jamie-suse))
- Rename `HealthcheckViewTest` -> `HealthViewTest` [#227](https://github.com/trento-project/wanda/pull/227) ([jamie-suse](https://github.com/jamie-suse))
- add api versioning to the readme examples [#226](https://github.com/trento-project/wanda/pull/226) ([angelabriel](https://github.com/angelabriel))
- Add healthcheck and readiness endpoints [#225](https://github.com/trento-project/wanda/pull/225) ([jamie-suse](https://github.com/jamie-suse))
- Add dev.local.exs usage [#223](https://github.com/trento-project/wanda/pull/223) ([arbulu89](https://github.com/arbulu89))
- Bump credo from 1.6.7 to 1.7.0 [#222](https://github.com/trento-project/wanda/pull/222) ([dependabot[bot]](https://github.com/apps/dependabot))
- Fix execution of SBD related checks  (jsc#CFSA-1961) [#220](https://github.com/trento-project/wanda/pull/220) ([angelabriel](https://github.com/angelabriel))
- Bump plug_cowboy from 2.6.0 to 2.6.1 [#218](https://github.com/trento-project/wanda/pull/218) ([dependabot[bot]](https://github.com/apps/dependabot))
- Refactor API errors [#217](https://github.com/trento-project/wanda/pull/217) ([fabriziosestito](https://github.com/fabriziosestito))
- Add failure message [#216](https://github.com/trento-project/wanda/pull/216) ([dottorblaster](https://github.com/dottorblaster))
- Bump excoveralls from 0.15.3 to 0.16.0 [#213](https://github.com/trento-project/wanda/pull/213) ([dependabot[bot]](https://github.com/apps/dependabot))
- Fixed broken web URLs [#212](https://github.com/trento-project/wanda/pull/212) ([ksanjeet](https://github.com/ksanjeet))
- Compile and test with --warnings-as-errors flag [#210](https://github.com/trento-project/wanda/pull/210) ([fabriziosestito](https://github.com/fabriziosestito))
- Update the hack on wanda guide [#209](https://github.com/trento-project/wanda/pull/209) ([EMaksy](https://github.com/EMaksy))
- Bump ex_doc from 0.29.1 to 0.29.2 [#208](https://github.com/trento-project/wanda/pull/208) ([dependabot[bot]](https://github.com/apps/dependabot))
- Remove jwt enablement flag usage from jwt plug tests [#207](https://github.com/trento-project/wanda/pull/207) ([arbulu89](https://github.com/arbulu89))
- Enrich the faker by using catalog data [#205](https://github.com/trento-project/wanda/pull/205) ([rtorrero](https://github.com/rtorrero))
- Facts schema value lists maps [#204](https://github.com/trento-project/wanda/pull/204) ([arbulu89](https://github.com/arbulu89))
- Bump actions/checkout from 2 to 3 [#203](https://github.com/trento-project/wanda/pull/203) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump excoveralls from 0.15.0 to 0.15.3 [#200](https://github.com/trento-project/wanda/pull/200) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump open_api_spex from 3.13.0 to 3.16.1 [#198](https://github.com/trento-project/wanda/pull/198) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump ecto_sql from 3.8.3 to 3.9.2 [#197](https://github.com/trento-project/wanda/pull/197) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump joken from 2.5.0 to 2.6.0 [#196](https://github.com/trento-project/wanda/pull/196) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump ex_doc from 0.29.0 to 0.29.1 [#195](https://github.com/trento-project/wanda/pull/195) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump credo from 1.6.6 to 1.6.7 [#194](https://github.com/trento-project/wanda/pull/194) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump phoenix from 1.6.12 to 1.6.16 [#193](https://github.com/trento-project/wanda/pull/193) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump docker/build-push-action from 3 to 4 [#192](https://github.com/trento-project/wanda/pull/192) ([dependabot[bot]](https://github.com/apps/dependabot))
- Add dependabot [#191](https://github.com/trento-project/wanda/pull/191) ([fabriziosestito](https://github.com/fabriziosestito))
- Filter out non-existing checks on the faker [#189](https://github.com/trento-project/wanda/pull/189) ([rtorrero](https://github.com/rtorrero))
- Remotely trigger demo deploy on new wanda image [#188](https://github.com/trento-project/wanda/pull/188) ([rtorrero](https://github.com/rtorrero))
- Add new demo env that uses faked execution server [#187](https://github.com/trento-project/wanda/pull/187) ([rtorrero](https://github.com/rtorrero))
- Fix warning in api redirector test [#186](https://github.com/trento-project/wanda/pull/186) ([fabriziosestito](https://github.com/fabriziosestito))
- Fix execution flaky test [#185](https://github.com/trento-project/wanda/pull/185) ([arbulu89](https://github.com/arbulu89))
- Api version v1 [#183](https://github.com/trento-project/wanda/pull/183) ([CDimonaco](https://github.com/CDimonaco))
- Update package_version gatherer doc [#182](https://github.com/trento-project/wanda/pull/182) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Run CI `test` step on different versions of Elixir & OTP [#181](https://github.com/trento-project/wanda/pull/181) ([jamie-suse](https://github.com/jamie-suse))
- Add information on how to install wanda directly for development [#178](https://github.com/trento-project/wanda/pull/178) ([EMaksy](https://github.com/EMaksy))
- Bump BCI base image to 15.4 for dev Dockerfile [#177](https://github.com/trento-project/wanda/pull/177) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Fix JWT plug runtime config [#176](https://github.com/trento-project/wanda/pull/176) ([fabriziosestito](https://github.com/fabriziosestito))
- Use new `trento-wanda` image name for check development environment [#175](https://github.com/trento-project/wanda/pull/175) ([nelsonkopliku](https://github.com/nelsonkopliku))
- rewrite trento community checks regarding 'package version'  [#124](https://github.com/trento-project/wanda/pull/124) ([angelabriel](https://github.com/angelabriel))

## [0.1.0](https://github.com/trento-project/wanda/tree/0.1.0) (2023-01-23)

[Full Changelog](https://github.com/trento-project/wanda/compare/a8b788751fe90542ed0d2541a816b3a148dedfd0...0.1.0)

**Implemented enhancements:**

- Build in obs [#173](https://github.com/trento-project/wanda/pull/173) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Add JWT auth [#168](https://github.com/trento-project/wanda/pull/168) ([fabriziosestito](https://github.com/fabriziosestito))
- Add premium flag option to catalog loading code [#163](https://github.com/trento-project/wanda/pull/163) ([arbulu89](https://github.com/arbulu89))
- Add check DA114A: Corosync has at least 2 rings configured [#141](https://github.com/trento-project/wanda/pull/141) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Add SBD dump gatherer documentation [#137](https://github.com/trento-project/wanda/pull/137) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Add last execution by group [#108](https://github.com/trento-project/wanda/pull/108) ([fabriziosestito](https://github.com/fabriziosestito))
- Add targets execution view [#106](https://github.com/trento-project/wanda/pull/106) ([arbulu89](https://github.com/arbulu89))
- Fix protobuf message mapping [#94](https://github.com/trento-project/wanda/pull/94) ([arbulu89](https://github.com/arbulu89))
- Ordered Execution list [#93](https://github.com/trento-project/wanda/pull/93) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Add cargo to dockerfile and build rustler [#74](https://github.com/trento-project/wanda/pull/74) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Start execution api [#73](https://github.com/trento-project/wanda/pull/73) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Add Checks Specification Documentation [#72](https://github.com/trento-project/wanda/pull/72) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Refactor executions api [#66](https://github.com/trento-project/wanda/pull/66) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Store execution state [#60](https://github.com/trento-project/wanda/pull/60) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Add support for values computation based on environment [#46](https://github.com/trento-project/wanda/pull/46) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Use env values [#42](https://github.com/trento-project/wanda/pull/42) ([arbulu89](https://github.com/arbulu89))
- Serve the execution results through an endpoint [#40](https://github.com/trento-project/wanda/pull/40) ([dottorblaster](https://github.com/dottorblaster))
- Some needed improvements to make the code runnable on prod environment [#38](https://github.com/trento-project/wanda/pull/38) ([arbulu89](https://github.com/arbulu89))
- Store execution result on Check execution completion [#36](https://github.com/trento-project/wanda/pull/36) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Add a storable Wanda.Result.ExecutionResult entity [#35](https://github.com/trento-project/wanda/pull/35) ([nelsonkopliku](https://github.com/nelsonkopliku))

**Fixed bugs:**

- Fix default value when getting system env for JWT_AUTHENTICATION_ENABLED [#172](https://github.com/trento-project/wanda/pull/172) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Set critical state on agent timeout and warning severity [#166](https://github.com/trento-project/wanda/pull/166) ([arbulu89](https://github.com/arbulu89))
- Fix get last execution by group id [#110](https://github.com/trento-project/wanda/pull/110) ([fabriziosestito](https://github.com/fabriziosestito))
- Improve Execution open api doc [#109](https://github.com/trento-project/wanda/pull/109) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Init before start [#101](https://github.com/trento-project/wanda/pull/101) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Fix flaky evaluation test [#96](https://github.com/trento-project/wanda/pull/96) ([arbulu89](https://github.com/arbulu89))
- Load checks properly for the execution [#61](https://github.com/trento-project/wanda/pull/61) ([arbulu89](https://github.com/arbulu89))
- Fixed items definition for expectation_results in ExecutionComplete event [#14](https://github.com/trento-project/wanda/pull/14) ([nelsonkopliku](https://github.com/nelsonkopliku))

**Closed issues:**

- Bad links in README.md [#126](https://github.com/trento-project/wanda/issues/126)

**Merged pull requests:**

- Fix cors plug integration [#174](https://github.com/trento-project/wanda/pull/174) ([CDimonaco](https://github.com/CDimonaco))
- Execution started event [#171](https://github.com/trento-project/wanda/pull/171) ([CDimonaco](https://github.com/CDimonaco))
- Chore: move tests in subfolder [#170](https://github.com/trento-project/wanda/pull/170) ([fabriziosestito](https://github.com/fabriziosestito))
- Remove ssh-address flag reference from docs [#169](https://github.com/trento-project/wanda/pull/169) ([arbulu89](https://github.com/arbulu89))
- rewrite trento community check regarding 'running corosync rings'  [#167](https://github.com/trento-project/wanda/pull/167) ([angelabriel](https://github.com/angelabriel))
- Add list & map examples for `corosync-cmapctl` docs [#165](https://github.com/trento-project/wanda/pull/165) ([jamie-suse](https://github.com/jamie-suse))
- Force rhai_rustler build  [#164](https://github.com/trento-project/wanda/pull/164) ([fabriziosestito](https://github.com/fabriziosestito))
- Add doc for the new package_version comparisons [#162](https://github.com/trento-project/wanda/pull/162) ([rtorrero](https://github.com/rtorrero))
- add when condition to decide where to run a check [#161](https://github.com/trento-project/wanda/pull/161) ([angelabriel](https://github.com/angelabriel))
- Improve gatherers documentation and add rhai example outputs [#160](https://github.com/trento-project/wanda/pull/160) ([fabriziosestito](https://github.com/fabriziosestito))
- Clean up doc saying that expectation evaluation has access to the env [#159](https://github.com/trento-project/wanda/pull/159) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Document the trento-agent facts command [#158](https://github.com/trento-project/wanda/pull/158) ([arbulu89](https://github.com/arbulu89))
- Fix integer mapping [#157](https://github.com/trento-project/wanda/pull/157) ([fabriziosestito](https://github.com/fabriziosestito))
- Add starting the targets section on the docs [#156](https://github.com/trento-project/wanda/pull/156) ([arbulu89](https://github.com/arbulu89))
- Document best practices [#155](https://github.com/trento-project/wanda/pull/155) ([arbulu89](https://github.com/arbulu89))
- Implement when condition [#154](https://github.com/trento-project/wanda/pull/154) ([dottorblaster](https://github.com/dottorblaster))
- rewrite trento community check regarding 'hacluster' password change [#153](https://github.com/trento-project/wanda/pull/153) ([angelabriel](https://github.com/angelabriel))
- Fix external links in ExDocs [#152](https://github.com/trento-project/wanda/pull/152) ([fabriziosestito](https://github.com/fabriziosestito))
- Chore: remove unusued fixture [#151](https://github.com/trento-project/wanda/pull/151) ([fabriziosestito](https://github.com/fabriziosestito))
- Bump to rhai_rustler to v0.1.3 [#149](https://github.com/trento-project/wanda/pull/149) ([fabriziosestito](https://github.com/fabriziosestito))
- Add documentation for verify_password gatherer [#147](https://github.com/trento-project/wanda/pull/147) ([rtorrero](https://github.com/rtorrero))
- rewrite trento community checks regarding 'cibadmin' configuration [#146](https://github.com/trento-project/wanda/pull/146) ([angelabriel](https://github.com/angelabriel))
- Improve table format and add req argument info [#145](https://github.com/trento-project/wanda/pull/145) ([rtorrero](https://github.com/rtorrero))
- Add saphostctrl gatherer to gatherers.md [#144](https://github.com/trento-project/wanda/pull/144) ([rtorrero](https://github.com/rtorrero))
- Add a cheat sheet for Rhai [#143](https://github.com/trento-project/wanda/pull/143) ([dottorblaster](https://github.com/dottorblaster))
- rewrite trento community checks regarding 'sbd dump' configuration [#142](https://github.com/trento-project/wanda/pull/142) ([angelabriel](https://github.com/angelabriel))
- Document cibadmin gatherer [#136](https://github.com/trento-project/wanda/pull/136) ([arbulu89](https://github.com/arbulu89))
- Add a ref to target to README [#133](https://github.com/trento-project/wanda/pull/133) ([dottorblaster](https://github.com/dottorblaster))
- rewrite trento community checks regarding 'sbd' configuration [#123](https://github.com/trento-project/wanda/pull/123) ([angelabriel](https://github.com/angelabriel))
- rewriting checks for Wanda gatherer corosync-cmapctl [#119](https://github.com/trento-project/wanda/pull/119) ([pirat013](https://github.com/pirat013))
- Add severity to the JSON schema [#116](https://github.com/trento-project/wanda/pull/116) ([dottorblaster](https://github.com/dottorblaster))
- Gatherer.corosyncconf [#115](https://github.com/trento-project/wanda/pull/115) ([pirat013](https://github.com/pirat013))
- Refactor factories [#112](https://github.com/trento-project/wanda/pull/112) ([fabriziosestito](https://github.com/fabriziosestito))
- Use Kernel.-- instead of Enum.filter [#111](https://github.com/trento-project/wanda/pull/111) ([fabriziosestito](https://github.com/fabriziosestito))
- add license [#107](https://github.com/trento-project/wanda/pull/107) ([stefanotorresi](https://github.com/stefanotorresi))
- Use specific compose ports for wanda dev/test docker-compose [#105](https://github.com/trento-project/wanda/pull/105) ([fabriziosestito](https://github.com/fabriziosestito))
- Add critical, warning and passing counts to the execution view [#104](https://github.com/trento-project/wanda/pull/104) ([fabriziosestito](https://github.com/fabriziosestito))
- Add ability to handle non-existent & malformed Checks supplied to catalog [#103](https://github.com/trento-project/wanda/pull/103) ([jamie-suse](https://github.com/jamie-suse))
- Add corosynccmapctl to gatherers.md [#102](https://github.com/trento-project/wanda/pull/102) ([rtorrero](https://github.com/rtorrero))
- Bump contracts [#99](https://github.com/trento-project/wanda/pull/99) ([fabriziosestito](https://github.com/fabriziosestito))
- Generate and push swagger-ui to gh-pages [#98](https://github.com/trento-project/wanda/pull/98) ([fabriziosestito](https://github.com/fabriziosestito))
- Re-add accidentaly removed headers [#97](https://github.com/trento-project/wanda/pull/97) ([rtorrero](https://github.com/rtorrero))
- Add test for policy handling Fact error [#95](https://github.com/trento-project/wanda/pull/95) ([jamie-suse](https://github.com/jamie-suse))
- Remove installation section from README.md [#92](https://github.com/trento-project/wanda/pull/92) ([fabriziosestito](https://github.com/fabriziosestito))
- Update CONTRIBUTING.md [#91](https://github.com/trento-project/wanda/pull/91) ([fabriziosestito](https://github.com/fabriziosestito))
- Add documentation for the package_version gatherer [#90](https://github.com/trento-project/wanda/pull/90) ([rtorrero](https://github.com/rtorrero))
- Document systemd gatherer [#89](https://github.com/trento-project/wanda/pull/89) ([arbulu89](https://github.com/arbulu89))
- Add Documentation for SBD Gatherer [#88](https://github.com/trento-project/wanda/pull/88) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Add badges to readme [#87](https://github.com/trento-project/wanda/pull/87) ([fabriziosestito](https://github.com/fabriziosestito))
- Use correct remediation text for check 156F64 [#85](https://github.com/trento-project/wanda/pull/85) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Support no args gatherers [#84](https://github.com/trento-project/wanda/pull/84) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Add coveralls [#83](https://github.com/trento-project/wanda/pull/83) ([fabriziosestito](https://github.com/fabriziosestito))
- Add /etc/hosts file gatherer documentation [#82](https://github.com/trento-project/wanda/pull/82) ([rtorrero](https://github.com/rtorrero))
- Add ExDoc config in mix.exs and supporting file to generate the doc [#81](https://github.com/trento-project/wanda/pull/81) ([fabriziosestito](https://github.com/fabriziosestito))
- Minor tweaks to the specs doc [#80](https://github.com/trento-project/wanda/pull/80) ([rtorrero](https://github.com/rtorrero))
- Fix Checks Specification doc link [#79](https://github.com/trento-project/wanda/pull/79) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Use strict module ordering [#77](https://github.com/trento-project/wanda/pull/77) ([fabriziosestito](https://github.com/fabriziosestito))
- Integrate TLint into CI [#76](https://github.com/trento-project/wanda/pull/76) ([dottorblaster](https://github.com/dottorblaster))
- Do not raise if an execution already exists [#75](https://github.com/trento-project/wanda/pull/75) ([fabriziosestito](https://github.com/fabriziosestito))
- Add ex doc gh pages [#71](https://github.com/trento-project/wanda/pull/71) ([fabriziosestito](https://github.com/fabriziosestito))
- Bump erlang version to 24.3.4 [#70](https://github.com/trento-project/wanda/pull/70) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Change Abacus to Rhai  [#69](https://github.com/trento-project/wanda/pull/69) ([fabriziosestito](https://github.com/fabriziosestito))
- Handle CORS in dev environment [#68](https://github.com/trento-project/wanda/pull/68) ([arbulu89](https://github.com/arbulu89))
- Refactor context [#65](https://github.com/trento-project/wanda/pull/65) ([fabriziosestito](https://github.com/fabriziosestito))
- Abstract RabbitMQ processing logic [#64](https://github.com/trento-project/wanda/pull/64) ([jamie-suse](https://github.com/jamie-suse))
- Detect already running execution for group_id [#63](https://github.com/trento-project/wanda/pull/63) ([arbulu89](https://github.com/arbulu89))
- Remove restart directive from container definitions [#62](https://github.com/trento-project/wanda/pull/62) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Chore: remove unused miss dep [#59](https://github.com/trento-project/wanda/pull/59) ([fabriziosestito](https://github.com/fabriziosestito))
- Use google protobuf value [#58](https://github.com/trento-project/wanda/pull/58) ([fabriziosestito](https://github.com/fabriziosestito))
- Chore: rename/refactor schemas [#56](https://github.com/trento-project/wanda/pull/56) ([fabriziosestito](https://github.com/fabriziosestito))
- Add get check result [#55](https://github.com/trento-project/wanda/pull/55) ([fabriziosestito](https://github.com/fabriziosestito))
- Rename controllers context [#54](https://github.com/trento-project/wanda/pull/54) ([fabriziosestito](https://github.com/fabriziosestito))
- Add Result OpenAPI Schema and cleanup [#53](https://github.com/trento-project/wanda/pull/53) ([fabriziosestito](https://github.com/fabriziosestito))
- More prod fixes [#52](https://github.com/trento-project/wanda/pull/52) ([arbulu89](https://github.com/arbulu89))
- Add initialization tasks for a release [#51](https://github.com/trento-project/wanda/pull/51) ([arbulu89](https://github.com/arbulu89))
- Enable phoenix server usage in prod [#50](https://github.com/trento-project/wanda/pull/50) ([arbulu89](https://github.com/arbulu89))
- Catalog controller [#49](https://github.com/trento-project/wanda/pull/49) ([arbulu89](https://github.com/arbulu89))
- Cleanup execution controller [#48](https://github.com/trento-project/wanda/pull/48) ([fabriziosestito](https://github.com/fabriziosestito))
- Refactor evaluation tests [#47](https://github.com/trento-project/wanda/pull/47) ([arbulu89](https://github.com/arbulu89))
- Switch to Views for JSON rendering [#45](https://github.com/trento-project/wanda/pull/45) ([dottorblaster](https://github.com/dottorblaster))
- Add CI step to check for unused dependencies [#44](https://github.com/trento-project/wanda/pull/44) ([jamie-suse](https://github.com/jamie-suse))
- Load check values from yaml [#43](https://github.com/trento-project/wanda/pull/43) ([arbulu89](https://github.com/arbulu89))
- Check severity [#41](https://github.com/trento-project/wanda/pull/41) ([arbulu89](https://github.com/arbulu89))
- Enable single pipe check on credo [#39](https://github.com/trento-project/wanda/pull/39) ([arbulu89](https://github.com/arbulu89))
- Add dockerfile [#37](https://github.com/trento-project/wanda/pull/37) ([fabriziosestito](https://github.com/fabriziosestito))
- Map ExecutionCompleted event [#34](https://github.com/trento-project/wanda/pull/34) ([arbulu89](https://github.com/arbulu89))
- Phoenix lift off [#33](https://github.com/trento-project/wanda/pull/33) ([arbulu89](https://github.com/arbulu89))
- Message content_type from Contracts [#32](https://github.com/trento-project/wanda/pull/32) ([CDimonaco](https://github.com/CDimonaco))
- Add amqp consumer integration tests [#31](https://github.com/trento-project/wanda/pull/31) ([fabriziosestito](https://github.com/fabriziosestito))
- Handle fact gathering errors [#30](https://github.com/trento-project/wanda/pull/30) ([arbulu89](https://github.com/arbulu89))
- Update contracts dep to trento-projects/contracts [#29](https://github.com/trento-project/wanda/pull/29) ([fabriziosestito](https://github.com/fabriziosestito))
- Set execution GenServer restart policy as transient [#28](https://github.com/trento-project/wanda/pull/28) ([arbulu89](https://github.com/arbulu89))
- Do not requeue amqp message on error [#26](https://github.com/trento-project/wanda/pull/26) ([arbulu89](https://github.com/arbulu89))
- Fix amqp message consumption [#25](https://github.com/trento-project/wanda/pull/25) ([arbulu89](https://github.com/arbulu89))
- Publish facts gathering requested [#24](https://github.com/trento-project/wanda/pull/24) ([fabriziosestito](https://github.com/fabriziosestito))
- Add checks to execution server state [#23](https://github.com/trento-project/wanda/pull/23) ([fabriziosestito](https://github.com/fabriziosestito))
- Map FactsGatheringRequested event [#22](https://github.com/trento-project/wanda/pull/22) ([fabriziosestito](https://github.com/fabriziosestito))
- Timeout business logic implementation [#21](https://github.com/trento-project/wanda/pull/21) ([dottorblaster](https://github.com/dottorblaster))
- Remove JSON schema, add new protobuf contracts  [#20](https://github.com/trento-project/wanda/pull/20) ([fabriziosestito](https://github.com/fabriziosestito))
- Add timeout logic to Wanda.Execution.Server [#19](https://github.com/trento-project/wanda/pull/19) ([dottorblaster](https://github.com/dottorblaster))
- Revert "Adds cache version to pipeline" [#18](https://github.com/trento-project/wanda/pull/18) ([fabriziosestito](https://github.com/fabriziosestito))
- fix execution requested event schema [#15](https://github.com/trento-project/wanda/pull/15) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Adds cache version to pipeline [#12](https://github.com/trento-project/wanda/pull/12) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Serialize an ExecutionCompleted json cloud event [#11](https://github.com/trento-project/wanda/pull/11) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Adds json schema for emitted ExecutionCompletedV1 [#10](https://github.com/trento-project/wanda/pull/10) ([nelsonkopliku](https://github.com/nelsonkopliku))
- Receive Execution Requested event [#9](https://github.com/trento-project/wanda/pull/9) ([fabriziosestito](https://github.com/fabriziosestito))
- Refactor Wanda.Execution in Wanda.Execution.Server, create execution API module [#8](https://github.com/trento-project/wanda/pull/8) ([fabriziosestito](https://github.com/fabriziosestito))
- Receive facts gathered event [#6](https://github.com/trento-project/wanda/pull/6) ([fabriziosestito](https://github.com/fabriziosestito))
- Setup amqp [#5](https://github.com/trento-project/wanda/pull/5) ([fabriziosestito](https://github.com/fabriziosestito))
- Group expectations evaluation [#4](https://github.com/trento-project/wanda/pull/4) ([fabriziosestito](https://github.com/fabriziosestito))
- Refactor execution pt1 [#3](https://github.com/trento-project/wanda/pull/3) ([fabriziosestito](https://github.com/fabriziosestito))
- Expectations eval pt 1 [#2](https://github.com/trento-project/wanda/pull/2) ([fabriziosestito](https://github.com/fabriziosestito))
- proof of concept of check execution orchestration, step 1 [#1](https://github.com/trento-project/wanda/pull/1) ([nelsonkopliku](https://github.com/nelsonkopliku))

* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
