def init
  super
  sections.push :requirements
  @namespace = object

end

def features
  @features ||= Registry.all(:feature)
end

def tags
  @tags ||= Registry.all(:tag).sort_by {|l| l.value.to_s }
end

def feature_directories
  @feature_directories ||= YARD::CodeObjects::Cucumber::CUCUMBER_NAMESPACE.children.find_all {|child| child.is_a?(YARD::CodeObjects::Cucumber::FeatureDirectory)}
end

def feature_subdirectories
  @feature_subdirectories ||= Registry.all(:featuredirectory) - feature_directories
end

def alpha_table(objects)
  @elements = Hash.new

  objects = run_verifier(objects)
  objects.each {|o| (@elements[o.value.to_s[0,1].upcase] ||= []) << o }
  @elements.values.each {|v| v.sort! {|a,b| b.value.to_s <=> a.value.to_s } }
  @elements = @elements.sort_by {|l,o| l.to_s }

  @elements.each {|letter,objects| objects.sort! {|a,b| b.value.to_s <=> a.value.to_s }}
  erb(:alpha_table)
end

def keyword_table(objects)
	@elements = Hash.new
	
	objects = run_verifier(objects)
	#objects.each {|o| (@elements[o.file.split('/')[0].upcase] ||= []) << o }
	objects.each {|o| 
	    file = o.file.split('/');
		if file[1].end_with? ".feature"
			if @elements[file[0].upcase].kind_of?(Hash) then
				@elements[file[0].upcase]['DEFAULT'] = Array.new if @elements[file[0].upcase]['DEFAULT'].nil?
				(@elements[file[0].upcase]['DEFAULT'] ||= []) << o
			else
				(@elements[file[0].upcase] ||= []) << o
			end	
		else
			if @elements[file[0].upcase].kind_of?(Array) then
				temp_array =  @elements[file[0].upcase]
			    @elements[file[0].upcase] = Hash.new
				@elements[file[0].upcase]['DEFAULT'] = Array.new if @elements[file[0].upcase]['DEFAULT'].nil?
				@elements[file[0].to_s.upcase]['DEFAULT'] .push(o)
			else
				@elements[file[0].upcase] = Hash.new if @elements[file[0].upcase].nil?
				@elements[file[0].upcase][file[1].upcase] = Array.new if @elements[file[0].upcase][file[1].upcase].nil?
				@elements[file[0].to_s.upcase][file[1].upcase.to_s] .push(o)
			end
			
		end	
	}
	#@elements.values.each {|v| v.sort! {|a,b| b.value.to_s <=> a.value.to_s } }
	
	@elements = @elements.sort_by {|l,o| l.to_s }

    #@elements.each {|letter,objects| objects.sort! {|a,b| b.value.to_s <=> a.value.to_s }}
    erb(:keyword_table)
end
