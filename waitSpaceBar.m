function waitSpaceBar()
  while 1
    [~, c, ~] = KbStrokeWait;
    c = find(c);
    
    if ~isempty(c) && 32 == c(1)
      break;
    end
  end
end