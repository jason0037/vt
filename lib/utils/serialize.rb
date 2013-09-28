
[NilClass,String,Symbol,Fixnum,Bignum,Hash,Array].each do |klass|
	klass.class_eval do
		include Utils::Serializable
	end
end