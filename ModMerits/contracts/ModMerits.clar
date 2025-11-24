;; ModMerits - A tipping service for community moderators
;; Built on Stacks blockchain in Clarity

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-amount (err u101))
(define-constant err-moderator-not-found (err u102))
(define-constant err-already-registered (err u103))
(define-constant err-transfer-failed (err u104))

;; Data Variables
(define-data-var platform-fee-percentage uint u5) ;; 5% platform fee

;; Data Maps
(define-map moderators
    principal
    {
        discord-id: (string-ascii 100),
        total-tips-received: uint,
        is-active: bool
    }
)

(define-map tip-history
    { tipper: principal, moderator: principal, tip-id: uint }
    {
        amount: uint,
        timestamp: uint,
        message: (string-utf8 280)
    }
)

(define-data-var tip-counter uint u0)

;; Read-only functions

(define-read-only (get-moderator-info (moderator principal))
    (map-get? moderators moderator)
)

(define-read-only (get-platform-fee)
    (var-get platform-fee-percentage)
)

(define-read-only (get-tip-details (tipper principal) (moderator principal) (tip-id uint))
    (map-get? tip-history { tipper: tipper, moderator: moderator, tip-id: tip-id })
)

(define-read-only (is-moderator-registered (moderator principal))
    (is-some (map-get? moderators moderator))
)

;; Public functions

;; Register as a moderator
(define-public (register-moderator (discord-id (string-ascii 100)))
    (let
        (
            (caller tx-sender)
        )
        (asserts! (is-none (map-get? moderators caller)) err-already-registered)
        (ok (map-set moderators caller {
            discord-id: discord-id,
            total-tips-received: u0,
            is-active: true
        }))
    )
)

;; Send a tip to a moderator
(define-public (send-tip (moderator principal) (amount uint) (message (string-utf8 280)))
    (let
        (
            (tipper tx-sender)
            (fee (/ (* amount (var-get platform-fee-percentage)) u100))
            (tip-amount (- amount fee))
            (moderator-data (unwrap! (map-get? moderators moderator) err-moderator-not-found))
            (current-tip-id (var-get tip-counter))
        )
        ;; Validate amount
        (asserts! (> amount u0) err-invalid-amount)
        (asserts! (get is-active moderator-data) err-moderator-not-found)
        
        ;; Transfer STX to moderator
        (unwrap! (stx-transfer? tip-amount tipper moderator) err-transfer-failed)
        
        ;; Transfer platform fee to contract owner
        (if (> fee u0)
            (unwrap! (stx-transfer? fee tipper contract-owner) err-transfer-failed)
            true
        )
        
        ;; Update moderator's total tips
        (map-set moderators moderator
            (merge moderator-data { 
                total-tips-received: (+ (get total-tips-received moderator-data) tip-amount)
            })
        )
        
        ;; Record tip history
        (map-set tip-history 
            { tipper: tipper, moderator: moderator, tip-id: current-tip-id }
            {
                amount: tip-amount,
                timestamp: stacks-block-height,
                message: message
            }
        )
        
        ;; Increment tip counter
        (var-set tip-counter (+ current-tip-id u1))
        
        (ok tip-amount)
    )
)

;; Deactivate moderator account (can only be done by the moderator themselves)
(define-public (deactivate-account)
    (let
        (
            (caller tx-sender)
            (moderator-data (unwrap! (map-get? moderators caller) err-moderator-not-found))
        )
        (ok (map-set moderators caller
            (merge moderator-data { is-active: false })
        ))
    )
)

;; Reactivate moderator account
(define-public (reactivate-account)
    (let
        (
            (caller tx-sender)
            (moderator-data (unwrap! (map-get? moderators caller) err-moderator-not-found))
        )
        (ok (map-set moderators caller
            (merge moderator-data { is-active: true })
        ))
    )
)

;; Admin function to update platform fee (only contract owner)
(define-public (set-platform-fee (new-fee uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (<= new-fee u20) err-invalid-amount) ;; Max 20% fee
        (ok (var-set platform-fee-percentage new-fee))
    )
)