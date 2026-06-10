# Master Service — Backend API Requirements

**Audience:** Backend developer  
**Client:** Flutter mobile app for service masters (Turkmenistan market)  
**Reference collection:** [`docs/bruno-master/`](../bruno-master/) (Bruno HTTP requests)  
**Last updated:** June 2026

This document describes what the mobile app **already consumes**, what it **expects from responses**, and what is **still missing** for a complete production-ready integration.

---

## 1. Overview

The Master Service app lets a master:

1. Log in with phone + OTP  
2. View profile, balance, and assigned orders  
3. Start and complete orders (with work photos and final price)  
4. Send live GPS location while online / on a trip  
5. (Planned) Receive new jobs in real time, view payment history, edit profile

**Base path:** `/api/v1/master`  
**Auth:** Laravel Sanctum Bearer token (except location endpoint — see §6)  
**Content-Type:** `application/json` (multipart for photo upload)  
**Accept:** `application/json`

---

## 2. Environments

Please provide stable URLs for:

| Environment | REST API | WebSocket (if used) |
|-------------|----------|---------------------|
| Local dev | e.g. `http://10.0.85.2:8000` | TBD |
| Staging | TBD | TBD |
| Production | HTTPS required | `wss://` required |

The app reads `API_BASE_URL` and `REALTIME_URL` at build time. Production builds must use **HTTPS / WSS**.

**Dev test account needed:**

- At least one master phone number registered in DB  
- How to obtain OTP in dev (SMS gateway vs `storage/logs/laravel.log`)  
- Expected OTP length (app accepts 4–6 digits)

---

## 3. General API conventions

### 3.1 Authentication

- Header: `Authorization: Bearer {sanctum_token}`  
- Token returned from `POST /auth/verify-otp`  
- On `401 Unauthorized`, the app will sign the user out and show login again (planned behaviour — confirm token TTL)

**Phone format sent by app:** E.164 Turkmenistan — `+993` + 8 digits (e.g. `+99362111222`).

### 3.2 Success responses

- Prefer wrapping single resources in `{ "data": { ... } }` (already used for profile and orders)  
- List endpoints: `{ "data": [ ... ], "meta": { "current_page", "last_page", ... } }`

### 3.3 Error responses (required for good UX)

The app parses errors in this order:

1. `{ "message": "Human readable text" }`  
2. Laravel validation: `{ "errors": { "field": ["First error message"] } }`  
3. Plain string body

Please keep **stable HTTP status codes**:

| Code | Usage in app |
|------|----------------|
| `401` | Invalid/expired token → force re-login |
| `403` | Disabled master / order not owned |
| `404` | Master or order not found |
| `422` | Validation (invalid OTP, wrong order status, etc.) |

**Ask:** Can you document a fixed error JSON schema (with optional `code` field) for all endpoints?

### 3.4 Dates

- ISO 8601 with timezone, e.g. `2026-05-16T10:00:00+05:00`  
- Used for `created_at`, `access_expires_at`, `recorded_at`

### 3.5 Order status values

The app maps these API statuses to UI actions:

| API `status` | UI action |
|--------------|-----------|
| `assigned` | Show **Start job** → `POST .../start` |
| `in_progress` | Show **Complete** → open details → `POST .../complete` |
| `completed` | History list |
| `cancelled` | History list |

**Confirm:** Full list of statuses and allowed transitions.

---

## 4. Implemented endpoints (already wired in app)

These match the Bruno collection. Please keep contracts stable or notify mobile team before breaking changes.

### 4.1 Auth

#### `POST /api/v1/master/auth/request-otp`

**Request:**
```json
{ "phone": "+99362111222" }
```

**Expected:** `200` + `{ "message": "OTP sent." }`  
**Errors:** `404` (phone not found), `403` (disabled)

---

#### `POST /api/v1/master/auth/verify-otp`

**Request:**
```json
{ "phone": "+99362111222", "code": "1234" }
```

