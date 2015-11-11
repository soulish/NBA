module MethodMissing
  def method_missing(meth, *args, &block)
    ##You can get fgm using: season.fg.m, season.stats("fg.m"), or season.stats("fg","m")
    if meth.to_s =~ /stats/
      if args.length == 1
        return self.instance_variable_get(:"@#{args[0]}") unless args[0].include?(".")
        return self.instance_variable_get(:"@#{args[0].split(".")[0]}").stats(args[0].split(".")[1]) if args[0].include?(".")
      elsif args.length == 2
        return self.instance_variable_get(:"@#{args[0]}").stats(args[1])  
      end
    elsif meth.to_s =~ /^(.+)$/
      meths = meth.to_s
      return self.instance_variable_get(:"@#{meth}") unless meths.include?(".")
      return self.instance_variable_get(:"@#{meths.split(".")[0]}").stats(meths.split(".")[1]) if meths.include?(".")
    else
      super
    end
  end  
end
