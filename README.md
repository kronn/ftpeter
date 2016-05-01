# FTPeter

In a world where capistrano and similar tools issue ssh-commands to setup your
application on a dedicated or virtual server, we tend to forget that we
sometimes do not have that luxury and freedom.

This is for those who need to fire up an FTP-Client to transfer files to a
hosting-service. This is for those, who still create a git-repository to manage
their files.

This is for those, who acknowledge the FTPeter in the room where we usually only
see SSHans.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "ftpeter"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ftpeter

## Usage

Basic usage: `ftpeter ftp://example.com`

The executable accepts three arguments:

- target-host (mandatory)
- directory to switch to on the target-host (`/` by default)
- last deployed version (`origin/master` by default)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment. Run `bundle exec ftpeter` to use the
gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on the Gitlab at
https://git.lanpartei.de/kronn/ftpeter

## License

"MIT-alike, not no military usage and no sublicensing"


Copyright (c) 2015 Matthias Viehweger

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

- The Software must not be used in a military context.

- The above copyright notice, all conditions and this permission notice shall be
  included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
