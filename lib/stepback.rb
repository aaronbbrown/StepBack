class StepBack
  def self.execute ( &block )
    s = StepBack.new(&block)
    s.run
  end

  def initialize ( &block )
    @steps, @run_stack = [], []
    @before_each_block = nil
    @after_each_block  = nil
    @before_each_undo_block = nil
    @after_each_undo_block  = nil
  yield self
  end

  def before_each ( &block )
    @before_each_block = lambda(&block) 
  end

  def after_each ( &block )
    @after_each_block = lambda(&block) 
  end

  def before_each_undo ( &block )
    @before_each_undo_block = lambda(&block) 
  end

  def after_each_undo ( &block )
    @after_each_undo_block = lambda(&block) 
  end

  def step ( options = {}, &block )
    @steps << { :step => lambda(&block), :description => options[:description] }
  end

  def undo ( options = {}, &block )
    @steps.last[:undo_description] = options[:description]
    @steps.last[:undo] = lambda(&block)
  end

  def run
    result = true
    unless result = call_blocks  
      undo_all
    end
    result
  end


  def undo_all
    @run_stack.each_with_index do |x,i|
      x[:undo] or next
      puts "Undo #{@run_stack.size - i}: #{x[:undo_description]}" if x[:undo_description]
      if @before_each_undo_block
        @before_each_undo_block.call or return false
      end

      begin
        unless x[:undo].call 
          STDERR.puts "Undo #{@run_stack.size - i} failed."
          return false
        end
      rescue Exception => e
        STDERR.puts e
        return false
      end

      if @after_each_undo_block
        @after_each_undo_block.call or return false
      end
    end
    true
  end

protected
  def call_blocks
    @steps.each_with_index do |x,i|
      puts "Step #{i+1}: #{x[:description]}" if x[:description]
      if @before_each_block
        @before_each_block.call or return false
      end

      begin
        unless x[:step].call
          STDERR.puts "Step #{i+1} failed"
          return false
        end
      rescue Exception => e
        STDERR.puts e
        return false
      end
      @run_stack.unshift(x)

      if @after_each_block
        @after_each_block.call or return false
      end
    end
    true
  end
end