**Expected:** `200`
```json
{
  "token": "1|...",
  "master": {
    "id": 1,
    "name": "Aydogdy Ussadow",
    "phone": "+99362111222",
    "balance": 250.00,
    "is_active": true,
    "access_expires_at": "2026-12-31",
    "categories": [{ "id": 1, "name": "Сантехника" }],
    "city": { "id": 1, "name": "Ашхабад" }
  }
}
```

App stores: `token`, `master.id`, `master.name`, `master.phone`.

**Optional fields used when present on `/me`:** `payment_model`, `payment_value`  
**Errors:** `404`, `403`, `422` (invalid/expired OTP)

---

#### `POST /api/v1/master/auth/logout`

**Auth:** Bearer  
**Expected:** `204 No Content`  
App clears local session even if this call fails.

---

### 4.2 Profile

#### `GET /api/v1/master/me`

**Auth:** Bearer  

**Expected:** `200`
```json
{
  "data": {
    "id": 1,
    "name": "Aydogdy Ussadow",
    "phone": "+99362111222",
    "balance": 250.00,
    "payment_model": "percentage",
    "payment_value": 15,
    "is_active": true,
    "access_expires_at": "2026-12-31",
    "categories": [{ "id": 1, "name": "Сантехника" }],
    "city": { "id": 1, "name": "Ашхабад" }
  }
}
```

**Used in UI:** Settings (name, skills/categories, city), Home (balance as earnings stat).

**`payment_model` values app can map (please confirm exact strings):**

- `percentage` — percent of `final_price`  
- `fixed_per_job` — fixed amount per job  
- `salary` / `monthly_salary` — no per-job accrual in UI

---

### 4.3 Orders

#### `GET /api/v1/master/orders?filter=active|history`

**Auth:** Bearer  

| `filter` | App usage |
|----------|-----------|
| `active` | Jobs tab, Home dashboard, Map markers |
| `history` | Jobs history section, History screen |

**Expected list item shape (minimum fields app reads today):**
```json
{
  "id": 42,
  "status": "assigned",
  "client_name": "Merdan",
  "address": "Ashgabat, Korogly 12",
  "category": "Сантехника",
  "description": "Сломался кран",
  "created_at": "2026-05-16T10:00:00+05:00"
}
```

**Gap:** List items have **no price** — app shows `"—"`.  
**Gap:** List items have **no `latitude` / `longitude`** — app fetches each order detail for map (N+1 requests).  
**Please add to list response (recommended):** `latitude`, `longitude`, `client_phone`, `estimated_price` or `final_price` (if known).

**Pagination:** App does not paginate yet but receives `meta.current_page` / `meta.last_page`. Confirm default page size and max.

---

#### `GET /api/v1/master/orders/{id}`

**Auth:** Bearer  

**Expected:**
```json
{
  "data": {
    "id": 1,
    "status": "assigned",
    "client_name": "Merdan",
    "client_phone": "+99361234567",
    "address": "Ashgabat, Korogly 12",
    "latitude": 37.95,
    "longitude": 58.38,
    "category": "Сантехника",
    "description": "Сломался кран на кухне",
    "photos": [{ "id": 1, "url": "https://...", "status": "done" }],
    "tasks": [
      {
        "id": 7,
        "title": "Замена прокладки",
        "description": "...",
        "before_photo": "https://...",
        "after_photo": null
      }
    ],
    "created_at": "2026-05-16T10:00:00+05:00"
  }
}
```

**Task photo fields:** App expects `before_photo` and `after_photo` as **URL strings** (or `null`).

**If photos are async:** After upload returns `pending`, app re-fetches this endpoint. Please document when URLs become available and recommended poll interval.

---

#### `POST /api/v1/master/orders/{id}/start`

**Auth:** Bearer, empty body  
**Transition:** `assigned` → `in_progress`  
**Expected:** `200` + `{ "data": { "id": 1, "status": "in_progress" } }`  
**Errors:** `403`, `422` (wrong status)

---

