# a standard job 
class Fb::AbstractJob
  def to_map_by(key, an_array)
    rv = {}
    an_array.each do |elem|
    rv[elem[key]] = elem
    end
    return rv
  end
    
  def info(msg)
    Rails.logger.info msg
  end
end
