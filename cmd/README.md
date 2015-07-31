Gesmew Installer
===============

**Until the release of Gesmew 1.0 you must use the --edge option**

Command line utility to create new Gesmew store applications
and extensions

See the main gesmew project: https://github.com/gesmew/gesmew

Installation
------------

```ruby
gem install gesmew_cmd
```
This will make the command line utility 'gesmew' available.

You can add Gesmew to an existing rails application

```ruby
rails new my_app
gesmew install my_app
```

Extensions
----------

To build a new Gesmew Extension, you can run
```ruby
gesmew extension my_extension
```
Examples
--------

If you want to accept all the defaults pass --auto_accept
```
gesmew install my_store --edge --auto_accept
```
to use a local clone of Gesmew, pass the --path option
```
gesmew install my_store --path=../gesmew
```

Options
-------

* `--auto_accept` to answer yes to all questions
* `--edge` to use the edge version of Gesmew
* `--path=../gesmew` to use a local version of gesmew
* `--branch=n-n-stable` to use git branch
* `--git=git@github.com:cmar/gesmew.git` to use git version of gesmew
  * `--ref=23423423423423` to use git reference
  * `--tag=my_tag` to use git tag

Older Versions of Gesmew
-----------------------

Versions of the Gesmew gem before 1.0 included a gesmew binary. If you
have one of these installed in your gemset, then you can alternatively
use the command line utility "gesmew_cmd". For example "gesmew_cmd install
my_app".



