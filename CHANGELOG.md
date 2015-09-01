# Change Log

## [Unreleased][unreleased]

### Fixed
 - All systemd service unit configurations to expect signal termination exit codes from the druid process.
 - Documentation errors. 
 - Unit test errors.

### Added
 - Project change log to track release changes.
 - Project contributing guidelines in CONTRIBUTING.md.
 - Travis CI config file.

## 0.1.0 - 2015-08-25

### Added
 - Main puppet module structure.
 - Manifests for each service druid performs.
 - Main `druid` class to handle package install and common configuration.
 - Defined type `druid::service` to abstract implementation of druid services.
 - Unit tests with 100% coverage of all resources defined.
 - Acceptance tests for each service the module is expected to manage.

[unreleased]: https://github.com/MrAlias/druid/compare/98ab9e2da518af046b15829d82b953bf0d36c020...HEAD
