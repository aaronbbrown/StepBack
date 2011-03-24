#!/usr/bin/env ruby
require 'stepback'
y = 1

steps = StepBack.new do |s|
#StepBack.execute do |s|
  s.before_each do
    puts "Before!"
    true
  end
  
  s.after_each do
    puts "After!"
    true
  end

  s.before_each_undo do
    puts "Before Undo!"
    true
  end
  
  s.after_each_undo do
    puts "After Undo!"
    true
  end

  s.step :description => "Step A" do
    true
  end

  s.undo :description => "Undo A" do
    true
  end


  s.step :description => "Step B" do
    true
  end

#  s.undo :description => "Undo B" do
#    true
#  end

  s.step :description => "Step C" do
    true
  end

  s.undo :description => "Undo C" do
    true
  end

  s.step :description => "Step D" do
    false
  end

  s.step :description => "Shouldn't Get here (Step E)" do
    false
  end


end

steps.run
