#lang racket

(define lam (string->symbol "\u03BB"))

(define (expr-compare x y)
    (cond
          ; test case 1: check if x, y are the same thing
          [(equal? x y) y]

          ; test cases 3-6: handle boolean values - fix this
          [(and (boolean? x) (boolean? y))
              (if y (if x #t '(not %)) (if x '% #f))
          ]

          ; handle lists and 'lambda vs lam
          [(list-compare x y)
           (if (and (pair? x) (pair? y))
               (if
                   (or
                     (and (equal? (car x) 'lambda) (equal? (car y) lam))
                     (and (equal? (car x) lam) (equal? (car y) 'lambda))
                   )
                   (handle-lambda lam x y)
                   (list 'if '% x y) )
               (list 'if '% x y) 
            )
          ]

          ; handle lambda
          [(both-first-equal x y 'lambda)
              (handle-lambda 'lambda x y)]
      
          [(both-first-equal x y lam)
              (handle-lambda lam x y)]

          [else (rec_cmp x y)]
    )
)


(define (empty-list? e1)
  (equal? e1 '())
)

(define (get-cat a b)
    (string-append (symbol->string a) "!" (symbol->string b))

)


(define (concatenate-symbols a b)
     (if
       (string-contains? (symbol->string a) "!")
       a
       (string->symbol (get-cat a b))
     )
)


(define (new-x head tail x)
  (cons (concatenate-symbols (car head) (car tail)) x)
)

(define (new-y head y)
  (cons (car head) y)
)

(define (new-z tail z)
  (cons (car tail) z)
)

(define (lamlam val x) 
    (lamlam-helper val x 0)
)

(define (lamlam-helper val x index)
    (if (equal? (car val) x) index (lamlam-helper (cdr val) x (+ 1 index)))
)

(define (check-stmts x y z)
  (or
          (stmt-compare x y z)
          (stmt-compare y x z)
  )
)


(define (list-compare x y)
  (or
          (and (not(list? x)) (not(list? y)) ) ;3
          (not (equal? (length y) (length x))) ;4
          (either-equal x y 'quote) ;5
          (check-stmts x y 'if)
          (check-stmts x y lam)
          (check-stmts x y 'lambda) ;6-12 (not 10)   
  )
)


(define (check_all head tail x y z)
    (cond
        [(both-equal head tail '() ) (list x y z)]
        [(equal? (car head) (car tail))
          (check_all (cdr head) (cdr tail) x y z)]
        [else 
          (check_all (cdr head) (cdr tail) (new-x head tail x) (new-y head y) (new-z tail z))]
    )
)

(define (hh9 n n1 x a)
  (cons (let ((index (lamlam x (car n)))) (list-ref a index)) (index-helper (cdr n) n1 x a))
)

(define (check-mem n x)
    (member (car n) x) 
)

;;fix this
(define (index-helper n n1 x a) 
    (cond
      [(empty-list? n)
          '()]
      [(list? (car n))
          (cons (index-helper (car n) n1 x a) (index-helper (cdr n) n1 x a))]
      [(check-mem n x)
          (hh9 n n1 x a)]
      [else
          (cons (car n) (index-helper (cdr n) n1 x a))]
    )
)

(define (index-cmp comparator x a)
  (cons (let ((i (lamlam x (get-second comparator) ))) (cons (list-ref a i) (cdr (car comparator)))) (get-index (cdr comparator) x a ))
)

(define (get-last comparator x a)
  (cons (car comparator) (get-index (cdr comparator) x a))
)

(define (get-index comparator x a)
    (cond 
        [(empty-list? comparator) '()]
        [(member (get-second comparator) x) (index-cmp comparator x a)]
        [else (get-last comparator x a)]
    )
)

(define (find_bindings head tail x y z)
    (cond 
        [(both-equal head tail '() ) (list x y z)]
        [(equal? (get-second head) (get-second tail))
                (find_bindings (cdr head) (cdr tail) x y z)]
        [else
                (find_bindings (cdr head) (cdr tail) (new-x (car head) (car tail) x) (new-y (car head) y) (new-z (car tail) z))]
    )
)

(define (both-equal x y z)
  (and (equal? x '()) (equal? y '())) 
)

(define (both-first-equal x y z)
  (and (equal? (car x) z) (equal? (car y) z))
)

(define (either-equal x y z)
  (or (equal? (car x) z) (equal? (car y) z))
)

(define (stmt-compare x y z)
  (not (or (equal? z (car x) ) (not (equal? z (car y) ))))
)

(define (handle-check_all a b var)
    (expr-compare
         (index-helper (cdr a) (cdr b) (get-tail var) (car var)) 
     (index-helper (cdr b) (cdr b) (get-tail (cdr var)) (car var))

    )
)

(define (h2 type x y var)
  (cons type (handle-check_all x y var))
)

(define (get-tail x)
  (car (cdr x))
)

(define (rec-helper x)
  (cdr (cdr x))
)

(define (get-second x)
  (car (car x))
)

(define (n-bindings x)
  (length (get-tail x))
)


(define (handle-lambda type x y)
    (if (equal? (n-bindings x) (n-bindings y)) 
      (let ((var (check_all (get-tail x) (get-tail y) '() '() '()))) 
      (h2 type x y var)) 
      (list 'if '% x y)
    )
)

(define (rec_cmp head tail) (cons (expr-compare (car head) (car tail)) (expr-compare (cdr head) (cdr tail))))

(define (test-expr-compare x y) 
  (if (and
            (equal?
                (eval x)
                (eval (list 'let '((% #t)) (expr-compare x y)))
            )
            (equal?
                (eval y)
                (eval (list 'let '((% #f)) (expr-compare x y)))
            )
         ) #t #f)
)


;things to test:
;equal numbers
;different numbers
;booleans
;quote
;lambda
;lam
;lambda + lam

(define test-expr-x
  (list
    #t
    #t
    #f
    #f
    12
    12
    '(1 2 3)
    '(1 2 3)
    '(cons a b)
    '(cons a b)
    'symbol1
    'symbol2
    "Str1"
    "Str2"
    '(+ a b)
    '(+ a b)
    '(+ 3 (- a b))
    ''(1 2)
    '(quote (1 2))
    '(lambda (a b) (+ a b))
    '(if a b c)
    '(if a b c)
  )
)

(define test-expr-y
  (list
      #t
      #f
      #t
      #f
      12
      20
      '(3 4 5)
      '(4 5 6)
      '(cons a b)
      '(cons c d)
      'symbol1
      'symbol3
      "Str1"
      "Str3"
      '(+ a b)
      '(+ b a)
      '(+ 3 (- c d))
      ''(4 3)
      '(quote (3 4))
      '(lambda (a b) (+ a b))
      '(if a b c)
      '(if b c a)
  )
)
;(expr-compare test-expr-x test-expr-y)
