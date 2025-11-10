# Professional Invoice Template

---

## Invoice Setup Instructions

**Before generating each invoice:**
1. Update the VARIABLES section below with current invoice details
2. Run the generation script or manually replace placeholders
3. Review all dates for accuracy
4. Verify hour calculations match work log
5. Export to PDF for client delivery

---

## VARIABLES (Update for each invoice)

```yaml
# Invoice Metadata
invoice_number: "INV-2025-001"  # Format: INV-YYYY-###
invoice_date: "2025-10-01"      # Date invoice is created
service_period_start: "2025-09-01"
service_period_end: "2025-09-30"
payment_terms_days: 30
due_date: "2025-10-31"          # Auto-calculate: invoice_date + payment_terms_days

# Client Information
client_name: "American Laboratory Trading"
client_attention: "Accounts Payable"
client_address_line1: "12 Colton Road"
client_city_state_zip: "East Lyme, CT 06333"
client_po_number: ""            # Optional: Client's PO number if provided
project_reference: ""           # Optional: Project name or code

# Billing Details
hourly_rate: 100.00
total_hours: 5.0
subtotal: 500.00
tax_rate: 0.00                  # Percentage (e.g., 0.0825 for 8.25%)
tax_amount: 0.00
total_amount: 500.00

# Payment Information
payment_method_primary: "ACH/Wire Transfer"
payment_method_secondary: "Check"
bank_name: "Your Bank Name"
account_name: "Arlen A. Greer"
routing_number: "XXX-XXX-XXX"
account_number: "****1234"
```

---

## INVOICE DOCUMENT

### Page 1: Invoice Summary

```
═══════════════════════════════════════════════════════════════════════

                            ARLEN A. GREER

                    150 Argyle Ave, Alamo Heights, TX 78209
                    619-940-7842 | arlenagreer@gmail.com

═══════════════════════════════════════════════════════════════════════


INVOICE                                     BILL TO:

Invoice #: [invoice_number]                [client_name]
Date: [invoice_date]                       Attention: [client_attention]
Due Date: [due_date]                       [client_address_line1]
Payment Terms: Net [payment_terms_days]    [client_city_state_zip]

                                           PO Number: [client_po_number]
                                           Project: [project_reference]


───────────────────────────────────────────────────────────────────────
DESCRIPTION                          QTY    UNIT PRICE         AMOUNT
───────────────────────────────────────────────────────────────────────

Professional Software Development
Services

Service Period: [service_period_start]
                through [service_period_end]

See attached work log for detailed      [total_hours]  $[hourly_rate]  $[subtotal]
task breakdown


───────────────────────────────────────────────────────────────────────
                                                   SUBTOTAL:  $[subtotal]
                                            TAX ([tax_rate]%):  $[tax_amount]
                                                              ─────────────
                                               TOTAL DUE:  $[total_amount]
───────────────────────────────────────────────────────────────────────


PAYMENT INFORMATION

Primary Method: [payment_method_primary]
  Bank: [bank_name]
  Account Name: [account_name]
  Routing #: [routing_number]
  Account #: [account_number]

Alternative: [payment_method_secondary]
  Payable to: Arlen A. Greer
  Mail to: 150 Argyle Ave, Alamo Heights, TX 78209

Late Payment: Invoices unpaid after 30 days may incur a 1.5% monthly
              finance charge.


───────────────────────────────────────────────────────────────────────

Thank you for your business. It's a pleasure to work with you on your
project. Attached, please find a detailed work log for this billing
period.

Questions? Contact me at arlenagreer@gmail.com or 619-940-7842.


                                                          Page 1 of 2
```

---

### Page 2: Detailed Work Log

