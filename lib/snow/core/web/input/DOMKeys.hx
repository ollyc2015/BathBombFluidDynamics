package snow.core.web.input;

import snow.types.Types;

@:noCompletion
class DOMKeys {

        /** This function takes the DOM keycode and translates it into the
            corresponding snow Keycodes value - but only if needed for special cases */
    public static function dom_key_to_keycode(_keycode:Int) {

        switch(_keycode) {

        //
            case dom_shift:         return Key.lshift;     //:todo : this is both left/right but returns left
            case dom_ctrl:          return Key.lctrl;      //:todo : ^
            case dom_alt:           return Key.lalt;       //:todo : ^
            case dom_capslock:      return Key.capslock;
        //
            case dom_pageup:        return Key.pageup;
            case dom_pagedown:      return Key.pagedown;
            case dom_end:           return Key.end;
            case dom_home:          return Key.home;
            case dom_left:          return Key.left;
            case dom_up:            return Key.up;
            case dom_right:         return Key.right;
            case dom_down:          return Key.down;
            case dom_printscr:      return Key.printscreen;
            case dom_insert:        return Key.insert;
            case dom_delete:        return Key.delete;
        //
            case dom_lmeta:         return Key.lmeta;
            case dom_rmeta:         return Key.rmeta;
            case dom_meta:          return Key.lmeta;
        //
            case dom_kp_0:          return Key.kp_0;
            case dom_kp_1:          return Key.kp_1;
            case dom_kp_2:          return Key.kp_2;
            case dom_kp_3:          return Key.kp_3;
            case dom_kp_4:          return Key.kp_4;
            case dom_kp_5:          return Key.kp_5;
            case dom_kp_6:          return Key.kp_6;
            case dom_kp_7:          return Key.kp_7;
            case dom_kp_8:          return Key.kp_8;
            case dom_kp_9:          return Key.kp_9;
            case dom_kp_multiply:   return Key.kp_multiply;
            case dom_kp_plus:       return Key.kp_plus;
            case dom_kp_minus:      return Key.kp_minus;
            case dom_kp_decimal:    return Key.kp_decimal;
            case dom_kp_divide:     return Key.kp_divide;
            case dom_kp_numlock:    return Key.numlockclear;
        //
            case dom_f1:            return Key.f1;
            case dom_f2:            return Key.f2;
            case dom_f3:            return Key.f3;
            case dom_f4:            return Key.f4;
            case dom_f5:            return Key.f5;
            case dom_f6:            return Key.f6;
            case dom_f7:            return Key.f7;
            case dom_f8:            return Key.f8;
            case dom_f9:            return Key.f9;
            case dom_f10:           return Key.f10;
            case dom_f11:           return Key.f11;
            case dom_f12:           return Key.f12;
            case dom_f13:           return Key.f13;
            case dom_f14:           return Key.f14;
            case dom_f15:           return Key.f15;
            case dom_f16:           return Key.f16;
            case dom_f17:           return Key.f17;
            case dom_f18:           return Key.f18;
            case dom_f19:           return Key.f19;
            case dom_f20:           return Key.f20;
            case dom_f21:           return Key.f21;
            case dom_f22:           return Key.f22;
            case dom_f23:           return Key.f23;
            case dom_f24:           return Key.f24;
        //
            case dom_caret:         return Key.caret;
            case dom_exclaim:       return Key.exclaim;
            case dom_quotedbl:      return Key.quotedbl;
            case dom_hash:          return Key.hash;
            case dom_dollar:        return Key.dollar;
            case dom_percent:       return Key.percent;
            case dom_ampersand:     return Key.ampersand;
            case dom_underscore:    return Key.underscore;
            case dom_leftparen:     return Key.leftparen;
            case dom_rightparen:    return Key.rightparen;
            case dom_asterisk:      return Key.asterisk;
            case dom_plus:          return Key.plus;
            case dom_pipe:          return Key.backslash; // pipe
            case dom_minus:         return Key.minus;
            case dom_leftbrace:     return Key.leftbracket; // {, same code as [ on native...
            case dom_rightbrace:    return Key.rightbracket; // }, same code as ] on native...
            case dom_tilde:         return Key.backquote; // tilde
        //
            case dom_audiomute:     return Key.audiomute;
            case dom_volumedown:    return Key.volumedown;
            case dom_volumeup:      return Key.volumeup;
        //
            case dom_comma:         return Key.comma;
            case dom_period:        return Key.period;
            case dom_slash:         return Key.slash;
            case dom_backquote:     return Key.backquote;
            case dom_leftbracket:   return Key.leftbracket;
            case dom_rightbracket:  return Key.rightbracket;
            case dom_backslash:     return Key.backslash;
            case dom_quote:         return Key.quote;

        } //switch(_keycode)

        return _keycode;

    } //dom_key_to_keycode

// the keycodes below are dom specific keycodes mapped to snow input names
// these values *come from the browser* dom spec codes only, some info here
// http://www.w3.org/TR/DOM-Level-3-Events/#determine-keydown-keyup-keyCode

//
    static inline var dom_shift          = 16;
    static inline var dom_ctrl           = 17;
    static inline var dom_alt            = 18;
    static inline var dom_capslock       = 20;
//
    static inline var dom_pageup         = 33;
    static inline var dom_pagedown       = 34;
    static inline var dom_end            = 35;
    static inline var dom_home           = 36;
    static inline var dom_left           = 37;
    static inline var dom_up             = 38;
    static inline var dom_right          = 39;
    static inline var dom_down           = 40;
    static inline var dom_printscr       = 44;
    static inline var dom_insert         = 45;
    static inline var dom_delete         = 46;
//
    static inline var dom_lmeta          = 91;
    static inline var dom_rmeta          = 93;
//
    static inline var dom_kp_0           = 96;
    static inline var dom_kp_1           = 97;
    static inline var dom_kp_2           = 98;
    static inline var dom_kp_3           = 99;
    static inline var dom_kp_4           = 100;
    static inline var dom_kp_5           = 101;
    static inline var dom_kp_6           = 102;
    static inline var dom_kp_7           = 103;
    static inline var dom_kp_8           = 104;
    static inline var dom_kp_9           = 105;
    static inline var dom_kp_multiply    = 106;
    static inline var dom_kp_plus        = 107;
    static inline var dom_kp_minus       = 109;
    static inline var dom_kp_decimal     = 110;
    static inline var dom_kp_divide      = 111;
    static inline var dom_kp_numlock     = 144;
//
    static inline var dom_f1             = 112;
    static inline var dom_f2             = 113;
    static inline var dom_f3             = 114;
    static inline var dom_f4             = 115;
    static inline var dom_f5             = 116;
    static inline var dom_f6             = 117;
    static inline var dom_f7             = 118;
    static inline var dom_f8             = 119;
    static inline var dom_f9             = 120;
    static inline var dom_f10            = 121;
    static inline var dom_f11            = 122;
    static inline var dom_f12            = 123;
    static inline var dom_f13            = 124;
    static inline var dom_f14            = 125;
    static inline var dom_f15            = 126;
    static inline var dom_f16            = 127;
    static inline var dom_f17            = 128;
    static inline var dom_f18            = 129;
    static inline var dom_f19            = 130;
    static inline var dom_f20            = 131;
    static inline var dom_f21            = 132;
    static inline var dom_f22            = 133;
    static inline var dom_f23            = 134;
    static inline var dom_f24            = 135;
//
    static inline var dom_caret          = 160;
    static inline var dom_exclaim        = 161;
    static inline var dom_quotedbl       = 162;
    static inline var dom_hash           = 163;
    static inline var dom_dollar         = 164;
    static inline var dom_percent        = 165;
    static inline var dom_ampersand      = 166;
    static inline var dom_underscore     = 167;
    static inline var dom_leftparen      = 168;
    static inline var dom_rightparen     = 169;
    static inline var dom_asterisk       = 170;
    static inline var dom_plus           = 171;
    static inline var dom_pipe           = 172; //backslash
    static inline var dom_minus          = 173;
    static inline var dom_leftbrace      = 174;
    static inline var dom_rightbrace     = 175;
    static inline var dom_tilde          = 176;
//
    static inline var dom_audiomute      = 181;
    static inline var dom_volumedown     = 182;
    static inline var dom_volumeup       = 183;
//
    static inline var dom_comma          = 188;
    static inline var dom_period         = 190;
    static inline var dom_slash          = 191;
    static inline var dom_backquote      = 192;
    static inline var dom_leftbracket    = 219;
    static inline var dom_rightbracket   = 221;
    static inline var dom_backslash      = 220;
    static inline var dom_quote          = 222;
    static inline var dom_meta           = 224;

} //DOM_SDL_keys