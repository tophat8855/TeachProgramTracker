# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

locations = Location.create([{name: 'San Francisco'}, {name: 'Contra Costa'}])

User.create({email: 'test@gmail.com', password: 'password', password_confirmation: 'password', name: 'Test1', admin: true, trainer: true, location_id: locations.first.id})
User.create({email: 'test2@gmail.com', password: 'password', password_confirmation: 'password', name: 'Test2' status: 'R2', location_id: locations.first.id})
