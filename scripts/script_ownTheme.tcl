# --------------------------------------------------------------------
# --   *****************************
# --   *   Trenz Electronic GmbH   *
# --   *   Beendorfer Straße 23    *
# --   *   32609 Hüllhorst         *
# --   *   Germany                 *
# --   *****************************
# --------------------------------------------------------------------
# -- $Author: Dück, Thomas $
# -- $Email: t.dueck@trenz-electronic.de $
# --------------------------------------------------------------------
# -- Change History:
# ------------------------------------------
# -- $Date: 2020/03/08 | $Author: Dück, Thomas
# -- - initial release
# ------------------------------------------
# -- $Date: 2020/04/07 | $Author: Dück, Thomas
# -- - add TProgressbar configuration
# ------------------------------------------
# --------------------------------------------------------------------
# --------------------------------------------------------------------

namespace eval ttk::theme::ownTheme {
  variable ::colors 
  array set ::colors {
    -white      "#ffffff"
    -black      "#000000"
    -lightgrey  "#F0F0F0"
    -grey       "#C8C8C8"
    -btngrey    "#e1e1e1"
    -darkgrey   "#767676"
    -highlight  "#e5f1fb"
    -lightblue  "#cce4f7"
    -blue       "#0078d7"
    -red        "#FF0000"
    -green      "#2FAA20"
    -magenta    "#FF00FF"
  }
  
  if {$::tcl_platform(platform) eq "windows"} {
    font create ownfont \
      -family "Arial" \
      -size 9 \
      -weight normal \
      -slant roman \
      ;
      
    font create ownfont_bold \
      -family "Arial" \
      -size 9 \
      -weight bold \
      -slant roman \
      ;
      
    font create ownfont_12bold \
      -family "Arial" \
      -size 12 \
      -weight bold \
      -slant roman \
      ;
  } else {
    font create ownfont \
      -family newspaper \
      -size 9 \
      -weight normal \
      -slant roman \
      ;
    
    font create ownfont_bold \
      -family newspaper \
      -size 9 \
      -weight bold \
      -slant roman \
      ;
    
    font create ownfont_12bold \
      -family newspaper \
      -size 12 \
      -weight bold \
      -slant roman \
      ;
  }

  ttk::style configure "." \
      -background $::colors(-lightgrey) \
      -foreground $::colors(-black) \
      -bordercolor $::colors(-grey) \
      -darkcolor $::colors(-lightgrey) \
      -lightcolor $::colors(-lightgrey) \
      -troughcolor $::colors(-grey) \
      -selectbackground $::colors(-blue) \
      -selectforeground $::colors(-white) \
      -selectborderwidth 0 \
      -font ownfont \
      ;

  ttk::style map "." \
      -background [list \
      disabled $::colors(-lightgrey) \
      active $::colors(-highlight)] \
    ;

  # Button:
  ttk::style configure TButton \
      -anchor center \
    -width -11 \
    -padding {1 1} \
    -relief raised \
    -shiftrelief 1 \
    -background $::colors(-btngrey) \
    -darkcolor $::colors(-btngrey) \
    -lightcolor $::colors(-btngrey) \
    -bordercolor $::colors(-grey) \
    ;
    
  ttk::style map TButton \
      -background [list \
      disabled $::colors(-grey) \
      pressed $::colors(-lightblue) \
      active $::colors(-highlight)] \
    -highlightcolor [list \
      pressed $::colors(-lightblue)] \
      -lightcolor [list \
      pressed $::colors(-lightblue) \
      disabled $::colors(-grey)] \
      -darkcolor [list \
      pressed $::colors(-lightblue) \
      disabled $::colors(-grey)] \
      -bordercolor [list \
      pressed $::colors(-blue)\
      active $::colors(-blue) \
      disabled $::colors(-grey)] \
    ;

  # Toolbutton;
  ttk::style configure Toolbutton \
      -anchor center \
    -padding 2 \
    -relief flat \
    ;
    
  ttk::style map Toolbutton \
      -relief [list \
      disabled flat \
      selected sunken \
      pressed sunken \
      active raised] \
      -background [list \
      disabled $::colors(-grey) \
      pressed $::colors(-lightblue) \
      active $::colors(-highlight)] \
      -lightcolor [list \
      pressed $::colors(-lightblue) \
      disabled $::colors(-grey)] \
      -darkcolor [list \
      pressed $::colors(-lightblue) \
      disabled $::colors(-grey)] \
      ;

