---
id: unpaid-bills
source: mail
model: quality
cooldown: 72h
---

## Fires when

An invoice arrived, its due date is within the next 5 days or already past, and nothing in
the mailbox suggests it was paid.

`model: quality` because deciding what is an invoice, what is a receipt for something
already paid, and what is a subscription notice with no action needed is genuinely
ambiguous. Getting it wrong in either direction is expensive: a missed bill costs money, a
false alarm costs trust.

## Gather

Mail from the last 45 days matching invoice vocabulary in the user's languages — invoice,
faktura, regning, betaling, payment due, forfald, girokort. Include attachments' filenames;
a PDF called `faktura_1041.pdf` is a strong signal on its own.

For each candidate, extract: sender, amount, due date, invoice number.

Then, separately, look for evidence of payment: a receipt or confirmation from the same
sender **after** the invoice date, a bank confirmation naming the amount or invoice
number, or the user's own reply saying it is handled.

## Rule

Skip anything with no extractable due date — a nudge about a bill with no deadline is
just noise.

Skip anything with matching payment evidence.

Skip subscription renewal notices where nothing is owed: automatic card charges,
"your plan renews on" messages.

Of what is left, take the one closest to its due date, past-due first.

## Nudge

```
Faktura fra {SENDER} på {AMOUNT} forfalder {DUE_DATE}. Jeg kan ikke se den er betalt.

Er den betalt, skal jeg minde dig igen i morgen, eller er den ikke din?

Sig betalt, i morgen, eller ikke min.
```

If it is already overdue, say so plainly in the first line and drop the "i morgen"
option. Past due is not a tomorrow problem.

## What this watcher must never do

Never pay anything, never open a payment link, never reply to the sender. It reads mail
and it tells the user. Money leaving an account is the user's decision every time.
