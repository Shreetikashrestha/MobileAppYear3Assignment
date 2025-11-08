
// // Requirements
// // 1. Create an abstract base class BankAccount that includes:
// // • Private fields for account number, account holder name, and balance
// // • Abstract methods for withdraw() and deposit()
// // • A method to display account information
// // • Proper encapsulation with getters/setters
// // 2. Implement three types of accounts that inherit from BankAccount:
// // SavingsAccount:
// // • Minimum balance requirement of $500
// // • 2% interest calculation method
// // • Withdrawal limit of 3 transactions per month
// // CheckingAccount:
// // • No minimum balance
// // • $35 overdraft fee if balance goes below $0
// // • No withdrawal limits
// // PremiumAccount:
// // • Minimum balance of $10,000
// // • 5% interest calculation
// // • Unlimited free withdrawals
// // 3. Create an interface/abstract class InterestBearing for accounts that earn interest
// // 4. Implement a Bank class that can:
// // • Create new accounts
// // • Find accounts by account number
// // • Transfer money between accounts
// // • Generate reports of all accounts

// // 






// // Interface for interest-bearing accounts
// abstract class InterestBearing {
//   void calculateInterest();
// }

// // Abstract BankAccount
// abstract class BankAccount {
//   String _accountNumber;
//   String _accountHolderName;
//   double _balance;

//   BankAccount(this._accountNumber, this._accountHolderName, this._balance);

//   // Getters
//   String get accountNumber {
//     return _accountNumber;
//   }

//   String get accountHolderName {
//     return _accountHolderName;
//   }

//   double get balance {
//     return _balance;
//   }

//   // Setters
//   set balance(double value) {
//     _balance = value;
//   }

//   // Abstract methods
//   void deposit(double amount);
//   void withdraw(double amount);

//   // Display info
//   void displayInfo() {
//     print("Account: ${_accountNumber}, Holder: ${_accountHolderName}, Balance: $_balance");
//   }
// }

// // SavingsAccount
// class SavingsAccount extends BankAccount implements InterestBearing {
//   int _withdrawals = 0;

//   SavingsAccount(String accountNumber, String accountHolderName, double balance) 
//       : super(accountNumber, accountHolderName, balance);

//   @override
//   void deposit(double amount) {
//     _balance = _balance + amount;
//   }

//   @override
//   void withdraw(double amount) {
//     if (_withdrawals >= 3) {
//       print("Withdrawal limit reached for SavingsAccount");
//       return;
//     }
//     if (_balance - amount < 500) {
//       print("Cannot withdraw below minimum balance of 500");
//       return;
//     }
//     _balance = _balance - amount;
//     _withdrawals = _withdrawals + 1;
//   }

//   @override
//   void calculateInterest() {
//     _balance = _balance + (_balance * 0.02);
//   }
// }

// // CheckingAccount
// class CheckingAccount extends BankAccount {
//   CheckingAccount(String accountNumber, String accountHolderName, double balance)
//       : super(accountNumber, accountHolderName, balance);

//   @override
//   void deposit(double amount) {
//     _balance = _balance + amount;
//   }

//   @override
//   void withdraw(double amount) {
//     _balance = _balance - amount;
//     if (_balance < 0) {
//       print("Overdraft! $35 fee applied");
//       _balance = _balance - 35;
//     }
//   }
// }

// // PremiumAccount
// class PremiumAccount extends BankAccount implements InterestBearing {
//   PremiumAccount(String accountNumber, String accountHolderName, double balance) 
//       : super(accountNumber, accountHolderName, balance) {
//     if (_balance < 10000) {
//       throw Exception('Minimum balance of 10000 required');
//     }
//   }

//   @override
//   void deposit(double amount) {
//     _balance = _balance + amount;
//   }

//   @override
//   void withdraw(double amount) {
//     _balance = _balance - amount;
//   }

//   @override
//   void calculateInterest() {
//     _balance = _balance + (_balance * 0.05);
//   }
// }

// // Bank class
// class Bank {
//   List<BankAccount> accounts = [];

//   void createAccount(BankAccount acc) {
//     accounts.add(acc);
//   }

//   BankAccount? findAccount(String num) {
//     for (var a in accounts) {
//       if (a.accountNumber == num) {
//         return a;
//       }
//     }
//     return null;
//   }

//   void transfer(String from, String to, double amt) {
//     BankAccount? f = findAccount(from);
//     BankAccount? t = findAccount(to);

//     if (f != null && t != null && f.balance >= amt) {
//       f.withdraw(amt);
//       t.deposit(amt);
//     } else {
//       print("Transfer failed: check balances or account numbers");
//     }
//   }

//   void generateReport() {
//     for (var acc in accounts) {
//       acc.displayInfo();
//       if (acc is InterestBearing) {
//         acc.calculateInterest();
//       }
//     }
//   }
// }

// // Main
// void main() {
//   Bank bank = Bank();
//   bank.createAccount(SavingsAccount('S1', 'John', 1000));
//   bank.createAccount(CheckingAccount('C1', 'Jane', 500));
//   bank.createAccount(PremiumAccount('P1', 'Alice', 15000));

