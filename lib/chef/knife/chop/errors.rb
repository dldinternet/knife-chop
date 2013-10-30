module ChopErrors
  class ChopError < StandardError ; end
  class ChopOptionError < ChopError ; end
  class ChopInternalError < ChopError ; end
end