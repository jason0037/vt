#encoding:utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Ecstore::Card.create({
		:no=>"12309878992",
		:value=>2000,
		:card_type=>"A",
		:sale_status=>"已出售",
		:use_status=>"未使用",
		:status=>"正常"
	})

Ecstore::Card.create({
		:no=>"12309875491",
		:value=>9000,
		:card_type=>"B",
		:sale_status=>"未出售",
		:use_status=>"未使用",
		:status=>"正常"
	})

Ecstore::Card.create({
		:no=>"1230312175491",
		:value=>3000,
		:card_type=>"B",
		:sale_status=>"已出售",
		:use_status=>"未使用",
		:status=>"正常"
	})