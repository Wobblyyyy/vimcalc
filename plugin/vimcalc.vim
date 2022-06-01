" vimcalc - a lightweight wrapper for v_calc
" https://github.com/Wobblyyyy/v_calc

scriptencoding=utf-8

if exists('g:did_vimcalc_load') || v:version < 800
    finish
endif

let g:vimcalcPath = get(g:, 'vimcalcPath', stdpath('data') . '/plugged/vimcalc/calc')

function! s:Calc(...)
    execute '!' . g:vimcalcPath . ' c ' . a:1
endfunction

function! s:Vcalc(...)
    execute '!' . g:vimcalcPath . ' vc ' . a:1
endfunction

function! s:Icalc(...)
    execute '!' . g:vimcalcPath . ' i '
endfunction

command! -nargs=? Calc call s:Calc(<f-args>)
command! -nargs=? Vcalc call s:Vcalc(<f-args>)
command! -nargs=? Icalc call s:Icalc(<f-args>)

let g:did_vimcalc_load = 1
