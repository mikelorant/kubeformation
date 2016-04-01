# Kubeformation

Kubeformation will transform Kubernetes AWS user data into individual files for injecting into CloudFormation stacks.

## Installation

```
git clone https://github.com/mikelorant/kubeformation.git
cd kubeformation
bundle
```

## Usage

Basic usage.

```
$ bundle exec exe/kubeformation help
Kubeformation commands:
  kubeformation generate [key=value ...]  # Generate options
  kubeformation help [COMMAND]            # Describe available commands or one specific command
  kubeformation version                   # Print the version and exit.
```

Generate options.

```
$ bundle exec exe/kubeformation help generate
Usage:
  kubeformation generate [key=value ...]

Options:
  -s, [--source=SOURCE]            # Kubernetes source files.
                                   # Default: /home/username/kubernetes
  -d, [--destination=DESTINATION]  # Destination output.
                                   # Default: /home/username/kubeformation/output
```

Example output.

```
$ bundle exec exe/kubeformation generate
I, [2016-04-01T15:26:04.550046 #14241]  INFO -- : Generating bootstrap...
I, [2016-04-01T15:26:04.662197 #14241]  INFO -- : Generating user data...
I, [2016-04-01T15:26:04.662290 #14241]  INFO -- : Extracting yaml files...
I, [2016-04-01T15:26:05.775265 #14241]  INFO -- : Transforming user data...
```

Output results.

```
$ ls output
bootstrap-script	master-user-data	node-user-data
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/Kubeformation. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
