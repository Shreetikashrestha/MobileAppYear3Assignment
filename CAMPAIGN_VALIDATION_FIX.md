# Campaign Creation Validation - Complete

## Requirements Implemented

### 1. Budget Range Validation
- **Minimum Budget**: Must be at least ₹100 (or NPR 100)
- **Maximum Budget**: Cannot exceed ₹1,000,000 (1 Million)
- **Range Validation**: Maximum budget must be greater than or equal to minimum budget

### 2. Date Validation
- **Only Present or Future Dates**: Campaign deadline cannot be in the past
- **Date Picker**: Automatically restricts selection to dates from today onwards
- **Submit Validation**: Additional check to prevent past dates if somehow selected

## Validation Levels

### Level 1: Inline Field Validation
Validates as you type in the budget fields:

**Min Budget Field**:
- Shows "Required" if empty
- Shows "Invalid number" if not a valid number
- Shows "Min ₹100" if less than 100
- Shows "Max ₹1M" if greater than 1,000,000

**Max Budget Field**:
- Shows "Required" if empty
- Shows "Invalid number" if not a valid number
- Shows "Min ₹100" if less than 100
- Shows "Max ₹1M" if greater than 1,000,000
- Shows "Must be ≥ min" if less than minimum budget

### Level 2: Submit Validation
Additional checks when submitting the form:

1. **Budget Validation**:
   - Checks if minimum budget is at least ₹100
   - Checks if maximum budget doesn't exceed ₹1,000,000
   - Checks if minimum budget is not greater than maximum budget
   - Shows clear error messages via SnackBar

2. **Date Validation**:
   - Checks if deadline is selected
   - Checks if deadline is not in the past
   - Shows clear error messages via SnackBar

## Error Messages

### Budget Errors
- "Minimum budget must be at least ₹100" (or NPR 100)
- "Maximum budget cannot exceed ₹1,000,000" (or NPR 1,000,000)
- "Minimum budget cannot be greater than maximum budget"
- "Please enter valid budget amounts"

### Date Errors
- "Please select a deadline"
- "Campaign deadline cannot be in the past"

## User Experience Improvements

1. **Visual Hints**:
   - Budget fields show "Budget range: ₹100 - ₹1,000,000" below the fields
   - Deadline field shows "Only present or future dates allowed" below the field

2. **Date Picker Restrictions**:
   - `firstDate: DateTime.now()` - Prevents selecting past dates
   - `lastDate: DateTime.now().add(Duration(days: 365))` - Allows up to 1 year in future

3. **Clear Labels**:
   - Budget fields labeled as "Min Budget (₹)" and "Max Budget (₹)"
   - Placeholder hints show example values

## Files Modified

### 1. Brand Home Create Campaign Screen
**File**: `MobileAppYear3Assignment/lib/features/home/presentation/pages/create_campaign_screen.dart`

**Changes**:
- Added budget range validation (100 to 1,000,000)
- Added inline validators for budget fields
- Added submit-time validation for budget range
- Added past date validation
- Added visual hints for budget range and date restrictions
- Updated field labels to include currency symbol

### 2. Campaign Feature Create Campaign Screen
**File**: `MobileAppYear3Assignment/lib/features/campaign/presentation/pages/create_campaign_screen.dart`

**Changes**:
- Enhanced budget validators (already had basic validation)
- Added submit-time validation for budget range
- Added past date validation
- Added clear error messages with red background
- Date picker already restricted to present/future dates

## Testing Instructions

### Test Budget Validation

1. **Test Minimum Budget < 100**:
   - Enter Min Budget: 50
   - Enter Max Budget: 500
   - Try to submit
   - Expected: Error "Minimum budget must be at least ₹100"

2. **Test Maximum Budget > 1,000,000**:
   - Enter Min Budget: 100
   - Enter Max Budget: 2000000
   - Try to submit
   - Expected: Error "Maximum budget cannot exceed ₹1,000,000"

3. **Test Min > Max**:
   - Enter Min Budget: 5000
   - Enter Max Budget: 1000
   - Try to submit
   - Expected: Error "Minimum budget cannot be greater than maximum budget"

4. **Test Valid Range**:
   - Enter Min Budget: 1000
   - Enter Max Budget: 5000
   - Should pass validation

### Test Date Validation

1. **Test Date Picker**:
   - Click on "Campaign Deadline" field
   - Try to select a past date
   - Expected: Past dates should be disabled/grayed out

2. **Test Valid Date**:
   - Select today's date or any future date
   - Should pass validation

3. **Test No Date Selected**:
   - Leave deadline empty
   - Try to submit
   - Expected: Error "Please select a deadline"

## Code Examples

### Budget Validation Code
```dart
// Inline validation
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Required';
  }
  final budget = double.tryParse(value);
  if (budget == null) {
    return 'Invalid number';
  }
  if (budget < 100) {
    return 'Min ₹100';
  }
  if (budget > 1000000) {
    return 'Max ₹1M';
  }
  return null;
}

// Submit validation
if (minBudget < 100) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Minimum budget must be at least ₹100'),
      backgroundColor: Colors.red,
    ),
  );
  return;
}
```

### Date Validation Code
```dart
// Date picker restriction
final DateTime? picked = await showDatePicker(
  context: context,
  initialDate: DateTime.now().add(const Duration(days: 30)),
  firstDate: DateTime.now(), // Only allow present or future dates
  lastDate: DateTime.now().add(const Duration(days: 365)),
);

// Submit validation
if (_selectedDeadline!.isBefore(DateTime.now())) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Campaign deadline cannot be in the past'),
      backgroundColor: Colors.red,
    ),
  );
  return;
}
```

## Summary

Both create campaign screens now have comprehensive validation:
- Budget must be between ₹100 and ₹1,000,000
- Campaign deadline must be present or future date
- Clear error messages guide users to fix issues
- Visual hints inform users of requirements
- Inline validation provides immediate feedback
- Submit validation catches any edge cases

Hot restart the app to see the changes!
