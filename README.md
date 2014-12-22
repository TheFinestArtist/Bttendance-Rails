Bttendance
=================
Bttendance a is "Smart TA" application, established 2013/11/01.

## Installation (OS X)
1. Install [Ruby Version Manager (RVM)](http://rvm.io) with ```\curl -sSL https://get.rvm.io | bash -s stable```
2. Install Ruby 2.1+ with ```rvm install 2.1.5```
3. Install Rails 4.0+ with ```sudo gem install rails -v 4.1.8```
4. Setup Postgres & Redis
5. After cloning this repository, run ```bundle install``` to install dependencies.
6. Set the ```DATABASE_URL``` environment variable to your desired Postgres development database URL ```launchctl setenv DATABASE_URL postgres```
7. Run ```rake db:setup``` to setup the database (creates database if doesn't exist and autoruns all migrations).
8. Run ```rake db:migrate RAILS_ENV=development``` to migrate new database
9. Run ```rails server``` to start server.

#### Install Postgres/Redis with [Homebrew](http://brew.sh)
    $ brew update
    $ brew doctor
    $ brew install postgresql redis

    // Start local Postgres/Redis server at boot
    $ ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
    $ ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents

    // Launch server now (without reboot)
    $ launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
    $ launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist

#### Get a backup of a Bttendance database
    // Assuming you have access to Bttendance on Heroku
    1. Go to [HerokuPostgres](https://postgres.heroku.com/databases/) and select the Bttendance database you want a copy of
    2. Scroll down to snapshots and download a copy of the latest database snapshot (xxxx.dump)

#### Configure Postgres
    // Connect to local postgres database (automatically created on install)
    $ psql postgres

    // Create the bttendance role and database and exit psql prompt
    postgres=# CREATE DATABASE bttendance;
    postgres=# \q

    // Restore from dump with options (ignore warnings generated by --no-owner)
    $ pg_restore --verbose --clean --no-acl --no-owner -d bttendance <path to DB dump downloaded above>

    // Edit .bash_profile (will create if it doesn't exist)
    $ vi ~/.bash_profile

    // Add following aliases to .bash_profile for quick starting/stopping of the Postgres server:
    alias pgs='pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start'
    alias pgq='pg_ctl -D /usr/local/var/postgres stop -s -m fast'

## Tips
Run ```rake api:routes``` to list the API routes, e.g.

    GET        /api/v1/users(.:format)
    GET        /api/v1/users/:id(.:format)
    POST       /api/v1/users(.:format)
    PUT        /api/v1/users/:id(.:format)
    GET        /api/v1/users/reset(.:format)
    POST       /api/v1/users/login(.:format)
    GET        /api/v1/users/:id/courses(.:format)
    GET        /api/v1/schools(.:format)
    GET        /api/v1/schools/:id(.:format)
    POST       /api/v1/schools(.:format)
    GET        /api/v1/courses(.:format)
    GET        /api/v1/devices(.:format)
    GET        /api/v1/attendance_alarms(.:format)
    POST       /api/v1/attendance_alarms(.:format)
    PUT        /api/v1/attendance_alarms/:id(.:format)
    DELETE     /api/v1/attendance_alarms/:id(.:format)
    POST       /api/v1/schedules(.:format)
    DELETE     /api/v1/schedules/:id(.:format)
    POST       /api/v1/attendances(.:format)
    POST       /api/v1/clickers(.:format)
    PUT        /api/v1/clickers/:id(.:format)
    DELETE     /api/v1/clickers/:id(.:format)
    POST       /api/v1/notices(.:format)
    PUT        /api/v1/notices/:id(.:format)

## Commands
#### Heroku commands
    // View Heroku instance logs (add --tail option for real-time log streaming to console)
    $ heroku logs —app bttendance-dev
    $ heroku logs —app bttendance

    // Add heroku-accounts plugin and create/set Heroku account automatically
    // Note: "Account nickname" is irrelevant, it can be whatever you want
    $ heroku plugins:install git://github.com/ddollar/heroku-accounts.git
    $ heroku accounts:add <account nickname> --auto
    $ heroku accounts:set <account nickname>


#### Postgres (psql) commands
    // Connect to local Bttendance DB
    $ psql postgres

    // Connect to a remote DB (prod, dev, etc)
    $ psql <db_url, e.g. postgres://...>
    $ psql "dbname=<database> host=<host> user=<username> password=<password> port=<port> sslmode=require"

    // List databases on current server
    $ \list

    // List tables in currently-selected database
    $ \dt

    // List Postgres users on current machine
    $ \du

    // Describe structure of specific table
    $ \d+ <table name>

    // Describe all data of specific table
    $ SELECT * FROM <table name>;

    // Exit psql prompt
    $ \q

    // Drop all tables (WARNING : DO NOT USE IN PRODUCTION DATABASE SERVER)
    $ drop schema public cascade;
    $ create schema public;

#### Redis (redis-cli) commands
    // Connect to local redis-server instance
    $ redis-cli

    // Connect to a remote redis instance
    $ redis-cli <db_url, e.g. redis://...>
    $ redis-cli -h <host> -p <port> -a <auth password>

    // List all key/value pairs
    $ KEYS *

    // Get value for a specific key
    $ GET <key name>

    // Exit redis cli
    $ CTRL+C

    // Drop all key-values (WARNING: DO NOT USE IN PRODUCTION DATABASE SERVER)
    $ FLUSHALL

#### Git commands
    // List local and remote branches
    $ git branch -a

    // List remote repository connections
    $ git remote

    // Add Heroku Git repositories (enables use of Heroku CLI tools within the project)
    $ git remote add bttendance-dev git@heroku.com:bttendance-dev.git
    $ git remote add bttendance git@heroku.com:bttendance.git

    // Push changes to main Git repository
    $ git push origin master

    // Heroku deployment commands -- USE WITH CARE
    $ git push bttendance-dev master
    $ git push bttendance master

## Developers

#### Devin Doolin
- Email: icddevin@bttendance.com

#### Hee Hwan Park
- Email: heehwan.park@bttendance.com

#### The Finest Artist
- Email: thefinestartist@bttendance.com

#### Copyright 2015 @Bttendance Inc.
