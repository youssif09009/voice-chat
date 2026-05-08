# Tasks — Agency Management System

## Task List

- [ ] 1. Extend Admin Dashboard shell to 9 tabs
  - [ ] 1.1 Update `TabController(length: 6)` to `length: 9` in `admin_dashboard_screen.dart`
  - [ ] 1.2 Add three new `Tab` entries to the `TabBar`: `🏢 Agency Types`, `₿ USDT Settlement`, `🌐 Agency Overview`
  - [ ] 1.3 Add three placeholder `Widget` entries to `TabBarView` (replaced in later tasks)
  - [ ] 1.4 Import the three new tab files once they exist

- [ ] 2. Extend Agent Dashboard shell to 5 tabs and add Withdrawal navigation
  - [ ] 2.1 Update `TabController(length: 3)` to `length: 5` in `agent_dashboard_screen.dart`
  - [ ] 2.2 Add two new `Tab` entries: `📈 My Earnings`, `👥 Referrals`
  - [ ] 2.3 Add two placeholder `Widget` entries to `TabBarView` (replaced in later tasks)
  - [ ] 2.4 Add a `💸 Withdraw` `IconButton` to the agent dashboard `AppBar` actions that navigates to `WithdrawalScreen`
  - [ ] 2.5 Import the new tab and screen files once they exist

- [ ] 3. Create Agency Types Tab (Admin Tab 7)
  - [ ] 3.1 Create `client/lib/screens/agency/tabs/agency_types_tab.dart`
  - [ ] 3.2 Define `AgencyType` enum (`usdt`, `recharge`, `country`, `shipping`) and `_Agency` data class with all type-specific nullable fields
  - [ ] 3.3 Define `_fakeAgencies` static list with at least 2 entries per type, covering all four `AgencyType` values and all type-specific fields
  - [ ] 3.4 Implement `AgencyTypesTab` as a `StatefulWidget` holding `_selectedType` filter state
  - [ ] 3.5 Implement `_TypeSummaryGrid` — 2×2 `GridView` of `_TypeCard` widgets showing count per type; tapping a card sets `_selectedType` filter
  - [ ] 3.6 Implement `_AgencyListView` — `ListView.builder` filtered by `_selectedType`; shows all agencies when filter is null
  - [ ] 3.7 Implement `_AgencyRow` — expandable card showing name, UID, type badge, status badge, key metric; inline Activate/Suspend buttons that mutate `status` via `setState` on the parent
  - [ ] 3.8 Wire `AgencyTypesTab` into admin dashboard Tab 7 (replacing placeholder)

- [ ] 4. Create Agent Earnings Dashboard Tab (Agent Tab 4)
  - [ ] 4.1 Create `client/lib/screens/agency/agent_tabs/agent_earnings_dashboard_tab.dart`
  - [ ] 4.2 Define static constants: `_kCurrentMonth`, `_kPreviousMonth`, invite target/current, volume target/current, and earnings breakdown values
  - [ ] 4.3 Implement `AgentEarningsDashboardTab` as a `StatelessWidget` with a `ListView`
  - [ ] 4.4 Implement `_MonthComparisonCard` — two-column layout showing current vs previous month earnings; compute trend percentage and display green ↑ or red ↓ indicator based on comparison
  - [ ] 4.5 Implement `_EarningsBreakdownSection` — three `_BreakdownRow` widgets for gift commissions, referral bonuses, and sub-agency overrides
  - [ ] 4.6 Implement `_BonusSection` — two `_BonusCard` widgets (invite bonus, volume bonus) each with metric name, current value, threshold, `LinearProgressIndicator`, and bonus amount
  - [ ] 4.7 Implement `_FullBonusBadge` — shown when both invite and volume targets are met (current >= target for both)
  - [ ] 4.8 Wire `AgentEarningsDashboardTab` into agent dashboard Tab 4 (replacing placeholder)

