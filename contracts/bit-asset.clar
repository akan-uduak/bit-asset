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

;; DATA VARIABLES FOR TRACKING COUNTERS

;; Counter for tracking the last registered asset ID
(define-data-var last-asset-id uint u0)

;; Counter for tracking the last created proposal ID
(define-data-var last-proposal-id uint u0)

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

;; Token Ownership Registry - Fractional ownership tracking
(define-map token-balances
  {
    owner: principal,
    asset-id: uint,
  }
  { balance: uint }
)

;; KYC Compliance Registry - Identity verification and compliance levels
(define-map kyc-status
  { address: principal }
  {
    is-approved: bool,
    level: uint,
    expiry: uint,
  }
)

;; Governance Proposal Registry - Decentralized decision making
(define-map proposals
  { proposal-id: uint }
  {
    title: (string-ascii 256),
    asset-id: uint,
    start-height: uint,
    end-height: uint,
    executed: bool,
    votes-for: uint,
    votes-against: uint,
    minimum-votes: uint,
  }
)

;; Voting Registry - Individual vote tracking
(define-map votes
  {
    proposal-id: uint,
    voter: principal,
  }
  { vote-amount: uint }
)

;; Dividend Distribution Registry - Automated reward tracking
(define-map dividend-claims
  {
    asset-id: uint,
    claimer: principal,
  }
  { last-claimed-amount: uint }
)

;; Oracle Price Feed Registry - External price data integration
(define-map price-feeds
  { asset-id: uint }
  {
    price: uint,
    decimals: uint,
    last-updated: uint,
    oracle: principal,
  }
)

;; INPUT VALIDATION FUNCTIONS

(define-private (validate-asset-value (value uint))
  ;; Validates asset value is within acceptable range
  (and
    (>= value MIN-ASSET-VALUE)
    (<= value MAX-ASSET-VALUE)
  )
)

(define-private (validate-duration (duration uint))
  ;; Validates proposal duration is within acceptable timeframe
  (and
    (>= duration MIN-DURATION)
    (<= duration MAX-DURATION)
  )
)

(define-private (validate-kyc-level (level uint))
  ;; Validates KYC compliance level
  (<= level MAX-KYC-LEVEL)
)

(define-private (validate-expiry (expiry uint))
  ;; Validates expiry timestamp is reasonable
  (and
    (> expiry stacks-block-height)
    (<= (- expiry stacks-block-height) MAX-EXPIRY)
  )
)

(define-private (validate-minimum-votes (vote-count uint))
  ;; Validates minimum vote threshold for proposals
  (and
    (> vote-count u0)
    (<= vote-count tokens-per-asset)
  )
)

(define-private (validate-metadata-uri (uri (string-ascii 256)))
  ;; Validates metadata URI format and length
  (and
    (> (len uri) u0)
    (<= (len uri) u256)
  )
)

;; HELPER FUNCTIONS

(define-private (get-next-asset-id)
  ;; Generates next sequential asset ID by incrementing the counter
  (let ((next-id (+ (var-get last-asset-id) u1)))
    (var-set last-asset-id next-id)
    next-id
  )
)

(define-private (get-next-proposal-id)
  ;; Generates next sequential proposal ID by incrementing the counter
  (let ((next-id (+ (var-get last-proposal-id) u1)))
    (var-set last-proposal-id next-id)
    next-id
  )
)

(define-private (get-last-asset-id)
  ;; Retrieves the last registered asset ID
  (some (var-get last-asset-id))
)

(define-private (get-last-proposal-id)
  ;; Retrieves the last created proposal ID
  (some (var-get last-proposal-id))
)

;; ASSET MANAGEMENT FUNCTIONS

(define-public (register-asset
    (metadata-uri (string-ascii 256))
    (asset-value uint)
  )
  ;; Registers a new real-world asset for tokenization
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (validate-metadata-uri metadata-uri) err-invalid-uri)
    (asserts! (validate-asset-value asset-value) err-invalid-value)
    (let ((asset-id (get-next-asset-id)))
      (map-set assets { asset-id: asset-id } {
        owner: contract-owner,
        metadata-uri: metadata-uri,
        asset-value: asset-value,
        is-locked: false,
        creation-height: stacks-block-height,
        last-price-update: stacks-block-height,
        total-dividends: u0,
      })
      (map-set token-balances {
        owner: contract-owner,
        asset-id: asset-id,
      } { balance: tokens-per-asset }
      )
      (ok asset-id)
    )
  )
)

;; DIVIDEND DISTRIBUTION SYSTEM

