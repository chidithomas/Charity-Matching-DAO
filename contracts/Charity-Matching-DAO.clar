;; Charity Matching DAO Smart Contract
;; Matches user donations with DAO treasury contributions

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-treasury (err u101))
(define-constant err-invalid-amount (err u102))
(define-constant err-charity-not-approved (err u103))
(define-constant err-matching-limit-exceeded (err u104))

;; Data variables
(define-data-var treasury-balance uint u0)
(define-data-var matching-ratio uint u100) ;; 100 = 1:1 matching, 50 = 0.5:1 matching
(define-data-var total-matched uint u0)
(define-data-var max-match-per-donation uint u1000000) ;; 1 STX in microSTX

;; Maps
(define-map approved-charities principal bool)
(define-map charity-total-received principal uint)
(define-map donor-total-donated principal uint)
(define-map donation-history {donor: principal, charity: principal, block: uint} {amount: uint, matched-amount: uint})

;; Read-only functions
(define-read-only (get-treasury-balance)
  (var-get treasury-balance))

(define-read-only (get-matching-ratio)
  (var-get matching-ratio))

(define-read-only (get-total-matched)
  (var-get total-matched))

(define-read-only (is-charity-approved (charity principal))
  (default-to false (map-get? approved-charities charity)))

(define-read-only (get-charity-total (charity principal))
  (default-to u0 (map-get? charity-total-received charity)))

(define-read-only (get-donor-total (donor principal))
  (default-to u0 (map-get? donor-total-donated donor)))

(define-read-only (calculate-match-amount (donation-amount uint))
  (/ (* donation-amount (var-get matching-ratio)) u100))

;; Public functions

;; Add funds to treasury (only owner)
(define-public (add-to-treasury (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> amount u0) err-invalid-amount)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set treasury-balance (+ (var-get treasury-balance) amount))
    (ok true)))

;; Approve charity (only owner)
(define-public (approve-charity (charity principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set approved-charities charity true)
    (ok true)))

;; Remove charity approval (only owner)
(define-public (remove-charity (charity principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set approved-charities charity false)
    (ok true)))

;; Set matching ratio (only owner)
(define-public (set-matching-ratio (new-ratio uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set matching-ratio new-ratio)
    (ok true)))

;; Set maximum match per donation (only owner)
(define-public (set-max-match (new-max uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set max-match-per-donation new-max)
    (ok true)))

;; Main donation function with matching
(define-public (donate-with-match (charity principal) (amount uint))
  (let (
    (match-amount (calculate-match-amount amount))
    (capped-match (if (> match-amount (var-get max-match-per-donation))
                      (var-get max-match-per-donation)
                      match-amount))
    (current-treasury (var-get treasury-balance))
    (donation-id {donor: tx-sender, charity: charity, block: block-height})
  )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (is-charity-approved charity) err-charity-not-approved)
    (asserts! (>= current-treasury capped-match) err-insufficient-treasury)

    ;; Transfer donation from donor to charity
    (try! (stx-transfer? amount tx-sender charity))

    ;; Transfer matching amount from contract to charity
    (try! (as-contract (stx-transfer? capped-match tx-sender charity)))

    ;; Update state variables
    (var-set treasury-balance (- current-treasury capped-match))
    (var-set total-matched (+ (var-get total-matched) capped-match))

    ;; Update maps
    (map-set charity-total-received charity 
             (+ (get-charity-total charity) amount capped-match))
    (map-set donor-total-donated tx-sender 
             (+ (get-donor-total tx-sender) amount))
    (map-set donation-history donation-id 
             {amount: amount, matched-amount: capped-match})

    (ok {donated: amount, matched: capped-match, total-to-charity: (+ amount capped-match)})))

;; Emergency withdraw (only owner)
(define-public (emergency-withdraw (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= amount (var-get treasury-balance)) err-insufficient-treasury)
    (try! (as-contract (stx-transfer? amount tx-sender contract-owner)))
    (var-set treasury-balance (- (var-get treasury-balance) amount))
    (ok true)))

;; Get donation history
(define-read-only (get-donation (donor principal) (charity principal) (block-num uint))
  (map-get? donation-history {donor: donor, charity: charity, block: block-num}))