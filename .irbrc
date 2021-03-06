IRB.conf[:PROMPT][:IRB_PROMPT] = { # name of prompt mode
  :AUTO_INDENT => true            # enables auto-indent mode
  :PROMPT_I => nil,               # normal prompt
  :PROMPT_S => nil,               # prompt for continuated strings
  :PROMPT_C => nil,               # prompt for continuated statement
  :RETURN => "    ==>%s\n"        # format to return value
}

IRB.conf[:PROMPT_MODE] = :IRB_PROMPT