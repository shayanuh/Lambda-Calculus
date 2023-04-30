# ---------------------------------------------------
# Name : Shayan Ul Haq
# Roll Number : 180706
# Group : 26 
# ---------------------------------------------------


class LambdaTerm
    @@allowewd_chars = ('a'..'z').to_set | ["(",")","[","]","\\","."].to_set
    @@allowed_variables = ('a'..'z').to_set
    def initialize(expression)
        # remove whitespaces for easier parsing
        @expression = expression.delete(' ')
        grammar_check = LambdaTerm.grammar_check(@expression)
        @is_valid_term = grammar_check.first
        @type = grammar_check[1]
        @bound_variable = nil
        @lambda_term_1 = nil
        @lambda_term_2 = nil
        @bound_lambda_term = nil
        @free_variables = []
        if @type == 1
            @free_variables = [@expression[0]] 
        end
        if @type == 2
            @bound_variable = grammar_check[2]
            @bound_lambda_term = grammar_check[3]
            @free_variables = @bound_lambda_term.free_variables.to_set.difference([@bound_variable].to_set).to_a
        end
        if @type == 3
            @lambda_term_1 = grammar_check[2]
            @lambda_term_2 = grammar_check[3]
            @free_variables = (@lambda_term_1.free_variables.to_set | @lambda_term_2.free_variables.to_set).to_a
        end
    end


    def LambdaTerm.grammar_check(expr)
        is_valid_expr = true
        
        expr.each_char do |char|
            is_valid_expr =  is_valid_expr & @@allowewd_chars.include?(char)
        end
        if is_valid_expr == false
            return [false,nil]
        end
        ## check case 1 : variable
        if expr.length == 1 && @@allowed_variables.include?(expr[0])
            return [true,1]
        end

        ## check case 2 : (\variable.\-term)
        if expr.length>=6 && expr[0..1] == '(\\' && @@allowed_variables.include?(expr[2]) && expr[3] == '.' && expr[-1] == ')'
            curr_lambda_term = LambdaTerm.new(expr[4..-2]) 
            is_valid_expr = curr_lambda_term.is_valid? 
            if is_valid_expr
                return [true,2,expr[2],curr_lambda_term]
            else
                return [false,nil]
            end
        end

        ## check case 3 : [\-term][\-term]
        if expr[0] == '[' && expr[-1] == ']'
            net_opened_bracket = 0
            num_lambda_terms = 0
            prev_open_bracket_start = -1
            lambda_terms = []
            expr.length.times do |i|
                char = expr[i]
                if char == '['
                    net_opened_bracket +=1
                    if net_opened_bracket == 1
                        prev_open_bracket_start = i
                    end
                elsif char == ']'
                    net_opened_bracket -= 1
                    if net_opened_bracket<0
                        return [false,nil]
                    elsif net_opened_bracket==0
                        curr_lambda_term = LambdaTerm.new(expr[(prev_open_bracket_start+1)..(i-1)]) 
                        lambda_terms.concat([curr_lambda_term])
                        is_valid_expr = curr_lambda_term.is_valid?
                        if is_valid_expr==false
                            return [false,nil]
                        end
                        num_lambda_terms += 1
                        if i!=expr.length-1 && expr[i+1]!='['
                            return [false,nil]
                        end
                    end 
                end   
            end
            if num_lambda_terms>2 || net_opened_bracket!=0
                return [false,nil]
            else
                return [true,3].concat(lambda_terms)
            end
        end
        return [false,nil]
    end
    def is_valid?
        return @is_valid_term
    end
    def get_lambda_term_1
        @lambda_term_1
    end
    def get_type
        @type
    end
    def get_lambda_term_2
        @lambda_term_2
    end
    def get_expression
        @expression
    end
    def get_bound_variable
        @bound_variable
    end
    def free_variables
        @free_variables
    end
    def get_bound_lambda_term
        @bound_lambda_term
    end
    def LambdaTerm.chose_new_bound_variable(restricted_variables)
        available_variables = ('a'..'z').to_a
        available_variables.each do |char|
            return char unless restricted_variables.include?(char) 
        end
    end
    def alpha_rename(new_bound_variable)
        new_expression = @expression.gsub(@bound_variable,new_bound_variable)
        return LambdaTerm.new(new_expression)
    end

    # Solution to third question: takes the input a variable  and a LambdaTerm instance and returns new instance of Lambdaterm 
    # by substituting all the freee occurecnes of variable in self with the provided LambdaTerm
    def substitute(variable,lambda_term)
        new_lambda_expression = ''
        if @type == 1
            if @free_variables.first == variable
                new_lambda_expression = lambda_term.get_expression
            else
                new_lambda_expression = @expression
            end
        elsif @type == 2
            if @bound_variable == variable
                new_lambda_expression = @expression
            elsif lambda_term.free_variables.include?(@bound_variable)
                restricted_variables = @free_variables.concat(lambda_term.free_variables).uniq
                new_bound_variable = LambdaTerm.chose_new_bound_variable(restricted_variables)
                renamed_lambda_term = alpha_rename(new_bound_variable)
                new_lambda_expression = renamed_lambda_term.get_expression[0..3] + renamed_lambda_term.get_bound_lambda_term.substitute(variable,lambda_term).get_expression + ')'
            else
                new_lambda_expression = @expression[0..3] + @bound_lambda_term.substitute(variable,lambda_term).get_expression + ')' 
            end
        elsif @type == 3
            new_lambda_expression = '[' + @lambda_term_1.substitute(variable,lambda_term).get_expression + '][' + @lambda_term_2.substitute(variable,lambda_term).get_expression + ']'
        else
            return nil
        end
        return LambdaTerm.new(new_lambda_expression)
    end


    # Solution to fourth question: returns new LambdaTerm instance
    # for type 1 : it will be unchanged
    # for type 2 : it will reduce the bounded term if it is possible
    # for type 3 : it will perform beta reduction
    def reduce
        new_lambda_expression = ''
        if @type == 1
            new_lambda_expression = @expression
        elsif @type == 2
            bound_lambda_term_reduced = @bound_lambda_term.reduce
            new_lambda_expression = @expression[0..3] + bound_lambda_term_reduced.get_expression + ')'
        elsif @type == 3
            reduced_lambda_term_1 =@lambda_term_1.reduce
            reduced_lambda_term_2 = @lambda_term_2.reduce

            if reduced_lambda_term_1.get_type == 2
                new_lambda_expression = reduced_lambda_term_1.get_bound_lambda_term.substitute(reduced_lambda_term_1.get_bound_variable, reduced_lambda_term_2).reduce.get_expression
            else
                new_lambda_expression = '[' + reduced_lambda_term_1.get_expression + '][' +reduced_lambda_term_2.get_expression + ']'
            end
        else
            return nil
        end
        return LambdaTerm.new(new_lambda_expression)
    end
end