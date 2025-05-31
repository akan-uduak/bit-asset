;; BITASSET PROTOCOL - TOKENIZED REAL WORLD ASSETS ON BITCOIN

;;
;; Title: BitAsset Protocol - Fractional Real-World Asset Tokenization
;;
;; Summary: A comprehensive Layer 2 protocol for tokenizing, trading, and 
;; governing real-world assets on the Bitcoin network through Stacks blockchain.
;; Enables fractional ownership, dividend distribution, and decentralized 
;; governance of physical and digital assets.
;;
;; Description: BitAsset Protocol transforms traditional asset ownership by 
;; creating Semi-Fungible Tokens (SFTs) backed by real-world assets. Each asset
;; is fractionalized into 100,000 tokens, enabling micro-investment opportunities
;; while maintaining Bitcoin's security and Stacks' smart contract capabilities.
;; The protocol includes KYC compliance, oracle price feeds, governance voting,
;; and automated dividend distribution - creating a bridge between traditional
;; finance and Bitcoin DeFi ecosystem.
;;
;; Features:
;; - Fractional asset tokenization (1:100,000 ratio)
;; - KYC/AML compliance framework
;; - Oracle-based price feeds
;; - Decentralized governance with weighted voting
;; - Automated dividend distribution
;; - Asset value tracking and updates
;; - Proposal-based asset management
;;

;; CONSTANTS & CONFIGURATION

;; Administrative Constants
(define-constant contract-owner tx-sender)

;; Error Code Registry
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-listed (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-not-authorized (err u104))
(define-constant err-kyc-required (err u105))
(define-constant err-vote-exists (err u106))
(define-constant err-vote-ended (err u107))
(define-constant err-price-expired (err u108))
(define-constant err-invalid-uri (err u110))
(define-constant err-invalid-value (err u111))
(define-constant err-invalid-duration (err u112))
(define-constant err-invalid-kyc-level (err u113))
(define-constant err-invalid-expiry (err u114))
(define-constant err-invalid-votes (err u115))
(define-constant err-invalid-address (err u116))
(define-constant err-invalid-title (err u117))

;; Protocol Configuration Limits
(define-constant MAX-ASSET-VALUE u1000000000000) ;; 1 trillion satoshis
(define-constant MIN-ASSET-VALUE u1000) ;; 1 thousand satoshis
(define-constant MAX-DURATION u144) ;; ~1 day in blocks
(define-constant MIN-DURATION u12) ;; ~1 hour in blocks
(define-constant MAX-KYC-LEVEL u5) ;; Maximum KYC compliance level
(define-constant MAX-EXPIRY u52560) ;; ~1 year in blocks

;; Tokenization Parameters
(define-constant tokens-per-asset u100000) ;; Fixed fractionalization ratio

;; DATA STRUCTURES & STORAGE MAPS

;; Asset Registry - Core asset information and metadata
(define-map assets
  { asset-id: uint }
  {
    owner: principal,
    metadata-uri: (string-ascii 256),
    asset-value: uint,
    is-locked: bool,
    creation-height: uint,
    last-price-update: uint,
    total-dividends: uint,
  }
)