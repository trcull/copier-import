
class ApiResult < Hash
  def initialize(data=nil)
    super
    if data
      data.each do |key, value|
        self[key] = value
      end
    end
  end

  def methodify_key(key)
    if !self.respond_to? key
      self.class.send(:define_method, key) do
        return self[key]
      end
      self.class.send(:define_method, "#{key}=") do |val|
        self[key] = val
      end
    end  
  end
    
  def []=(key, value)
    hierarchy = key.to_s.split('__')
    insert_in = self
    if hierarchy.length > 1
      parents = hierarchy[0..(hierarchy.length-2)]
      leaf = hierarchy.last
      parents.each do |parent|
        captures = parent.scan(/_(\d+)$/)
        if captures.length > 0
          index = captures[0][0].to_i
          the_array = fetch(parent.sub(/_\d+$/,"_n").to_sym, [])
          this_parent = the_array[index]
        elsif parent.end_with? '_n' #TODO: or parent ends with a number
          this_parent = fetch(parent.to_sym, [])
        else
          this_parent = fetch(parent.to_sym, ApiResult.new)
        end
        if insert_in.class == Array
          insert_in << this_parent
        else
          insert_in.store(parent.to_sym, this_parent)
          insert_in.methodify_key parent.to_sym
          insert_in = this_parent
        end
      end
    else
      leaf = key
    end
    if value.class == Array
      to_store = []
      value.each do |sub_tree|
        to_store << ApiResult.new(sub_tree)
      end
    else
      to_store = value
    end
    target_key = leaf.to_sym
    if insert_in.class == Array
      has_been_inserted = false
      insert_in.each do |potential_insert|
        if potential_insert[target_key].nil?
          potential_insert[target_key] = to_store
          has_been_inserted = true
          break
        end
      end
      if !has_been_inserted
        insert_in << ApiResult.new({target_key=>to_store})        
      end
    else
      insert_in.store(target_key, to_store)
      insert_in.methodify_key target_key
    end
  end
  
  def [](key)
    #figure out if the key we're looking for is for a specific index in an array value.  for example, an_array_0
    captures = key.to_s.scan(/_(\d+)$/)
    if captures.length > 0
      index = captures[0][0].to_i
      #convert key to _n form just for fetching, for example, convert an_array_0 to an_array_n
      key = key.to_s.sub(/_\d+$/,'_n')
    else 
      index = nil
    end
    value = fetch(key, nil)
    #try a symbol instead of a string and vice versa
    if value.nil?
      #try the other form
      case key
      when Symbol
        value = fetch(key.to_s, nil)
      when String
        value = fetch(key.to_sym, nil)
      else
        value = nil
      end
    end
    #if still null, try to detect compound tags and walk up the hierarchy
    # for example, if we got level_one__level_two then we want to first look for self[:level_one] and then look for self[:level_two] in the result
    if value.nil?
      hierarchy = key.to_s.split('__') #note, this is a double underscore
      if hierarchy.length > 1
        sub_tree_key = hierarchy[1..(hierarchy.length-1)].join('__')
        parent = self[hierarchy.first]
        if parent.present?
          if parent.class == Array
            captures = hierarchy.first.scan(/_(\d+)$/)
            #if we got a key something like level_one_2__level_two then return parent[2][:level_two]
            if captures.length > 0
              index = captures[0][0].to_i
              value = parent[index][sub_tree_key]
            #if we got a key something like level_one_n__level_two then return an array of all the level_twos under level_one
            else 
              value = []
              parent.each do |sub_tree|
                value << sub_tree[sub_tree_key]
              end
            end
          else
            value = parent[sub_tree_key]
          end
        end
      end
    end
    if value.class == Hash
      rv = ApiResult.new value
    elsif value.class == Array
      if index.present?
        rv = value[index]
      else 
        rv = value
      end
    else
      rv = value
    end
    rv
  end
end
