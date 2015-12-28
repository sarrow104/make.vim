# 下面两行表示的是选区标记；必须放在函数模式的前面。
# 使用者可以修改——不过尽量不要使用makefile文件中可能出现到的符号。
# 注意，包括shell中可能用到的符号命令！
Region_Start = ~<
Region_End = >~
# 下面的各行表示的是GUN-make所支持的built-in函数；后面的注释将在补全中出现，以便使用
# 如果你有常用的自定义函数，也可以加在函数列表文件里面。如：
# 
# $(call mkdir-if-not-exist ~<dir-name>~)
# 
# 不过，补全的时候，就不能
# $(call m<C-X><C-O>了，而只能在第一个空格之前按<C-X><C-O>
$(~<variable>~:~<search>~=~<replace>~)	# replace search with replace in variable
$(addprefix ~<prefix>~,~<names...>~)
$(addsuffix ~<suffix>~,~<names...>~)
$(basename ~<names...>~) # rt. the filename without its suffix
$(call ~<macro-name[,param_1,..]>~)
$(dir ~<list...>~) # rt. the directory portion of each word in list
$(error ~<msg>~) # print error message, then quit
$(eval ~<makefile-comands>~) # eval makefile-commands
$(filter ~<pattern...>~,~<text>~)
$(filter-out ~<pattern...>~,~<text>~)
$(findstring ~<string>~,~<text>~)	# find string in text, '' for none
$(firstword ~<text>~)	# equal to $(word 1,text)
$(foreach ~<var>~,~<list>~,~<body>~) # join item in list
$(if ~<condition>~,~<then-part[,else-part]>~) # if condition is not ''...
$(join ~<prefix-list>~,~<suffix-list>~) # cat. nth item in 1st-list with nth in 2cd-list
$(notdir ~<names...>~)  # rt. the filename portion of a file path
$(origin ~<vairable>~) # rt. the variable type describing in a word
$(patsubst ~<search-pattern>~,~<replacew-pattern>~,~<text>~)
$(shell ~<command>~)	# execute shell command
$(sort ~<list>~)	# sorts list and removes duplicates
$(strip ~<text>~)	# strip leading and trailing spaces
$(subst ~<search-string>~,~<replace-string>~,~<text>~)
$(suffix ~<names...>~) # rt. the suffix of each word in name...
$(warning ~<msg>~) # print warning message, no quit
$(wildcard ~<pattern...>~) # e.g. $(wildcard *.c *.h)
$(word ~<n>~,~<text>~)	# the nth word in text
$(wordlist ~<s>~,~<e>~,~<text>~) # subsequence [s, e] in text
$(words ~<text>~)	# the number of words in text
