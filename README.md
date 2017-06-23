# TeachProgramTracker
TEACH Program Software Stack

## Table of Contents
- [Getting Started](#getting-started)
    - [Workspace Setup](#workspace-setup)
    - [Running Tests](#running-the-tests)
    - [Starting the Server](#starting-the-server)
- [Contribution](#contribution)
    -[Pushing Code](#pushing-code)

## Getting Started
The following steps will help you get your workstation set up.

### Prerequesites
- Ruby 2.4.0
- Rails 5.0.2
- Postgresql

### Workspace Setup
``` 
git clone git@gihub.com:tophat8855/teachprogramtracker.git

cd teachprogramtracker
bundle install

rake db:create db:migrate db:seed
```

### Running the tests
This app uses rspec for testing.

```
bundle exec rspec
```

### Starting the server

```
rails s
```

The server should be running on port 3000.

## Contribution

### Pushing code

```
rspec && git push
```

Pushing the code to master will also deploy to the heroku app.
