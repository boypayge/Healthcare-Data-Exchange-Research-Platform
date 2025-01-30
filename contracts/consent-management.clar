;; Consent Management Contract

(define-map consents
  { patient: principal, dataset-id: uint }
  { granted: bool, last-updated: uint }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))

(define-read-only (get-consent (patient principal) (dataset-id uint))
  (default-to
    { granted: false, last-updated: u0 }
    (map-get? consents { patient: patient, dataset-id: dataset-id })
  )
)

(define-public (grant-consent (dataset-id uint))
  (ok (map-set consents
    { patient: tx-sender, dataset-id: dataset-id }
    { granted: true, last-updated: block-height }
  ))
)

(define-public (revoke-consent (dataset-id uint))
  (ok (map-set consents
    { patient: tx-sender, dataset-id: dataset-id }
    { granted: false, last-updated: block-height }
  ))
)

(define-read-only (check-consent (patient principal) (dataset-id uint))
  (get granted (get-consent patient dataset-id))
)

