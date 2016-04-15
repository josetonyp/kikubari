![Build Status](https://travis-ci.org/josetonyp/kikubari.svg?branch=master)

# kikubari

Naive deploy system for deploy agnostic code. Kikubari only take care about repository, folder structure and file configurations. It also will run before an after task from commmand line and log it to the deployment log. I created because I have to maintain a server with PHP and Ruby code with differents framworks: Ruby on Rails, Symfony 1 and 2, pure PHP and Worpress.

If you need a more complex solution maybe you want to take a look on Capistrano. If you want to deploy differents frameworks with differents languages maybe you want to stay here a colaborate.

## Usage:

* Create a *deploy.yml* file in your deploy target folder
* Run *kikubari*:: */path_to_folder* or ./
* Have a beer and see it work

```
project
│   deploy.yml
│   ...

```

```bash
  kikubari .
```


Result:

```
project
│   deploy.yml
│
└── releases
│   │   12345678
│   │   current
│
└── your_folder
    │   your_files

```

# Examples

### Wordpress

```ruby

  config:
    framework: wordpress
    system: git
    origin: "git@github.com:josetonyp/path_to_project.git"
    branch: master
    history_limit: 10

  do:
    folder_structure:
      log: 'log'
      uploads: 'uploads'
      config: 'config'
      coda_cache: 'coda_cache'

    link_files:
      uploads: 'wp-content/uploads'
      coda_cache: 'wp-content/themes/coda/cache'

```

# Contributing to kikubari

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

= Copyright

Copyright (c) 2012 Jose Antonio Pio Gil. See LICENSE.txt for further details.

