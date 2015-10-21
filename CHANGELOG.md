# Change Log

## [Unreleased][unreleased]

### Changed
 - Made the default installed version of druid v0.8.1 instead of v0.8.0.

### Fixed
 - Template syntax for empty variables.
 - Systemd unit files now define the classpath based on where the install directory was set to be.

## [0.2.0] - 2015-09-09

### Fixed
 - Explicitly set the service provider to systemd.  This is currently the only provider the module supports.
 - Middle manager template sets service configuration properties.
 - Corrected the `druid.cache.hosts` common configuration property to be a comma separated list.

### Added
 - Explicit documentation of the systemd requirement. 
 - Missing configuration parameters for `druid::indexing::middle_manager`

### Changed
 - Druid runtime property templates are not populated with blank configuration options. When the puppet parameter is `undef` or empty no default value is put in the template.  This is in order to not repeat default values twice as well as have the option to explicitly omit setting values.

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

[unreleased]: https://github.com/MrAlias/druid/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/MrAlias/druid/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/MrAlias/druid/compare/v0.1.0...v0.1.1