```
═══════════════════════════════════════════════════════════════════════
                            WORK LOG DETAIL
              Invoice [invoice_number] | Period: [service_period_start] - [service_period_end]
═══════════════════════════════════════════════════════════════════════

┌──────────┬───────┬────────────────────────────────────────────────────┐
│   DATE   │ HOURS │                   DESCRIPTION                      │
├──────────┼───────┼────────────────────────────────────────────────────┤
│          │       │                                                    │
│ [date]   │ [hrs] │ [Task description]                                 │
│          │       │                                                    │
├──────────┼───────┼────────────────────────────────────────────────────┤
│          │       │                                                    │
│ [date]   │ [hrs] │ [Task description]                                 │
│          │       │                                                    │
├──────────┼───────┼────────────────────────────────────────────────────┤
│          │       │                                                    │
│ [date]   │ [hrs] │ [Task description]                                 │
│          │       │                                                    │
├──────────┼───────┼────────────────────────────────────────────────────┤
│          │       │                                                    │
│ [date]   │ [hrs] │ [Task description]                                 │
│          │       │                                                    │
├──────────┼───────┼────────────────────────────────────────────────────┤
│          │       │                                                    │
│ [date]   │ [hrs] │ [Task description]                                 │
│          │       │                                                    │
├──────────┼───────┼────────────────────────────────────────────────────┤
│          │       │                                                    │
│ [date]   │ [hrs] │ [Task description]                                 │
│          │       │                                                    │
├──────────┼───────┼────────────────────────────────────────────────────┤
│          │       │                                                    │
│ [date]   │ [hrs] │ [Task description]                                 │
│          │       │                                                    │
├──────────┼───────┼────────────────────────────────────────────────────┤
│          │       │                                                    │
│ [date]   │ [hrs] │ [Task description]                                 │
│          │       │                                                    │
└──────────┴───────┴────────────────────────────────────────────────────┘

                                          TOTAL HOURS:  [total_hours]
                                          HOURLY RATE:  $[hourly_rate]
                                                       ─────────────
                                         TOTAL AMOUNT:  $[total_amount]


───────────────────────────────────────────────────────────────────────
NOTES:

• All work performed remotely unless otherwise noted
• Times recorded in standard hours (decimal format)
• Collaborative meetings include time for preparation and follow-up
• System updates include testing and verification time


                                                          Page 2 of 2
```

---

## USAGE EXAMPLES

### Example 1: Monthly Retainer Invoice

```yaml
invoice_number: "INV-2025-010"
invoice_date: "2025-10-01"
service_period_start: "2025-09-01"
service_period_end: "2025-09-30"
payment_terms_days: 30
due_date: "2025-10-31"

client_name: "American Laboratory Trading"
client_attention: "Accounts Payable"
client_po_number: "PO-45821"
project_reference: "SalesRaptor Development"

hourly_rate: 100.00
total_hours: 5.0
subtotal: 500.00
tax_amount: 0.00
total_amount: 500.00
```

### Example 2: Project-Based Invoice

```yaml
invoice_number: "INV-2025-011"
invoice_date: "2025-11-01"
service_period_start: "2025-10-15"
service_period_end: "2025-10-31"
payment_terms_days: 15  # Shorter terms for milestone payment
due_date: "2025-11-16"

client_name: "Tech Startup Inc"
client_attention: "Finance Department"
client_po_number: "STARTUP-001"
project_reference: "API Integration - Phase 1"

hourly_rate: 125.00
total_hours: 20.0
subtotal: 2500.00
tax_amount: 0.00
total_amount: 2500.00
```

---

## QUALITY CHECKLIST

Before sending any invoice, verify:

**Accuracy:**
- [ ] Invoice number follows sequential pattern
- [ ] All dates are correct and consistent
- [ ] Service period matches work log entries
- [ ] Due date = invoice date + payment terms
- [ ] Hours in summary match work log total
- [ ] All calculations are correct
- [ ] No typos in dates (especially watch for extra digits)

**Completeness:**
- [ ] Client information is complete and current
- [ ] PO number included if client provided one
- [ ] Project reference is accurate
- [ ] Payment instructions are clear
- [ ] Contact information is up to date
- [ ] Both pages included

**Professionalism:**
- [ ] Work log entries are sorted chronologically
- [ ] Task descriptions are clear and professional
- [ ] Formatting is consistent throughout
- [ ] PDF export looks clean (no formatting errors)
- [ ] File named appropriately: Invoice-[number]-[client]-[date].pdf

**Communication:**
- [ ] Email subject line: "Invoice [number] - [Client] - [Period]"
- [ ] Email body includes due date and payment methods
- [ ] Copy kept in records/invoices folder
- [ ] Calendar reminder set for due date

---

## AUTOMATION SCRIPTS

### Python Invoice Generator (Optional)

