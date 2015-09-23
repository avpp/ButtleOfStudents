class TaskType < ActiveRecord::Base
  store :options, accessors: [:name, :text, :config], coder: JSON
  
  def get_var_val(vars, name)
    return vars[name] if vars[name].is_a? Fixnum
    s = vars[name]
    s1 = s.split(",")
    ans = []
    sub = []
    s1.each do |s1_i|
      s1_i = s1_i.strip
      s2 = s1_i.split("..")
      start = nil
      if not s2[0][/\d*/].empty?
        start = s2[0].to_i
      else
        if s2[0][0] == "*"
          d_c = 0
          if not s2[0][1..-1][/\d*/].empty?
            d_c = s2[0][1..-1].to_i
          else
            d_c = vars[s2[0][1..-1]] = get_var_val(vars, (s2[0][1..-1]))
          end
          start = rand(1..9).to_s
          (d_c-1).times{start+=rand(0..9).to_s}
          start = start.to_i
        elsif s2[0][0] == "-"
          if not s2[0][1..-1][/\d*/].empty?
            sub << s2[0][1..-1].to_i
          else
            vars[s2[0][1..-1]] = get_var_val(vars, (s2[0][1..-1]))
            sub << -vars[s2[0][1..-1]]
          end
          next
        else
          start = vars[s2[0]] = get_var_val(vars, (s2[0]))
        end
      end
      if s2.size == 1
        ans << start
        next
      end
      stop = nil
      if not s2[1][/\d*/].empty?
        stop = s2[1].to_i
      else
        if s2[1][0] == "*"
          d_c = 0
          if not s2[1][1..-1][/\d*/].empty?
            d_c = s2[1][1..-1].to_i
          else
            d_c = vars[s2[1][1..-1]] = get_var_val(vars, (s2[1][1..-1]))
          end
          stop = rand(1..9).to_s
          (d_c-1).times{stop+=rand(0..9).to_s}
          stop = stop.to_i
        else
          stop = vars[s2[1]] = get_var_val(vars, (s2[1]))
        end
      end
      ans << ((start>stop)?(stop..start):(start..stop))
    end
    sub.each do |s|
      seps = []
      ans.each_with_index do |a, i|
        if a.is_a? Range
          seps << i if (-s).in? a
        else
          seps << i if (-s) == a
        end
      end
      seps.sort.reverse.each do |sep|
        if ans[sep].is_a? Range
          if -s+1 <= ans[sep].max
            ans<<(-s+1..ans[sep].max)
          end
          if -s-1 >= ans[sep].min
            ans[sep] = ans[sep].min..(-s-1)
          end
        else
          ans.delete_at(sep)
        end
      end
    end
    sum = 0
    ans.each do |a|
      sum += 1
      if a.is_a? Range
        sum += a.max - a.min
      end
    end
    r = rand(sum)
    i = 0
    while r >= 0 do
      if ans[i].is_a? Range
        if ans[i].max - ans[i].min < r
          r -= (ans[i].max - ans[i].min)
        else
          return ans[i].min + r
        end
      else
        return ans[i] if r == 0
        r-=1
      end
      i = (i+1) % ans.size
    end
    return 0
  end


  def convert_with_vars(n, o, vars)
    n = (n[/\d*/].empty?) ? vars[n] : n.to_i
    o = (o[/\d*/].empty?) ? vars[o] : o.to_i
    return n.to_s(o)
  end

  def fill_pattern(vars)
    t = JSON.parse([self.text].to_json)[0]
    t.gsub!(/%(#\w+?#)?(\w)/) {|m| convert_with_vars($2, (($1.nil?) ? "10":$1[1..-2]), vars) }
    t.gsub!(/%!(\w)/, "<input type=\"text\" name=\"answer[\\1]\"/>")
    return t
  end


  def generate_task_for(ut, battle, l)
    new_t = Task.new
    new_t.task_type = self
    new_t.battle = battle
    vars = JSON.parse(self.config["vars"].to_json)
    vars.merge! self.config["levels"][l]["vars"]
    vars.each do |k, v|
       vars[k] = get_var_val(vars, k)
    end
    new_t.vars = vars
    new_t.level = l
    new_t.html = self.fill_pattern(vars)
    return new_t if battle.nil?
    new_t.save
    ut.tasks<<new_t if not ut.nil?
  end
end