- [ ] 5. Create Withdrawal Screen
  - [ ] 5.1 Create `client/lib/screens/agency/agent_tabs/withdrawal_screen.dart`
  - [ ] 5.2 Define `_WithdrawalRequest` data class and `_fakeWithdrawalHistory` static list with at least 3 entries covering `pending`, `approved`, and `rejected` statuses
  - [ ] 5.3 Implement `WithdrawalScreen` as a `Scaffold` with `AppBar` and a `ListView` containing balance card, form, and history
  - [ ] 5.4 Implement `_BalanceCard` — displays `_kWithdrawableBalance` (1850.0 Diamonds) prominently
  - [ ] 5.5 Implement `_WithdrawalForm` as a `StatefulWidget` with: amount `TextField`, payment method selector (`_MethodSelector`), account details `TextField`, and submit button
  - [ ] 5.6 Implement validation: show inline error if amount is empty, if amount > balance, or if amount < 50; prevent submission in all error cases
  - [ ] 5.7 Implement `_WithdrawalConfirmation` — replaces the form after valid submit; shows request details and a "Pending" `StatusBadge`
  - [ ] 5.8 Implement `_WithdrawalHistoryList` — `ListView` of `_WithdrawalHistoryRow` widgets showing id, amount, method, status badge, date
  - [ ] 5.9 Wire `WithdrawalScreen` into agent dashboard AppBar action (task 2.4)

- [ ] 6. Enhance Sub-Agency Screen with UID-based add flow
  - [ ] 6.1 Add `_knownUsers` static map (`uid → username`) with at least 5 entries to `sub_agency_screen.dart`
  - [ ] 6.2 Add `uid` field to `_SubAgent` data class
  - [ ] 6.3 Implement `_AddByUidSheet` — replaces `_AddSubAgentSheet`; single UID `TextField` with `TextInputType.number`, validation (6–12 digit numeric), fake lookup delay, "User not found" error for unknown UIDs, success adds agent to list
  - [ ] 6.4 Replace `_showAddSheet` call to use `_AddByUidSheet` instead of `_AddSubAgentSheet`
  - [ ] 6.5 Update `_SubAgencyOverview` to display aggregate stats: total subordinates, active count, total network invites, total network earnings (already partially present — verify all four stats are shown)

- [ ] 7. Create Referral Tracking Tab (Agent Tab 5)
  - [ ] 7.1 Create `client/lib/screens/agency/agent_tabs/agent_referral_tab.dart`
  - [ ] 7.2 Define `_ReferralEntry` data class and `_fakeReferrals` static list with at least 5 entries; include at least 2 entries with `giftsThisMonth > 0` (active) and at least 2 with `giftsThisMonth == 0` (inactive)
  - [ ] 7.3 Implement `AgentReferralTab` as a `StatelessWidget` with a `ListView`
  - [ ] 7.4 Implement `_ReferralSummaryCard` — three-column card showing total referrals, active referrals count, and total commission earned (computed from static list)
  - [ ] 7.5 Implement `_ReferralList` — `ListView.builder` of `_ReferralRow` widgets
  - [ ] 7.6 Implement `_ReferralRow` — card showing username, UID, join date, status badge; "Active" `StatusBadge` shown when `giftsThisMonth > 0`; gift count and commission earned displayed
  - [ ] 7.7 Wire `AgentReferralTab` into agent dashboard Tab 5 (replacing placeholder)

- [ ] 8. Enhance Payment Screen with USDT flow and Google Pay
  - [ ] 8.1 Add USDT method tile to `_methods` list in `_PaymentSheet` (id: `'usdt'`, name: `'USDT (Crypto)'`, icon: `'₿'`, color: `Color(0xFFF7931A)`)
  - [ ] 8.2 Add Google Pay method tile to `_methods` list (id: `'gpay'`, name: `'Google Pay'`, icon: `'G'`, color: `Color(0xFF4285F4)`)
  - [ ] 8.3 Implement `_UsdtFlow` as a `StatefulWidget`: displays a static wallet address, a TxID `TextField`, inline validation error, submit button, and transitions to `_UsdtConfirmation` on valid submit
  - [ ] 8.4 Implement TxID validation: non-empty, matches `RegExp(r'^[a-zA-Z0-9]+$')`, length >= 10; show inline error message on failure
  - [ ] 8.5 Implement `_UsdtConfirmation` — shows submitted TxID, wallet address, and a "Pending Verification" `StatusBadge`
  - [ ] 8.6 In `_PaymentSheet.build`, when `_selectedMethod == 'usdt'` and user taps Pay, show `_UsdtFlow` instead of the normal payment processing flow
  - [ ] 8.7 Add a `Refunded` status case to `_OrderCard._statusColor` and `_OrderCard._statusIcon` (red color, `Icons.replay_rounded`)
  - [ ] 8.8 Add one `Refunded` order entry to `_fakeOrders` static list

