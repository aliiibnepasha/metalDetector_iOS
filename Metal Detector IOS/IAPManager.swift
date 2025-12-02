//
//  IAPManager.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import Foundation
import StoreKit
import Combine

class IAPManager: ObservableObject {
    static let shared = IAPManager()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Product ID
    private let monthlyProductID = "com.theswiftvision.metaldetectorios.monthly"
    
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        // Load products on initialization
        Task {
            await loadProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Load Products
    @MainActor
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let productIDs = [monthlyProductID]
            products = try await Product.products(for: productIDs)
            isLoading = false
            print("✅ Products loaded: \(products.count)")
        } catch {
            isLoading = false
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("❌ Error loading products: \(error)")
        }
    }
    
    // MARK: - Get Monthly Product
    var monthlyProduct: Product? {
        return products.first { $0.id == monthlyProductID }
    }
    
    // MARK: - Purchase Product
    @MainActor
    func purchase(_ product: Product) async throws -> Bool {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updatePurchasedProducts()
                return true
                
            case .userCancelled:
                print("⚠️ User cancelled purchase")
                return false
                
            case .pending:
                print("⏳ Purchase pending")
                return false
                
            @unknown default:
                print("❓ Unknown purchase result")
                return false
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            print("❌ Purchase error: \(error)")
            throw error
        }
    }
    
    // MARK: - Check Verification
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Listen for Transactions
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    print("❌ Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Update Purchased Products
    @MainActor
    func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productID == monthlyProductID {
                    purchasedIDs.insert(transaction.productID)
                }
            } catch {
                print("❌ Error checking entitlement: \(error)")
            }
        }
        
        purchasedProductIDs = purchasedIDs
    }
    
    // MARK: - Check if User is Premium
    var isPremium: Bool {
        return purchasedProductIDs.contains(monthlyProductID)
    }
    
    // MARK: - Restore Purchases
    @MainActor
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            print("✅ Purchases restored")
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            print("❌ Restore error: \(error)")
        }
    }
}

enum StoreError: Error {
    case failedVerification
}