//   bank.accounts[0].withdraw(100); // SavingsAccount
//   bank.transfer('S1', 'C1', 200);
//   bank.generateReport();
// }





// Interface for interest-bearing accounts
abstract class InterestBearing {
  void calculateInterest();
}

// Abstract BankAccount
abstract class BankAccount {
  String _accountNumber;
  String _accountHolderName;
  double _balance;

  BankAccount(this._accountNumber, this._accountHolderName, this._balance);

  // Getters
  String get accountNumber {
    return _accountNumber;
  }

  String get accountHolderName {
    return _accountHolderName;
  }

  double get balance {
    return _balance;
  }

  // Setters
  set balance(double value) {
    _balance = value;
  }

  // Abstract methods
  void deposit(double amount);
  void withdraw(double amount);

  // Display info
  void displayInfo() {
    print("Account: ${_accountNumber}, Holder: ${_accountHolderName}, Balance: $_balance");
  }
  
  void calculateInterest() {}
}

// SavingsAccount
class SavingsAccount extends BankAccount implements InterestBearing {
  int _withdrawals = 0;

  SavingsAccount(String accountNumber, String accountHolderName, double balance) 
      : super(accountNumber, accountHolderName, balance);

  @override
  void deposit(double amount) {
    _balance = _balance + amount;
  }

  @override
  void withdraw(double amount) {
    if (_withdrawals >= 3) {
      print("Withdrawal limit reached for SavingsAccount");
      return;
    }
    if (_balance - amount < 500) {
      print("Cannot withdraw below minimum balance of 500");
      return;
    }
    _balance = _balance - amount;
    _withdrawals = _withdrawals + 1;
    print("Withdrawn $amount from SavingsAccount. Remaining balance: $_balance");
  }

  @override
  void calculateInterest() {
    _balance = _balance + (_balance * 0.02);
    print("Interest added to SavingsAccount. New balance: $_balance");
  }
}

// CheckingAccount
class CheckingAccount extends BankAccount {
  CheckingAccount(String accountNumber, String accountHolderName, double balance)
      : super(accountNumber, accountHolderName, balance);

  @override
  void deposit(double amount) {
    _balance = _balance + amount;
    print("Deposited $amount to CheckingAccount. New balance: $_balance");
  }

  @override
  void withdraw(double amount) {
    _balance = _balance - amount;
    if (_balance < 0) {
      print("Overdraft! $35 fee applied to CheckingAccount");
      _balance = _balance - 35;
    }
    print("Withdrawn $amount from CheckingAccount. Remaining balance: $_balance");
  }
}

// PremiumAccount
class PremiumAccount extends BankAccount implements InterestBearing {
  PremiumAccount(String accountNumber, String accountHolderName, double balance) 
      : super(accountNumber, accountHolderName, balance) {
    if (_balance < 10000) {
      throw Exception('Minimum balance of 10000 required');
    }
  }

  @override
  void deposit(double amount) {
    _balance = _balance + amount;
    print("Deposited $amount to PremiumAccount. New balance: $_balance");
  }

  @override
  void withdraw(double amount) {
    _balance = _balance - amount;
    print("Withdrawn $amount from PremiumAccount. Remaining balance: $_balance");
  }

  @override
  void calculateInterest() {
    _balance = _balance + (_balance * 0.05);
    print("Interest added to PremiumAccount. New balance: $_balance");
  }
}

// Bank class
class Bank {
  List<BankAccount> accounts = [];

  void createAccount(BankAccount acc) {
    accounts.add(acc);
    print("Account ${acc.accountNumber} created for ${acc.accountHolderName}");
  }

  BankAccount? findAccount(String num) {
    for (var a in accounts) {
      if (a.accountNumber == num) {
        return a;
      }
    }
    return null;
  }

  void transfer(String from, String to, double amt) {
    BankAccount? f = findAccount(from);
    BankAccount? t = findAccount(to);

    if (f != null && t != null) {
      if (f is CheckingAccount || f.balance >= amt) {
        f.withdraw(amt);
        t.deposit(amt);
        print("Transferred $amt from ${f.accountNumber} to ${t.accountNumber}");
      } else {
        print("Transfer failed: insufficient balance");
      }
    } else {
      print("Transfer failed: account not found");
    }
  }

  void generateReport() {
    print("\n--- Bank Report ---");
    for (var acc in accounts) {
      if (acc is InterestBearing) {
        acc.calculateInterest(); // Apply interest first
      }
      acc.displayInfo();
    }
    print("--- End of Report ---\n");
  }
}

// Main
void main() {
  Bank bank = Bank();
  bank.createAccount(SavingsAccount('S1', 'John', 1000));
  bank.createAccount(CheckingAccount('C1', 'Jane', 500));
  bank.createAccount(PremiumAccount('P1', 'Alice', 15000));

  bank.accounts[0].withdraw(100); // SavingsAccount
  bank.transfer('S1', 'C1', 200);
  bank.generateReport();
}
