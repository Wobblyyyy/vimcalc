# vimcalc
Incredibly lightweight and minimal wrapper for
[clicalc](https://github.com/Wobblyyyy/v_calc). This provides no additional
functionality: it simply allows you to clicalc from inside the Vim editor.

## Usage

### Regular `calc` command
```vim
:Calc 10+10
:Calc 10+10*[40*2]
:Calc 10+10*[cos{sin{3}}]
```

### `vcalc` command
```vim
:Vcalc 10+10
:Vcalc 10+10*[40*2]
:Vcalc 10+10*[cos{sin{3}}]
```

## License
Who cares, to be honest? This entire project is... say... maybe... 20 lines
of code? MIT. Why not?
