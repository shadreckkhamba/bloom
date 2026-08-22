# Bloom

Rails app for wedding planning, guest management, invitations, RSVPs, and shared partner access.

## Requirements

- Ruby `3.2.1`
- PostgreSQL for production

## Local setup

1. Install gems:
   ```bash
   bundle install
   ```
2. Set up the database:
   ```bash
   bin/rails db:prepare
   ```
3. Start the app:
   ```bash
   bin/rails server
   ```

## Render + Supabase deployment

This app uses `DATABASE_URL` in production, so it can connect to Supabase without code changes to the app models or controllers.

1. Create a Supabase project.
2. Copy the Postgres connection string from Supabase.
3. Use the session pooler URL if your network needs it, and include `?sslmode=require`.
4. Set these environment variables on Render:
   - `DATABASE_URL`
   - `RAILS_MASTER_KEY`
   - `RAILS_ENV=production`
   - `RAILS_LOG_TO_STDOUT=true`
   - `RAILS_SERVE_STATIC_FILES=true`
5. Deploy using the Render blueprint in `render.yaml`.

## Notes

- The primary application database is read from `DATABASE_URL`.
- Render no longer provisions its own Postgres database in this repo.
- If you change the database URL later, redeploy the Render service so the new value is picked up.
