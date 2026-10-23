# My Mongo App

A Rails application for managing users, their posts, and their addresses with
MongoDB. It provides browser-based CRUD pages and a JSON API for users.

## Stack

- Ruby 3.4.5
- Rails 8.1 (locked to 8.1.4)
- Mongoid 9.1 with MongoDB (CI uses MongoDB 8.0)
- ERB views, Turbo, Stimulus, Importmap, and Propshaft
- RSpec for model and request tests

Active Record is disabled. Document fields and indexes are defined in the
Mongoid models rather than SQL migrations.

## Local setup

Install the Ruby version in `.ruby-version`, Bundler, and MongoDB. Start MongoDB
on `localhost:27017` before running database commands or tests.

From the project directory:

```sh
bundle install
bin/rails db:mongoid:create_indexes
RAILS_ENV=test bin/rails db:mongoid:create_indexes
bin/dev
```

Open <http://localhost:3000>. The home page lists users. Create a user, then open
its details to manage posts and addresses.

`bin/setup --skip-server` can also install missing gems and clear logs and
temporary files. It does not start MongoDB or create indexes.

## Database and models

Connection settings are in `config/mongoid.yml`:

| Environment | Database | Host |
| --- | --- | --- |
| Development | `my_mongo_app_development` | `localhost:27017` |
| Test | `my_mongo_app_test` | `localhost:27017` |

MongoDB creates databases and collections as data is written; no SQL database
creation or migration step is required.

| Model | Fields | Relationships |
| --- | --- | --- |
| User | `name`, `email`, `age`, `created_at`, `updated_at` | Has many posts; embeds many addresses |
| Post | `title`, `content`, `user_id` | Belongs to a user; stored in a separate collection |
| Address | `street`, `city` | Embedded within its user document |

Users require a name and a unique email. Deleting a user also destroys their
posts and removes their embedded addresses.

The models declare a unique index on `users.email` and an index on
`posts.user_id`. Run `bin/rails db:mongoid:create_indexes` after adding index
declarations, and run it separately for each environment. Existing duplicate
emails must be resolved before creating the unique email index.

## Browser routes

All three resources support listing, viewing, creating, editing, and deleting.
Post and address lookups are scoped to the user in the URL.

| Resource | List | New record |
| --- | --- | --- |
| Users | `/users` (also `/`) | `/users/new` |
| Posts | `/users/:user_id/posts` | `/users/:user_id/posts/new` |
| Addresses | `/users/:user_id/addresses` | `/users/:user_id/addresses/new` |

Record pages append `/:id`; edit pages append `/:id/edit`. HTML forms include
validation feedback and deletion confirmations.

`GET /up` is the Rails application health endpoint; it does not verify MongoDB
connectivity.

## User JSON API

Use the `.json` suffix or request JSON explicitly. Posts and addresses currently
have HTML CRUD endpoints only.

| Method | Endpoint | Successful response |
| --- | --- | --- |
| GET | `/users.json` | 200 with all users |
| GET | `/users/:id.json` | 200 with one user |
| POST | `/users.json` | 201 with the created user |
| PATCH / PUT | `/users/:id.json` | 200 with the updated user |
| DELETE | `/users/:id.json` | 204 with no response body |

Create a user:

```sh
curl -X POST http://localhost:3000/users.json \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ana","email":"ana@example.com","age":30}}'
```

Create and update accept `name`, `email`, and `age` inside a `user` object.
Validation failures return HTTP 422 with an `errors` array. Missing records
return HTTP 404. JSON writes to users are exempt from CSRF protection; HTML
forms retain it.

## Tests

With MongoDB running, create test indexes and run RSpec:

```sh
RAILS_ENV=test bin/rails db:mongoid:create_indexes
bundle exec rspec
```

Run a subset:

```sh
bundle exec rspec spec/models
bundle exec rspec spec/requests
```

The suite covers user validation, the user JSON API, HTML CRUD, and ownership
scoping for nested resources. Before each example, the test helper deletes all
posts and users from the test database, including embedded addresses, while
preserving indexes. Keep the test database separate from development data and
run the current cleanup strategy sequentially.

There are currently no browser system specs. `bin/rails test:system` runs
Minitest system tests, not RSpec.

## CI and code checks

GitHub Actions runs on pull requests and pushes to `main`. The workflow in
`.github/workflows/ci.yml` runs RuboCop, Brakeman, dependency audits, and RSpec.
The test job starts a MongoDB 8.0 service, waits for its health check, and creates
test indexes before running specs.

Run the local CI sequence with MongoDB already running and test indexes created:

```sh
bin/ci
```

Individual checks:

```sh
bin/rubocop
bin/brakeman
bin/bundler-audit
bin/importmap audit
bin/rails zeitwerk:check
```

## Deployment status

The repository includes a production Dockerfile and Kamal configuration, but
production setup is incomplete: `config/mongoid.yml` has no production section,
and `config/deploy.yml` contains placeholder deployment settings. Configure
production MongoDB access and create its indexes before serving database-backed
requests. Keep `config/master.key` and other unencrypted secrets out of Git.

Authentication and authorization are not implemented. Scoping posts and
addresses to a user URL does not restrict who can manage that user.
