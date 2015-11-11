class Pct
  include MethodMissing
  attr_reader :pct
  
  def initialize(makes, attempts,pct = nil)
    @m = makes
    attempts = attempts < 0 ? 0 : attempts
    @a = attempts
    @p = nil
    if p.nil?
      ##since I am using this generically, thing like ftr, and tsp
      ##can have a greater numerator than denominator for low numbers 
      ##of attempts.  These shouldn't come up often, and will be treated
      ##as if their pct is 0.99 for simplicity
      if attempts == 0
        @p = 0
      elsif makes >= attempts
        @p = 0.99
      else
        @p = makes/attempts.to_f
      end
    else
      @p = pct
    end
    @pct = @p
    @var = attempts == 0 ? 0 : @p*(1-@p)/attempts.to_f
    #puts "#{makes}\t#{attempts}\t#{@p}"
    @std_dev = attempts == 0 ? 0 : Math::sqrt(@p*(1-@p)/attempts.to_f)
    @sdom = attempts == 0 ? 0 : Math::sqrt(@p*(1-@p)/(attempts.to_f)**2)
    @sdosd = attempts <= 1 ? 0 : 1/Math::sqrt(2*(attempts-1))
    @vofv = attempts <= 1 ? 0 : 1/(2*(attempts-1)).to_f
  end
end

