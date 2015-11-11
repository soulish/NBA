class Rate
  include MethodMissing
  #attr_reader :stats
  
  @@rates = []

  def initialize(quantity, time,rate = nil)
    @q = quantity
    @t = time
    @rate = rate.nil? ? quantity/time.to_f : rate
    @var = @rate*(1-@rate)/time.to_f
    @std_dev = Math::sqrt(@rate*(1-@rate)/time.to_f)
    @sdom = Math::sqrt(@rate*(1-@rate)/(time.to_f)**2)
    @sdosd = 1/Math::sqrt(2*(time-1))
    @vofv = 1/(2*(time-1)).to_f
    @@rates.push self
  end
end

class Rates

  def initialize
    @rates = []
  end

  def add_rate(rate)
    @rates.push rate
  end

  def length; @rates.length; end
  def last; @rates.last; end

  def sum(var = "rate")
    sum = 0
    @rates.each{|pt| sum += pt.stats(var)}
    sum
  end

  def sum_inv_var
    sum = 0
    @rates.each{|pt| sum += 1/pt.stats("var") unless pt.stats("var") == 0}
    sum
  end

  def average(var = "rate")
    sum = self.sum(var)
    sum/@rates.length.to_f
  end

  def p_bar
    self.sum("q")/self.sum("t").to_f
  end

  def weighted_average
    sum_weights = 0
    @rates.each{|pt| sum_weights += 1/pt.stats("var").to_f}

    sum = 0
    @rates.each{|pt| sum += (1/pt.stats("var").to_f)*pt.stats("rate")/sum_weights}
    sum
  end

  def weighted_average_alt
    sum_weights = 0
    @rates.each{|pt| sum_weights += pt.stats("a")}

    #we use only attempts as our weight because we know for certain what the
    #rate was (we set it), 
    sum = 0
    @rates.each{|pt| sum += pt.stats("t")*pt.stats("rate")/sum_weights}
    sum
  end

  def std_dev
    p_bar = self.p_bar
    sum = 0
    @rates.each{|pt| sum += (pt.stats("rate")-p_bar)**2/(@rates.length.to_f-1)}
    Math::sqrt(sum)
  end

  def weighted_std_dev
    p_bar = self.p_bar

    sum_weights = 0
    @rates.each{|pt| sum_weights += 1/pt.stats("var")}

    sum = 0
    @rates.each{|pt| sum += (((1/pt.stats("var"))*(pt.stats("rate")-p_bar)**2)/sum_weights)}
    Math::sqrt(sum)
  end

  def sum_indiv_vars
    ##This is a weighted sum of the variances, weighted by the std dev of the std dev
    sum_weights = 0
    @rates.each{|pt| sum_weights += 1/pt.stats("vofv").to_f unless pt.stats("vofv") == 0}

    var_tot = 0
    @rates.each do |pt|
      var_tot += (1/pt.stats("vofv").to_f)*pt.stats("var") unless pt.stats("vofv") == 0
    end
    var_tot /= sum_weights
  end
end

