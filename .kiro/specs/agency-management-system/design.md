# Design Document — Agency Management System

## Overview

The Agency Management System is a UI-only Flutter feature that extends the existing dark-purple voice-chat app with a full agency portal. All data is static/fake — no backend calls are made. The system adds eight new screens/tabs across the admin and agent dashboards, covering agency-type management, earnings dashboards, a withdrawal flow, subordinate management, referral tracking, a multi-gateway recharge system, a USDT settlement workflow, and an admin agency overview.

The app already auto-logs in as admin on startup and routes to `AdminDashboardScreen` (a 6-tab `TabBarView`). The agent dashboard (`AgentDashboardScreen`) currently has 3 tabs. Both shells will be extended with new tabs. Standalone screens are navigated to via `Navigator.push` from existing tabs.

### Key Constraints

- **DDC crash prevention**: Every `build()` method that would exceed ~80 lines of widget tree must be split into separate named widget classes or separate files. This is the single most important implementation constraint.
- **Static data only**: All monetary values, user records, and transaction histories are hardcoded Dart constants or `final` lists.
- **Theme**: `AppColors.background` (#0F0F1E) scaffold, `AppColors.surface` (#1A1635) cards, `AppColors.primaryPurple` (#8B5CF6) accents. Reuse `StatCard`, `SectionHeader`, `StatusBadge`, `GradientButton`, `LeaderboardRow`, `TargetRow` from `agency_widgets.dart`.
- **No live-room UI**: No medals, streaming controls, or room-related widgets.

---

## Architecture

The feature follows the existing flat file layout under `client/lib/screens/agency/`. New files are added alongside existing ones; no new packages or state management libraries are introduced.

```
client/lib/screens/agency/
├── tabs/                          (admin dashboard tabs — existing)
│   ├── overview_tab.dart
│   ├── applications_tab.dart
│   ├── agents_tab.dart
│   ├── hosts_tab.dart
│   ├── earnings_tab.dart
│   ├── users_tab.dart
│   ├── agency_types_tab.dart      ← NEW  (admin tab 7)
│   ├── usdt_settlement_tab.dart   ← NEW  (admin tab 8)
│   └── agency_overview_tab.dart   ← NEW  (admin tab 9)
├── agent_tabs/                    ← NEW directory
│   ├── agent_earnings_dashboard_tab.dart   ← NEW
│   ├── agent_referral_tab.dart             ← NEW
│   └── agent_withdrawal_tab.dart           ← NEW (standalone screen)
├── widgets/
│   └── agency_widgets.dart        (existing shared widgets)
├── admin_dashboard_screen.dart    (extend TabController length 6→9)
├── agent_dashboard_screen.dart    (extend TabController length 3→5)
├── payment_screen.dart            (enhance with USDT + Google Pay flows)
├── sub_agency_screen.dart         (enhance with UID-based add flow)
└── ...
```

### Navigation Map

```
AdminDashboardScreen (TabBarView, 9 tabs)
  Tab 1: 📊 Overview          (existing)
  Tab 2: 📋 Applications      (existing)
  Tab 3: 🤝 Agents            (existing)
  Tab 4: 🎙 Hosts             (existing)
  Tab 5: 💰 Earnings          (existing)
  Tab 6: 👥 Users             (existing)
  Tab 7: 🏢 Agency Types      ← NEW
  Tab 8: ₿  USDT Settlement   ← NEW
  Tab 9: 🌐 Agency Overview   ← NEW

AgentDashboardScreen (TabBarView, 5 tabs)
  Tab 1: 📊 Overview          (existing)
  Tab 2: 🎯 Targets           (existing)
  Tab 3: 💰 Earnings          (existing)
  Tab 4: 📈 My Earnings       ← NEW (Earnings Dashboard)
  Tab 5: 👥 Referrals         ← NEW (Referral Tracking)
  AppBar action: 💸 Withdraw  ← NEW (navigates to WithdrawalScreen)

PaymentScreen (existing, enhanced)
  + USDT gateway flow (TxID entry + pending confirmation)
  + Google Pay method tile
  + Refunded status in order history

SubAgencyScreen (existing, enhanced)
  + UID-based add flow (replaces name+code form)
  + Aggregate stats panel
```

---

## Components and Interfaces

### 1. Agency Types Tab (`agency_types_tab.dart`)

**Location**: Admin dashboard, Tab 7 ("🏢 Agency Types")

**Responsibilities**:
- Display four agency type cards (USDT, Recharge, Country, Shipping) with type-specific fields
- Allow status toggling (active / suspended / pending) per agency record
- Show a filtered list when a type card is tapped

**Widget decomposition** (DDC-safe):
- `AgencyTypesTab` — `StatefulWidget`, top-level tab, holds `_selectedType` filter state
- `_TypeSummaryGrid` — 2×2 grid of `_TypeCard` widgets (count + icon per type)
- `_TypeCard` — single agency-type summary card; tappable to set filter
- `_AgencyListView` — `ListView.builder` of `_AgencyRow` widgets
- `_AgencyRow` — expandable card showing name, UID, type badge, status badge, key metric; inline status-change buttons

**Static data model**:
```dart
class _Agency {
  final String uid;
  final String name;
  final AgencyType type;
  String status;           // mutable for UI toggle
  final DateTime createdAt;
  // Type-specific fields (nullable):
  final String? region;        // Country
  final String? walletAddress; // USDT
  final int? diamondCreditLimit; // Recharge
  final int? maxTransferCap;   // Shipping
}

enum AgencyType { usdt, recharge, country, shipping }
```

---

### 2. Agent Earnings Dashboard Tab (`agent_earnings_dashboard_tab.dart`)

**Location**: Agent dashboard, Tab 4 ("📈 My Earnings")

**Responsibilities**:
- Show current-month vs previous-month earnings side by side
- Display trend indicator (green ↑ / red ↓ with percentage)
- Break down earnings by source: gift commissions, referral bonuses, sub-agency overrides
- Show bonus calculation: invite-count bonus, Diamond-volume bonus, Full Bonus badge
- Progress bars toward each bonus threshold

**Widget decomposition**:
- `AgentEarningsDashboardTab` — `StatelessWidget`, scrollable `ListView`
- `_MonthComparisonCard` — two-column card (current vs previous month) with trend arrow
- `_EarningsBreakdownSection` — three `_BreakdownRow` widgets (gift comm, referral, override)
- `_BonusSection` — two `_BonusCard` widgets (invite bonus, volume bonus) + optional `_FullBonusBadge`
- `_BonusCard` — shows metric name, current value, threshold, progress bar, bonus amount

**Static data**:
```dart
const _kCurrentMonth = 3_420.0;   // Diamonds
const _kPreviousMonth = 2_850.0;
const _kInviteTarget = 30;
const _kInviteCurrent = 34;
const _kVolumeTarget = 10_000.0;
const _kVolumeCurrent = 11_200.0;
```

---

### 3. Withdrawal Screen (`agent_withdrawal_tab.dart` → `WithdrawalScreen`)

**Location**: Navigated to from agent dashboard AppBar action button

**Responsibilities**:
- Display withdrawable residual income balance
- Form: amount field, payment method selector, account details field
- Validation: amount > 0, amount ≤ balance, amount ≥ 50 (minimum threshold)
- On valid submit: show confirmation card with "Pending" badge
- History list of past withdrawal requests

**Widget decomposition**:
- `WithdrawalScreen` — `Scaffold` with `AppBar` + `ListView`
- `_BalanceCard` — shows withdrawable balance prominently
- `_WithdrawalForm` — `StatefulWidget` with form fields and validation logic
- `_MethodSelector` — horizontal scroll of payment method chips
- `_WithdrawalConfirmation` — shown after successful submit (replaces form)
- `_WithdrawalHistoryList` — `ListView` of `_WithdrawalHistoryRow` widgets

**Static data**:
```dart
const _kWithdrawableBalance = 1_850.0;
const _kMinWithdrawal = 50.0;

final _fakeWithdrawalHistory = [
  _WithdrawalRequest(id: 'WD-001', amount: 500, method: 'Vodafone Cash',
      status: 'approved', date: DateTime(2026, 4, 15)),
  _WithdrawalRequest(id: 'WD-002', amount: 200, method: 'InstaPay',
      status: 'pending', date: DateTime(2026, 5, 1)),
  _WithdrawalRequest(id: 'WD-003', amount: 100, method: 'Bank Transfer',
      status: 'rejected', date: DateTime(2026, 3, 20)),
];
```

---

### 4. Sub-Agency Screen Enhancement (`sub_agency_screen.dart`)

**Changes to existing file**:
- Replace the name+code add form with a UID-based lookup flow
- Add UID validation (6–12 digit numeric string)
- Show "User not found" error for unknown UIDs (checked against static dataset)
- Enhance the Overview tab with aggregate stats: total subordinates, active count, total network invites, total network earnings

**New widget**:
- `_AddByUidSheet` — replaces `_AddSubAgentSheet`; single UID text field with numeric keyboard, validation, fake lookup delay, "User not found" error state

**Static UID lookup table**:
```dart
const _knownUsers = {
  '100001': 'Youssef_Pro',
  '100002': 'Layla_Star',
  '100003': 'Omar_Elite',
  '100004': 'Nadia_VIP',
  '100005': 'Tarek_Boss',
};
```

---

### 5. Referral Tracking Tab (`agent_referral_tab.dart`)

**Location**: Agent dashboard, Tab 5 ("👥 Referrals")

**Responsibilities**:
- Summary row: total referrals, active referrals, total commission
- List of referral log entries: username, UID, join date, status, gifts sent, commission earned
- "Active" badge for invitees with gifts in current month

**Widget decomposition**:
- `AgentReferralTab` — `StatelessWidget`, `ListView`
- `_ReferralSummaryCard` — three-column summary (total, active, commission)
- `_ReferralList` — `ListView.builder` of `_ReferralRow`
- `_ReferralRow` — card with username, UID, join date, status badge, gift count, commission

**Static data**:
```dart
class _ReferralEntry {
  final String username;
  final String uid;
  final DateTime joinDate;
  final String status;       // 'active' | 'inactive'
  final int giftsThisMonth;
  final double commissionEarned;
}
```

---

### 6. Payment Screen Enhancement (`payment_screen.dart`)

**Changes to existing file**:
- Add USDT payment method to `_methods` list in `_PaymentSheet`
- Add Google Pay payment method to `_methods` list
- Add `_UsdtFlow` widget: shows wallet address, TxID input field, validation, "Pending Verification" confirmation
- Add `Refunded` status to `_OrderCard` (red badge, same as Failed)
- Add a fake refunded order to `_fakeOrders`

**New widgets** (to avoid DDC crash in `_PaymentSheet.build`):
- `_UsdtFlow` — `StatefulWidget`; wallet address display, TxID `TextField`, submit button, confirmation state
- `_UsdtConfirmation` — shown after valid TxID submit; displays TxID and "Pending" badge

**TxID validation rule**: non-empty, alphanumeric only (`RegExp(r'^[a-zA-Z0-9]+$')`), minimum 10 characters.

---

### 7. USDT Settlement Tab (`usdt_settlement_tab.dart`)

**Location**: Admin dashboard, Tab 8 ("₿ USDT Settlement")

**Responsibilities**:
- List pending USDT settlement requests
- Approve action: updates status to "Approved", shows snackbar
- Reject action: prompts for rejection reason (required), updates status to "Rejected"
- Validation: rejection reason must be non-empty

**Widget decomposition**:
- `UsdtSettlementTab` — `StatefulWidget`, holds mutable list of requests
- `_SettlementList` — `ListView.builder` of `_SettlementCard`
- `_SettlementCard` — shows agent name, UID, TxID, Diamond amount, date, status badge; Approve/Reject buttons when pending
- `_RejectDialog` — `AlertDialog` with a `TextField` for rejection reason

**Static data**:
```dart
class _SettlementRequest {
  final String id;
  final String agentName;
  final String agentUid;
  final String txId;
  final int diamondAmount;
  final DateTime submittedAt;
  String status;   // mutable: 'pending' | 'approved' | 'rejected'
  String? rejectionReason;
}
```

---

### 8. Admin Agency Overview Tab (`agency_overview_tab.dart`)

**Location**: Admin dashboard, Tab 9 ("🌐 Agency Overview")

**Responsibilities**:
- Summary panel: agency counts by type, total Diamond volume (Recharge), pending withdrawals count+value, pending USDT settlements count+value
- Type cards: tappable, navigates to filtered agency list (reuses `AgencyTypesTab` filter logic or pushes a filtered screen)
- Agency list with name, UID, type badge, status badge, key metric
- Status change from detail view (active ↔ suspended ↔ pending)

**Widget decomposition**:
- `AgencyOverviewTab` — `StatefulWidget`, `ListView`
- `_SummaryPanel` — 2×2 `GridView` of `StatCard` widgets
- `_PendingAlerts` — row showing pending withdrawals + USDT settlements with counts
- `_AgencyTypeCards` — horizontal scroll of `_TypeOverviewCard` (tappable)
- `_AgencyDetailList` — `ListView.builder` of `_AgencyDetailRow`
- `_AgencyDetailRow` — expandable; shows key metric and inline status-change buttons

---

## Data Models

All data models are defined as private Dart classes within their respective files (UI-only, no serialization needed).

### Shared Status Values

| Status | Badge Color | Used In |
|--------|-------------|---------|
| `active` | `Colors.greenAccent` | Agencies, sub-agents, referrals |
| `pending` | `AppColors.gold` | Agencies, withdrawals, USDT settlements |
| `suspended` | `AppColors.red` | Agencies, sub-agents |
| `approved` | `Colors.greenAccent` | Withdrawals, USDT settlements |
| `rejected` | `AppColors.red` | Withdrawals, USDT settlements |
| `success` | `Colors.greenAccent` | Recharge orders |
| `failed` | `AppColors.red` | Recharge orders |
| `refunded` | `AppColors.red` | Recharge orders |

### Agency Type Key Metrics

| Type | Key Metric Field | Display Label |
|------|-----------------|---------------|
| USDT | `walletAddress` | Wallet |
| Recharge | `diamondCreditLimit` | Credit Limit |
| Country | `region` | Region |
| Shipping | `maxTransferCap` | Max Transfer |

### Withdrawal Request

```dart
class _WithdrawalRequest {
  final String id;
  final double amount;
  final String method;
  String status;   // pending | approved | rejected
  final DateTime date;
}
```

### USDT Settlement Request

```dart
class _SettlementRequest {
  final String id;
  final String agentName;
  final String agentUid;
  final String txId;
  final int diamondAmount;
  final DateTime submittedAt;
  String status;
  String? rejectionReason;
}
```

### Referral Entry

```dart
class _ReferralEntry {
  final String username;
  final String uid;
  final DateTime joinDate;
  final String status;
  final int giftsThisMonth;
  final double commissionEarned;
}
```

---

## Error Handling

Since this is a UI-only feature with no network calls, error handling focuses on user input validation and UI state management.

### Input Validation Rules

| Field | Rule | Error Message |
|-------|------|---------------|
| Withdrawal amount | > 0 and ≤ balance | "Amount exceeds available balance" |
| Withdrawal amount | ≥ 50 Diamonds | "Minimum withdrawal is 🪙50" |
| Withdrawal amount | Non-empty | "Please enter an amount" |
| USDT TxID | Non-empty, alphanumeric, ≥ 10 chars | "TxID must be at least 10 alphanumeric characters" |
| Sub-agent UID | 6–12 digit numeric string | "UID must be 6–12 digits" |
| Sub-agent UID | Must exist in static dataset | "User not found" |
| Rejection reason | Non-empty | "Please provide a rejection reason" |

### UI State Patterns

All interactive forms follow the same pattern already established in `sub_agency_screen.dart` and `payment_screen.dart`:

1. **Idle**: form fields visible, submit button enabled
2. **Validating**: inline error message shown below the offending field, submit blocked
3. **Processing**: `CircularProgressIndicator` replaces button label, `Future.delayed` simulates async work
4. **Success**: confirmation widget replaces form, optional `SnackBar` notification
5. **Error**: error container with red border shown above form

### Empty States

Every list view must handle the empty state with a centered emoji + descriptive text, following the pattern in `_SubAgentsList`.

---

## Testing Strategy

This feature is a UI-only Flutter implementation with static/fake data. It consists entirely of widget trees, state management via `setState`, and hardcoded data models. There are no pure functions, parsers, serializers, or algorithmic transformations that would benefit from property-based testing.

**PBT assessment**: Not applicable. All acceptance criteria describe UI interactions, visual states, and static data display — none involve universal properties over a varying input space that would be cost-effective to test with 100+ iterations.

### Unit Tests (Example-Based)

Focus on the validation logic extracted into pure functions:

| Test | What to verify |
|------|---------------|
| `validateWithdrawalAmount` | Returns error for amount > balance |
| `validateWithdrawalAmount` | Returns error for amount < 50 |
| `validateWithdrawalAmount` | Returns null for valid amount |
| `validateTxId` | Returns error for empty string |
| `validateTxId` | Returns error for string < 10 chars |
| `validateTxId` | Returns error for non-alphanumeric input |
| `validateTxId` | Returns null for valid 10+ char alphanumeric |
| `validateSubAgentUid` | Returns error for non-numeric input |
| `validateSubAgentUid` | Returns error for < 6 digits |
| `validateSubAgentUid` | Returns error for > 12 digits |
| `validateSubAgentUid` | Returns null for valid 6–12 digit string |
| `validateRejectionReason` | Returns error for empty/whitespace |
| `validateRejectionReason` | Returns null for non-empty string |

### Widget Tests (Example-Based)

| Test | What to verify |
|------|---------------|
| `AgencyTypesTab` | Renders 4 type cards |
| `AgencyTypesTab` | Tapping a type card filters the list |
| `AgentEarningsDashboardTab` | Shows green trend when current > previous month |
| `AgentEarningsDashboardTab` | Shows red trend when current < previous month |
| `AgentEarningsDashboardTab` | Shows "Full Bonus" badge when both targets met |
| `WithdrawalScreen` | Submit blocked when amount > balance |
| `WithdrawalScreen` | Submit blocked when amount < 50 |
| `WithdrawalScreen` | Shows confirmation card after valid submit |
| `_UsdtFlow` | Submit blocked for TxID < 10 chars |
| `_UsdtFlow` | Shows pending confirmation after valid TxID |
| `UsdtSettlementTab` | Approve updates card status to "Approved" |
| `UsdtSettlementTab` | Reject blocked when reason is empty |
| `UsdtSettlementTab` | Reject updates card status to "Rejected" with reason |
| `AgentReferralTab` | Active badge shown for entries with giftsThisMonth > 0 |
| `SubAgencyScreen` | "User not found" shown for unknown UID |
| `SubAgencyScreen` | UID validation rejects non-numeric input |

### Integration / Smoke Tests

| Test | What to verify |
|------|---------------|
| Admin dashboard | Renders with 9 tabs after extension |
| Agent dashboard | Renders with 5 tabs after extension |
| Navigation | Withdrawal screen accessible from agent dashboard |
| Navigation | Agency type filter navigates correctly |
| Theme | All new screens use `AppColors.background` scaffold |