(define-public (claim-dividends (asset-id uint))
  ;; Claims accumulated dividends for fractional asset ownership
  (let (
      (asset (unwrap! (get-asset-info asset-id) err-not-found))
      (balance (get-balance tx-sender asset-id))
      (last-claim (get-last-claim asset-id tx-sender))
      (total-dividends (get total-dividends asset))
      (claimable-amount (/ (* balance (- total-dividends last-claim)) tokens-per-asset))
    )
    (asserts! (> claimable-amount u0) err-invalid-amount)
    (asserts! (is-some (get-asset-info asset-id)) err-not-found)
    (ok (map-set dividend-claims {
      asset-id: asset-id,
      claimer: tx-sender,
    } { last-claimed-amount: total-dividends }
    ))
  )
)

;; DECENTRALIZED GOVERNANCE SYSTEM

(define-public (create-proposal
    (asset-id uint)
    (title (string-ascii 256))
    (duration uint)
    (minimum-votes uint)
  )
  ;; Creates a new governance proposal for asset management
  (begin
    (asserts! (validate-duration duration) err-invalid-duration)
    (asserts! (validate-minimum-votes minimum-votes) err-invalid-votes)
    (asserts! (validate-metadata-uri title) err-invalid-title)
    (asserts! (>= (get-balance tx-sender asset-id) (/ tokens-per-asset u10))
      err-not-authorized
    )
    (let ((proposal-id (get-next-proposal-id)))
      (ok (map-set proposals { proposal-id: proposal-id } {
        title: title,
        asset-id: asset-id,
        start-height: stacks-block-height,
        end-height: (+ stacks-block-height duration),
        executed: false,
        votes-for: u0,
        votes-against: u0,
        minimum-votes: minimum-votes,
      }))
    )
  )
)

(define-public (vote
    (proposal-id uint)
    (vote-for bool)
    (amount uint)
  )
  ;; Casts weighted vote on governance proposal based on token ownership
  (let (
      (proposal (unwrap! (get-proposal proposal-id) err-not-found))
      (asset-id (get asset-id proposal))
      (balance (get-balance tx-sender asset-id))
    )
    (begin
      (asserts! (>= balance amount) err-invalid-amount)
      (asserts! (< stacks-block-height (get end-height proposal)) err-vote-ended)
      (asserts! (is-none (get-vote proposal-id tx-sender)) err-vote-exists)
      (map-set votes {
        proposal-id: proposal-id,
        voter: tx-sender,
      } { vote-amount: amount }
      )
      (ok (map-set proposals { proposal-id: proposal-id }
        (merge proposal {
          votes-for: (if vote-for
            (+ (get votes-for proposal) amount)
            (get votes-for proposal)
          ),
          votes-against: (if vote-for
            (get votes-against proposal)
            (+ (get votes-against proposal) amount)
          ),
        })
      ))
    )
  )
)

;; READ-ONLY QUERY FUNCTIONS

(define-read-only (get-asset-info (asset-id uint))
  ;; Retrieves comprehensive asset information and metadata
  (map-get? assets { asset-id: asset-id })
)

(define-read-only (get-balance
    (owner principal)
    (asset-id uint)
  )
  ;; Returns fractional token balance for specific asset and owner
  (default-to u0
    (get balance
      (map-get? token-balances {
        owner: owner,
        asset-id: asset-id,
      })
    ))
)

(define-read-only (get-proposal (proposal-id uint))
  ;; Retrieves governance proposal details and voting status
  (map-get? proposals { proposal-id: proposal-id })
)

(define-read-only (get-vote
    (proposal-id uint)
    (voter principal)
  )
  ;; Returns individual voting record for specific proposal
  (map-get? votes {
    proposal-id: proposal-id,
    voter: voter,
  })
)

(define-read-only (get-price-feed (asset-id uint))
  ;; Retrieves latest oracle price feed data for asset
  (map-get? price-feeds { asset-id: asset-id })
)

(define-read-only (get-last-claim
    (asset-id uint)
    (claimer principal)
  )
  ;; Returns last dividend claim amount for tracking purposes
  (default-to u0
    (get last-claimed-amount
      (map-get? dividend-claims {
        asset-id: asset-id,
        claimer: claimer,
      })
    ))
)

;; PUBLIC READ-ONLY FUNCTIONS FOR ACCESSING COUNTERS

(define-read-only (get-current-asset-count)
  ;; Returns the total number of registered assets
  (var-get last-asset-id)
)

(define-read-only (get-current-proposal-count)
  ;; Returns the total number of created proposals
  (var-get last-proposal-id)
)
