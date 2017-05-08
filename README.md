# News app

Demo appilation, for playing with:

  - Rails 5.1
  - ActionCable
  - <nolink>Vue.js<nolink>
  - Slim
  - Webpack
  - Docker
  - Application design
  - Making nice <nolink>Readme.md<nolink>

### System requirements
* [Docker](https://docs.docker.com/engine/installation/)
* [docker-compose](https://docs.docker.com/compose/install/)
### Docker
For the first launch:
```sh
$ git clone https://github.com/slava-nikulin/news_app.git
$ cd news_app
$ cp .env.example .env
$ chmod +x docker-entrypoint.sh
$ chmod +x docker-entrypoint-website.sh
$ docker-compose build
$ docker-compose -f docker-compose.commands.yml run --rm website rails db:create db:migrate db:test:prepare
$ docker-compose -f docker-compose.commands.yml run --rm website yarn install
$ docker-compose up
```
Next time just:
```
$ docker-compose up
```
If there were changes in `Dockerfile`:
```
$ docker-compose up --build
```
If `Gemfile` changed:
```
$ docker-compose -f docker-compose.commands.yml run --rm website bundle
```
To compile assets:
```
$ docker-compose -f docker-compose.commands.yml run --rm website ./bin/webpack
```
Then application will be available at http://localhost:3000/

Works fine on Ubuntu, for Windows it will be a little bit complicated, but still possible...
### Test
```
$ docker-compose -f docker-compose.commands.yml run --rm -e "RAILS_ENV=test" website rspec
```
### Deploy
Configure
* `config.action_cable.url`
* `config.action_cable.allowed_request_origins`

in `config/production.rb`
then
* `config/cable.yml`
* `config/database.yml`
* `config/secrets.yml`

And use `docker-compose-deploy.yml`
### TODO
* Add CI
