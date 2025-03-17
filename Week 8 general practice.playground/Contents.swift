//basic banking system with account management and deposits/withdrawals, while ensuring concurrency safety in Swift.

import Foundation

enum AccountType {
    case savings, checking
}

// Actor to manage the next account number safely
actor AccountNumberGenerator {
    private var nextAccountNumber = 1001
    
    func generateNewAccountNumber() -> Int {
        let newNumber = nextAccountNumber
        nextAccountNumber += 1
        return newNumber
    }
}

// Global instance of the actor
let accountNumberGenerator = AccountNumberGenerator()

// Marking BankAccount as @unchecked Sendable to allow safe usage across actors
class BankAccount: @unchecked Sendable {
    let accountNumber: Int
    let accountType: AccountType
    private(set) var balance: Double
    
    init(accountType: AccountType, initialDeposit: Double) async {
        self.accountNumber = await accountNumberGenerator.generateNewAccountNumber()
        self.accountType = accountType
        self.balance = initialDeposit
    }
    
    func deposit(amount: Double) {
        balance += amount
        print("Deposited $\(amount). New balance: $\(balance)")
    }
    
    func withdraw(amount: Double) -> Bool {
        if amount > balance {
            print("Insufficient funds! Withdrawal failed.")
            return false
        }
        balance -= amount
        print("Withdrew $\(amount). New balance: $\(balance)")
        return true
    }
}

// Example Usage (Must be inside an async context)
Task {
    let account1 = await BankAccount(accountType: .savings, initialDeposit: 500.0)
    let account2 = await BankAccount(accountType: .checking, initialDeposit: 1000.0)

    account1.deposit(amount: 200)
    account2.withdraw(amount: 300)
    
    print("Account \(account1.accountNumber) balance: $\(account1.balance)")
    print("Account \(account2.accountNumber) balance: $\(account2.balance)")
}