  # Checkbutton / Radiobutton:
  ttk::style configure TCheckbutton \
      -indicatorbackground "#ffffff" \
      -indicatormargin {1 1 4 1} \
      -padding 2 \
    ;
  
  ttk::style configure TRadiobutton \
      -indicatorbackground "#ffffff" \
      -indicatormargin {1 1 4 1} \
      -padding 2 \
    ;
    
  ttk::style map TCheckbutton \
    -foreground [list \
      {!disabled active} $::colors(-blue) \
      disabled $::colors(-grey) \
      !selected $::colors(-black)] \
    -indicatorbackground [list \
      disabled $::colors(-white) \
      pressed $::colors(-lightgrey)] \
    -background [list \
      active $::colors(-lightgrey)] \
    ;
    
  ttk::style map TRadiobutton \
    -foreground [list \
      {!disabled active} $::colors(-blue) \
      disabled $::colors(-grey) \
      !selected $::colors(-black)] \
    -indicatorbackground [list \
      disabled $::colors(-white) \
      pressed $::colors(-lightgrey)] \
    -background [list \
      active $::colors(-lightgrey)] \
    ;
    
  # Combobox:
  ttk::style configure TCombobox \
    -padding 1 \
    -insertwidth 1 \
    -background $::colors(-white) \
    -bordercolor $::colors(-grey) \
    ;
  ttk::style map TCombobox \
    -selectbackground [list \
      !focus  $::colors(-white)] \
      -selectforeground [list \
      !focus  $::colors(-black)] \
      -background [list \
      active $::colors(-highlight)] \
      -fieldbackground [list \
      {readonly focus} $::colors(-blue) \
      readonly $::colors(-white)] \
      -foreground [list \
      {readonly focus} $::colors(-white) \
      disabled $::colors(-grey)] \
       -focusfill  [list \
      {readonly focus} $::colors(-highlight)] \
      ;
    
  ttk::style configure ComboboxPopdownFrame \
      -relief solid \
    -borderwidth 1 \
    -background $::colors(-white) \
    -fieldbackground $::colors(-white) \
    -selectbackground $::colors(-blue) \
    ;

  # Treeview:
  ttk::style configure Heading \
    -padding {3} \
    -background $::colors(-white) \
    -bordercolor $::colors(-white) \
    -lightcolor $::colors(-grey) \
    -darkcolor $::colors(-white) \
    ;
    
  ttk::style configure Treeview \
    -background $::colors(-white) \
    ;
  ttk::style map Treeview \
      -background [list \
      selected $::colors(-blue)] \
      -foreground [list \
      selected $::colors(-white)] \
    ;
    
  # Entry:
  ttk::style configure TEntry \
    -padding {2 2 2 4} \
    ;
  ttk::style map TEntry \
    -selectbackground [list \
      !focus $::colors(-white)] \
      -selectforeground [list \
      !focus $::colors(-black)] \
      ;
    
  # Labelframe:  
    ttk::style configure TLabelframe \
      -labeloutside false \
    -labelmargins {10 0 0 0} \
      -borderwidth 2 \
    ;
    
  ttk::style configure TLabelframe.Label \
    -foreground "#0046d5" \
    ;

  # Scrollbar:
  ttk::style configure TScrollbar \
    -relief raised \
    -troughcolor $::colors(-lightgrey) \
    -bordercolor $::colors(-btngrey) \
    -darkcolor $::colors(-grey) \
    -lightcolor $::colors(-btngrey) \
    -background $::colors(-btngrey) \
    -foreground $::colors(-lightgrey) \
    ;
    
  ttk::style map TScrollbar \
    -arrowcolor [list \
      {!disabled active} $::colors(-black) \
      disabled $::colors(-grey)] \
    -background [list \
      disabled $::colors(-lightgrey) \
      {!disabled active} $::colors(-grey) \
      pressed $::colors(-grey)] \
    -lightcolor [list \
      disabled $::colors(-lightgrey) \
      {!disabled active} $::colors(-grey)] \
    -bordercolor [list \
      disabled $::colors(-lightgrey) \
      {!disabled active} $::colors(-grey)] \
    -darkcolor [list \
      disabled $::colors(-lightgrey) \
      {!disabled active} $::colors(-grey)] \
    ;
  
  # Progressbar:
  ttk::style configure TProgressbar \
    -background $::colors(-blue) \
    -troughcolor $::colors(-btngrey) \
    -darkcolor $::colors(-blue) \
    -lightcolor $::colors(-blue) \
    -bordercolor $::colors(-grey) \
    ;

  ttk::style configure Sash -sashthickness 6 -gripcount 10
}
