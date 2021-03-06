module ParserTest where

import Test.Framework
import Test.Framework.Providers.HUnit
import Test.HUnit
import Syntax
import Parser

expressions =
    [ "Parser Lit 1"    ~: parseExpr "True"
                            ~?= ELit (LBool True)
    , "Parser Lit 2"    ~: parseExpr "False"
                            ~?= ELit (LBool False)
    , "Parser Lit 3"    ~: parseExpr "0"
                            ~?= ELit (LInt 0)
    , "Parser Lit 4"    ~: parseExpr "9223372036854775807"
                            ~?= ELit (LInt 9223372036854775807)
    , "Parser Variable" ~: parseExpr "x"
                            ~?= (EVar "x")
    , "Parser Lambda"   ~: parseExpr "fun x -> x"
                            ~?= (ELam "x" (EVar "x"))
    , "Parser App"      ~: parseExpr "(fun x -> x) 1"
                            ~?= (EApp (ELam "x" (EVar "x")) (ELit (LInt 1)))
    , "Parser Let 1"    ~: parseExpr "let x = 1 in x"
                            ~?= (ELet "x" (ELit (LInt 1)) (EVar "x"))
    , "Parser Let 2"    ~: parseExpr "let add x y = x + y in add 10 20"
                            ~?= (ELet "add" (ELam "x" (ELam "y" (EOp Add (EVar "x") (EVar "y"))))
                                          (EApp (EApp (EVar "add") (ELit (LInt 10))) (ELit (LInt 20))))
    , "Parser Fix"      ~: parseExpr "fix f (fun x -> x)"
                            ~?= (EFix "f" (ELam "x" (EVar "x")))
    , "Parser If"       ~: parseExpr "if True then 1 else 2"
                            ~?= (EIf (ELit (LBool True)) (ELit (LInt 1)) (ELit (LInt 2)))
    , "Parser Let rec 1" ~: parseExpr "let rec fib = (fun x -> if x==0 || x==1 then 1 else fib (x-1) + fib (x-2)) in fib 10"
                             ~?= (ELet "fib" (EFix "fib" (ELam "x"
                                                          (EIf (EOp Or (EOp Eq (EVar "x") (ELit (LInt 0))) (EOp Eq (EVar "x") (ELit (LInt 1))))
                                                                   (ELit (LInt 1))
                                                           (EOp Add (EApp (EVar "fib") (EOp Sub (EVar "x") (ELit (LInt 1))))
                                                                    (EApp (EVar "fib") (EOp Sub (EVar "x") (ELit (LInt 2))))))))
                                  (EApp (EVar "fib") (ELit (LInt 10))))
    , "Parser Let rec 2" ~: parseExpr "let rec fact n = if n==0 then 1 else n * n-1 in fact 10"
                             ~?= (ELet "fact" (EFix "fact" (ELam "n"
                                                            (EIf (EOp Eq (EVar "n") (ELit (LInt 0)))
                                                                     (ELit (LInt 1))
                                                                     (EOp Sub (EOp Mul (EVar "n") (EVar "n")) (ELit (LInt 1))))))
                                  (EApp (EVar "fact") (ELit (LInt 10))))
        ]

precedence =[
      "Parser Prec 01" ~: parseExpr "1 + 2 * 3"
                          ~?= (EOp Add
                               (ELit (LInt 1))
                               (EOp Mul (ELit (LInt 2))
                                        (ELit (LInt 3))))
    , "Parser Prec 02" ~: parseExpr "True == False || 1 + 2 > 1"
                           ~?= (EOp Or
                                (EOp Eq (ELit (LBool True))
                                 (ELit (LBool False)))
                                (EOp Gt (EOp Add (ELit (LInt 1))
                                         (ELit (LInt 2)))
                                 (ELit (LInt 1))))
    , "Parser Prec 03" ~: parseExpr "1 + f 2"
                           ~?= (EOp Add (ELit (LInt 1))
                                (EApp (EVar "f") (ELit (LInt 2))))
    , "Parser Prec 04" ~: parseExpr "let f = fun x -> x+1 in f 1"
                           ~?= (ELet "f"
                                (ELam "x" (EOp Add (EVar "x") (ELit (LInt 1))))
                                (EApp (EVar "f") (ELit (LInt 1))))
    , "Parser Prec 05" ~: parseExpr "(x)"
                           ~?= (EVar "x")
    , "Parser Prec 06" ~: parseExpr "f (1 + 2)"
                           ~?= (EApp (EVar "f")
                                (EOp Add (ELit (LInt 1)) (ELit (LInt 2))))
           ]

parserTests = expressions ++ precedence
