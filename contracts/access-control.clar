;; Access Control Contract

(define-map access-permissions
  { dataset-id: uint, researcher: principal }
  { granted: bool, expiration: uint }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))

(define-read-only (get-access-permission (dataset-id uint) (researcher principal))
  (default-to
    { granted: false, expiration: u0 }
    (map-get? access-permissions { dataset-id: dataset-id, researcher: researcher })
  )
)

(define-public (grant-access (dataset-id uint) (researcher principal) (duration uint))
  (let
    ((dataset (unwrap! (contract-call? .data-registry get-dataset dataset-id) ERR_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get provider dataset)) ERR_UNAUTHORIZED)
    (ok (map-set access-permissions
      { dataset-id: dataset-id, researcher: researcher }
      { granted: true, expiration: (+ block-height duration) }
    ))
  )
)

(define-public (revoke-access (dataset-id uint) (researcher principal))
  (let
    ((dataset (unwrap! (contract-call? .data-registry get-dataset dataset-id) ERR_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get provider dataset)) ERR_UNAUTHORIZED)
    (ok (map-set access-permissions
      { dataset-id: dataset-id, researcher: researcher }
      { granted: false, expiration: block-height }
    ))
  )
)

(define-read-only (check-access (dataset-id uint) (researcher principal))
  (let
    ((permission (get-access-permission dataset-id researcher)))
    (and (get granted permission) (> (get expiration permission) block-height))
  )
)