#### `POST /api/v1/master/orders/{id}/complete`

**Auth:** Bearer  

**Request:**
```json
{ "final_price": 150.00 }
```

**Transition:** `in_progress` → `completed` (triggers balance accrual per master payment model)  
**Expected:** `200` + `{ "data": { "id": 1, "status": "completed", "final_price": 150.00 } }`

**Please confirm:**

- Is `final_price` required? Min/max? Currency always TMT?  
- Must before/after photos exist before complete is allowed?  
- Response should include master's updated `balance` (optional but useful)

---

#### `POST /api/v1/master/orders/{id}/tasks`

**Auth:** Bearer  

**Request:**
```json
{
  "title": "Замена прокладки крана",
  "description": "Заменил резиновую прокладку"
}
```

**Expected:** `201` + task object with `id`, `title`, `description`, `before_photo`, `after_photo`  

**App behaviour:** Auto-creates one task when opening job details if `tasks` is empty (title = description or category).

**Please confirm:** One task per order or multiple? App currently uses **first task only** for photo upload.

---

#### `POST /api/v1/master/orders/{id}/tasks/{task_id}/photo`

**Auth:** Bearer  
**Content-Type:** `multipart/form-data`

| Field | Type | Values |
|-------|------|--------|
| `type` | string | `before` or `after` |
| `photo` | file | image/*, max 8 MB |

**Expected:** `202 Accepted`
```json
{ "id": 7, "status": "pending", "type": "before" }
```

**Please confirm:**

- Can master upload **multiple** `before` or `after` photos per task? (UI shows 2 slots per section but API appears 1:1)  
- When `status` becomes `done`, how does client get final WebP URL?  
- Allowed MIME types and max dimensions

---

### 4.4 Location

#### `POST /api/v1/master/{master_id}/location`

**Auth (current Bruno note):** None (temporary) — app still sends Bearer header.

**Request (with active trip):**
```json
{
  "latitude": 37.952321,
  "longitude": 58.382345,
  "order_id": 1,
  "recorded_at": "2026-05-16T13:45:00+05:00"
}
```

**Request (online, no trip):**
```json
{
  "latitude": 37.960000,
  "longitude": 58.390000
}
```

**App behaviour:**

- Sends every **~12 seconds** while master is authenticated  
- Includes `order_id` when master has an order in `in_progress`  
- Sends `recorded_at` as device local time ISO8601

**Please confirm:**

- Final auth requirement for this endpoint  
- Rate limits (app ≈ 5 requests/minute per master)  
- `master_id` in URL must match authenticated master when auth is enabled

---

## 5. Missing endpoints (required for full app)

These screens exist in the app but have **no API** in Bruno. Please implement or confirm timeline.

### 5.1 Profile update — **High priority**

**Screen:** Edit Profile (`/profile/edit`)

**Suggested:** `PATCH /api/v1/master/me`

```json
{
  "name": "Aydogdy Ussadow",
  "city_id": 1
}
```

Phone change likely needs separate OTP flow — please specify.

---

### 5.2 Payment / transaction history — **High priority**

**Screens:** Payments tab, Payment History in Settings

**Suggested:** `GET /api/v1/master/payments` or `GET /api/v1/master/transactions`

```json
{
  "data": [
    {
      "id": 101,
      "type": "earning",
      "amount": 22.50,
      "order_id": 42,
      "description": "Order #42 completed",
      "created_at": "2026-05-16T15:00:00+05:00"
    }
  ],
  "meta": { "current_page": 1, "last_page": 1 }
}
```

**Also useful:** `GET /api/v1/master/balance` summary if different from `/me`.

---

### 5.3 Master categories — **Medium priority**

If `categories` is empty after login, app has onboarding flags but no screen yet.

**Suggested:** `PUT /api/v1/master/me/categories`

```json
{ "category_ids": [1, 3, 5] }
```

**Also:** `GET /api/v1/master/categories` — list of selectable service categories.

---

### 5.4 Cities list — **Medium priority**

For profile edit dropdown.

**Suggested:** `GET /api/v1/master/cities` or public `GET /api/v1/cities`

---

### 5.5 Order reject / cancel by master — **Low priority (confirm need)**

UI has no reject button yet. If masters can decline assigned orders:

**Suggested:** `POST /api/v1/master/orders/{id}/reject` with optional reason.

---

### 5.6 Support / FAQ — **Low priority**

**Screen:** Support center — static for now. Optional: `GET /api/v1/master/support/faq`

---

## 6. Real-time events (not in Bruno — app prepared but not connected)

The app includes a WebSocket client expecting:

**Connection:** `wss://{host}?token={sanctum_token}`

**Message format:**
```json
{
  "type": "new_job | job_assigned | job_status_changed",
  "payload": { }
}
```

| Event | Intended use |
|-------|----------------|
| `new_job` | New order available (map / home) |
| `job_assigned` | Order assigned to this master |
| `job_status_changed` | Refresh jobs list without polling |

**Please provide:**

- WebSocket URL and auth method  
- Exact `type` strings and `payload` schema per event  
- Or confirm **v1 uses polling only** (app can poll `GET /orders?filter=active` every N seconds)

---

## 7. Push notifications (optional, future)

Not implemented in app yet. If planned:

- FCM device token registration endpoint  
- Events: new assignment, order cancelled, payment received

---

## 8. Business rules to confirm

Please document answers for:

1. **Master access:** What happens when `is_active: false` or `access_expires_at` is past? Block at login or per action?  
2. **Order assignment:** Are orders pre-assigned to master only (current UI assumption) or is there an accept flow?  
3. **Complete order:** Validation rules (photos required? price bounds?)  
4. **Earnings:** How `payment_model` + `payment_value` + `final_price` calculate balance credit  
5. **Client phone:** Always visible on detail? Any masking?  
6. **Location:** Required only during `in_progress` or whenever app is open?

---

## 9. Contract maintenance

Please maintain one of:

- Updated Bruno collection in repo (`docs/bruno-master/`)  
- OpenAPI 3.0 spec (preferred for long term)

Notify mobile team before:

- Renaming fields (`snake_case` assumed throughout)  
- Changing status enum values  
- Changing auth scheme  
- Removing `data` wrapper

---

## 10. Integration checklist (for joint testing)

| # | Test case | Pass? |
|---|-----------|-------|
| 1 | Request OTP for registered master | ☐ |
| 2 | Verify OTP → receive token + master | ☐ |
| 3 | `GET /me` with token | ☐ |
| 4 | List active orders | ☐ |
| 5 | Start order (`assigned` → `in_progress`) | ☐ |
| 6 | Create task + upload before photo | ☐ |
| 7 | Photo URL appears on `GET /orders/{id}` after processing | ☐ |
| 8 | Upload after photo | ☐ |
| 9 | Complete order with `final_price` → balance updates | ☐ |
| 10 | Order appears in `filter=history` | ☐ |
| 11 | Location ping without `order_id` | ☐ |
| 12 | Location ping with `order_id` during trip | ☐ |
| 13 | Logout revokes token | ☐ |
| 14 | `401` on expired token | ☐ |

---

## 11. Summary for backend developer

**Already integrated (11 HTTP operations):** auth (3), profile (1), orders (6), location (1).

**Needed for complete app experience:**

1. Stable error JSON + documented status transitions  
2. Richer order list fields (`lat`, `lng`, price, phone)  
3. Clear async photo workflow (pending → URL)  
4. `PATCH /me` (profile edit)  
5. Payment / transaction history API  
6. Categories + cities endpoints (profile onboarding)  
7. WebSocket spec **or** confirm polling-only v1  
8. Dev/staging URLs + test master account  

**Contact:** Mobile team — share breaking changes before deployment.

---

*Generated from Master Service Flutter app integration state. Bruno reference: [`docs/bruno-master/`](../bruno-master/).*