```python
#!/usr/bin/env python3
"""
Invoice Generator Script
Usage: python generate_invoice.py config.yaml
"""

import yaml
from datetime import datetime, timedelta
from decimal import Decimal

def calculate_due_date(invoice_date_str, terms_days):
    """Calculate due date from invoice date and terms."""
    invoice_date = datetime.strptime(invoice_date_str, "%Y-%m-%d")
    due_date = invoice_date + timedelta(days=terms_days)
    return due_date.strftime("%Y-%m-%d")

def calculate_totals(hours, rate, tax_rate=0.0):
    """Calculate invoice totals."""
    subtotal = Decimal(str(hours)) * Decimal(str(rate))
    tax = subtotal * Decimal(str(tax_rate))
    total = subtotal + tax
    return {
        'subtotal': float(subtotal),
        'tax': float(tax),
        'total': float(total)
    }

def generate_invoice(config_file):
    """Generate invoice from config file."""
    with open(config_file, 'r') as f:
        config = yaml.safe_load(f)

    # Auto-calculate due date if not provided
    if not config.get('due_date'):
        config['due_date'] = calculate_due_date(
            config['invoice_date'],
            config['payment_terms_days']
        )

    # Auto-calculate totals
    totals = calculate_totals(
        config['total_hours'],
        config['hourly_rate'],
        config.get('tax_rate', 0.0)
    )
    config.update(totals)

    # Load template and replace placeholders
    with open('invoice-template.md', 'r') as f:
        template = f.read()

    for key, value in config.items():
        placeholder = f"[{key}]"
        template = template.replace(placeholder, str(value))

    # Write output
    output_file = f"Invoice-{config['invoice_number']}.md"
    with open(output_file, 'w') as f:
        f.write(template)

    print(f"Invoice generated: {output_file}")
    print(f"Due date: {config['due_date']}")
    print(f"Total: ${config['total']:.2f}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python generate_invoice.py config.yaml")
        sys.exit(1)
    generate_invoice(sys.argv[1])
```

### Work Log Entry Template

```yaml
# Add entries in chronological order
work_log:
  - date: "2025-09-04"
    hours: 0.5
    description: "Generated list of model image versions from legacy system, along with sample URLs from a random catalog model"

  - date: "2025-09-04"
    hours: 1.0
    description: "Met with Susan to confirm recommended workflow and architecture for the SalesRaptor project, as well as estimated timeframe and priorities"

  - date: "2025-09-08"
    hours: 1.0
    description: "Met with Susan to generate list of deliverables for SalesRaptor application. Also posted these to Asana and confirmed methodology, project timeline"

  - date: "2025-09-08"
    hours: 0.25
    description: "Reviewed change requests with Kevin"
```

---

## FILE NAMING CONVENTIONS

**Invoice Files:**
- Markdown: `Invoice-INV-2025-010-AmericanLab-2025-10.md`
- PDF: `Invoice-INV-2025-010-AmericanLab-2025-10.pdf`

**Config Files:**
- `invoice-config-2025-10-americanlab.yaml`

**Work Logs:**
- `worklog-2025-09-americanlab.yaml`

---

## RECORD KEEPING

Maintain these files for each invoice:
1. Original markdown/source file
2. PDF sent to client
3. YAML config used for generation
4. Email confirmation of receipt
5. Payment confirmation when received

Organize by year and client:
```
invoices/
├── 2025/
│   ├── american-laboratory-trading/
│   │   ├── INV-2025-010/
│   │   │   ├── invoice.pdf
│   │   │   ├── config.yaml
│   │   │   ├── sent-email.txt
│   │   │   └── payment-received.txt
│   │   └── INV-2025-011/
│   └── other-client/
└── 2024/
```

---

## CUSTOMIZATION NOTES

**For Your Brand:**
- Add logo at top (replace text header with logo image)
- Adjust colors to match brand (if creating in design tool)
- Modify footer text to include tagline or additional services

**For Different Service Types:**
- Adjust "Professional Software Development Services" to match offering
- Modify work log format for different billing structures
- Add project-specific fields as needed

**For International Clients:**
- Add currency specification (USD)
- Include exchange rate reference if applicable
- Adjust tax fields for VAT or other international taxes
- Consider multi-language versions

---

## LEGAL DISCLAIMERS (Optional)

Add if required in your jurisdiction:

```
TERMS & CONDITIONS

1. Payment is due within [payment_terms_days] days of invoice date.
2. Late payments subject to 1.5% monthly finance charge.
3. Services provided are professional consulting services.
4. All work product remains property of consultant until payment received.
5. Disputes must be resolved within 30 days of invoice date.

This invoice is governed by the laws of the State of Texas.
```

---

## VERSION HISTORY

- v1.0 (2025-10-01): Initial template created
- Based on: alt-invoice-2025-10-01.pdf
- Improvements: Chronological sorting, enhanced payment details, professional formatting

---

**Template Maintained By:** Arlen A. Greer
**Last Updated:** 2025-10-01
**Next Review:** 2026-01-01
