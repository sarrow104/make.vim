" Vim filetype plugin file
"
"   Language:  MakeFile
"     Plugin:  make.vim
" Maintainer:  Sarrow
"       Date:  2008十一月13
" LastModify:  2008十一月25
"    Version:  0.11
"
" This will enable some completion utility for mingw.Makefile
"
" using Vim's dictionary feature |i_CTRL-X_CTRL-K|.
" 	      Omin-complete utility |i_CTRL-X_CTRL-O|.
" -----------------------------------------------------------------
"
" Only do this when not done yet for this buffer
"
if exists("b:did_make_ftplugin")
  finish
endif
let b:did_make_ftplugin = 1

" ---------- Usr Setting Variable List --------------------------------- " {{{ 1
let maplocalleader = ";"

" ---------- User-Key mappings List ------------------------------------ " {{{1

"if !exists("g:completekey") {{{2
"    "Sarrow:change the default key setting
"    let g:completekey = "<c-j>"   "hotkey
"endif

"execute "inoremap <buffer> <silent>	".g:completekey."	<C-r>=call <SID>Insert_keyword_mapping_and_jump_regin()<CR>"
"}}}2

inoremap <buffer> <silent>	<C-j>			<C-r>=<SID>Insert_keyword_mapping_and_jump_regin()<CR>

nnoremap <buffer> <silent>	<LocalLeader>ma		:call <SID>Call_Make("all")<CR>
nnoremap <buffer> <silent>	<LocalLeader>mr		:call <SID>Call_Make("release")<CR>
nnoremap <buffer> <silent>	<LocalLeader>md		:call <SID>Call_Make("debug")<CR>
nnoremap <buffer> <silent>	<LocalLeader>mc		:call <SID>Call_Make("clean")<CR>
nnoremap <buffer> <silent>	<LocalLeader>mp		:call <SID>Call_Make("depends")<CR>
nnoremap <buffer> <silent>	<LocalLeader>mg		:call <SID>Set_Make_Argument()<CR>

" ---------- Makefile User Specified 3rd Party Library dictionary List ------ " {{{1
" Variable Name: g:Mingw_usr_lib_file
" 	   Type: type("")
if !exists("g:Mingw_usr_lib_file")
    let g:Mingw_usr_lib_file = globpath(&runtimepath, 'ftplugin/make_res/mingw.lib.lst')
endif

let b:Makefile_argument = ''

function! <SID>Call_Make(ag)
    " update : write source file if necessary
    exe	":update"
    " run make

    " Sarrow: below 2 line are modified, at date 2008/10/8
    " original is: >
    " 	exe	":!make ".s:C_MakeCmdLineArgs
    " <
    silent exe	"make -f % ". a:ag . b:Makefile_argument
    exe	":botright cwindow"
endfunction

function! <SID>Set_Make_Argument()
    let b:Makefile_argument = input("Plz. input your makefile arguments: ")
endfunction

" ---------- User-Template mappings List ------------------------------- " {{{1
"
" 检查当前buffer中有文字没有；如果是空的，就从外部文件中读入模板，然后写入；反
" 之，则询问用户，让用户在‘放弃原文’、‘缀到尾部’、‘放弃’三个选项中选择一
" 个。
if !exists("g:Mingw_make_template")
    function! Load_mingw_make_template_entry()
	" 模板以及对应的快捷键都是用户自定义的。
	" 快捷键取文件名中部的至多前4个字符。
	" 要添加新的模板文件，直接新建make.*.template样式的文件即可；要修改快
	" 捷键，修改对应的文件名即可。
	let entry_list = split(globpath(&runtimepath, 'ftplugin/make_res/make.*.mak'), "\n")
	let ret_val = {}
	for entry in entry_list
	    " VIM:
	    " 	:h filename-modifiers
	    let entry_fname = matchstr(fnamemodify(entry,':t'), '^make\.\zs[^.]\+')
	    let entry_pat = entry_fname[0:3]
	    " 仅middle name的前4个字符作为快捷键
	    "let entry_pat = entry_fname[0:3]
	    let ret_val[entry_pat] = {'path': entry}
	    execute 'nnoremap <buffer> <silent> <LocalLeader>'.entry_pat.' :call Load_make_template("'.escape(entry,'\ ').'")<CR>'
	    " 绑定菜单
	    execute 'nmenu &Make.&Load\ Template.'.entry_fname.' :call Load_make_template("'.escape(entry,'\ ').'")<CR>'
	endfor
	return ret_val
    endfunction
    let g:Mingw_make_template = Load_mingw_make_template_entry()
endif

" :h Funcref function()
function! Load_make_template(template_path) " {{{2

    " State Value:
    " 1) Append at end
    " 2) Overwrite
    " 3) Cancel -- default
    let state = 3

    let save_ruler = &ruler
    let save_showcmd = &showcmd
    set noruler noshowcmd
    if line('$') == 1 && getline(1) == ''
	let state = 1
    else
	let state = confirm("Waring: Non-empty file!\nLoad template anyway?", "&Append\n&Overwrite\n&Cancel", 3, "W")
	if state == 3
	    return
	elseif state == 1
	    execute '$'
	elseif state == 2
	    " delete All to black-hole, then changes to "Append" state
	    execute "1,$delete _"
	    execute '$'
	    let state = 1
	endif
    endif
    let content = join(readfile(a:template_path), "\n")
    for key in keys(g:Mingw_Make_Template_Operator)
        let replace = g:Mingw_Make_Template_Operator[key]()
        let content = substitute(content, '\s*\$'.key.'\$', escape(replace, '\'), 'g')
    endfor
    setlocal paste
    normal $"=contentp
    "normal A=content
    setlocal nopaste
    let &ruler = save_ruler
    let &showcmd = save_showcmd
endfunction " }}}2

if !exists("g:Mingw_Make_Template_Operator") " {{{1
    let g:Mingw_Make_Template_Operator={}
    " 需要支持更多的替换关键字，可以仿造下面的格式，自行添加即可。
    function g:Mingw_Make_Template_Operator['C']() dict
	return s:List_Current_File(g:Make_Complete_extensions['C'])
    endfunction
    function g:Mingw_Make_Template_Operator['CPP']() dict
	return s:List_Current_File(g:Make_Complete_extensions['CPP'])
    endfunction
    function g:Mingw_Make_Template_Operator['RES']() dict
	return s:List_Current_File(g:Make_Complete_extensions['RES'])
    endfunction
    function g:Mingw_Make_Template_Operator['SRC']() dict
	return s:List_Current_File(g:Make_Complete_extensions['SRC'])
    endfunction
    function g:Mingw_Make_Template_Operator['H']() dict
	return s:List_Current_File(g:Make_Complete_extensions['H'])
    endfunction
    function g:Mingw_Make_Template_Operator['HPP']() dict
	return s:List_Current_File(g:Make_Complete_extensions['HPP'])
    endfunction
    function g:Mingw_Make_Template_Operator['HH']() dict
	return s:List_Current_File(g:Make_Complete_extensions['HH'])
    endfunction
    function g:Mingw_Make_Template_Operator['ALL']() dict
	return s:List_Current_File(g:Make_Complete_extensions['ALL'])
    endfunction
    function g:Mingw_Make_Template_Operator['DATE']() dict
	return strftime("%Y %b %d %X")
    endfunction
    function g:Mingw_Make_Template_Operator['DIRNAME']() dict
	return expand("%:p:h:t")
    endfunction
    function g:Mingw_Make_Template_Operator['FNAME_NO_EXT']() dict
	return expand("%:r")
    endfunction
    function g:Mingw_Make_Template_Operator['FNAME']() dict
	return expand("%")
    endfunction
    function g:Mingw_Make_Template_Operator['FNAME_EXT']() dict
	return expand("%:e")
    endfunction
    function g:Mingw_Make_Template_Operator['CWP']() dict
	return expand("%:p:h")
    endfunction
endif

if !exists("g:Make_Complete_extensions") " {{{1
    let g:Make_Complete_extensions = {
		\'C': 	['c'],
		\'CPP': ['cpp', 'cxx', 'cc'],
		\'RES': ['rc'],
		\'H': 	['h'],
		\'HPP': ['hpp']}
    let g:Make_Complete_extensions['SRC'] =
		\g:Make_Complete_extensions['C'] +
		\g:Make_Complete_extensions['CPP'] +
		\g:Make_Complete_extensions['RES']
    let g:Make_Complete_extensions['HH'] = g:Make_Complete_extensions['H'] + g:Make_Complete_extensions['HPP']
    let g:Make_Complete_extensions['ALL'] = g:Make_Complete_extensions['SRC'] + g:Make_Complete_extensions['HH']
endif

function! <SID>Insert_keyword_mapping_and_jump_regin() " {{{1
    let aword = s:Get_last_word()
    if !has_key(g:Mingw_Make_Template_Operator, aword)
	return s:SwitchRegion()
    endif
    let complete = g:Mingw_Make_Template_Operator[aword]()
    let complete = substitute(complete, '\t', '', 'g')
    if complete != ""
	return "normal \<c-w>".complete
	" 在不离开插入模式的情况下，删除光标之前的一个单词：
	" execute "normal i\<c-w>\<c-o>l"
    else
	echohl WarningMsg
	echomsg 'No file extension with ' . string(g:Make_Complete_extensions[aword]) . ' found!'
	echomsg 'Plz. check your Current Work Directory!'
	echohl None
	return ''
    endif
endfunction

" Sarrow:2008十一月24
" this function comes from code_complete.vim
function! s:SwitchRegion()
    " if s:jumppos != -1
    "     call cursor(s:jumppos,0)
    "     let s:jumppos = -1
    " endif
    let rs = escape(g:Mingw_make_functions['R_S'], '~%^$\')
    let re = escape(g:Mingw_make_functions['R_E'], '~%^$\')
    if match(getline('.'),rs.'.*'.re)!=-1 || search(rs.'.\{-}'.re)!=0
        normal 0
        call search(rs,'c',line('.'))
        normal v
        call search(re,'e',line('.'))
        if &selection == "exclusive"
            exec "normal " . "\<right>"
        endif
        return "\<c-\>\<c-n>gvo\<c-g>"
    else
        "if s:doappend == 1
	"    if g:completekey == "<tab>"
        "        return "\<tab>"
        "    endif
        "endif
        return ''
    endif
endfunction

function! s:Get_last_word()
    return substitute(getline('.')[:(col('.')-1)], '\zs.*\W\ze\w*$', '', 'g')
endfunction

" 根据提供的后缀列表，把当前目录的文件列出来。并自动添加续行符以及escape掉空格
function! s:List_Current_File(ext) " {{{1
    let file_list = []
    if type(a:ext) == type("")
	" 注意，globpath()返回的是一个字符串！
	let file_list = split(globpath('.', '*.'.a:ext), "\n")
    elseif type(a:ext) == type([])
	for item in a:ext
	    call extend(file_list, split(globpath('.', '*.'.item), "\n"))
	endfor
    endif
    let file_list2 = []
    for item in file_list
	call extend(file_list2, [substitute(item, '^\.\', "\t", 'g')])
    endfor
    return join(file_list2, "\\\n")
endfunction

if !exists("g:Mingw_tool_para_dict") " {{{1
    let g:Mingw_tool_para_dict = {}
    "   g:Mingw_tool_para_dict['windres']=[...]{{{2
    let g:Mingw_tool_para_dict['windres']=[
                \{'word': '-i',  'menu': '--input=<file>'},
                \{'word': '-o',  'menu': '--output=<file>'},
                \{'word': '-J',  'menu': '--input-format=<format>'},
                \{'word': '-O',  'menu': '--output-format=<format>'},
                \{'word': '-F',  'menu': '--target=<target>'},
                \{'word': '-I',  'menu': '--include-dir=<dir>'},
                \{'word': '-D',  'menu': '--define <sym>[=<val>]'},
                \{'word': '-U',  'menu': '--undefine <sym>'},
                \{'word': '-v',  'menu': '--verbose'},
                \{'word': '-l',  'menu': '--language=<val>'},
                \{'word': '-r'},
                \{'word': '-h',  'menu': '--help'},
                \{'word': '-V',  'menu': '--version'}]

    "   g:Mingw_tool_para_dict['gcc']=[...] {{{2
    let g:Mingw_tool_para_dict['gcc']=[
                \'-m128bit-long-double',
                \'-m32',
                \'-m3dnow',
                \'-m64',
                \'-m80387',
                \'-m96bit-long-double',
                \'-maccumulate-outgoing-args',
                \'-malign-double',
                \'-malign-functions=',
                \'-malign-jumps=',
                \'-malign-loops=',
                \'-malign-stringops',
                \'-march=',
                \'-masm=',
                \'-mbranch-cost=',
                \'-mcmodel=',
                \'-mconsole',
                \'-mcygwin',
                \'-mdll',
                \'-mfancy-math-387',
                \'-mfp-ret-in-387',
                \'-mfpmath=',
                \'-mhard-float',
                \'-mieee-fp',
                \'-minline-all-stringops',
                \'-mmmx',
                \'-mms-bitfields',
                \'-mno-3dnow',
                \'-mno-80387',
                \'-mno-accumulate-outgoing-args',
                \'-mno-align-double',
                \'-mno-align-stringops',
                \'-mno-cygwin',
                \'-mno-fancy-math-387',
                \'-mno-fp-ret-in-387',
                \'-mno-ieee-fp',
                \'-mno-inline-all-stringops',
                \'-mno-mmx',
                \'-mno-ms-bitfields',
                \'-mno-push-args',
                \'-mno-red-zone',
                \'-mno-rtd',
                \'-mno-soft-float',
                \'-mno-sse',
                \'-mno-sse2',
                \'-mno-sse3',
                \'-mno-svr3-shlib',
                \'-mno-tls-direct-seg-refs',
                \'-mno-win32',
                \'-mnop-fun-dllimport',
                \'-momit-leaf-frame-pointer',
                \'-mpreferred-stack-boundary=',
                \'-mpush-args',
                \'-mred-zone',
                \'-mregparm=',
                \'-mrtd',
                \'-msoft-float',
                \'-msse',
                \'-msse2',
                \'-msse3',
                \'-mstack-arg-probe',
                \'-msvr3-shlib',
                \'-mthreads',
                \'-mtls-dialect=',
                \'-mtls-direct-seg-refs',
                \'-mtune=',
                \'-mwin32',
                \'-mwindows']
    " }}}2

    let g:Mingw_tool_para_dict["g++"] = g:Mingw_tool_para_dict['gcc']
    let g:Mingw_tool_para_dict['ar'] = ['rus']
endif

" NOTE:
" 这是补全路径用的，比如 -L 和 -I 
" 这个没必要从环境变量中生成；
" 因为，你既然使用了环境变量，那么编译器、连接器
" 都能读取到该信息！
if !exists("g:Mingw_usr_library_dirs") " {{{1
    let g:Mingw_usr_library_dirs = {}

    " Sarrow: 2008十一月24
    let g:Mingw_usr_library_dirs['inc'] = []
    let g:Mingw_usr_library_dirs['lib'] = []

    let library_entrys = readfile(globpath(&runtimepath, 'ftplugin/make_res/3rd_part_library_dir.lst'))

    let entry_type = ""
    for entry in library_entrys
	" 以#开头的是注释，忽略之
	if entry =~ '^\s*#'
	    continue
	endif
	let entry = matchstr(entry, '\zs\S.\{-0,}\ze\s*$')

	if entry =~ '^\%(lib:\|include:\)*\zs\(lib:\|include:\)\ze'
	    let entry_type = matchstr(entry, '^\%(lib:\|include:\)*\zs\(lib:\|include:\)\ze')[0:2]
	    let entry = matchstr(entry, '^\%(lib:\|include:\)*\zs.*$')
	endif
	if entry_type == "" || entry == ""
	    continue
	endif

	if entry =~ '^\$(\zs\S\+\ze)$' && expand('$'.matchstr(entry, '^\$(\zs\S\+\ze)$')) =~ ' '
	    let entry = '"'.entry.'"'
	endif
	if entry != ""
	    call add(g:Mingw_usr_library_dirs[entry_type], entry)
	endif

    endfor
    " End: 2008十一月24
endif

function! Load_mingw_make_functions() " {{{1
    let functions_path = globpath(&runtimepath, 'ftplugin/make_res/functions.mak')
    let file_content = readfile(functions_path)

    let line_idx = -1
    let R_S = ""
    let R_E = ""

    " Load Region-Begin and Region-End Mark {{{2
    while line_idx < len(file_content) - 1 && (R_S == "" || R_E == "")
	let line_idx += 1
	if file_content[line_idx] =~ '^\s*#'
	    continue
	endif
	if R_S == ""
	    let R_S = matchstr(file_content[line_idx], '^Region_Start\s*=\s*\zs\S\+\ze\s*$')
	endif
	if R_E == ""
	    let R_E = matchstr(file_content[line_idx], '^Region_End\s*=\s*\zs\S\+\ze\s*$')
	endif
    endwhile	"}}}2

    " load make.functions and its describe {{{2
    let funcs = []
    while line_idx < len(file_content) - 1
	let line_idx += 1
	if file_content[line_idx] =~ '^\s*#'
	    continue
	endif
	let func_entry = matchstr(file_content[line_idx], '^\$(.\{-1,})')
	if func_entry == ""
	    continue
	endif
	let fun_describ = matchstr(file_content[line_idx], '^\$(.\{-1,})\s*#\s*\zs.\+')
	if fun_describ != ""
	    call add(funcs, {'word': func_entry, 'menu': fun_describ})
	else
	    call add(funcs, {'word': func_entry})
	endif
    endwhile	"}}}2

    return {'R_S': R_S, 'R_E': R_E, 'funcs': funcs}
endfunction

if !exists("g:Mingw_make_functions") " {{{1
    let g:Mingw_make_functions = Load_mingw_make_functions()
endif

if !exists("g:Mingw_usr_libs") " {{{1
    " NOTE:
    " gcc
    " 在链接时候，库的查找路径分为两部分；一部分是由LIBRARY_PATH环境变量控制
    " 一部分是由ld工具控制——通过ld --verbose可以查询；
    " http://stackoverflow.com/questions/9922949/how-to-print-the-ldlinker-search-path
    " 环境变量LIBRARY_PATH的优先级更高——这样，便可以覆盖系统原本的库了。
    " 另外一种获取方式，是通过
    "   gcc -print-search-dirs
    " ；它会自动将LIBRARY_PATH的问题，也考虑进来
    "
    " 另外 LIBRARY_PATH 和 LD_LIBRARY_PATH
    " 的区别在于，前者管编译时，连接器如何找库；后者管运行时，加载器如何找库；
    " http://stackoverflow.com/questions/4250624/ld-library-path-vs-library-path
    " 另外，《影响gcc的环境变量列表》
    " https://gcc.gnu.org/onlinedocs/gcc/Environment-Variables.html
    if exists("$LIBRARY_PATH") && len(expand("$LIBRARY_PATH")) > 0
        let g:Mingw_usr_libs = []

        let libraries = ''
        for paths in split(system("gcc -print-search-dirs"), "\n")
            if match(paths, '^libraries: =') != -1
                let libraries = strpart(paths, 12)
                break
            endif
        endfor
        for path in split(libraries, ':')
            if len(path) && path[0] == '.'
                continue
            endif
            let current_list  = split(globpath(path, "lib*.a"), "\n")
            call map(current_list, 'fnamemodify(v:val, ":t")')
            call map(current_list, '"-l".strpart(v:val, 3, len(v:val) - 5)')
            call extend(g:Mingw_usr_libs, current_list)
        endfor
        "        let library_entrys = split(expand("$LIBRARY_PATH"), ':')
        "        let library_entrys2 = split(substitute(system("ld --verbose \| grep SEARCH_DIR \| tr -s ' ;' '\n'"), 'SEARCH_DIR("\%(=\)\?\|")', '', 'g'), "\n")
        "        call extend(library_entrys, library_entrys2)
        "        for entry in library_entrys
        "            if !isdirectory(entry)
        "                continue
        "            endif
        "            let current_list  = split(globpath(entry, "lib*.a"), "\n")
        "            call map(current_list, 'fnamemodify(v:val, ":t")')
        "            call map(current_list, '"-l".strpart(v:val, 3, len(v:val) - 5)')
        "            call extend(g:Mingw_usr_libs, current_list)
        "        endfor
    else
        let g:Mingw_usr_libs = readfile(g:Mingw_usr_lib_file)
    endif
    call sort(g:Mingw_usr_libs)
endif

" 补全参数
function! Make_Omni_Complete(findstart, base) " {{{1
    " vim系统会分两次调用本函数。
    " 第一次调用的时候，a:findstart为1；第二次为0；
    " 当第一次调用的返回值表示补全开始的列位置。如果为-1，则表示当此补全没有匹
    " 配项目，对本函数的第二次调用将被vim取消。
    "
    " NOTE: 注意，vim中，假设某一行内容为“^|”，其中“^”表示行首，“|”表
    " 示光标位置，那么col('.')的值是1！即col('.')-1才表示的是光标之前串的长度
    " （注意，对于vim来说，称为字节数更为准确）。
    " 而通过getline('.')获取到的行内容的时候，下标则是从0开始的。

    if a:findstart
	" 应该从光标位置之前一个位置开始查找
	" start_col 表示关闭之前的'字符数'，或者说'串长度'
        let start_col = col('.') - 1

	"  至少得有两个字符以上，才能判断
	if start_col <= 1
	    return -1
	endif
        let line = getline('.')[:start_col-1]
	" 本智能补全提供以下几种补全方式：
	"
	"   -	之前一个字符是空格或者-，则触发“工具.参数”补全
	"   -	为“$(”，则触发“函数”补全，即make内建函数
	"   -	为“-I”，则触发“include_dir”补全。
	"   -	为“-L”，则触发“lib_dir”补全。
	"   -	为“-D”，则触发“常用预编译控制的macro”补全
	"
	if line =~ '\$(\%(\w[a-z-]*\)\=$'
	    let func_pat = matchstr(line, '\$(\%(\w[a-z-]*\)\=$')
	    let b:func_pat = escape(func_pat, '^$ \.')
	    return start_col - strlen(func_pat)
	elseif line =~ '-l\%(\i\|\.\)*$'
	    let arch_pat = matchstr(line, '-l\%(\i\|\.\)*$')
	    let b:arch_pat = arch_pat
	    return start_col - strlen(arch_pat)
	elseif line =~ '-I\s*$'
	    let inc_pat = matchstr(line, '-I\zs\s*$')
	    let b:inc_pat = 1
	    return start_col - strlen(inc_pat)
	elseif line =~ '-L\s*$'
	    let lib_pat = matchstr(line, '-L\zs\s*$')
	    let b:lib_pat = 1
	    return start_col - strlen(lib_pat)
	elseif line =~ '\s\%(-\w*\)\=$'
	    " “工具.参数”补全分为三种；
	    " 1)  ^\s\+-\=@\=\w[\w+]
	    " 		即行首就是工具的名字
	    " 2) ^\s\+-\=@\=\$(\w[\w+])
	    " 		即使用了变量模式
	    " 		此种情况，可以使用normal gD找到定义处，然后解析之（此
	    " 		解析可能还会遇到include other-makefile的问题
	    " 3)  之前的一行使用了续行符——回溯若干行，知道遇到情况1)或者2)
	    let tool_name = matchstr(line, '[a-zA-Z+]\+')
	    " TODO 当遇到 $(CXX) 这样的情况时，可以normal gD，然后分析该处的情况。再“`.”回来
	    if !has_key(g:Mingw_tool_para_dict, tool_name)
		return -1
	    endif
	    let b:tool_name = tool_name
	    return start_col
	else
	    return -1
	endif

	" the second time call this function
    else
	if exists('b:tool_name')
	    let tool_name = b:tool_name
	    unlet b:tool_name
	    return g:Mingw_tool_para_dict[tool_name]
	elseif exists('b:func_pat')
	    let func_pat = b:func_pat
	    unlet b:func_pat
	    let match_funcs = []
	    for entry in g:Mingw_make_functions['funcs']
		" type(entry)==type("") && entry =~ func_pat ||
	        if type(entry)==type({}) && entry['word'] =~ func_pat
		    call add(match_funcs, entry)
	        endif
	    endfor
	    return match_funcs
	elseif exists('b:arch_pat')
	    let arch_pat = b:arch_pat
	    unlet b:arch_pat
	    let matchs = []
	    for entry in g:Mingw_usr_libs
	        if entry =~ arch_pat
		    call add(matchs, entry)
	        endif
	    endfor
	    return matchs
	elseif exists('b:inc_pat')
	    unlet b:inc_pat
	    return g:Mingw_usr_library_dirs['inc']
	elseif exists('b:lib_pat')
	    unlet b:lib_pat
	    return g:Mingw_usr_library_dirs['lib']
	endif
    endif
endfun
setlocal completefunc=Make_Omni_Complete

