module SeedFu
  # @private
  class BlockHash
    def initialize(proc)
      @hash = {}
      proc.call(self)
    end

    def to_hash
      @hash
    end

    def method_missing(method_name, *args, &block)
      if method_name.to_s =~ /^(.*)=$/ && args.length == 1 && block.nil?
        @hash[$1] = args.first
      else
        super
      end
    end
  end
end