- [ ] 9. Create USDT Settlement Tab (Admin Tab 8)
  - [ ] 9.1 Create `client/lib/screens/agency/tabs/usdt_settlement_tab.dart`
  - [ ] 9.2 Define `_SettlementRequest` data class (mutable `status` and `rejectionReason`) and `_fakeSettlements` static list with at least 4 entries: 2 pending, 1 approved, 1 rejected
  - [ ] 9.3 Implement `UsdtSettlementTab` as a `StatefulWidget` holding a mutable copy of the settlements list
  - [ ] 9.4 Implement `_SettlementList` — `ListView.builder` of `_SettlementCard` widgets
  - [ ] 9.5 Implement `_SettlementCard` — shows agent name, UID, TxID (truncated), Diamond amount, submission date, status badge; Approve and Reject buttons visible only when status is `pending`
  - [ ] 9.6 Implement Approve action: updates `status` to `'approved'` via `setState`, shows a green `SnackBar`
  - [ ] 9.7 Implement `_RejectDialog` — `AlertDialog` with a `TextField` for rejection reason; submit blocked and error shown if reason is empty; on valid submit, updates `status` to `'rejected'` and stores `rejectionReason`
  - [ ] 9.8 Wire `UsdtSettlementTab` into admin dashboard Tab 8 (replacing placeholder)

- [ ] 10. Create Admin Agency Overview Tab (Admin Tab 9)
  - [ ] 10.1 Create `client/lib/screens/agency/tabs/agency_overview_tab.dart`
  - [ ] 10.2 Reuse or import `_Agency` data class and `_fakeAgencies` from `agency_types_tab.dart` (or define a shared static list accessible to both tabs)
  - [ ] 10.3 Define static summary constants: total Diamond volume by Recharge agencies, pending withdrawal count and combined value, pending USDT settlement count and combined Diamond value
  - [ ] 10.4 Implement `AgencyOverviewTab` as a `StatefulWidget` with a `ListView`
  - [ ] 10.5 Implement `_SummaryPanel` — 2×2 `GridView` of `StatCard` widgets: agency count by type (4 cards), total Recharge volume, pending withdrawals, pending USDT settlements
  - [ ] 10.6 Implement `_PendingAlerts` — row showing pending withdrawal and USDT settlement counts with gold warning icon; only shown when counts > 0
  - [ ] 10.7 Implement `_AgencyTypeCards` — horizontally scrollable row of `_TypeOverviewCard` widgets; tapping a card sets a `_selectedType` filter on the tab
  - [ ] 10.8 Implement `_AgencyDetailList` — `ListView.builder` of `_AgencyDetailRow` widgets filtered by `_selectedType`
  - [ ] 10.9 Implement `_AgencyDetailRow` — expandable card showing name, UID, type badge, status badge, key metric; inline status-change buttons (Activate / Suspend / Set Pending) that mutate status via `setState`
  - [ ] 10.10 Wire `AgencyOverviewTab` into admin dashboard Tab 9 (replacing placeholder)

- [ ] 11. Theme and consistency pass
  - [ ] 11.1 Verify all new `Scaffold` widgets use `backgroundColor: AppColors.background`
  - [ ] 11.2 Verify all new card/container widgets use `color: AppColors.surface` as their decoration color
  - [ ] 11.3 Verify all new primary buttons and indicators use `AppColors.primaryPurple`
  - [ ] 11.4 Verify all Diamond monetary values are prefixed with `🪙` and all fiat values use the appropriate currency symbol (EGP)
  - [ ] 11.5 Verify no live-room, medal, or streaming UI elements appear in any new screen
  - [ ] 11.6 Verify all new `build()` methods that exceed ~80 lines of widget tree are split into separate named widget classes

- [ ] 12. Create `agent_tabs` directory and ensure all new agent files are importable
  - [ ] 12.1 Confirm `client/lib/screens/agency/agent_tabs/` directory exists (created implicitly when files are written)
  - [ ] 12.2 Add correct relative imports in `agent_dashboard_screen.dart` for all new agent tab files
  - [ ] 12.3 Add correct relative imports in `admin_dashboard_screen.dart` for all new admin tab files
