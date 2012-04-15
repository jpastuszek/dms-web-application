class RackApp  
  def call(environment)    
  [
    '200', 
    {'Content-Type' => 'text/html'}, 
    ["Hello world"]
  ]
  end 
end

run RackApp.new do |s|
	puts 'hello world'
	p s
end