class Pcts

  def initialize
    @pcts = []
  end

  def add_pct(pct)
    @pcts.push pct
  end

  def length; @pcts.length; end
  def last; @pcts.last; end

  def sum(var = "p")
    sum = 0
    @pcts.each{|pt| sum += pt.stats(var)}
    sum
  end

  def sum_inv_var
    sum = 0
    @pcts.each{|pt| sum += 1/pt.stats("var") unless pt.stats("var") == 0}
    sum
  end

  def sum_inv_var_asymmetric(mean)
    sum_low = 0;sum_high = 0
    @pcts.each do |pt| 
      fake_p = mean + (mean - pt.stats("p"))
      fake_p = 0.99 if fake_p >= 0.99
      fake_var = fake_p*(1-fake_p)/pt.stats("a")
      if pt.stats("p") >= mean
        sum_high += 1/pt.stats("var")
        sum_high += 1/fake_var
      else
        sum_low += 1/pt.stats("var")
        sum_low += 1/fake_var
      end        
    end
    [sum_low,sum_high]
  end

  def average(var = "p")
    sum = self.sum(var)
    sum/@pcts.length.to_f
  end

  def p_bar
    self.sum("m")/self.sum("a").to_f
  end

  def weighted_average
    sum_weights = 0
    @pcts.each{|pt| sum_weights += 1/pt.stats("var").to_f}

    sum = 0
    @pcts.each{|pt| sum += (1/pt.stats("var").to_f)*pt.stats("p")/sum_weights}
    sum
  end

  def weighted_average_alt
    sum_weights = 0
    @pcts.each{|pt| sum_weights += pt.stats("a")}

    #we use only attempts as our weight because we know for certain what the
    #pct was (we set it), 
    sum = 0
    @pcts.each{|pt| sum += pt.stats("a")*pt.stats("p")/sum_weights}
    sum
  end

  def std_dev
    p_bar = self.p_bar
    sum = 0
    @pcts.each{|pt| sum += (pt.stats("p")-p_bar)**2/(@pcts.length.to_f-1)}
    Math::sqrt(sum)
  end

  def weighted_std_dev(verbose = false)
    p_bar = self.p_bar

    sum_weights = 0
    @pcts.each{|pt| sum_weights += 1/pt.stats("var") if pt.stats("var") != 0}

    sum = 0
    @pcts.each{|pt| sum += (((1/pt.stats("var"))*(pt.stats("p")-p_bar)**2)/sum_weights) if pt.stats("var") != 0}

    if verbose
      @pcts.each do |pt| 
        puts (1/pt.stats("var"))
        puts "#{pt.stats("p")}\t#{p_bar}\t\t\t#{(pt.stats("p")-p_bar)**2}"
        puts (((1/pt.stats("var"))*(pt.stats("p")-p_bar)**2))
        puts (((1/pt.stats("var"))*(pt.stats("p")-p_bar)**2)/sum_weights)
        puts
      end
    end

    if Math::sqrt(sum).nan?
      puts "Error:::"
      @pcts.each{|pt| puts "#{pt.stats("m")}\t#{pt.stats("a")}\t#{pt.stats("var")}"}
      puts "Error:::"
    end

    Math::sqrt(sum)
  end

  def weighted_asymmetric_std_dev(mean)
    p_bar = self.p_bar

    sum_weights_low,sum_weights_high = *self.sum_inv_var_asymmetric(mean)
    # sum_weights_low,sum_weights_high = 0,0
    # @pcts.each do |pt| 
    #   fake_p = mean + (mean - pt.stats("p"))
    #   fake_p = 0.99 if fake_p >= 0.99
    #   fake_var = fake_p*(1-fake_p)/pt.stats("a")
    #   if pt.stats("p") >= mean
    #     sum_weights_high += 1/pt.stats("var")
    #     sum_weights_high += 1/fake_var
    #   else
    #     sum_weights_low += 1/pt.stats("var")
    #     sum_weights_low += 1/fake_var
    #   end        
    # end

    sum_low = 0;sum_high = 0
    @pcts.each do |pt| 
      fake_p = mean + (mean - pt.stats("p"))
      fake_p = 0.99 if fake_p >= 0.99
      fake_var = fake_p*(1-fake_p)/pt.stats("a")
      if pt.stats("p") >= mean
        sum_high += (((1/pt.stats("var"))*(pt.stats("p")-mean)**2)/sum_weights_high)
        sum_high += (((1/fake_var)*(fake_p-mean)**2)/sum_weights_high)
      else
        sum_low += (((1/pt.stats("var"))*(pt.stats("p")-mean)**2)/sum_weights_low)
        sum_low += (((1/fake_var)*(fake_p-mean)**2)/sum_weights_low)
      end
    end

    if Math::sqrt(sum_high).nan?
      puts "Error:::"
      @pcts.each{|pt| puts "#{pt.stats("m")}\t#{pt.stats("a")}\t#{pt.stats("var")}" if pt.stats("p") >= mean}
      puts "Error:::"
    end

    if Math::sqrt(sum_low).nan?
      puts "Error:::"
      @pcts.each{|pt| puts "#{pt.stats("m")}\t#{pt.stats("a")}\t#{pt.stats("var")}"if pt.stats("p") < mean}
      puts "Error:::"
    end

    [Math::sqrt(sum_low),Math::sqrt(sum_high)]
  end

  def std_dev_component(var)
    ary = []
    @pcts.each{|pt| ary.push pt.stats(var)}
    ary.std_dev
  end

  def sum_indiv_vars
    ##This is a weighted sum of the variances, weighted by the std dev of the std dev
    sum_weights = 0
    @pcts.each{|pt| sum_weights += 1/pt.stats("vofv").to_f unless pt.stats("vofv") == 0}
    if sum_weights == 0
      puts "ERROR:::::::::::::::::"
      @pcts.each{|pt| puts pt.stats("vofv")}
      puts "ERROR:::::::::::::::::"
    end

    var_tot = 0
    @pcts.each do |pt|
      var_tot += (1/pt.stats("vofv").to_f)*pt.stats("var") unless pt.stats("vofv") == 0
    end
    var_tot /= sum_weights
  end

  def sum_indiv_vars_asymmetric(mean)
    ##This is a weighted sum of the variances, weighted by the std dev of the std dev
    sum_weights_low = 0;sum_weights_high = 0
    @pcts.each do |pt| 
      sum_weights_high += 1/pt.stats("vofv").to_f if pt.stats("p") >= mean
      sum_weights_low += 1/pt.stats("vofv").to_f if pt.stats("p") < mean
    end
    if sum_weights_low == 0
      puts "ERROR sum_indiv_var_asymmetric low:::::::::::::::::#{mean}"
      @pcts.each{|pt| puts pt.stats("vofv") if pt.stats("p") < mean}
      puts "ERROR sum_indiv_var_asymmetric low:::::::::::::::::#{mean}"
    end

    if sum_weights_high == 0
      puts "ERROR sum_indiv_var_asymmetric high:::::::::::::::::#{mean}"
      @pcts.each{|pt| puts pt.stats("vofv") if pt.stats("p") >= mean}
      puts "ERROR sum_indiv_var_asymmetric high:::::::::::::::::#{mean}"
    end

    var_tot_low = 0;var_tot_high = 0
    @pcts.each do |pt|
      var_tot_high += (1/pt.stats("vofv").to_f)*pt.stats("var") if pt.stats("p") >= mean
      var_tot_low += (1/pt.stats("vofv").to_f)*pt.stats("var") if pt.stats("p") < mean
    end
    [var_tot_low/sum_weights_low,var_tot_high/sum_weights_high]
  end
end







#This proved to be not necessary
=begin
class Efgp

  attr_reader :stats
  
  @@pcts = []

  def initialize(fgm, fga, threem, threea)
    @stats = {}
    @stats["fgm"] = fgm
    @stats["fga"] = fga
    fgp = fgm/fga.to_f
    @stats["threem"] = threem
    @stats["threea"] = threea
    threep = threem/threea.to_f
    @stats["m"] = fgm + 0.5*threem
    @stats["a"] = fga
    @stats["p"] = (fgm+0.5*threem)/fga.to_f
    @stats["var"] = (fga*fgp*(1-fgp) + 0.5**2*threea*threep*(1-threep))/fga**2
    @stats["std_dev"] = Math::sqrt(@stats["var"])
    @stats["sdom"] = @stats["std_dev"]/fga.to_f
    @stats["sdosd"] = 1/Math::sqrt(2*(fga-1))
    @stats["vofv"] = 1/(2*(fga-1)).to_f
    @@pcts.push self
  end
end

=end
