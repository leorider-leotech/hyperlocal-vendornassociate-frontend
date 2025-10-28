# Appydex Vendor API Contract (Frontend Expectations)

Base URL: `${APP_BASE_URL}` (default `https://api.appydex.co`)

## Authentication

### POST /auth/login
Request:
```json
{ "phone": "+919XXXXXXXXX" }
```
Response:
```json
{ "challenge": "otp_sent" }
```

### POST /auth/verify
Request:
```json
{ "phone": "+91...", "otp": "123456" }
```
Response:
```json
{
  "access_token": "<jwt>",
  "refresh_token": "<rt>",
  "vendor": { "id": "v_123", "name": "My Shop", "subscription": { "plan": "basic" } }
}
```

### POST /auth/refresh
Request:
```json
{ "refresh_token": "<rt>" }
```
Response:
```json
{ "access_token": "<jwt>", "refresh_token": "<rt>" }
```

## Vendor Profile

### GET /vendors/me
Returns vendor profile, subscription, and KPI stats.

## Services

- `GET /vendors/services`
- `POST /vendors/services`
- `PUT /vendors/services/{id}`
- `DELETE /vendors/services/{id}`

Payload example:
```json
{
  "name": "Packers & Movers",
  "category": "Logistics",
  "price": 1999,
  "status": "published",
  "image_url": "https://cdn..."
}
```

Image uploads use either:
- `POST /uploads/presign` → use returned URL for PUT upload
- `POST /uploads` with multipart fallback

## Leads

- `GET /vendors/leads?status=new`
- `GET /vendors/leads/{id}`
- `PUT /vendors/leads/{id}/status`

Lead status transitions: `new → accepted | rejected | quoted → closed`.

## Orders

- `GET /vendors/orders`
- `PUT /vendors/orders/{id}/status`

Order status transitions: `pending → in_progress → completed | cancelled`.

## Subscription & Payments

- `GET /vendors/subscription`
- `POST /payments/create`
- `POST /payments/verify`

Payment integrations use Razorpay/Stripe keys from environment. Enable `FAKE_PAY=true` to use mock flow.

## Referrals

- `GET /vendors/referrals`
- `POST /vendors/referrals/apply`

## Notifications

- Firebase Cloud Messaging tokens should be registered via `/vendors/notifications/register`
- Test pushes are received via Firebase console.

## Error Handling

Errors follow:
```json
{
  "error": "validation_error",
  "message": "Readable error message",
  "details": { "field": "description" }
}
```
