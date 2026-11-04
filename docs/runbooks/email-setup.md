# Email setup: sign-in codes and marketing mail for heymey.app

## Decision

| Mail | From address | Sending domain | Provider |
|---|---|---|---|
| Sign-in codes (OTP), account mail | `HeyMey <notification@heymey.app>` | `heymey.app` | **Amazon SES** (Mumbai, `ap-south-1`) |
| Marketing, newsletters | `HeyMey <hello@news.heymey.app>` | `news.heymey.app` | Brevo or SES (a separate configuration set) |
| Receiving replies, support | `support@heymey.app` | — | Cloudflare Email Routing to your Gmail (free) |

**Why SES:** it costs about **$0.10 per 1,000 emails**, with no daily cap once production access is granted.
For comparison:

- Resend free: 100 emails a day.
- Brevo free: 300 emails a day.
- ZeptoMail (Zoho): pay-as-you-go credits billed in India. Check the current price on zoho.com/zeptomail. It is a good backup.

At 50,000 sign-ins a month, SES costs about $5. Our worker sends over plain SMTP, so switching providers later is
only a change of secrets. No code changes.

**Why marketing is on a different subdomain:** spam complaints about newsletters must never hurt delivery of
sign-in codes. Cloudflare Email Routing only **receives** mail. It cannot send.

## Steps

### A. Amazon SES (sign-in codes)

1. Create an AWS account. Open **SES** and switch the region to **Asia Pacific (Mumbai) ap-south-1**.
2. Go to **Identities**, then **Create identity**, then **Domain**, and enter `heymey.app`. Tick **Easy DKIM (RSA 2048)**.
   Set the custom MAIL FROM domain to `bounce.heymey.app`.
3. SES shows you 3 DKIM CNAME records plus an MX and a TXT record for `bounce`. Add them in Cloudflare (step B).
4. Go to **Account dashboard** and choose **Request production access**. Fill it in as follows:
   - Use case: transactional, one-time sign-in codes for an exam-preparation app.
   - Volume: your estimate, for example 2,000 a day.
   - Bounces: handled through SNS, and addresses that bounce are suppressed.

   Approval usually takes about 24 hours. Until it comes through, you can only send to addresses you have verified.
5. Go to **SMTP settings** and choose **Create SMTP credentials**. You get a username and a password. Keep them for step C.
6. Go to **Configuration sets** and create `heymey-otp` with bounce and complaint events going to SNS. The
   account-level suppression list must be ON.

### B. Cloudflare DNS (dash.cloudflare.com, heymey.app, then DNS)

Every record below must be **DNS only** (grey cloud), never proxied.

| Type | Name | Value |
|---|---|---|
| CNAME ×3 | `xxxx._domainkey` | the 3 values SES gave you |
| MX | `bounce` | `10 feedback-smtp.ap-south-1.amazonses.com` |
| TXT | `bounce` | `v=spf1 include:amazonses.com ~all` |
| TXT | `@` | `v=spf1 include:amazonses.com include:_spf.mx.cloudflare.net ~all` (**one** SPF record only; merge it with any SPF record you already have) |
| TXT | `_dmarc` | `v=DMARC1; p=none; rua=mailto:dmarc@heymey.app; adkim=s; aspf=r` |

After 2 weeks of clean reports, change DMARC to `p=quarantine`.

To receive mail, go to **Email**, then **Email Routing**, enable it, and add these routes:

- `support@heymey.app` to your Gmail;
- `dmarc@heymey.app` to your Gmail.

Cloudflare adds its own MX records for the root domain. Those are fine: `bounce.` has its own MX for SES.

### C. Put the credentials into HeyMey (never in chat or code)

Add these to `infra/secrets/production.enc.env` and `staging.enc.env` with `sops`:

```
SMTP_HOST=email-smtp.ap-south-1.amazonaws.com
SMTP_PORT=587
SMTP_SECURE=false            # STARTTLS on 587
SMTP_USER=<SES SMTP username>
SMTP_PASS=<SES SMTP password>
MAIL_FROM="HeyMey <notification@heymey.app>"
```

Local development keeps using Mailpit (`http://localhost:4585`), so no real mail is sent while you test.

### D. Check it works

1. Send a test from the SES console to a Gmail address. In Gmail, open **Show original**. It must show SPF, DKIM
   and DMARC all as **PASS**.
2. Check the domain at https://www.mail-tester.com. Aim for 9/10 or better.
3. Do a staging sign-in end to end.

### E. Marketing (later, Phase 4 and the launch campaign)

1. Use Brevo, or a second SES identity, with `news.heymey.app`.
2. Add that provider's DKIM and SPF records for `news`.
3. Every mail needs a one-click unsubscribe link (`List-Unsubscribe`).
4. Send only to users who ticked the marketing consent. That consent is already stored per user (Phase 1).
