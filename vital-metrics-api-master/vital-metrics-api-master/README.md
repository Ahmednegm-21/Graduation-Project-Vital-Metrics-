<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="200" alt="Nest Logo" /></a>
</p>

[circleci-image]: https://img.shields.io/circleci/build/github/nestjs/nest/master?token=abc123def456
[circleci-url]: https://circleci.com/gh/nestjs/nest

  <p align="center">A progressive <a href="http://nodejs.org" target="_blank">Node.js</a> framework for building efficient and scalable server-side applications.</p>
    <p align="center">
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/v/@nestjs/core.svg" alt="NPM Version" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/l/@nestjs/core.svg" alt="Package License" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/dm/@nestjs/common.svg" alt="NPM Downloads" /></a>
<a href="https://circleci.com/gh/nestjs/nest" target="_blank"><img src="https://img.shields.io/circleci/build/github/nestjs/nest/master" alt="CircleCI" /></a>
<a href="https://coveralls.io/github/nestjs/nest?branch=master" target="_blank"><img src="https://coveralls.io/repos/github/nestjs/nest/badge.svg?branch=master#9" alt="Coverage" /></a>
<a href="https://discord.gg/G7Qnnhy" target="_blank"><img src="https://img.shields.io/badge/discord-online-brightgreen.svg" alt="Discord"/></a>
<a href="https://opencollective.com/nest#backer" target="_blank"><img src="https://opencollective.com/nest/backers/badge.svg" alt="Backers on Open Collective" /></a>
<a href="https://opencollective.com/nest#sponsor" target="_blank"><img src="https://opencollective.com/nest/sponsors/badge.svg" alt="Sponsors on Open Collective" /></a>
  <a href="https://paypal.me/kamilmysliwiec" target="_blank"><img src="https://img.shields.io/badge/Donate-PayPal-ff3f59.svg"/></a>
    <a href="https://opencollective.com/nest#sponsor"  target="_blank"><img src="https://img.shields.io/badge/Support%20us-Open%20Collective-41B883.svg" alt="Support us"></a>
  <a href="https://twitter.com/nestframework" target="_blank"><img src="https://img.shields.io/twitter/follow/nestframework.svg?style=social&label=Follow"></a>
</p>
  <!--[![Backers on Open Collective](https://opencollective.com/nest/backers/badge.svg)](https://opencollective.com/nest#backer)
  [![Sponsors on Open Collective](https://opencollective.com/nest/sponsors/badge.svg)](https://opencollective.com/nest#sponsor)-->

## Description

[Nest](https://github.com/nestjs/nest) framework TypeScript starter repository.

## Installation

```bash
$ npm install
```

## Running the app

```bash
# development
$ npm run start

# watch mode
$ npm run start:dev

# production mode
$ npm run start:prod
```

## Test

```bash
# unit tests
$ npm run test

# e2e tests
$ npm run test:e2e

# test coverage
$ npm run test:cov
```

## Google Login (ID token)

This API supports **Login with Google** via a token-based flow.

### Prerequisites

- Create OAuth client credentials in Google Cloud Console.
- Set the following environment variable:

```bash
GOOGLE_CLIENT_ID=your_google_oauth_client_id.apps.googleusercontent.com
```

### Database migration

Google login links accounts using a stable Google subject identifier (`sub`) stored in the `users.google_sub` column.

Run the Drizzle migration after pulling the latest code:

```bash
npx drizzle-kit migrate
```

If you don’t use `drizzle-kit migrate` in your workflow, apply the generated SQL in [drizzle/0004_wise_spitfire.sql](drizzle/0004_wise_spitfire.sql) manually.

### Endpoint

`POST /auth/google/token`

The client must obtain a Google **ID token** (`id_token`) using “Sign in with Google”, then send it to this API.

#### Request body

- `id_token` (required): Google ID token
- The following fields are **required only on first sign-in** (because the DB requires them):
  - `name` (required for first sign-in): unique username for this API (`users.name`)
  - `gender` (required for first sign-in): `male` | `female`
  - `date_of_birth` (required for first sign-in): ISO date string (e.g. `1990-05-15`)
  - `height` (required for first sign-in): number (cm)
  - `weight` (required for first sign-in): number (kg)

Example:

```json
{
  "id_token": "<google_id_token>",
  "name": "john_doe_92",
  "gender": "male",
  "date_of_birth": "1990-05-15",
  "height": 175,
  "weight": 70.5
}
```

#### Response

Returns the same shape as normal login:

```json
{
  "access_token": "<jwt_access>",
  "refresh_token": "<jwt_refresh>",
  "user": {
    "user_id": 1,
    "name": "john_doe_92",
    "email": "john@example.com",
    "is_admin": false,
    "is_verified": true
  }
}
```

### Account linking behavior

- If the Google account was previously linked, the API finds the user by `google_sub`.
- Otherwise, if a local account already exists with the same email, the API links it by setting `users.google_sub`.
- Google sign-in requires `email_verified === true` and will mark the user as verified in this API.

## Support

Nest is an MIT-licensed open source project. It can grow thanks to the sponsors and support by the amazing backers. If you'd like to join them, please [read more here](https://docs.nestjs.com/support).

## Stay in touch

- Author - [Kamil Myśliwiec](https://kamilmysliwiec.com)
- Website - [https://nestjs.com](https://nestjs.com/)
- Twitter - [@nestframework](https://twitter.com/nestframework)

## License

Nest is [MIT licensed](LICENSE).
