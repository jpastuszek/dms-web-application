describe EventSource do
	subject do
		EventSource.new
	end

	it 'should generate 2049 byte padding by default' do
		lines = []
		subject.each do |line|
			lines << line
		end

		lines.shift.should match(/^:.{2049}$/)
		lines.should be_empty
	end

	it 'should generate messages' do
		lines = []
		subject.each do |line|
			lines << line
		end

		subject.message('test1', 'message body 1') 
		subject.message('test2', 'message body 2') 
		subject.message('test3', <<EOF) 
multi
line
message
body
EOF

		lines.shift # padding

		lines.shift.should == "test1:message body 1\n"
		lines.shift.should == "\n"
		lines.shift.should == "test2:message body 2\n"
		lines.shift.should == "\n"
		lines.shift.should == "test3:multi\n"
		lines.shift.should == "test3:line\n"
		lines.shift.should == "test3:message\n"
		lines.shift.should == "test3:body\n"
		lines.shift.should == "\n"
		lines.should be_empty
	end

	it 'should generate comments' do
		lines = []
		subject.each do |line|
			lines << line
		end

		lines.shift # padding

		subject.message('test1', 'message body 1') 
		subject.comment('this is comment')
		subject.message('test2', 'message body 2') 

		lines.shift.should == "test1:message body 1\n"
		lines.shift.should == "\n"
		lines.shift.should == ":this is comment\n"
		lines.shift.should == "test2:message body 2\n"
		lines.shift.should == "\n"
	end
end	

