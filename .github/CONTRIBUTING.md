# Contribution guidelines

1. [Issue style - Always start by opening an issue](#issues)
1. [Pull requests](#pull-requests)
  * [Development environment setup](#development-environment-setup)
  * [Code style - Don't offend RuboCop](#code-style)
  * [Write tests first - they're mandatory](#testing)
  * [Commit style - Be clean, be passing, be atomic](#commit-style)
  * [Mandatory legal statement](#mandatory-legal-statement)

## Issues

A good issue or bug report leaves no room for interpretation and describes not only the problem,
but also the complete situation it arises in. We highly recommend [Cucumber](http://cukes.io/) style user stories:

* **Given** Oracle Solaris 11.3 with Ruby 1.9, Puppet 3.6.2 and CUPS 1.4.5.

* **When** I apply the manifest

  ```puppet
  include '::cups'

  cups_queue { 'Office':
    ensure => 'printer',
  }
  ```

* **In order to** install a new raw printer queue

* **Then** I get the error message:

  ```Shell
  Error: This version of the CUPS module does not know how to install or manage the CUPS service on your operating system.
  at /etc/puppetlabs/code/environments/production/modules/cups/manifests/params.pp:17 on node nina.initech.com
  ```

Please make sure that you describe what you **expected to happen**, preferably in the "**In order to**" step.

## Pull requests

Did you already open an issue? Opening an issue and discussing shortcomings first can save you a lot of time and trouble.
Maybe there is already uncommitted work in progress to solve your issue.
Maybe there is a reason this module does not offer your desired functionality.
Or maybe there is just a misunderstanding and we need to improve the documentation.

### Development environment setup

For test driven development it is imperative to be able to run acceptance tests.
Assuming [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/)
are already installed on your system, the following additional packages are required
to build the native extensions for the acceptance testing framework [Beaker](https://github.com/puppetlabs/beaker)
and other Ruby gems:

* On a Debian or Ubuntu you can install these using

  ```Shell
  sudo apt-get install ruby-dev libxml2-dev libxslt1-dev g++ zlib1g-dev
  ```

* On an EL or Fedora system use

  ```Shell
  sudo yum install make gcc gcc-c++ libxml2-devel libxslt-devel ruby-devel
  ```

You will also need [Bundler](http://bundler.io/) to install the required gems. One way to install Bundler is:

  ```Shell
  gem install bundler
  ```

Now change to the directory you cloned this git repository to and run

  ```Shell
  bundle install
  ```

Finally, add [Overcommit](https://github.com/brigade/overcommit) to your setup for automated commit checks:

  ```Shell
  overcommit --install
  ```

### Code Style

Mandatory file format:

* UTF-8 encoding
* Coding language is American English
* Unix style linebreaks
* New line at end of file

The Ruby code style is considered acceptable if [RuboCop](https://github.com/bbatsov/rubocop)
does not report any offenses when running

  ```Shell
  bundle exec rubocop -a
  ```

Furthermore the overall code style is considered acceptable if linting and validation pass

  ```Shell
  bundle exec rake lint
  bundle exec rake validate
  ```

### Testing

This module is written using _test driven development_ (TDD). Hence we strongly encourage to

* write the tests first - check that they are failing
* implement the features
* run the tests again - check that they are passing

The next sections explain how to write and run tests.

#### RSpec unit tests

As a rule of thumb, every line of code in `lib` should have tests in `spec/unit`.
The structure of both directories is similar, i.e. the tests for the code in
`lib/puppet_x/cups/instances.rb` go into the file `spec/unit/puppet_x/cups/instances_spec.rb` and so on.

Every unit test file should begin with the line

  ```Ruby
  require 'spec_helper'
  ```

Tests are written in RSpec 3 syntax following their excellent [documentation](https://relishapp.com/rspec)
and can be run on a per file basis

  ```Shell
  bundle exec rspec spec/unit/puppet_x/cups/instances_spec.rb
  ```

or all at once using

  ```Shell
  bundle exec rake spec
  ```

Appending `--only-failures` will only rerun those tests which failed in the previous run.

#### RSpec-Puppet catalog tests

All classes and defined types in the `manifests` folder should have tests in `spec/classes`
or `spec/defines` respectively, and a usage examples in the `examples` folder.

For example the tests for the class `manifests/default_queue.pp` go into
`spec/classes/default_queue_spec.rb` and usage examples go into `examples/default_queue.pp`.

Every catalog test file should begin with the line

  ```Ruby
  require 'spec_helper'
  ```

Tests are written in RSpec-Puppet following their excellent [documentation](http://rspec-puppet.com/)
and are meant to ensure that the Puppet catalog contains the desired resources, as well as to prevent
future code extensions from break existing functionality, i.e. to prevent regression.
They can be run a per file basis

  ```Shell
  bundle exec rspec spec/classes/default_queue_spec.rb
  ```

or all at once using

  ```Shell
  bundle exec rake spec
  ```

Appending `--only-failures` will only rerun those tests which failed in the previous run.

#### Beaker acceptance tests

To ensure that the module actually does what it is supposed to,
we try to check every aspect by applying the corresponding manifests on a test system.

Acceptance tests are written in [Beaker DSL](http://www.rubydoc.info/github/puppetlabs/beaker/)
and go into the `spec/acceptance` folder. Every unit test file should begin with the line

  ```Ruby
  require 'spec_helper_acceptance'
  ```

The recommended skeleton for acceptance tests is

```Ruby
context 'when using my new feature' do
  before(:all) do
    # Your new feature is meant to ensure a certain system state.
    # This section sets up the wrong state in order to make changes necessary.
  end

  manifest = <<-EOM
    # The manifest you want to apply
  EOM

  it 'applies changes' do
    apply_manifest(manifest, expect_changes: true)
  end

  it 'sets the correct value' do
    # Check that the system now is in the desired state.
  end

  it 'is idempotent' do
    apply_manifest(manifest, catch_changes: true)
  end
end
```

The tests can be run on a per file basis

  ```Shell
  bundle exec rspec spec/acceptance/classes/init_spec.rb
  ```

or all at once using

  ```Shell
  bundle exec rake beaker
  ```

on the default testing system defined in `spec/acceptance/nodesets/default.yml`.
To use a different test system, pick a name from the list returned by

  ```Shell
  bundle exec rake beaker:sets
  ```

e.g. `ubuntu-17.04-x64` and set the environment variable

  ```Shell
  export BEAKER_set='ubuntu-17.04-x64'
  ```

Beaker will create and provision the test system on every run and destroy it afterwards.
To avoid this time consuming behavior, you can use the self explaining commands

  ```Shell
  export BEAKER_destroy='no'
  ```

before a Beaker run and

  ```Shell
  export BEAKER_provision='no'
  ```

afterwards.

### Commit style

Pre-commit checklist:

* Do not check in commented out code or unneeded files.

* Does your commit fix one single problem or add one single functionality?

* Did you update the documentation in the [README](README.md) file?

* Does your commit contain all unit, regression and acceptance testing necessary?

* Do all tests pass?

  ```Shell
  bundle exec rake spec
  bundle exec rake beaker
  ```

* Is your code clean and free of unnecessary whitespace?

  ```Shell
  bundle exec rubocop -a
  bundle exec rake lint
  bundle exec rake validate
  git diff --check
  ```

Commit message checklist:

* Make sure [Overcommit](#development-environment-setup) is set up correctly.
  It will automatically check your commit message for formal errors.

* The first line of the commit message should be a short
  description (50 characters is the soft limit, excluding ticket
  number(s)), and should skip the full stop.

* The body should provide a meaningful commit message, which:
  * uses the imperative, present tense: "change", not "changed" or "changes".
  * includes motivation for the change, and contrasts its implementation with the previous behavior.

* Describe the technical detail of the change(s). If your
  description starts to get too long, that is a good sign that you
  probably need to split up your commit into more finely grained pieces.

* Commits which plainly describe the things which help
  reviewers check the patch and future developers understand the
  code are much more likely to be merged in with a minimum of
  bike-shedding or requested changes. Ideally, the commit message
  would include information, and be in a form suitable for
  inclusion in the release notes for the version of Puppet that includes them.

### Mandatory legal statement

Open Source software inspires creativity, learning and collaboration.
Legal troubles will kill all of these in an instant.

This module is provided free of charge and open to everyone (see [LICENSE](LICENSE.txt), *tl;dr* use at your own risk).
To keep it this way and avoid legal trouble of any kind, we kindly ask every contributer to include
the following statement verbatim in their commit messages:

> By committing to this project I transfer the full copyright for my contributions
> to the current project maintainer as per the project's LICENSE file.

_Thank you for your interest in contributing to this project_.
