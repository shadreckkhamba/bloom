# Partner Accounts — Design Spec

## Overview

Allow the bride and groom to have separate logins that are linked to the
same wedding. Each partner manages their own guest list independently, but
both see the full combined picture on their dashboards.

---

## Data Model Changes

### `weddings` table — add one column

| Column       | Type    | Notes                                      |
|--------------|---------|--------------------------------------------|
| `partner_id` | integer | FK → users.id, nullable, unique per wedding |

- The user who created the wedding is the **owner** (`wedding.user_id`).
- The second account is the **partner** (`wedding.partner_id`).
- Only one partner slot — one wedding, two people.

### `guests` table — add one column

| Column        | Type    | Notes                                     |
|---------------|---------|-------------------------------------------|
| `added_by_id` | integer | FK → users.id, not null (set on create)   |

- Every guest is tagged with who added them.
- Existing guests default to the wedding owner's id (migration sets this).

---

## Partner Invite Flow

```
Owner dashboard
  └─ "Connect your partner" card (shown when partner_id is nil)
       └─ Generates a signed token: /partner/accept?token=<signed>
            └─ Token encodes: wedding_id, expires in 7 days

Partner clicks link
  ├─ Not logged in → taken to /signup?partner_token=<token>
  │    └─ Creates account → auto-joined to the wedding
  └─ Already logged in (has own wedding) → shown error: "You already have a wedding"
  └─ Already logged in (no wedding) → auto-joined immediately

After joining
  - partner_id set on wedding
  - Link is invalidated (single-use)
  - Both partners redirected to dashboard
```

**Token signing:** use Rails' `MessageVerifier` with a 7-day expiry.
No new DB table needed — the token is stateless.

---

## Access Rules

| Action                        | Owner | Partner |
|-------------------------------|-------|---------|
| View dashboard                | ✅    | ✅      |
| View full guest list          | ✅    | ✅      |
| Add guests                    | ✅    | ✅      |
| Delete their own guests       | ✅    | ✅      |
| Delete partner's guests       | ❌    | ❌      |
| Edit wedding details          | ✅    | ❌      |
| View messages                 | ✅    | ✅      |
| Check-in guests               | ✅    | ✅      |
| Connect/disconnect partner    | ✅    | ❌      |
| Set seat limit                | ✅    | ❌      |

---

## Seat Limit

Add `seat_limit` (integer, nullable) to `weddings`.

Dashboard shows:
```
Seats:  [owner guests confirmed] + [partner guests confirmed] = [total] / [limit]
Remaining: [limit - total]  (highlighted red when < 10)
```

If limit is nil, show totals only without a cap.

---

## Dashboard Changes

### Combined stats (existing row — no change to layout)
Still shows total invited / accepted / declined / pending across both partners.

### New "Partner" section (below stats)
```
┌─────────────────────────────────────────────────┐
│  👰 Florence's guests    🤵 Prince's guests      │
│  Invited: 45             Invited: 38             │
│  Confirmed: 32           Confirmed: 29           │
└─────────────────────────────────────────────────┘
```

### "Connect your partner" card (owner only, shown until partner joins)
```
┌─────────────────────────────────────────────────┐
│  🔗 Invite your partner                          │
│  Send this link to [partner name] so they can    │
│  manage their guests separately.                 │
│                                                  │
│  [Copy link]   [Regenerate]                      │
└─────────────────────────────────────────────────┘
```

---

## Guest List Changes

- Add a **"Added by"** column (small badge: "You" or partner's first name)
- Add a **filter tab**: All | Mine | Partner's
- Filter is client-side (no extra requests)

---

## Routes to Add

```ruby
# Partner invite
get  '/partner/invite',  to: 'partners#invite',  as: :partner_invite
post '/partner/invite',  to: 'partners#create_invite'
get  '/partner/accept',  to: 'partners#accept',  as: :partner_accept
post '/partner/accept',  to: 'partners#confirm'
delete '/partner',       to: 'partners#destroy', as: :partner_destroy

# Signup with partner token (extend existing signup)
# — handled by passing partner_token param through registrations#create
```

---

## New Files

| File | Purpose |
|------|---------|
| `app/controllers/partners_controller.rb` | Invite generation, accept, disconnect |
| `app/views/partners/invite.html.erb` | "Share this link" page |
| `app/views/partners/accept.html.erb` | "Join this wedding" confirmation page |
| `db/migrate/..._add_partner_to_weddings.rb` | Adds partner_id, seat_limit |
| `db/migrate/..._add_added_by_to_guests.rb` | Adds added_by_id |

---

## Modified Files

| File | Change |
|------|--------|
| `app/models/wedding.rb` | belongs_to :partner, has partner? helper, owner? / partner? role checks |
| `app/models/user.rb` | has_one :owned_wedding, has_one :partner_wedding |
| `app/models/guest.rb` | belongs_to :added_by (user), scope :by_owner, :by_partner |
| `app/controllers/application_controller.rb` | `current_wedding` helper covering both roles |
| `app/controllers/guests_controller.rb` | Set added_by_id on create, scope destroy to own guests only |
| `app/controllers/registrations_controller.rb` | Handle partner_token on signup |
| `app/controllers/dashboard_controller.rb` | Add per-partner stats |
| `app/views/dashboard/index.html.erb` | Partner split panel + connect card |
| `app/views/guests/index.html.erb` | Added-by badge + filter tabs |
| `app/views/guests/_guest_row.html.erb` | Added-by badge |
| `app/views/guests/create.turbo_stream.erb` | Pass added_by context |
| `app/views/layouts/application.html.erb` | Show partner indicator in nav |
| `config/routes.rb` | Partner routes |

---

## What Does NOT Change

- Invitation flow (`/i/:token`) — guests don't know or care who added them
- RSVP flow — unchanged
- QR pass — unchanged  
- Check-in — unchanged
- Wedding details form — unchanged (partner just can't access edit)
