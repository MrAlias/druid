# Contributing

Please fork and submit a pull request.

When submitting a pull request, please use the following guidelines:

- Try to keep pull requests short and submit separate ones for unrelated features, but feel free to combine simple bugfixes/tests into one pull request.
- Keep the number of commits small and combine commits for related changes.
- Each commit should ideally pass tests, but at a minimum the pull request as a whole needs to pass all tests.
- Bugfixes should include a unit-test or integration test reproducing the issue.
- Non-trivial features should include unit-test covering the new functionality, and integration tests where applicable.
- Make sure your code respects existing [formatting conventions](https://docs.puppetlabs.com/guides/style_guide.html).  This can be checked with the `rake validate` task.
