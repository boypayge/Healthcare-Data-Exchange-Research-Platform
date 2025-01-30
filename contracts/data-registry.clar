;; Data Registry Contract

(define-map datasets
  { dataset-id: uint }
  {
    provider: principal,
    description: (string-utf8 500),
    data-hash: (buff 32),
    creation-date: uint,
    last-updated: uint,
    is-active: bool
  }
)

(define-data-var dataset-id-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_ALREADY_EXISTS (err u409))

(define-read-only (get-dataset (dataset-id uint))
  (map-get? datasets { dataset-id: dataset-id })
)

(define-public (register-dataset (description (string-utf8 500)) (data-hash (buff 32)))
  (let
    ((new-dataset-id (+ (var-get dataset-id-nonce) u1)))
    (map-set datasets
      { dataset-id: new-dataset-id }
      {
        provider: tx-sender,
        description: description,
        data-hash: data-hash,
        creation-date: block-height,
        last-updated: block-height,
        is-active: true
      }
    )
    (var-set dataset-id-nonce new-dataset-id)
    (ok new-dataset-id)
  )
)

(define-public (update-dataset (dataset-id uint) (new-description (string-utf8 500)) (new-data-hash (buff 32)))
  (let
    ((dataset (unwrap! (map-get? datasets { dataset-id: dataset-id }) ERR_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get provider dataset)) ERR_UNAUTHORIZED)
    (ok (map-set datasets
      { dataset-id: dataset-id }
      (merge dataset
        {
          description: new-description,
          data-hash: new-data-hash,
          last-updated: block-height
        }
      )
    ))
  )
)

(define-public (deactivate-dataset (dataset-id uint))
  (let
    ((dataset (unwrap! (map-get? datasets { dataset-id: dataset-id }) ERR_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get provider dataset)) ERR_UNAUTHORIZED)
    (ok (map-set datasets
      { dataset-id: dataset-id }
      (merge dataset { is-active: false })
    ))
  )
)

(define-read-only (get-active-datasets)
  (ok (var-get dataset-id-nonce))
)

