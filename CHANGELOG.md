# Change Log

## [Unreleased][unreleased]

### Fixed
 - Explicitly set the service provider to systemd.  This is currently the only provider the module supports.
 - Middle manager template sets service configuration properties.

### Added
 - Explicit documentation of the systemd requirement. 
 - Missing configuration parameters for `druid::indexing::middle_manager`

## [0.1.1] - 2015-09-03

### Fixed
 - All systemd service unit configurations to expect signal termination exit codes from the druid process.
 - Validation of input parameters in the `druid::historical` class.
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

[unreleased]: https://github.com/MrAlias/druid/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/MrAlias/druid/compare/v0.1.0...v0.1.1
