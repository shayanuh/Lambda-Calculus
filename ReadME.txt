-----------------------
Name : Shayan Ul Haq
Roll Number : 180706
Group : 26 
CS 350 Project
-----------------------


-----------------------------------
Note:
1) The resultant expression returned after substitute() and/or reduce()
might be subjected to alpha-renaming 
2) beta-reduction will only work when the given expression can be reduced
For eg. it will not work for expression
"[(\x.[x][x])][(\x.[x][x])]"
3) reduce() and substitute() returns LambdaTerm instance , to get the expression use instance method get_expression() of LambdaTerm.
4) The result of substitute() mmigt not in reduced form to convert it into reduced form(if it exists) use reduce().
eg sample_lambda_term.substitute(variable,sample_lambda_term_2).reduce
5) The expression provided must follow the convention provided in the Question
i.e 
expression of type 1 : variable  eg "x"
expression of type 2 : (\variable · λ − term)  eg "(\\x.[y][y])"   (note that '\' need to be specified  as '\\' )
expression of type 3 : [λ − term][λ − term]    eg "[z][(\z.y)]"
----------------------------------------------
Following is the sample usage:
-----------------------------------------------
# define lambda term , expression is a string and can be something like "(\\x.[y][y])"
lambda_term = LambdaTerm.new(expression)

# checking if the given lambda term is valid or not
lambda_term.is_valid?

# listing free variables, returns a list of chars denoting free variables in lambda_term
lambda_term.free_variables


# substitute free occurenences of variable (char) with lambda_term_2 (instance of LambdaTerm) in lambda_term
new_lambda_term = lambda_term.substitute(variable,lambda_term_2)


# perform beta reduction
new_lambda_term = lambda_term.reduce
-----------------------------------------------------------


-----------------------------------------------------------
Examples:-

------------------------------------------------------------
Example 1 (type 1)
------------------------------------------------------------
m = LambdaTerm.new("x")
m.is_valid?
m.free_variables
m.substitute("x",LambdaTerm.new("(\\x.y)")).get_expression
m.reduce.get_expression
------------------------------------------------------------


------------------------------------------------------------
Example 2 (type 2)
------------------------------------------------------------
m = LambdaTerm.new("(\\x.[(\\x.[z][z])][(\\x.y)])")
m.is_valid?
m.free_variables
m.substitute("x",LambdaTerm.new("(\\y.x)")).get_expression
m.reduce.get_expression 
------------------------------------------------------------


------------------------------------------------------------
Example 3 (type 3)
------------------------------------------------------------
m = LambdaTerm.new("[(\\x.x)][(\\y.(\\p.[x][x]))]")
m.is_valid? 
m.free_variables
m.substitute("x",LambdaTerm.new("(\\z.[z][x])")).get_expression 
m.reduce.get_expression 
------------------------------------------------------------


------------------------------------------------------------
Example 4 (invalid type)
------------------------------------------------------------
LambdaTerm.new("Z").is_valid?
LambdaTerm.new("(x)").is_valid?
LambdaTerm.new("[x]").is_valid?
LambdaTerm.new("(\\x.(x))").is_valid?
LambdaTerm.new("(\\x.xx)").is_valid?
------------------------------------------------------------

Similarly the program can be tested using different combinations of expresssions
